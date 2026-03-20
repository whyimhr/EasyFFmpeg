import SwiftUI

struct AppCard<Content: View>: View {
    let icon: String
    let title: String
    var trailingHeader: AnyView? = nil
    @ViewBuilder let content: () -> Content

    init(icon: String, title: String,
         @ViewBuilder content: @escaping () -> Content) {
        self.icon = icon; self.title = title
        self.trailingHeader = nil; self.content = content
    }

    init<T: View>(icon: String, title: String,
                  @ViewBuilder trailing: () -> T,
                  @ViewBuilder content: @escaping () -> Content) {
        self.icon = icon; self.title = title
        self.trailingHeader = AnyView(trailing()); self.content = content
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.accent)
                Text(title)
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundStyle(Theme.text)
                Spacer(minLength: 4)
                trailingHeader
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(Theme.surface)
            .overlay(Rectangle().frame(height: 1).foregroundStyle(Theme.border), alignment: .bottom)

            content()
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Theme.border2, lineWidth: 1)
        )
    }
}

struct FormLabel: View {
    let text: String
    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 10.5, weight: .bold))
            .foregroundStyle(Theme.text3)
            .kerning(0.6)
    }
}

struct MonoValue: View {
    let text: String
    var color: Color = Theme.text
    var body: some View {
        Text(text)
            .font(.system(size: 11.5, weight: .medium, design: .monospaced))
            .foregroundStyle(color)
    }
}

struct InfoLabel: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 12.5))
            .foregroundStyle(Theme.text2)
    }
}
