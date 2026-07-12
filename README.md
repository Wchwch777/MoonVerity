# MoonVerity

MoonVerity 是一个基于 MoonBit 的数据契约与数据质量闸门工具包，聚焦 CSV / JSONL 记录型数据的契约定义、规则校验、数据画像与 CLI 质检流程。

## 核心能力

- JSON 契约解析
- CSV / JSONL 输入适配
- 唯一性、完整性、枚举、范围、跨字段比较等规则校验
- 文本 / JSON 报告输出
- `validate`、`profile`、`diff-contract` 三个命令

## 快速开始

```bash
moon check --warn-list +73
moon test
moon run cmd/main validate examples/retail-orders/contract.json examples/retail-orders/orders.csv
```

## 仓库与文档

- GitHub: <https://github.com/Wchwch777/MoonVerity>
- GitLink: <https://gitlink.org.cn/Wchwch/moonverity>
- 详细说明：[`README.mbt.md`](README.mbt.md)
- 一页申报书：[`docs/competition/MoonVerity-proposal.pdf`](docs/competition/MoonVerity-proposal.pdf)

## 参赛交付对齐

- 公开 README、源码、测试、CI、许可证、提交记录
- MoonBit 为主要实现语言
- 提供示例数据、示例命令和比赛申报材料
- 已发布至 mooncakes.io
