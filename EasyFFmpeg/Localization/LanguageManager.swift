import Foundation
import SwiftUI
import Combine

enum AppLanguage: String, CaseIterable, Identifiable {
    case russian = "ru"
    case english = "en"
    var id: String { rawValue }
    var displayName: String {
        switch self { case .russian: return "Русский"; case .english: return "English" }
    }
    var flag: String {
        switch self { case .russian: return "🇷🇺"; case .english: return "🇬🇧" }
    }
}

final class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    @Published var language: AppLanguage {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: "appLanguage") }
    }

    private init() {
        let saved = UserDefaults.standard.string(forKey: "appLanguage") ?? "ru"
        language = AppLanguage(rawValue: saved) ?? .russian
    }
}
