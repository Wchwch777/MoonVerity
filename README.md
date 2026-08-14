# MoonVerity

MoonVerity 是一个纯 MoonBit 数据契约与数据质量闸门工具包，面向 CSV / JSONL 记录型数据，提供契约解析、字段 schema 校验、质量规则、数据画像、契约 diff 和可脚本化 CLI。

## 能力概览

- 字段类型、必填/可空、整数范围、日期、布尔值、枚举和 pattern 的 schema 校验
- `Unique`、`Completeness`、`Enum`、`IntRange`、`CompareInts`、`PatternMatch`、`StringLength`、`DistinctCount`、`RequiredIf`、`RowCount` 规则
- Warning 与 Error 分离统计；仅 Warning 不会让质量闸门失败
- CSV 引号/逗号/转义双引号处理，JSONL primitive/null/嵌套值归一化
- 文本和 JSON 报告、profile 指标、规则级 contract diff、contract 配置检查
- 字段引用诊断、数据质量评分和确定性 benchmark suite
- 可复用的行标准化、列投影、CSV/JSONL round-trip API

## 快速开始

```bash
# MoonBit 0.10.3
moon fmt && git diff --exit-code
moon check --deny-warn --target all
moon build --deny-warn --target all
moon test --deny-warn --target wasm-gc

本地验收基线为 MoonBit 0.10.3；CI 使用官方安装器当前可获取的稳定工具链，并在安装后打印实际版本。项目源码已按 0.10.3 语法和 `--deny-warn` 规则验证。

# 成功路径：退出码 0
moon run cmd/main validate examples/retail-orders/contract.json examples/retail-orders/orders-valid.csv

# 失败路径：退出码 1；报告仍会打印具体行号和规则
moon run cmd/main validate examples/retail-orders/contract.json examples/retail-orders/orders-invalid.csv
```

基准数据：examples/retail-orders/orders-benchmark.csv；执行 scripts/verify_benchmark.py 可验证 24 行有效/错误业务样本和 CLI 退出码。

## CLI

```text
validate <contract.json> <data.csv|data.jsonl> [--json]
profile <data.csv|data.jsonl> [--json]
diff-contract <before.json> <after.json> [--json]
check-contract <contract.json> [--json]
```

`validate` 默认执行字段 schema 与显式规则；Warning 以 `[warn]` 展示，存在 Error 时返回 1。`check-contract` 用于在 CI 或发布前发现重复字段、非法范围和不完整规则配置。

## MoonBit API

根包 `Wchwch777/moonverity` re-export 了 core、adapters 和 cli 的稳定入口，包括：

- `validate_rows`：保持兼容的显式规则校验
- `validate_rows_with_schema`：字段 schema + 显式规则校验
- `inspect_contract`、`normalize_contract`、`contract_stats`
- `profile_rows`、`diff_contracts`、`summarize_report`
- `parse_csv_text`、`parse_jsonl_text`、`normalize_rows`、`project_rows`

## 仓库与参赛材料

- GitHub: <https://github.com/Wchwch777/MoonVerity>
- GitLink: <https://gitlink.org.cn/Wchwch/moonverity>
- 详细 API 和示例：[`README.mbt.md`](README.mbt.md)
- 架构：[`docs/architecture.md`](docs/architecture.md)
- 验收清单：[`docs/acceptance-checklist.md`](docs/acceptance-checklist.md)
- 一页申报书：[`docs/competition/MoonVerity-proposal.pdf`](docs/competition/MoonVerity-proposal.pdf)

## 工程与发布

- 当前实现规模按官方 4–10k 有效 MoonBit 行参考口径审计，基准数据明确标注为可复现合成业务样本

- Apache-2.0，见 [`LICENSE`](LICENSE) 与 [`NOTICE`](NOTICE)
- 三平台 GitHub Actions：Linux / macOS / Windows，完整历史、格式、check、build、test、info 和合规检查
- `moon.mod` 已声明 Mooncakes 元数据；发布前运行 `moon publish --dry-run`
- 本地验收：`powershell -File scripts/verify_acceptance.ps1 -SkipRepoSyncCheck`
