import AppKit
import CoreText

/// One template image lets AppKit center the whole label and apply native menu-bar tint.
@MainActor
func menuBarLabel(symbol: String, countdown: String) -> NSImage? {
    let font = NSFont.monospacedDigitSystemFont(ofSize: NSFont.menuBarFont(ofSize: 0).pointSize, weight: .regular)
    guard let icon = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)?
        .withSymbolConfiguration(.init(pointSize: font.pointSize, weight: .regular)) else { return nil }
    guard !countdown.isEmpty else {
        icon.isTemplate = true
        return icon
    }

    let text = NSAttributedString(string: countdown, attributes: [.font: font, .foregroundColor: NSColor.black])
    let line = CTLineCreateWithAttributedString(text)
    let ink = CTLineGetBoundsWithOptions(line, .useGlyphPathBounds)
    // Ink width varies between digits despite equal advances; only use ink for vertical alignment.
    let textWidth = CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil))
    let gap: CGFloat = 4
    let size = NSSize(width: ceil(icon.size.width + gap + textWidth),
                      height: ceil(max(18, icon.size.height, ink.height)))
    let image = NSImage(size: size, flipped: false) { rect in
        // Symbols provide an optical alignment rect; badges can make the full canvas asymmetric.
        icon.draw(in: NSRect(x: 0, y: rect.height / 2 - icon.alignmentRect.midY,
                            width: icon.size.width, height: icon.size.height),
                  from: .zero, operation: .sourceOver, fraction: 1)
        guard let context = NSGraphicsContext.current?.cgContext else { return false }
        context.saveGState()
        context.textMatrix = .identity
        context.textPosition = CGPoint(x: icon.size.width + gap, y: (rect.height - ink.height) / 2 - ink.minY)
        CTLineDraw(line, context)
        context.restoreGState()
        return true
    }
    image.isTemplate = true
    return image
}
