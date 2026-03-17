import SwiftUI

struct FileInfoView: View {
    let metadata: VideoMetadata
    let onChooseAnother: () -> Void
    @EnvironmentObject var langMgr: LanguageManager
    private func t(_ k: L10n.Key) -> String { L10n.string(k, language: langMgr.language) }

    private var rows: [(String, String)] {
        var r: [(String, String)] = [
            (t(.labelFile),       metadata.fileName),
            (t(.labelSize),       metadata.formattedSize),
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

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(rows, id: \.0) { label, value in
                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                            Text(label)
                                .font(.caption).foregroundStyle(.secondary)
                                .frame(width: 108, alignment: .leading)
                            Text(value)
                                .font(.caption).fontWeight(.medium)
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }

                Divider()

                Button {
                    onChooseAnother()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text(t(.chooseAnotherFile))
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 4)
                }
                .buttonStyle(.bordered).controlSize(.large)
            }
            .padding(6)
        } label: {
            Label(t(.fileInfo), systemImage: "info.circle")
                .font(.callout).fontWeight(.semibold)
        }
    }
}
