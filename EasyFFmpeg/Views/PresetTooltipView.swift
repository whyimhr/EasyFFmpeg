import SwiftUI

struct QualityStars: View {
    let rating: Int
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { i in
                Image(systemName: i <= rating ? "star.fill" : "star")
                    .font(.caption2)
                    .foregroundStyle(i <= rating ? Color.yellow : Theme.text3)
            }
        }
    }
}

struct PresetTooltipView: View {
    let preset: Preset
    @EnvironmentObject var langMgr: LanguageManager
    private func t(_ k: L10n.Key) -> String { L10n.string(k, language: langMgr.language) }
    private var isEn: Bool { langMgr.language == .english }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {

                HStack(spacing: 10) {
                    Image(systemName: preset.icon)
                        .font(.title3)
                        .foregroundStyle(Theme.accent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(preset.localizedName(langMgr.language))
                            .font(.headline)
                            .foregroundStyle(Theme.text)
                        Text(preset.category.rawValue)
                            .font(.caption2)
                            .foregroundStyle(Theme.text3)
                    }
                }

                Text(preset.localizedShortDesc(langMgr.language))
                    .font(.caption)
                    .foregroundStyle(Theme.text2)

                Divider()

                VStack(alignment: .leading, spacing: 5) {
                    paramRow(isEn ? "Video:" : "Видео:", preset.videoCodec.displayName, icon: "film")
                    paramRow(isEn ? "Audio:" : "Аудио:", preset.audioCodec.displayName, icon: "waveform")
                    if let crf = preset.crf {
                        paramRow("CRF:", "\(crf)", icon: "slider.horizontal.3")
                    }
                    if let ep = preset.encoderPreset {
                        paramRow(isEn ? "Speed:" : "Скорость:", ep.rawValue, icon: "speedometer")
                    }
                    if let fps = preset.fps {
                        paramRow("FPS:", "\(fps)", icon: "film.stack")
                    }
                    if let res = preset.resolution {
                        paramRow(isEn ? "Resolution:" : "Разрешение:", res.displayName, icon: "aspectratio")
                    }
                    if let br = preset.videoBitrate {
                        paramRow(isEn ? "Bitrate:" : "Битрейт:", "\(br) kbps", icon: "waveform.path")
                    }
                    if preset.videoCodec.supportsHWAccel {
                        HStack(spacing: 6) {
                            Image(systemName: "bolt.fill")
                                .font(.caption2)
                                .foregroundStyle(Theme.purple)
                            Text(isEn ? "Supports HW Acceleration" : "Поддерживает HW Acceleration")
                                .font(.caption)
                                .foregroundStyle(Theme.purple)
                        }
                        .padding(.horizontal, 8).padding(.vertical, 5)
                        .background(Theme.purple.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(Theme.purple.opacity(0.2), lineWidth: 1))
                    }
                }
                .font(.caption)

                Divider()

                HStack {
                    Label(t(.compressionRatio) + ": \(preset.compressionRatio)",
                          systemImage: "arrow.down.right.square")
                        .font(.caption)
                        .foregroundStyle(Theme.text2)
                    Spacer()
                    Text(String(repeating: "★", count: preset.qualityStars) +
                         String(repeating: "☆", count: 5 - preset.qualityStars))
                        .font(.caption2)
                        .foregroundStyle(Color.yellow)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text((isEn ? "⏱ Per 1h: " : "⏱ На 1 час: ") + preset.timePerHour)
                    Text((isEn ? "⏱ Per 1 GB: " : "⏱ На 1 ГБ: ") + preset.timePerGB)
                }
                .font(.caption)
                .foregroundStyle(Theme.text3)

                Divider()

                Text(preset.localizedFullDesc(langMgr.language))
                    .font(.caption)
                    .foregroundStyle(Theme.text2)
                    .fixedSize(horizontal: false, vertical: true)

                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    Text(isEn ? "Suitable for:" : "Подходит для:")
                        .font(.caption).fontWeight(.semibold)
                        .foregroundStyle(Theme.text)
                    ForEach(preset.localizedUseCases(langMgr.language), id: \.self) { uc in
                        HStack(spacing: 5) {
                            Circle().fill(Theme.accent).frame(width: 4, height: 4)
                            Text(uc).font(.caption).foregroundStyle(Theme.text2)
                        }
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 6) {
                    Text(t(.ffmpegCommand) + ":")
                        .font(.caption).fontWeight(.semibold)
                        .foregroundStyle(Theme.text)
                    Text(preset.ffmpegCommand)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(Theme.text2)
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.surface2)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            .padding(14)
        }
        .background(Theme.surface)
        .frame(width: 320)
        .frame(maxHeight: 520)
    }

    @ViewBuilder
    private func paramRow(_ label: String, _ value: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Theme.accent)
                .frame(width: 14)
            Text(label)
                .foregroundStyle(Theme.text3)
            Text(value)
                .foregroundStyle(Theme.text)
                .fontWeight(.medium)
        }
    }
}
