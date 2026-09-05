# Contributing

FlowBreak targets macOS 14+ on Apple Silicon only. See [README](README.en.md) for setup and [AGENTS.md](AGENTS.md) for contributor and agent rules.

1. Describe the behavior change in a specification, preserving stable `FB-*` IDs.
2. Create an iteration from [templates](docs/templates/iteration.md); list scope, non-goals, requirement IDs and acceptance checks.
3. Add an ADR for a material architectural decision; reference any research and rejected options.
4. Implement a narrow change, maintain Chinese and English UI strings together, and add meaningful behavioral tests.
5. Run `make check`, record actual outcomes in the iteration verification file, and update implementation status only as far as the evidence supports.

PR descriptions should explain the concrete behavior change, relevant requirement/ADR IDs, validation and remaining limitations. Do not include private runtime data. Contributions are under the [MIT license](LICENSE).
