import Foundation
import UserNotifications
import IOKit.pwr_mgt
import Combine

class FFmpegRunner: ObservableObject {
    static let shared = FFmpegRunner()

    @Published var isRunning = false
    private(set) var lastCommand: String = ""
    private var currentProcess: Process?
    private var sleepAssertionID: IOPMAssertionID = 0

    var ffmpegPath: String? {
        // Check Homebrew locations directly — Xcode app has limited PATH
        let candidates = [
            "/opt/homebrew/bin/ffmpeg",      // Apple Silicon Homebrew
            "/usr/local/bin/ffmpeg",          // Intel Homebrew
            "/usr/bin/ffmpeg",                // System
        ]
        if let found = candidates.first(where: { FileManager.default.fileExists(atPath: $0) }) {
            return found
        }
        // Fallback to manager's detected path
        return FFmpegManager.shared.ffmpegPath
    }

    var isFFmpegAvailable: Bool { ffmpegPath != nil }

    // MARK: - Sleep prevention

    private func preventSleep() {
        let reason = "Video compression in progress" as CFString
        IOPMAssertionCreateWithName(
            kIOPMAssertionTypeNoIdleSleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &sleepAssertionID
        )
    }

    private func allowSleep() {
        if sleepAssertionID != 0 {
            IOPMAssertionRelease(sleepAssertionID)
            sleepAssertionID = 0
        }
    }

    // MARK: - Compress

    func compress(
        inputURL: URL,
        outputURL: URL,
        settings: CompressionSettings,
        metadata: VideoMetadata,
        onProgress: @escaping (EncodingProgress) -> Void
    ) async throws {
        guard let path = ffmpegPath else { throw AppError.ffmpegNotFound }

        let inputAccess  = inputURL.startAccessingSecurityScopedResource()
        let outputAccess = outputURL.deletingLastPathComponent().startAccessingSecurityScopedResource()
        defer {
            if inputAccess  { inputURL.stopAccessingSecurityScopedResource() }
            if outputAccess { outputURL.deletingLastPathComponent().stopAccessingSecurityScopedResource() }
        }

        let tmpDir = FileManager.default.temporaryDirectory
        let uid = UUID().uuidString
        let progressFile = tmpDir.appendingPathComponent("vcprog_\(uid).txt")
        let stderrFile   = tmpDir.appendingPathComponent("vcerr_\(uid).txt")
        FileManager.default.createFile(atPath: progressFile.path, contents: nil)
        FileManager.default.createFile(atPath: stderrFile.path,   contents: nil)
        defer {
            try? FileManager.default.removeItem(at: progressFile)
            try? FileManager.default.removeItem(at: stderrFile)
        }

        let args = settings.buildFFmpegArguments(
            inputPath: inputURL.path,
            outputPath: outputURL.path,
            progressFilePath: progressFile.path,
            metadata: metadata
        )

        let cmdString = ([path] + args)
            .map { $0.contains(" ") ? "\"\($0)\"" : $0 }
            .joined(separator: " ")
        await MainActor.run { self.lastCommand = cmdString }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = args
        process.environment = FFmpegManager.makeChildEnv()
        process.currentDirectoryURL = tmpDir
        process.standardInput  = FileHandle.nullDevice
        process.standardOutput = FileHandle.nullDevice
        let stderrHandle = FileHandle(forWritingAtPath: stderrFile.path)
        process.standardError  = stderrHandle ?? FileHandle.nullDevice

        self.currentProcess = process
        await MainActor.run { self.isRunning = true }
        preventSleep()

        let parser = ProgressParser(totalDuration: metadata.duration)
        let progressTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 500_000_000)
                guard let text = try? String(contentsOf: progressFile, encoding: .utf8),
                      !text.isEmpty else { continue }
                var latest: EncodingProgress?
                for line in text.components(separatedBy: "\n") {
                    if let p = parser.parse(line: line) { latest = p }
                }
                if let p = latest { await MainActor.run { onProgress(p) } }
            }
        }

        return try await withCheckedThrowingContinuation { continuation in
            process.terminationHandler = { [weak self] proc in
                progressTask.cancel()
                stderrHandle?.closeFile()
                self?.allowSleep()
                Task { @MainActor in self?.isRunning = false }
                self?.currentProcess = nil

                // Both .terminate() and user pressing cancel send SIGTERM (uncaughtSignal)
                // Also check for exit code 255 which ffmpeg uses on SIGTERM
                let wasCancelled = proc.terminationReason == .uncaughtSignal
                    || proc.terminationStatus == 255
                    || proc.terminationStatus == 143  // 128 + SIGTERM(15)

                if wasCancelled {
                    continuation.resume(throwing: AppError.cancelled)
                    return
                }
                if proc.terminationStatus == 0 {
                    self?.sendCompletionNotification(outputURL: outputURL)
                    continuation.resume()
                } else {
                    let errText = (try? String(contentsOf: stderrFile, encoding: .utf8)) ?? ""
                    let errLines = errText
                        .components(separatedBy: "\n")
                        .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                        .suffix(5)
                        .joined(separator: "\n")
                    let msg = [
                        errLines.isEmpty ? "Код: \(proc.terminationStatus)" : errLines,
                        "",
                        "Команда:",
                        cmdString
                    ].joined(separator: "\n")
                    continuation.resume(throwing: AppError.encodingFailed(msg))
                }
            }
            do {
                try process.run()
            } catch {
                progressTask.cancel()
                allowSleep()
                continuation.resume(throwing: error)
            }
        }
    }

    func cancel() {
        currentProcess?.terminate()
        currentProcess = nil
        allowSleep()
        isRunning = false
    }

    private func sendCompletionNotification(outputURL: URL) {
        let content = UNMutableNotificationContent()
        content.title = "Сжатие завершено"
        content.body = "Файл сохранён: \(outputURL.lastPathComponent)"
        content.sound = .default
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        )
    }
}
