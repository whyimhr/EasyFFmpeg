import SwiftUI

struct FileInfoView: View {
    let metadata: VideoMetadata
    let onChooseAnother: () -> Void
    @EnvironmentObject var langMgr: LanguageManager
    private func t(_ k: L10n.Key) -> String { L10n.string(k, language: langMgr.language) }

    var body: some View {
        AppCard(icon: "play.rectangle", title: t(.fileInfo)) {
            VStack(spacing: 0) {
                HStack(spacing: 9) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Theme.accent.opacity(0.13))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: "film")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Theme.accent)
                        )

                    VStack(alignment: .leading, spacing: 1) {
                        Text(metadata.fileName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.text)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Text("\(metadata.formattedSize) · \(metadata.formattedResolution) · \(metadata.formattedDuration)")
                            .font(.system(size: 10.5, design: .monospaced))
                            .foregroundStyle(Theme.text3)
                    }

                    Spacer(minLength: 4)

                    Button {
                        onChooseAnother()
                    } label: {
                        Text(langMgr.language == .english ? "Remove" : "Убрать")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Theme.red)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(Theme.red.opacity(0.10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .strokeBorder(Theme.red.opacity(0.25), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 9)

                Rectangle().fill(Theme.border).frame(height: 1).padding(.bottom, 5)

                // .textSelection(.enabled) on VStack propagates to all child Text views
                // — user can click any row, select text, Cmd+C to copy
                VStack(spacing: 0) {
                    ForEach(Array(infoRows.enumerated()), id: \.offset) { idx, row in
                        HStack {
                            Text(row.0)
                                .font(.system(size: 12.5))
                                .foregroundStyle(Theme.text2)
                            Spacer()
                            Text(row.1)
                                .font(.system(size: 11.5, weight: .medium, design: .monospaced))
                                .foregroundStyle(Theme.text)
                        }
                        .padding(.vertical, 4.5)
                        if idx < infoRows.count - 1 {
                            Rectangle().fill(Theme.border).frame(height: 1)
                        }
                    }
                }
                .textSelection(.enabled)
            }
        }
    }

    private var infoRows: [(String, String)] {
        var r: [(String, String)] = [
            (t(.labelDuration),   metadata.formattedDuration),
            (t(.labelResolution), metadata.formattedResolution),
            (t(.labelFPS),        metadata.formattedFPS),
            (t(.labelVideoCodec), metadata.videoCodec.uppercased()),
        ]
        if let vbr = metadata.videoBitrate { r.append((t(.labelVideoBitrate), "\(vbr) kbps")) }
        if let ac  = metadata.audioCodec   { r.append((t(.labelAudioCodec),   ac.uppercased())) }
        if let abr = metadata.audioBitrate { r.append((t(.labelAudioBitrate), "\(abr) kbps")) }
        return r
    }
}
