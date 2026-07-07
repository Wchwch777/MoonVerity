# 验收清单

- [x] MoonBit 为主要实现语言
- [x] 公开仓库结构清晰
- [x] README 完整可审查
- [x] 示例数据与契约已提供
- [x] 核心测试覆盖契约解析、校验、适配器、CLI
- [x] 命令行入口已提供
- [ ] `moon publish --dry-run`
- [ ] GitHub / GitLink 双远端同步
- [ ] Mooncakes 发布
- [x] 一页 PDF 项目申报书导出

## 本地验证命令

```bash
moon check --warn-list +73
moon test
moon run cmd/main validate examples/retail-orders/contract.json examples/retail-orders/orders.csv
moon run cmd/main profile examples/retail-orders/orders.csv
moon run cmd/main diff-contract examples/retail-orders/contract.json examples/retail-orders/contract_v1_1.json
```
