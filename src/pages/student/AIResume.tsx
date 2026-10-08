import { useEffect, useState } from "react";

import { useAuth } from "../../context/AuthContext";
import StudentLayout from "../../components/student/StudentLayout";
import type { StudentSidebarIconName } from "../../components/student/StudentSidebar";
import { getApiErrorMessage, studentApi, unwrapData } from "../../services/studentApi";

// ─── Icon System (subset needed on this page; same visual style as the rest of the app) ──
type IconName =
  | "dashboard"
  | "user-check"
  | "briefcase"
  | "clipboard"
  | "bell"
  | "award"
  | "building"
  | "notifications"
  | "settings"
  | "resume"
  | "sparkles"
  | "wand"
  | "plus"
  | "trash"
  | "download"
  | "copy"
  | "refresh"
  | "check"
  | "alert"
  | "graduation"
  | "target"
  | "link"
  | "layout"
  | "user"
  | "lightbulb"
  | "zap"
  | "interview"
  
  ;

const Icon = ({
  name,
  className = "h-4 w-4",
}: {
  name: IconName;
  className?: string;
}) => {
  const paths: Record<IconName, React.ReactNode> = {
    dashboard: (
      <>
        <rect x="3" y="3" width="7" height="7" rx="1.5" />
        <rect x="14" y="3" width="7" height="7" rx="1.5" />
        <rect x="3" y="14" width="7" height="7" rx="1.5" />
        <rect x="14" y="14" width="7" height="7" rx="1.5" />
      </>
    ),
    "user-check": (
      <>
        <path d="M15 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" />
        <circle cx="8.5" cy="7" r="4" />
        <path d="m16 11 2 2 4-5" />
      </>
    ),
    briefcase: (
      <>
        <path d="M9 7V5a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2v2" />
        <path d="M4 7h16v11a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V7Z" />
        <path d="M4 12h16" />
      </>
    ),
    clipboard: (
      <>
        <rect x="6" y="4" width="12" height="17" rx="2" />
        <path d="M9 4V3a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v1" />
        <path d="m9 12 2 2 4-4" />
      </>
    ),
    bell: (
      <>
        <path d="M18 9a6 6 0 0 0-12 0c0 7-3 7-3 7h18s-3 0-3-7" />
        <path d="M10 20a2 2 0 0 0 4 0" />
      </>
    ),
    award: (
      <>
        <circle cx="12" cy="8" r="6" />
        <path d="m9 13.5-1 7.5 4-2 4 2-1-7.5" />
      </>
    ),
    settings: (
      <>
        <circle cx="12" cy="12" r="3" />
        <path d="M19 12a7.5 7.5 0 0 0-.1-1.2l2-1.5-2-3.5-2.4 1a7.5 7.5 0 0 0-2-1.2L14.2 3h-4.4l-.3 2.6a7.5 7.5 0 0 0-2 1.2l-2.4-1-2 3.5 2 1.5A7.5 7.5 0 0 0 5 12c0 .4 0 .8.1 1.2l-2 1.5 2 3.5 2.4-1a7.5 7.5 0 0 0 2 1.2l.3 2.6h4.4l.3-2.6a7.5 7.5 0 0 0 2-1.2l2.4 1 2-3.5-2-1.5c.1-.4.1-.8.1-1.2Z" />
      </>
    ),
    resume: (
      <>
        <path d="M6 3h9l5 5v13a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2Z" />
        <path d="M14 3v5h5" />
        <path d="M8 13h8" />
        <path d="M8 17h6" />
      </>
    ),
    sparkles: (
      <>
        <path d="M12 3 10.5 8.5 5 10l5.5 1.5L12 17l1.5-5.5L19 10l-5.5-1.5L12 3Z" />
        <path d="M5 16v4" />
        <path d="M3 18h4" />
        <path d="M19 3v3" />
        <path d="M17.5 4.5h3" />
      </>
    ),
    wand: (
      <>
        <path d="m15 5 4 4" />
        <path d="M13 7 8.7 2.7a2.41 2.41 0 0 0-3.4 3.43L9.6 10.1" />
        <path d="m9.6 10.1-4.3 4.3a2.41 2.41 0 0 0 3.43 3.4L13 13.4" />
        <path d="m13 13.4 4.3 4.3a2.41 2.41 0 0 0 3.4-3.43L16.6 10" />
        <path d="m16.6 10 1.7-1.7" />
      </>
    ),
    plus: (
      <>
        <path d="M12 5v14" />
        <path d="M5 12h14" />
      </>
    ),
    building: (
      <>
        <path d="M5 21V5a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v16" />
        <path d="M3 21h18" />
        <path d="M9 7h1" />
        <path d="M14 7h1" />
        <path d="M9 11h1" />
        <path d="M14 11h1" />
      </>
    ),
    notifications: (
      <>
        <path d="M18 9a6 6 0 0 0-12 0c0 7-3 7-3 7h18s-3 0-3-7" />
        <path d="M10 20a2 2 0 0 0 4 0" />
      </>
    ),
    trash: (
      <>
        <path d="M4 7h16" />
        <path d="M9 7V4h6v3" />
        <path d="M6 7l1 13a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2l1-13" />
        <path d="M10 11v6" />
        <path d="M14 11v6" />
      </>
    ),
    download: (
      <>
        <path d="M12 3v12" />
        <path d="m7 11 5 5 5-5" />
        <path d="M4 19h16" />
      </>
    ),
    copy: (
      <>
        <rect x="9" y="9" width="12" height="12" rx="2" />
        <path d="M5 15V5a2 2 0 0 1 2-2h10" />
      </>
    ),
    refresh: (
      <>
        <path d="M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8" />
        <path d="M21 3v5h-5" />
        <path d="M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16" />
        <path d="M8 16H3v5" />
      </>
    ),
    check: (
      <>
        <path d="M21 12a9 9 0 1 1-5-8" />
        <path d="m9 12 2 2 6-7" />
      </>
    ),
    alert: (
      <>
        <path d="M12 4 3.5 18.5h17L12 4Z" />
        <path d="M12 9v4" />
        <path d="M12 16h.01" />
      </>
    ),
    graduation: (
      <>
        <path d="m22 10-10-5-10 5 10 5 10-5Z" />
        <path d="M6 12v5c3 2 9 2 12 0v-5" />
      </>
    ),
    target: (
      <>
        <circle cx="12" cy="12" r="8" />
        <circle cx="12" cy="12" r="4" />
        <path d="M12 2v3" />
        <path d="M12 19v3" />
        <path d="M2 12h3" />
        <path d="M19 12h3" />
      </>
    ),
    link: (
      <>
        <path d="M9 15 15 9" />
        <path d="M10.5 6.5 12 5a3.5 3.5 0 0 1 5 5l-1.5 1.5" />
        <path d="M13.5 17.5 12 19a3.5 3.5 0 0 1-5-5l1.5-1.5" />
      </>
    ),
    layout: (
      <>
        <rect x="3" y="3" width="18" height="18" rx="2" />
        <path d="M3 9h18" />
        <path d="M9 21V9" />
      </>
    ),
    user: (
      <>
        <circle cx="12" cy="8" r="4" />
        <path d="M4 21c0-4.4 3.6-7 8-7s8 2.6 8 7" />
      </>
    ),
    lightbulb: (
      <>
        <path d="M9 18h6" />
        <path d="M10 21h4" />
        <path d="M12 3a6 6 0 0 0-4 10.5c.6.5 1 1.3 1 2.1V16h6v-.4c0-.8.4-1.6 1-2.1A6 6 0 0 0 12 3Z" />
      </>
    ),
    zap: <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2" />,
    interview: (
      <>
        <rect x="4" y="4" width="16" height="16" rx="2" />
        <path d="M8 10h8" />
        <path d="M8 14h5" />
        <circle cx="18" cy="18" r="2" />
      </>
    ),
  };
  return (
    <svg
      className={className}
      fill="none"
      stroke="currentColor"
      strokeLinecap="round"
      strokeLinejoin="round"
      strokeWidth="2"
      viewBox="0 0 24 24"
      aria-hidden="true"
    >
      {paths[name]}
    </svg>
  );
};

// ─── small helpers ────────────────────────────────────────────────────────────
const getInitials = (name: string) =>
  name
    .trim()
    .split(/\s+/)
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2) || "YS";

const uid = () => Math.random().toString(36).slice(2, 9);


// ─── Sidebar (identical items/order to the rest of the student portal) ───────

const sidebarItems: Array<{
  label: string;
  icon: StudentSidebarIconName;
  route: string;
  badge?: number;
}> = [
  {
    label: "Dashboard",
    icon: "dashboard",
    route: "/student-dashboard",
  },
  {
    label: "My Profile",
    icon: "user-check",
    route: "/student/profile",
  },
  {
    label: "My Projects",
    icon: "briefcase",
    route: "/student/projects",
  },
  {
    label: "Applications",
    icon: "clipboard",
    route: "/student/applications",
    badge: 2,
  },
  {
    label: "Placement Prep",
    icon: "building",
    route: "/student/placementprep",
  },
  {
    label: "Notifications",
    icon: "bell",
    route: "/student/notifications",
    badge: 3,
  },
  {
    label: "Certificates",
    icon: "award",
    route: "/student/certificates",
  },
  {
    label: "Settings",
    icon: "settings",
    route: "/student/settings",
  },
  {
    label: "AI Resume",
    icon: "resume",
    route: "/student/ai-resume",
  },
  {
    label: "Career Roadmap",
    icon: "map",
    route: "/student/roadmap",
  },
  {
    label: "Career Updates",
    icon: "megaphone",
    route: "/student/broadcast",
  },
];
// ─── Types ────────────────────────────────────────────────────────────────────
interface EducationEntry {
  id: string;
  degree: string;
  institution: string;
  duration: string;
  gpa: string;
}
interface ExperienceEntry {
  id: string;
  role: string;
  organization: string;
  duration: string;
  bullets: string; // newline-separated, rendered as a bullet list
}
interface CertificationEntry {
  id: string;
  name: string;
  issuer: string;
  date: string;
}
interface ResumeData {
  fullName: string;
  title: string;
  email: string;
  phone: string;
  location: string;
  linkedin: string;
  github: string;
  targetRole: string;
  summary: string;
  skills: string[];
  education: EducationEntry[];
  experience: ExperienceEntry[];
  certifications: CertificationEntry[];
}

type Template = "modern" | "minimal";

interface AssistantExtraction {
  type: "experience" | "certification" | "skill";
  experience?: { role: string; organization: string; duration: string; bullets: string[] } | null;
  certification?: { name: string; issuer: string; date: string } | null;
  skills?: string[];
  confirmation: string;
}

// ─── Small shared bits ────────────────────────────────────────────────────────
const CardHeader = ({
  icon,
  iconColor,
  eyebrow,
  title,
  trailing,
}: {
  icon: IconName;
  iconColor: string;
  eyebrow: string;
  title: string;
  trailing?: React.ReactNode;
}) => (
  <div className="flex items-start justify-between gap-3">
    <div>
      <p className="text-[10px] font-bold uppercase tracking-widest text-slate-400">{eyebrow}</p>
      <h2 className="mt-0.5 flex items-center gap-2 text-base font-black text-slate-900">
        <span
          className="flex h-7 w-7 items-center justify-center rounded-lg"
          style={{ background: `${iconColor}14`, color: iconColor }}
        >
          <Icon name={icon} className="h-3.5 w-3.5" />
        </span>
        {title}
      </h2>
    </div>
    {trailing}
  </div>
);

const FieldLabel = ({ children }: { children: React.ReactNode }) => (
  <label className="mb-1 block text-[11px] font-semibold text-slate-500">{children}</label>
);

const inputCls =
  "w-full rounded-lg border border-slate-200 bg-white px-3 py-2 text-xs text-slate-700 placeholder-slate-400 outline-none transition focus:border-[#B99AFF] focus:ring-2 focus:ring-[#F4EFFF]";

const ghostBtnCls =
  "flex items-center justify-center gap-1.5 rounded-xl border border-dashed border-slate-200 py-2 text-xs font-bold text-slate-500 transition hover:border-[#B99AFF] hover:bg-[#F4EFFF] hover:text-[#5400D6]";

const primaryBtnCls =
  "flex items-center justify-center gap-1.5 rounded-xl bg-gradient-to-r from-[#5400D6] to-[#5400D6] px-4 py-2 text-xs font-bold text-white shadow-lg shadow-[#5400D6]/20 transition-all hover:shadow-[#5400D6]/30 active:scale-[0.98] disabled:opacity-50 disabled:shadow-none";

const emptyResumeData = (currentUser?: { fullName?: string; name?: string; email?: string; phone?: string }): ResumeData => ({
  fullName: currentUser?.fullName || currentUser?.name || "",
  title: "",
  email: currentUser?.email || "",
  phone: currentUser?.phone || "",
  location: "",
  linkedin: "",
  github: "",
  targetRole: "",
  summary: "",
  skills: [],
  education: [],
  experience: [{ id: uid(), role: "", organization: "", duration: "", bullets: "" }],
  certifications: [],
});

const normalizeResumeData = (resume: Partial<ResumeData>, fallback: ResumeData): ResumeData => ({
  ...fallback,
  ...resume,
  skills: Array.isArray(resume.skills) ? resume.skills : fallback.skills,
  education: (Array.isArray(resume.education) ? resume.education : fallback.education).map((entry) => ({
    id: entry.id || uid(),
    degree: entry.degree || "",
    institution: entry.institution || "",
    duration: entry.duration || "",
    gpa: entry.gpa || "",
  })),
  experience: (Array.isArray(resume.experience) && resume.experience.length ? resume.experience : fallback.experience).map((entry) => ({
    id: entry.id || uid(),
    role: entry.role || "",
    organization: entry.organization || "",
    duration: entry.duration || "",
    bullets: Array.isArray((entry as any).bullets) ? (entry as any).bullets.join("\n") : entry.bullets || "",
  })),
  certifications: (Array.isArray(resume.certifications) ? resume.certifications : fallback.certifications).map((entry) => ({
    id: entry.id || uid(),
    name: entry.name || "",
    issuer: entry.issuer || "",
    date: entry.date || "",
  })),
});

// ═══════════════════════════════════════════════════════════════════════════
// MAIN PAGE
// ═══════════════════════════════════════════════════════════════════════════
export const AIResumeBuilder = () => {
  const { currentUser } = useAuth();
  const fallbackResume = emptyResumeData(currentUser ?? undefined);
  const initials = getInitials(fallbackResume.fullName || "Student");

  const [data, setData] = useState<ResumeData>(fallbackResume);

  const [template, setTemplate] = useState<Template>("modern");
  const [skillInput, setSkillInput] = useState("");
  const [summaryLoading, setSummaryLoading] = useState(false);
  const [enhancingId, setEnhancingId] = useState<string | null>(null);
  const [error, setError] = useState("");
  const [loadingResume, setLoadingResume] = useState(true);
  const [savingResume, setSavingResume] = useState(false);
  const [resumeLoaded, setResumeLoaded] = useState(false);
  const [copied, setCopied] = useState(false);
  const [downloading, setDownloading] = useState(false);

  // ── AI assistant: "anything else to add?" ──
  const [assistantInput, setAssistantInput] = useState("");
  const [assistantLoading, setAssistantLoading] = useState(false);
  const [assistantNote, setAssistantNote] = useState("");

  useEffect(() => {
    let mounted = true;

    const loadResume = async () => {
      setLoadingResume(true);
      setError("");

      try {
        const response = await studentApi.getResumeBuilder();
        const payload = unwrapData<{ resume: Partial<ResumeData>; template?: Template }>(response);
        if (!mounted) return;

        setData(normalizeResumeData(payload.resume || {}, emptyResumeData(currentUser ?? undefined)));
        setTemplate(payload.template || "modern");
        setResumeLoaded(true);
      } catch (loadError) {
        if (mounted) {
          setError(getApiErrorMessage(loadError));
          setResumeLoaded(true);
        }
      } finally {
        if (mounted) setLoadingResume(false);
      }
    };

    loadResume();

    return () => {
      mounted = false;
    };
  }, [currentUser]);

  useEffect(() => {
    if (!resumeLoaded || loadingResume) return;

    const timeoutId = window.setTimeout(async () => {
      setSavingResume(true);
      try {
        await studentApi.saveResumeBuilder({ resume: data, template });
      } catch (saveError) {
        setError(getApiErrorMessage(saveError));
      } finally {
        setSavingResume(false);
      }
    }, 900);

    return () => window.clearTimeout(timeoutId);
  }, [data, template, resumeLoaded, loadingResume]);

  // ── derived: resume completeness score, shown in the header stat card ──
  const completeness = (() => {
    let score = 0;
    if (data.fullName.trim()) score += 10;
    if (data.email.trim() && data.phone.trim()) score += 10;
    if (data.summary.trim().length > 30) score += 20;
    if (data.skills.length >= 3) score += 20;
    if (data.education.some((e) => e.degree.trim())) score += 15;
    if (data.experience.some((e) => e.bullets.trim())) score += 15;
    if (data.certifications.length > 0) score += 10;
    return Math.min(score, 100);
  })();

  // ── field helpers ──
  const setField = <K extends keyof ResumeData>(key: K, value: ResumeData[K]) =>
    setData((d) => ({ ...d, [key]: value }));

  const addSkill = () => {
    const s = skillInput.trim();
    if (!s || data.skills.includes(s)) {
      setSkillInput("");
      return;
    }
    setField("skills", [...data.skills, s]);
    setSkillInput("");
  };
  const removeSkill = (s: string) => setField("skills", data.skills.filter((x) => x !== s));

  const addEducation = () =>
    setField("education", [...data.education, { id: uid(), degree: "", institution: "", duration: "", gpa: "" }]);
  const updateEducation = (id: string, field: keyof EducationEntry, value: string) =>
    setField("education", data.education.map((e) => (e.id === id ? { ...e, [field]: value } : e)));
  const removeEducation = (id: string) => setField("education", data.education.filter((e) => e.id !== id));

  const addExperience = () =>
    setField("experience", [...data.experience, { id: uid(), role: "", organization: "", duration: "", bullets: "" }]);
  const updateExperience = (id: string, field: keyof ExperienceEntry, value: string) =>
    setField("experience", data.experience.map((e) => (e.id === id ? { ...e, [field]: value } : e)));
  const removeExperience = (id: string) => setField("experience", data.experience.filter((e) => e.id !== id));

  const addCertification = () =>
    setField("certifications", [...data.certifications, { id: uid(), name: "", issuer: "", date: "" }]);
  const updateCertification = (id: string, field: keyof CertificationEntry, value: string) =>
    setField("certifications", data.certifications.map((c) => (c.id === id ? { ...c, [field]: value } : c)));
  const removeCertification = (id: string) =>
    setField("certifications", data.certifications.filter((c) => c.id !== id));

  // ── AI: generate professional summary ──
  const generateSummary = async () => {
    setSummaryLoading(true);
    setError("");
    try {
      const response = await studentApi.generateResumeSummary({
        prompt: `You write concise, ATS-friendly resume summaries for engineering students. Return ONLY valid JSON, no markdown, no backticks. Format: {"summary":"..."}

Rules:
- 2-3 sentences, under 45 words total
- No first person pronouns
- Confident, specific, no clichés like "hardworking" or "team player" alone

Candidate:
Name: ${data.fullName}
Target role: ${data.targetRole || "Software Engineering roles"}
Education: ${data.education.map((e) => `${e.degree} at ${e.institution}`).join("; ") || "Not specified"}
Skills: ${data.skills.join(", ") || "Not specified"}
Experience/projects: ${
          data.experience
            .filter((e) => e.role || e.bullets)
            .map((e) => `${e.role} — ${e.bullets.split("\n").filter(Boolean).join("; ")}`)
            .join(" | ") || "Not specified"
        }`,
      });
      const parsed = unwrapData<{ summary: string }>(response);
      setField("summary", parsed.summary);
    } catch {
      setError("Couldn't generate a summary. Please try again.");
    } finally {
      setSummaryLoading(false);
    }
  };

  // ── AI: enhance a single experience entry's bullet points ──
  const enhanceExperience = async (entry: ExperienceEntry) => {
    if (!entry.bullets.trim() && !entry.role.trim()) return;
    setEnhancingId(entry.id);
    setError("");
    try {
      const response = await studentApi.enhanceResumeExperience({
        prompt: `You rewrite rough notes into strong, ATS-friendly resume bullet points. Return ONLY valid JSON, no markdown, no backticks. Format: {"bullets":["...","..."]}

Rules:
- 3-4 bullets max
- Each starts with a strong action verb, past or present tense as appropriate
- Add plausible quantification only if implied by the notes — never invent specific numbers
- Each bullet under 20 words

Role: ${entry.role || "Not specified"}
Organization: ${entry.organization || "Not specified"}
Raw notes: ${entry.bullets || "Not specified"}`,
      });
      const parsed = unwrapData<{ bullets: string[] }>(response);
      updateExperience(entry.id, "bullets", parsed.bullets.join("\n"));
    } catch {
      setError("Couldn't enhance those bullet points. Please try again.");
    } finally {
      setEnhancingId(null);
    }
  };

  // ── AI assistant: classify a freeform note into the right resume section ──
  const addWithAI = async () => {
    const note = assistantInput.trim();
    if (!note) return;
    setAssistantLoading(true);
    setError("");
    setAssistantNote("");
    try {
      const response = await studentApi.classifyResumeNote({
        prompt: `You classify freeform notes into the right resume section. Return ONLY valid JSON, no markdown, no backticks. Format: {"type":"...","...":"...","confirmation":"..."}

Rules:  
- "type" must be exactly one of "experience", "certification", "skill"
- Use "experience" for internships, jobs, hackathons, or projects
- Use "certification" for courses, certificates, or credentials completed
- Use "skill" for standalone tools, technologies, or languages
- Only fill the object matching the chosen type; set the others to null or empty arrays
- bullets: 2-4 short resume-style bullets built from the note
- Do not invent metrics or credentials

Note: ${note}`,
      });
      const parsed = unwrapData<AssistantExtraction>(response);
      if (parsed.type === "experience" && parsed.experience) {
        setField("experience", [
          ...data.experience,
          {
            id: uid(),
            role: parsed.experience.role,
            organization: parsed.experience.organization,
            duration: parsed.experience.duration,
            bullets: parsed.experience.bullets.join("\n"),
          },
        ]);
      } else if (parsed.type === "certification" && parsed.certification) {
        setField("certifications", [...data.certifications, { id: uid(), ...parsed.certification }]);
      } else if (parsed.type === "skill" && parsed.skills?.length) {
        setField("skills", [...new Set([...data.skills, ...parsed.skills])]);
      }
      setAssistantNote(parsed.confirmation);
      setAssistantInput("");
    } catch {
      setError("Couldn't process that note. Please try again.");
    } finally {
      setAssistantLoading(false);
    }
  };

  // ── export: print-to-PDF via the browser's print dialog ──
  const downloadPDF = () => {
    setDownloading(true);
    setTimeout(() => {
      window.print();
      setDownloading(false);
    }, 500);
  };

  // ── export: plain-text copy ──
  const copyAsText = async () => {
    const lines: string[] = [
      data.fullName,
      data.title,
      [data.location, data.email, data.phone, data.linkedin, data.github].filter(Boolean).join(" | "),
      "",
      data.summary ? "SUMMARY\n" + data.summary : "",
      data.skills.length ? "\nSKILLS\n" + data.skills.join(", ") : "",
      data.education.length
        ? "\nEDUCATION\n" +
          data.education
            .map((e) => `${e.degree} — ${e.institution} (${e.duration})${e.gpa ? `, GPA ${e.gpa}` : ""}`)
            .join("\n")
        : "",
      data.experience.some((e) => e.role || e.bullets)
        ? "\nEXPERIENCE / PROJECTS\n" +
          data.experience
            .filter((e) => e.role || e.bullets)
            .map(
              (e) =>
                `${e.role} — ${e.organization} (${e.duration})\n${e.bullets
                  .split("\n")
                  .filter(Boolean)
                  .map((b) => `• ${b}`)
                  .join("\n")}`
            )
            .join("\n\n")
        : "",
      data.certifications.length
        ? "\nCERTIFICATIONS\n" +
          data.certifications.map((c) => `${c.name} — ${c.issuer} (${c.date})`).join("\n")
        : "",
    ].filter(Boolean);
    try {
      await navigator.clipboard.writeText(lines.join("\n"));
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch {
      setError("Couldn't copy to clipboard.");
    }
  };

  return (
    <StudentLayout
      sidebarItems={sidebarItems}
      sidebarHighlight="AI Resume Builder"
      userSummary={{
        fullName: data.fullName || "Student",
        role: data.title || "Student",
        status: "Placement track active",
      }}
      stats={{
        label: "Resume completeness",
        value: String(completeness),
        subtitle: template === "modern" ? "Modern template" : "Minimal / ATS template",
        accent: `${completeness}%`,
      }}
    >
      <div className="space-y-6">
        {/* print-only styling: hide everything except the resume when printing */}
        <style>{`
          @media print {
            body * { visibility: hidden; }
            #resume-print-root, #resume-print-root * { visibility: visible; }
            #resume-print-root { position: absolute; inset: 0; width: 100%; box-shadow: none !important; border: none !important; }
          }
          /* custom scrollbar for the preview pane */
          .preview-scroll::-webkit-scrollbar {
            width: 4px;
          }
          .preview-scroll::-webkit-scrollbar-track {
            background: #f1f5f9;
            border-radius: 8px;
          }
          .preview-scroll::-webkit-scrollbar-thumb {
            background: #cbd5e1;
            border-radius: 8px;
          }
          .preview-scroll::-webkit-scrollbar-thumb:hover {
            background: #94a3b8;
          }
        `}</style>

        {/* Hero */}
        <div className="relative overflow-hidden rounded-3xl border border-slate-200 bg-white p-8 shadow-sm">
          <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(#E9DDFF_1px,transparent_1px)] opacity-60 [background-size:18px_18px]" />
          <div className="pointer-events-none absolute right-0 top-0 h-56 w-56 rounded-full bg-[#E9DDFF]/60 blur-3xl" />
          <div className="pointer-events-none absolute -left-10 bottom-0 h-40 w-40 rounded-full bg-[#E9DDFF]/50 blur-3xl" />
          <div className="relative">
            <span className="inline-flex items-center gap-1.5 rounded-full border border-[#E9DDFF] bg-gradient-to-r from-[#F4EFFF] to-[#F4EFFF] px-3 py-1 text-[11px] font-bold text-[#5400D6] shadow-sm">
              <Icon name="sparkles" className="h-3 w-3" />
              AI-powered resume workspace
            </span>
            <h1 className="mt-4 text-3xl font-black tracking-tight text-slate-900 sm:text-4xl">
              AI Resume Builder
            </h1>
            <p className="mt-2.5 max-w-xl text-sm leading-6 text-slate-500">
              Your details are pulled in from your student profile. Sharpen the wording with AI,
              add anything that's missing, and export a recruiter-ready resume.
            </p>
          </div>
        </div>

        {error && (
          <div className="flex items-center gap-2 rounded-xl border border-rose-100 bg-rose-50 px-4 py-3 text-xs text-rose-600 shadow-sm">
            <Icon name="alert" className="h-3.5 w-3.5 flex-shrink-0" />
            {error}
          </div>
        )}
        {loadingResume && (
          <div className="flex items-center gap-2 rounded-xl border border-slate-200 bg-white px-4 py-3 text-xs text-slate-500 shadow-sm">
            <Icon name="refresh" className="h-3.5 w-3.5 flex-shrink-0 animate-spin" />
            Loading resume data...
          </div>
        )}
        {savingResume && (
          <div className="flex items-center gap-2 rounded-xl border border-[#E9DDFF] bg-[#F4EFFF] px-4 py-3 text-xs text-[#5400D6] shadow-sm">
            <Icon name="refresh" className="h-3.5 w-3.5 flex-shrink-0 animate-spin" />
            Saving resume...
          </div>
        )}

        {/* AI Import & Assistant — full width */}
        <section className="rounded-2xl border border-[#E9DDFF] bg-gradient-to-br from-[#F4EFFF]/60 via-white to-white p-6 shadow-sm">
          <CardHeader
            icon="sparkles"
            iconColor="#5400D6"
            eyebrow="AI Assistant"
            title="Imported from your student profile"
          />
          <div className="mt-4 flex flex-wrap gap-1.5">
            {[data.fullName, data.title, data.email, data.phone, data.location, data.linkedin, data.github, ...data.skills].map(
              (chip, i) =>
                chip && (
                  <span
                    key={i}
                    className="flex items-center gap-1 rounded-full bg-white px-2.5 py-1 text-[11px] font-semibold text-slate-600 ring-1 ring-slate-200"
                  >
                    <Icon name="check" className="h-3 w-3 text-emerald-500" />
                    {chip}
                  </span>
                )
            )}
          </div>

          <div className="mt-5 border-t border-[#E9DDFF]/70 pt-4">
            <p className="text-xs font-bold text-slate-700">Anything else to add?</p>
            <p className="mt-0.5 text-[11px] text-slate-500">
              Describe an internship, project, hackathon, or certification in your own words — AI will file
              it into the right section for you.
            </p>
            <div className="mt-3 flex flex-col gap-2 sm:flex-row">
              <input
                className={`${inputCls} flex-1`}
                value={assistantInput}
                onChange={(e) => setAssistantInput(e.target.value)}
                onKeyDown={(e) => e.key === "Enter" && (e.preventDefault(), addWithAI())}
                placeholder="e.g. Built an XGBoost churn model for ChurnZero 26 hackathon by IIT Kharagpur"
              />
              <button
                onClick={addWithAI}
                disabled={assistantLoading || !assistantInput.trim()}
                className={primaryBtnCls}
              >
                <Icon name={assistantLoading ? "refresh" : "wand"} className={`h-3.5 w-3.5 ${assistantLoading ? "animate-spin" : ""}`} />
                {assistantLoading ? "Filing…" : "Add to resume"}
              </button>
            </div>
            {assistantNote && (
              <div className="mt-3 flex items-center gap-2 rounded-lg bg-emerald-50 px-3 py-2 text-[11px] font-semibold text-emerald-700 ring-1 ring-emerald-100">
                <Icon name="check" className="h-3.5 w-3.5 flex-shrink-0" />
                {assistantNote}
              </div>
            )}
          </div>
        </section>

        {/* ── Two‑column layout: left scrolls, right is sticky ── */}
        <div className="grid grid-cols-1 gap-6 xl:grid-cols-2 xl:items-start">
          {/* ── LEFT: form ───────────────────────────────────────────── */}
          <div className="min-w-0 space-y-5">
            {/* Personal info */}
            <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm transition hover:shadow-md">
              <CardHeader icon="user" iconColor="#5400D6" eyebrow="Contact Details" title="Personal Info" />
              <div className="mt-4 grid grid-cols-1 gap-3 sm:grid-cols-2">
                <div>
                  <FieldLabel>Full name</FieldLabel>
                  <input className={inputCls} value={data.fullName} onChange={(e) => setField("fullName", e.target.value)} />
                </div>
                <div>
                  <FieldLabel>Headline / title</FieldLabel>
                  <input
                    className={inputCls}
                    value={data.title}
                    onChange={(e) => setField("title", e.target.value)}
                    placeholder="e.g. B.Tech CSE Student"
                  />
                </div>
                <div>
                  <FieldLabel>Email</FieldLabel>
                  <input className={inputCls} value={data.email} onChange={(e) => setField("email", e.target.value)} />
                </div>
                <div>
                  <FieldLabel>Phone</FieldLabel>
                  <input className={inputCls} value={data.phone} onChange={(e) => setField("phone", e.target.value)} />
                </div>
                <div>
                  <FieldLabel>Location</FieldLabel>
                  <input className={inputCls} value={data.location} onChange={(e) => setField("location", e.target.value)} />
                </div>
                <div>
                  <FieldLabel>Target role (optional)</FieldLabel>
                  <input
                    className={inputCls}
                    value={data.targetRole}
                    onChange={(e) => setField("targetRole", e.target.value)}
                    placeholder="e.g. Frontend Developer Intern"
                  />
                </div>
                <div>
                  <FieldLabel>LinkedIn</FieldLabel>
                  <input
                    className={inputCls}
                    value={data.linkedin}
                    onChange={(e) => setField("linkedin", e.target.value)}
                    placeholder="linkedin.com/in/…"
                  />
                </div>
                <div>
                  <FieldLabel>GitHub</FieldLabel>
                  <input
                    className={inputCls}
                    value={data.github}
                    onChange={(e) => setField("github", e.target.value)}
                    placeholder="github.com/…"
                  />
                </div>
              </div>
            </section>

            {/* Summary */}
            <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm transition hover:shadow-md">
              <CardHeader
                icon="sparkles"
                iconColor="#7C3AED"
                eyebrow="Professional Summary"
                title="Summary"
                trailing={
                  <button onClick={generateSummary} disabled={summaryLoading} className={primaryBtnCls}>
                    <Icon name={summaryLoading ? "refresh" : "wand"} className={`h-3.5 w-3.5 ${summaryLoading ? "animate-spin" : ""}`} />
                    {summaryLoading ? "Writing…" : data.summary ? "Regenerate" : "Generate with AI"}
                  </button>
                }
              />
              <textarea
                className={`${inputCls} mt-4 min-h-[96px] resize-none`}
                value={data.summary}
                onChange={(e) => setField("summary", e.target.value)}
                placeholder="A short, punchy summary of who you are and what you're aiming for — or let AI draft one from the rest of your form."
              />
            </section>

            {/* Skills */}
            <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm transition hover:shadow-md">
              <CardHeader icon="zap" iconColor="#f59e0b" eyebrow="Core Competencies" title="Skills" />
              <div className="mt-4 flex gap-2">
                <input
                  className={inputCls}
                  value={skillInput}
                  onChange={(e) => setSkillInput(e.target.value)}
                  onKeyDown={(e) => e.key === "Enter" && (e.preventDefault(), addSkill())}
                  placeholder="Type a skill and press Enter"
                />
                <button onClick={addSkill} className="flex-shrink-0 rounded-lg bg-slate-900 px-3 py-2 text-white transition hover:bg-slate-800">
                  <Icon name="plus" className="h-3.5 w-3.5" />
                </button>
              </div>
              <div className="mt-3 flex flex-wrap gap-1.5">
                {data.skills.map((s) => (
                  <span
                    key={s}
                    className="flex items-center gap-1.5 rounded-full bg-[#F4EFFF] py-1 pl-2.5 pr-1.5 text-[11px] font-semibold text-[#5400D6] ring-1 ring-[#E9DDFF]"
                  >
                    {s}
                    <button
                      onClick={() => removeSkill(s)}
                      className="flex h-3.5 w-3.5 items-center justify-center rounded-full text-[#8B5CF6] hover:bg-[#E9DDFF] hover:text-[#5400D6]"
                      aria-label={`Remove ${s}`}
                    >
                      ×
                    </button>
                  </span>
                ))}
                {data.skills.length === 0 && <p className="text-xs text-slate-400">No skills added yet.</p>}
              </div>
            </section>

            {/* Education */}
            <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm transition hover:shadow-md">
              <CardHeader icon="graduation" iconColor="#10b981" eyebrow="Academics" title="Education" />
              <div className="mt-4 space-y-3">
                {data.education.map((e) => (
                  <div key={e.id} className="rounded-xl border border-slate-100 bg-slate-50 p-4">
                    <div className="flex items-start justify-between gap-2">
                      <div className="grid min-w-0 flex-1 grid-cols-1 gap-2.5 sm:grid-cols-2">
                        <input className={inputCls} placeholder="Degree" value={e.degree} onChange={(ev) => updateEducation(e.id, "degree", ev.target.value)} />
                        <input className={inputCls} placeholder="Institution" value={e.institution} onChange={(ev) => updateEducation(e.id, "institution", ev.target.value)} />
                        <input className={inputCls} placeholder="Duration (e.g. 2023 – 2027)" value={e.duration} onChange={(ev) => updateEducation(e.id, "duration", ev.target.value)} />
                        <input className={inputCls} placeholder="CGPA / % (optional)" value={e.gpa} onChange={(ev) => updateEducation(e.id, "gpa", ev.target.value)} />
                      </div>
                      <button onClick={() => removeEducation(e.id)} className="flex-shrink-0 rounded-lg p-1.5 text-slate-400 transition hover:bg-rose-50 hover:text-rose-500" aria-label="Remove education entry">
                        <Icon name="trash" className="h-3.5 w-3.5" />
                      </button>
                    </div>
                  </div>
                ))}
                <button onClick={addEducation} className={`${ghostBtnCls} w-full`}>
                  <Icon name="plus" className="h-3.5 w-3.5" />
                  Add education
                </button>
              </div>
            </section>

            {/* Experience / Projects */}
            <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm transition hover:shadow-md">
              <CardHeader icon="briefcase" iconColor="#f43f5e" eyebrow="Work & Projects" title="Experience / Projects" />
              <div className="mt-4 space-y-3">
                {data.experience.map((e) => (
                  <div key={e.id} className="rounded-xl border border-slate-100 bg-slate-50 p-4">
                    <div className="flex items-start justify-between gap-2">
                      <div className="grid min-w-0 flex-1 grid-cols-1 gap-2.5 sm:grid-cols-2">
                        <input className={inputCls} placeholder="Role / project title" value={e.role} onChange={(ev) => updateExperience(e.id, "role", ev.target.value)} />
                        <input className={inputCls} placeholder="Organization" value={e.organization} onChange={(ev) => updateExperience(e.id, "organization", ev.target.value)} />
                        <input className={`${inputCls} sm:col-span-2`} placeholder="Duration (e.g. Jan 2026 – Present)" value={e.duration} onChange={(ev) => updateExperience(e.id, "duration", ev.target.value)} />
                      </div>
                      <button onClick={() => removeExperience(e.id)} className="flex-shrink-0 rounded-lg p-1.5 text-slate-400 transition hover:bg-rose-50 hover:text-rose-500" aria-label="Remove experience entry">
                        <Icon name="trash" className="h-3.5 w-3.5" />
                      </button>
                    </div>
                    <textarea
                      className={`${inputCls} mt-2.5 min-h-[70px] resize-none`}
                      placeholder="Rough notes, one per line — AI will turn these into strong bullet points"
                      value={e.bullets}
                      onChange={(ev) => updateExperience(e.id, "bullets", ev.target.value)}
                    />
                    <button
                      onClick={() => enhanceExperience(e)}
                      disabled={enhancingId === e.id}
                      className="mt-2 flex items-center gap-1.5 rounded-lg border border-slate-200 bg-white px-2.5 py-1.5 text-[11px] font-bold text-slate-600 transition hover:border-purple-200 hover:bg-purple-50 hover:text-purple-700 disabled:opacity-50"
                    >
                      <Icon name={enhancingId === e.id ? "refresh" : "wand"} className={`h-3 w-3 ${enhancingId === e.id ? "animate-spin" : ""}`} />
                      {enhancingId === e.id ? "Enhancing…" : "Enhance with AI"}
                    </button>
                  </div>
                ))}
                <button onClick={addExperience} className={`${ghostBtnCls} w-full`}>
                  <Icon name="plus" className="h-3.5 w-3.5" />
                  Add experience / project
                </button>
              </div>
            </section>

            {/* Certifications */}
            <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm transition hover:shadow-md">
              <CardHeader icon="award" iconColor="#5400D6" eyebrow="Credentials" title="Certifications" />
              <div className="mt-4 space-y-3">
                {data.certifications.map((c) => (
                  <div key={c.id} className="rounded-xl border border-slate-100 bg-slate-50 p-4">
                    <div className="flex items-start justify-between gap-2">
                      <div className="grid min-w-0 flex-1 grid-cols-1 gap-2.5 sm:grid-cols-3">
                        <input className={inputCls} placeholder="Certificate name" value={c.name} onChange={(ev) => updateCertification(c.id, "name", ev.target.value)} />
                        <input className={inputCls} placeholder="Issuer" value={c.issuer} onChange={(ev) => updateCertification(c.id, "issuer", ev.target.value)} />
                        <input className={inputCls} placeholder="Date" value={c.date} onChange={(ev) => updateCertification(c.id, "date", ev.target.value)} />
                      </div>
                      <button onClick={() => removeCertification(c.id)} className="flex-shrink-0 rounded-lg p-1.5 text-slate-400 transition hover:bg-rose-50 hover:text-rose-500" aria-label="Remove certification">
                        <Icon name="trash" className="h-3.5 w-3.5" />
                      </button>
                    </div>
                  </div>
                ))}
                <button onClick={addCertification} className={`${ghostBtnCls} w-full`}>
                  <Icon name="plus" className="h-3.5 w-3.5" />
                  Add certification
                </button>
              </div>
            </section>
          </div>

          {/* ── RIGHT: live preview (sticky, with independent scroll) ── */}
          <div className="min-w-0 space-y-4 xl:sticky xl:top-4 xl:self-start">
            <section className="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
              <div className="flex flex-wrap items-center justify-between gap-3">
                <div className="flex items-center gap-2">
                  <Icon name="layout" className="h-4 w-4 text-slate-400" />
                  <div className="flex rounded-lg border border-slate-200 p-0.5">
                    {(["modern", "minimal"] as Template[]).map((t) => (
                      <button
                        key={t}
                        onClick={() => setTemplate(t)}
                        className={`rounded-md px-3 py-1.5 text-[11px] font-bold capitalize transition ${
                          template === t ? "bg-slate-900 text-white" : "text-slate-500 hover:bg-slate-50"
                        }`}
                      >
                        {t}
                      </button>
                    ))}
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <button onClick={copyAsText} className="flex items-center gap-1.5 rounded-lg border border-slate-200 px-3 py-1.5 text-[11px] font-bold text-slate-600 transition hover:bg-slate-50">
                    <Icon name={copied ? "check" : "copy"} className="h-3.5 w-3.5" />
                    {copied ? "Copied" : "Copy text"}
                  </button>
                  <button onClick={downloadPDF} disabled={downloading} className={primaryBtnCls}>
                    <Icon name={downloading ? "refresh" : "download"} className={`h-3.5 w-3.5 ${downloading ? "animate-spin" : ""}`} />
                    {downloading ? "Preparing…" : "Download PDF"}
                  </button>
                </div>
              </div>
            </section>

            {/* Preview container with scroll */}
            <div className="preview-scroll max-h-[calc(100vh-12rem)] overflow-y-auto rounded-2xl shadow-lg ring-1 ring-slate-900/5">
              <ResumePreview data={data} template={template} initials={initials} />
            </div>

            <div className="flex gap-2.5 rounded-xl border border-[#E9DDFF] bg-[#F4EFFF] p-4">
              <Icon name="lightbulb" className="mt-0.5 h-4 w-4 flex-shrink-0 text-[#6F2AE8]" />
              <p className="text-xs text-[#5400D6]">
                Keep it to one page. The <span className="font-semibold">Minimal</span> template is the
                safest choice for ATS screening; use <span className="font-semibold">Modern</span> when
                you know a human will read it first.
              </p>
            </div>
          </div>
        </div>
      </div>
    </StudentLayout>
  );
};

// ═══════════════════════════════════════════════════════════════════════════
// Live resume preview — two templates sharing the same data
// ═══════════════════════════════════════════════════════════════════════════
const ResumePreview = ({ data, template, initials }: { data: ResumeData; template: Template; initials: string }) => {
  const contactLine = [data.location, data.email, data.phone, data.linkedin, data.github].filter(Boolean).join("   •   ");
  const hasEducation = data.education.some((e) => e.degree || e.institution);
  const hasExperience = data.experience.some((e) => e.role || e.bullets);
  const hasCerts = data.certifications.some((c) => c.name);

  if (template === "minimal") {
    return (
      <div id="resume-print-root" className="mx-auto max-w-[720px] overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-md ring-1 ring-slate-900/5">
        <div className="h-1.5 w-full bg-gradient-to-r from-slate-800 via-slate-600 to-slate-800" />
        <div className="p-8 font-sans text-slate-900">
          <div className="text-center">
            <h1 className="text-2xl font-bold tracking-tight">{data.fullName || "Your Name"}</h1>
            <p className="mt-1 text-sm text-slate-600">{data.title}</p>
            {contactLine && <p className="mt-2 text-[11px] text-slate-500">{contactLine}</p>}
          </div>

          {data.summary && (
            <MinimalSection title="Summary">
              <p className="text-[12.5px] leading-relaxed text-slate-700">{data.summary}</p>
            </MinimalSection>
          )}

          {data.skills.length > 0 && (
            <MinimalSection title="Skills">
              <p className="text-[12.5px] text-slate-700">{data.skills.join(" • ")}</p>
            </MinimalSection>
          )}

          {hasEducation && (
            <MinimalSection title="Education">
              <div className="space-y-2">
                {data.education
                  .filter((e) => e.degree || e.institution)
                  .map((e) => (
                    <div key={e.id} className="flex items-baseline justify-between text-[12.5px]">
                      <span className="font-semibold">
                        {e.degree}
                        {e.institution ? `, ${e.institution}` : ""}
                        {e.gpa ? ` — GPA ${e.gpa}` : ""}
                      </span>
                      <span className="flex-shrink-0 text-slate-500">{e.duration}</span>
                    </div>
                  ))}
              </div>
            </MinimalSection>
          )}

          {hasExperience && (
            <MinimalSection title="Experience / Projects">
              <div className="space-y-3">
                {data.experience
                  .filter((e) => e.role || e.bullets)
                  .map((e) => (
                    <div key={e.id}>
                      <div className="flex items-baseline justify-between text-[12.5px]">
                        <span className="font-semibold">
                          {e.role}
                          {e.organization ? ` — ${e.organization}` : ""}
                        </span>
                        <span className="flex-shrink-0 text-slate-500">{e.duration}</span>
                      </div>
                      <ul className="mt-1 list-disc space-y-0.5 pl-4">
                        {e.bullets.split("\n").filter(Boolean).map((b, i) => (
                          <li key={i} className="text-[12px] leading-snug text-slate-700">{b}</li>
                        ))}
                      </ul>
                    </div>
                  ))}
              </div>
            </MinimalSection>
          )}

          {hasCerts && (
            <MinimalSection title="Certifications">
              <ul className="space-y-1">
                {data.certifications
                  .filter((c) => c.name)
                  .map((c) => (
                    <li key={c.id} className="flex items-baseline justify-between text-[12.5px] text-slate-700">
                      <span>
                        {c.name}
                        {c.issuer ? ` — ${c.issuer}` : ""}
                      </span>
                      <span className="flex-shrink-0 text-slate-500">{c.date}</span>
                    </li>
                  ))}
              </ul>
            </MinimalSection>
          )}
        </div>
      </div>
    );
  }

  // "modern" template
  return (
    <div id="resume-print-root" className="mx-auto max-w-[720px] overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-md ring-1 ring-slate-900/5">
      <div className="h-1.5 w-full bg-gradient-to-r from-[#6F2AE8] via-[#F4EFFF]0 to-purple-500" />
      <div className="bg-gradient-to-br from-slate-950 to-slate-900 p-7 text-white">
        <div className="flex items-center gap-4">
          <div className="flex h-14 w-14 flex-shrink-0 items-center justify-center rounded-full bg-white/10 text-lg font-black ring-1 ring-white/20">
            {initials}
          </div>
          <div>
            <h1 className="text-xl font-black tracking-tight">{data.fullName || "Your Name"}</h1>
            <p className="text-sm text-[#B99AFF]">{data.title}</p>
          </div>
        </div>
        {contactLine && (
          <div className="mt-4 flex flex-wrap gap-x-4 gap-y-1 text-[11px] text-slate-300">
            {contactLine.split("   •   ").map((c, i) => (
              <span key={i} className="flex items-center gap-1">
                <span className="h-1 w-1 rounded-full bg-[#8B5CF6]" />
                {c}
              </span>
            ))}
          </div>
        )}
      </div>

      <div className="space-y-5 p-7">
        {data.summary && (
          <ModernSection title="Summary">
            <p className="text-[12.5px] leading-relaxed text-slate-700">{data.summary}</p>
          </ModernSection>
        )}

        {data.skills.length > 0 && (
          <ModernSection title="Skills">
            <div className="flex flex-wrap gap-1.5">
              {data.skills.map((s) => (
                <span key={s} className="rounded-full bg-[#F4EFFF] px-2.5 py-1 text-[11px] font-semibold text-[#5400D6] ring-1 ring-[#E9DDFF]">
                  {s}
                </span>
              ))}
            </div>
          </ModernSection>
        )}

        {hasEducation && (
          <ModernSection title="Education">
            <div className="space-y-2.5">
              {data.education
                .filter((e) => e.degree || e.institution)
                .map((e) => (
                  <div key={e.id} className="flex items-baseline justify-between gap-3">
                    <div>
                      <p className="text-[12.5px] font-bold text-slate-900">{e.degree}</p>
                      <p className="text-[11px] text-slate-500">
                        {e.institution}
                        {e.gpa ? ` · GPA ${e.gpa}` : ""}
                      </p>
                    </div>
                    <span className="flex-shrink-0 text-[11px] font-semibold text-slate-400">{e.duration}</span>
                  </div>
                ))}
            </div>
          </ModernSection>
        )}

        {hasExperience && (
          <ModernSection title="Experience / Projects">
            <div className="space-y-4">
              {data.experience
                .filter((e) => e.role || e.bullets)
                .map((e) => (
                  <div key={e.id}>
                    <div className="flex items-baseline justify-between gap-3">
                      <p className="text-[12.5px] font-bold text-slate-900">
                        {e.role}
                        {e.organization && <span className="font-medium text-slate-500"> — {e.organization}</span>}
                      </p>
                      <span className="flex-shrink-0 text-[11px] font-semibold text-slate-400">{e.duration}</span>
                    </div>
                    <ul className="mt-1.5 space-y-1">
                      {e.bullets.split("\n").filter(Boolean).map((b, i) => (
                        <li key={i} className="flex items-start gap-2 text-[12px] leading-snug text-slate-700">
                          <span className="mt-1.5 h-1 w-1 flex-shrink-0 rounded-full bg-[#8B5CF6]" />
                          {b}
                        </li>
                      ))}
                    </ul>
                  </div>
                ))}
            </div>
          </ModernSection>
        )}

        {hasCerts && (
          <ModernSection title="Certifications">
            <div className="space-y-1.5">
              {data.certifications
                .filter((c) => c.name)
                .map((c) => (
                  <div key={c.id} className="flex items-baseline justify-between gap-3">
                    <p className="text-[12.5px] text-slate-700">
                      <span className="font-bold text-slate-900">{c.name}</span>
                      {c.issuer ? ` — ${c.issuer}` : ""}
                    </p>
                    <span className="flex-shrink-0 text-[11px] font-semibold text-slate-400">{c.date}</span>
                  </div>
                ))}
            </div>
          </ModernSection>
        )}
      </div>
    </div>
  );
};

const ModernSection = ({ title, children }: { title: string; children: React.ReactNode }) => (
  <div className="border-l-2 border-[#6F2AE8] pl-4">
    <p className="mb-2 text-[10px] font-bold uppercase tracking-widest text-slate-400">{title}</p>
    {children}
  </div>
);

const MinimalSection = ({ title, children }: { title: string; children: React.ReactNode }) => (
  <div className="mt-4">
    <p className="border-b border-slate-300 pb-1 text-[11px] font-bold uppercase tracking-widest text-slate-800">{title}</p>
    <div className="mt-2">{children}</div>
  </div>
);

export default AIResumeBuilder;