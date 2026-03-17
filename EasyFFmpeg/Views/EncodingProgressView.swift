import SwiftUI

struct EncodingProgressView: View {
    @EnvironmentObject var langMgr: LanguageManager
    private func t(_ k: L10n.Key) -> String { L10n.string(k, language: langMgr.language) }
    let progress: EncodingProgress?
    let fileName: String
    let onCancel: () -> Void
    let isDone: Bool
    let error: String?
    let completionStats: CompletionStats?
    let onReveal: () -> Void
    let onReset: () -> Void

    var body: some View {
        GroupBox {
            VStack(spacing: 14) {
                if isDone {
                    doneView
                } else if let error = error {
                    errorView(error)
                } else {
                    encodingView
                }
            }
            .padding(4)
            .animation(.easeInOut(duration: 0.25), value: isDone)
        } label: {
            Label(
                isDone ? t(.done) : t(.encoding),
                systemImage: isDone ? "checkmark.circle.fill" : "gearshape.arrow.triangle.2.circlepath"
            )
            .font(.headline)
            .foregroundStyle(isDone ? .green : .primary)
        }
    }

    @ViewBuilder
    private var encodingView: some View {
        // File name
        Text(fileName)
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .truncationMode(.middle)
            .frame(maxWidth: .infinity, alignment: .leading)

        // Progress bar + percentage
        VStack(spacing: 5) {
            ProgressView(value: progress?.percentage ?? 0)
                .progressViewStyle(.linear)
                .tint(Color.accentColor)

            HStack {
                Text(String(format: "%.0f%%", (progress?.percentage ?? 0) * 100))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.accentColor)
                    .monospacedDigit()
                Spacer()
                if let eta = progress?.eta {
                    Text("~\(eta.formattedDuration) " + (langMgr.language == .english ? "left" : "осталось"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
        }

        // Stats row
        if let prog = progress {
            HStack(spacing: 0) {
                statCell(icon: "clock",       label: t(.elapsed),    value: prog.elapsed.formattedDuration)
                Divider().frame(height: 28)
                statCell(icon: "bolt",        label: t(.speed),  value: String(format: "%.1fx", prog.speed))
                Divider().frame(height: 28)
                statCell(icon: "film",        label: t(.processed),
                         value: "\(fmtTime(prog.currentTime)) / \(fmtTime(prog.totalDuration))")
            }
            .background(Color.secondary.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 7))
        } else {
            HStack(spacing: 6) {
                ProgressView().scaleEffect(0.7)
                Text(langMgr.language == .english ? "Starting…" : "Запуск…").font(.caption).foregroundStyle(.secondary)
            }
        }

        Button(t(.cancel), action: onCancel)
            .buttonStyle(.bordered)
            .tint(.red)
            .controlSize(.regular)
    }

    @ViewBuilder
    private var doneView: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(.green)
            Text(t(.encodingComplete)).font(.headline)
        }

        // Completion stats grid
        if let stats = completionStats {
            HStack(spacing: 0) {
                statCell(
                    icon: "clock.fill",
                    label: langMgr.language == .english ? "Time" : "Время",
                    value: stats.formattedElapsed,
                    color: .blue
                )
                Divider().frame(height: 36)
                statCell(
                    icon: "arrow.down.circle.fill",
                    label: langMgr.language == .english ? "Saved" : "Сэкономлено",
                    value: "\(stats.savedPercent)%",
                    color: .green
                )
                Divider().frame(height: 36)
                statCell(
                    icon: "internaldrive",
                    label: langMgr.language == .english ? "Result" : "Результат",
                    value: stats.formattedOutput,
                    color: .primary
                )
            }
            .background(Color.secondary.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // Size comparison bar
            GeometryReader { geo in
                let ratio = min(Double(stats.outputBytes) / Double(max(stats.inputBytes, 1)), 1.0)
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.12))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.green)
                        .frame(width: geo.size.width * ratio, height: 6)
                }
            }
            .frame(height: 6)

            HStack {
                Text(stats.formattedInput)
                    .font(.caption2).foregroundStyle(.secondary)
                Spacer()
                Text("→ \(stats.formattedOutput)")
                    .font(.caption2).fontWeight(.medium)
                    .foregroundStyle(.green)
            }
        }

        HStack(spacing: 10) {
            Button(t(.showInFinder), action: onReveal)
                .buttonStyle(.borderedProminent)
            Button(t(.processAnother), action: onReset)
                .buttonStyle(.bordered)
        }
    }

    @ViewBuilder
    private func errorView(_ error: String) -> some View {
        Image(systemName: "xmark.circle.fill").font(.system(size: 38)).foregroundStyle(.red)
        Text(t(.encodingError)).font(.headline)
        Text(error)
            .font(.caption).foregroundStyle(.secondary)
            .multilineTextAlignment(.center).textSelection(.enabled)
        Button(langMgr.language == .english ? "Try Again" : "Попробовать снова", action: onReset).buttonStyle(.bordered)
    }

    @ViewBuilder
    private func statCell(icon: String, label: String, value: String,
                          color: Color = .secondary) -> some View {
        VStack(spacing: 2) {
            Image(systemName: icon).font(.caption2).foregroundStyle(color)
            Text(value).font(.caption).fontWeight(.medium).monospacedDigit().lineLimit(1)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 7)
    }

    private func fmtTime(_ s: Double) -> String {
        let t = Int(s); let m = t / 60; let sec = t % 60
        return String(format: "%d:%02d", m, sec)
    }
}
