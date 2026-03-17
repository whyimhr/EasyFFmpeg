import SwiftUI

struct QualityStars: View {
    let rating: Int
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { i in
                Image(systemName: i <= rating ? "star.fill" : "star")
                    .font(.caption2)
                    .foregroundStyle(i <= rating ? Color.yellow : Color.secondary.opacity(0.4))
            }
        }
    }
}

struct PresetTooltipView: View {
    let preset: Preset
    @EnvironmentObject var langMgr: LanguageManager
    private func t(_ k: L10n.Key) -> String { L10n.string(k, language: langMgr.language) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: preset.icon)
                        .font(.title3)
                        .foregroundStyle(Color.accentColor)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(preset.localizedName(langMgr.language)).font(.headline)
                        Text(preset.category.rawValue)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Text(preset.localizedShortDesc(langMgr.language))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Divider()

                // Codec info
                Group {
                    Label("Видео: \(preset.videoCodec.displayName)", systemImage: "film")
                    Label("Аудио: \(preset.audioCodec.displayName)", systemImage: "waveform")
                    if let crf = preset.crf {
                        Label("CRF: \(crf)", systemImage: "slider.horizontal.3")
                    }
                    if let ep = preset.encoderPreset {
                        Label("Preset: \(ep.rawValue)", systemImage: "speedometer")
                    }
                    if let fps = preset.fps {
                        Label("FPS: \(fps)", systemImage: "film.stack")
                    }
                    if let res = preset.resolution {
                        Label("Разрешение: \(res.displayName)", systemImage: "aspectratio")
                    }
                    if let br = preset.videoBitrate {
                        Label("Битрейт: \(br) kbps", systemImage: "waveform.path")
                    }
                }
                .font(.caption)

                Divider()

                HStack {
                    Label(t(.compressionRatio) + ": \(preset.compressionRatio)", systemImage: "arrow.down.right.square")
                        .font(.caption)
                    Spacer()
                    Text(String(repeating: "★", count: preset.qualityStars) +
                         String(repeating: "☆", count: 5 - preset.qualityStars))
                        .font(.caption2)
                        .foregroundStyle(.yellow)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text((langMgr.language == .english ? "⏱ Per 1h: " : "⏱ На 1 час: ") + preset.timePerHour)
                    Text((langMgr.language == .english ? "⏱ Per 1 GB: " : "⏱ На 1 ГБ: ") + preset.timePerGB)
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    Text(preset.localizedFullDesc(langMgr.language))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    Text(langMgr.language == .english ? "Suitable for:" : "Подходит для:")
                        .font(.caption).fontWeight(.semibold)
                    ForEach(preset.localizedUseCases(langMgr.language), id: \.self) { uc in
                        Text("• \(uc)").font(.caption).foregroundStyle(.secondary)
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    Text(t(.ffmpegCommand) + ":")
                        .font(.caption).fontWeight(.semibold)
                    Text(preset.ffmpegCommand)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(14)
        }
        .frame(width: 340)
        .frame(maxHeight: 540)
    }
}
