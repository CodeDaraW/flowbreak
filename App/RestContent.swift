import SwiftUI
import FlowBreakCore

struct RestContent: View {
    @ObservedObject var model: AppModel
    private func text(_ key: String) -> String { model.settings.text(key) }
    var body: some View {
        let eye = model.engine.session.activeBreak == .eye
        let duration = max(1, model.engine.breakDuration)
        VStack(spacing: 14) {
            Image(systemName: eye ? "eye" : "figure.walk").font(.system(size: 30, weight: .light)).foregroundStyle(.green)
            Text(text(eye ? "rest.lookAway" : "rest.move")).font(.system(size: 22, weight: .semibold))
            Text(text(eye ? "rest.eye.help" : "rest.move.help")).font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
            Text(timeString(model.engine.breakRemaining)).font(.system(size: 32, weight: .medium, design: .rounded)).monospacedDigit()
            ProgressView(value: max(0, min(1, 1 - model.engine.breakRemaining / duration))).tint(.green)
            if !eye {
                Button(text("rest.extend.minute")) { model.act { $0.extendBreak(seconds: 60) } }.buttonStyle(FlowButtonStyle())
            }
            Button(text("rest.endEarly")) { model.act { $0.cancelBreak() } }.buttonStyle(FlowButtonStyle())
            Text(text("rest.end.help")).font(.system(size: 10)).foregroundStyle(.secondary)
        }.padding(18).frame(maxWidth: .infinity)
            .background(.green.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))
    }
}
