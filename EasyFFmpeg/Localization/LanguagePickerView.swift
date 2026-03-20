import SwiftUI

struct LanguagePickerCompact: View {
    @ObservedObject var langMgr = LanguageManager.shared

    var body: some View {
        Picker("", selection: $langMgr.language) {
            ForEach(AppLanguage.allCases) { lang in
                Text(lang.shortCode).tag(lang)
            }
        }
        .labelsHidden()
        .pickerStyle(.menu)
        .fixedSize()
        .fontDesign(.monospaced)
        .fontWeight(.semibold)
    }
}

struct LanguagePickerView: View {
    @ObservedObject var langMgr = LanguageManager.shared

    var body: some View {
        Picker("", selection: $langMgr.language) {
            ForEach(AppLanguage.allCases) { lang in
                Text(lang.displayName).tag(lang)
            }
        }
        .labelsHidden()
        .pickerStyle(.menu)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 2)
        .buttonStyle(.plain)
    }
}
