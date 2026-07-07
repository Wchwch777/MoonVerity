# 演示运行手册

## 环境准备

```bash
moon check --warn-list +73
moon test
```

## 示例一：订单数据校验

```bash
moon run cmd/main validate examples/retail-orders/contract.json examples/retail-orders/orders.csv
```

预期：

- 输出 `PASS`。
- 报告中包含行数、规则数和失败条目统计。

## 示例二：数据画像

```bash
moon run cmd/main profile examples/retail-orders/orders.csv
```

预期：

- 输出每个字段的非空统计、空值统计与去重值数量。

## 示例三：契约差异

```bash
moon run cmd/main diff-contract examples/retail-orders/contract.json examples/retail-orders/contract_v1_1.json
```

预期：

- 输出新增、删除或变更的字段与规则摘要。

## 比赛材料对应关系

- 公开仓库：GitHub / GitLink
- 一页 PDF：`docs/competition/MoonVerity-proposal.pdf`
- 示例数据：`examples/retail-orders/`
- 自查脚本：`scripts/check_repo_compliance.py`
- 验收脚本：`scripts/verify_acceptance.ps1`
