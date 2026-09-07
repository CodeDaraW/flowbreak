# Iteration 0009: Button hit regions and hover feedback

Status: active

User reports small button hit regions and missing native-style hover affordance visible in r02. FB-001, FB-009, FB-011. Approved source uses button background/brightness hover transitions and padded hit regions. Current FlowButtonStyle has pressed feedback only; plain/borderless text controls often expose text-sized regions.

Use shared enabled-aware hover/pressed styling for primary, secondary, text, icon, sidebar and mode-card buttons. Main buttons use 40 pt minimum height; compact actions use 32 pt, with the entire padded shape clickable. Keep disabled controls inactive and visually muted. Preserve native pickers/toggles and timing semantics. Verify actual layouts and clicks in the native app, without treating generated hover previews as physical pointer evidence.

In parallel resume iteration 0007 on newly supplied development identity. Initial identity existed but was not valid in keychain search; adding verified Apple WWDR G3 intermediate (without trust overrides) made it valid.
