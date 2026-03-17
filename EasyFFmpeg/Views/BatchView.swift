import SwiftUI

struct BatchView: View {
    @EnvironmentObject var vm: BatchViewModel
    @EnvironmentObject var langMgr: LanguageManager
    private func t(_ k: L10n.Key) -> String { L10n.string(k, language: langMgr.language) }

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack(spacing: 12) {
                Button { vm.chooseFolder() } label: {
                    Label(t(.batchOpenFolder), systemImage: "folder.badge.plus")
                }
                .buttonStyle(.bordered)
                Spacer()
                if !vm.jobs.isEmpty {
                    Text("\(vm.selectedJobs.count) из \(vm.jobs.count) файлов")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 20).padding(.vertical, 12)
            .background(Color(nsColor: .windowBackgroundColor))
            Divider()

            if vm.jobs.isEmpty { emptyState }
            else {
                HStack(alignment: .top, spacing: 0) {
                    jobsTable.frame(maxWidth: .infinity)
                    Divider()
                    // Fix 10: settings panel with tab (presets + manual)
                    batchSettings.frame(width: 320)
                }
            }
        }
        .navigationTitle(t(.batchProcessing))
    }

    // MARK: — Empty state

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.stack.3d.up.slash").font(.system(size: 52)).foregroundStyle(.secondary.opacity(0.35))
            Text(langMgr.language == .english ? "Choose a folder with videos" : "Выберите папку с видео").font(.title3).foregroundStyle(.secondary)
            Text(langMgr.language == .english ? "All video files from the folder will be added" : "Все видеофайлы из папки будут добавлены в список").font(.caption).foregroundStyle(.tertiary)
            Button(t(.batchOpenFolder) + "…") { vm.chooseFolder() }.buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: — Jobs table

    @ViewBuilder
    private var jobsTable: some View {
        Table(vm.jobs) {
            TableColumn("") { job in
                Toggle("", isOn: Binding(get: { job.isSelected }, set: { job.isSelected = $0 }))
                    .toggleStyle(.checkbox).disabled(vm.isRunning)
            }
            .width(28)
            TableColumn(t(.labelFile)) { job in
                Text(job.fileName).font(.caption).lineLimit(1).truncationMode(.middle)
            }
            TableColumn(t(.labelSize)) { job in
                Text(job.formattedSize).font(.caption).monospacedDigit().foregroundStyle(.secondary)
            }
            .width(70)
            TableColumn(t(.labelDuration)) { job in
                Text(job.metadata?.formattedDuration ?? "—").font(.caption).monospacedDigit().foregroundStyle(.secondary)
            }
            .width(80)
            TableColumn(langMgr.language == .english ? "Status" : "Статус") { job in
                JobStatusBadge(status: job.status)
            }
            .width(110)
        }
    }

    // MARK: — Settings panel (Fix 10: tabs for presets + manual)

    @ViewBuilder
    private var batchSettings: some View {
        ScrollView {
            VStack(spacing: 14) {
                // Stats
                GroupBox {
                    VStack(spacing: 8) {
                        statRow(t(.batchSelectedFiles), "\(vm.selectedJobs.count)")
                        statRow(t(.batchTotalSize), vm.formattedTotalSize)
                    }.padding(6)
                } label: {
                    Label(t(.batchStats), systemImage: "chart.pie")
                        .font(.subheadline).fontWeight(.semibold)
                }

                // Fix 5: compact preset radio list + settings tab
                GroupBox {
                    BatchPresetsView(
                        selectedPresetID: vm.selectedPreset.id,
                        onSelect: { vm.applyPreset($0) },
                        settings: $vm.settings
                    )
                    .padding(4)
                }

                // Output settings
                GroupBox {
                    VStack(alignment: .leading, spacing: 10) {
                        Toggle(t(.saveNextToOriginal), isOn: $vm.useSourceFolder)
                            .toggleStyle(.checkbox).font(.caption)
                        if !vm.useSourceFolder {
                            HStack {
                                Text(vm.outputFolderURL?.path ?? t(.notSelected))
                                    .font(.caption2).foregroundStyle(.secondary)
                                    .lineLimit(1).truncationMode(.middle).frame(maxWidth: .infinity, alignment: .leading)
                                Button("…") { vm.chooseOutputFolder() }.buttonStyle(.bordered).controlSize(.mini)
                            }
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(t(.fileNameSuffix) + ":").font(.caption2).foregroundStyle(.secondary)
                            TextField(t(.fileNameSuffix), text: $vm.suffix).textFieldStyle(.roundedBorder).font(.caption)
                        }
                    }
                    .padding(6)
                } label: {
                    Label(t(.batchSaving), systemImage: "square.and.arrow.down")
                        .font(.subheadline).fontWeight(.semibold)
                }

                // Progress
                if vm.isRunning {
                    GroupBox {
                        VStack(spacing: 8) {
                            Text("\(t(.batchFile)) \(vm.currentJobIndex + 1) \(t(.batchOf)) \(vm.selectedJobs.count)")
                                .font(.caption).foregroundStyle(.secondary)
                            ProgressView(value: Double(vm.currentJobIndex) / Double(max(vm.selectedJobs.count, 1)))
                                .progressViewStyle(.linear)
                            if let prog = vm.currentProgress {
                                ProgressView(value: prog.percentage).progressViewStyle(.linear).tint(.green)
                                HStack {
                                    Text(String(format: "%.0f%%", prog.percentage * 100))
                                    Spacer()
                                    Text(String(format: "%.1fx", prog.speed))
                                }
                                .font(.caption2).foregroundStyle(.secondary).monospacedDigit()
                            }
                        }.padding(6)
                    } label: {
                        Label(t(.batchProgress), systemImage: "gearshape.arrow.triangle.2.circlepath")
                            .font(.subheadline).fontWeight(.semibold)
                    }
                }

                // Action
                if vm.isRunning {
                    Button(t(.batchStop)) { vm.cancelBatch() }
                        .buttonStyle(.bordered).tint(.red).frame(maxWidth: .infinity)
                } else {
                    Button {
                        vm.startBatch()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                            Text(t(.batchStart)).fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 4)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(vm.selectedJobs.isEmpty)
                }
            }
            .padding(14)
            .padding(.bottom, 16)
        }
    }

    @ViewBuilder
    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.caption).fontWeight(.semibold).monospacedDigit()
        }
    }
}

struct JobStatusBadge: View {
    let status: JobStatus
    var body: some View {
        switch status {
        case .waiting:
            Text(L10n.string(.batchWaiting, language: LanguageManager.shared.language)).font(.caption2).foregroundStyle(.secondary)
        case .inProgress(let p):
            HStack(spacing: 4) {
                ProgressView(value: p).progressViewStyle(.linear).frame(width: 50).tint(.blue)
                Text(String(format: "%.0f%%", p * 100)).font(.caption2).foregroundStyle(.blue).monospacedDigit()
            }
        case .done:
            Label(L10n.string(.batchDone, language: LanguageManager.shared.language), systemImage: "checkmark.circle.fill").font(.caption2).foregroundStyle(.green).labelStyle(.iconOnly)
        case .failed:
            Label(L10n.string(.batchError, language: LanguageManager.shared.language), systemImage: "xmark.circle.fill").font(.caption2).foregroundStyle(.red)
        case .skipped:
            Text(L10n.string(.batchSkipped, language: LanguageManager.shared.language)).font(.caption2).foregroundStyle(.orange)
        }
    }
}


// MARK: — Fix 5: Batch preset picker — compact radio list + manual settings tab

struct BatchPresetsView: View {
    let selectedPresetID: String
    let onSelect: (Preset) -> Void
    @Binding var settings: CompressionSettings
    @State private var tab: Tab = .presets
    @EnvironmentObject var langMgr: LanguageManager
    private func t(_ k: L10n.Key) -> String { L10n.string(k, language: langMgr.language) }

    enum Tab { case presets, manual }

    var body: some View {
        VStack(spacing: 0) {
            // Tab selector
            HStack(spacing: 2) {
                tabButton(t(.preset), icon: "dial.medium",   active: tab == .presets) { tab = .presets }
                tabButton(t(.settingsTab), icon: "gearshape.2", active: tab == .manual)  { tab = .manual }
            }
            .padding(3)
            .background(Color.secondary.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 9))
            .padding(.bottom, 10)

            if tab == .presets {
                // Fix 5: Radio-style list — compact, full name visible
                VStack(spacing: 2) {
                    ForEach(Preset.all) { preset in
                        HStack(spacing: 8) {
                            // Radio indicator
                            Image(systemName: selectedPresetID == preset.id
                                  ? "circle.inset.filled"
                                  : "circle")
                                .font(.system(size: 13))
                                .foregroundStyle(selectedPresetID == preset.id
                                                 ? Color.accentColor : Color.secondary)

                            VStack(alignment: .leading, spacing: 1) {
                                Text(preset.localizedName(langMgr.language))
                                    .font(.caption)
                                    .fontWeight(selectedPresetID == preset.id ? .semibold : .regular)
                                    .foregroundStyle(selectedPresetID == preset.id ? .primary : .primary)
                                Text(preset.compressionRatio + " · " + preset.videoCodec.shortTag)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(selectedPresetID == preset.id
                                      ? Color.accentColor.opacity(0.06)
                                      : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(selectedPresetID == preset.id
                                              ? Color.accentColor.opacity(0.3)
                                              : Color.clear, lineWidth: 1)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture { onSelect(preset) }
                    }
                }
            } else {
                ManualSettingsInner(settings: $settings)
            }
        }
    }

    @ViewBuilder
    private func tabButton(_ label: String, icon: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 10, weight: .medium))
                Text(label).font(.system(size: 11, weight: active ? .semibold : .regular))
            }
            .padding(.horizontal, 12).padding(.vertical, 6)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 7)
                    .fill(active ? Color(nsColor: .controlBackgroundColor) : Color.clear)
                    .shadow(color: active ? .black.opacity(0.07) : .clear, radius: 2, y: 1)
            )
            .foregroundStyle(active ? .primary : .secondary)
        }
        .buttonStyle(.plain)
    }
}
