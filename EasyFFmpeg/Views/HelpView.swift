import SwiftUI

struct HelpView: View {
    @EnvironmentObject var langMgr: LanguageManager
    private func t(_ k: L10n.Key) -> String { L10n.string(k, language: langMgr.language) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                howToChooseSection
                presetComparisonTable
                videoCodecsSection
                audioCodecsSection
                parametersSection
                ffmpegCommandsSection
                tipsSection
            }
            .padding(24)
            .padding(.bottom, 32)
        }
        .navigationTitle(t(.helpTitle))
    }

    // MARK: — How to choose

    @ViewBuilder
    private var howToChooseSection: some View {
        section(title: t(.howToChoose), icon: "target") {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text(t(.situationLabel)).font(.caption).fontWeight(.semibold).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 12).padding(.vertical, 7)
                    Text(t(.recommendedPreset)).font(.caption).fontWeight(.semibold).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 12).padding(.vertical, 7)
                }
                .background(Color.secondary.opacity(0.08))
                Divider()
                let rows: [(String, L10n.Key, L10n.Key)] = [
                    ("❓", .howRow1, .howPreset1), ("⚡", .howRow2, .howPreset2),
                    ("💎", .howRow3, .howPreset3), ("🗜️", .howRow4, .howPreset4),
                    ("🎓", .howRow5, .howPreset5), ("📺", .howRow6, .howPreset6),
                    ("📦", .howRow7, .howPreset7), ("📟", .howRow8, .howPreset8),
                ]
                ForEach(Array(rows.enumerated()), id: \.offset) { idx, row in
                    HStack(spacing: 0) {
                        HStack(spacing: 6) {
                            Text(row.0).font(.caption)
                            Text(t(row.1)).font(.caption)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 12).padding(.vertical, 7)
                        Text(t(row.2)).font(.caption).fontWeight(.medium).foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 12).padding(.vertical, 7)
                    }
                    if idx < rows.count - 1 { Divider() }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.secondary.opacity(0.2)))
        }
    }

    // MARK: — Preset comparison

    @ViewBuilder
    private var presetComparisonTable: some View {
        section(title: t(.presetComparison), icon: "table") {
            VStack(spacing: 0) {
                tableHeader([t(.preset), t(.videoCodec), "⏱ / 1h", t(.compressionRatio), t(.qualityLabel)])
                Divider()
                ForEach(Preset.all) { p in
                    HStack(spacing: 0) {
                        tableCellLeading(p.localizedName(langMgr.language))
                        tableCell(p.videoCodec.displayName)
                        tableCell(p.timePerHour)
                        tableCell(p.compressionRatio)
                        tableCell(String(repeating: "★", count: p.qualityStars) +
                                  String(repeating: "☆", count: 5 - p.qualityStars))
                    }
                    Divider()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.secondary.opacity(0.2)))
            Text(t(.presetTimeNote)).font(.caption).foregroundStyle(.secondary).padding(.top, 4)
        }
    }

    // MARK: — Video Codecs

    @ViewBuilder
    private var videoCodecsSection: some View {
        section(title: t(.videoCodecsSection), icon: "film") {
            VStack(spacing: 0) {
                tableHeader([t(.codecColName), t(.codecColCompr), t(.codecColSpeed), t(.codecColCompat), t(.codecColBestFor)])
                Divider()
                codecRow(.h264,   t(.h264BestFor),   false)
                codecRow(.h265,   t(.h265BestFor),   true)
                codecRow(.h265Hw, t(.h265hwBestFor), false)
                codecRow(.vp9,    t(.vp9BestFor),    false)
                codecRow(.av1,    t(.av1BestFor),    false)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.secondary.opacity(0.2)))

            VStack(alignment: .leading, spacing: 6) {
                Text(t(.detailedDesc)).font(.caption).fontWeight(.semibold).padding(.top, 8)
                ForEach(VideoCodec.allCases) { codec in
                    DisclosureGroup(codec.displayName + " — " + codec.shortDescription(language: langMgr.language)) {
                        Text(codec.fullDescription(language: langMgr.language))
                            .font(.caption).foregroundStyle(.secondary).padding(.vertical, 6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .font(.caption)
                }
            }
        }
    }

    // MARK: — Audio Codecs

    @ViewBuilder
    private var audioCodecsSection: some View {
        section(title: t(.audioCodecsSection), icon: "waveform") {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(AudioCodec.allCases) { codec in
                    DisclosureGroup(codec.localizedDisplayName(langMgr.language) + " — " + codec.localizedShortDescription(langMgr.language)) {
                        Text(codec.localizedFullDescription(langMgr.language))
                            .font(.caption).foregroundStyle(.secondary).padding(.vertical, 6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .font(.caption)
                }
            }
        }
    }

    // MARK: — Parameters

    @ViewBuilder
    private var parametersSection: some View {
        section(title: t(.parameters), icon: "slider.horizontal.3") {
            VStack(alignment: .leading, spacing: 12) {
                Text(t(.crfExplainTitle) + " " + t(.crfExplainBody)).font(.body)
                VStack(spacing: 0) {
                    tableHeader([t(.crfValueCol), t(.crfResultCol), t(.crfUsageCol)])
                    Divider()
                    tableDataRow([t(.crf18), t(.crfRes18), t(.crfUse18)])
                    tableDataRow([t(.crf21), t(.crfRes21), t(.crfUse21)])
                    tableDataRow([t(.crf25), t(.crfRes25), t(.crfUse25)])
                    tableDataRow([t(.crf28), t(.crfRes28), t(.crfUse28)])
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.secondary.opacity(0.2)))

                callout(icon: "exclamationmark.triangle", color: .orange,
                        text: langMgr.language == .english
                            ? "CRF affects quality MUCH more than preset!"
                            : "CRF влияет на качество ГОРАЗДО сильнее, чем preset!")

                Text(t(.presetSpeedTitle) + " " + t(.presetSpeedBody)).font(.body).padding(.top, 4)
                VStack(spacing: 0) {
                    tableHeader(["Preset", t(.presetSpeedCol), t(.presetTimeCol)])
                    Divider()
                    tableDataRow(["ultrafast", "★★★★★", "~5–10 min"])
                    tableDataRow(["fast",      "★★★★☆", "~15–25 min"])
                    tableDataRow(["medium",    "★★★☆☆", "~30–50 min"])
                    tableDataRow(["slow",      "★★☆☆☆", "~1.5–3 h"])
                    tableDataRow(["slower",    "★☆☆☆☆", "~3–6 h"])
                    tableDataRow(["veryslow",  "☆☆☆☆☆", "~6–12 h"])
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.secondary.opacity(0.2)))
            }
        }
    }

    // MARK: — FFmpeg Commands

    @ViewBuilder
    private var ffmpegCommandsSection: some View {
        section(title: t(.commands), icon: "terminal") {
            Text(langMgr.language == .english
                 ? "Exact commands generated by the app for each preset:"
                 : "Точные команды, генерируемые приложением для каждого пресета:")
                .font(.caption).foregroundStyle(.secondary)
            VStack(spacing: 8) {
                ForEach(Preset.all) { preset in
                    CommandRow(preset: preset)
                }
            }
        }
    }

    // MARK: — Tips

    @ViewBuilder
    private var tipsSection: some View {
        section(title: t(.tips), icon: "lightbulb") {
            VStack(alignment: .leading, spacing: 10) {
                tipRow(icon: "arrow.2.circlepath", color: .red,     title: t(.tip1Title), text: t(.tip1Text))
                tipRow(icon: "apple.logo",         color: .primary,  title: t(.tip2Title), text: t(.tip2Text))
                tipRow(icon: "waveform",           color: .blue,    title: t(.tip3Title), text: t(.tip3Text))
                tipRow(icon: "testtube.2",         color: .purple,  title: t(.tip4Title), text: t(.tip4Text))
                tipRow(icon: "bolt",               color: .orange,  title: t(.tip5Title), text: t(.tip5Text))
                tipRow(icon: "cpu",                color: .green,   title: t(.tip6Title), text: t(.tip6Text))
                tipRow(icon: "lock.open",          color: .teal,    title: t(.tip7Title), text: t(.tip7Text))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: — Helpers

    @ViewBuilder
    private func section<C: View>(title: String, icon: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon).font(.title2).fontWeight(.semibold)
            content()
        }
    }

    @ViewBuilder
    private func tableHeader(_ cols: [String]) -> some View {
        HStack(spacing: 0) {
            ForEach(cols, id: \.self) { col in
                Text(col).font(.caption).fontWeight(.semibold).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 10).padding(.vertical, 6)
            }
        }
        .background(Color.secondary.opacity(0.08))
    }

    @ViewBuilder private func tableCellLeading(_ t: String) -> some View {
        Text(t).font(.caption).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 10).padding(.vertical, 6)
    }
    @ViewBuilder private func tableCell(_ t: String) -> some View {
        Text(t).font(.caption).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 10).padding(.vertical, 6)
    }
    @ViewBuilder private func tableDataRow(_ cols: [String]) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(cols.enumerated()), id: \.offset) { _, col in
                Text(col).font(.caption).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 10).padding(.vertical, 6)
            }
        }
        Divider()
    }

    @ViewBuilder
    private func codecRow(_ codec: VideoCodec, _ bestFor: String, _ recommended: Bool) -> some View {
        HStack(spacing: 0) {
            HStack(spacing: 4) {
                Text(codec.displayName).font(.caption)
                if recommended { Text("★").font(.caption2).foregroundStyle(.green) }
            }
            .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 10).padding(.vertical, 6)
            ratingDots(codec.compressionEfficiency)
            ratingDots(codec.encodingSpeed)
            ratingDots(codec.compatibility)
            Text(bestFor).font(.caption).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 10).padding(.vertical, 6)
        }
        Divider()
    }

    @ViewBuilder
    private func ratingDots(_ n: Int) -> some View {
        Text(String(repeating: "●", count: n) + String(repeating: "○", count: 5 - n))
            .font(.caption2).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 10).padding(.vertical, 6)
    }

    @ViewBuilder
    private func callout(icon: String, color: Color, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon).foregroundStyle(color).font(.caption)
            Text(text).font(.caption)
        }
        .padding(10).background(color.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 8))
    }

    @ViewBuilder
    private func tipRow(icon: String, color: Color, title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon).font(.title3).foregroundStyle(color).frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.caption).fontWeight(.semibold)
                Text(text).font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10).frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.secondary.opacity(0.04)).clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct CommandRow: View {
    let preset: Preset
    @State private var copied = false
    @ObservedObject private var langMgr = LanguageManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: preset.icon).foregroundStyle(Color.accentColor).font(.caption2)
                Text(preset.localizedName(langMgr.language)).font(.caption2).foregroundStyle(.secondary).fontWeight(.medium)
                Spacer()
                Button {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(preset.ffmpegCommand, forType: .string)
                    withAnimation(.spring(response: 0.3)) { copied = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                        withAnimation(.easeOut) { copied = false }
                    }
                } label: {
                    Image(systemName: copied ? "checkmark.circle.fill" : "doc.on.doc")
                        .font(.caption).foregroundStyle(copied ? .green : .secondary)
                        .scaleEffect(copied ? 1.25 : 1.0)
                }
                .buttonStyle(.plain)
            }
            Text(preset.ffmpegCommand)
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.primary).textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10).background(Color.secondary.opacity(0.05)).clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
