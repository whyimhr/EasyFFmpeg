import SwiftUI

struct ContentView: View {
    @StateObject private var mainVM    = MainViewModel()
    @StateObject private var batchVM   = BatchViewModel()
    @StateObject private var ffmpegMgr = FFmpegManager.shared
    @StateObject private var langMgr   = LanguageManager.shared
    @ObservedObject private var themeMgr = ThemeManager.shared
    @State private var selectedItem: SidebarItem = .single

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedItem) {
                Section("Main") {
                    ForEach([SidebarItem.single, .batch]) { item in
                        Label(item.label(langMgr.language), systemImage: item.icon).tag(item)
                    }
                }
                Section("Tools") {
                    ForEach([SidebarItem.ffmpeg, .help]) { item in
                        Label(item.label(langMgr.language), systemImage: item.icon).tag(item)
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 160, ideal: 190)
            .listStyle(.sidebar)
            .background(Theme.sidebar)
            .scrollContentBackground(.hidden)

        } detail: {
            Group {
                switch selectedItem {
                case .single:
                    SingleFileView()
                        .environmentObject(mainVM)
                        .environmentObject(langMgr)
                case .batch:
                    BatchView()
                        .environmentObject(batchVM)
                        .environmentObject(langMgr)
                case .ffmpeg:
                    FFmpegSetupView(manager: ffmpegMgr)
                        .environmentObject(langMgr)
                case .help:
                    HelpView()
                        .environmentObject(langMgr)
                }
            }
            // .id forces full re-render on theme change so Theme.* computed colors update instantly
            .id(themeMgr.isDark)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.panel)
        }
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                ThemeToggleButton()
                LanguagePickerCompact()
            }
        }
        .task { await ffmpegMgr.detectFFmpeg() }
    }
}

enum SidebarItem: String, CaseIterable, Identifiable {
    case single = "single", batch = "batch", ffmpeg = "ffmpeg", help = "help"
    var id: String { rawValue }
    func label(_ lang: AppLanguage) -> String {
        switch self {
        case .single:  return L10n.string(.singleFile,      language: lang)
        case .batch:   return L10n.string(.batchProcessing, language: lang)
        case .ffmpeg:  return L10n.string(.ffmpegMenu,      language: lang)
        case .help:    return L10n.string(.help,            language: lang)
        }
    }
    var icon: String {
        switch self {
        case .single:  return "film"
        case .batch:   return "square.stack.3d.up"
        case .ffmpeg:  return "gearshape.2"
        case .help:    return "questionmark.circle"
        }
    }
}
