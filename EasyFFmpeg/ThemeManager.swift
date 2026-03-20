import SwiftUI
import AppKit
import Combine

final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var isDark: Bool {
        didSet {
            UserDefaults.standard.set(isDark, forKey: "appThemeIsDark")
            Task { @MainActor in applyWindowAppearance() }
        }
    }

    private init() {
        let saved = UserDefaults.standard.object(forKey: "appThemeIsDark")
        isDark = (saved as? Bool) ?? true
    }

    @MainActor
    func applyWindowAppearance() {
        let appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
        NSApp.appearance = appearance
        for window in NSApp.windows {
            window.backgroundColor = NSColor(hex: isDark ? "0d0d10" : "f0f0f5")
            window.appearance = appearance
        }
    }
}

// MARK: - ThemeToggleButton
// WCAG fix:
//   Dark mode  — icon: purple #a78bfa on dark bg: ≈7.5:1 ✓
//   Light mode — amber #fbbf24 on white = 1.66:1 ✗ FAILS AA
//                Use dark amber #92400e: 7.0:1 on white ✓ WCAG AA

struct ThemeToggleButton: View {
    @ObservedObject private var themeMgr = ThemeManager.shared

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.72)) {
                themeMgr.isDark.toggle()
            }
        } label: {
            ZStack {
                Capsule()
                    .fill(pillFill)
                    .frame(width: 34, height: 22)
                Capsule()
                    .strokeBorder(pillBorder, lineWidth: 1)
                    .frame(width: 34, height: 22)
                Image(systemName: themeMgr.isDark ? "moon.fill" : "sun.max.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(iconColor)
                    .id("icon-\(themeMgr.isDark)")
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.5).combined(with: .opacity),
                        removal:   .scale(scale: 1.4).combined(with: .opacity)
                    ))
            }
        }
        .buttonStyle(.plain)
        .help(themeMgr.isDark ? "Switch to Light Mode" : "Switch to Dark Mode")
    }

    private var iconColor: Color {
        themeMgr.isDark
            ? Theme.purple                  // #a78bfa on dark — high contrast ✓
            : Color(hex: "92400e")          // dark amber-800 on white: 7.0:1 ✓ WCAG AA
    }

    private var pillFill: Color {
        themeMgr.isDark
            ? Theme.purple.opacity(0.14)
            : Color(hex: "fbbf24").opacity(0.15)
    }

    private var pillBorder: Color {
        themeMgr.isDark
            ? Theme.purple.opacity(0.30)
            : Color(hex: "92400e").opacity(0.40)
    }
}
