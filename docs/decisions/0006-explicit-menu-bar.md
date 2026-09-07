# ADR-0006: Explicit ownership of menu bar presentation

Status: Accepted

User-reported menu bar entry failure makes both the dashboard and its Quit button inaccessible, despite a responsive process. Use AppKit NSStatusItem and a retained NSPopover hosting the existing SwiftUI dashboard. Update the existing status button rather than replacing its scene. Add a native right-click Open/Quit menu independent of SwiftUI layout, and handle application reopen. This narrows the presentation lifecycle under application control without changing reminder/timing semantics. No private APIs or additional permissions.
