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
    var quiet = false
    var fullWidth = true

    func makeBody(configuration: Configuration) -> some View {
        FlowButtonSurface(configuration: configuration, prominent: prominent,
                          tint: tint, quiet: quiet, fullWidth: fullWidth)
    }
}

private struct FlowButtonSurface: View {
    let configuration: ButtonStyleConfiguration
    let prominent: Bool
    let tint: Color
    let quiet: Bool
    let fullWidth: Bool
    @Environment(\.isEnabled) private var isEnabled
    @State private var hovering = false

    private var highlighted: Bool { isEnabled && hovering }
    private var pressed: Bool { isEnabled && configuration.isPressed }
    var body: some View {
        configuration.label
            .font(.system(size: 12, weight: quiet ? .medium : .semibold))
            .padding(.horizontal, quiet ? 8 : 12)
            .frame(minWidth: 32, maxWidth: fullWidth ? .infinity : nil, minHeight: quiet ? 32 : 40)
            .foregroundStyle(prominent ? Color.white : Color.primary)
            .background {
                RoundedRectangle(cornerRadius: 9)
                    .fill(prominent ? tint : (quiet ? Color.clear : FlowStyle.card))
                RoundedRectangle(cornerRadius: 9)
                    .fill((prominent ? Color.black : Color.primary)
                        .opacity(pressed ? 0.15 : (highlighted ? 0.07 : 0)))
            }
            .overlay(RoundedRectangle(cornerRadius: 9)
                .strokeBorder(quiet || prominent ? Color.clear : FlowStyle.border))
            .contentShape(RoundedRectangle(cornerRadius: 9))
            .opacity(isEnabled ? 1 : 0.42)
            .onHover { hovering = $0 }
            .animation(.easeOut(duration: 0.12), value: highlighted)
            .animation(.easeOut(duration: 0.08), value: pressed)
    }
}

/// Selection and hover share a single padded surface, so their edges cannot drift.
struct FlowSidebarButtonStyle: ButtonStyle {
    let selected: Bool
    func makeBody(configuration: Configuration) -> some View {
        SidebarButtonSurface(configuration: configuration, selected: selected)
    }
}

private struct SidebarButtonSurface: View {
    let configuration: ButtonStyleConfiguration
    let selected: Bool
    @State private var hovering = false
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        let active = isEnabled && (hovering || configuration.isPressed)
        configuration.label
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .frame(minHeight: 36)
            .foregroundStyle(selected ? Color.accentColor : Color.primary)
            .background(RoundedRectangle(cornerRadius: 8)
                .fill(selected ? Color.accentColor.opacity(active ? 0.18 : 0.12)
                      : Color.primary.opacity(active ? 0.07 : 0)))
            .contentShape(RoundedRectangle(cornerRadius: 8))
            .opacity(isEnabled ? 1 : 0.42)
            .onHover { hovering = $0 }
            .animation(.easeOut(duration: 0.12), value: active)
    }
}

/// The card itself is the button surface; no second padded hover backdrop.
struct FlowModeButtonStyle: ButtonStyle {
    let active: Bool
    func makeBody(configuration: Configuration) -> some View {
        ModeButtonSurface(configuration: configuration, active: active)
    }
}

private struct ModeButtonSurface: View {
    let configuration: ButtonStyleConfiguration
    let active: Bool
    @Environment(\.isEnabled) private var isEnabled
    @State private var hovering = false

    var body: some View {
        let highlighted = isEnabled && hovering
        let pressed = isEnabled && configuration.isPressed
        let shape = RoundedRectangle(cornerRadius: 10)
        configuration.label
            .padding(10)
            .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
            .foregroundStyle(Color.primary)
            .background {
                shape.fill(active ? Color.blue.opacity(0.07) : FlowStyle.card)
                shape.fill(Color.primary.opacity(pressed ? 0.15 : highlighted ? 0.07 : 0))
            }
            .overlay(shape.strokeBorder(active ? Color.blue.opacity(0.3) : FlowStyle.border))
            .contentShape(shape)
            .opacity(isEnabled ? 1 : 0.42)
            .onHover { hovering = $0 }
            .animation(.easeOut(duration: 0.12), value: highlighted)
            .animation(.easeOut(duration: 0.08), value: pressed)
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
