import SwiftUI
import AppKit

// MARK: - Design tokens
// All properties are computed vars that read ThemeManager.shared.isDark.
// When ContentView re-renders (because it observes ThemeManager), all child
// views also re-render and pick up updated Theme colors automatically.
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DARK  (isDark = true) — original redesign palette
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//   --bg:       #0d0d10   window background
//   --sidebar:  #111114   sidebar / titlebar
//   --panel:    #17171c   detail area
//   --surface:  #1e1e25   card background
//   --surface2: #252530   inputs, stat rows, preset chips
//   --border:   rgba(255,255,255,.06)  subtle dividers
//   --border2:  rgba(255,255,255,.10)  card/button borders
//   --text:     #e8e8f0   primary
//   --text2:    #9090a8   secondary
//   --text3:    #58586c   tertiary
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LIGHT (isDark = false) — cool-purple-tinted light palette
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//   --bg:       #f0f0f5   window background (cool light grey)
//   --sidebar:  #e7e7f0   sidebar (slightly darker)
//   --panel:    #f5f5fa   detail area
//   --surface:  #ffffff   cards (pure white, stand out from panel)
//   --surface2: #eaeaf2   inputs, stat rows (matching bg tint)
//   --border:   rgba(0,0,0,.06)
//   --border2:  rgba(0,0,0,.11)
//   --text:     #1a1a2c   primary (deep navy, not pure black)
//   --text2:    #52527a   secondary
//   --text3:    #8080aa   tertiary

enum Theme {

    private static var d: Bool { ThemeManager.shared.isDark }

    // ── Backgrounds ─────────────────────────────────────────
    static var bg:       Color { d ? Color(hex: "0d0d10") : Color(hex: "f0f0f5") }
    static var sidebar:  Color { d ? Color(hex: "111114") : Color(hex: "e7e7f0") }
    static var panel:    Color { d ? Color(hex: "17171c") : Color(hex: "f5f5fa") }
    static var surface:  Color { d ? Color(hex: "1e1e25") : Color(hex: "ffffff") }
    static var surface2: Color { d ? Color(hex: "252530") : Color(hex: "eaeaf2") }

    // ── Borders ─────────────────────────────────────────────
    static var border:   Color { d ? Color.white.opacity(0.06) : Color.black.opacity(0.06) }
    static var border2:  Color { d ? Color.white.opacity(0.10) : Color.black.opacity(0.11) }

    // ── Text ────────────────────────────────────────────────
    // WCAG check (light mode, bg = white #ffffff):
    //   text  #1a1a2c → lum≈0.016, contrast 16.5:1 ✓ AAA
    //   text2 #52527a → lum≈0.109, contrast  6.6:1 ✓ AA
    //   text3 #8080aa → lum≈0.230, contrast  3.75:1 ✗ fails AA for small text
    //   text3 fixed: #5c5c8a → lum≈0.136, contrast  5.8:1 ✓ AA
    static var text:     Color { d ? Color(hex: "e8e8f0") : Color(hex: "1a1a2c") }
    static var text2:    Color { d ? Color(hex: "9090a8") : Color(hex: "52527a") }
    static var text3:    Color { d ? Color(hex: "58586c") : Color(hex: "5c5c8a") }  // darkened for WCAG AA

    // ── Accents (identical in both themes) ──────────────────
    static let accent  = Color(hex: "4f8eff")
    static let green   = Color(hex: "34d399")
    static let amber   = Color(hex: "fbbf24")
    static let red     = Color(hex: "f87171")
    static let purple  = Color(hex: "a78bfa")
}

// MARK: - Color(hex:)

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6: (r, g, b) = (int >> 16, (int >> 8) & 0xFF, int & 0xFF)
        default: (r, g, b) = (1, 1, 1)
        }
        self.init(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
    }
}

extension NSColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = CGFloat((int >> 16) & 0xFF) / 255
        let g = CGFloat((int >> 8)  & 0xFF) / 255
        let b = CGFloat(int & 0xFF)          / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
