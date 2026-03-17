import SwiftUI
import Combine

@MainActor
class MainViewModel: ObservableObject {
    @Published var selectedFileURL: URL?
    @Published var metadata: VideoMetadata?
    @Published var isAnalyzing = false
    @Published var analysisError: String?

    @Published var selectedPreset: Preset = Preset.universal
    @Published var settings: CompressionSettings = .init()
    @Published var outputFileName: String = ""
    @Published var outputFolderURL: URL?

    @Published var estimation: EstimationResult?
    @Published var isEncoding = false
    @Published var encodingProgress: EncodingProgress?
    @Published var encodingError: String?
    @Published var encodingDone = false
    @Published var outputFileURL: URL?

    private var cancellables = Set<AnyCancellable>()

    init() {
        Publishers.CombineLatest($settings, $metadata)
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] settings, metadata in
                guard let self, let metadata else { return }
                self.estimation = SizeEstimator.estimate(settings: settings, metadata: metadata)
            }
            .store(in: &cancellables)
    }

    func selectFile(_ url: URL) {
        selectedFileURL = url
        outputFolderURL = url.deletingLastPathComponent()
        let name = url.deletingPathExtension().lastPathComponent
        outputFileName = "\(name)_compressed"
        analyzeFile(url)
    }

    func applyPreset(_ preset: Preset) {
        selectedPreset = preset
        settings = CompressionSettings.from(preset: preset)
    }

    private func analyzeFile(_ url: URL) {
        isAnalyzing = true; analysisError = nil; metadata = nil
        Task {
            do {
                let meta = try await FFprobeAnalyzer.shared.analyze(url: url)
                self.metadata = meta
                if let meta = self.metadata {
                    self.estimation = SizeEstimator.estimate(settings: self.settings, metadata: meta)
                }
            } catch {
                self.analysisError = error.localizedDescription
            }
            self.isAnalyzing = false
        }
    }

    func startEncoding() {
        guard let inputURL = selectedFileURL, let metadata else { return }
        // Auto-fix audio codec for container compatibility
        var finalSettings = settings
        finalSettings.autoSelectAudioCodec()

        let ext = finalSettings.recommendedContainer
        let folder = outputFolderURL ?? inputURL.deletingLastPathComponent()
        let outURL = folder.appendingPathComponent("\(outputFileName).\(ext)")
        outputFileURL = outURL

        isEncoding = true; encodingError = nil; encodingDone = false; encodingProgress = nil

        Task {
            do {
                try await FFmpegRunner.shared.compress(
                    inputURL: inputURL, outputURL: outURL,
                    settings: finalSettings, metadata: metadata,
                    onProgress: { [weak self] prog in self?.encodingProgress = prog }
                )
                self.encodingDone = true
            } catch AppError.cancelled {
                // no message
            } catch {
                self.encodingError = error.localizedDescription
            }
            self.isEncoding = false
        }
    }

    func cancelEncoding() { FFmpegRunner.shared.cancel(); isEncoding = false }

    func revealInFinder() {
        if let url = outputFileURL {
            NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: "")
        }
    }

    func chooseOutputFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false; panel.canChooseDirectories = true
        panel.prompt = "Выбрать"
        if panel.runModal() == .OK { outputFolderURL = panel.url }
    }

    func resetFile() {
        selectedFileURL = nil; metadata = nil; estimation = nil
        encodingDone = false; encodingError = nil; encodingProgress = nil
    }
}
