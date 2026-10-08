from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR, MSO_AUTO_SIZE
from pptx.enum.shapes import MSO_SHAPE

OUT = r"D:\ultra-latest-c2c-02\Harsh_Bhardwaj_Internship_PPT_Commonwealth_Bank_Professional.pptx"

prs = Presentation()
prs.slide_width = Inches(13.33)
prs.slide_height = Inches(7.5)
# set default

# Colors
NAVY = RGBColor(0x0B, 0x1D, 0x3A)
GOLD = RGBColor(0xFF, 0xC3, 0x00)
GOLD_DARK = RGBColor(0xE6, 0xAA, 0x00)
SLATE = RGBColor(0x5D, 0x6D, 0x7E)
LIGHT_BG = RGBColor(0xF7, 0xF8, 0xFA)
CARD_BORDER = RGBColor(0xE5, 0xE7, 0xEB)
WHITE = RGBColor(0xFF, 0xFF, 0xFF)
BLUE = RGBColor(0x0F, 0x4C, 0xE3)
SUCCESS = RGBColor(0x10, 0x98, 0x57)

def add_bg(slide, color):
    bg = slide.background
    fill = bg.fill
    fill.solid()
    fill.fore_color.rgb = color

def set_text(frame, text, size=12, bold=False, color=NAVY, align=PP_ALIGN.LEFT, italic=False, name="Calibri"):
    # expects TextFrame
    p = frame.paragraphs[0]
    p.text = text
    p.font.size = Pt(size)
    p.font.bold = bold
    p.font.color.rgb = color
    p.font.italic = italic
    p.font.name = name
    p.alignment = align
    return p

def add_text_box(slide, left, top, width, height, text, size=12, bold=False, color=NAVY, align=PP_ALIGN.LEFT, italic=False, name="Calibri", line_spacing=1.1):
    txBox = slide.shapes.add_textbox(Inches(left), Inches(top), Inches(width), Inches(height))
    tf = txBox.text_frame
    tf.word_wrap = True
    tf.auto_size = None
    p = tf.paragraphs[0]
    p.text = text
    p.font.size = Pt(size)
    p.font.bold = bold
    p.font.color.rgb = color
    p.font.italic = italic
    p.font.name = name
    p.alignment = align
    p.line_spacing = Pt(size * line_spacing)
    return txBox

def add_shape_card(slide, left, top, width, height, fill_color=WHITE, border_color=CARD_BORDER, radius=Inches(0.12), shadow=False):
    shape = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(left), Inches(top), Inches(width), Inches(height))
    shape.fill.solid()
    shape.fill.fore_color.rgb = fill_color
    shape.line.color.rgb = border_color
    shape.line.width = Pt(1)
    shape.shadow.inherit_shadow = False
    if shadow:
        shape.shadow.visible = True
        shape.shadow.style = 1
    # adjust radius
    shape.adjustments[0] = 0.08
    return shape

def add_badge(slide, left, top, text, bg=GOLD, fg=NAVY, size=7):
    shape = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(left), Inches(top), Inches(len(text)*0.09+0.22), Inches(0.28))
    shape.fill.solid()
    shape.fill.fore_color.rgb = bg
    shape.line.fill.background()
    shape.adjustments[0]=0.5
    tf = shape.text_frame
    tf.word_wrap = True
    tf.vertical_anchor = MSO_ANCHOR.MIDDLE
    p = tf.paragraphs[0]
    p.text = text
    p.font.size = Pt(size)
    p.font.bold = True
    p.font.color.rgb = fg
    p.font.name = "Calibri"
    p.alignment = PP_ALIGN.CENTER
    return shape

def add_line(slide, left, top, width, color=GOLD, weight=Pt(3)):
    shape = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(left), Inches(top), Inches(width), Pt(3))
    shape.fill.solid()
    shape.fill.fore_color.rgb = color
    shape.line.fill.background()
    return shape

# ================= Slide 1: Title =================
slide = prs.slides.add_slide(prs.slide_layouts[6]) # blank
add_bg(slide, WHITE)
# top gold accent line
add_line(slide, 0, 0, 13.33, GOLD, Pt(4))
# left navy vertical bar decorative
shape = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(0.6), Inches(1.4), Inches(0.08), Inches(4.8))
shape.fill.solid()
shape.fill.fore_color.rgb = NAVY
shape.line.fill.background()

add_text_box(slide, 0.9, 0.35, 12, 0.4, "KIET GROUP OF INSTITUTIONS  •  DEPARTMENT OF INFORMATION TECHNOLOGY", size=7, color=SLATE, bold=True, align=PP_ALIGN.LEFT, name="Calibri")
add_text_box(slide, 0.9, 1.45, 7.5, 0.45, "Internship Completion", size=28, bold=True, color=NAVY, align=PP_ALIGN.LEFT, name="Calibri")
add_text_box(slide, 0.9, 1.95, 7.5, 0.7, "Harsh Bhardwaj  (IT - B)\n202401100600083", size=26, bold=True, color=NAVY, align=PP_ALIGN.LEFT, name="Calibri")
# line under name
add_line(slide, 0.9, 2.85, 5.8, GOLD, Pt(3))
add_text_box(slide, 0.9, 3.15, 7.2, 0.7, "Software Engineering Job Simulation  •  Commonwealth Bank  (via Forage)", size=11, color=SLATE, bold=False, align=PP_ALIGN.LEFT, name="Calibri")
add_text_box(slide, 0.9, 3.6, 7.2, 0.35, "June – July 2026  •  Virtual Simulation  •  4 Weeks", size=9, color=SLATE, bold=True, align=PP_ALIGN.LEFT, name="Calibri")

# Right card with key credential
card = add_shape_card(slide, 8.6, 1.4, 3.9, 4.6, fill_color=NAVY, border_color=NAVY, radius=Inches(0.18))
# Inside card
add_text_box(slide, 8.95, 1.7, 3.3, 0.3, "VERIFIED CREDENTIAL", size=7, color=GOLD, bold=True, align=PP_ALIGN.LEFT, name="Calibri")
add_text_box(slide, 8.95, 2.05, 3.3, 0.5, "Commonwealth Bank\nSoftware Engineering", size=14, bold=True, color=WHITE, align=PP_ALIGN.LEFT, name="Calibri")
add_text_box(slide, 8.95, 2.75, 3.3, 0.35, "Via Forage — Certified Simulation", size=8, color=RGBColor(0xC8,0xD0,0xDD), align=PP_ALIGN.LEFT, italic=True)
add_line(slide, 8.95, 3.25, 3.2, GOLD, Pt(1.5))
add_text_box(slide, 8.95, 3.45, 3.3, 0.8, "✓  Completed 5 core tasks\n✓  All tasks reviewed & merged\n✓  100% task completion", size=8.5, color=WHITE, align=PP_ALIGN.LEFT)
# Badge at bottom of card
add_badge(slide, 8.95, 4.55, "  ●  VERIFIED FORAGE SIMULATION  ", bg=WHITE, fg=NAVY, size=6.5)
add_badge(slide, 8.95, 4.92, "  COMMONWEALTH BANK  ", bg=GOLD, fg=NAVY, size=6.5)
# small codes
add_text_box(slide, 8.95, 5.45, 3.3, 0.35, "ID: 202401100600083  •  Session 2026–27", size=6, color=RGBColor(0x8A,0x95,0xA8), align=PP_ALIGN.LEFT)

# footer
add_text_box(slide, 0.9, 6.95, 12, 0.2, "Harsh Bhardwaj  •  KIET Ghaziabad  •  B.Tech IT  •  har承载bhardwaj@kiet.edu  •  LinkedIn Available", size=6.5, color=SLATE, align=PP_ALIGN.LEFT)
add_line(slide, 0, 7.35, 13.33, NAVY, Pt(6))

# ================= Slide 2: About Commonwealth Bank =================
slide = prs.slides.add_slide(prs.slide_layouts[6])
add_bg(slide, LIGHT_BG)
add_line(slide, 0, 0, 13.33, GOLD, Pt(4))
add_text_box(slide, 0.7, 0.4, 3, 0.3, "01  —  ABOUT ORGANIZATION", size=7, color=SLATE, bold=True)
add_text_box(slide, 0.7, 0.7, 7, 0.5, "About Commonwealth Bank", size=22, bold=True, color=NAVY)
add_text_box(slide, 0.7, 1.25, 12.3, 0.7, "Australia's leading digital bank — trusted by 17+ million customers. Focused on secure, scalable, and customer-first banking. Its engineering teams build reliable, compliant, and easy-to-use financial services.", size=9.5, color=RGBColor(0x33,0x44,0x5E), align=PP_ALIGN.LEFT)

# 3 cards simplified
cards = [
    ("◈  Security-First", "Strong data protection, encryption,\nand strict compliance with\nbanking regulations.", "Risk controls & privacy"),
    ("◎  Scale & Reliability", "Systems built to stay fast and\navailable even during peak loads\nfor millions of users.", "High-availability engineering"),
    ("◆  Engineering Culture", "Emphasis on automated testing,\nthorough code reviews, and\nsmall, steady improvements.", "CI/CD & quality"),
]
for i, (title, desc, cap) in enumerate(cards):
    x = 0.7 + i*4.2
    card = add_shape_card(slide, x, 2.25, 3.9, 3.0, fill_color=WHITE, border_color=CARD_BORDER)
    # icon circle
    circ = slide.shapes.add_shape(MSO_SHAPE.OVAL, Inches(x+0.3), Inches(2.5), Inches(0.45), Inches(0.45))
    circ.fill.solid()
    circ.fill.fore_color.rgb = NAVY
    circ.line.fill.background()
    tf = circ.text_frame
    tf.word_wrap=True
    tf.vertical_anchor=MSO_ANCHOR.MIDDLE
    p=tf.paragraphs[0]
    p.text = "●"
    p.font.size=Pt(14)
    p.font.color.rgb=GOLD
    p.font.name="Calibri"
    p.alignment=PP_ALIGN.CENTER
    add_text_box(slide, x+0.9, 2.5, 2.8, 0.3, title, size=11, bold=True, color=NAVY)
    add_text_box(slide, x+0.3, 3.05, 3.35, 0.9, desc, size=8.5, color=SLATE, align=PP_ALIGN.LEFT)
    # caption badge
    add_badge(slide, x+0.3, 4.35, cap.upper(), bg=RGBColor(0xEE,0xF1,0xF6), fg=SLATE, size=6)

# bottom strip
add_text_box(slide, 0.7, 5.9, 12.3, 0.35, "Why this matters for the internship:  We practiced the same values — building secure, reliable features in small, well-tested steps.", size=8, color=NAVY, bold=True, italic=True)
card_bg = add_shape_card(slide, 0.7, 6.25, 12.3, 0.55, fill_color=NAVY, border_color=NAVY)
add_text_box(slide, 0.9, 6.35, 12, 0.35, "Cloud-native platforms  •  Strong CI/CD  •  Customer-centric delivery", size=8, color=GOLD, align=PP_ALIGN.CENTER, bold=True)

# ================= Slide 3: Objective =================
slide = prs.slides.add_slide(prs.slide_layouts[6])
add_bg(slide, WHITE)
add_line(slide, 0, 0, 13.33, GOLD, Pt(4))
add_text_box(slide, 0.7, 0.4, 3, 0.3, "02  —  INTERNSHIP OBJECTIVE", size=7, color=SLATE, bold=True)
add_text_box(slide, 0.7, 0.7, 8, 0.5, "What was the goal?", size=22, bold=True, color=NAVY)
add_text_box(slide, 0.7, 1.35, 11.5, 0.75, "Experience a real software engineering workflow — from coding a feature to testing it, getting it reviewed, and delivering it through CI — just like engineers do at Commonwealth Bank.", size=10, color=RGBColor(0x33,0x44,0x5E))

# 3 pillars with numbers
pillars = [
    ("01", "Build Features", "Develop small backend and\nfrontend features end-to-end —\nfrom idea to working code."),
    ("02", "Test & Integrate", "Connect with existing services\nand write clear unit tests to\nmake sure nothing breaks."),
    ("03", "Collaborate", "Use Git, pull requests, and\nCI feedback — review, improve,\nand merge with confidence."),
]
for i, (num, title, desc) in enumerate(pillars):
    x = 0.7 + i*4.2
    card = add_shape_card(slide, x, 2.6, 3.9, 2.9, fill_color=WHITE, border_color=CARD_BORDER, shadow=False)
    # number badge
    shp = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(x+0.3), Inches(2.85), Inches(0.6), Inches(0.28))
    shp.fill.solid()
    shp.fill.fore_color.rgb = GOLD
    shp.line.fill.background()
    shp.adjustments[0]=0.5
    tf=shp.text_frame
    tf.vertical_anchor=MSO_ANCHOR.MIDDLE
    p=tf.paragraphs[0]
    p.text=num
    p.font.size=Pt(9)
    p.font.bold=True
    p.font.color.rgb=NAVY
    p.alignment=PP_ALIGN.CENTER
    p.font.name="Calibri"
    add_text_box(slide, x+0.3, 3.35, 3.35, 0.35, title, size=12, bold=True, color=NAVY)
    add_line(slide, x+0.3, 3.75, 3.35, GOLD, Pt(2))
    add_text_box(slide, x+0.3, 4.0, 3.35, 0.9, desc, size=8.5, color=SLATE)

# bottom simple flow
add_text_box(slide, 0.7, 6.05, 12.3, 0.3, "Simple flow we followed:   Code  →  Test  →  Pull Request  →  Review  →  CI Checks  →  Merge", size=8, color=NAVY, bold=True, align=PP_ALIGN.CENTER)
box = add_shape_card(slide, 0.7, 6.4, 12.3, 0.45, fill_color=RGBColor(0xF0,0xF4,0xFF), border_color=RGBColor(0xD0,0xDA,0xF5))
add_text_box(slide, 0.9, 6.52, 12, 0.25, "Focus: Clean code, small steps, and reliable delivery — not just making it work, but making it work well.", size=7.5, color=SLATE, italic=True, align=PP_ALIGN.CENTER)

# ================= Slide 4: Tech Stack =================
slide = prs.slides.add_slide(prs.slide_layouts[6])
add_bg(slide, LIGHT_BG)
add_line(slide, 0, 0, 13.33, GOLD, Pt(4))
add_text_box(slide, 0.7, 0.4, 3, 0.3, "03  —  TECHNOLOGY STACK", size=7, color=SLATE, bold=True)
add_text_box(slide, 0.7, 0.7, 8, 0.5, "Tools & Technologies", size=22, bold=True, color=NAVY)
add_text_box(slide, 0.7, 1.3, 8, 0.35, "Simple, industry-standard stack — same patterns used in bank microservices.", size=9, color=SLATE, italic=True)

stack = [
    (".NET (C#)", "Backend APIs & business logic", "Built APIs, added validation & clean services"),
    ("React + Redux", "Frontend & state management", "Built UI components, managed app state simply"),
    ("MongoDB", "Flexible data storage", "Stored data as documents, easy to change"),
    ("Git & GitHub", "Team workflow", "Branches, pull requests & code reviews"),
    ("Testing Tools", "xUnit, Jest, React Testing Library", "Wrote tests to catch issues early"),
]

for idx, (tech, sub, note) in enumerate(stack):
    y = 1.95 + idx*0.92
    card = add_shape_card(slide, 0.7, y, 7.5, 0.82, fill_color=WHITE, border_color=CARD_BORDER)
    # left gold bar
    bar = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(0.7), Inches(y), Inches(0.05), Inches(0.82))
    bar.fill.solid()
    bar.fill.fore_color.rgb = GOLD
    bar.line.fill.background()
    add_text_box(slide, 0.9, y+0.1, 2.8, 0.25, tech, size=9.5, bold=True, color=NAVY)
    add_text_box(slide, 0.9, y+0.38, 2.8, 0.2, sub, size=7, color=SLATE)
    add_text_box(slide, 3.9, y+0.22, 4, 0.35, note, size=8, color=RGBColor(0x33,0x44,0x5E))

# Right highlight box
card = add_shape_card(slide, 8.7, 1.95, 4.0, 2.8, fill_color=NAVY, border_color=NAVY)
add_text_box(slide, 9.0, 2.25, 3.5, 0.35, "Why this stack?", size=9, bold=True, color=GOLD)
add_text_box(slide, 9.0, 2.65, 3.5, 1.4, "This mix is common in modern banking.\nIt helps build services that are fast,\nsecure, and easy to maintain — exactly\nwhat large banks need.", size=8.5, color=WHITE)
add_line(slide, 9.0, 4.25, 3.4, GOLD, Pt(1.5))
add_text_box(slide, 9.0, 4.4, 3.5, 0.25, "Industry-aligned  •  Practical  •  Job-ready", size=7, color=GOLD, bold=True)

# Tags bottom
tags = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(8.7), Inches(5.15), Inches(4.0), Inches(0.55))
tags.fill.solid()
tags.fill.fore_color.rgb = WHITE
tags.line.color.rgb = CARD_BORDER
tags.adjustments[0]=0.15
add_text_box(slide, 8.75, 5.22, 3.9, 0.4, "  C#   •   React   •   Redux   •   MongoDB   •   Git   •   CI/CD", size=7, color=SLATE, bold=True, align=PP_ALIGN.CENTER)

# ================= Slide 5: Key Learnings =================
slide = prs.slides.add_slide(prs.slide_layouts[6])
add_bg(slide, WHITE)
add_line(slide, 0, 0, 13.33, GOLD, Pt(4))
add_text_box(slide, 0.7, 0.4, 3, 0.3, "04  —  KEY LEARNINGS", size=7, color=SLATE, bold=True)
add_text_box(slide, 0.7, 0.7, 8, 0.5, "What I Learned", size=22, bold=True, color=NAVY)
add_text_box(slide, 0.7, 1.3, 10, 0.35, "Hands-on skills gained — explained in simple terms.", size=9, color=SLATE, italic=True)

learn = [
    ("Backend", "Built API endpoints, added\nproper input checks, and\nmade code easy to test\nwith clean services.", "C# / .NET"),
    ("Frontend", "Created React pages,\nmanaged data with Redux,\nand tested how the UI\nbehaves.", "React / Redux"),
    ("Testing & CI", "Wrote unit tests and\nran them via CI so\nmistakes are caught early.", "Quality checks"),
    ("Teamwork", "Wrote clear PRs, fixed\nreview comments quickly,\nand kept work moving.", "Git / Reviews"),
]

for i, (title, desc, tag) in enumerate(learn):
    x = 0.7 + i*3.15
    card = add_shape_card(slide, x, 1.9, 2.95, 3.85, fill_color=WHITE, border_color=CARD_BORDER)
    # icon box
    icon = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(x+0.25), Inches(2.15), Inches(0.45), Inches(0.45))
    icon.fill.solid()
    icon.fill.fore_color.rgb = RGBColor(0xEE,0xF1,0xF6)
    icon.line.color.rgb = RGBColor(0xD0,0xDA,0xF5)
    icon.adjustments[0]=0.2
    tf=icon.text_frame
    tf.vertical_anchor=MSO_ANCHOR.MIDDLE
    p=tf.paragraphs[0]
    p.text = "◆"
    p.font.size=Pt(14)
    p.font.color.rgb=NAVY
    p.alignment=PP_ALIGN.CENTER
    p.font.name="Calibri"
    add_text_box(slide, x+0.85, 2.18, 1.85, 0.3, title, size=11, bold=True, color=NAVY)
    add_text_box(slide, x+0.25, 2.75, 2.45, 1.35, desc, size=8.5, color=SLATE)
    # tag
    add_badge(slide, x+0.25, 4.55, tag, bg=RGBColor(0xF7,0xF8,0xFA), fg=SLATE, size=6)
    # bottom gold line
    add_line(slide, x, 5.75, 2.95, GOLD, Pt(2.5))

add_text_box(slide, 0.7, 6.4, 12.3, 0.3, "Key takeaway:  Writing testable code and keeping changes small makes teamwork and reviews much easier.", size=8, color=NAVY, bold=True, italic=True, align=PP_ALIGN.CENTER)

# ================= Slide 6: Challenges =================
slide = prs.slides.add_slide(prs.slide_layouts[6])
add_bg(slide, LIGHT_BG)
add_line(slide, 0, 0, 13.33, GOLD, Pt(4))
add_text_box(slide, 0.7, 0.4, 3, 0.3, "05  —  CHALLENGES FACED", size=7, color=SLATE, bold=True)
add_text_box(slide, 0.7, 0.7, 8, 0.5, "Challenges & How I Solved Them", size=22, bold=True, color=NAVY)
add_text_box(slide, 0.7, 1.3, 10, 0.35, "Real problems — solved with simple, practical steps.", size=9, color=SLATE, italic=True)

challs = [
    ("Old code, less docs", "Hard to understand how old\nparts were connected.", "Read code step-by-step, added\ndocuments & typed interfaces."),
    ("State was complex", "Redux data made UI re-render\nmore than needed.", "Cleaned state, used better\nselectors to render less."),
    ("Logging without breaking", "Add logs & error handling\nwithout affecting features.", "Added small middleware &\ntested existing flows again."),
    ("Mocking for tests", "Need fake data layers for\nreliable tests.", "Created simple mocks & fake\nservices for clean tests."),
]

for i, (title, prob, sol) in enumerate(challs):
    x = 0.7 + i*3.15
    card = add_shape_card(slide, x, 1.95, 2.95, 3.8, fill_color=WHITE, border_color=CARD_BORDER)
    add_text_box(slide, x+0.25, 2.15, 2.45, 0.3, title, size=9.5, bold=True, color=NAVY, align=PP_ALIGN.LEFT)
    add_line(slide, x+0.25, 2.5, 2.45, GOLD, Pt(2))
    add_text_box(slide, x+0.25, 2.7, 2.45, 0.55, prob, size=8, color=SLATE)
    # arrow
    add_text_box(slide, x+0.25, 3.3, 2.45, 0.15, "↓  Solution:", size=7, bold=True, color=SUCCESS)
    add_text_box(slide, x+0.25, 3.5, 2.45, 0.9, sol, size=7.5, color=RGBColor(0x33,0x44,0x5E))

# bottom highlight
box = add_shape_card(slide, 0.7, 6.2, 12.3, 0.65, fill_color=RGBColor(0xE6,0xF0,0xFF), border_color=RGBColor(0xB8,0xD0,0xFF))
add_text_box(slide, 0.9, 6.35, 0.4, 0.35, "ⓘ", size=12, color=BLUE, bold=True, align=PP_ALIGN.CENTER)
add_text_box(slide, 1.35, 6.32, 11.2, 0.45, "Simple rule I followed: Make small changes, write a test, and verify — reduces risk and keeps code safe.", size=8.5, color=NAVY, italic=True)

# ================= Slide 7: Results =================
slide = prs.slides.add_slide(prs.slide_layouts[6])
add_bg(slide, WHITE)
add_line(slide, 0, 0, 13.33, GOLD, Pt(4))
add_text_box(slide, 0.7, 0.4, 3, 0.3, "06  —  RESULTS & CONCLUSIONS", size=7, color=SLATE, bold=True)
add_text_box(slide, 0.7, 0.7, 9, 0.5, "Results & Conclusion", size=22, bold=True, color=NAVY)
add_text_box(slide, 0.7, 1.3, 11, 0.5, "All tasks completed (100%) — backend APIs, React components, tests, and PRs delivered. The simulation improved my readiness for real engineering roles in banking.", size=9, color=RGBColor(0x33,0x44,0x5E))

cols = [
    ("Outcomes", "All features matched\nrequirements, CI passed,\nand code was reviewed\nand merged to main.", "100% delivery"),
    ("Skills Gained", "Test-driven thinking,\nGit teamwork, state\nmanagement, and\npractical debugging.", "Job-ready skills"),
    ("Next Steps", "Use these learnings on\nbigger projects, join\narchitecture talks, and\nseek mentorship.", "Growth ahead"),
]

for i, (title, desc, tag) in enumerate(cols):
    x = 0.7 + i*4.2
    card = add_shape_card(slide, x, 2.1, 3.9, 3.3, fill_color=WHITE, border_color=CARD_BORDER)
    # top navy header
    hdr = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(x), Inches(2.1), Inches(3.9), Inches(0.5))
    hdr.fill.solid()
    hdr.fill.fore_color.rgb = NAVY
    hdr.line.fill.background()
    hdr.adjustments[0]=0.08
    tf=hdr.text_frame
    tf.vertical_anchor=MSO_ANCHOR.MIDDLE
    p=tf.paragraphs[0]
    p.text = title
    p.font.size=Pt(10)
    p.font.bold=True
    p.font.color.rgb=WHITE
    p.font.name="Calibri"
    p.alignment=PP_ALIGN.CENTER
    add_text_box(slide, x+0.3, 2.85, 3.3, 1.1, desc, size=8.5, color=SLATE)
    add_badge(slide, x+0.3, 4.4, tag, bg=RGBColor(0xEE,0xF1,0xF6), fg=NAVY, size=6.5)
    add_line(slide, x, 5.4, 3.9, GOLD, Pt(2.5))

add_text_box(slide, 0.7, 6.0, 12.3, 0.4, "Bottom line:  I can now build, test, and ship small features the way professional teams do — safely and in collaboration.", size=8.5, color=NAVY, bold=True, italic=True, align=PP_ALIGN.CENTER)
# small stats row
stats = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.7), Inches(6.45), Inches(12.3), Inches(0.5))
stats.fill.solid()
stats.fill.fore_color.rgb = LIGHT_BG
stats.line.color.rgb = CARD_BORDER
stats.adjustments[0]=0.05
add_text_box(slide, 0.9, 6.55, 12, 0.3, "✓  Feature parity     •     ✓  Passing CI     •     ✓  Peer-reviewed     •     ✓  Merged to main", size=7.5, color=SLATE, bold=True, align=PP_ALIGN.CENTER)

# ================= Slide 8: Certificate =================
slide = prs.slides.add_slide(prs.slide_layouts[6])
add_bg(slide, WHITE)
add_line(slide, 0, 0, 13.33, GOLD, Pt(4))
add_text_box(slide, 0.7, 0.4, 4, 0.3, "07  —  CERTIFICATE", size=7, color=SLATE, bold=True)
add_text_box(slide, 0.7, 0.7, 8, 0.5, "Certificate of Completion", size=22, bold=True, color=NAVY)
add_text_box(slide, 0.7, 1.25, 8, 0.35, "Verified by Forage • Issued July 3, 2026", size=9, color=SLATE, italic=True)

# main cert card bordered
card = add_shape_card(slide, 0.7, 1.75, 7.8, 5.1, fill_color=WHITE, border_color=NAVY)
# inner header with yellow diamond and Forage
add_text_box(slide, 1.0, 1.95, 2.5, 0.3, "◆  Commonwealth Bank", size=9, bold=True, color=NAVY)
# Forage badge right side inside card
badge = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(6.0), Inches(1.95), Inches(1.9), Inches(0.8))
badge.fill.solid()
badge.fill.fore_color.rgb = RGBColor(0x1A,0x1A,0x1A)
badge.line.fill.background()
badge.adjustments[0]=0.12
tf=badge.text_frame
tf.word_wrap=True
tf.vertical_anchor=MSO_ANCHOR.MIDDLE
p=tf.paragraphs[0]
p.text="Forage"
p.font.size=Pt(14)
p.font.bold=True
p.font.color.rgb=WHITE
p.font.name="Calibri"
p.alignment=PP_ALIGN.CENTER
p2=tf.add_paragraph()
p2.text="Inspiring future professionals"
p2.font.size=Pt(5)
p2.font.color.rgb=RGBColor(0xD0,0xD3,0xD6)
p2.alignment=PP_ALIGN.CENTER
p2.font.name="Calibri"

add_line(slide, 1.0, 2.9, 7.2, RGBColor(0xE5,0xE7,0xEB), Pt(1))

add_text_box(slide, 1.0, 3.15, 7.2, 0.4, "Harsh Bhardwaj", size=20, bold=True, color=NAVY)
add_text_box(slide, 1.0, 3.55, 7.2, 0.3, "Software Engineering Job Simulation", size=12, bold=True, color=NAVY)
add_text_box(slide, 1.0, 3.9, 7.2, 0.25, "Certificate of Completion  •  July 3rd, 2026", size=9, color=SLATE)
add_line(slide, 1.0, 4.25, 7.2, GOLD, Pt(1.5))
add_text_box(slide, 1.0, 4.45, 7.2, 0.3, "Over the period of June – July 2026, Harsh Bhardwaj completed practical tasks in:", size=7, color=SLATE)
tasks = ["Modify an Existing .NET Backend", "Modify an Existing React/Redux Frontend", "Modify the Client's Requests", "Cover Your Code!  (Write Tests)", "Create a Pull Request"]
for idx, t in enumerate(tasks):
    y = 4.8 + idx*0.25
    add_text_box(slide, 1.15, y, 7, 0.2, f"•   {t}", size=7, color=RGBColor(0x33,0x44,0x5E))

# signature
add_text_box(slide, 5.2, 6.15, 2.8, 0.25, "Tom Brunskill", size=8, bold=True, color=NAVY, align=PP_ALIGN.RIGHT)
add_text_box(slide, 5.2, 6.35, 2.8, 0.2, "Co-Founder of Forage", size=7, color=SLATE, align=PP_ALIGN.RIGHT)
# line signature
add_line(slide, 5.5, 6.05, 1.9, SLATE, Pt(0.8))

# small codes
add_text_box(slide, 1.0, 6.65, 7.2, 0.15, "Enrolment: Fwfrpz772fW3Eb7si  •  User: 6a26a772b567c3d3d1438bfa  •  Issued by Forage", size=6, color=RGBColor(0x95,0xA5,0xA6))

# Right side - simple verification box
r_card = add_shape_card(slide, 9.0, 1.75, 3.6, 2.8, fill_color=LIGHT_BG, border_color=CARD_BORDER)
add_text_box(slide, 9.3, 2.0, 3.0, 0.3, "Verification", size=9, bold=True, color=NAVY)
add_text_box(slide, 9.3, 2.35, 3.0, 0.9, "This certificate is verified.\nUse the codes below to verify\non the Forage platform.", size=8, color=SLATE)
add_line(slide, 9.3, 3.35, 3.0, GOLD, Pt(1.5))
add_text_box(slide, 9.3, 3.55, 3.0, 0.4, "Keep this certificate for your\nrecords and interviews.", size=7, color=SLATE, italic=True)
# details box small
detail = add_shape_card(slide, 9.0, 4.75, 3.6, 2.1, fill_color=NAVY, border_color=NAVY)
add_text_box(slide, 9.3, 5.0, 3.0, 0.25, "Student Details", size=7, color=GOLD, bold=True)
add_text_box(slide, 9.3, 5.3, 3.0, 0.8, "Harsh Bhardwaj\nIT - B  •  202401100600083\nKIET Group of Institutions\nJune–July 2026", size=8, color=WHITE)

# ================= Slide 9: Thank You =================
slide = prs.slides.add_slide(prs.slide_layouts[6])
add_bg(slide, WHITE)
add_line(slide, 0, 0, 13.33, GOLD, Pt(4))
# left content
add_text_box(slide, 0.7, 1.2, 7.5, 0.6, "Thank You", size=32, bold=True, color=NAVY)
add_text_box(slide, 0.7, 2.0, 7.5, 0.6, "Happy to discuss my work, technical choices,\nor share code samples from the simulation.", size=10, color=SLATE)
# contact card
card = add_shape_card(slide, 0.7, 2.85, 7.5, 1.1, fill_color=LIGHT_BG, border_color=CARD_BORDER)
# envelope icon box
icon = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.9), Inches(3.15), Inches(0.5), Inches(0.5))
icon.fill.solid()
icon.fill.fore_color.rgb = RGBColor(0xE6,0xF0,0xFF)
icon.line.color.rgb = RGBColor(0xB8,0xD0,0xFF)
icon.adjustments[0]=0.2
tf=icon.text_frame
tf.vertical_anchor=MSO_ANCHOR.MIDDLE
p=tf.paragraphs[0]
p.text="✉"
p.font.size=Pt(14)
p.font.color.rgb=BLUE
p.alignment=PP_ALIGN.CENTER
p.font.name="Calibri"
add_text_box(slide, 1.55, 3.05, 6.2, 0.25, "Contact", size=11, bold=True, color=NAVY)
add_text_box(slide, 1.55, 3.35, 6.2, 0.4, "Harsh Bhardwaj — Available on LinkedIn & email for follow-ups and interviews.", size=9, color=SLATE)

# artifacts card
card2 = add_shape_card(slide, 0.7, 4.25, 7.5, 1.1, fill_color=LIGHT_BG, border_color=CARD_BORDER)
icon2 = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.9), Inches(4.55), Inches(0.5), Inches(0.5))
icon2.fill.solid()
icon2.fill.fore_color.rgb = RGBColor(0xE6,0xF0,0xFF)
icon2.line.color.rgb = RGBColor(0xB8,0xD0,0xFF)
icon2.adjustments[0]=0.2
tf=icon2.text_frame
tf.vertical_anchor=MSO_ANCHOR.MIDDLE
p=tf.paragraphs[0]
p.text="≡"
p.font.size=Pt(14)
p.font.color.rgb=BLUE
p.alignment=PP_ALIGN.CENTER
p.font.name="Calibri"
add_text_box(slide, 1.55, 4.45, 6.2, 0.25, "Artifacts", size=11, bold=True, color=NAVY)
add_text_box(slide, 1.55, 4.75, 6.2, 0.4, "Code snippets, unit tests, and PRs available on request for review.", size=9, color=SLATE)

# right navy panel
panel = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(8.7), Inches(0.15), Inches(4.63), Inches(7.35))
panel.fill.solid()
panel.fill.fore_color.rgb = NAVY
panel.line.fill.background()
add_text_box(slide, 9.1, 1.5, 3.85, 0.5, "Let's Connect", size=16, bold=True, color=WHITE, align=PP_ALIGN.LEFT)
add_text_box(slide, 9.1, 2.1, 3.85, 0.8, "Open to feedback, mentorship,\nand entry-level engineering\nopportunities.", size=9, color=RGBColor(0xC8,0xD0,0xDD))
add_line(slide, 9.1, 3.15, 3.7, GOLD, Pt(2))
add_text_box(slide, 9.1, 3.45, 3.85, 1.4, "Harsh Bhardwaj\nB.Tech — Information Technology\nKIET Group of Institutions\nRoll No. 202401100600083", size=9, color=WHITE)
# small badges in panel
add_badge(slide, 9.1, 5.2, "  LINKEDIN AVAILABLE  ", bg=WHITE, fg=NAVY, size=6)
add_badge(slide, 9.1, 5.55, "  EMAIL FOR INTERVIEWS  ", bg=GOLD, fg=NAVY, size=6)
add_text_box(slide, 9.1, 6.6, 3.85, 0.3, "Session 2026–27  •  Commonwealth Bank Simulation", size=7, color=RGBColor(0x8A,0x95,0xA8), align=PP_ALIGN.LEFT)

# finalize
prs.save(OUT)
print(f"Saved to {OUT}")
