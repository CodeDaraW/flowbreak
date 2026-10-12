import Foundation

/// Round up so a running countdown does not read zero before it has ended.
func menuBarCountdown(_ remaining: Double, text: (String) -> String) -> String {
    let minutes = remaining >= 60
    let value = Int(ceil(max(0, remaining) / (minutes ? 60 : 1)))
    return String(format: text(minutes ? "menu.countdown.minutes" : "menu.countdown.seconds"), value)
}
