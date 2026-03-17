import SwiftUI

struct OutputSettingsView: View {
    @EnvironmentObject var langMgr: LanguageManager
    private func t(_ k: L10n.Key) -> String { L10n.string(k, language: langMgr.language) }
    @Binding var outputFileName: String
    @Binding var outputFolderURL: URL?
    let onChooseFolder: () -> Void

    // Fix 2: track focus state to allow dismissing
    @FocusState private var fileNameFocused: Bool

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                // File name
                VStack(alignment: .leading, spacing: 5) {
                    Text(t(.fileName))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 4) {
                        TextField(t(.fileName), text: $outputFileName)
                            .textFieldStyle(.roundedBorder)
                            .font(.caption)
                            .focused($fileNameFocused) // Fix 2
                        Text(".mp4")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Divider()

                // Output folder
                VStack(alignment: .leading, spacing: 5) {
                    Text(t(.saveFolder))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 6) {
                        Label(
                            outputFolderURL?.abbreviatingWithTildeInPath ?? "Не выбрана",
                            systemImage: "folder"
                        )
                        .font(.caption)
                        .foregroundStyle(outputFolderURL == nil ? .secondary : .primary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Button(t(.changeFolder), action: onChooseFolder)
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                    }
                }
            }
            .padding(6)
            // Fix 2: click outside the text field → resign focus
            .contentShape(Rectangle())
            .onTapGesture {
                fileNameFocused = false
            }
        } label: {
            Label(t(.outputSettings), systemImage: "square.and.arrow.down")
                .font(.callout).fontWeight(.semibold)
        }
    }
}

private extension URL {
    var abbreviatingWithTildeInPath: String {
        (path as NSString).abbreviatingWithTildeInPath
    }
}
