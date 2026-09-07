# Iteration 0008: Restore menu bar access

Status: completed

User reports the highlighted menu bar icon does not open the dashboard, preventing access to Quit. FB-001, FB-009, FB-011. Live process sampling shows an active AppKit run loop, not a main-thread deadlock. Native CU cannot discover a usable window. Previous standalone-window acceptance did not exercise the production menu bar presentation path.

Replace implicit SwiftUI MenuBarExtra window ownership with an explicitly retained NSStatusItem and NSPopover. Left click toggles the existing dashboard. Right click provides an independent native Open/Quit menu. Reopening the running app presents its dashboard. Preserve Settings scene, existing core and persistence. Record exact verification limits; sample alone does not identify the underlying SwiftUI failure.
