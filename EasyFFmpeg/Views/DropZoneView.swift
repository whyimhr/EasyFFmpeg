import SwiftUI
import UniformTypeIdentifiers

struct DropZoneView: View {
    let langMgr: LanguageManager
    let onFileDropped: (URL) -> Void
    private func t(_ k: L10n.Key) -> String { L10n.string(k, language: langMgr.language) }
    @State private var isTargeted = false

    private let supportedExts = ["mp4", "mov", "mkv", "avi", "webm"]

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    isTargeted ? Color.accentColor : Color.secondary.opacity(0.25),
                    style: StrokeStyle(lineWidth: 1.5, dash: isTargeted ? [] : [6, 4])
                )
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isTargeted
                              ? Color.accentColor.opacity(0.06)
                              : Color.secondary.opacity(0.03))
                )
                .animation(.easeInOut(duration: 0.18), value: isTargeted)

            VStack(spacing: 8) {
                Image(systemName: isTargeted ? "arrow.down.circle.fill" : "arrow.down.circle")
                    .font(.system(size: 32, weight: .light))
                    .foregroundStyle(isTargeted ? Color.accentColor : Color.secondary)
                    .scaleEffect(isTargeted ? 1.08 : 1.0)
                    .animation(.spring(response: 0.28, dampingFraction: 0.65), value: isTargeted)

                Text(isTargeted ? t(.dragDropTitle) : t(.dragDropTitle))
                    .font(.body)
                    .foregroundStyle(isTargeted ? Color.accentColor : .secondary)
                    .multilineTextAlignment(.center)

                Button(t(.chooseFile)) { openFilePanel() }
                    .buttonStyle(.bordered)
                    .controlSize(.regular)
                    .opacity(isTargeted ? 0.4 : 1.0)
                    .animation(.easeInOut(duration: 0.15), value: isTargeted)

                Text(supportedExts.map { ".\($0)" }.joined(separator: "  "))
                    .font(.caption2)
                    .foregroundStyle(.quaternary)
                    .padding(.top, 2)
            }
            .padding(24)
        }
        .frame(height: 180)
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            handleDrop(providers: providers)
        }
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier) { item, _ in
            guard let data = item as? Data,
                  let url = URL(dataRepresentation: data, relativeTo: nil),
                  supportedExts.contains(url.pathExtension.lowercased()) else { return }
            DispatchQueue.main.async { onFileDropped(url) }
        }
        return true
    }

    private func openFilePanel() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [
            .mpeg4Movie, .quickTimeMovie,
            UTType(filenameExtension: "mkv") ?? .movie,
            UTType(filenameExtension: "avi") ?? .movie,
            UTType(filenameExtension: "webm") ?? .movie,
        ]
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK, let url = panel.url { onFileDropped(url) }
    }
}
