# MoonVerity 提交状态

更新时间：2026-08-10

## 已完成

- GitHub：<https://github.com/Wchwch777/MoonVerity>
- GitLink：<https://gitlink.org.cn/Wchwch/moonverity>
- 公开 README、Apache-2.0 LICENSE、NOTICE、来源说明和一页 PDF 申报书
- MoonBit 0.10.x 新格式、schema 校验、质量规则、profile、contract diff 和 CLI 入口
- 失败/Warning/负数比较语义修复及 57 个自动化测试
- 4030 行有效 MoonBit 源码、24 行可复现零售订单 benchmark 和错误变体
- 字段引用诊断、质量评分、行形状检查和确定性 benchmark suite
- 三平台 CI、完整历史 checkout、显式 build、Moon info 漂移检查
- 本地 CLI 负路径和仓库合规脚本
- GitHub 与 GitLink 的 master 与本地 HEAD 保持同步，默认分支均为 master
- 全部公开提交统一为创建者 Wchwch <1341376491@qq.com>，无第二贡献者
- Mooncakes：[`Wchwch777/moonverity@0.1.1`](https://mooncakes.io/docs/Wchwch777/moonverity)

## 发布记录

- `moon publish --dry-run --verbose`：服务端 `202 Accepted`，包内解包检查通过
- `moon publish --verbose`：服务端 `200 OK`，`0.1.1` 发布完成
