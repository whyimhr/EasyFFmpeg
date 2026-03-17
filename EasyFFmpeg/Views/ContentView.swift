import SwiftUI

enum SidebarItem: String, CaseIterable, Identifiable {
    case single  = "single"
    case batch   = "batch"
    case ffmpeg  = "ffmpeg"
    case help    = "help"
    var id: String { rawValue }
    func label(_ lang: AppLanguage) -> String {
        switch self {
        case .single:  return L10n.string(.singleFile,       language: lang)
        case .batch:   return L10n.string(.batchProcessing,  language: lang)
        case .ffmpeg:  return L10n.string(.ffmpegMenu,       language: lang)
        case .help:    return L10n.string(.help,             language: lang)
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

struct ContentView: View {
    @StateObject private var mainVM    = MainViewModel()
    @StateObject private var batchVM   = BatchViewModel()
    @StateObject private var ffmpegMgr = FFmpegManager.shared
    @StateObject private var langMgr   = LanguageManager.shared
    @State private var selectedItem: SidebarItem = .single

    var body: some View {
        NavigationSplitView {
            List(SidebarItem.allCases, selection: $selectedItem) { item in
                Label(item.label(langMgr.language), systemImage: item.icon).tag(item)
            }
            .navigationSplitViewColumnWidth(min: 160, ideal: 185)
            .listStyle(.sidebar)

            Divider()
            // Language selector — no flag, just name
            LanguagePickerView()
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        } detail: {
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
        .task { await ffmpegMgr.detectFFmpeg() }
    }
}
