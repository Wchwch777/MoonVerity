# MoonVerity 项目申报书

## 项目名称

MoonVerity：基于 MoonBit 的数据契约与数据质量闸门工具包

## 项目定位

面向 CSV / JSONL 等常见记录型数据，构建一个 MoonBit 原生的数据契约与数据质量校验工具，支持契约解析、规则检查、数据画像、差异分析和 CLI 使用方式，帮助开发者在数据进入业务流程前发现重复值、缺失值、非法枚举、数值异常和跨字段不一致问题。

## 目标用户

- 使用 MoonBit 进行工程化开发的开发者
- 需要对本地数据文件做一致性和质量检查的个人或团队
- 希望在 MoonBit 生态中复用数据校验基础设施的项目作者

## 核心内容

- 提供统一契约模型和 JSON 契约格式
- 提供 CSV / JSONL 适配器
- 提供唯一性、完整性、枚举、整数范围、跨字段比较、行数约束等规则
- 提供 CLI 入口与可解释文本 / JSON 报告
- 提供示例数据、测试、文档和 CI

## 仓库链接

- GitHub: https://github.com/Wchwch777/MoonVerity
- GitLink: https://gitlink.org.cn/Wchwch/moonverity

## 技术特点

- MoonBit 原生实现，结构清晰，适合生态复用
- 强调“规则显式、结果可解释、接口可扩展”
- 采用“核心库 + CLI + 示例仓库”交付方式，便于比赛评审和后续维护

## 预期成果

- 公开可访问的 GitHub / GitLink 仓库
- 可运行的 MoonBit 包与命令行工具
- 完整 README、测试、示例和 CI
- 具备后续扩展与发布准备基础
