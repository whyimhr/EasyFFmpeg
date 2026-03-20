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
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(Theme.amber)
                        Text(t(.ffmpegNotFound) + ". " + (langMgr.language == .english
                             ? "Go to FFmpeg section in the sidebar."
                             : "Перейдите в раздел FFmpeg в боковом меню."))
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.text2)
                        Spacer()
                    }
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(Theme.amber.opacity(0.08))
                    .overlay(
                        Rectangle().frame(height: 1).foregroundStyle(Theme.amber.opacity(0.2)),
                        alignment: .bottom
                    )
                }

                if vm.selectedFileURL == nil {
                    DropZoneView(langMgr: langMgr) { url in vm.selectFile(url) }
                        .padding(20).padding(.top, 8)
                } else {
                    if vm.isAnalyzing {
                        HStack(spacing: 8) {
                            ProgressView().scaleEffect(0.8)
                            Text(t(.analyzing))
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.text3)
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 20)
                    }
                    if let err = vm.analysisError {
                        Text("\(t(.analysisError)): \(err)")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.red)
                            .padding(.horizontal, 20).padding(.top, 8)
                    }

                    if let metadata = vm.metadata {
                        HStack(alignment: .top, spacing: 14) {
                            VStack(spacing: 12) {
                                FileInfoView(metadata: metadata) { vm.resetFile() }

                                if let est = vm.estimation {
                                    EstimationView(metadata: metadata, estimation: est)
                                }

                                if !vm.isEncoding && !vm.encodingDone && vm.encodingError == nil {
                                    OutputSettingsView(
                                        outputFileName: $vm.outputFileName,
                                        outputFolderURL: $vm.outputFolderURL,
                                        onChooseFolder: { vm.chooseOutputFolder() },
                                        onStartEncoding: { vm.startEncoding() },
                                        isStartDisabled: vm.outputFileName
                                            .trimmingCharacters(in: .whitespaces).isEmpty
                                    )
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .fixedSize(horizontal: false, vertical: true)
                            .opacity(vm.isEncoding ? 0.45 : 1.0)
                            .allowsHitTesting(!vm.isEncoding)
                            .animation(.easeInOut(duration: 0.2), value: vm.isEncoding)

                            VStack(spacing: 12) {
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
                                    AppCard(
                                        icon: "gearshape",
                                        title: langMgr.language == .english
                                            ? "Compression Settings"
                                            : "Настройки сжатия"
                                    ) {
                                        PresetsAndSettingsView(
                                            selectedPresetID: vm.selectedPreset.id,
                                            onSelect: { vm.applyPreset($0) },
                                            settings: $vm.settings
                                        )
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 18)
                    }
                }
            }
            .padding(.bottom, 32)
        }
        .background(Theme.panel)
        // Tap outside text field to dismiss keyboard
        .simultaneousGesture(
            TapGesture().onEnded {
                NSApp.keyWindow?.makeFirstResponder(nil)
            }
        )
        .navigationTitle(t(.singleFile))
    }
}
