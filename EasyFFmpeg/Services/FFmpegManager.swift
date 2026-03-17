import Foundation
import Combine
import SwiftUI

@MainActor
class FFmpegManager: ObservableObject {
    static let shared = FFmpegManager()

    @Published var installedVersion: String?
    @Published var ffmpegSource: FFmpegSource = .notFound
    @Published var ffmpegPath: String?
    @Published var isChecking: Bool = false
    @Published var homebrewInstalled: Bool = false
    @Published var codecSupport: [String: Bool] = [:]
    @Published var isInstalling: Bool = false
    @Published var installProgress: String = ""
    @Published var installLog: String = ""

    enum FFmpegSource: String {
        case bundled  = "Встроенный"
        case homebrew = "Homebrew"
        case system   = "Системный"
        case notFound = "Не найден"
    }

    private let homebrewPaths = ["/opt/homebrew/bin/ffmpeg", "/usr/local/bin/ffmpeg"]
    private let homebrewBin   = ["/opt/homebrew/bin/brew", "/usr/local/bin/brew"]

    // MARK: - Detection

    func detectFFmpeg() async {
        isChecking = true
        defer { isChecking = false }

        // 1. Check Homebrew first (user-installed, supports updates)
        for path in homebrewPaths {
            if FileManager.default.fileExists(atPath: path) {
                if let v = await getVersion(at: path) {
                    ffmpegPath = path
                    ffmpegSource = .homebrew
                    installedVersion = v
                    homebrewInstalled = checkHomebrew()
                    await checkCodecSupport(at: path)
                    return
                }
            }
        }

        // 2. System PATH fallback
        if let path = await findInPATH("ffmpeg") {
            if let v = await getVersion(at: path) {
                ffmpegPath = path
                ffmpegSource = .system
                installedVersion = v
                homebrewInstalled = checkHomebrew()
                await checkCodecSupport(at: path)
                return
            }
        }

        ffmpegSource = .notFound
        ffmpegPath = nil
        installedVersion = nil
        homebrewInstalled = checkHomebrew()
    }

    func getVersion(at path: String) async -> String? {
        let result = await runCommand(path, args: ["-version"])
        guard let output = result else { return nil }
        // "ffmpeg version 7.1 Copyright..."
        let line = output.components(separatedBy: "\n").first ?? ""
        let parts = line.components(separatedBy: " ")
        if parts.count >= 3, parts[0] == "ffmpeg", parts[1] == "version" {
            return parts[2]
        }
        return nil
    }

    func checkCodecSupport(at path: String) async {
        let result = await runCommand(path, args: ["-codecs"]) ?? ""
        let checks: [(VideoCodec, String)] = [
            (.h264,   "libx264"),
            (.h265,   "libx265"),
            (.h265Hw, "hevc_videotoolbox"),
            (.vp9,    "libvpx-vp9"),
            (.av1,    "libsvtav1"),
        ]
        var support: [String: Bool] = [:]
        for (codec, needle) in checks {
            support[codec.rawValue] = result.contains(needle)
        }
        codecSupport = support
    }

    // MARK: - Homebrew


    /// Returns true if check succeeded (even if no update available), false if network error
    func checkForUpdates() async -> Bool {
        guard let url = URL(string: "https://formulae.brew.sh/api/formula/ffmpeg.json") else { return false }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let versions = json["versions"] as? [String: Any],
               let stable = versions["stable"] as? String {
                let current = installedVersion ?? ""
                if !stable.isEmpty && stable != current {
                    installProgress = "Доступна новая версия: \(stable) (установлена: \(current))"
                } else {
                    installProgress = "FFmpeg актуален (\(current))"
                }
                return true
            }
        } catch { }
        return false
    }

    func checkHomebrew() -> Bool {
        homebrewBin.contains { FileManager.default.fileExists(atPath: $0) }
    }

    var brewPath: String? { homebrewBin.first { FileManager.default.fileExists(atPath: $0) } }

    func installFFmpegViaHomebrew() async {
        guard let brew = brewPath else { return }
        isInstalling = true
        installLog = ""
        defer { isInstalling = false }

        installProgress = "Обновление индекса Homebrew..."
        _ = await runCommandStreaming(brew, args: ["update"])

        installProgress = "Установка ffmpeg..."
        _ = await runCommandStreaming(brew, args: ["install", "ffmpeg"])

        installProgress = "Проверка установки..."
        await detectFFmpeg()
        installProgress = ffmpegPath != nil ? "FFmpeg успешно установлен!" : "Ошибка установки"
    }

    func updateFFmpegViaHomebrew() async {
        guard let brew = brewPath else { return }
        isInstalling = true
        installLog = ""
        defer { isInstalling = false }

        installProgress = "Обновление ffmpeg..."
        _ = await runCommandStreaming(brew, args: ["upgrade", "ffmpeg"])

        await detectFFmpeg()
        installProgress = "Обновление завершено. Версия: \(installedVersion ?? "?")"
    }

    // MARK: - Helpers

    private func findInPATH(_ binary: String) async -> String? {
        let result = await runCommand("/usr/bin/which", args: [binary])
        let path = result?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return path.isEmpty ? nil : path
    }

    private func runCommand(_ executable: String, args: [String]) async -> String? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                let p = Process()
                p.executableURL = URL(fileURLWithPath: executable)
                p.arguments = args
                let pipe = Pipe()
                p.standardOutput = pipe
                p.standardError  = pipe
                p.environment    = Self.makeChildEnv()
                do {
                    try p.run(); p.waitUntilExit()
                    let data = pipe.fileHandleForReading.readDataToEndOfFile()
                    continuation.resume(returning: String(data: data, encoding: .utf8))
                } catch {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    @discardableResult
    private func runCommandStreaming(_ executable: String, args: [String]) async -> String {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                let p = Process()
                p.executableURL = URL(fileURLWithPath: executable)
                p.arguments = args
                let pipe = Pipe()
                p.standardOutput = pipe
                p.standardError  = pipe
                p.environment    = Self.makeChildEnv()

                pipe.fileHandleForReading.readabilityHandler = { handle in
                    let data = handle.availableData
                    guard !data.isEmpty, let text = String(data: data, encoding: .utf8) else { return }
                    Task { @MainActor in
                        self.installLog += text
                        // Show last non-empty line as progress
                        let lines = text.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                        if let last = lines.last { self.installProgress = last }
                    }
                }

                do {
                    try p.run(); p.waitUntilExit()
                    pipe.fileHandleForReading.readabilityHandler = nil
                    let data = pipe.fileHandleForReading.readDataToEndOfFile()
                    continuation.resume(returning: String(data: data, encoding: .utf8) ?? "")
                } catch {
                    continuation.resume(returning: error.localizedDescription)
                }
            }
        }
    }

    nonisolated static func makeChildEnv() -> [String: String] {
        var env = ProcessInfo.processInfo.environment
        env["PATH"] = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
        return env
    }
}
