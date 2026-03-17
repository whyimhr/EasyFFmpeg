import SwiftUI

// MARK: — Equal-height preset cards via PreferenceKey

private struct CardHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: — Presets + Settings tab container

struct PresetsAndSettingsView: View {
    let selectedPresetID: String
    let onSelect: (Preset) -> Void
    @Binding var settings: CompressionSettings
    @State private var selectedTab: SettingsTab = .presets
    @EnvironmentObject var langMgr: LanguageManager
    private func t(_ k: L10n.Key) -> String { L10n.string(k, language: langMgr.language) }

    enum SettingsTab: String, CaseIterable, Identifiable {
        case presets; case manual
        var id: Self { self }
        func label(_ lang: AppLanguage) -> String {
            switch self {
            case .presets: return L10n.string(.presetsTab, language: lang)
            case .manual:  return L10n.string(.settingsTab, language: lang)
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            HStack(spacing: 2) {
                ForEach(SettingsTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.18)) { selectedTab = tab }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: tab == .presets ? "dial.medium" : "gearshape.2")
                                .font(.system(size: 11, weight: .medium))
                            Text(tab.label(langMgr.language))
                                .font(.callout)
                                .fontWeight(selectedTab == tab ? .semibold : .regular)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 7)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 7)
                                .fill(selectedTab == tab ? Color(nsColor: .controlBackgroundColor) : Color.clear)
                                .shadow(color: selectedTab == tab ? .black.opacity(0.08) : .clear, radius: 2, y: 1)
                        )
                        .foregroundStyle(selectedTab == tab ? .primary : .secondary)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(4)
            .background(Color.secondary.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.bottom, 10)

            if selectedTab == .presets {
                EqualHeightPresetGrid(selectedPresetID: selectedPresetID, onSelect: onSelect)
                    .transition(.opacity)
            } else {
                ManualSettingsInner(settings: $settings)
                    .transition(.opacity)
            }
        }
    }
}

// MARK: — Grid that makes all cards the same height

struct EqualHeightPresetGrid: View {
    let selectedPresetID: String
    let onSelect: (Preset) -> Void
    @State private var popoverPresetID: String? = nil
    @State private var hoveredPresetID: String? = nil
    @State private var cardHeight: CGFloat = 0

    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Preset.all) { preset in
                PresetCardWithInfo(
                    preset: preset,
                    isSelected: selectedPresetID == preset.id,
                    isHovered: hoveredPresetID == preset.id,
                    isPopoverShown: popoverPresetID == preset.id,
                    cardHeight: cardHeight,         // pass measured max height
                    onTap: { onSelect(preset) },
                    onHover: { hoveredPresetID = $0 ? preset.id : nil },
                    onInfoToggle: {
                        popoverPresetID = (popoverPresetID == preset.id) ? nil : preset.id
                    },
                    onPopoverDismiss: {
                        if popoverPresetID == preset.id { popoverPresetID = nil }
                    }
                )
                // Collect natural height from each card
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(key: CardHeightKey.self, value: geo.size.height)
                    }
                )
            }
        }
        // Apply max height to all cards
        .onPreferenceChange(CardHeightKey.self) { h in
            if h > cardHeight { cardHeight = h }
        }
    }
}

// MARK: — Individual card

struct PresetCardWithInfo: View {
    let preset: Preset
    let isSelected: Bool
    let isHovered: Bool
    let isPopoverShown: Bool
    let cardHeight: CGFloat       // enforced equal height
    let onTap: () -> Void
    let onHover: (Bool) -> Void
    let onInfoToggle: () -> Void
    let onPopoverDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 7) {
                    Image(systemName: preset.icon)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.accentColor)
                        .frame(width: 18)
                    Text(preset.localizedName(LanguageManager.shared.language))
                        .font(.caption).fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
                .frame(minHeight: 28)

                TagFlowRow(tags: buildTags())
                    .frame(minHeight: 16, alignment: .topLeading)

                Spacer(minLength: 0)   // push content to top, let height be enforced below
            }
            .padding(.horizontal, 10)
            .padding(.top, 10)
            .padding(.bottom, 10)
            // Fix 1: if we have a measured max height, apply it; otherwise size naturally
            .frame(maxWidth: .infinity,
                   minHeight: cardHeight > 0 ? cardHeight : nil,
                   alignment: .topLeading)
            .contentShape(Rectangle())
            .onTapGesture { onTap() }

            // Info button
            Button {
                onInfoToggle()
            } label: {
                Image(systemName: isPopoverShown ? "info.circle.fill" : "info.circle")
                    .font(.system(size: 11))
                    .foregroundStyle(isPopoverShown ? Color.accentColor : Color.secondary.opacity(0.5))
                    .frame(width: 24, height: 24)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(4)
            .popover(
                isPresented: Binding(
                    get: { isPopoverShown },
                    set: { if !$0 { onPopoverDismiss() } }
                ),
                arrowEdge: .trailing
            ) {
                PresetTooltipView(preset: preset)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isHovered && !isSelected
                      ? Color.accentColor.opacity(0.05)
                      : Color.secondary.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(
                    isSelected ? Color.accentColor : Color.secondary.opacity(0.12),
                    lineWidth: isSelected ? 2 : 1
                )
        )
        .animation(.easeInOut(duration: 0.13), value: isSelected)
        .animation(.easeInOut(duration: 0.1), value: isHovered)
        .onHover { onHover($0) }
        .contextMenu { Button(L10n.string(.presetDetails, language: LanguageManager.shared.language)) { onInfoToggle() } }
    }

    private func buildTags() -> [(String, String)] {
        var tags: [(String, String)] = [
            (preset.videoCodec.shortTag, preset.videoCodec.shortDescription),
            (preset.compressionRatio, LanguageManager.shared.language == .english ? "Expected compression ratio" : "Ожидаемое сжатие относительно оригинала"),
        ]
        if let fps = preset.fps {
            tags.append(("\(fps) fps", LanguageManager.shared.language == .english ? "FPS limited to \(fps) to reduce size" : "FPS ограничен до \(fps) для уменьшения размера"))
        }
        if let res = preset.resolution, res != .original {
            tags.append((res.shortTag, LanguageManager.shared.language == .english ? "Resolution limited to \(res.displayName)" : "Разрешение ограничено до \(res.displayName)"))
        }
        return tags
    }
}

// MARK: — Extension helpers

extension VideoCodec {
    var shortTag: String {
        switch self {
        case .h264:   return "H.264"
        case .h265:   return "H.265"
        case .h265Hw: return "HW"
        case .vp9:    return "VP9"
        case .av1:    return "AV1"
        }
    }
}

extension Resolution {
    var shortTag: String {
        switch self {
        case .original: return ""
        case .r4k:      return "4K"
        case .r1080p:   return "1080p"
        case .r720p:    return "720p"
        case .r480p:    return "480p"
        }
    }
}

// MARK: — Standalone PresetPickerView (for contexts without tabs)

struct PresetPickerView: View {
    let selectedPresetID: String
    let onSelect: (Preset) -> Void

    var body: some View {
        GroupBox {
            EqualHeightPresetGrid(selectedPresetID: selectedPresetID, onSelect: onSelect)
                .padding(4)
        } label: {
            Label("Пресет", systemImage: "dial.medium").font(.callout).fontWeight(.semibold)
        }
    }
}

// MARK: — CodecBadge + PresetCard (BatchView compat)

struct CodecBadge: View {
    let codec: VideoCodec; let isSelected: Bool
    var body: some View {
        Text(codec.shortTag)
            .font(.system(size: 9, weight: .semibold))
            .foregroundStyle(Color.secondary)
            .padding(.horizontal, 5).padding(.vertical, 2)
            .background(RoundedRectangle(cornerRadius: 3).fill(Color.secondary.opacity(0.12)))
    }
}

struct PresetCard: View {
    let preset: Preset; let isSelected: Bool; let isHovered: Bool
    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: preset.icon).font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.accentColor).frame(width: 20)
            VStack(alignment: .leading, spacing: 3) {
                Text(preset.localizedName(LanguageManager.shared.language)).font(.caption).fontWeight(.semibold)
                    .foregroundStyle(.primary).lineLimit(2)
                CodecBadge(codec: preset.videoCodec, isSelected: isSelected)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10).padding(.vertical, 9)
        .background(RoundedRectangle(cornerRadius: 9)
            .fill(isSelected ? Color.accentColor : (isHovered ? Color.accentColor.opacity(0.08) : Color.secondary.opacity(0.07))))
        .overlay(RoundedRectangle(cornerRadius: 9)
            .strokeBorder(isSelected ? Color.clear : Color.secondary.opacity(0.12), lineWidth: 1))
    }
}
