#!/usr/bin/env python3
import docx
from docx.shared import Pt, Inches, RGBColor, Emu
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_LINE_SPACING, WD_TAB_ALIGNMENT, WD_TAB_LEADER
from docx.enum.section import WD_SECTION
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_CELL_VERTICAL_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import OxmlElement
from docx.oxml.ns import qn, nsdecls
from docx.dml.color import ColorFormat
import os

OUT = r"D:\ultra-latest-c2c-02\KIET_Internship_Report_Harsh_Bhardwaj_IT-B_202401100600083.docx"

doc = docx.Document()

# -- Global styles --
style = doc.styles['Normal']
style.font.name = 'Times New Roman'
style.font.size = Pt(11)
style.font.color.rgb = RGBColor(0x1F, 0x2B, 0x3A)
style.paragraph_format.space_after = Pt(6)
style.paragraph_format.line_spacing_rule = WD_LINE_SPACING.ONE_POINT_FIVE
# Ensure Times New Roman for all styles
for s in doc.styles:
    if s.type == 1:  # paragraph
        try:
            s.font.name = 'Times New Roman'
        except: pass

sections = doc.sections
for sec in sections:
    sec.top_margin = Inches(0.6)
    sec.bottom_margin = Inches(0.6)
    sec.left_margin = Inches(0.9)
    sec.right_margin = Inches(0.9)
    sec.header_distance = Inches(0.3)
    sec.footer_distance = Inches(0.3)

def set_cell_shading(cell, color_hex):
    tblCell = cell._tc
    tblCellProperties = tblCell.get_or_add_tcPr()
    shd = OxmlElement('w:shd')
    shd.set(qn('w:val'), 'clear')
    shd.set(qn('w:color'), 'auto')
    shd.set(qn('w:fill'), color_hex)
    tblCellProperties.append(shd)

def set_cell_border(cell, color="FFFFFF", sz="6"):
    tc = cell._tc
    tcPr = tc.get_or_add_tcPr()
    tcBorders = OxmlElement('w:tcBorders')
    for edge in ['top','left','bottom','right','insideH','insideV']:
        e = OxmlElement(f'w:{edge}')
        e.set(qn('w:val'), 'single')
        e.set(qn('w:sz'), sz)
        e.set(qn('w:space'), '0')
        e.set(qn('w:color'), color)
        tcBorders.append(e)
    tcPr.append(tcBorders)

def add_paragraph(cell, text, size=11, bold=False, italic=False, color=RGBColor(0xFF,0xFF,0xFF), align=WD_ALIGN_PARAGRAPH.CENTER, space_after=Pt(2), space_before=Pt(0), underline=False):
    p = cell.add_paragraph() if cell.paragraphs[0].text != "" else cell.paragraphs[0]
    # if cell already has content, create new paragraph
    if cell.paragraphs[0].text != "" and text != "":
        # need new para
        if p.text != "":
            p = cell.add_paragraph()
    p.alignment = align
    p.paragraph_format.space_after = space_after
    p.paragraph_format.space_before = space_before
    run = p.add_run(text)
    run.font.name = 'Times New Roman'
    run.font.size = Pt(size)
    run.bold = bold
    run.italic = italic
    run.font.color.rgb = color
    if underline:
        run.underline = True
    return p

def set_double_page_border(section, color="FFFFFF", sz="6"):
    sectPr = section._sectPr
    pgBorders = OxmlElement('w:pgBorders')
    pgBorders.set(qn('w:offsetFrom'), 'page')
    for edge in ['top','left','bottom','right']:
        e = OxmlElement(f'w:{edge}')
        e.set(qn('w:val'), 'double')
        e.set(qn('w:sz'), '6')
        e.set(qn('w:space'), '24')
        e.set(qn('w:color'), color)
        pgBorders.append(e)
    sectPr.append(pgBorders)

# =========================================================
# COVER PAGE - exact first image
# =========================================================
# Add double border to first section (cover)
set_double_page_border(sections[0], color="FFFFFF", sz="6")

# Create a large table to simulate dark background cover
# Instead of trying to color entire page, we will use a single cell table covering content area and shade it
# But to get full page dark, we will also add background shade via table
table = doc.add_table(rows=1, cols=1)
table.alignment = WD_TABLE_ALIGNMENT.CENTER
table.autofit = False
table.allow_autofit = False
table.columns[0].width = Inches(6.8)
cell = table.cell(0,0)
cell.vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER
set_cell_shading(cell, "1A1A1A")
set_cell_border(cell, color="FFFFFF", sz="6")
# Remove default paragraph
cell.paragraphs[0].clear()

# Inside cell, add cover content with proper spacing
# KIET Logo placeholder - create a centered box mimicking logo
# We'll make a small inner table for logo area with white background
logo_para = add_paragraph(cell, "", size=8, align=WD_ALIGN_PARAGRAPH.CENTER, space_after=Pt(0))
# Add logo text as styled runs
p_logo = cell.paragraphs[0]
p_logo.alignment = WD_ALIGN_PARAGRAPH.CENTER
# Create logo band: we add a paragraph with white background simulated via shading of paragraph? We'll just add text with colors
# Add an inner table for logo for better visual
inner_table = cell.add_table(rows=1, cols=1)
inner_table.alignment = WD_TABLE_ALIGNMENT.CENTER
inner_cell = inner_table.cell(0,0)
set_cell_shading(inner_cell, "FFFFFF")
inner_cell.vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER
inner_cell.width = Inches(4.2)
# Clear default
inner_cell.paragraphs[0].clear()
# Row1: KIET + A+ NAAC
p = inner_cell.paragraphs[0]
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
p.paragraph_format.space_after = Pt(0)
p.paragraph_format.space_before = Pt(4)
r = p.add_run("KIET")
r.font.name = 'Times New Roman'
r.font.size = Pt(28)
r.bold = True
r.font.color.rgb = RGBColor(0x0B, 0x2E, 0x8A)
r = p.add_run("  A+")
r.font.name = 'Times New Roman'
r.font.size = Pt(22)
r.bold = True
r.font.color.rgb = RGBColor(0xC0, 0x39, 0x2B)
# Second line
p2 = inner_cell.add_paragraph()
p2.alignment = WD_ALIGN_PARAGRAPH.CENTER
p2.paragraph_format.space_after = Pt(0)
r = p2.add_run("GROUP OF INSTITUTIONS")
r.font.name = 'Times New Roman'
r.font.size = Pt(8)
r.bold = True
r.font.color.rgb = RGBColor(0x0B, 0x2E, 0x8A)
r = p2.add_run("   NAAC")
r.font.size = Pt(7)
r.bold = True
r.font.color.rgb = RGBColor(0xC0,0x39,0x2B)
p3 = inner_cell.add_paragraph()
p3.alignment = WD_ALIGN_PARAGRAPH.CENTER
p3.paragraph_format.space_after = Pt(1)
r = p3.add_run("Connecting Life with Learning")
r.font.name = 'Times New Roman'
r.font.size = Pt(6)
r.italic = True
r.font.color.rgb = RGBColor(0xE6, 0x7E, 0x22)
# Blue band
p4 = inner_cell.add_paragraph()
p4.alignment = WD_ALIGN_PARAGRAPH.CENTER
pf = p4.paragraph_format
pf.space_after = Pt(0)
# Add shading to paragraph via xml
pPr = p4._p.get_or_add_pPr()
shd = OxmlElement('w:shd')
shd.set(qn('w:val'), 'clear')
shd.set(qn('w:color'), 'auto')
shd.set(qn('w:fill'), '0B2E8A')
pPr.append(shd)
r = p4.add_run("  An Autonomous Institute  ")
r.font.name = 'Times New Roman'
r.font.size = Pt(7)
r.bold = True
r.font.color.rgb = RGBColor(0xFF,0xFF,0xFF)
# small www line
p5 = inner_cell.add_paragraph()
p5.alignment = WD_ALIGN_PARAGRAPH.CENTER
p5.paragraph_format.space_after = Pt(4)
r = p5.add_run("www.kiet.edu   Delhi-NCR, Ghaziabad   Established 1998")
r.font.name = 'Times New Roman'
r.font.size = Pt(5)
r.font.color.rgb = RGBColor(0x5D,0x6D,0x7E)

# Spacer after logo
sp = cell.add_paragraph()
sp.paragraph_format.space_before = Pt(18)
sp.paragraph_format.space_after = Pt(0)
r = sp.add_run("")
r.font.size = Pt(2)

# Department
add_paragraph(cell, "Department of Information Technology", size=11, italic=True, color=RGBColor(0xFF,0xFF,0xFF), align=WD_ALIGN_PARAGRAPH.CENTER, space_after=Pt(36), space_before=Pt(6))

# Internship Report
add_paragraph(cell, "Internship Report", size=13, bold=True, color=RGBColor(0xFF,0xFF,0xFF), align=WD_ALIGN_PARAGRAPH.CENTER, space_after=Pt(4))
add_paragraph(cell, "on", size=11, bold=False, color=RGBColor(0xFF,0xFF,0xFF), align=WD_ALIGN_PARAGRAPH.CENTER, space_after=Pt(4))
add_paragraph(cell, "Software Engineering Job Simulation at Commonwealth Bank", size=11, bold=True, color=RGBColor(0xFF,0xFF,0xFF), align=WD_ALIGN_PARAGRAPH.CENTER, space_after=Pt(2))
# maybe add second line for via Forage
add_paragraph(cell, "(via Forage) — June–July 2026", size=9, bold=False, italic=True, color=RGBColor(0xD5,0xD8,0xDC), align=WD_ALIGN_PARAGRAPH.CENTER, space_after=Pt(42))

# Session
add_paragraph(cell, "(Session-2026-27)", size=11, bold=True, color=RGBColor(0xFF,0xFF,0xFF), align=WD_ALIGN_PARAGRAPH.CENTER, space_after=Pt(72))

# Submitted By - right aligned bottom
p = cell.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
p.paragraph_format.space_after = Pt(1)
r = p.add_run("Submitted By:")
r.font.name = 'Times New Roman'
r.font.size = Pt(9)
r.bold = True
r.font.color.rgb = RGBColor(0xFF,0xFF,0xFF)
p = cell.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
p.paragraph_format.space_after = Pt(1)
r = p.add_run("Harsh Bhardwaj")
r.font.name = 'Times New Roman'
r.font.size = Pt(9)
r.bold = True
r.font.color.rgb = RGBColor(0xFF,0xFF,0xFF)
p = cell.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
p.paragraph_format.space_after = Pt(1)
r = p.add_run("IT - B (Sem-Sec.)")
r.font.name = 'Times New Roman'
r.font.size = Pt(9)
r.bold = True
r.font.color.rgb = RGBColor(0xFF,0xFF,0xFF)
p = cell.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
p.paragraph_format.space_after = Pt(8)
r = p.add_run("Roll No. 202401100600083")
r.font.name = 'Times New Roman'
r.font.size = Pt(9)
r.bold = True
r.font.color.rgb = RGBColor(0xFF,0xFF,0xFF)

# Ensure cell height approx to fill page
# Set row height
tr = table.rows[0]._tr
trPr = tr.get_or_add_trPr()
trHeight = OxmlElement('w:trHeight')
trHeight.set(qn('w:val'), '9500')
trHeight.set(qn('w:hRule'), 'atLeast')
trPr.append(trHeight)

doc.add_page_break()

# Remove double border for subsequent sections - create new section for rest with single border and white background
# Add new section
sec2 = doc.add_section(WD_SECTION.NEW_PAGE)
sec2.top_margin = Inches(0.7)
sec2.bottom_margin = Inches(0.7)
sec2.left_margin = Inches(0.9)
sec2.right_margin = Inches(0.9)
# Single thin border for inner pages (optional, not in image but professional)
sectPr2 = sec2._sectPr
pgBorders2 = OxmlElement('w:pgBorders')
pgBorders2.set(qn('w:offsetFrom'), 'page')
for edge in ['top','left','bottom','right']:
    e = OxmlElement(f'w:{edge}')
    e.set(qn('w:val'), 'single')
    e.set(qn('w:sz'), '4')
    e.set(qn('w:space'), '18')
    e.set(qn('w:color'), '2C3E50')
    pgBorders2.append(e)
sectPr2.append(pgBorders2)

# Helper for headings
def add_heading(text, level=1, align=WD_ALIGN_PARAGRAPH.LEFT, color=RGBColor(0x0B,0x2E,0x8A), size=14, space_before=Pt(12), space_after=Pt(6), underline=False):
    p = doc.add_paragraph()
    p.alignment = align
    p.paragraph_format.space_before = space_before
    p.paragraph_format.space_after = space_after
    # keep with next
    pPr = p._p.get_or_add_pPr()
    keep = OxmlElement('w:keepNext')
    pPr.append(keep)
    run = p.add_run(text)
    run.font.name = 'Times New Roman'
    run.font.size = Pt(size)
    run.bold = True
    run.font.color.rgb = color
    if underline:
        run.underline = True
    if level==1:
        # add bottom border line
        pPr2 = p._p.get_or_add_pPr()
        pBdr = OxmlElement('w:pBdr')
        bottom = OxmlElement('w:bottom')
        bottom.set(qn('w:val'), 'single')
        bottom.set(qn('w:sz'), '6')
        bottom.set(qn('w:space'), '1')
        bottom.set(qn('w:color'), '0B2E8A')
        pBdr.append(bottom)
        pPr2.append(pBdr)
    return p

def add_subheading(text, size=11, color=RGBColor(0x1A,0x1A,0x1A), space_before=Pt(10), space_after=Pt(4)):
    p = doc.add_paragraph()
    p.paragraph_format.space_before = space_before
    p.paragraph_format.space_after = space_after
    run = p.add_run(text)
    run.font.name = 'Times New Roman'
    run.font.size = Pt(size)
    run.bold = True
    run.font.color.rgb = color
    return p

def add_body(text, align=WD_ALIGN_PARAGRAPH.JUSTIFY, size=11, bold=False, italic=False, space_after=Pt(6), color=RGBColor(0x21,0x21,0x21), bullet=False, level=0):
    p = doc.add_paragraph(style='List Bullet' if bullet else 'Normal')
    p.alignment = align
    p.paragraph_format.space_after = space_after
    p.paragraph_format.space_before = Pt(0)
    p.paragraph_format.left_indent = Inches(0.2*level) if bullet else Inches(0)
    p.paragraph_format.first_line_indent = Inches(0) 
    run = p.add_run(text)
    run.font.name = 'Times New Roman'
    run.font.size = Pt(size)
    run.bold = bold
    run.italic = italic
    run.font.color.rgb = color
    return p

def add_numbered(text, num, size=11):
    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(2)
    p.paragraph_format.left_indent = Inches(0.3)
    p.style.font.name = 'Times New Roman'
    run = p.add_run(f"{num}.  {text}")
    run.font.name = 'Times New Roman'
    run.font.size = Pt(size)
    run.font.color.rgb = RGBColor(0x21,0x21,0x21)
    return p

# =========================================================
# GUIDELINES / INDEX PAGE - second image strict
# =========================================================
# Title right aligned underline
p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
p.paragraph_format.space_after = Pt(8)
r = p.add_run("Guidelines/Index for Internship Report")
r.font.name = 'Times New Roman'
r.font.size = Pt(13)
r.bold = True
r.underline = True
r.font.color.rgb = RGBColor(0x1A,0x1A,0x1A)

p = doc.add_paragraph()
p.paragraph_format.space_after = Pt(4)
r = p.add_run("Following essentials are to be taken in to consideration during preparation of internship report:")
r.font.name = 'Times New Roman'
r.font.size = Pt(10)
r.bold = True
r.font.color.rgb = RGBColor(0x21,0x21,0x21)

items = [
    "Internship Certificate",
    "Brief of Internship.",
    "Details of Technical learning during Internship",
    "Conclusion/Outcome of Internship",
    "Attach Internship Certificates",
    "Attach literature review report about existing system related to work done during internship (minimum 2 pages)"
]
for idx, it in enumerate(items, 1):
    add_numbered(it, idx, size=10)

# Note
p = doc.add_paragraph()
p.paragraph_format.space_before = Pt(12)
p.paragraph_format.space_after = Pt(4)
r = p.add_run("Note*:")
r.font.name = 'Times New Roman'
r.font.size = Pt(10)
r.bold = True
r.underline = True
notes = [
    "All text of the report must be in similar font (times new roman).",
    "Uniformity in headings, sub-heading and text should be taken in to consideration.",
    "All contents must be initiated by an index.",
    "All contents of report must be submitted in a single \"pdf\"."
]
for idx, n in enumerate(notes, 1):
    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(1)
    p.paragraph_format.left_indent = Inches(0.3)
    r = p.add_run(f"{idx}.  {n}")
    r.font.name = 'Times New Roman'
    r.font.size = Pt(9)
    r.italic = True if idx==4 else False
    r.bold = True if idx==4 else False
    r.font.color.rgb = RGBColor(0x21,0x21,0x21)

# --- Actual Index (Table of Contents) ---
add_heading("INDEX", level=1, align=WD_ALIGN_PARAGRAPH.CENTER, size=16, space_before=Pt(18), space_after=Pt(10))
# Create TOC table
toc_data = [
    ("S. No.", "Contents", "Page No."),
    ("1", "Internship Certificate", "3"),
    ("2", "Brief of Internship", "4"),
    ("3", "About Commonwealth Bank", "4"),
    ("4", "Internship Objective", "5"),
    ("5", "Technology Stack", "6"),
    ("6", "Details of Technical Learning during Internship", "7"),
    ("7", "Key Learnings", "7"),
    ("8", "Challenges Faced", "9"),
    ("9", "Results & Conclusions", "10"),
    ("10", "Outcome & Competencies Gained", "10"),
    ("11", "Internship Certificate (Forage - Copy)", "11"),
    ("12", "Literature Review Report (Existing System Study)", "12-13"),
    ("13", "References & Thank You", "14"),
]
toc_table = doc.add_table(rows=1, cols=3)
toc_table.alignment = WD_TABLE_ALIGNMENT.CENTER
toc_table.style = 'Light Grid Accent 1'
# set column widths
for row in toc_table.rows:
    row.cells[0].width = Inches(0.8)
    row.cells[1].width = Inches(4.8)
    row.cells[2].width = Inches(1.0)
hdr = toc_table.rows[0].cells
for i, h in enumerate(toc_data[0]):
    p = hdr[i].paragraphs[0]
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = p.add_run(h)
    r.font.name = 'Times New Roman'
    r.font.size = Pt(10)
    r.bold = True
    r.font.color.rgb = RGBColor(0xFF,0xFF,0xFF)
    shading = OxmlElement('w:shd')
    shading.set(qn('w:val'), 'clear')
    shading.set(qn('w:color'), 'auto')
    shading.set(qn('w:fill'), '0B2E8A')
    hdr[i]._tc.get_or_add_tcPr().append(shading)

for s_no, content, pg in toc_data[1:]:
    row = toc_table.add_row().cells
    for i, txt in enumerate([s_no, content, pg]):
        p = row[i].paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER if i in [0,2] else WD_ALIGN_PARAGRAPH.LEFT
        r = p.add_run(txt)
        r.font.name = 'Times New Roman'
        r.font.size = Pt(9)
        r.font.color.rgb = RGBColor(0x21,0x21,0x21)
        if i==1:
            p.paragraph_format.left_indent = Inches(0.1)

doc.add_page_break()

# =========================================================
# 1. Internship Certificate (Blank with heading)
# =========================================================
add_heading("1.  Internship Certificate", level=1, size=14)
p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
p.paragraph_format.space_before = Pt(18)
r = p.add_run("[ Certificate Page — Heading Retained, Content Left Blank as Instructed ]")
r.font.name = 'Times New Roman'
r.font.size = Pt(10)
r.italic = True
r.font.color.rgb = RGBColor(0x5D,0x6D,0x7E)
# Add bordered placeholder box
table_c = doc.add_table(rows=1, cols=1)
table_c.alignment = WD_TABLE_ALIGNMENT.CENTER
cell_c = table_c.cell(0,0)
cell_c.height = Inches(3.2)
cell_c.vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER
set_cell_shading(cell_c, "F8F9FA")
# border
tcPr = cell_c._tc.get_or_add_tcPr()
tcBorders = OxmlElement('w:tcBorders')
for edge in ['top','left','bottom','right']:
    e = OxmlElement(f'w:{edge}')
    e.set(qn('w:val'), 'dashed')
    e.set(qn('w:sz'), '6')
    e.set(qn('w:space'), '6')
    e.set(qn('w:color'), '5D6D7E')
    tcBorders.append(e)
tcPr.append(tcBorders)
p = cell_c.paragraphs[0]
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
r = p.add_run("Internship Certificate to be attached here\n(Forage / Commonwealth Bank Verification)\n— Blank as per instructions —")
r.font.name = 'Times New Roman'
r.font.size = Pt(9)
r.italic = True
r.font.color.rgb = RGBColor(0x5D,0x6D,0x7E)

add_body("Note: Original verified certificate is enclosed in Section 11 of this report for reference.", size=8, italic=True, color=RGBColor(0x5D,0x6D,0x7E), align=WD_ALIGN_PARAGRAPH.CENTER, space_after=Pt(12))

# =========================================================
# 2. Brief of Internship
# =========================================================
add_heading("2.  Brief of Internship", level=1, size=14)
add_body("Internship Title: Software Engineering Job Simulation at Commonwealth Bank (via Forage) — June–July 2026", size=11, bold=True, color=RGBColor(0x0B,0x2E,0x8A))
add_body("Student: Harsh Bhardwaj — B. Tech Information Technology, Section B — Roll No. 202401100600083 — KIET Group of Institutions, Delhi-NCR, Ghaziabad", size=10, italic=True, color=RGBColor(0x2C,0x3E,0x50))

add_subheading("2.1  Overview")
add_body("The Commonwealth Bank of Australia (CBA) Software Engineering Job Simulation, hosted on the Forage platform, is a verified virtual internship that replicates production-grade engineering workflows within a highly regulated financial-services environment. The simulation was undertaken from June to July 2026 and focused on end-to-end feature delivery, legacy-system integration, rigorous testing, and collaborative Git practices that mirror industry standards at Australia's leading digital bank serving over 17 million customers.")

add_subheading("2.2  About Commonwealth Bank")
add_body("Commonwealth Bank is Australia's leading digital bank recognized for secure, scalable, and customer-centric financial services. Its engineering organization is built on cloud-native platforms with strong emphasis on CI/CD, high-availability systems, and security-first delivery. Key tenets include robust risk controls and encryption, compliance with financial regulations, incremental delivery through automated testing and code-review culture, and reliability engineering for peak-load resilience. These principles formed the backdrop for all tasks in the simulation.")

# Feature boxes like presentation - we'll recreate as table
t = doc.add_table(rows=1, cols=3)
t.alignment = WD_TABLE_ALIGNMENT.CENTER
t.style = 'Light Grid Accent 1'
hdr = t.rows[0].cells
headers = ["Security-first", "Scale & Reliability", "Engineering Practices"]
descs = [
    "Robust risk controls, encryption, and regulatory compliance across services.",
    "High-availability systems designed for millions of customers and peak loads.",
    "Emphasis on test automation, code review culture, and incremental delivery."
]
for i, h in enumerate(headers):
    p = hdr[i].paragraphs[0]
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = p.add_run(h)
    r.font.name = 'Times New Roman'
    r.font.size = Pt(9)
    r.bold = True
    r.font.color.rgb = RGBColor(0xFF,0xFF,0xFF)
    shd = OxmlElement('w:shd')
    shd.set(qn('w:val'), 'clear')
    shd.set(qn('w:color'), 'auto')
    shd.set(qn('w:fill'), '0B2E8A')
    hdr[i]._tc.get_or_add_tcPr().append(shd)
row = t.add_row().cells
for i, d in enumerate(descs):
    p = row[i].paragraphs[0]
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = p.add_run(d)
    r.font.name = 'Times New Roman'
    r.font.size = Pt(8)
    r.font.color.rgb = RGBColor(0x21,0x21,0x21)

add_subheading("2.3  Duration & Mode")
add_body("Duration: June 2026 – July 2026 (4–5 weeks, self-paced) | Mode: Virtual Job Simulation (Forage) | Verification: Forage Verified Simulation – Commonwealth Bank | Enrolment Verification Code: Fwfrpz772fW3Eb7si | User Verification Code: 6a26a772b567c3d3d1438bfa")

# =========================================================
# 3. Internship Objective (also part of Brief but as per presentation)
# =========================================================
add_heading("3.  Internship Objective", level=1, size=14)
add_body("The primary objective of the simulation was to simulate a production-grade software engineering workflow: implement features, integrate with existing services, write unit tests, and follow pull-request and CI practices used at Commonwealth Bank. The objective was decomposed into three measurable tracks:")

obj_table = doc.add_table(rows=1, cols=3)
obj_table.style = 'Light Grid Accent 1'
obj_table.alignment = WD_TABLE_ALIGNMENT.CENTER
hdr = obj_table.rows[0].cells
for i, txt in enumerate(["01 — Feature Implementation", "02 — Integration & Testing", "03 — Collaboration"]):
    p = hdr[i].paragraphs[0]
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = p.add_run(txt)
    r.font.name='Times New Roman'
    r.font.size=Pt(9)
    r.bold=True
    r.font.color.rgb=RGBColor(0xFF,0xFF,0xFF)
    shd=OxmlElement('w:shd'); shd.set(qn('w:val'),'clear'); shd.set(qn('w:color'),'auto'); shd.set(qn('w:fill'),'0B2E8A')
    hdr[i]._tc.get_or_add_tcPr().append(shd)
row = obj_table.add_row().cells
texts = [
    "Start-to-finish delivery of small backend and frontend features, from requirement analysis to deployment readiness.",
    "Integrate with mock services; author unit and component tests using xUnit/Jest and React Testing Library.",
    "Use Git workflows, PR reviews, and CI feedback loops to maintain velocity and code quality."
]
for i, txt in enumerate(texts):
    p=row[i].paragraphs[0]
    p.alignment=WD_ALIGN_PARAGRAPH.JUSTIFY
    r=p.add_run(txt)
    r.font.name='Times New Roman'
    r.font.size=Pt(8)
    r.font.color.rgb=RGBColor(0x21,0x21,0x21)

add_body("On successful completion, all assigned pull requests were peer-reviewed, CI checks passed, and code was merged to main, thereby demonstrating readiness for entry-level engineering roles in regulated environments.", size=10, italic=True)

# =========================================================
# 4. Details of Technical Learning (presentation Technology Stack + Key Learnings)
# =========================================================
add_heading("4.  Details of Technical Learning during Internship", level=1, size=14)
add_body("This section consolidates the technology stack explored and the hands-on learning derived from implementing, testing, and integrating features in a banking-grade codebase.")

add_subheading("4.1  Technology Stack")
add_body("The stack was chosen to mirror Commonwealth Bank's microservice and web-app patterns used in simulations and is summarized below:")

bullets = [
    (".NET (C#) — backend APIs and business logic", "Built RESTful endpoints, implemented input validation, service-layer abstraction, and dependency-injection friendly services for high testability."),
    ("React + Redux — interactive frontend and state management", "Developed reusable React components, managed global state via Redux slices, implemented selectors to minimize re-renders, and normalized complex state shapes."),
    ("MongoDB — document data storage for flexible models", "Designed flexible document schemas for user/transaction data, integrated data-access layers, and mocked persistence for isolated tests."),
    ("Git & GitHub workflows — branching, PRs, and code reviews", "Followed feature-branch strategy, authored clear PR descriptions, responded to review comments, and iterated promptly to keep CI green."),
    ("Unit testing frameworks — xUnit for .NET, Jest / React Testing Library for frontend", "Authored unit and integration tests, achieved deterministic mocks for external services, and integrated tests into CI to catch regressions early."),
]
for title, desc in bullets:
    p = doc.add_paragraph(style='List Bullet')
    p.paragraph_format.space_after = Pt(3)
    r = p.add_run(title)
    r.font.name='Times New Roman'
    r.font.size=Pt(10)
    r.bold=True
    r.font.color.rgb=RGBColor(0x0B,0x2E,0x8A)
    r = p.add_run(f" — {desc}")
    r.font.name='Times New Roman'
    r.font.size=Pt(9)
    r.bold=False
    r.font.color.rgb=RGBColor(0x21,0x21,0x21)

# Info box
p = doc.add_paragraph()
pPr = p._p.get_or_add_pPr()
shd = OxmlElement('w:shd'); shd.set(qn('w:val'),'clear'); shd.set(qn('w:color'),'auto'); shd.set(qn('w:fill'),'EAF2F8')
pPr.append(shd)
pPr2 = OxmlElement('w:pBdr')
for edge in ['top','left','bottom','right']:
    e=OxmlElement(f'w:{edge}'); e.set(qn('w:val'),'single'); e.set(qn('w:sz'),'4'); e.set(qn('w:space'),'4'); e.set(qn('w:color'),'0B2E8A')
    pPr2.append(e)
p._p.get_or_add_pPr().append(pPr2)
p.alignment = WD_ALIGN_PARAGRAPH.LEFT
r = p.add_run("Note: ")
r.font.name='Times New Roman'; r.font.size=Pt(8); r.bold=True; r.font.color.rgb=RGBColor(0x0B,0x2E,0x8A)
r = p.add_run("Stack choices mirror common Commonwealth Bank microservice and web-app patterns used in simulations, ensuring transferability to enterprise financial systems.")
r.font.name='Times New Roman'; r.font.size=Pt(8); r.font.color.rgb=RGBColor(0x21,0x21,0x21)

add_subheading("4.2  Key Learnings")
# 4 columns table like presentation Key Learnings
kl_table = doc.add_table(rows=1, cols=4)
kl_table.style='Light Grid Accent 1'
kl_table.alignment = WD_TABLE_ALIGNMENT.CENTER
hdr = kl_table.rows[0].cells
kl_headers = ["Backend Development", "Frontend Engineering", "Testing & CI", "Collaboration"]
for i, h in enumerate(kl_headers):
    p=hdr[i].paragraphs[0]; p.alignment=WD_ALIGN_PARAGRAPH.CENTER
    r=p.add_run(h); r.font.name='Times New Roman'; r.font.size=Pt(8); r.bold=True; r.font.color.rgb=RGBColor(0xFF,0xFF,0xFF)
    shd=OxmlElement('w:shd'); shd.set(qn('w:val'),'clear'); shd.set(qn('w:color'),'auto'); shd.set(qn('w:fill'),'0B2E8A')
    hdr[i]._tc.get_or_add_tcPr().append(shd)
row = kl_table.add_row().cells
kl_descs = [
    "Implemented API endpoints, improved input validation, and added dependency-injection friendly services for testability. Emphasized clean service separation and error-handling middleware.",
    "Built React components, connected state via Redux slices, and verified UI behavior with component tests. Optimized selector usage to avoid unnecessary renders.",
    "Authored unit and integration tests; integrated them into CI to catch regressions early. Practiced test-driven development and reliable mocking of data-access layers.",
    "Practiced clear PR descriptions, addressed review feedback, and iterated promptly to maintain velocity. Strengthened code-review culture and incremental refactoring discipline."
]
for i, d in enumerate(kl_descs):
    p=row[i].paragraphs[0]; p.alignment=WD_ALIGN_PARAGRAPH.JUSTIFY
    r=p.add_run(d); r.font.name='Times New Roman'; r.font.size=Pt(7); r.font.color.rgb=RGBColor(0x21,0x21,0x21)

add_subheading("4.3  Hands-on Activities Performed")
add_body("• Created and modified existing .NET backend controllers/services, adding validation and logging without breaking existing flows.", bullet=True)
add_body("• Modified existing React/Redux frontend: built new UI components, updated Redux store, and handled client-side requests vialive mock APIs.", bullet=True)
add_body("• Created feature branches, pushed commits, opened pull requests, and incorporated reviewer suggestions before merge.", bullet=True)
add_body("• Wrote xUnit and Jest tests, mocked MongoDB/data-access layers, and ensured CI pipeline remained green.", bullet=True)
add_body("• Documented technical decisions in PR descriptions and simulation journals for auditability.", bullet=True)

# =========================================================
# 5. Challenges Faced - expanded
# =========================================================
add_heading("5.  Challenges Faced & Mitigation", level=1, size=14)
add_body("Working within a legacy-simulated banking codebase introduced realistic constraints. The following challenges were encountered and systematically addressed:")

challenges = [
    ("Legacy code integration", "Understanding implicit dependencies and limited documentation.", "Performed incremental code archaeology: traced call graphs, added typed interfaces, and wrote characterization tests before refactoring."),
    ("Redux state complexity", "Normalizing state and selecting efficient selectors to avoid unnecessary renders.", "Introduced normalized Redux state, memoized selectors, and verified render counts via component tests."),
    ("Cross-cutting concerns", "Adding logging and error-handling without breaking existing flows.", "Implemented middleware-style logging and centralized error boundaries/HTTP interceptors, validated with integration tests."),
    ("Test isolation", "Creating reliable mocks for data-access layers and external services.", "Built dependency-injection friendly services, substituted MongoDB repositories with in-memory fakes, and introduced test fixtures for deterministic runs."),
]
for title, prob, sol in challenges:
    p=doc.add_paragraph()
    p.paragraph_format.space_after=Pt(3)
    p.style.font.name='Times New Roman'
    r=p.add_run(f"•  {title} — ")
    r.font.name='Times New Roman'; r.font.size=Pt(10); r.bold=True; r.font.color.rgb=RGBColor(0x0B,0x2E,0x8A)
    r=p.add_run(prob)
    r.font.name='Times New Roman'; r.font.size=Pt(9); r.font.color.rgb=RGBColor(0x21,0x21,0x21)
    p2=doc.add_paragraph()
    p2.paragraph_format.left_indent=Inches(0.25)
    p2.paragraph_format.space_after=Pt(4)
    r=p2.add_run("Mitigation: ")
    r.font.name='Times New Roman'; r.font.size=Pt(9); r.bold=True; r.italic=True; r.font.color.rgb=RGBColor(0x1A,0x1A,0x1A)
    r=p2.add_run(sol)
    r.font.name='Times New Roman'; r.font.size=Pt(9); r.font.color.rgb=RGBColor(0x21,0x21,0x21)

# Blue info box as in presentation
p = doc.add_paragraph()
pPr = p._p.get_or_add_pPr()
shd = OxmlElement('w:shd'); shd.set(qn('w:val'),'clear'); shd.set(qn('w:color'),'auto'); shd.set(qn('w:fill'),'D6EAF8')
pPr.append(shd)
pBdr = OxmlElement('w:pBdr')
for edge in ['top','left','bottom','right']:
    e=OxmlElement(f'w:{edge}'); e.set(qn('w:val'),'single'); e.set(qn('w:sz'),'4'); e.set(qn('w:space'),'4'); e.set(qn('w:color'),'2980B9')
    pBdr.append(e)
pPr.append(pBdr)
p.alignment=WD_ALIGN_PARAGRAPH.LEFT
r=p.add_run("Addressed challenges through incremental refactors, typed interfaces, and targeted tests to reduce risk, thereby maintaining system stability while delivering new features.")
r.font.name='Times New Roman'; r.font.size=Pt(8); r.italic=True; r.font.color.rgb=RGBColor(0x1A,0x1A,0x1A)

# =========================================================
# 6. Conclusion / Outcome
# =========================================================
add_heading("6.  Conclusion / Outcome of Internship", level=1, size=14)
add_body("All assigned tasks were completed (100%). Deliverables included production-ready backend endpoints, interactive React components, comprehensive unit tests, and well-documented pull requests. The simulation materially accelerated practical readiness for entry-level engineering roles in regulated financial environments, instilling confidence in delivering secure, scalable, and well-tested software.")

res_table = doc.add_table(rows=1, cols=3)
res_table.style='Light Grid Accent 1'
res_table.alignment=WD_TABLE_ALIGNMENT.CENTER
hdr=res_table.rows[0].cells
for i, h in enumerate(["Outcomes", "Competencies Gained", "Next Steps"]):
    p=hdr[i].paragraphs[0]; p.alignment=WD_ALIGN_PARAGRAPH.CENTER
    r=p.add_run(h); r.font.name='Times New Roman'; r.font.size=Pt(9); r.bold=True; r.font.color.rgb=RGBColor(0xFF,0xFF,0xFF)
    shd=OxmlElement('w:shd'); shd.set(qn('w:val'),'clear'); shd.set(qn('w:color'),'auto'); shd.set(qn('w:fill'),'0B2E8A')
    hdr[i]._tc.get_or_add_tcPr().append(shd)
row=res_table.add_row().cells
outcomes = [
    "Feature parity with requirements, passing CI checks, and peer-reviewed code merged to main.",
    "Test-driven development, Git collaboration, state management, and pragmatic debugging.",
    "Apply learnings to larger codebases, contribute to architecture discussions, and pursue mentorship within engineering teams."
]
for i, txt in enumerate(outcomes):
    p=row[i].paragraphs[0]; p.alignment=WD_ALIGN_PARAGRAPH.JUSTIFY
    r=p.add_run(txt); r.font.name='Times New Roman'; r.font.size=Pt(8); r.font.color.rgb=RGBColor(0x21,0x21,0x21)

add_subheading("6.1  Overall Outcome Assessment")
add_body("The simulation validated the intern's ability to navigate enterprise constraints, deliver incremental value without destabilizing legacy modules, and uphold rigorous quality gates. Feedback loops via CI and code review reinforced disciplined engineering, while the banking domain context deepened appreciation for security, compliance, and reliability as non-negotiable pillars. The experience serves as a strong foundation for future internships and full-time roles in fintech and enterprise software.")

# =========================================================
# 7. Attach Internship Certificates
# =========================================================
add_heading("7.  Attach Internship Certificate(s)", level=1, size=14)
add_body("Verified Certificate of Completion — Software Engineering Job Simulation, Commonwealth Bank (via Forage) — Issued July 3, 2026", size=11, bold=True, color=RGBColor(0x0B,0x2E,0x8A), align=WD_ALIGN_PARAGRAPH.CENTER)

# Recreate certificate box stylized
cert_table = doc.add_table(rows=1, cols=1)
cert_table.alignment=WD_TABLE_ALIGNMENT.CENTER
cert_cell = cert_table.cell(0,0)
set_cell_shading(cert_cell, "FFFFFF")
tcPr=cert_cell._tc.get_or_add_tcPr()
tcBorders=OxmlElement('w:tcBorders')
for edge in ['top','left','bottom','right']:
    e=OxmlElement(f'w:{edge}'); e.set(qn('w:val'),'single'); e.set(qn('w:sz'),'6'); e.set(qn('w:space'),'4'); e.set(qn('w:color'),'2C3E50')
    tcBorders.append(e)
tcPr.append(tcBorders)
# inside
p = cert_cell.paragraphs[0]
p.alignment=WD_ALIGN_PARAGRAPH.LEFT
p.paragraph_format.space_after=Pt(12)
# top row with CBA and Forage placeholders
inner = cert_cell.add_table(rows=1, cols=2)
inner.autofit=True
c1 = inner.cell(0,0)
c2 = inner.cell(0,1)
p = c1.paragraphs[0]; p.alignment=WD_ALIGN_PARAGRAPH.LEFT
r=p.add_run("◆  Commonwealth Bank")
r.font.name='Times New Roman'; r.font.size=Pt(9); r.bold=True; r.font.color.rgb=RGBColor(0xF1,0xC4,0x0)
p = c2.paragraphs[0]; p.alignment=WD_ALIGN_PARAGRAPH.RIGHT
# Forage badge
pPr2 = p._p.get_or_add_pPr()
shd=OxmlElement('w:shd'); shd.set(qn('w:val'),'clear'); shd.set(qn('w:color'),'auto'); shd.set(qn('w:fill'),'1A1A1A')
pPr2.append(shd)
r=p.add_run("  Forage  ")
r.font.name='Times New Roman'; r.font.size=Pt(10); r.bold=True; r.font.color.rgb=RGBColor(0xFF,0xFF,0xFF)
p = c2.add_paragraph(); p.alignment=WD_ALIGN_PARAGRAPH.RIGHT
r=p.add_run("Inspiring and empowering future professionals")
r.font.name='Times New Roman'; r.font.size=Pt(6); r.font.color.rgb=RGBColor(0xFF,0xFF,0xFF)
# add shading to c2 cell
set_cell_shading(c2, "1A1A1A")

p = cert_cell.add_paragraph()
p.paragraph_format.space_before=Pt(12)
p.alignment=WD_ALIGN_PARAGRAPH.LEFT
r=p.add_run("Harsh Bhardwaj")
r.font.name='Times New Roman'; r.font.size=Pt(16); r.bold=True; r.font.color.rgb=RGBColor(0x1A,0x1A,0x1A)
p = cert_cell.add_paragraph()
r=p.add_run("Software Engineering Job Simulation")
r.font.name='Times New Roman'; r.font.size=Pt(12); r.bold=True; r.font.color.rgb=RGBColor(0x1A,0x1A,0x1A)
p = cert_cell.add_paragraph()
r=p.add_run("Certificate of Completion")
r.font.name='Times New Roman'; r.font.size=Pt(10); r.font.color.rgb=RGBColor(0x5D,0x6D,0x7E)
p = cert_cell.add_paragraph()
p.paragraph_format.space_after=Pt(12)
r=p.add_run("July 3rd, 2026")
r.font.name='Times New Roman'; r.font.size=Pt(9); r.font.color.rgb=RGBColor(0x5D,0x6D,0x7E)

p = cert_cell.add_paragraph()
p.paragraph_format.space_before=Pt(12)
# line
pPrLine = p._p.get_or_add_pPr()
pBdrLine = OxmlElement('w:pBdr')
top = OxmlElement('w:top'); top.set(qn('w:val'),'single'); top.set(qn('w:sz'),'4'); top.set(qn('w:space'),'1'); top.set(qn('w:color'),'D5D8DC')
pBdrLine.append(top)
pPrLine.append(pBdrLine)
r=p.add_run("Over the period of June 2026 to July 2026, Harsh Bhardwaj has completed practical tasks in:")
r.font.name='Times New Roman'; r.font.size=Pt(7); r.font.color.rgb=RGBColor(0x5D,0x6D,0x7E)
bullets_cert = [
    "Modify an Existing .NET Backend",
    "Modify an Existing React/Redux Frontend",
    "Modify the Client's Requests",
    "Cover Your Code!",
    "Create a Pull Request"
]
for b in bullets_cert:
    p=cert_cell.add_paragraph(style='List Bullet')
    p.paragraph_format.space_after=Pt(0)
    r=p.add_run(b)
    r.font.name='Times New Roman'; r.font.size=Pt(7); r.font.color.rgb=RGBColor(0x1A,0x1A,0x1A)
# signature line
p=cert_cell.add_paragraph()
p.alignment=WD_ALIGN_PARAGRAPH.RIGHT
p.paragraph_format.space_before=Pt(12)
r=p.add_run("Tom Brunskill\nCo-Founder of Forage")
r.font.name='Times New Roman'; r.font.size=Pt(7); r.italic=True; r.font.color.rgb=RGBColor(0x5D,0x6D,0x7E)
p=cert_cell.add_paragraph()
p.alignment=WD_ALIGN_PARAGRAPH.CENTER
p.paragraph_format.space_before=Pt(12)
r=p.add_run("Enrolment Verification Code Fwfrpz772fW3Eb7si  |  User Verification Code 6a26a772b567c3d3d1438bfa  |  Issued by Forage")
r.font.name='Times New Roman'; r.font.size=Pt(5); r.font.color.rgb=RGBColor(0x95,0xA5,0xA6)

add_body("The above is a faithful transcription of the verified digital certificate. Original PDF verification can be validated via Forage platform using the codes stated.", size=8, italic=True, color=RGBColor(0x5D,0x6D,0x7E), align=WD_ALIGN_PARAGRAPH.CENTER, space_after=Pt(10))

# =========================================================
# 8. Literature Review (minimum 2 pages)
# =========================================================
add_heading("8.  Literature Review Report — Existing System Related to Work Done", level=1, size=13)
add_body("Introduction & Scope", size=11, bold=True, color=RGBColor(0x0B,0x2E,0x8A))
add_body("This literature review examines existing systems, architectures, and practices relevant to the Software Engineering Job Simulation at Commonwealth Bank. The review spans banking-grade microservice ecosystems, frontend state management in large-scale web applications, and quality assurance practices in regulated environments. At least two pages of synthesis are provided to contextualize the simulation work within broader industry literature.")
add_body("Objective: To understand how enterprise banks structure their technology landscapes, how legacy backends are incrementally modernized, and how testing and CI strategies sustain high availability and compliance.", size=9, italic=True, color=RGBColor(0x2C,0x3E,0x50))

add_subheading("8.1  Banking Microservice & Cloud-Native Architectures")
add_body("Commonwealth Bank, like many tier-1 financial institutions, has transitioned from monolithic core banking systems toward distributed, cloud-native microservices. Literature (Richardson, 2018; Newman, 2021) highlights patterns such as API gateways, service discovery, and circuit breakers that enable fault isolation and independent deployability. Backend work in the simulation—.NET APIs with dependency-injected services—aligns with these patterns: service layers abstract business rules, while controllers handle validation and HTTP concerns. Documented benefits include scalability under peak loads (e.g., end-of-month transactions) and security via token-based authentication and encrypted data at rest, both emphasized in the bank's security-first posture.")
add_body("Existing systems reviewed include CBA's CommBank app and NetBank platform, which handle millions of daily transactions. Case studies indicate that legacy integration remains a bottleneck; incremental strangler-fig refactoring—wrapping legacy modules behind new service facades—was directly practiced when modifying the existing .NET backend in Task 1 of the simulation. This approach, advocated by Fowler, reduces risk compared to big-bang rewrites and was mirrored by adding validation/logging without breaking established flows.")

add_subheading("8.2  Frontend State Management at Scale")
add_body("Large banking frontends require predictable state handling. Redux, as implemented in the simulation, originates from Flux architecture and is widely documented (Abramov & Clark, 2015) for centralized, immutable state. Literature notes that normalized state shapes and memoized selectors (e.g., Reselect) prevent unnecessary renders—precisely the challenge encountered when Redux state complexity grew. The simulation's solution (normalizing slices, optimizing selectors) reflects established best practice. Comparative reviews of alternatives (Context API, Zustand, MobX) suggest Redux remains preferred in enterprise where time-travel debugging and middleware (logging, error reporting) are critical for audit trails.")
add_body("Component testing via Jest and React Testing Library, as practiced, is supported by literature on shift-left testing (Meszaros, 2007). Component tests that interact with the UI as a user would—rather than testing implementation details—improve resilience to refactors, a principle applied when verifying Redux-connected components in the simulation.")

add_subheading("8.3  Data Persistence — Document vs Relational Models")
add_body("MongoDB, used in the simulation for flexible document storage, contrasts with traditional relational cores (Oracle/DB2) historically used in banking ledgers. Literature distinguishes transactional systems (ACID, strongly consistent) from engagement layers (profile, analytics) where document stores excel due to schema flexibility. The simulation's mock MongoDB repositories for student/transaction data exemplify this engagement-layer use case. Isolation in tests—substituting real persistence with in-memory fakes—is a recognized technique (Fowler, Test Double patterns) to achieve deterministic, fast feedback loops, directly applied when mocking data-access layers.")
add_body("Security literature further emphasizes encryption, field-level redaction, and audit logging for any customer data store, reinforcing the security-first lens applied to backend validation in the internship.")

add_subheading("8.4  Quality Assurance, CI/CD, and Collaboration")
add_body("Regulated financial delivery mandates high confidence. Literature on continuous integration (Duvall et al., 2007) identifies automated unit/integration tests, static analysis, and branch protection as prerequisites for compliance. The simulation's practice—authoring xUnit/Jest tests, integrating them into CI, and maintaining green pipelines—mirrors this. Test isolation via DI-friendly services reflects modern testability guidelines (Osherove, 2013).")
add_body("Git workflows and pull-request culture, central to Task 5, are extensively documented as enablers of knowledge sharing and defect prevention (Kalliamvakou et al., 2014). The simulation required clear PR descriptions, addressing reviewer feedback, and iterative refinement—behaviors correlated with faster merge rates and lower defect leakage in empirical studies of large open-source and enterprise repositories. Incremental delivery, another theme in the simulation, aligns with DevOps Research and Assessment (DORA) findings linking small-batch, frequent deployments to higher performance and stability.")

add_subheading("8.5  Gaps in Existing Systems & Simulation Relevance")
add_body("Existing banking systems often struggle with: (i) legacy code with implicit dependencies and sparse documentation, (ii) state synchronization across distributed frontends, and (iii) balancing cross-cutting concerns (logging, error handling) with feature velocity. The simulation exposed each gap in miniature, offering controlled experimentation. By applying typed interfaces, incremental refactors, and targeted tests, the approach demonstrated how academic concepts—clean architecture, SOLID principles, and test doubles—translate into pragmatic mitigation strategies.")
add_body("Furthermore, literature on socio-technical systems highlights collaboration as equally important as technical implementation. Practicing prompt iteration on PR feedback cultivated marshaling skills essential for geographically distributed banking engineering teams that coordinate across risk, compliance, and product divisions.")

add_subheading("8.6  Review Synthesis & Research Directions")
add_body("Synthesizing the review, the simulation's technology choices (.NET + React/Redux + MongoDB + Git/CI) are not arbitrary; they instantiate patterns validated by both literature and industry case studies of modern banking platforms. Future work, as noted in Section 6 (Next Steps), includes extending learnings to larger codebases and engaging in architecture discussions—directions supported by literature advocating mentorship and deliberate practice for novice engineers transitioning to enterprise contexts.")
add_body("In total, the review confirms that the internship tasks—backend modification, frontend state integration, test authoring, and PR-based collaboration—are microcosms of real production challenges in financial enterprises. The literature provides both justification for the methods used and a roadmap for deeper study: event-driven architectures, advanced security hardening, and observability at scale.", size=10)

# References
add_subheading("8.7  References (Indicative)")
refs = [
    "Richardson, C. (2018). Microservices Patterns. Manning.",
    "Newman, S. (2021). Building Microservices (2nd ed.). O'Reilly.",
    "Abramov, D. & Clark, A. (2015). Redux Documentation & Flux Architecture.",
    "Meszaros, G. (2007). xUnit Test Patterns. Addison-Wesley.",
    "Duvall, P., et al. (2007). Continuous Integration. Addison-Wesley.",
    "Osherove, R. (2013). The Art of Unit Testing.", 
    "Kalliamvakou, E., et al. (2014). The Promises and Perils of Mining GitHub. MSR.",
    "Fowler, M. Strangler Fig Application & Test Double Patterns. martinfowler.com.",
    "Commonwealth Bank — Technology & Engineering Insights (Public Engineering Blog & Forage Simulation Brief, 2026)."
]
for ref in refs:
    p=doc.add_paragraph(style='List Bullet')
    p.paragraph_format.space_after=Pt(1)
    r=p.add_run(ref)
    r.font.name='Times New Roman'; r.font.size=Pt(7); r.italic=True; r.font.color.rgb=RGBColor(0x2C,0x3E,0x50)

# =========================================================
# Closing - Thank You
# =========================================================
add_heading("Thank You", level=1, size=14, align=WD_ALIGN_PARAGRAPH.CENTER, space_before=Pt(18))
p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
p.paragraph_format.space_after=Pt(6)
r=p.add_run("Questions? I'm happy to discuss technical decisions, tests, or code samples from the simulation.")
r.font.name='Times New Roman'; r.font.size=Pt(10); r.italic=True; r.font.color.rgb=RGBColor(0x21,0x21,0x21)

p = doc.add_paragraph()
p.paragraph_format.space_before=Pt(8)
# Contact icon simulation with text
r=p.add_run("Contact:  ")
r.font.name='Times New Roman'; r.font.size=Pt(10); r.bold=True; r.font.color.rgb=RGBColor(0x0B,0x2E,0x8A)
r=p.add_run("Harsh Bhardwaj — Available on LinkedIn and email for follow-ups and technical interviews.")
r.font.name='Times New Roman'; r.font.size=Pt(9); r.font.color.rgb=RGBColor(0x21,0x21,0x21)

p = doc.add_paragraph()
r=p.add_run("Artifacts:  ")
r.font.name='Times New Roman'; r.font.size=Pt(10); r.bold=True; r.font.color.rgb=RGBColor(0x0B,0x2E,0x8A)
r=p.add_run("Code snippets, unit tests, and PRs can be shared on request for technical review.")
r.font.name='Times New Roman'; r.font.size=Pt(9); r.font.color.rgb=RGBColor(0x21,0x21,0x21)

# Footer note
p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
p.paragraph_format.space_before = Pt(18)
r = p.add_run("— End of Report —\nDepartment of Information Technology, KIET Group of Institutions, Delhi-NCR (Session 2026-27)")
r.font.name='Times New Roman'; r.font.size=Pt(8); r.italic=True; r.font.color.rgb=RGBColor(0x5D,0x6D,0x7E)

# Set footer with page numbers
section = doc.sections[1]
footer = section.footer
footer.is_linked_to_previous = False
p = footer.paragraphs[0]
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
r = p.add_run()
fldChar1 = OxmlElement('w:fldChar'); fldChar1.set(qn('w:fldCharType'), 'begin')
r._r.append(fldChar1)
r2 = p.add_run()
instr = OxmlElement('w:instrText')
instr.set(qn('xml:space'), 'preserve')
instr.text = 'PAGE'
r2._r.append(instr)
r3 = p.add_run()
fldChar2 = OxmlElement('w:fldChar'); fldChar2.set(qn('w:fldCharType'), 'end')
r3._r.append(fldChar2)
r = p.add_run("  |  Harsh Bhardwaj  |  202401100600083  |  KIET — IT B  |  Internship Report 2026-27")
r.font.name='Times New Roman'; r.font.size=Pt(7); r.font.color.rgb=RGBColor(0x5D,0x6D,0x7E)

doc.save(OUT)
print(f"Saved to {OUT}")
print(f"File exists: {os.path.exists(OUT)}")
