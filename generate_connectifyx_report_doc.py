import os
import docx
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn

def set_cell_background(cell, hex_color):
    """Set background color of a table cell."""
    shading_elm = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{hex_color}"/>')
    cell._tc.get_or_add_tcPr().append(shading_elm)

def set_cell_margins(cell, top=100, bottom=100, left=150, right=150):
    """Set inner margins (padding) for a table cell in twentieths of a point (dxa)."""
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = OxmlElement('w:tcMar')
    for m, val in [('top', top), ('bottom', bottom), ('left', left), ('right', right)]:
        node = OxmlElement(f'w:{m}')
        node.set(qn('w:w'), str(val))
        node.set(qn('w:type'), 'dxa')
        tcMar.append(node)
    tcPr.append(tcMar)

def set_table_borders(table, color="D1D5DB", sz="4", val="single"):
    """Set subtle modern borders for a table."""
    tblPr = table._tbl.tblPr
    borders = parse_xml(
        f'<w:tblBorders {nsdecls("w")}>'
        f'<w:top w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>'
        f'<w:bottom w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>'
        f'<w:insideH w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>'
        f'<w:insideV w:val="none"/>'
        f'<w:left w:val="none"/>'
        f'<w:right w:val="none"/>'
        f'</w:tblBorders>'
    )
    tblPr.append(borders)

def create_report():
    doc = Document()

    # Set page margins
    sections = doc.sections
    for section in sections:
        section.top_margin = Inches(0.8)
        section.bottom_margin = Inches(0.8)
        section.left_margin = Inches(0.8)
        section.right_margin = Inches(0.8)

    # Color Palette Constants
    PRIMARY_HEX = "1E3A8A"      # Deep Navy Blue
    SECONDARY_HEX = "0D9488"    # Teal Accent
    DARK_TEXT_HEX = "1F2937"    # Slate Gray
    MUTED_TEXT_HEX = "4B5563"   # Cool Gray
    HEADER_BG_HEX = "1E3A8A"    # Table Header Deep Blue
    ALT_ROW_BG = "F3F4F6"       # Light gray row

    COLOR_PRIMARY = RGBColor(30, 58, 138)
    COLOR_SECONDARY = RGBColor(13, 148, 136)
    COLOR_DARK = RGBColor(31, 41, 55)
    COLOR_MUTED = RGBColor(75, 85, 99)

    # Document Header / Banner Box
    title_p = doc.add_paragraph()
    title_p.paragraph_format.space_before = Pt(0)
    title_p.paragraph_format.space_after = Pt(2)
    title_run = title_p.add_run("CONNECTIFYX")
    title_run.font.name = "Arial"
    title_run.font.size = Pt(26)
    title_run.font.bold = True
    title_run.font.color.rgb = COLOR_PRIMARY

    sub_p = doc.add_paragraph()
    sub_p.paragraph_format.space_before = Pt(0)
    sub_p.paragraph_format.space_after = Pt(12)
    sub_run = sub_p.add_run("Unified Higher Education & Corporate Placement Ecosystem — Engineering Handover & Technical Specification")
    sub_run.font.name = "Arial"
    sub_run.font.size = Pt(13)
    sub_run.font.italic = True
    sub_run.font.color.rgb = COLOR_SECONDARY

    # Metadata Box Table
    meta_table = doc.add_table(rows=4, cols=2)
    meta_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    meta_table.autofit = False
    set_table_borders(meta_table, color="E5E7EB", sz="4")

    col_widths = [Inches(2.2), Inches(4.6)]
    metadata = [
        ("Project Title:", "CONNECTIFYX (Campus-to-Corporate Higher Education Platform)"),
        ("Classification:", "Engineering Handover, Architectural Blueprint & Developer Guide"),
        ("System Release:", "v2.4.0-Enterprise (React 19, Express 5, MongoDB, Gemini AI, Flutter)"),
        ("Target Audience:", "Incoming Software Engineers, Interns & System Architects")
    ]

    for row_idx, (label, val) in enumerate(metadata):
        row = meta_table.rows[row_idx]
        for c_idx, cell in enumerate(row.cells):
            cell.width = col_widths[c_idx]
            set_cell_margins(cell, top=80, bottom=80, left=120, right=120)
        
        # Label cell
        cell_lbl = row.cells[0]
        set_cell_background(cell_lbl, "F9FAFB")
        p_lbl = cell_lbl.paragraphs[0]
        p_lbl.paragraph_format.space_before = Pt(0)
        p_lbl.paragraph_format.space_after = Pt(0)
        r_lbl = p_lbl.add_run(label)
        r_lbl.font.name = "Arial"
        r_lbl.font.size = Pt(9.5)
        r_lbl.font.bold = True
        r_lbl.font.color.rgb = COLOR_PRIMARY

        # Value cell
        cell_val = row.cells[1]
        set_cell_background(cell_val, "FFFFFF")
        p_val = cell_val.paragraphs[0]
        p_val.paragraph_format.space_before = Pt(0)
        p_val.paragraph_format.space_after = Pt(0)
        r_val = p_val.add_run(val)
        r_val.font.name = "Arial"
        r_val.font.size = Pt(9.5)
        r_val.font.color.rgb = COLOR_DARK

    doc.add_paragraph().paragraph_format.space_after = Pt(8)

    def add_section_header(text, level=1):
        p = doc.add_paragraph()
        if level == 1:
            p.paragraph_format.space_before = Pt(16)
            p.paragraph_format.space_after = Pt(6)
            p.paragraph_format.keep_with_next = True
            run = p.add_run(text)
            run.font.name = "Arial"
            run.font.size = Pt(15)
            run.font.bold = True
            run.font.color.rgb = COLOR_PRIMARY
        elif level == 2:
            p.paragraph_format.space_before = Pt(12)
            p.paragraph_format.space_after = Pt(4)
            p.paragraph_format.keep_with_next = True
            run = p.add_run(text)
            run.font.name = "Arial"
            run.font.size = Pt(12)
            run.font.bold = True
            run.font.color.rgb = COLOR_SECONDARY
        elif level == 3:
            p.paragraph_format.space_before = Pt(8)
            p.paragraph_format.space_after = Pt(2)
            p.paragraph_format.keep_with_next = True
            run = p.add_run(text)
            run.font.name = "Arial"
            run.font.size = Pt(10.5)
            run.font.bold = True
            run.font.color.rgb = COLOR_DARK
        return p

    def add_body_p(text, bold_prefix=None, bullet=False):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(2)
        p.paragraph_format.space_after = Pt(4)
        p.paragraph_format.line_spacing = 1.15
        
        if bullet:
            p.paragraph_format.left_indent = Inches(0.25)
            dot = p.add_run("•  ")
            dot.font.name = "Arial"
            dot.font.size = Pt(10)
            dot.font.color.rgb = COLOR_SECONDARY
            dot.font.bold = True

        if bold_prefix:
            bp_run = p.add_run(bold_prefix)
            bp_run.font.name = "Arial"
            bp_run.font.size = Pt(10)
            bp_run.font.bold = True
            bp_run.font.color.rgb = COLOR_DARK

        body_run = p.add_run(text)
        body_run.font.name = "Arial"
        body_run.font.size = Pt(10)
        body_run.font.color.rgb = COLOR_DARK
        return p

    def create_styled_table(headers, rows_data, col_widths=None):
        table = doc.add_table(rows=len(rows_data) + 1, cols=len(headers))
        table.alignment = WD_TABLE_ALIGNMENT.CENTER
        table.autofit = False
        set_table_borders(table, color="CBD5E1", sz="4")

        # Header Row
        hdr_row = table.rows[0]
        for idx, h_text in enumerate(headers):
            cell = hdr_row.cells[idx]
            if col_widths and idx < len(col_widths):
                cell.width = col_widths[idx]
            set_cell_background(cell, HEADER_BG_HEX)
            set_cell_margins(cell, top=100, bottom=100, left=120, right=120)
            p = cell.paragraphs[0]
            p.paragraph_format.space_before = Pt(0)
            p.paragraph_format.space_after = Pt(0)
            run = p.add_run(h_text)
            run.font.name = "Arial"
            run.font.size = Pt(9.5)
            run.font.bold = True
            run.font.color.rgb = RGBColor(255, 255, 255)

        # Data Rows
        for r_idx, row_vals in enumerate(rows_data):
            row = table.rows[r_idx + 1]
            bg_color = ALT_ROW_BG if r_idx % 2 == 1 else "FFFFFF"
            for c_idx, val in enumerate(row_vals):
                cell = row.cells[c_idx]
                if col_widths and c_idx < len(col_widths):
                    cell.width = col_widths[c_idx]
                set_cell_background(cell, bg_color)
                set_cell_margins(cell, top=70, bottom=70, left=120, right=120)
                p = cell.paragraphs[0]
                p.paragraph_format.space_before = Pt(0)
                p.paragraph_format.space_after = Pt(0)
                run = p.add_run(str(val))
                run.font.name = "Arial"
                run.font.size = Pt(9)
                run.font.color.rgb = COLOR_DARK

        doc.add_paragraph().paragraph_format.space_after = Pt(6)
        return table

    # -------------------------------------------------------------
    # 1. Executive Summary & Product Vision
    # -------------------------------------------------------------
    add_section_header("1. Executive Summary & Product Vision", level=1)
    add_body_p("CONNECTIFYX is an enterprise-grade, multi-tenant digital placement, mentorship, and career readiness platform. It bridges the critical divide between higher education institutions (universities and colleges), engineering/management students, certified industry mentors, and corporate enterprise recruiters.")
    add_body_p("The platform modernizes university placement cell operations by consolidating fragmented email and spreadsheet workflows into a cohesive, role-protected ecosystem enriched with Google Gemini GenAI intelligence.")
    
    add_body_p("Core Problems Solved:", bold_prefix="Key Value Drivers: ")
    add_body_p(" Eliminates manual placement coordination through real-time drive registrations, eligibility filters, and instant offer management.", bold_prefix="1. Placement Cell Automation:", bullet=True)
    add_body_p(" Empowers students with AI-powered resume parsing, 5-day study plans, skill gap analysis, and interactive mock interviews.", bold_prefix="2. AI-Driven Employability Matrix:", bullet=True)
    add_body_p(" Provides recruiters with a Kanban-style hiring pipeline and transparent candidate dossiers featuring verified academic and project records.", bold_prefix="3. Transparent Corporate Pipeline:", bullet=True)
    add_body_p(" Equips college leadership with predictive placement forecasts and early warnings for at-risk candidates.", bold_prefix="4. Institutional Analytics & Governance:", bullet=True)

    # -------------------------------------------------------------
    # 2. Complete Technology Stack
    # -------------------------------------------------------------
    add_section_header("2. Comprehensive Technology Stack", level=1)
    add_body_p("CONNECTIFYX utilizes a modern, reactive, type-safe full-stack architecture:")

    tech_headers = ["Layer", "Technology", "Version / Spec", "Core Functionality"]
    tech_data = [
        ["Frontend Framework", "React", "^19.2.6", "Concurrent UI rendering and declarative component tree"],
        ["Type System", "TypeScript", "~6.0.2", "Strict static type safety across interfaces and props"],
        ["Frontend Bundler", "Vite", "^8.0.12", "High-speed ES modules dev server and optimized production build"],
        ["Styling Architecture", "Tailwind CSS", "^4.3.2", "Modern CSS variable design tokens and responsive styling"],
        ["UI Components & Icons", "Lucide React / Framer", "^1.24.0 / ^12.42.2", "Crisp iconography and fluid page micro-interactions"],
        ["Analytics Charts", "Recharts", "^3.9.2", "Placement statistics, department metrics, candidate funnels"],
        ["Client-Side Routing", "React Router DOM", "^7.18.0", "Declarative nested and protected route hierarchies"],
        ["Web Auth Provider", "Clerk React", "^5.61.8", "Enterprise social login, MFA, and user session management"],
        ["HTTP Client", "Axios", "^1.18.1", "Centralized interceptor client with automatic Bearer JWT injection"],
        ["Backend Runtime", "Node.js (ESM)", "v18+ / v20+", "Asynchronous non-blocking server execution environment"],
        ["API Framework", "Express.js", "^5.2.1", "High-performance REST API routing and middleware pipeline"],
        ["Database Layer", "MongoDB Atlas", "Cloud v7.0+", "Scalable NoSQL document persistence and indexing"],
        ["Object Data Modeling", "Mongoose", "^9.7.4", "Schema validation, virtual population, and query execution"],
        ["Artificial Intelligence", "Google GenAI SDK", "@google/genai ^2.18.0", "Model: gemini-2.5-flash for real-time JSON-schema evaluation"],
        ["Security & Cryptography", "JWT & Bcryptjs", "^9.0.3 / ^3.0.3", "Stateless authentication tokens and salted password hashing"],
        ["Mobile App Framework", "Flutter (Dart)", "^3.11.0 / BLoC", "Cross-platform iOS/Android mobile client with secure token keychain"]
    ]
    create_styled_table(tech_headers, tech_data, [Inches(1.5), Inches(1.3), Inches(1.3), Inches(2.7)])

    # -------------------------------------------------------------
    # 3. Detailed Architectural Modules & Features
    # -------------------------------------------------------------
    add_section_header("3. Architectural Modules & Functional Specifications", level=1)
    add_body_p("The CONNECTIFYX platform is architected into 5 distinct, role-governed user portals plus a native mobile application:")

    # 3.1 Student Portal
    add_section_header("3.1 🎓 Student Portal Module", level=2)
    add_body_p("Located in src/pages/student/ — Serves as the comprehensive cockpit for student career advancement.")
    student_features = [
        ("Employability Score Dashboard (StudentDashboard.tsx):", " Aggregates academics, verified coding skills, attendance, and project evaluations into a dynamic 0-100% placement readiness metric."),
        ("AI Resume Studio & ATS Analyzer (AIResume.tsx):", " Integrates with Google Gemini 2.5 Flash to scan raw resume content, calculate ATS match percentages, detect missing keywords, and suggest bullet optimizations."),
        ("AI Mock Interview & Hiring Simulation (HiringProcess.tsx / PlacementPrep.tsx):", " Simulates multi-round technical and behavioral interviews with dynamic question generation and real-time response grading."),
        ("Dynamic 5-Day Study Planner:", " Analyzes student profile gaps and generates customized day-by-day technical review schedules."),
        ("Project Showcase & Submissions (ProjectList.tsx / AppliedProjects.tsx):", " Allows students to explore verified industry capstones, submit GitHub links, and track mentor evaluations."),
        ("Job Drive Application Pipeline (Applications.tsx):", " Provides an active status tracker across application stages (Applied, Shortlisted, Technical Round, HR Round, Offer Letter Issued)."),
        ("Skill Roadmaps & Notifications (StudentRoadmap.tsx / Notifications.tsx):", " Curated learning tracks across Full-Stack, AI/ML, Cloud, and Cybersecurity with real-time campus drive broadcasts.")
    ]
    for title, desc in student_features:
        add_body_p(desc, bold_prefix=title, bullet=True)

    # 3.2 Recruiter Portal
    add_section_header("3.2 🏢 Recruiter Portal Module", level=2)
    add_body_p("Located in src/pages/recruiter/ — Built for corporate talent acquisition teams.")
    recruiter_features = [
        ("Recruiter Command Center (RecruiterDashboard.tsx):", " Tracks hiring drive KPIs, applicant pipelines, shortlisting velocity, and interview conversion ratios."),
        ("Campus Drive Job Creator (PostJob.tsx / MyJobPostings.tsx):", " Interface to post on-campus drives with CTC (LPA), minimum CGPA cutoffs, eligible branches, and bond parameters."),
        ("Candidate Dossier & Talent Discovery (CandidateDossier.tsx):", " Comprehensive candidate viewer displaying verified GitHub repos, LeetCode ratings, academic records, and AI readiness breakdown."),
        ("Hiring Pipeline Kanban (PipelineManagement.tsx):", " Interactive stage manager enabling recruiters to shortlist, schedule technical rounds, and extend offers with single-click actions."),
        ("Direct Messaging Center (Messages.tsx):", " Secure communication channel between corporate recruiters, prospective students, and college TPOs.")
    ]
    for title, desc in recruiter_features:
        add_body_p(desc, bold_prefix=title, bullet=True)

    # 3.3 College / TPO Portal
    add_section_header("3.3 🏛️ College / TPO (Training & Placement Officer) Portal", level=2)
    add_body_p("Located in src/pages/college/ & src/components/dashboard/college/ — Designed for placement leadership and faculty coordinators.")
    college_features = [
        ("Executive Placement Overview (CollegeDashboard.tsx):", " High-level visual telemetry displaying branch-wise placement percentages, median/average package metrics, and active recruiters."),
        ("Student Cohort Directory (StudentManagement.tsx):", " Full database search, filterable by branch, CGPA, backlogs, and placement status with one-click bulk CSV report export."),
        ("Corporate Drive Coordination (RecruiterManagement.tsx):", " Review and approve incoming recruiter drive requests, allocate interview slots, and verify issued student offers."),
        ("At-Risk Early Warning Diagnostic:", " Automatically flags unplaced students with low test scores, missing resumes, or poor mock interview results for targeted intervention."),
        ("Accreditation & AISHE Settings (Profile.tsx / Settings.tsx):", " Institutional profile management including AISHE code compliance, NAAC/NBA accreditation data, and placement cell staff governance.")
    ]
    for title, desc in college_features:
        add_body_p(desc, bold_prefix=title, bullet=True)

    # 3.4 Mentor Portal
    add_section_header("3.4 👨‍🏫 Mentor Portal Module", level=2)
    add_body_p("Located in src/pages/MentorDashboard.tsx — Tailored for industry coaches and alumni mentors.")
    mentor_features = [
        ("360° Employability Evaluation Matrix:", " Multi-axial rating framework assessing student technical depth, problem-solving, soft skills, and communication."),
        ("1-on-1 Mentorship Scheduler:", " Integrated session calendar for booking mock interviews, code reviews, and resume clinics."),
        ("Resource Repository Hub:", " Centralized library to upload and distribute company interview experiences, curated coding sheets, and resume templates."),
        ("Student Milestones & Task Tracker:", " Assign specific learning goals and monitor student submission progress in real-time.")
    ]
    for title, desc in mentor_features:
        add_body_p(desc, bold_prefix=title, bullet=True)

    # 3.5 Super Admin Portal
    add_section_header("3.5 🛡️ Super Admin Portal Module", level=2)
    add_body_p("Located in src/pages/admin/ & src/components/dashboard/admin/ — Provides overarching platform governance.")
    admin_features = [
        ("Platform-Wide User Governance (UserManagement.tsx):", " Complete administrative control to search, edit, ban, or modify roles across all students, recruiters, mentors, and colleges."),
        ("Institutional & Recruiter Verification Queue (VerificationQueue.tsx):", " KYB/KYC verification pipeline to approve newly registered colleges and validate corporate email domains."),
        ("Global Broadcast Engine (BroadcastControl.tsx):", " Emergency alert and placement announcement broadcasting system delivering notices across all portals."),
        ("Placement Oversight & Cross-College Analytics (PlacementOversight.tsx):", " Macro-economic placement analytics tracking salary distributions and industry hiring trends.")
    ]
    for title, desc in admin_features:
        add_body_p(desc, bold_prefix=title, bullet=True)

    # -------------------------------------------------------------
    # 4. Database Schema Specification
    # -------------------------------------------------------------
    add_section_header("4. Database Collections & Schema Architecture", level=1)
    add_body_p("The database architecture is implemented in MongoDB Atlas via Mongoose models in backend/src/models/:")

    schema_headers = ["Collection / Model", "Key Schema Fields", "Relationships & References", "Description"]
    schema_data = [
        [
            "Student (student.js)",
            "name, email, password, college, branch, semester, gpa, skills[], placementStatus, metrics{resumeScore, techScore, commScore}, certifications[]",
            "Referenced by Application, MentorEvaluation, MentorSession",
            "Stores student credentials, verified academic background, skills, and composite readiness scores."
        ],
        [
            "Company (company.js)",
            "companyName, website, industry, contactEmail, isVerified, logo, location",
            "Parent of Project / JobDrive",
            "Corporate recruiter entity profile with domain verification status."
        ],
        [
            "Project / JobDrive (project.js)",
            "title, companyId, role, packageLPA, eligibility{minGpa, allowedBranches[], maxBacklogs}, description, deadline, status",
            "Ref -> Company; Referenced by Application",
            "Campus placement drives and project openings posted by recruiters."
        ],
        [
            "Application (application.js)",
            "studentId, jobId, status ('Applied' | 'Shortlisted' | 'Technical Round' | 'HR Round' | 'Selected' | 'Rejected'), appliedAt, interviewDate",
            "Ref -> Student, Ref -> Project",
            "Tracks the complete lifecycle of a student's application through corporate hiring stages."
        ],
        [
            "College (college.js)",
            "collegeName, aisheCode, accreditation, verificationStatus, contactEmail, phone, departments[]",
            "Referenced by Student profiles",
            "Institutional profile holding university accreditation and verification credentials."
        ],
        [
            "MentorProfile (mentorProfile.js)",
            "name, email, company, role, expertise[], bio, rating, totalMentees",
            "Parent of MentorSession, MentorEvaluation",
            "Industry professional and alumni mentor profile information."
        ],
        [
            "MentorSession (mentorSession.js)",
            "mentorId, studentId, scheduledTime, topic, meetingLink, status ('Scheduled' | 'Completed' | 'Cancelled')",
            "Ref -> MentorProfile, Ref -> Student",
            "1-on-1 mentorship appointments and mock interview meeting logs."
        ],
        [
            "Admin (admin.js)",
            "email, password, role ('superadmin'), permissions[], lastLogin",
            "Standalone Auth",
            "Root governance account for platform administration and verification."
        ]
    ]
    create_styled_table(schema_headers, schema_data, [Inches(1.6), Inches(2.2), Inches(1.5), Inches(1.5)])

    # -------------------------------------------------------------
    # 5. REST API Endpoints Specification
    # -------------------------------------------------------------
    add_section_header("5. REST API Endpoints Specification", level=1)
    add_body_p("The backend API server operates on port 5000 under the /api/ prefix:")

    api_headers = ["Method", "Endpoint Path", "Controller / Handler", "Authentication Required", "Purpose"]
    api_data = [
        ["POST", "/api/auth/register", "studentController.register", "Public", "Student registration and profile initialization"],
        ["POST", "/api/auth/login", "studentController.login", "Public", "Student JWT authentication & credential verification"],
        ["GET", "/api/student/profile", "studentController.getProfile", "Bearer Token", "Fetch logged-in student details and readiness metrics"],
        ["PUT", "/api/student/profile", "studentController.updateProfile", "Bearer Token", "Update student bio, skills, academics, and projects"],
        ["GET", "/api/student/applications", "studentController.getApplications", "Bearer Token", "List all drives applied to by the authenticated student"],
        ["POST", "/api/student/apply/:jobId", "studentController.applyJob", "Bearer Token", "Submit formal application for an active campus drive"],
        ["POST", "/api/ai/resume-analyzer", "aiController.analyzeResume", "Bearer Token", "ATS resume analysis returning score, keywords, and tips"],
        ["POST", "/api/ai/study-plan", "aiController.getStudyPlan", "Bearer Token", "Generates personalized 5-day structured study roadmap"],
        ["POST", "/api/ai/skill-gap", "aiController.getSkillGap", "Bearer Token", "Calculates percentage match and missing skills for target role"],
        ["POST", "/api/ai/career-coach", "aiController.coachChat", "Bearer Token", "Natural language Q&A career and placement advisory"],
        ["POST", "/api/ai/interview-gen", "aiController.generateInterview", "Bearer Token", "Generates structured technical and HR mock interview rounds"],
        ["POST", "/api/ai/evaluate-answer", "aiController.evaluateAnswer", "Bearer Token", "Evaluates candidate answer text and grades technical depth"],
        ["POST", "/api/recruiter/jobs", "recruiterController.createJob", "Recruiter Auth", "Publish new corporate campus hiring drive"],
        ["GET", "/api/recruiter/jobs", "recruiterController.getMyJobs", "Recruiter Auth", "Retrieve all drives posted by the recruiter's organization"],
        ["GET", "/api/recruiter/pipeline/:jobId", "recruiterController.getPipeline", "Recruiter Auth", "Fetch candidate pipeline partitioned by round"],
        ["PATCH", "/api/recruiter/application/:id/status", "recruiterController.updateStatus", "Recruiter Auth", "Promote candidate status (e.g. to Technical, Offer)"],
        ["POST", "/api/mentor/sessions", "mentorController.createSession", "Mentor Auth", "Book mentorship slot and generate meeting link"],
        ["POST", "/api/mentor/evaluation", "mentorController.submitEvaluation", "Mentor Auth", "Save 360-degree student evaluation and feedback ratings"],
        ["POST", "/api/admin/login", "adminController.login", "Public", "Super Admin JWT authentication"],
        ["GET", "/api/admin/users", "adminController.getAllUsers", "Admin JWT", "Retrieve master user list across all 5 platform roles"],
        ["PATCH", "/api/admin/verify-entity", "adminController.verifyEntity", "Admin JWT", "Approve or reject college or corporate recruiter registration"]
    ]
    create_styled_table(api_headers, api_data, [Inches(0.8), Inches(2.2), Inches(1.6), Inches(1.0), Inches(1.2)])

    # -------------------------------------------------------------
    # 6. Developer Setup & Installation Guide
    # -------------------------------------------------------------
    add_section_header("6. Developer Setup & Installation Guide", level=1)
    add_body_p("Follow these exact steps to set up the CONNECTIFYX development environment on a new workstation:")

    add_body_p("Step 1: Environment Variables Configuration (.env)", bold_prefix="Configuration: ")
    add_body_p("Create a .env file in the project root directory with the following variables:")
    
    env_code = (
        "MONGO_URI=mongodb+srv://<username>:<password>@cluster0.mongodb.net/connectifyx?retryWrites=true&w=majority\n"
        "VITE_CLERK_PUBLISHABLE_KEY=pk_test_your_clerk_key_here\n"
        "GEMINI_API_KEY=your_gemini_api_key_here\n"
        "GEMINI_MODEL=gemini-2.5-flash\n"
        "ADMIN_EMAIL=admin@connectifyx.com\n"
        "ADMIN_PASSWORD=your_admin_secure_password\n"
        "JWT_ADMIN_SECRET=your_super_secret_admin_jwt_key_2026\n"
        "PORT=5000"
    )
    p_env = doc.add_paragraph()
    p_env.paragraph_format.left_indent = Inches(0.25)
    r_env = p_env.add_run(env_code)
    r_env.font.name = "Consolas"
    r_env.font.size = Pt(8.5)
    r_env.font.color.rgb = COLOR_DARK

    add_body_p("Step 2: Start the Backend API Server", bold_prefix="Backend Execution: ")
    p_cmd1 = doc.add_paragraph()
    p_cmd1.paragraph_format.left_indent = Inches(0.25)
    r_cmd1 = p_cmd1.add_run("cd backend\nnpm install\nnpm run dev")
    r_cmd1.font.name = "Consolas"
    r_cmd1.font.size = Pt(9)
    r_cmd1.font.bold = True
    r_cmd1.font.color.rgb = COLOR_PRIMARY
    add_body_p("Verify in terminal: 'Server running on port 5000' and 'MongoDB Connected Successfully'.")

    add_body_p("Step 3: Start the Frontend Web Client", bold_prefix="Frontend Execution: ")
    p_cmd2 = doc.add_paragraph()
    p_cmd2.paragraph_format.left_indent = Inches(0.25)
    r_cmd2 = p_cmd2.add_run("npm install\nnpm run dev")
    r_cmd2.font.name = "Consolas"
    r_cmd2.font.size = Pt(9)
    r_cmd2.font.bold = True
    r_cmd2.font.color.rgb = COLOR_PRIMARY
    add_body_p("Web application will be accessible at http://localhost:5173/ with hot-module-replacement (HMR).")

    # -------------------------------------------------------------
    # 7. Critical Onboarding Notes & Roadmap
    # -------------------------------------------------------------
    add_section_header("7. Critical Onboarding Notes & Engineering Roadmap", level=1)
    
    add_section_header("7.1 Architectural Gotchas", level=2)
    add_body_p(" All frontend API calls are routed through src/services/api.ts which defaults to baseURL: 'http://localhost:5000/api'. Always ensure the backend is running on port 5000.", bold_prefix="1. Port Alignment:", bullet=True)
    add_body_p(" Google Gemini GenAI calls enforce structured JSON output (responseMimeType: 'application/json'). When adding new prompts in backend/src/services/aiServices.js, ensure JSON parsing error handlers are maintained.", bold_prefix="2. Gemini JSON Mode:", bullet=True)
    add_body_p(" Public/Student routes use Clerk authentication, whereas Admin and College management routes use JWT authentication stored in localStorage.getItem('token').", bold_prefix="3. Dual Authentication Mechanism:", bullet=True)

    add_section_header("7.2 Priority Roadmap for Future Interns / Developers", level=2)
    roadmap_items = [
        ("Phase 1 — Real-Time WebSockets:", " Implement Socket.io to support real-time push alerts for drive application stage changes and instant recruiter chat."),
        ("Phase 2 — Automated Resume PDF Generator:", " Build an automated PDF resume generator with customizable ATS-friendly templates using Puppeteer or jsPDF."),
        ("Phase 3 — Video AI Mock Interviews:", " Integrate WebRTC audio/video capture with Whisper speech-to-text to evaluate vocal clarity, filler words, and pacing."),
        ("Phase 4 — Multi-Campus Benchmarking:", " Expand the Super Admin dashboard with benchmarking charts comparing placement velocity across regional universities.")
    ]
    for r_title, r_desc in roadmap_items:
        add_body_p(r_desc, bold_prefix=r_title, bullet=True)

    # Handover signoff paragraph
    doc.add_paragraph().paragraph_format.space_after = Pt(12)
    p_sign = doc.add_paragraph()
    p_sign.paragraph_format.space_before = Pt(12)
    p_sign.paragraph_format.space_after = Pt(0)
    r_sign = p_sign.add_run("Handover Authorized & Prepared for New Incoming Interns — CONNECTIFYX Engineering Team")
    r_sign.font.name = "Arial"
    r_sign.font.size = Pt(10)
    r_sign.font.bold = True
    r_sign.font.italic = True
    r_sign.font.color.rgb = COLOR_PRIMARY

    # Save document
    output_filename = "CONNECTIFYX_Complete_Engineering_Handover_Report.docx"
    doc.save(output_filename)
    print(f"Document successfully created: {os.path.abspath(output_filename)}")

if __name__ == "__main__":
    create_report()
