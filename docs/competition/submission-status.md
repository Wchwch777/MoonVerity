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
- 最终提交：`71dfed832f895209097c2df692405c0643cbf3ca`
- GitHub 与 GitLink 的 `master` 已同步到上述提交，默认分支均为 `master`
- Mooncakes：[`Wchwch777/moonverity@0.1.1`](https://mooncakes.io/docs/Wchwch777/moonverity)

## 发布记录

- `moon publish --dry-run --verbose`：服务端 `202 Accepted`，包内解包检查通过
- `moon publish --verbose`：服务端 `200 OK`，`0.1.1` 发布完成
