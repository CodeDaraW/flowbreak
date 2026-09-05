# Iteration NNNN: Title

Status: planned | active | completed | blocked

## plan.md

- Source / date / confirmed constraints
- Requirement IDs (FB-*) and specification changes
- Scope and non-goals
- Design and linked ADRs
- Acceptance criteria and required environments

## tasks.md

- [ ] Stable task ID, requirement mapping, implementation path
- [ ] Verification command or manual procedure
- [ ] Documentation and requirement status updates

## verification.md

For each check: environment, command or steps, expected, actual, verdict, evidence.
Record untested scenarios and remaining limitations explicitly.

## manifest.json

```json
{
  "id": "NNNN-slug",
  "status": "planned",
  "requirements": ["FB-001"],
  "decisions": ["docs/decisions/0001-native-foundation.md"],
  "artifacts": ["plan.md", "tasks.md", "verification.md"]
}
```

Resolve decision paths relative to repo root; artifact paths relative to iteration.
Close only after acceptance. Subsequent changes get a new iteration, not an overwrite.
