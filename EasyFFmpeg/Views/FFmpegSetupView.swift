import SwiftUI

enum UpdateStatus {
    case unknown
    case checking
    case upToDate(version: String)
    case updateAvailable(current: String, latest: String)
    case failed
}

struct FFmpegSetupView: View {
    @ObservedObject var manager: FFmpegManager
    @EnvironmentObject var langMgr: LanguageManager
    private func t(_ k: L10n.Key) -> String { L10n.string(k, language: langMgr.language) }
    @State private var showInstallLog = false
    @State private var updateStatus: UpdateStatus = .unknown

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Fix 2: status + version check merged into one card
                statusCard
                if manager.ffmpegPath != nil { codecSupportCard }
                if !manager.homebrewInstalled { homebrewCard }
                else if manager.ffmpegPath == nil { installCard }
                if manager.isInstalling { installProgressCard }
                licenseCard
            }
            .padding(20)
            .padding(.bottom, 16)
        }
        .navigationTitle(t(.ffmpegTitle))
        .task { await manager.detectFFmpeg() }
    }

    // MARK: — Status + Update (Fix 2: merged)

    @ViewBuilder
    private var statusCard: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {

                // Row 1: status icon + info + refresh
                HStack(spacing: 10) {
                    Image(systemName: statusIcon).font(.title2).foregroundStyle(statusColor)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(statusTitle).font(.headline)
                        Text(statusSubtitle).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    if manager.isChecking {
                        ProgressView().scaleEffect(0.8)
                    } else {
                        Button {
                            Task {
                                await manager.detectFFmpeg()
                                updateStatus = .unknown
                            }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .buttonStyle(.bordered).controlSize(.small)
                        .help(t(.ffmpegCheckUpdates))
                    }
                }

                if let path = manager.ffmpegPath {
                    Divider()
                    Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 6) {
                        infoRow(t(.ffmpegVersion), manager.installedVersion ?? "—")
                        infoRow(t(.ffmpegSource), manager.ffmpegSource.rawValue)
                        infoRow(t(.ffmpegPath), path)
                    }

                    // Row 2 (Homebrew only): update check inline
                    if manager.homebrewInstalled {
                        Divider()
                        HStack(spacing: 10) {
                            updateStatusView
                            Spacer()
                            if case .updateAvailable = updateStatus {
                                Button {
                                    Task { await manager.updateFFmpegViaHomebrew() }
                                } label: {
                                    Label(t(.ffmpegUpdate), systemImage: "arrow.triangle.2.circlepath")
                                }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.small)
                                .disabled(manager.isInstalling)
                            }
                        }
                    }
                }
            }
            .padding(4)
        } label: {
            Label(t(.ffmpegStatus), systemImage: "gearshape.2").font(.headline)
        }
    }

    @ViewBuilder
    private var updateStatusView: some View {
        switch updateStatus {
        case .unknown:
            Button {
                Task { await checkForUpdates() }
            } label: {
                Label(t(.ffmpegCheckUpdates), systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered).controlSize(.small)

        case .checking:
            HStack(spacing: 6) {
                ProgressView().scaleEffect(0.7)
                Text(t(.ffmpegChecking)).font(.caption).foregroundStyle(.secondary)
            }

        case .upToDate(let v):
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green).font(.caption)
                Text("FFmpeg \(v) \(t(.ffmpegUpToDate))").font(.caption).foregroundStyle(.secondary)
                Button { Task { await checkForUpdates() } } label: {
                    Image(systemName: "arrow.clockwise").font(.caption2)
                }
                .buttonStyle(.plain).foregroundStyle(.tertiary)
            }

        case .updateAvailable(let cur, let latest):
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.circle.fill").foregroundStyle(.orange).font(.caption)
                VStack(alignment: .leading, spacing: 1) {
                    Text(t(.ffmpegUpdateAvailable) + " \(latest)").font(.caption).fontWeight(.semibold)
                    Text((langMgr.language == .english ? "Installed: " : "Установлена: ") + cur).font(.caption2).foregroundStyle(.secondary)
                }
            }

        case .failed:
            HStack(spacing: 6) {
                Image(systemName: "wifi.slash").foregroundStyle(.orange).font(.caption)
                Text(t(.ffmpegNoConnection)).font(.caption).foregroundStyle(.secondary)
                Button { Task { await checkForUpdates() } } label: {
                    Image(systemName: "arrow.clockwise").font(.caption2)
                }
                .buttonStyle(.plain).foregroundStyle(.tertiary)
            }
        }
    }

    private func checkForUpdates() async {
        updateStatus = .checking
        guard let url = URL(string: "https://formulae.brew.sh/api/formula/ffmpeg.json") else {
            updateStatus = .failed; return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let versions = json["versions"] as? [String: Any],
               let stable = versions["stable"] as? String {
                let current = manager.installedVersion ?? ""
                updateStatus = (!stable.isEmpty && stable != current && !current.isEmpty)
                    ? .updateAvailable(current: current, latest: stable)
                    : .upToDate(version: stable.isEmpty ? current : stable)
            } else {
                updateStatus = .failed
            }
        } catch {
            updateStatus = .failed
        }
    }

    private var statusIcon: String { manager.ffmpegPath != nil ? "checkmark.circle.fill" : "xmark.circle.fill" }
    private var statusColor: Color { manager.ffmpegPath != nil ? .green : .red }
    private var statusTitle: String {
        manager.isChecking ? t(.ffmpegChecking) : (manager.ffmpegPath != nil ? t(.ffmpegReady) : t(.ffmpegNotFound))
    }
    private var statusSubtitle: String {
        manager.ffmpegSource == .notFound ? t(.ffmpegInstallHint) : "\(t(.ffmpegSource)): \(manager.ffmpegSource.rawValue)"
    }

    // MARK: — Codec support

    @ViewBuilder
    private var codecSupportCard: some View {
        GroupBox {
            if manager.codecSupport.isEmpty {
                HStack { ProgressView().scaleEffect(0.7); Text("Проверка…").font(.caption).foregroundStyle(.secondary) }.padding(4)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 170))], spacing: 8) {
                    ForEach(VideoCodec.allCases) { codec in
                        let ok = manager.codecSupport[codec.rawValue] ?? false
                        HStack(spacing: 6) {
                            Image(systemName: ok ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(ok ? .green : .secondary).font(.caption)
                            Text(codec.displayName).font(.caption).foregroundStyle(ok ? .primary : .secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
                .padding(4)
            }
        } label: {
            Label(t(.ffmpegCodecSupport), systemImage: "cpu").font(.headline)
        }
    }

    // MARK: — Install

    @ViewBuilder
    private var installCard: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text(t(.ffmpegNotFound) + ". " + t(.ffmpegInstallHint) + ":").font(.caption).foregroundStyle(.secondary)
                Button {
                    Task { await manager.installFFmpegViaHomebrew() }
                } label: {
                    Label(t(.ffmpegInstall), systemImage: "arrow.down.circle")
                        .frame(maxWidth: .infinity).padding(.vertical, 2)
                }
                .buttonStyle(.borderedProminent).disabled(manager.isInstalling)
                Divider()
                Text("Или установите вручную:").font(.caption).foregroundStyle(.secondary)
                manualInstallCode("brew install ffmpeg")
            }
            .padding(4)
        } label: {
            Label(t(.ffmpegInstall), systemImage: "arrow.down.to.line").font(.headline)
        }
    }

    @ViewBuilder
    private var homebrewCard: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text(t(.homebrewNotInstalled))
                    .font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                Button {
                    Task { await manager.installFFmpegViaHomebrew() }
                } label: {
                    Label(t(.homebrewInstallBtn), systemImage: "shippingbox")
                        .frame(maxWidth: .infinity).padding(.vertical, 2)
                }
                .buttonStyle(.borderedProminent)
                Divider()
                Text(t(.manualInstall) + ":").font(.caption).foregroundStyle(.secondary)
                manualInstallCode(#"/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)""#)
                manualInstallCode("brew install ffmpeg")
            }
            .padding(4)
        } label: {
            Label(t(.homebrewNotInstalled).components(separatedBy: ".").first ?? t(.homebrewNotInstalled), systemImage: "shippingbox").font(.headline)
        }
    }

    @ViewBuilder
    private var installProgressCard: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                ProgressView().progressViewStyle(.linear)
                Text(manager.installProgress).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                if !manager.installLog.isEmpty {
                    Button(showInstallLog ? t(.hideLog) : t(.showLog)) { showInstallLog.toggle() }
                        .buttonStyle(.plain).font(.caption)
                    if showInstallLog {
                        ScrollView {
                            Text(manager.installLog)
                                .font(.system(.caption2, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxHeight: 150)
                        .background(Color.secondary.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            }
            .padding(4)
        } label: {
            Label(langMgr.language == .english ? "Installing…" : "Установка…", systemImage: "gearshape.arrow.triangle.2.circlepath").font(.headline)
        }
    }

    // MARK: — License

    @ViewBuilder
    private var licenseCard: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Text(t(.ffmpegLicenseIntro))
                    .font(.caption).fixedSize(horizontal: false, vertical: true)
                Divider()
                VStack(alignment: .leading, spacing: 6) {
                    let isEn = langMgr.language == .english
                    licenseRow(icon: "doc.text",       title: "FFmpeg",
                        text: isEn ? "Licensed under LGPL 2.1+ (some components under GPL 2+). ffmpeg.org"
                                   : "Распространяется под лицензией LGPL 2.1+ (с отдельными компонентами под GPL 2+). ffmpeg.org")
                    licenseRow(icon: "lock.shield",     title: "H.264 (libx264)",
                        text: isEn ? "GPLv2. Patent licensing may be required for commercial use."
                                   : "GPLv2. Патентное лицензирование может потребоваться для коммерческого использования.")
                    licenseRow(icon: "lock.shield",     title: "H.265 (libx265)",
                        text: isEn ? "GPLv2+. Protected by HEVC Advance and Via LA patents. No restrictions for personal use."
                                   : "GPLv2+. Защищён патентами HEVC Advance и Via LA. Для личного использования ограничений нет.")
                    licenseRow(icon: "checkmark.shield", title: "VP9 (libvpx)",
                        text: isEn ? "BSD. Fully free, no patent restrictions. Developed by Google."
                                   : "BSD. Полностью свободный, без патентных ограничений. Разработан Google.")
                    licenseRow(icon: "checkmark.shield", title: "AV1 (libsvtav1)",
                        text: isEn ? "BSD + Patent License. Open standard by Alliance for Open Media. No royalties."
                                   : "BSD + Patent License. Открытый стандарт Alliance for Open Media. Без лицензионных отчислений.")
                    licenseRow(icon: "checkmark.shield", title: "Opus (libopus)",
                        text: isEn ? "BSD. Fully free audio codec. Developed by Xiph.Org."
                                   : "BSD. Полностью свободный аудиокодек. Разработан Xiph.Org.")
                }
                Divider()
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "info.circle").font(.caption2).foregroundStyle(.secondary)
                    Text(t(.ffmpegLicenseNote))
                        .font(.caption2).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                }
                Button {
                    NSWorkspace.shared.open(URL(string: "https://ffmpeg.org/legal.html")!)
                } label: {
                    Label(t(.ffmpegLicenseLink), systemImage: "arrow.up.right.square").font(.caption)
                }
                .buttonStyle(.plain).foregroundStyle(Color.accentColor)
            }
            .padding(4)
        } label: {
            Label(t(.ffmpegLicenses), systemImage: "doc.badge.gearshape").font(.headline)
        }
    }

    @ViewBuilder
    private func licenseRow(icon: String, title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon).font(.caption).foregroundStyle(.secondary).frame(width: 16)
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.caption).fontWeight(.semibold)
                Text(text).font(.caption2).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    @ViewBuilder
    private func infoRow(_ label: String, _ value: String) -> some View {
        GridRow {
            Text(label).foregroundStyle(.secondary).font(.caption).gridColumnAlignment(.trailing)
            Text(value).font(.caption).textSelection(.enabled)
        }
    }

    @ViewBuilder
    private func manualInstallCode(_ cmd: String) -> some View {
        HStack {
            Text(cmd)
                .font(.system(.caption2, design: .monospaced)).textSelection(.enabled)
                .padding(8).frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.secondary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            Button {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(cmd, forType: .string)
            } label: {
                Image(systemName: "doc.on.doc").font(.caption)
            }
            .buttonStyle(.plain).foregroundStyle(.secondary)
        }
    }
}
