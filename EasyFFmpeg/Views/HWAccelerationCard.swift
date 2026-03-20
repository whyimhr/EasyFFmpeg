import SwiftUI

struct HWAccelerationCard: View {
    let videoCodec: VideoCodec
    @Binding var hwAccelEnabled: Bool
    @EnvironmentObject var langMgr: LanguageManager
    private func t(_ k: L10n.Key) -> String { L10n.string(k, language: langMgr.language) }

    private var isAvailable: Bool { videoCodec.supportsHWAccel }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // frame(maxWidth:.infinity) ensures card stays full-width when disabled
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 7) {
                    Image(systemName: "cpu")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.purple)
                    Text(t(.hwAccelTitle))
                        .font(.system(size: 12.5, weight: .semibold))
                        .foregroundStyle(Theme.text)
                }

                Text(subtitleText)
                    .font(.system(size: 11))
                    .foregroundStyle(subtitleColor)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)

                if isAvailable && hwAccelEnabled {
                    HStack(spacing: 4) {
                        Group {
                            Text("-c:v ")
                                .foregroundStyle(Theme.text3)
                            + Text("hevc_videotoolbox")
                                .foregroundStyle(Theme.purple)
                                .fontWeight(.semibold)
                            + Text(" -tag:v hvc1")
                                .foregroundStyle(Theme.text3)
                        }
                        .font(.system(size: 10, design: .monospaced))
                    }
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.surface2)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .strokeBorder(Theme.border2, lineWidth: 1)
                    )
                    .padding(.top, 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Toggle("", isOn: Binding(
                get: { hwAccelEnabled && isAvailable },
                set: { if isAvailable { hwAccelEnabled = $0 } }
            ))
            .toggleStyle(.switch)
            .disabled(!isAvailable)
            .labelsHidden()
            .controlSize(.small)
            .padding(.top, 2)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Theme.border2, lineWidth: 1)
        )
        .opacity(isAvailable ? 1.0 : 0.45)
        .animation(.easeInOut(duration: 0.15), value: hwAccelEnabled)
        .animation(.easeInOut(duration: 0.15), value: isAvailable)
    }

    private var subtitleText: String {
        guard isAvailable else {
            switch videoCodec {
            case .h264:
                return langMgr.language == .english
                    ? "Not available for H.264. Select H.265 to enable."
                    : "Недоступно для H.264. Выберите H.265 для включения."
            case .vp9:
                return langMgr.language == .english
                    ? "Not available: VP9 doesn't support HW acceleration."
                    : "Недоступно: VP9 не поддерживает HW-ускорение."
            case .av1:
                return langMgr.language == .english
                    ? "Not available: AV1 doesn't support HW acceleration."
                    : "Недоступно: AV1 не поддерживает HW-ускорение."
            case .h265Hw:
                return langMgr.language == .english
                    ? "Already using hardware encoder."
                    : "Уже используется аппаратный кодировщик."
            default:
                return langMgr.language == .english
                    ? "Not available for this codec."
                    : "Недоступно для этого кодека."
            }
        }
        if hwAccelEnabled {
            return langMgr.language == .english
                ? "libx265 → hevc_videotoolbox · 5–10× faster, ~5–10% larger file."
                : "libx265 → hevc_videotoolbox · В 5–10× быстрее, файл ~5–10% больше."
        } else {
            return langMgr.language == .english
                ? "Apple Silicon hardware encoder. 5–10× faster than software H.265."
                : "Аппаратный кодировщик Apple Silicon. В 5–10× быстрее программного H.265."
        }
    }

    private var subtitleColor: Color {
        if !isAvailable { return Theme.amber }
        if hwAccelEnabled { return Theme.purple.opacity(0.85) }
        return Theme.text3
    }
}
