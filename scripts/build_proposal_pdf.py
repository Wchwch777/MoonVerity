from pathlib import Path
import hashlib

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfdoc
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfbase.pdfmetrics import registerFont
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs" / "competition" / "MoonVerity-proposal.pdf"
FONT_PATH = Path(r"C:\Windows\Fonts\simhei.ttf")


def _compat_md5(*args, **kwargs):
    kwargs.pop("usedforsecurity", None)
    return hashlib.md5(*args, **kwargs)


pdfdoc.md5 = _compat_md5


def register_fonts():
    registerFont(TTFont("SimHei", str(FONT_PATH)))


def build():
    register_fonts()
    doc = SimpleDocTemplate(
        str(OUT),
        pagesize=A4,
        leftMargin=16 * mm,
        rightMargin=16 * mm,
        topMargin=14 * mm,
        bottomMargin=14 * mm,
    )
    styles = getSampleStyleSheet()
    title = ParagraphStyle(
        "title",
        parent=styles["Title"],
        fontName="SimHei",
        fontSize=18,
        leading=22,
        textColor=colors.HexColor("#0f2f5f"),
        spaceAfter=10,
    )
    heading = ParagraphStyle(
        "heading",
        parent=styles["Heading2"],
        fontName="SimHei",
        fontSize=11.5,
        leading=14,
        textColor=colors.HexColor("#0c8b8f"),
        spaceBefore=4,
        spaceAfter=4,
    )
    body = ParagraphStyle(
        "body",
        parent=styles["BodyText"],
        fontName="SimHei",
        fontSize=9.3,
        leading=12,
        textColor=colors.HexColor("#1f2937"),
        spaceAfter=3,
    )

    flow = [
        Paragraph("MoonVerity 项目申报书", title),
        Paragraph("项目定位：基于 MoonBit 的数据契约与数据质量闸门工具包", body),
        Paragraph("一、项目目标", heading),
        Paragraph(
            "面向 CSV、JSONL 等常见记录型数据，构建 MoonBit 原生的数据契约与质量校验工具，"
            "支持契约解析、规则检查、数据画像、差异分析和 CLI 使用方式，帮助开发者在数据进入业务流程前发现重复值、缺失值、非法枚举、数值异常和跨字段不一致问题。",
            body,
        ),
        Paragraph("二、目标用户", heading),
        Paragraph(
            "1. 使用 MoonBit 进行工程化开发的开发者。<br/>"
            "2. 需要对本地数据文件做一致性和质量检查的个人或团队。<br/>"
            "3. 希望在 MoonBit 生态中复用数据校验基础设施的项目作者。",
            body,
        ),
        Paragraph("三、核心能力", heading),
    ]

    table = Table(
        [
            ["能力模块", "内容"],
            ["契约模型", "统一 JSON 契约格式，描述字段、规则、版本与约束边界"],
            ["规则引擎", "唯一性、完整性、枚举、整数范围、跨字段比较、行数约束"],
            ["输入适配", "CSV / JSONL 统一转换为行记录抽象"],
            ["输出能力", "文本报告、JSON 报告、数据画像、契约 diff"],
            ["工程交付", "README、测试、示例数据、CLI、CI、Mooncakes 发布准备"],
        ],
        colWidths=[32 * mm, 138 * mm],
    )
    table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#d9f2f3")),
                ("TEXTCOLOR", (0, 0), (-1, 0), colors.HexColor("#0f2f5f")),
                ("FONTNAME", (0, 0), (-1, -1), "SimHei"),
                ("FONTSIZE", (0, 0), (-1, -1), 8.8),
                ("LEADING", (0, 0), (-1, -1), 11),
                ("GRID", (0, 0), (-1, -1), 0.35, colors.HexColor("#9ac8cb")),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, colors.HexColor("#f7fbfb")]),
                ("LEFTPADDING", (0, 0), (-1, -1), 5),
                ("RIGHTPADDING", (0, 0), (-1, -1), 5),
                ("TOPPADDING", (0, 0), (-1, -1), 4),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
            ]
        )
    )

    flow.extend(
        [
            table,
            Spacer(1, 5),
            Paragraph("四、技术特点", heading),
            Paragraph(
                "MoonBit 原生实现，结构清晰，适合作为生态基础设施复用；采用“核心库 + CLI + 示例仓库”交付形态，"
                "强调规则显式、结果可解释、边界可扩展，既便于比赛评审，也便于后续维护和发布到 Mooncakes。",
                body,
            ),
            Paragraph("五、预期成果", heading),
            Paragraph(
                "形成公开 GitHub / GitLink 仓库、可运行 MoonBit 包与命令行工具、完整 README、测试、示例和 CI，"
                "并具备后续 Mooncakes 发布与进一步规则扩展的基础。",
                body,
            ),
        ]
    )
    doc.build(flow)


if __name__ == "__main__":
    build()
