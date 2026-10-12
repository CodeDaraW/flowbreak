# ADR-0009: Draw the status icon and countdown together

Status: Accepted

## Background

After the minute/second formatter and monospaced-digit font change, the user reports vertical misalignment in the native status button. Separate button image/title layout leaves perceived alignment dependent on symbol and fallback-font metrics. The screenshot establishes the visual issue; it does not isolate a single AppKit implementation cause.

## Decision

Keep ADR-0006's native NSStatusItem/NSStatusBarButton and its event/popover ownership. For a countdown, draw the configured SF Symbol and a Core Text line into one template NSImage. Center the symbol's native optical alignment rectangle and the text's visible glyph bounds vertically. Symbol badge canvases can be asymmetric. Use Core Text typographic advance for width, preserving monospaced digit stability. Native template drawing supplies system tint/highlight. With no countdown, use the symbol alone.

Cache by symbol and displayed countdown so one-second engine ticks do not redraw identical labels. Set the button accessibility label to FlowBreak plus the localized countdown; the image is presentation, not the sole accessibility source.

## Alternatives and consequences

- An arbitrary title baseline offset would depend on font, language and symbol and does not express the intended visible centering.
- Custom clickable subviews would add layout/hit-testing responsibility to the native status button. A composite template image leaves existing native interaction intact.
- The label is no longer native button text; accessibility must be explicit, and rendering needs bilingual/retina inspection. No new permissions, private APIs or core dependencies.
