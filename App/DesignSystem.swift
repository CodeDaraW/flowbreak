import SwiftUI

/// Native semantic colors retain contrast in both system appearances.
enum FlowStyle {
    static let blue = Color.accentColor
    static let green = Color.green
    static let canvas = Color(nsColor: .windowBackgroundColor)
    static let card = Color(nsColor: .controlBackgroundColor)
    static let border = Color.primary.opacity(0.09)
}

struct FlowCard<Content: View>: View {
    var accent: Color = .clear
    @ViewBuilder var content: Content
    var body: some View {
        content.padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(FlowStyle.card, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(accent == .clear ? FlowStyle.border : accent.opacity(0.35)))
    }
}

struct FlowButtonStyle: ButtonStyle {
    var prominent = false
    var tint: Color = .accentColor
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(size: 12, weight: .semibold))
            .frame(maxWidth: .infinity, minHeight: 36)
            .padding(.horizontal, 8)
            .foregroundStyle(prominent ? Color.white : Color.primary)
            .background(prominent ? tint : FlowStyle.card, in: RoundedRectangle(cornerRadius: 9))
            .overlay(RoundedRectangle(cornerRadius: 9).strokeBorder(prominent ? .clear : FlowStyle.border))
            .opacity(configuration.isPressed ? 0.65 : 1)
            .contentShape(RoundedRectangle(cornerRadius: 9))
    }
}

struct SectionCaption: View {
    let title: String
    var body: some View { Text(title).font(.system(size: 10, weight: .semibold)).foregroundStyle(.secondary) }
}

func timeString(_ seconds: Double) -> String {
    let total = Int(max(0, min(seconds, Double(Int.max / 2))).rounded(.up))
    return String(format: "%02d:%02d", total / 60, total % 60)
}
