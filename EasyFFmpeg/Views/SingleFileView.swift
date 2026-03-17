import SwiftUI

struct SingleFileView: View {
    @EnvironmentObject var vm: MainViewModel
    @EnvironmentObject var langMgr: LanguageManager
    private func t(_ k: L10n.Key) -> String { L10n.string(k, language: langMgr.language) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if !FFmpegRunner.shared.isFFmpegAvailable {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.yellow)
                        Text(t(.ffmpegNotFound) + ". " + (langMgr.language == .english
                             ? "Go to FFmpeg section in the sidebar."
                             : "Перейдите в раздел FFmpeg в боковом меню."))
                            .font(.caption)
                        Spacer()
                    }
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(Color.yellow.opacity(0.12))
                    .overlay(Rectangle().frame(height: 1).foregroundStyle(Color.yellow.opacity(0.3)), alignment: .bottom)
                }

                if vm.selectedFileURL == nil {
                    DropZoneView(langMgr: langMgr) { url in vm.selectFile(url) }
                        .padding(20).padding(.top, 8)
                } else {
                    if vm.isAnalyzing {
                        HStack(spacing: 8) {
                            ProgressView().scaleEffect(0.8)
                            Text(t(.analyzing)).font(.caption).foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 20)
                    }
                    if let err = vm.analysisError {
                        Text("\(t(.analysisError)): \(err)").font(.caption).foregroundStyle(.red)
                            .padding(.horizontal, 20).padding(.top, 8)
                    }
                    if let metadata = vm.metadata {
                        GeometryReader { geo in
                            let colWidth = (geo.size.width - 20 * 2 - 16) / 2
                            HStack(alignment: .top, spacing: 16) {
                                // LEFT
                                VStack(spacing: 10) {
                                    FileInfoView(metadata: metadata) { vm.resetFile() }
                                    if let est = vm.estimation {
                                        EstimationView(metadata: metadata, estimation: est)
                                    }
                                    if !vm.isEncoding && !vm.encodingDone && vm.encodingError == nil {
                                        OutputSettingsView(
                                            outputFileName: $vm.outputFileName,
                                            outputFolderURL: $vm.outputFolderURL,
                                            onChooseFolder: { vm.chooseOutputFolder() }
                                        )
                                        Button {
                                            vm.startEncoding()
                                        } label: {
                                            HStack(spacing: 8) {
                                                Image(systemName: "play.fill")
                                                Text(t(.startEncoding)).fontWeight(.semibold)
                                            }
                                            .frame(maxWidth: .infinity).padding(.vertical, 6)
                                        }
                                        .buttonStyle(.borderedProminent).controlSize(.large)
                                        .disabled(vm.outputFileName.trimmingCharacters(in: .whitespaces).isEmpty)
                                    }
                                }
                                .frame(width: colWidth)

                                // RIGHT
                                VStack(spacing: 10) {
                                    if vm.isEncoding || vm.encodingDone || vm.encodingError != nil {
                                        EncodingProgressView(
                                            progress: vm.encodingProgress,
                                            fileName: metadata.fileName,
                                            onCancel: { vm.cancelEncoding() },
                                            isDone: vm.encodingDone,
                                            error: vm.encodingError,
                                            completionStats: vm.completionStats,
                                            onReveal: { vm.revealInFinder() },
                                            onReset: {
                                                vm.encodingDone = false
                                                vm.encodingError = nil
                                                vm.encodingProgress = nil
                                            }
                                        )
                                    } else {
                                        GroupBox {
                                            PresetsAndSettingsView(
                                                selectedPresetID: vm.selectedPreset.id,
                                                onSelect: { vm.applyPreset($0) },
                                                settings: $vm.settings
                                            )
                                            .padding(4)
                                        }
                                    }
                                }
                                .frame(width: colWidth)
                            }
                            .padding(.horizontal, 20).padding(.top, 16)
                        }
                        .frame(height: estimatedHeight(metadata: metadata))
                    }
                }
            }
            .padding(.bottom, 32)
        }
        .navigationTitle(t(.singleFile))
    }

    private func estimatedHeight(metadata: VideoMetadata) -> CGFloat {
        let rows = 6 + (metadata.videoBitrate != nil ? 1 : 0)
            + (metadata.audioCodec != nil ? 1 : 0)
            + (metadata.audioBitrate != nil ? 1 : 0)
        return CGFloat(80 + rows * 22) + 160 + 130 + 60 + 80
    }
}
