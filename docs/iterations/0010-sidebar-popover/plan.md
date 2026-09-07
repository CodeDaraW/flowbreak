# Iteration 0010: Sidebar alignment and popover material

Status: active

FB-001, FB-009, FB-011. User screenshots show variable-width symbol alignment and two overlapping selected/hover backgrounds in Settings. Popover arrow uses native material while dashboard paints an opaque canvas, exposing a color seam.

Use an 18 pt symbol column and one shared selected/hover rounded rectangle spanning the whole sidebar row. Let the menu dashboard inherit the native popover material instead of covering its body with a different solid canvas; synchronize popover appearance with app appearance. Standalone dashboard retains its canvas. Keep public AppKit APIs and existing menu lifecycle.
