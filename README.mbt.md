# MoonVerity

MoonVerity 是一个基于 MoonBit 的数据契约与数据质量闸门工具包，面向 CSV / JSONL 这类记录型数据，提供契约解析、规则校验、数据画像和命令行检查能力。

MoonVerity is a MoonBit-native data contract and data quality gate toolkit for CSV and JSONL datasets.

## 项目定位

- 面向 MoonBit 生态的可复用工程基础设施
- 采用“核心库 + CLI + 示例数据 + 文档 + CI”的完整交付形态
- 适合作为 MoonBit OSC2026 参赛项目的公开仓库样例

## 当前能力

- 契约 JSON 解析
- 规则校验：唯一性、完整性、枚举、整数范围、跨字段比较、行数约束
- 数据画像：非空统计、空值统计、去重值计数
- 输入适配：CSV / JSONL
- CLI：`validate`、`profile`、`diff-contract`

## 仓库链接

- GitHub: <https://github.com/Wchwch777/MoonVerity>
- GitLink: <https://gitlink.org.cn/Wchwch/moonverity>

## 快速开始

```bash
moon check --warn-list +73
moon test
moon run cmd/main validate examples/retail-orders/contract.json examples/retail-orders/orders.csv
moon run cmd/main profile examples/retail-orders/orders.csv
moon run cmd/main diff-contract examples/retail-orders/contract.json examples/retail-orders/contract_v1_1.json
```

## 示例

```mbt nocheck
import "Wchwch777/moonverity"

let contract = @moonverity.parse_contract_json(contract_text)
let rows = @moonverity.parse_csv_text(csv_text)
let report = @moonverity.validate_rows(contract, rows)
```

## 仓库结构

- `core/`：契约模型、规则执行器、画像和契约 diff
- `adapters/`：CSV / JSONL 输入适配
- `cli/`：可测试命令层
- `cmd/main/`：命令行入口
- `examples/retail-orders/`：电商订单示例契约和数据
- `docs/`：架构说明、合规说明、验收清单、比赛材料
- `assets/logo/`：项目标识
- `scripts/`：PDF 生成、仓库自查与验收脚本

## 合规状态

- MoonBit 为主要实现语言
- 仓库公开可访问
- 提供 README、测试、CI、示例数据和一页 PDF 申报书
- Mooncakes 发布暂未执行；当前仓库仅保留发布准备，不自动发布

## 相关文档

- [架构说明](docs/architecture.md)
- [验收清单](docs/acceptance-checklist.md)
- [官方要求对照](docs/competition/official-requirements.md)
- [来源说明](docs/source-attribution.md)
