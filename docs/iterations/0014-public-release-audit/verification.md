# Public release audit verification

Date: 2026-09-07. Requirement: FB-012.

## Scope and method

Baseline HEAD: `2fa0e79cbaacb42d3382e3fd891b3dabfc78e46e`.

- Enumerated `git rev-list --objects --all --reflog`: 25 commits, 241 trees and 284 unique blobs. This includes main and local Codex refs, plus reflog-reachable objects, rather than just the latest snapshot.
- Read commit messages and author/committer metadata; scanned every textual historical blob with local Python patterns for private-key headers, common provider tokens, credential assignments, email addresses, personal home paths, internal hostnames, URLs and IPv4 addresses. Reviewed contextual keyword and high-entropy candidates. No repository content was uploaded to an external scanner.
- Checked the 119 baseline tracked files and the four new iteration files. Enumerated historical paths and tested them against ignore rules using `git check-ignore --no-index --stdin`; no historical path matched the ignored local-workspace/build/credential paths.
- `git fsck --full --no-reflogs` exited 0 with no diagnostics. `git diff --check` passed.
- Historical binaries are seven unique PNG icon blobs (reused by ten icon filenames). Examined PNG chunks and EXIF: only image dimensions in EXIF, no author, GPS or text metadata. Inspected the largest icon visually: project leaf artwork.

## Findings

No credentials, private keys, signing identities/Team ID values, internal service links, personal absolute home paths, private account records or raw chat exports were identified in the reviewed publishable files or history.

Git author/committer metadata contains the existing personal name and email. The author explicitly approved their publication during this audit. History is preserved; this is an accepted disclosure, not an absent finding.

URLs are public Apple documentation/certificate and GitHub references. Token keyword matches were observer variables or documentation, not authentication values. Email-like icon filenames and high-entropy paths/build-setting names were false positives. Research mentions of Feishu and a source-design archive filename/hash are project context, without private chat contents or private service links.

Ignored local build output, generated Xcode projects, tools and workspaces remain outside the publishable file set. Their private contents were not audited as release assets and must remain excluded. This audit covers source publication through Git, not uploading the entire local directory or distributing a signed binary.

## License and documentation

- Existing LICENSE contains the complete MIT grant, notice condition and warranty/liability disclaimer, with the existing 2026 FlowBreak contributors notice. Retained unchanged.
- Both READMEs now state that the project was built entirely through Vibe Coding and does not accept external contributions, including pull requests. CONTRIBUTING.md states the same policy in both languages; the former invitation was removed.
- No external package dependencies are declared in Package.swift or project.yml. The icon generator is tracked; the research note explicitly records that reference-project code was not copied. This is a repository review, not independent proof of all generated code provenance.
- Added ignore patterns for local certificate, private-key and keychain file extensions.

## Validation and disposition

Initial `make check` was blocked by the execution sandbox (`sandbox_apply: Operation not permitted`). After execution approval, the same `make check` completed with exit 0: document checks (12 requirements, 14 iterations, 197 bilingual keys), 56 tests and Xcode build passed. No sandbox settings were changed. Raw logs and scan output remain outside Git in temporary local storage.

No application behavior was changed; no new UI acceptance is claimed. Existing platform acceptance gaps remain as documented in earlier iterations.

Result: no publication blocker identified within this scope, with the Git identity disclosure explicitly accepted. Pattern scanning and manual candidate review cannot prove the absence of every possible secret; Gitleaks and TruffleHog were not installed or run. Recheck any later changes before publishing. No history rewrite, remote configuration, push or publication was performed.
