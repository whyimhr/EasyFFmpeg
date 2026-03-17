import SwiftUI
import UniformTypeIdentifiers
import Combine

@MainActor
class BatchViewModel: ObservableObject {
    @Published var jobs: [BatchJob] = []
    @Published var selectedPreset: Preset = Preset.universal
    @Published var settings: CompressionSettings = CompressionSettings.from(preset: Preset.universal)
    @Published var useCustomSettings: Bool = false  // Fix 10: manual settings toggle
    @Published var outputFolderURL: URL?
    @Published var useSourceFolder = true
    @Published var suffix = "_compressed"
    @Published var isRunning = false
    @Published var currentJobIndex = 0
    @Published var currentProgress: EncodingProgress?

    var selectedJobs: [BatchJob] { jobs.filter(\.isSelected) }

    var totalInputSize: Int64 { selectedJobs.reduce(0) { $0 + $1.fileSize } }

    var formattedTotalSize: String {
        let gb = Double(totalInputSize) / 1_073_741_824
        if gb >= 1 { return String(format: "%.2f ГБ", gb) }
        return String(format: "%.0f МБ", Double(totalInputSize) / 1_048_576)
    }

    func applyPreset(_ preset: Preset) {
        selectedPreset = preset
        if !useCustomSettings {
            settings = CompressionSettings.from(preset: preset)
        }
    }

    func chooseFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Выбрать папку"
        if panel.runModal() == .OK, let url = panel.url {
            loadVideos(from: url)
        }
    }

    func chooseOutputFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.prompt = "Выбрать"
        if panel.runModal() == .OK { outputFolderURL = panel.url }
    }

    private func loadVideos(from folder: URL) {
        let exts = Set(["mp4", "mov", "mkv", "avi", "webm"])
        guard let enumerator = FileManager.default.enumerator(
            at: folder,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
        ) else { return }
        jobs = []
        for case let url as URL in enumerator {
            if exts.contains(url.pathExtension.lowercased()) {
                jobs.append(BatchJob(fileURL: url))
            }
        }
        Task {
            for job in jobs {
                if let meta = try? await FFprobeAnalyzer.shared.analyze(url: job.fileURL) {
                    await MainActor.run { job.metadata = meta }
                }
            }
        }
    }

    func startBatch() {
        guard !isRunning else { return }
        isRunning = true; currentJobIndex = 0
        let toProcess = selectedJobs

        Task {
            for (i, job) in toProcess.enumerated() {
                currentJobIndex = i
                guard let metadata = job.metadata else {
                    job.status = .failed(error: "Нет метаданных"); continue
                }

                let finalSettings = useCustomSettings ? settings : CompressionSettings.from(preset: selectedPreset)
                let folder = useSourceFolder
                    ? job.fileURL.deletingLastPathComponent()
                    : (outputFolderURL ?? job.fileURL.deletingLastPathComponent())

                let ext = finalSettings.recommendedContainer
                let outURL = folder.appendingPathComponent(
                    "\(job.fileURL.deletingPathExtension().lastPathComponent)\(suffix).\(ext)"
                )

                job.status = .inProgress(progress: 0)
                do {
                    try await FFmpegRunner.shared.compress(
                        inputURL: job.fileURL, outputURL: outURL,
                        settings: finalSettings, metadata: metadata,
                        onProgress: { prog in
                            job.status = .inProgress(progress: prog.percentage)
                            self.currentProgress = prog
                        }
                    )
                    let size = (try? outURL.resourceValues(forKeys: [.fileSizeKey]).fileSize).map(Int64.init)
                    job.status = .done(outputSize: size ?? 0)
                } catch AppError.cancelled {
                    job.status = .waiting; break
                } catch {
                    job.status = .failed(error: error.localizedDescription)
                }
            }
            isRunning = false
        }
    }

    func cancelBatch() {
        FFmpegRunner.shared.cancel()
        isRunning = false
    }
}
