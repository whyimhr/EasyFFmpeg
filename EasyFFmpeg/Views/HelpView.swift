import SwiftUI

struct HelpView: View {
    @EnvironmentObject var langMgr: LanguageManager
    private func t(_ k: L10n.Key) -> String { L10n.string(k, language: langMgr.language) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                howToChooseSection
                presetComparisonTable
                videoCodecsSection
                audioCodecsSection
                parametersSection
                ffmpegCommandsSection
                tipsSection
            }
            .padding(20)
            .padding(.bottom, 32)
        }
        .navigationTitle(t(.helpTitle))
        .background(Theme.panel)
    }

    // MARK: - How to choose

    @ViewBuilder
    private var howToChooseSection: some View {
        helpSection(title: t(.howToChoose), icon: "shield.checkerboard") {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    helpTh(t(.situationLabel), maxWidth: .infinity)
                    helpTh(t(.recommendedPreset), maxWidth: .infinity)
                }
                .background(Color.secondary.opacity(0.06))
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
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10).padding(.vertical, 6)

                        Text(t(row.2))
                            .font(.caption).fontWeight(.medium)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 10).padding(.vertical, 6)
                    }
                    if idx < rows.count - 1 { Divider() }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Theme.border2, lineWidth: 1))
        }
    }

    // MARK: - Preset comparison (with HW column)

    @ViewBuilder
    private var presetComparisonTable: some View {
        helpSection(title: t(.presetComparison), icon: "tablecells") {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    helpTh(t(.preset),          maxWidth: .infinity)
                    helpTh(t(.videoCodec),       width: 56)
                    helpTh("⏱ / 1h",            width: 64)
                    helpTh(t(.compressionRatio), width: 56)
                    helpTh(t(.qualityLabel),     width: 60)
                    helpTh("HW",                 width: 36)
                }
                .background(Color.secondary.opacity(0.06))
                Divider()

                ForEach(Preset.all) { p in
                    HStack(spacing: 0) {
                        HStack(spacing: 5) {
                            Text(p.icon.isEmpty ? "" : "")
                            Text(p.localizedName(langMgr.language))
                                .font(.system(size: 11.5, weight: .medium))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10).padding(.vertical, 6)

                        Text(p.videoCodec.shortTag)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .frame(width: 56, alignment: .leading)
                            .padding(.horizontal, 6).padding(.vertical, 6)

                        Text(p.timePerHour)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .frame(width: 64, alignment: .leading)
                            .padding(.horizontal, 6).padding(.vertical, 6)

                        Text(p.compressionRatio)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .frame(width: 56, alignment: .leading)
                            .padding(.horizontal, 6).padding(.vertical, 6)

                        Text(String(repeating: "★", count: p.qualityStars) +
                             String(repeating: "☆", count: 5 - p.qualityStars))
                            .font(.system(size: 11))
                            .foregroundStyle(Color.yellow)
                            .frame(width: 60, alignment: .leading)
                            .padding(.horizontal, 6).padding(.vertical, 6)

                        Group {
                            if p.videoCodec.supportsHWAccel {
                                HStack(spacing: 3) {
                                    Circle()
                                        .fill(Color.purple)
                                        .frame(width: 7, height: 7)
                                        .shadow(color: Color.purple, radius: 2)
                                    Text(langMgr.language == .english ? "yes" : "да")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.purple)
                                }
                            } else {
                                Text("—")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .frame(width: 36, alignment: .leading)
                        .padding(.horizontal, 6).padding(.vertical, 6)
                    }
                    Divider()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Theme.border2, lineWidth: 1))

            Text(t(.presetTimeNote)).font(.caption).foregroundStyle(.secondary).padding(.top, 4)

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "cpu")
                    .font(.system(size: 12))
                    .foregroundStyle(.purple)
                    .padding(.top, 1)
                Text(langMgr.language == .english
                     ? "HW Acceleration is available for H.265 presets. Replaces libx265 → hevc_videotoolbox, encodes 5–10× faster, file ~5–10% larger."
                     : "HW Acceleration доступно для пресетов с H.265. Заменяет libx265 → hevc_videotoolbox, ускоряет в 5–10×, файл ~5–10% больше.")
                    .font(.caption)
                    .foregroundStyle(Color.purple.opacity(0.9))
            }
            .padding(.horizontal, 12).padding(.vertical, 9)
            .background(Color.purple.opacity(0.07))
            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.purple.opacity(0.2), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.top, 4)
        }
    }

    // MARK: - Video Codecs

    @ViewBuilder
    private var videoCodecsSection: some View {
        helpSection(title: t(.videoCodecsSection), icon: "film") {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    helpTh(t(.codecColName),    maxWidth: .infinity)
                    helpTh(t(.codecColCompr),   width: 64)
                    helpTh(t(.codecColSpeed),   width: 64)
                    helpTh(t(.codecColCompat),  width: 64)
                    helpTh(t(.codecColBestFor), maxWidth: .infinity)
                }
                .background(Color.secondary.opacity(0.06))
                Divider()
                codecRow(.h264,   t(.h264BestFor),   false)
                codecRow(.h265,   t(.h265BestFor),   true)
                codecRow(.h265Hw, t(.h265hwBestFor), false)
                codecRow(.vp9,    t(.vp9BestFor),    false)
                codecRow(.av1,    t(.av1BestFor),    false)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Theme.border2, lineWidth: 1))

            VStack(alignment: .leading, spacing: 4) {
                Text(t(.detailedDesc))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.text)
                    .padding(.top, 8).padding(.bottom, 4)
                ForEach(VideoCodec.allCases) { codec in
                    HelpDisclosureRow(
                        header: codec.displayName,
                        subtitle: codec.shortDescription(language: langMgr.language),
                        icon: "film",
                        description: codec.fullDescription(language: langMgr.language)
                    )
                }
            }
        }
    }

    // MARK: - Audio Codecs

    @ViewBuilder
    private var audioCodecsSection: some View {
        helpSection(title: t(.audioCodecsSection), icon: "waveform") {
            VStack(spacing: 4) {
                ForEach(AudioCodec.allCases) { codec in
                    HelpDisclosureRow(
                        header: codec.localizedDisplayName(langMgr.language),
                        subtitle: codec.localizedShortDescription(langMgr.language),
                        icon: "waveform",
                        description: codec.localizedFullDescription(langMgr.language)
                    )
                }
            }
        }
    }

    // MARK: - Parameters

    @ViewBuilder
    private var parametersSection: some View {
        helpSection(title: t(.parameters), icon: "slider.horizontal.3") {
            VStack(alignment: .leading, spacing: 12) {
                Text(t(.crfExplainTitle) + " " + t(.crfExplainBody)).font(.caption)
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        helpTh(t(.crfValueCol), maxWidth: .infinity)
                        helpTh(t(.crfResultCol), maxWidth: .infinity)
                        helpTh(t(.crfUsageCol), maxWidth: .infinity)
                    }
                    .background(Color.secondary.opacity(0.06))
                    Divider()
                    helpDataRow([t(.crf18), t(.crfRes18), t(.crfUse18)])
                    helpDataRow([t(.crf21), t(.crfRes21), t(.crfUse21)])
                    helpDataRow([t(.crf25), t(.crfRes25), t(.crfUse25)])
                    helpDataRow([t(.crf28), t(.crfRes28), t(.crfUse28)])
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Theme.border2, lineWidth: 1))

                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 12))
                        .foregroundStyle(.orange).padding(.top, 1)
                    Text(langMgr.language == .english
                         ? "CRF affects quality MUCH more than preset!"
                         : "CRF влияет на качество ГОРАЗДО сильнее, чем preset!")
                        .font(.caption).foregroundStyle(Color.orange.opacity(0.9))
                }
                .padding(.horizontal, 12).padding(.vertical, 9)
                .background(Color.orange.opacity(0.07))
                .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.orange.opacity(0.2), lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

                Text(t(.presetSpeedTitle) + " " + t(.presetSpeedBody)).font(.caption).padding(.top, 4)
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        helpTh("Preset", maxWidth: .infinity)
                        helpTh(t(.presetSpeedCol), maxWidth: .infinity)
                        helpTh(t(.presetTimeCol), maxWidth: .infinity)
                    }
                    .background(Color.secondary.opacity(0.06))
                    Divider()
                    helpDataRow(["ultrafast", "★★★★★", "~5–10 min"])
                    helpDataRow(["fast",      "★★★★☆", "~15–25 min"])
                    helpDataRow(["medium",    "★★★☆☆", "~30–50 min"])
                    helpDataRow(["slow",      "★★☆☆☆", "~1.5–3 h"])
                    helpDataRow(["slower",    "★☆☆☆☆", "~3–6 h"])
                    helpDataRow(["veryslow",  "☆☆☆☆☆", "~6–12 h"])
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Theme.border2, lineWidth: 1))
            }
        }
    }

    // MARK: - FFmpeg Commands

    @ViewBuilder
    private var ffmpegCommandsSection: some View {
        helpSection(title: t(.commands), icon: "terminal") {
            VStack(alignment: .leading, spacing: 0) {
                Text(langMgr.language == .english
                     ? "Common filter \"-vf format=yuv420p\" is appended to all presets automatically."
                     : "Общий фильтр \"-vf format=yuv420p\" добавляется ко всем пресетам автоматически.")
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)
                    .padding(.bottom, 10)

                VStack(spacing: 5) {
                    ForEach(Preset.all) { preset in
                        CommandRow(preset: preset)
                    }
                }
            }
        }
    }

    // MARK: - Tips

    @ViewBuilder
    private var tipsSection: some View {
        helpSection(title: t(.tips), icon: "lightbulb") {
            VStack(spacing: 0) {
                let tips: [(String, Color, String, L10n.Key, L10n.Key)] = [
                    ("arrow.2.circlepath",  .red,    "", .tip1Title, .tip1Text),
                    ("bolt.fill",           .purple, "", .tip2Title, .tip2Text),
                    ("globe",               .orange, "", .tip3Title, .tip3Text),
                    ("graduationcap.fill",  .green,  "", .tip4Title, .tip4Text),
                    ("waveform",            .blue,   "", .tip5Title, .tip5Text),
                    ("cpu",                 .green,  "", .tip6Title, .tip6Text),
                    ("lock.open.fill",      .teal,   "", .tip7Title, .tip7Text),
                ]
                ForEach(Array(tips.enumerated()), id: \.offset) { idx, tip in
                    tipRow(icon: tip.0, color: tip.1, titleKey: tip.3, textKey: tip.4)
                    if idx < tips.count - 1 { Divider() }
                }
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func helpSection<C: View>(title: String, icon: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.accentColor)
                Text(title)
                    .font(.system(size: 13, weight: .bold))
            }
            .padding(.bottom, 8)
            .overlay(Divider(), alignment: .bottom)

            content()
        }
    }

    @ViewBuilder
    private func helpTh(_ text: String, maxWidth: CGFloat? = nil, width: CGFloat? = nil) -> some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.tertiary)
            .kerning(0.6)
            .frame(maxWidth: maxWidth, alignment: .leading)
            .frame(width: width, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
    }

    @ViewBuilder
    private func helpDataRow(_ cols: [String]) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(cols.enumerated()), id: \.offset) { _, col in
                Text(col)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10).padding(.vertical, 6)
            }
        }
        Divider()
    }

    @ViewBuilder
    private func codecRow(_ codec: VideoCodec, _ bestFor: String, _ recommended: Bool) -> some View {
        HStack(spacing: 0) {
            HStack(spacing: 4) {
                Text(codec.displayName).font(.caption)
                if recommended {
                    Text("★").font(.system(size: 9)).foregroundStyle(.green)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 10).padding(.vertical, 6)
            ratingDots(codec.compressionEfficiency, width: 64)
            ratingDots(codec.encodingSpeed,         width: 64)
            ratingDots(codec.compatibility,         width: 64)
            Text(bestFor).font(.caption).frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10).padding(.vertical, 6)
        }
        Divider()
    }

    @ViewBuilder
    private func ratingDots(_ n: Int, width: CGFloat) -> some View {
        Text(String(repeating: "●", count: n) + String(repeating: "○", count: 5 - n))
            .font(.system(size: 9.5))
            .foregroundStyle(Color.secondary)
            .frame(width: width, alignment: .leading)
            .padding(.horizontal, 10).padding(.vertical, 6)
    }

    @ViewBuilder
    private func tipRow(icon: String, color: Color, titleKey: L10n.Key, textKey: L10n.Key) -> some View {
        HStack(alignment: .top, spacing: 10) {
            RoundedRectangle(cornerRadius: 6)
                .fill(color.opacity(0.12))
                .frame(width: 26, height: 26)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(color)
                )
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 2) {
                Text(t(titleKey))
                    .font(.system(size: 12.5, weight: .semibold))
                Text(t(textKey))
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 9)
    }
}

// MARK: - HelpDisclosureRow
// Expandable card for video/audio codec descriptions.
// Matches CommandRow style: accent icon square + header + chevron.

struct HelpDisclosureRow: View {
    let header: String
    let subtitle: String
    let icon: String
    let description: String   // named 'description' not 'body' to avoid View.body conflict
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.15)) { isExpanded.toggle() }
            } label: {
                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Theme.accent.opacity(0.10))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Image(systemName: icon)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Theme.accent)
                        )

                    VStack(alignment: .leading, spacing: 1) {
                        Text(header)
                            .font(.system(size: 12.5, weight: .semibold))
                            .foregroundStyle(Theme.text)
                        Text(subtitle)
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.text3)
                            .lineLimit(1)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Theme.text3)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.horizontal, 12).padding(.vertical, 9)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider()
                    .padding(.horizontal, 12)
                Text(description)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.text2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12).padding(.vertical, 10)
                    .background(Theme.surface2)
            }
        }
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Theme.border2, lineWidth: 1))
        .animation(.easeInOut(duration: 0.15), value: isExpanded)
    }
}

// MARK: - CommandRow
// Expandable card for FFmpeg commands with full-width tap target and copy button.
// Uses foregroundColor (not foregroundStyle) in Text concatenations — macOS 13 compat.
// Uses font(.system(size:design:)) instead of .fontDesign() — macOS 13 compat.

struct CommandRow: View {
    let preset: Preset
    @State private var copied = false
    @State private var isExpanded = false
    @ObservedObject private var langMgr = LanguageManager.shared

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.15)) { isExpanded.toggle() }
            } label: {
                HStack {
                    Image(systemName: preset.icon)
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.accent)
                    Text(preset.localizedName(langMgr.language))
                        .font(.system(size: 12.5, weight: .medium))
                        .foregroundStyle(Theme.text)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Theme.text3)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.horizontal, 14).padding(.vertical, 9)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider()
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Spacer()
                        Button {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(preset.ffmpegCommand, forType: .string)
                            withAnimation(.spring(response: 0.3)) { copied = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                                withAnimation(.easeOut) { copied = false }
                            }
                        } label: {
                            Text(copied
                                 ? (langMgr.language == .english ? "Copied!" : "Скопировано!")
                                 : (langMgr.language == .english ? "Copy" : "Копировать"))
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(copied ? Color.green : Color.secondary.opacity(0.5))
                                .padding(.horizontal, 8).padding(.vertical, 2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .strokeBorder(Theme.border2, lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                        .buttonStyle(.plain)
                    }

                    Text(preset.ffmpegCommand)
                        .font(.system(size: 10.5, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.secondary.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 7))

                    // HW note — uses foregroundColor + explicit font(design:) for macOS 13 compat
                    // (Text-returning overloads of foregroundStyle/fontDesign require macOS 14)
                    if preset.videoCodec.supportsHWAccel {
                        HStack(spacing: 5) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(Color.purple)
                            (Text(langMgr.language == .english ? "With HW: " : "С HW: ")
                                .foregroundColor(Color.secondary)
                            + Text("-c:v hevc_videotoolbox")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(Color.purple)
                            + Text(langMgr.language == .english ? " instead of libx265" : " вместо libx265")
                                .foregroundColor(Color.secondary))
                            .font(.system(size: 11))
                        }
                    }
                    // .webm note
                    if preset.videoCodec.recommendedContainer == "webm" {
                        HStack(spacing: 5) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(Color.orange)
                            (Text(langMgr.language == .english ? "Output file: " : "Выходной файл: ")
                                .foregroundColor(Color.secondary)
                            + Text(".webm")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(Color.orange)
                            + Text(langMgr.language == .english ? " — not compatible with QuickTime." : " — не совместим с QuickTime.")
                                .foregroundColor(Color.secondary))
                            .font(.system(size: 11))
                        }
                    }
                }
                .padding(.horizontal, 14).padding(.top, 10).padding(.bottom, 12)
            }
        }
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Theme.border2, lineWidth: 1))
    }
}
