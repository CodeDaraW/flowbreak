# ADR-0008: Persistent nonactivating reminder overlay

Status: Accepted

Supersedes ADR-0003 outside-click dismissal only. Browser clicks must not dismiss a reminder. Remove the global mouse-down monitor rather than filtering some applications. Use public NSWindow.Level.popUpMenu above ordinary app/floating/modal windows, without making the panel key or activating FlowBreak. This is not an absolute guarantee above system security UI or other apps using higher levels. Keep configured expiry and explicit close/snooze/rest/suppression semantics. Native fullscreen and cross-Space remain separately scoped acceptance.
