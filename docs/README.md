# 规格驱动的迭代与决策机制

这是一套轻量 SDD（Specification-Driven Development）流程，不依赖特定 AI 工具或远程服务。规格描述应该怎样，迭代描述本轮改什么，验证描述实际证明了什么。

## 阅读路径

[产品规格](specs/product.md) → [状态与时间规则](specs/state-model.md) → [需求索引](specs/requirements.json) → [当前迭代](iterations/0013-reminder-stacking/plan.md) → [技术决策](decisions/0001-native-foundation.md)。未来工作见 [路线图](roadmap.md)。

## 文档职责与唯一来源

| 位置 | 职责 | 更新方式 |
|---|---|---|
| specs/product.md | 当前认可行为；稳定需求 ID | 行为修改先改规格，在新迭代说明变更 |
| specs/requirements.json | 需求状态、实现路径、验证路径 | 随实现更新；部分实现必须标 partial |
| specs/state-model.md | 优先级、时间语义、关键时间线 | 与规则测试同步 |
| iterations/NNNN-slug/ | plan.md、tasks.md、verification.md、manifest.json | 同一轮持续更新，关闭后只追加勘误 |
| decisions/NNNN-title.md | 背景、决定、替代方案、后果 | Accepted 决策通过新 ADR supersede |
| research/ | 证据、范围、未知项 | 研究结论不能替代规格确认 |

## 每次迭代

1. 创建下一个编号目录，复制 [迭代模板](templates/iteration.md)，创建计划、任务、验证和 manifest。
2. 记录来源、需求 ID、范围、非目标、设计和验收；重要歧义先确认，普通实现选择自行完成。
3. 需要新决策时复制 [ADR 模板](templates/adr.md)。区分 Proposed / Accepted / Superseded；spec 已接受不代表功能已实现。
4. 实现并持续登记任务、变更与实测结果。每个需求映射到代码及验证路径，未做的保留 planned/deferred。
5. `make check` 检查文档关联、双语资源、核心测试及构建。人工检查记录环境、操作、期望、实际和局限，不用构建成功替代用户体验验证。
6. 验收后关闭本轮，记录尚未实现的能力并转入路线图；下一轮不覆盖历史。

manifest 状态：planned / active / completed / blocked。需求实现状态：planned / partial / implemented / deferred。`implemented` 仅用于具备完整行为与验证的需求。

## 约束

原始聊天中的用户诉求与 ChatGPT 建议必须区分。本轮直接确认优先于旧建议。原始聊天导出仅用于本地输入，不放进开源仓库。源码隔离是为了可测试的 macOS 工程，不意味着跨平台承诺。

`python3 scripts/check_docs.py` 验证必需文档、ID 唯一性、迭代关联、实现/验证路径与中英资源键一致；它不裁定文档内容或实际功能正确性。
