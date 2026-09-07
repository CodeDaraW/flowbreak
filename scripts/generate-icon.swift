// Run from repository root: swift scripts/generate-icon.swift
// Original vector artwork rendered by AppKit; no external assets or dependencies.
import AppKit
import Foundation

let directory = URL(fileURLWithPath: "App/Resources/Assets.xcassets/AppIcon.appiconset", isDirectory: true)
try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
var entries: [[String: String]] = []
for points in [16, 32, 128, 256, 512] {
    for scale in [1, 2] {
        let pixels = points * scale
        let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
        let context = NSGraphicsContext.current!.cgContext
        context.scaleBy(x: CGFloat(pixels) / 1024, y: CGFloat(pixels) / 1024)
        let tile = NSBezierPath(roundedRect: NSRect(x: 76, y: 76, width: 872, height: 872), xRadius: 196, yRadius: 196)
        NSGraphicsContext.saveGraphicsState()
        let shadow = NSShadow(); shadow.shadowColor = NSColor.black.withAlphaComponent(0.20)
        shadow.shadowBlurRadius = 22; shadow.shadowOffset = NSSize(width: 0, height: -10); shadow.set()
        NSColor.systemGreen.setFill(); tile.fill()
        NSGraphicsContext.restoreGraphicsState()
        NSGradient(starting: NSColor(srgbRed: 0.12, green: 0.78, blue: 0.49, alpha: 1),
                   ending: NSColor(srgbRed: 0.02, green: 0.48, blue: 0.36, alpha: 1))!.draw(in: tile, angle: -65)
        let leaf = NSBezierPath()
        leaf.move(to: NSPoint(x: 268, y: 731))
        leaf.curve(to: NSPoint(x: 752, y: 360), controlPoint1: NSPoint(x: 445, y: 608), controlPoint2: NSPoint(x: 821, y: 800))
        leaf.curve(to: NSPoint(x: 268, y: 731), controlPoint1: NSPoint(x: 458, y: 263), controlPoint2: NSPoint(x: 230, y: 442))
        leaf.close(); NSColor.white.setFill(); leaf.fill()
        let vein = NSBezierPath(); vein.move(to: NSPoint(x: 333, y: 609))
        vein.curve(to: NSPoint(x: 727, y: 381), controlPoint1: NSPoint(x: 448, y: 461), controlPoint2: NSPoint(x: 599, y: 558))
        vein.lineWidth = 27; vein.lineCapStyle = .round
        NSColor(srgbRed: 0.07, green: 0.61, blue: 0.41, alpha: 1).setStroke(); vein.stroke()
        let stem = NSBezierPath(); stem.move(to: NSPoint(x: 714, y: 411))
        stem.curve(to: NSPoint(x: 774, y: 300), controlPoint1: NSPoint(x: 750, y: 376), controlPoint2: NSPoint(x: 770, y: 333))
        stem.lineWidth = 29; stem.lineCapStyle = .round; NSColor.white.setStroke(); stem.stroke()
        NSGraphicsContext.restoreGraphicsState()
        let name = "icon_\(points)x\(points)@\(scale)x.png"
        try bitmap.representation(using: .png, properties: [:])!.write(to: directory.appendingPathComponent(name))
        entries.append(["idiom": "mac", "size": "\(points)x\(points)", "scale": "\(scale)x", "filename": name])
    }
}
let contents: [String: Any] = ["images": entries, "info": ["version": 1, "author": "xcode"]]
try JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted, .sortedKeys]).write(to: directory.appendingPathComponent("Contents.json"))
