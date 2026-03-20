import SwiftUI
import UserNotifications

@main
struct EasyFFmpegApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject private var themeMgr = ThemeManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(themeMgr.isDark ? .dark : .light)
        }
        .defaultSize(width: 960, height: 680)
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound]
        ) { _, _ in }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            NSApp.windows.first?.minSize = NSSize(width: 860, height: 600)
            Task { @MainActor in ThemeManager.shared.applyWindowAppearance() }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}
