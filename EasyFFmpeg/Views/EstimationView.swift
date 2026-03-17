import SwiftUI

struct EstimationView: View {
    let metadata: VideoMetadata
    let estimation: EstimationResult
    @EnvironmentObject var langMgr: LanguageManager
    private func t(_ k: L10n.Key) -> String { L10n.string(k, language: langMgr.language) }

    var body: some View {
        GroupBox {
            VStack(spacing: 14) {
                // Arrow diagram
                HStack(alignment: .center, spacing: 0) {
                    sizeBlock(label: t(.original),  value: metadata.formattedSize,    color: .secondary)
                    Spacer()
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.right").font(.title2).foregroundStyle(Color.accentColor)
                        Text(String(format: "%.1f×", max(estimation.compressionRatio, 1.0)))
                            .font(.caption).fontWeight(.semibold)
                            .foregroundStyle(compressionColor).monospacedDigit()
                    }
                    Spacer()
                    sizeBlock(label: t(.expected), value: estimation.formattedSize, color: compressionColor)
                }

                Divider()

                HStack(spacing: 0) {
                    statItem(icon: "arrow.down.circle", label: t(.compression),
                             value: String(format: "%.1f×", max(estimation.compressionRatio, 1.0)))
                    Divider().frame(height: 28)
                    statItem(icon: "clock",         label: t(.timeLabel),   value: estimation.formattedTime)
                    Divider().frame(height: 28)
                    statItem(icon: "internaldrive", label: t(.savings), value: savedSize)
                }
                .background(Color.secondary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(6)
        } label: {
            // Fix 6: same font(.headline) as other sections
            Label(t(.estimation), systemImage: "chart.bar.xaxis")
                .font(.callout).fontWeight(.semibold)
        }
    }

    private var compressionColor: Color {
        let r = estimation.compressionRatio
        if r >= 4 { return .green }
        if r >= 1.5 { return Color.accentColor }
        return .orange
    }

    private var savedSize: String {
        let saved = metadata.fileSize - estimation.estimatedBytes
        guard saved > 0 else { return "—" }
        let mb = Double(saved) / 1_048_576
        if mb >= 1024 { return String(format: "%.1f ГБ", mb / 1024) }
        return String(format: "%.0f МБ", mb)
    }

    @ViewBuilder
    private func sizeBlock(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.title2).fontWeight(.bold).foregroundStyle(color).monospacedDigit()
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(width: 110)
    }

    @ViewBuilder
    private func statItem(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Image(systemName: icon).font(.caption2).foregroundStyle(.secondary)
            Text(value).font(.caption).fontWeight(.semibold).monospacedDigit()
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}
