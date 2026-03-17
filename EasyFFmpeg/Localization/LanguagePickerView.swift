import SwiftUI

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
        // Full width, subdued appearance matching sidebar footer style
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 2)
        .buttonStyle(.plain)
    }
}
