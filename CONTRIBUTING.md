# Contributing

## 开发约定

- 优先保持 MoonBit 代码、测试和文档同步更新。
- 功能改动应同时补充测试或示例。
- 对外行为变更应在 `CHANGELOG.md` 中记录。
- 提交前至少运行：

```bash
moon check --warn-list +73
moon test
```

## 提交建议

- `feat:` 新功能或新能力
- `fix:` 缺陷修复
- `docs:` 文档或比赛材料修订
- `ci:` CI 与自动化流程调整
- `chore:` 仓库维护、脚本、自查工具

## 比赛仓库维护说明

- 本仓库默认同时维护 GitHub 与 GitLink 两个远端。
- Mooncakes 发布默认不自动执行，需由仓库维护者手动确认。
- 若参考或移植外部项目，必须同步更新 `docs/source-attribution.md`。
