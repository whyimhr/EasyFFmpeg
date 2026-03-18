import SwiftUI

// ManualSettingsView — standalone GroupBox (used in some contexts)
struct ManualSettingsView: View {
    @Binding var settings: CompressionSettings
    @State private var isExpanded = false
    @EnvironmentObject var langMgr: LanguageManager
    private func t(_ k: L10n.Key) -> String { L10n.string(k, language: langMgr.language) }

    var body: some View {
        GroupBox {
            DisclosureGroup(isExpanded: $isExpanded) {
                ManualSettingsInner(settings: $settings)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
            } label: {
                Label(t(.manualSettings), systemImage: "gearshape.2").font(.callout).fontWeight(.semibold)
            }
        }
    }
}

// ManualSettingsInner — content only, no GroupBox wrapper (used inside tabs)
struct ManualSettingsInner: View {
    @Binding var settings: CompressionSettings
    @EnvironmentObject var langMgr: LanguageManager
    private func t(_ k: L10n.Key) -> String { L10n.string(k, language: langMgr.language) }

    var body: some View {
        VStack(spacing: 14) {
            videoCodecSection
            Divider()
            if !settings.videoCodec.isHardware {
                crfSection
                Divider()
                encoderPresetSection
                Divider()
            } else {
                bitrateSection
                Divider()
            }
            fpsSection
            Divider()
            resolutionSection
            Divider()
            audioSection
        }
    }

    // MARK: Video Codec

    @ViewBuilder
    private var videoCodecSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(t(.videoCodec), systemImage: "film").font(.caption).foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(VideoCodec.allCases) { codec in
                        QuickCodecButton(
                            title: codec.displayName,  // codec names are universal
                            isSelected: settings.videoCodec == codec
                        ) {
                            settings.videoCodec = codec
                            settings.autoSelectAudioCodec()
                            if !codec.crfRange.contains(settings.crf) {
                                settings.crf = codec.defaultCRF
                            }
                        }
                    }
                }
            }
            CodecInfoBox(codec: settings.videoCodec)
        }
    }

    // MARK: CRF

    @ViewBuilder
    private var crfSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(langMgr.language == .english ? settings.videoCodec.crfLabelEn : settings.videoCodec.crfLabel, systemImage: "slider.horizontal.3")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text("\(settings.crf)")
                    .font(.caption).fontWeight(.semibold).monospacedDigit()
                    .foregroundStyle(Color.accentColor).frame(width: 32)
            }
            Slider(
                value: Binding(get: { Double(settings.crf) }, set: { settings.crf = Int($0) }),
                in: Double(settings.videoCodec.crfRange.lowerBound)...Double(settings.videoCodec.crfRange.upperBound),
                step: 1
            )
            HStack {
                Text("\(settings.videoCodec.crfRange.lowerBound) — \(t(.maxQuality))")
                Spacer()
                Text("\(settings.videoCodec.crfRange.upperBound) — \(t(.minSize))")
            }
            .font(.caption2).foregroundStyle(.tertiary)
            Text(t(.crfNote))
                .font(.caption2).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: Encoder Preset

    @ViewBuilder
    private var encoderPresetSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(t(.encodingSpeed), systemImage: "speedometer")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text(settings.encoderPreset.rawValue)
                    .font(.caption).fontWeight(.semibold).foregroundStyle(Color.accentColor)
            }
            // Fix 3: shorter labels prevent wrapping in narrow panels
            HStack(spacing: 2) {
                ForEach(EncoderPreset.allCases) { preset in
                    let isSel = settings.encoderPreset == preset
                    Text(preset.shortLabel)
                        .font(.system(size: 10, weight: isSel ? .semibold : .regular))
                        .foregroundStyle(isSel ? .white : .primary)
                        .padding(.horizontal, 4).padding(.vertical, 5)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(isSel ? Color.accentColor : Color.clear)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture { settings.encoderPreset = preset }
                        .animation(.easeInOut(duration: 0.12), value: isSel)
                        .help(preset.rawValue)   // full name in tooltip
                }
            }
            .padding(2)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.secondary.opacity(0.1)))
            HStack {
                Text(t(.fasterBigger))
                Spacer()
                Text(t(.slowerSmaller))
            }
            .font(.caption2).foregroundStyle(.tertiary)
            Text(t(.presetNote))
                .font(.caption2).foregroundStyle(.secondary)
        }
    }

    // MARK: HW Bitrate

    @ViewBuilder
    private var bitrateSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(t(.bitrate), systemImage: "waveform.path")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text("\(settings.videoBitrate ?? 5000) kbps")
                    .font(.caption).fontWeight(.semibold).foregroundStyle(Color.accentColor)
            }
            Picker(t(.bitrate), selection: Binding(
                get: { settings.videoBitrate ?? 5000 },
                set: { settings.videoBitrate = $0 }
            )) {
                Text(t(.bitrateHeavy)).tag(2500)
                Text(t(.balanceBitrate)).tag(4000)
                Text(t(.goodBitrate)).tag(5000)
                Text(t(.highBitrate)).tag(8000)
            }
            .labelsHidden()
        }
    }

    // MARK: FPS

    @ViewBuilder
    private var fpsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(t(.fps), systemImage: "film.stack")
                .font(.caption).foregroundStyle(.secondary)
            Picker(t(.fps), selection: $settings.fps) {
                Text(t(.originalFPS)).tag(Optional<Int>.none)
                Text("60 FPS").tag(Optional(60))
                Text("30 FPS").tag(Optional(30))
                Text("24 FPS").tag(Optional(24))
                Text("15 FPS").tag(Optional(15))
            }
            .labelsHidden()
        }
    }

    // MARK: Resolution

    @ViewBuilder
    private var resolutionSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(t(.resolution), systemImage: "aspectratio")
                .font(.caption).foregroundStyle(.secondary)
            Picker(t(.resolution), selection: $settings.resolution) {
                ForEach(Resolution.allCases) { Text($0.localizedDisplayName(langMgr.language)).tag($0) }
            }
            .labelsHidden()
        }
    }

    // MARK: Audio

    @ViewBuilder
    private var audioSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(t(.audio), systemImage: "waveform").font(.caption).foregroundStyle(.secondary)
            Picker(t(.audio), selection: $settings.audioCodec) {
                ForEach(AudioCodec.allCases) { codec in
                    VStack(alignment: .leading) {
                        Text(codec.localizedDisplayName(langMgr.language))
                        Text(codec.localizedShortDescription(langMgr.language)).font(.caption2).foregroundStyle(.secondary)
                    }
                    .tag(codec)
                }
            }
            .labelsHidden()
            .onChange(of: settings.audioCodec) { _, newValue in
                if newValue.defaultBitrate > 0 {
                    settings.audioBitrate = newValue.defaultBitrate
                }
            }
            if settings.audioCodec.hasBitrate {
                HStack {
                    Text(t(.audioBitrate) + ":").font(.caption2).foregroundStyle(.secondary)
                    Spacer()
                    Text("\(settings.audioBitrate) kbps").font(.caption2).fontWeight(.semibold).foregroundStyle(Color.accentColor)
                }
                Picker("Аудиобитрейт", selection: $settings.audioBitrate) {
                    ForEach([64, 96, 128, 192, 256, 320], id: \.self) { Text("\($0)k").tag($0) }
                }
                .pickerStyle(.segmented).labelsHidden()
                Toggle(t(.monoAudio), isOn: $settings.monoAudio)
                    .toggleStyle(.checkbox).font(.caption)
            }
            if settings.videoCodec.recommendedContainer == "mp4" && !settings.audioCodec.compatibleWithMP4 {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange).font(.caption)
                    Text("\(settings.audioCodec.displayName) \(t(.audioIncompatible))")
                        .font(.caption2).foregroundStyle(.orange)
                }
            }
        }
    }
}

// MARK: - Sub-views

struct QuickCodecButton: View {
    let title: String; let isSelected: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(RoundedRectangle(cornerRadius: 7).fill(isSelected ? Color.accentColor : Color.secondary.opacity(0.1)))
        }
        .buttonStyle(.plain)
    }
}

struct CodecInfoBox: View {
    let codec: VideoCodec
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(codec.displayName).font(.caption).fontWeight(.semibold)
                Spacer()
                ForEach(codec.tags.prefix(2), id: \.self) { tag in
                    Text(tag.displayName(LanguageManager.shared.language)).font(.caption2)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(tag.color.opacity(0.15)).foregroundStyle(tag.color)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            // Fix 2: 3-column grid — labels left-aligned within each column
            HStack(alignment: .top, spacing: 0) {
                RatingRow(label: L10n.string(.ratingCompression, language: LanguageManager.shared.language), rating: codec.compressionEfficiency)
                    .frame(maxWidth: .infinity, alignment: .leading)
                RatingRow(label: L10n.string(.ratingSpeed, language: LanguageManager.shared.language), rating: codec.encodingSpeed)
                    .frame(maxWidth: .infinity, alignment: .leading)
                RatingRow(label: L10n.string(.ratingCompatibility, language: LanguageManager.shared.language), rating: codec.compatibility)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Text(codec.shortDescription(language: LanguageManager.shared.language)).font(.caption2).foregroundStyle(.secondary)
        }
        .padding(10).background(Color.secondary.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct RatingRow: View {
    let label: String; let rating: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.caption2).foregroundStyle(.secondary)
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(i <= rating ? Color.accentColor : Color.secondary.opacity(0.2))
                        .frame(width: 8, height: 6)
                }
            }
        }
    }
}
