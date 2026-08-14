# MoonVerity 演示运行手册

## 环境准备

建议使用 MoonBit 0.10.3（组委会验收基线）：

```bash
moon version --all
moon update
moon fmt && git diff --exit-code
moon check --deny-warn --target all
moon build --deny-warn --target all
moon test --deny-warn --target wasm-gc
```

CI 还会在 Linux/macOS/Windows 安装对应的 C/OpenSSL 依赖并运行 native 测试。

## 1. 成功校验

```bash
moon run cmd/main validate examples/retail-orders/contract.json examples/retail-orders/orders-valid.csv
```

预期关键输出：

```text
dataset: retail_orders
rows: 3
passed: true
failures: 0
warnings: 0
```

该命令退出码为 `0`。

## 2. 失败校验

```bash
moon run cmd/main validate examples/retail-orders/contract.json examples/retail-orders/orders-invalid.csv
```

预期关键输出包含 `passed: false`、`[fail]`、失败行号和规则消息；该命令退出码为 `1`。这条负路径用于证明校验失败不会错误返回 0。

`Warning` 只增加 `warnings` 计数并显示为 `[warn]`，不会改变 `passed: true`；只有 Error 失败才会使进程退出 1。

## 3. JSON 报告与画像

```bash
moon run cmd/main validate examples/retail-orders/contract.json examples/retail-orders/orders-valid.csv --json
moon run cmd/main profile examples/retail-orders/orders-valid.csv --json
```

JSON profile 包含 `row_count`、每列非空/空值、distinct 值以及最小/最大/总文本长度。

基准验证命令：python scripts/verify_benchmark.py。它验证 24 条可复现合成零售订单、有效/错误两条路径、profile 行数/列宽和 contract check。

## 4. 契约 diff 与配置检查

```bash
moon run cmd/main diff-contract examples/retail-orders/contract.json examples/retail-orders/contract_v1_1.json
moon run cmd/main diff-contract examples/retail-orders/contract.json examples/retail-orders/contract_v1_1.json --json
moon run cmd/main check-contract examples/retail-orders/contract.json
```

diff 同时列出字段与规则的新增、删除、变更；`check-contract` 检查重复字段、非法范围、空规则参数和不完整配置。

## 5. 本地验收脚本

```powershell
python scripts/verify_cli_exit.py
powershell -File scripts/verify_acceptance.ps1 -SkipRepoSyncCheck
python scripts/check_repo_compliance.py --skip-remote-sync
```

外部远程同步检查需要当前仓库同时配置 `origin`（GitLink）和 `github`（GitHub），且两端默认分支均为 `master`。
