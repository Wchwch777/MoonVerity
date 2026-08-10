# MoonVerity 提交状态

更新时间：2026-08-10

## 已完成

- GitHub：<https://github.com/Wchwch777/MoonVerity>
- GitLink：<https://gitlink.org.cn/Wchwch/moonverity>
- 公开 README、Apache-2.0 LICENSE、NOTICE、来源说明和一页 PDF 申报书
- MoonBit 0.10.x 新格式、schema 校验、质量规则、profile、contract diff 和 CLI 入口
- 失败/Warning/负数比较语义修复及 44+ 个自动化测试
- 三平台 CI、完整历史 checkout、显式 build、Moon info 漂移检查
- 本地 CLI 负路径和仓库合规脚本

## 发布前最后一步

1. 在有授权凭据的环境执行 `moon publish --dry-run`。
2. 确认 dry-run、完整本地验证和远程同步均为 0 退出码后执行 `moon publish`。
3. 将最终 GitHub/GitLink commit hash、Mooncakes 版本和发布链接补录到本文件。

本文件不预先声称 Mooncakes 发布成功；发布状态以实际命令输出和公开包页面为准。
