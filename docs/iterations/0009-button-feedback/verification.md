# Verification

Before change: FlowButtonStyle exposes only isPressed opacity. Plain close/back/footer/sidebar and borderless actions lack shared hover background. r02 menu page defines background/brightness hover transitions. Native pointer verification pending.


make check passed 56 tests, bilingual/SDD validation and arm64 build. Shared styles cover primary/secondary, mode cards, sidebar, footer, back/close, correction/undo and reminder actions. Enabled-aware onHover/pressed backgrounds are implemented; disabled controls are muted. Primary regions are at least 40 pt high; compact regions at least32 pt with padded contentShape. Native defaults remain for pickers/toggles.

CU clicked Displays sidebar at x140,y238, beyond the text, and observed Displays content: padded hit region PASS. Inspected main dashboard and final settings; removed excess sidebar horizontal padding to keep Recent activity readable. Mode-card click was followed by a no-window observation, but subsequent AX read showed its Keep awake page with Back button, so the action succeeded. Some transient-popover observations were interrupted by changing user focus. Persistent physical hover cannot be proved by click/drag captures alone; requested user feedback on the normal signed app. Final settings screenshot: workspaces/button-feedback/20260907/test_result/settings-final.png. Main layout screenshot also appears in focus quiet evidence. Normal app left running with original user data after restoring isolated parameters.
