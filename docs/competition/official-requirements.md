# OSC2026 官方要求与本仓库对照

本文件用于验收复核，不替代赛事公告。赛事时间、表单和材料要求具有时效性，最终以官方页面和组委会通知为准。

## 核对来源

- 官方赛事仓库：<https://github.com/moonbitlang/OSC2026>
- 官方网站源码：<https://github.com/moonbitlang/OSC2026/blob/main/main/main.mbt>
- 赛事页面：<https://moonbitlang.github.io/OSC2026/>
- GitLink 赛道页面：<https://www.gitlink.org.cn/competitions/track1_2026MoonBit>
- MoonBit 社区 workflow 模板：<https://github.com/moonbit-community/.github/tree/main/workflow-templates>

## 当前可确认的质量要求

官方页面强调以下可验收特征：

- 项目边界清楚、真实可用、文档完整、测试可运行、长期可维护
- 项目应围绕公开仓库持续开发，提交记录、工单、合并请求和更新日志可追踪
- MoonBit 应为主要实现语言；项目需使用 OSI 认可的开源许可证
- 不应包含未经授权的私有、闭源、商业或来源不明的生成内容
- 官方首页源码给出的有效 MoonBit 代码参考区间为 4–10k 行，质量、边界和可维护性优先
- 基础支持在页面中展示为 150 元启动支持 + 350 元完成支持；奖励另行评选

## 本轮组委会反馈映射

| 反馈 | 本仓库修复 |
| --- | --- |
| 三平台 CI 拉取完整历史并显式构建 | `ci.yml` 使用 `fetch-depth: 0`，安装平台依赖，运行 `moon build --deny-warn --target all` |
| 补齐 MoonBit 工具链安装 | Linux/macOS 使用 unix 安装脚本，Windows 使用 PowerShell 脚本，并在 Windows 配置 MSYS2 UCRT64 |
| 演示预期与真实输出一致 | `orders-valid.csv` 明确成功路径，`orders-invalid.csv` 明确失败路径，runbook 标注退出码 |
| 校验失败仍返回 0 | `cmd/main` 根据 `ValidationOutcome.passed` 调用 `@sys.exit(1)` |
| Warning 被计为失败 | `failure_count` 只累计 Error，Warning 只累计 `warning_count` 并输出 `[warn]` |
| 负数跨字段比较漏报 | 移除不合理的 `left > 0` / `right >= 0` 前置条件，增加负数、零值和所有操作符测试 |
| 增加入口及边界测试 | CLI contract check、CLI exit smoke、CSV/JSONL、schema、规则、profile、diff 边界测试 |

## 时间信息

官方源码会随赛事进程更新；历史快照曾展示申报、验收、评选和线下展示阶段，组委会本轮通知要求项目持续更新至 8 月 17 日。提交前应再次核对官方页面和邮件通知，不将本文件中的时间视为永久规则。
