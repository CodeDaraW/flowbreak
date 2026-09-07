# ADR-0007: Native login item

Status: Accepted

Use public SMAppService.mainApp to register the installed main app at login. The system is the source of truth; do not persist a second enabled flag or install a LaunchAgent. Registration is initiated only by the settings toggle, not startup. Show requiresApproval and errors explicitly, and refresh when settings appear or the app becomes active. A login item launches after user login, not before authentication.

Reference: https://developer.apple.com/documentation/servicemanagement/smappservice
