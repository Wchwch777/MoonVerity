# OSC2026 验收自查清单

## 代码与工具链

- [x] MoonBit 为主要实现语言，源码按 `core` / `adapters` / `cli` / `cmd` 分包
- [x] 使用 `moon.mod`、`moon.pkg` 新格式，入口包使用 `pkgtype(kind: "executable")`
- [x] 空 Map 已统一为 `Map([])`，可通过 MoonBit 0.10.x 的 warning 82 检查
- [x] `validate_rows` 保持显式规则兼容；`validate_rows_with_schema` 执行字段契约
- [x] Error 与 Warning 分离统计，负数/零值跨字段比较不会漏报
- [x] 校验失败 CLI 返回 1，成功或仅 Warning 返回 0
- [x] CSV 引号、逗号、转义双引号、CRLF、缺失单元格有边界测试
- [x] JSONL null、布尔、负数、嵌套对象有边界测试
- [x] 当前有效 MoonBit 源码规模达到官方 4,000–10,000 行参考区间，测试覆盖核心、适配器、CLI、入口和基准 fixture
- [x] 24 行可复现零售订单 benchmark 覆盖日期、渠道、状态、金额、折扣、引号字段和错误变体
- [x] 字段引用、质量评分、行形状和 benchmark suite 均有边界测试

## 仓库与发布

- [x] GitHub 和 GitLink 为公开仓库
- [x] 两个远程均使用 `master` 默认分支
- [x] README、README.mbt.md、LICENSE、NOTICE、来源说明、申报 PDF 齐全
- [x] 提交历史保留公开开发过程，且只保留真实贡献者
- [x] `.gitignore` 排除 `_build`、`.mooncakes` 和本地工作树
- [x] `moon.mod` 声明 readme、repository、license、version、description
- [x] GitHub/GitLink 已接收本轮最终提交（两端 master 与本地 HEAD 同步）
- [x] 全部公开提交统一为创建者身份，无第二个项目贡献者
- [x] Mooncakes 已通过 dry-run 并发布 `Wchwch777/moonverity@0.1.1`

## CI

- [x] GitHub Actions 使用 `fetch-depth: 0` 拉取完整历史
- [x] Linux/macOS/Windows 均有 MoonBit 安装步骤
- [x] Linux/macOS/Windows 均有 native 构建所需 C/OpenSSL 依赖步骤
- [x] CI 按官方模板运行 `moon fmt` 并用 `git diff --exit-code` 检查格式漂移
- [x] CI 显式运行 `moon check --deny-warn --target all`
- [x] CI 显式运行 `moon build --deny-warn --target all`
- [x] CI 运行 `moon info` 并以 `git diff --exit-code` 检查生成接口无漂移
- [x] CI 运行 wasm-gc/native 测试与覆盖率摘要
- [x] CI 执行仓库合规脚本

## 重现命令

```bash
moon fmt --check
moon check --deny-warn --target all
moon build --deny-warn --target all
moon test --deny-warn --target wasm-gc
moon info
git diff --exit-code
```

```powershell
powershell -File scripts/verify_cli_exit.py
python scripts/verify_benchmark.py
powershell -File scripts/verify_acceptance.ps1 -SkipRepoSyncCheck
```
