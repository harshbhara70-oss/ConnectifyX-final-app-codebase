import { useState, useEffect, useRef } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../../context/AuthContext";
import StudentLayout from "../../components/student/StudentLayout";
import type { StudentSidebarIconName } from "../../components/student/StudentSidebar";
import {
  getApiErrorMessage,
  studentApi,
  unwrapData,
  type StudentProfile,
} from "../../services/studentApi";

// ─── Icon System (matches Admin Dashboard) ────────────────────────────────────
type IconName =
  | "activity"
  | "alert"
  | "arrow-up"
  | "arrow-down"
  | "bell"
  | "briefcase"
  | "building"
  | "broadcast"
  | "calendar"
  | "chart"
  | "check"
  | "clock"
  | "dashboard"
  | "database"
  | "file"
  | "graduation"
  | "lock"
  | "plug"
  | "search"
  | "settings"
  | "shield"
  | "sparkles"
  | "target"
  | "user-check"
  | "users"
  | "ai-brain"
  | "placement"
  | "resume"
  | "interview"
  | "risk"
  | "campus"
  | "automation"
  | "monitor"
  | "send"
  | "refresh"
  | "close"
  | "chevron-right"
  | "wand"
  | "zap"
  | "trending-up"
  | "cpu"
  | "mail"
  | "phone"
  | "book"
  | "award"
  | "upload"
  | "eye"
  | "message"
  | "megaphone"
  | "chevron-down"
  | "lightbulb"
  | "clipboard"
  | "logout"
  | "map";

const Icon = ({
  name,
  className = "h-4 w-4",
}: {
  name: IconName;
  className?: string;
}) => {
  const paths: Record<IconName, React.ReactNode> = {
    activity: <path d="M4 12h3l2-6 4 12 2-6h5" />,
    alert: (
      <>
        <path d="M12 4 3.5 18.5h17L12 4Z" />
        <path d="M12 9v4" />
        <path d="M12 16h.01" />
      </>
    ),
    "arrow-up": (
      <>
        <path d="M7 17 17 7" />
        <path d="M9 7h8v8" />
      </>
    ),
    "arrow-down": (
      <>
        <path d="M7 7 17 17" />
        <path d="M17 9v8H9" />
      </>
    ),
    bell: (
      <>
        <path d="M18 9a6 6 0 0 0-12 0c0 7-3 7-3 7h18s-3 0-3-7" />
        <path d="M10 20a2 2 0 0 0 4 0" />
      </>
    ),
    briefcase: (
      <>
        <path d="M9 7V5a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2v2" />
        <path d="M4 7h16v11a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V7Z" />
        <path d="M4 12h16" />
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
    calendar: (
      <>
        <path d="M7 3v4" />
        <path d="M17 3v4" />
        <rect x="4" y="5" width="16" height="16" rx="2" />
        <path d="M4 10h16" />
      </>
    ),
    chart: (
      <>
        <path d="M4 19V5" />
        <path d="M4 19h16" />
        <path d="M8 16v-5" />
        <path d="M12 16V8" />
        <path d="M16 16v-7" />
      </>
    ),
    check: (
      <>
        <path d="M21 12a9 9 0 1 1-5-8" />
        <path d="m9 12 2 2 6-7" />
      </>
    ),
    clock: (
      <>
        <circle cx="12" cy="12" r="9" />
        <path d="M12 7v5l3 2" />
      </>
    ),
    dashboard: (
      <>
        <rect x="3" y="3" width="7" height="7" rx="1.5" />
        <rect x="14" y="3" width="7" height="7" rx="1.5" />
        <rect x="3" y="14" width="7" height="7" rx="1.5" />
        <rect x="14" y="14" width="7" height="7" rx="1.5" />
      </>
    ),
    database: (
      <>
        <ellipse cx="12" cy="5" rx="7" ry="3" />
        <path d="M5 5v7c0 1.7 3.1 3 7 3s7-1.3 7-3V5" />
        <path d="M5 12v7c0 1.7 3.1 3 7 3s7-1.3 7-3v-7" />
      </>
    ),
    file: (
      <>
        <path d="M14 3H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9Z" />
        <path d="M14 3v6h6" />
        <path d="M8 13h8" />
        <path d="M8 17h5" />
      </>
    ),
    graduation: (
      <>
        <path d="m22 10-10-5-10 5 10 5 10-5Z" />
        <path d="M6 12v5c3 2 9 2 12 0v-5" />
      </>
    ),
    lock: (
      <>
        <rect x="4" y="11" width="16" height="10" rx="2" />
        <path d="M8 11V8a4 4 0 0 1 8 0v3" />
      </>
    ),
    plug: (
      <>
        <path d="M8 3v5" />
        <path d="M16 3v5" />
        <path d="M6 8h12v4a6 6 0 0 1-12 0V8Z" />
        <path d="M12 18v3" />
      </>
    ),
    search: (
      <>
        <circle cx="11" cy="11" r="7" />
        <path d="m16 16 4 4" />
      </>
    ),
    settings: (
      <>
        <circle cx="12" cy="12" r="3" />
        <path d="M19 12a7.5 7.5 0 0 0-.1-1.2l2-1.5-2-3.5-2.4 1a7.5 7.5 0 0 0-2-1.2L14.2 3h-4.4l-.3 2.6a7.5 7.5 0 0 0-2 1.2l-2.4-1-2 3.5 2 1.5A7.5 7.5 0 0 0 5 12c0 .4 0 .8.1 1.2l-2 1.5 2 3.5 2.4-1a7.5 7.5 0 0 0 2 1.2l.3 2.6h4.4l.3-2.6a7.5 7.5 0 0 0 2-1.2l2.4 1 2-3.5-2-1.5c.1-.4.1-.8.1-1.2Z" />
      </>
    ),
    shield: (
      <>
        <path d="M12 3 20 6v6c0 5-3.4 8-8 9-4.6-1-8-4-8-9V6l8-3Z" />
        <path d="m9 12 2 2 4-5" />
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
    "user-check": (
      <>
        <path d="M15 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" />
        <circle cx="8.5" cy="7" r="4" />
        <path d="m16 11 2 2 4-5" />
      </>
    ),
    users: (
      <>
        <path d="M16 21v-2a4 4 0 0 0-4-4H7a4 4 0 0 0-4 4v2" />
        <circle cx="9.5" cy="7" r="4" />
        <path d="M22 21v-2a4 4 0 0 0-3-3.8" />
        <path d="M16 3.2a4 4 0 0 1 0 7.6" />
      </>
    ),
    "ai-brain": (
      <>
        <circle cx="12" cy="12" r="5" />
        <path d="M12 2v3M12 19v3M2 12h3M19 12h3" />
        <path d="m4.9 4.9 2.1 2.1M16.9 16.9l2.1 2.1M4.9 19.1l2.1-2.1M16.9 7.1l2.1-2.1" />
      </>
    ),
    placement: (
      <>
        <path d="M12 4v12" />
        <path d="m8 12 4-4 4 4" />
        <path d="M8 20h8" />
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
    interview: (
      <>
        <path d="M6 7h12v8H9l-3 3V7Z" />
        <path d="M8 5h8" />
      </>
    ),
    risk: (
      <>
        <path d="M12 3 3 19h18L12 3Z" />
        <path d="M12 9v4" />
        <path d="M12 17h.01" />
      </>
    ),
    campus: (
      <>
        <path d="M4 21V9l8-5 8 5v12" />
        <path d="M12 3v18" />
        <path d="M8 12h8" />
      </>
    ),
    automation: (
      <>
        <circle cx="12" cy="12" r="5" />
        <path d="M12 2v2M12 20v2M2 12h2M20 12h2" />
        <path d="m4.9 4.9 1.4 1.4M17.7 17.7l1.4 1.4M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4" />
      </>
    ),
    monitor: (
      <>
        <rect x="4" y="5" width="16" height="12" rx="2" />
        <path d="M8 21h8" />
        <path d="M12 17v4" />
      </>
    ),
    send: (
      <>
        <path d="m22 2-11 11" />
        <path d="m22 2-7 20-4-9-9-4 20-7z" />
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
    close: (
      <>
        <path d="M18 6 6 18" />
        <path d="m6 6 12 12" />
      </>
    ),
    "chevron-right": <path d="m9 18 6-6-6-6" />,
    wand: (
      <>
        <path d="m15 5 4 4" />
        <path d="M13 7 8.7 2.7a2.41 2.41 0 0 0-3.4 3.43L9.6 10.1" />
        <path d="m9.6 10.1-4.3 4.3a2.41 2.41 0 0 0 3.43 3.4L13 13.4" />
        <path d="m13 13.4 4.3 4.3a2.41 2.41 0 0 0 3.4-3.43L16.6 10" />
        <path d="m16.6 10 1.7-1.7" />
      </>
    ),
    zap: <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2" />,
    "trending-up": (
      <>
        <polyline points="22 7 13.5 15.5 8.5 10.5 2 17" />
        <polyline points="16 7 22 7 22 13" />
      </>
    ),
    cpu: (
      <>
        <rect x="4" y="4" width="16" height="16" rx="2" />
        <rect x="9" y="9" width="6" height="6" />
        <path d="M15 2v2M9 2v2M2 15h2M2 9h2M15 20v2M9 20v2M20 15h2M20 9h2" />
      </>
    ),
    mail: (
      <>
        <rect x="3" y="5" width="18" height="14" rx="2" />
        <path d="m3 7 9 6 9-6" />
      </>
    ),
    phone: <path d="M6.6 10.8a15.9 15.9 0 0 0 6.6 6.6l2.2-2.2c.3-.3.7-.4 1-.3 1.1.4 2.3.6 3.6.6.6 0 1 .4 1 1V21c0 .6-.4 1-1 1C10.6 22 2 13.4 2 3c0-.6.4-1 1-1h3.5c.6 0 1 .4 1 1 0 1.3.2 2.5.6 3.6.1.3 0 .7-.3 1L6.6 10.8Z" />,
    book: (
      <>
        <path d="M4 5a2 2 0 0 1 2-2h9v16H6a2 2 0 0 0-2 2V5Z" />
        <path d="M15 3h3a2 2 0 0 1 2 2v14a2 2 0 0 0-2-2h-3" />
      </>
    ),
    award: (
      <>
        <circle cx="12" cy="8" r="6" />
        <path d="m9 13.5-1 7.5 4-2 4 2-1-7.5" />
      </>
    ),
    upload: (
      <>
        <path d="M12 3v12" />
        <path d="m7 8 5-5 5 5" />
        <path d="M4 17v2a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-2" />
      </>
    ),
    eye: (
      <>
        <path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7Z" />
        <circle cx="12" cy="12" r="3" />
      </>
    ),
    message: <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v10Z" />,
    "chevron-down": <path d="m6 9 6 6 6-6" />,
    lightbulb: (
      <>
        <path d="M9 18h6" />
        <path d="M10 21h4" />
        <path d="M12 3a6 6 0 0 0-4 10.5c.6.5 1 1.3 1 2.1V16h6v-.4c0-.8.4-1.6 1-2.1A6 6 0 0 0 12 3Z" />
      </>
    ),
    clipboard: (
      <>
        <rect x="6" y="4" width="12" height="17" rx="2" />
        <path d="M9 4V3a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v1" />
        <path d="m9 12 2 2 4-4" />
      </>
    ),
    logout: (
      <>
        <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" />
        <path d="m16 17 5-5-5-5" />
        <path d="M21 12H9" />
      </>
    ),
    // AI Hiring
    megaphone: (
      <>
        <path d="m3 11 18-5v12L3 14v-3Z" />
        <path d="M11 15v5" />
        <path d="M7 16.2a4 4 0 0 0 4 3.8" />
      </>
    ),
    map: (
      <>
        <path d="m4 6 6-3 4 3 6-3v15l-6 3-4-3-6 3V6Z" />
        <path d="M10 3v15" />
        <path d="M14 6v15" />
      </>
    ),
    broadcast: (
      <>
        <circle cx="12" cy="12" r="2" />
        <path d="M8.5 16.5a6 6 0 0 1 0-9" />
        <path d="M15.5 7.5a6 6 0 0 1 0 9" />
        <path d="M5.5 19.5a10 10 0 0 1 0-15" />
        <path d="M18.5 4.5a10 10 0 0 1 0 15" />
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



const getInitials = (name: string) =>
  name
    .trim()
    .split(/\s+/)
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2) || "YS";

const buildStudentContext = (name: string) =>
  `Student: ${name}
Use the connected dashboard profile, learning, applications, and notification data when giving guidance.`;

// Shared hook: pulls the signed-in user (with sensible fallbacks) and derives
// everything the dashboard and AI features need from it.
const useStudentProfile = () => {
  const { currentUser, logout } = useAuth();
  const fullName = currentUser?.fullName || currentUser?.name || "Student";
  const firstName = fullName.split(" ")[0] || "Student";
  const initials = getInitials(fullName);
  const email = currentUser?.email || "";
  const phone = currentUser?.phone || "";
  const context = buildStudentContext(fullName);
  return { fullName, firstName, initials, email, phone, context, logout, currentUser };
};

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
const roadmapSteps = [
  {
    step: "01",
    title: "Profile Building",
    desc: "Secure, verified credentials.",
    icon: "user-check" as IconName,
  },
  {
    step: "02",
    title: "Skill Assessment",
    desc: "AI proctored baseline tests.",
    icon: "ai-brain" as IconName,
  },
  {
    step: "03",
    title: "Learning Roadmap",
    desc: "Curated targeted content.",
    icon: "book" as IconName,
  },
  {
    step: "04",
    title: "Mentorship",
    desc: "Mock trials & expert reviews.",
    icon: "users" as IconName,
  },
  {
    step: "05",
    title: "AI Matching",
    desc: "Vector matching active roles.",
    icon: "cpu" as IconName,
  },
  {
    step: "06",
    title: "Interview",
    desc: "Calendar scheduling.",
    icon: "calendar" as IconName,
  },
  {
    step: "07",
    title: "Placement",
    desc: "Final contract signing.",
    icon: "award" as IconName,
  },
];

const aiCoachTopics = [
  "How do I crack placement interviews?",
  "What should I focus on this week?",
  "Review my weak areas",
  "Predict my placement readiness",
];

const popularRoles = [
  "Frontend Developer",
  "Backend Developer",
  "Data Analyst",
  "Full Stack Developer",
];

// ─── Types ────────────────────────────────────────────────────────────────────
interface StudyDay {
  day: string;
  tasks: string[];
}
interface ProfileResult {
  score: number;
  strengths: string[];
  gaps: string[];
  tip: string;
}
interface ATSBreakdown {
  label: string;
  score: number;
}
interface ATSResult {
  score: number;
  title: string;
  description: string;
  breakdown: ATSBreakdown[];
  keywords_found: string[];
  keywords_missing: string[];
  tip: string;
}
interface SkillGapResult {
  match_score: number;
  role: string;
  summary: string;
  matched_skills: string[];
  missing_skills: { skill: string; priority: "High" | "Medium" | "Low" }[];
  suggested_modules: string[];
  tip: string;
}

interface DashboardModule {
  id?: string;
  title: string;
  category: string;
  progress: number;
  color: string;
}

interface DashboardActivity {
  id?: string;
  title: string;
  desc: string;
  date: string;
  tone: "High" | "Medium" | "Normal" | "Low" | string;
}

interface DashboardData {
  profile: StudentProfile;
  stats: {
    registeredCourses: number;
    completed: number;
    pending: number;
    certificates: number;
    appliedProjects: number;
    unreadNotifications: number;
    closingThisWeek: number;
    learningScore: number;
  };
  modules: DashboardModule[];
  performanceData: Array<{ month: string; score: number }>;
  upcomingActivities: DashboardActivity[];
}

// ─── Pulse dot ────────────────────────────────────────────────────────────────
const PulseDot = ({ color = "#10b981" }: { color?: string }) => (
  <span className="relative flex h-2 w-2">
    <span
      className="absolute inline-flex h-full w-full animate-ping rounded-full opacity-60"
      style={{ backgroundColor: color }}
    />
    <span
      className="relative inline-flex h-2 w-2 rounded-full"
      style={{ backgroundColor: color }}
    />
  </span>
);

// ─── Section header (matches admin card headers) ─────────────────────────────
const SectionHeader = ({
  eyebrow,
  title,
  sub,
  icon,
  iconColor = "#2563eb",
}: {
  eyebrow: string;
  title: string;
  sub?: string;
  icon: IconName;
  iconColor?: string;
}) => (
  <div className="flex items-start justify-between">
    <div>
      <p className="text-[10px] font-bold uppercase tracking-widest text-slate-400">
        {eyebrow}
      </p>
      <h2 className="mt-0.5 flex items-center gap-2 text-lg font-black text-slate-900">
        <span style={{ color: iconColor }}>
          <Icon name={icon} className="h-4 w-4" />
        </span>
        {title}
      </h2>
      {sub && <p className="mt-1 text-xs text-slate-400">{sub}</p>}
    </div>
    <span className="flex-shrink-0 rounded-full bg-blue-50 px-2 py-0.5 text-[10px] font-bold text-blue-700 ring-1 ring-blue-100">
      AI
    </span>
  </div>
);

// ═══════════════════════════════════════════════════════════════════════════
// FEATURE 1 — AI Smart Study Planner
// ═══════════════════════════════════════════════════════════════════════════
export const AIStudyPlanner = () => {
  const { context } = useStudentProfile();
  const [loading, setLoading] = useState(false);
  const [plan, setPlan] = useState<StudyDay[] | null>(null);
  const [error, setError] = useState("");
  const [generated, setGenerated] = useState(false);

  const generatePlan = async () => {
    setLoading(true);
    setError("");
    setPlan(null);
    try {
      const response = await studentApi.generateStudyPlan(context);

      const plan = unwrapData<StudyDay[]>(response);

      setPlan(plan);
      setGenerated(true);
    } catch (error) {
      setError(getApiErrorMessage(error));
    } finally {
      setLoading(false);
    }
  };
  

  return (
    <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
      <SectionHeader
        eyebrow="Study Planner"
        title="AI Smart Study Planner"
        icon="calendar"
        iconColor="#8b5cf6"
      />

      {!generated && !loading && (
        <div className="mt-4 flex items-center justify-between rounded-xl border border-slate-100 bg-slate-50 p-4">
          <div>
            <p className="text-xs font-bold text-slate-700">
              Generate your weekly study plan
            </p>
            <p className="mt-0.5 text-[11px] text-slate-400">
              AI-powered schedule based on your weak areas & deadlines
            </p>
          </div>
          <button
            onClick={generatePlan}
            className="ml-3 flex-shrink-0 rounded-xl bg-slate-900 px-3.5 py-2 text-xs font-bold text-white transition hover:bg-slate-800"
          >
            Generate
          </button>
        </div>
      )}

      {loading && (
        <div className="mt-4 flex items-center gap-3 rounded-xl border border-slate-100 bg-slate-50 px-4 py-3">
          <Icon
            name="refresh"
            className="h-4 w-4 flex-shrink-0 animate-spin text-purple-500"
          />
          <p className="text-xs text-slate-500">Creating your study plan…</p>
        </div>
      )}

      {error && (
        <div className="mt-3 flex items-center gap-2 rounded-lg border border-rose-100 bg-rose-50 px-3 py-2 text-xs text-rose-600">
          <Icon name="alert" className="h-3.5 w-3.5" />
          {error}
        </div>
      )}

      {plan && (
        <div className="mt-4 space-y-4">
          {plan.map((day) => (
            <div
              key={day.day}
              className="rounded-xl border border-slate-100 bg-slate-50 p-4"
            >
              <p className="text-xs font-bold text-slate-700">{day.day}</p>
              <ul className="mt-2 space-y-1.5">
                {day.tasks.map((task, i) => (
                  <li key={i} className="flex items-start gap-2 text-xs text-slate-600">
                    <span className="mt-0.5 flex h-4 w-4 flex-shrink-0 items-center justify-center rounded-full bg-purple-100 text-[9px] font-bold text-purple-700">
                      {i + 1}
                    </span>
                    {task}
                  </li>
                ))}
              </ul>
            </div>
          ))}
          <button
            onClick={generatePlan}
            className="flex w-full items-center justify-center gap-2 rounded-xl border border-slate-200 py-2 text-xs font-bold text-slate-600 transition hover:bg-slate-50"
          >
            <Icon name="refresh" className="h-3 w-3" />
            Regenerate plan
          </button>
        </div>
      )}
    </div>
  );
};

// ═══════════════════════════════════════════════════════════════════════════
// FEATURE 2 — AI Placement Readiness Analyzer
// ═══════════════════════════════════════════════════════════════════════════
export const AIProfileAnalyzer = () => {
  const { context } = useStudentProfile();
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<ProfileResult | null>(null);
  const [error, setError] = useState("");
  const [analyzed, setAnalyzed] = useState(false);

  const analyzeProfile = async () => {
    setLoading(true);
    setError("");
    setResult(null);
    try {
      const response = await studentApi.placementAnalysis(context);

      const result = unwrapData<ProfileResult>(response);

      setResult(result);
      setAnalyzed(true);
    } catch (error) {
      setError(getApiErrorMessage(error));
    } finally {
      setLoading(false);
    } 
  };


  const scoreColor = result
    ? result.score >= 75
      ? "#10b981"
      : result.score >= 50
        ? "#f59e0b"
        : "#ef4444"
    : "#2563eb";
  const circumference = 2 * Math.PI * 28;

  return (
    <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
      <SectionHeader
        eyebrow="Readiness Check"
        title="AI Placement Readiness Analyzer"
        icon="target"
        iconColor="#10b981"
      />

      {!analyzed && !loading && (
        <div className="mt-4 flex items-center justify-between rounded-xl border border-slate-100 bg-slate-50 p-4">
          <div>
            <p className="text-xs font-bold text-slate-700">
              Analyze your placement readiness
            </p>
            <p className="mt-0.5 text-[11px] text-slate-400">
              Get strengths, skill gaps & top priority action
            </p>
          </div>
          <button
            onClick={analyzeProfile}
            className="ml-3 flex-shrink-0 rounded-xl bg-slate-900 px-3.5 py-2 text-xs font-bold text-white transition hover:bg-slate-800"
          >
            Analyze now
          </button>
        </div>
      )}

      {loading && (
        <div className="mt-4 flex items-center gap-3 rounded-xl border border-slate-100 bg-slate-50 px-4 py-3">
          <Icon
            name="refresh"
            className="h-4 w-4 flex-shrink-0 animate-spin text-emerald-500"
          />
          <p className="text-xs text-slate-500">Analyzing your profile…</p>
        </div>
      )}

      {error && (
        <div className="mt-3 flex items-center gap-2 rounded-lg border border-rose-100 bg-rose-50 px-3 py-2 text-xs text-rose-600">
          <Icon name="alert" className="h-3.5 w-3.5" />
          {error}
        </div>
      )}

      {result && (
        <div className="mt-4 flex flex-col gap-6 sm:flex-row">
          <div className="flex flex-shrink-0 flex-col items-center justify-center">
            <svg width="72" height="72" viewBox="0 0 72 72">
              <circle
                cx="36"
                cy="36"
                r="28"
                fill="none"
                stroke="#f1f5f9"
                strokeWidth="6"
              />
              <circle
                cx="36"
                cy="36"
                r="28"
                fill="none"
                stroke={scoreColor}
                strokeWidth="6"
                strokeLinecap="round"
                strokeDasharray={circumference}
                strokeDashoffset={
                  circumference - (circumference * result.score) / 100
                }
                transform="rotate(-90 36 36)"
              />
            </svg>
            <p className="-mt-12 text-2xl font-black" style={{ color: scoreColor }}>
              {result.score}
            </p>
            <p className="mt-8 text-[10px] font-bold uppercase tracking-wider text-slate-400">
              Readiness
            </p>
          </div>

          <div className="flex-1 space-y-4">
            <div>
              <p className="mb-2 text-[10px] font-bold uppercase tracking-widest text-slate-400">
                Strengths
              </p>
              <div className="space-y-1.5">
                {result.strengths.map((s, i) => (
                  <div key={i} className="flex items-center gap-2 text-xs text-slate-600">
                    <Icon name="check" className="h-3.5 w-3.5 flex-shrink-0 text-emerald-500" />
                    {s}
                  </div>
                ))}
              </div>
            </div>
            <div>
              <p className="mb-2 text-[10px] font-bold uppercase tracking-widest text-slate-400">
                Skill gaps
              </p>
              <div className="space-y-1.5">
                {result.gaps.map((g, i) => (
                  <div key={i} className="flex items-center gap-2 text-xs text-slate-600">
                    <Icon name="alert" className="h-3.5 w-3.5 flex-shrink-0 text-amber-500" />
                    {g}
                  </div>
                ))}
              </div>
            </div>
            <div className="rounded-xl border border-blue-100 bg-blue-50 p-3">
              <p className="mb-1 text-[10px] font-bold uppercase tracking-widest text-blue-400">
                Top priority
              </p>
              <p className="text-xs font-medium text-blue-700">{result.tip}</p>
            </div>
          </div>
        </div>
      )}

      {analyzed && !loading && (
        <button
          onClick={analyzeProfile}
          className="mt-4 flex w-full items-center justify-center gap-1.5 rounded-xl border border-slate-200 py-2 text-xs font-bold text-slate-600 transition hover:bg-slate-50"
        >
          <Icon name="refresh" className="h-3 w-3" />
          Re-analyze profile
        </button>
      )}
    </div>
  );
};

// ═══════════════════════════════════════════════════════════════════════════
// FEATURE 3 — AI ATS Resume Scorer
// ═══════════════════════════════════════════════════════════════════════════
export const AIATSScorer = () => {
  const [fileName, setFileName] = useState("");
  const [fileContent, setFileContent] = useState("");
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<ATSResult | null>(null);
  const [error, setError] = useState("");
  const [isDragging, setIsDragging] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const processFile = (file: File) => {
    setFileName(file.name);
    setError("");
    const reader = new FileReader();
    reader.onload = (e) => setFileContent((e.target?.result as string) || "");
    reader.readAsText(file);
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(false);
    const file = e.dataTransfer.files?.[0];
    if (file) processFile(file);
  };

  const handleFileInput = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) processFile(file);
  };

  const analyze = async () => {
    if (!fileName) return;
    setLoading(true);
    setError("");
    setResult(null);
    const resumeText = fileContent
      ? fileContent.slice(0, 3000)
      : `No extractable text — filename: ${fileName}`;
    try {
      const response = await studentApi.atsScore(resumeText);

      const result = unwrapData<ATSResult>(response);

      setResult(result);
    } catch (error) {
      setError(getApiErrorMessage(error));
    } finally {
      setLoading(false);
    }
  };

  const reset = () => {
    setFileName("");
    setFileContent("");
    setResult(null);
    setError("");
    if (fileInputRef.current) fileInputRef.current.value = "";
  };

  const scoreHex = (s: number) =>
    s >= 75 ? "#10b981" : s >= 50 ? "#f59e0b" : "#ef4444";
  const scoreTag = (s: number) =>
    s >= 75
      ? { label: "ATS Friendly", cls: "bg-emerald-50 text-emerald-700 ring-emerald-100" }
      : s >= 50
        ? { label: "Needs Improvement", cls: "bg-amber-50 text-amber-700 ring-amber-100" }
        : { label: "Low ATS Score", cls: "bg-rose-50 text-rose-700 ring-rose-100" };

  const circumference = 2 * Math.PI * 32;

  return (
    <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
      <SectionHeader
        eyebrow="Resume Intelligence"
        title="AI ATS Resume Scorer"
        icon="resume"
        iconColor="#f59e0b"
      />

      {!loading && !result && (
        <>
          <div
            onClick={() => fileInputRef.current?.click()}
            onDragOver={(e) => {
              e.preventDefault();
              setIsDragging(true);
            }}
            onDragLeave={() => setIsDragging(false)}
            onDrop={handleDrop}
            className={`mt-4 cursor-pointer rounded-xl border-2 border-dashed p-6 text-center transition ${
              isDragging
                ? "border-amber-400 bg-amber-50"
                : fileName
                  ? "border-emerald-300 bg-emerald-50"
                  : "border-slate-200 bg-slate-50 hover:border-amber-300 hover:bg-amber-50"
            }`}
          >
            <div className="mx-auto mb-3 flex h-9 w-9 items-center justify-center rounded-xl bg-white ring-1 ring-slate-200">
              <Icon
                name="upload"
                className={`h-4 w-4 ${fileName ? "text-emerald-500" : "text-slate-400"}`}
              />
            </div>
            {fileName ? (
              <>
                <p className="text-xs font-bold text-emerald-700">{fileName}</p>
                <p className="mt-1 text-[11px] text-slate-400">Click to replace</p>
              </>
            ) : (
              <>
                <p className="text-xs font-bold text-slate-700">
                  Drop your resume here or click to browse
                </p>
                <p className="mt-1 text-[11px] text-slate-400">
                  PDF, TXT, DOC · Max 5 MB
                </p>
              </>
            )}
          </div>

          <input
            ref={fileInputRef}
            type="file"
            accept=".pdf,.txt,.doc,.docx"
            className="hidden"
            onChange={handleFileInput}
          />

          <button
            onClick={analyze}
            disabled={!fileName}
            className="mt-3 flex w-full items-center justify-center gap-2 rounded-xl bg-slate-900 py-2.5 text-xs font-bold text-white transition hover:bg-slate-800 disabled:cursor-not-allowed disabled:opacity-40"
          >
            <Icon name="sparkles" className="h-3.5 w-3.5" />
            Analyze resume
          </button>

          {error && (
            <div className="mt-3 flex items-center gap-2 rounded-lg border border-rose-100 bg-rose-50 px-3 py-2 text-xs text-rose-600">
              <Icon name="alert" className="h-3.5 w-3.5 flex-shrink-0" />
              {error}
            </div>
          )}
        </>
      )}

      {loading && (
        <div className="mt-4 flex flex-col items-center gap-2 py-8">
          <Icon name="refresh" className="h-5 w-5 animate-spin text-amber-500" />
          <p className="text-xs text-slate-400">
            Analyzing your resume against ATS criteria…
          </p>
        </div>
      )}

      {result && (
        <div className="mt-4 space-y-5">
          <div className="flex items-center gap-5">
            <div className="relative h-20 w-20 flex-shrink-0">
              <svg width="80" height="80" viewBox="0 0 80 80">
                <circle
                  cx="40"
                  cy="40"
                  r="32"
                  fill="none"
                  stroke="#f1f5f9"
                  strokeWidth="7"
                />
                <circle
                  cx="40"
                  cy="40"
                  r="32"
                  fill="none"
                  stroke={scoreHex(result.score)}
                  strokeWidth="7"
                  strokeLinecap="round"
                  strokeDasharray={circumference}
                  strokeDashoffset={
                    circumference - (circumference * result.score) / 100
                  }
                  transform="rotate(-90 40 40)"
                />
              </svg>
              <div className="absolute inset-0 flex flex-col items-center justify-center">
                <span className="text-xl font-black" style={{ color: scoreHex(result.score) }}>
                  {result.score}
                </span>
                <span className="text-[9px] text-slate-400">/ 100</span>
              </div>
            </div>
            <div>
              <p className="text-sm font-bold text-slate-900">{result.title}</p>
              <p className="mt-0.5 text-xs text-slate-500">{result.description}</p>
              <span
                className={`mt-2 inline-block rounded-full px-2.5 py-0.5 text-[10px] font-bold ring-1 ${scoreTag(result.score).cls}`}
              >
                {scoreTag(result.score).label}
              </span>
            </div>
          </div>

          <div>
            <p className="mb-3 text-[10px] font-bold uppercase tracking-widest text-slate-400">
              Score breakdown
            </p>
            <div className="grid grid-cols-1 gap-x-6 gap-y-3 sm:grid-cols-2">
              {result.breakdown.map((item, i) => (
                <div key={i}>
                  <div className="mb-1 flex justify-between">
                    <span className="text-[11px] text-slate-600">{item.label}</span>
                    <span className="text-[11px] font-bold text-slate-700">
                      {item.score}%
                    </span>
                  </div>
                  <div className="h-1.5 w-full overflow-hidden rounded-full bg-slate-100">
                    <div
                      className="h-1.5 rounded-full transition-all duration-500"
                      style={{
                        width: `${item.score}%`,
                        background: scoreHex(item.score),
                      }}
                    />
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
            <div>
              <p className="mb-2 text-[10px] font-bold uppercase tracking-widest text-slate-400">
                Keywords found
              </p>
              <div className="flex flex-wrap gap-1.5">
                {result.keywords_found.map((k, i) => (
                  <span
                    key={i}
                    className="rounded-full bg-emerald-50 px-2.5 py-1 text-[11px] font-semibold text-emerald-700 ring-1 ring-emerald-100"
                  >
                    {k}
                  </span>
                ))}
              </div>
            </div>
            <div>
              <p className="mb-2 text-[10px] font-bold uppercase tracking-widest text-slate-400">
                Keywords missing
              </p>
              <div className="flex flex-wrap gap-1.5">
                {result.keywords_missing.map((k, i) => (
                  <span
                    key={i}
                    className="rounded-full bg-rose-50 px-2.5 py-1 text-[11px] font-semibold text-rose-700 ring-1 ring-rose-100"
                  >
                    {k}
                  </span>
                ))}
              </div>
            </div>
          </div>

          <div className="flex gap-2.5 rounded-xl border border-blue-100 bg-blue-50 p-3">
            <Icon name="lightbulb" className="mt-0.5 h-4 w-4 flex-shrink-0 text-blue-500" />
            <div>
              <p className="mb-0.5 text-[10px] font-bold uppercase tracking-widest text-blue-400">
                Top recommendation
              </p>
              <p className="text-xs text-blue-700">{result.tip}</p>
            </div>
          </div>

          <div className="flex items-center gap-2 rounded-xl border border-slate-100 bg-slate-50 px-3 py-2">
            <Icon name="eye" className="h-3.5 w-3.5 flex-shrink-0 text-slate-400" />
            <p className="text-[11px] text-slate-400">
              This score is visible to <span className="font-semibold text-slate-500">you</span>,{" "}
              <span className="font-semibold text-slate-500">recruiters</span>, and{" "}
              <span className="font-semibold text-slate-500">admins</span> reviewing your profile.
            </p>
          </div>

          <button
            onClick={reset}
            className="flex w-full items-center justify-center gap-2 rounded-xl border border-slate-200 py-2 text-xs font-bold text-slate-600 transition hover:bg-slate-50"
          >
            <Icon name="refresh" className="h-3 w-3" />
            Score another resume
          </button>
        </div>
      )}
    </div>
  );
};

// ═══════════════════════════════════════════════════════════════════════════
// FEATURE 4 — AI Job Skills & Gap Analysis Matching
// ═══════════════════════════════════════════════════════════════════════════
export const AISkillGapAnalyzer = () => {
  const { context } = useStudentProfile();
  const [role, setRole] = useState("");
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<SkillGapResult | null>(null);
  const [error, setError] = useState("");

  const analyze = async (targetRole?: string) => {
    const roleToUse = (targetRole ?? role).trim();
    if (!roleToUse) return;
    setRole(roleToUse);
    setLoading(true);
    setError("");
    setResult(null);
    try {
      const response = await studentApi.skillGap(
        context,
        roleToUse
      );

      const result = unwrapData<SkillGapResult>(response);

      setResult(result);
    } catch (error) {
      setError(getApiErrorMessage(error));
    } finally {
      setLoading(false);
    }
  };

  const reset = () => {
    setResult(null);
    setError("");
    setRole("");
  };

  const scoreHex = result
    ? result.match_score >= 75
      ? "#10b981"
      : result.match_score >= 50
        ? "#f59e0b"
        : "#ef4444"
    : "#2563eb";
  const circumference = 2 * Math.PI * 28;

  const priorityCls = (p: string) =>
    p === "High"
      ? "bg-rose-50 text-rose-700 ring-rose-100"
      : p === "Medium"
        ? "bg-amber-50 text-amber-700 ring-amber-100"
        : "bg-slate-100 text-slate-600 ring-slate-200";

  return (
    <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
      <SectionHeader
        eyebrow="Job Matching"
        title="AI Job Skills & Gap Analysis"
        icon="target"
        iconColor="#f43f5e"
      />

      {!result && !loading && (
        <div className="mt-4 rounded-xl border border-slate-100 bg-slate-50 p-4">
          <div className="mb-3 flex items-center gap-2">
            <Icon name="briefcase" className="h-3.5 w-3.5 text-slate-400" />
            <p className="text-xs font-bold text-slate-700">
              Enter a target job role
            </p>
          </div>
          <div className="flex gap-2">
            <input
              type="text"
              value={role}
              onChange={(e) => setRole(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && analyze()}
              placeholder="e.g. Frontend Developer"
              className="flex-1 rounded-lg border border-slate-200 bg-white px-3 py-2.5 text-xs text-slate-700 placeholder-slate-400 outline-none focus:border-blue-300 focus:ring-2 focus:ring-blue-50"
            />
            <button
              onClick={() => analyze()}
              disabled={!role.trim()}
              className="flex-shrink-0 rounded-lg bg-slate-900 px-4 py-2.5 text-xs font-bold text-white transition hover:bg-slate-800 disabled:cursor-not-allowed disabled:opacity-40"
            >
              Analyze
            </button>
          </div>
          <div className="mt-3 flex flex-wrap gap-2">
            {popularRoles.map((r) => (
              <button
                key={r}
                onClick={() => analyze(r)}
                className="rounded-full border border-slate-200 bg-white px-2.5 py-1 text-[11px] font-semibold text-slate-500 transition hover:border-blue-200 hover:bg-blue-50 hover:text-blue-700"
              >
                {r}
              </button>
            ))}
          </div>
          {error && (
            <div className="mt-3 flex items-center gap-2 rounded-lg border border-rose-100 bg-rose-50 px-3 py-2 text-xs text-rose-600">
              <Icon name="alert" className="h-3.5 w-3.5 flex-shrink-0" />
              {error}
            </div>
          )}
        </div>
      )}

      {loading && (
        <div className="mt-4 flex items-center gap-3 rounded-xl border border-slate-100 bg-slate-50 px-4 py-3">
          <Icon
            name="refresh"
            className="h-4 w-4 flex-shrink-0 animate-spin text-rose-500"
          />
          <p className="text-xs text-slate-500">
            Matching your skills against {role}…
          </p>
        </div>
      )}

      {result && (
        <div className="mt-4 space-y-5">
          <div className="flex items-center gap-5">
            <div className="relative h-[72px] w-[72px] flex-shrink-0">
              <svg width="72" height="72" viewBox="0 0 72 72">
                <circle
                  cx="36"
                  cy="36"
                  r="28"
                  fill="none"
                  stroke="#f1f5f9"
                  strokeWidth="6"
                />
                <circle
                  cx="36"
                  cy="36"
                  r="28"
                  fill="none"
                  stroke={scoreHex}
                  strokeWidth="6"
                  strokeLinecap="round"
                  strokeDasharray={circumference}
                  strokeDashoffset={
                    circumference - (circumference * result.match_score) / 100
                  }
                  transform="rotate(-90 36 36)"
                />
              </svg>
              <div className="absolute inset-0 flex flex-col items-center justify-center">
                <span className="text-lg font-black" style={{ color: scoreHex }}>
                  {result.match_score}%
                </span>
              </div>
            </div>
            <div>
              <p className="text-sm font-bold text-slate-900">{result.role}</p>
              <p className="mt-0.5 text-xs text-slate-500">{result.summary}</p>
            </div>
          </div>

          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
            <div>
              <p className="mb-2 text-[10px] font-bold uppercase tracking-widest text-slate-400">
                Matched skills
              </p>
              <div className="flex flex-wrap gap-1.5">
                {result.matched_skills.map((s, i) => (
                  <span
                    key={i}
                    className="flex items-center gap-1 rounded-full bg-emerald-50 px-2.5 py-1 text-[11px] font-semibold text-emerald-700 ring-1 ring-emerald-100"
                  >
                    <Icon name="check" className="h-3 w-3" />
                    {s}
                  </span>
                ))}
              </div>
            </div>
            <div>
              <p className="mb-2 text-[10px] font-bold uppercase tracking-widest text-slate-400">
                Skill gaps
              </p>
              <div className="flex flex-col gap-1.5">
                {result.missing_skills.map((m, i) => (
                  <div
                    key={i}
                    className="flex items-center justify-between rounded-lg border border-slate-100 bg-slate-50 px-2.5 py-1.5 text-[11px]"
                  >
                    <span className="text-slate-700">{m.skill}</span>
                    <span
                      className={`rounded-full px-2 py-0.5 text-[10px] font-bold ring-1 ${priorityCls(m.priority)}`}
                    >
                      {m.priority}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          </div>

          <div>
            <p className="mb-2 text-[10px] font-bold uppercase tracking-widest text-slate-400">
              Suggested modules to close the gap
            </p>
            <div className="flex flex-wrap gap-1.5">
              {result.suggested_modules.map((m, i) => (
                <span
                  key={i}
                  className="rounded-full bg-blue-50 px-2.5 py-1 text-[11px] font-semibold text-blue-700 ring-1 ring-blue-100"
                >
                  {m}
                </span>
              ))}
            </div>
          </div>

          <div className="flex gap-2.5 rounded-xl border border-rose-100 bg-rose-50 p-3">
            <Icon name="lightbulb" className="mt-0.5 h-4 w-4 flex-shrink-0 text-rose-500" />
            <div>
              <p className="mb-0.5 text-[10px] font-bold uppercase tracking-widest text-rose-400">
                Top recommendation
              </p>
              <p className="text-xs text-rose-700">{result.tip}</p>
            </div>
          </div>

          <button
            onClick={reset}
            className="flex w-full items-center justify-center gap-2 rounded-xl border border-slate-200 py-2 text-xs font-bold text-slate-600 transition hover:bg-slate-50"
          >
            <Icon name="refresh" className="h-3 w-3" />
            Check another role
          </button>
        </div>
      )}
    </div>
  );
};

const BadgesSection = () => {
  const badges = [
    {
      title: "React Expert",
      icon: "⚛️",
      color: "from-blue-500 to-cyan-500",
      earned: true,
    },
    {
      title: "SQL Master",
      icon: "🗄️",
      color: "from-emerald-500 to-green-500",
      earned: true,
    },
    {
      title: "DSA Warrior",
      icon: "⚔️",
      color: "from-purple-500 to-indigo-500",
      earned: true,
    },
    {
      title: "Placement Ready",
      icon: "🎯",
      color: "from-orange-500 to-red-500",
      earned: false,
    },
    {
      title: "Top Performer",
      icon: "🏆",
      color: "from-yellow-400 to-orange-500",
      earned: false,
    },
    {
      title: "100 Day Streak",
      icon: "🔥",
      color: "from-pink-500 to-red-500",
      earned: false,
    },
  ];

  return (
    <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-[10px] font-bold uppercase tracking-widest text-slate-400">
            Achievements
          </p>
          <h2 className="mt-1 text-xl font-black text-slate-900">
            🏅 Badges & Achievements
          </h2>
          <p className="mt-1 text-sm text-slate-500">
            Unlock badges as you progress through your learning journey.
          </p>
        </div>
        <span className="rounded-full bg-blue-50 px-3 py-1 text-xs font-bold text-blue-700">
          3 / 6 Earned
        </span>
      </div>

      <div className="mt-6 grid grid-cols-2 gap-4 md:grid-cols-3 lg:grid-cols-6">
        {badges.map((badge, index) => (
          <div
            key={index}
            className={`rounded-2xl border p-4 text-center transition-all duration-300 hover:-translate-y-1 hover:shadow-lg ${
              badge.earned
                ? "border-slate-200 bg-white"
                : "border-dashed border-slate-200 bg-slate-50 opacity-60"
            }`}
          >
            <div
              className={`mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-gradient-to-br ${badge.color} text-3xl shadow-lg`}
            >
              {badge.icon}
            </div>
            <h3 className="mt-4 text-sm font-bold text-slate-900">
              {badge.title}
            </h3>
            <p
              className={`mt-2 text-xs font-semibold ${
                badge.earned ? "text-emerald-600" : "text-slate-400"
              }`}
            >
              {badge.earned ? "Unlocked" : "Locked"}
            </p>
          </div>
        ))}
      </div>
    </section>
  );
};

// ═══════════════════════════════════════════════════════════════════════════
// FEATURE 5 — Daily Streak
// ═══════════════════════════════════════════════════════════════════════════
const DailyStreak = () => (
  <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
    <div className="flex items-center justify-between">
      <div>
        <p className="text-[10px] font-bold uppercase tracking-widest text-slate-400">
          Productivity
        </p>
        <h2 className="mt-0.5 text-lg font-black text-slate-900">
          Daily Streak
        </h2>
      </div>
      <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-orange-50">
        <Icon name="zap" className="h-4 w-4 text-orange-500" />
      </div>
    </div>

    <div className="mt-4 grid gap-3 sm:grid-cols-2">
      <div className="rounded-xl border border-slate-100 bg-orange-50/60 p-4">
        <p className="text-[11px] font-semibold text-slate-500">Daily Streak</p>
        <p className="mt-1.5 text-2xl font-black text-orange-600">🔥 12 days</p>
      </div>
      <div className="rounded-xl border border-slate-100 bg-blue-50/60 p-4">
        <p className="text-[11px] font-semibold text-slate-500">Current project</p>
        <p className="mt-1.5 text-base font-bold text-slate-900">
          AI Resume Analyzer
        </p>
      </div>
    </div>

    <div className="mt-4 rounded-xl border border-slate-100 bg-slate-50 p-4">
      <div className="flex items-center justify-between text-xs">
        <span className="text-slate-500">Today&apos;s goal</span>
        <span className="font-semibold text-slate-700">
          Complete Module 4
        </span>
      </div>
      <div className="mt-3 flex items-center justify-between text-[11px] text-slate-500">
        <span>Progress</span>
        <span>2 / 3 tasks completed</span>
      </div>
      <div className="mt-1.5 h-1.5 overflow-hidden rounded-full bg-slate-200">
        <div className="h-1.5 w-2/3 rounded-full bg-gradient-to-r from-violet-600 to-blue-500" />
      </div>
    </div>

    <div className="mt-4 flex items-center justify-between rounded-xl border border-emerald-100 bg-emerald-50 p-4">
      <div>
        <p className="text-xs font-bold text-slate-900">XP earned today</p>
        <p className="mt-0.5 text-[11px] text-slate-500">Keep your streak alive</p>
      </div>
      <p className="text-2xl font-black text-emerald-600">+18 XP</p>
    </div>
  </section>
);

// ═══════════════════════════════════════════════════════════════════════════
// AI Career Coach — Chat Drawer (matches Admin's AIChatPanel)
// ═══════════════════════════════════════════════════════════════════════════
const AICareerCoachPanel = ({ onClose }: { onClose: () => void }) => {
  const { firstName, context } = useStudentProfile();
  const [messages, setMessages] = useState<
    { role: "user" | "assistant"; text: string }[]
  >([
    {
      role: "assistant",
      text: `Hi ${firstName}! I'm your AI Career Coach. I know your profile — ask me anything about placements, interviews, or your learning path.`,
    },
  ]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const bottomRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages, loading]);

  const send = async (text?: string) => {
    const userText = text ?? input.trim();
    if (!userText) return;
    setInput("");
    const history = [...messages, { role: "user" as const, text: userText }];
    setMessages(history);
    setLoading(true);
    try {
      const response = await studentApi.careerCoach(
        userText,
        context
      );
      const result = unwrapData<{ answer?: string } | string>(response);
      const answer = typeof result === "string" ? result : result.answer || "I couldn't generate a response right now.";

      setMessages((current) => [...current, { role: "assistant", text: answer }]);
    } catch (error) {
      setMessages((current) => [
        ...current,
        { role: "assistant", text: getApiErrorMessage(error) },
      ]);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex h-full flex-col">
      <div className="flex items-center justify-between border-b border-slate-800 p-4">
        <div className="flex items-center gap-2.5">
          <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-blue-500/20">
            <Icon name="ai-brain" className="h-4 w-4 text-blue-400" />
          </div>
          <div>
            <p className="text-sm font-bold text-white">AI Career Coach</p>
            <div className="flex items-center gap-1.5">
              <PulseDot color="#10b981" />
              <span className="text-[10px] text-emerald-400">Online</span>
            </div>
          </div>
        </div>
        <button
          onClick={onClose}
          className="rounded-lg p-1.5 text-slate-400 transition hover:bg-slate-800 hover:text-white"
        >
          <Icon name="close" className="h-4 w-4" />
        </button>
      </div>

      <div className="flex flex-wrap gap-1.5 border-b border-slate-800 p-3">
        {aiCoachTopics.map((t) => (
          <button
            key={t}
            onClick={() => send(t)}
            className="rounded-full border border-slate-700 px-2.5 py-1 text-[10px] font-semibold text-slate-300 transition hover:border-blue-500 hover:text-blue-400"
          >
            {t}
          </button>
        ))}
      </div>

      <div className="flex-1 space-y-3 overflow-y-auto p-4">
        {messages.map((m, i) => (
          <div
            key={i}
            className={`flex ${m.role === "user" ? "justify-end" : "justify-start"}`}
          >
            {m.role === "assistant" && (
              <div className="mr-2 mt-1 flex h-6 w-6 flex-shrink-0 items-center justify-center rounded-full bg-blue-500/20">
                <Icon name="sparkles" className="h-3 w-3 text-blue-400" />
              </div>
            )}
            <div
              className={`max-w-[85%] whitespace-pre-wrap rounded-2xl px-3.5 py-2.5 text-sm leading-relaxed ${
                m.role === "user"
                  ? "rounded-tr-sm bg-blue-600 text-white"
                  : "rounded-tl-sm bg-slate-800 text-slate-200"
              }`}
            >
              {m.text}
            </div>
          </div>
        ))}
        {loading && (
          <div className="flex justify-start">
            <div className="mr-2 mt-1 flex h-6 w-6 flex-shrink-0 items-center justify-center rounded-full bg-blue-500/20">
              <Icon name="sparkles" className="h-3 w-3 text-blue-400" />
            </div>
            <div className="rounded-2xl rounded-tl-sm bg-slate-800 px-4 py-3">
              <span className="flex gap-1">
                {[0, 1, 2].map((d) => (
                  <span
                    key={d}
                    className="h-1.5 w-1.5 animate-bounce rounded-full bg-blue-400"
                    style={{ animationDelay: `${d * 0.15}s` }}
                  />
                ))}
              </span>
            </div>
          </div>
        )}
        <div ref={bottomRef} />
      </div>

      <div className="border-t border-slate-800 p-3">
        <div className="flex items-center gap-2 rounded-xl bg-slate-800 px-3 py-2">
          <input
            className="flex-1 bg-transparent text-sm text-white placeholder-slate-500 outline-none"
            placeholder="Ask your career coach…"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && !e.shiftKey && send()}
          />
          <button
            onClick={() => send()}
            className="flex h-7 w-7 items-center justify-center rounded-lg bg-blue-600 text-white transition hover:bg-blue-500 disabled:opacity-40"
            disabled={loading || !input.trim()}
          >
            <Icon name="send" className="h-3.5 w-3.5" />
          </button>
        </div>
      </div>
    </div>
  );
};

// ═══════════════════════════════════════════════════════════════════════════
// MAIN DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════
export const StudentDashboard = () => {
  const navigate = useNavigate();
  const { fullName, firstName, currentUser } = useStudentProfile();
  const [aiOpen, setAiOpen] = useState(false);
  const [dashboard, setDashboard] = useState<DashboardData | null>(null);
  const [dashboardLoading, setDashboardLoading] = useState(true);
  const [dashboardError, setDashboardError] = useState("");

  useEffect(() => {
    let mounted = true;

    const loadDashboard = async () => {
      setDashboardLoading(true);
      setDashboardError("");

      try {
        const response = await studentApi.getDashboard();
        if (mounted) {
          setDashboard(unwrapData<DashboardData>(response));
        }
      } catch (error) {
        if (mounted) {
          setDashboardError(getApiErrorMessage(error));
          setDashboard(null);
        }
      } finally {
        if (mounted) {
          setDashboardLoading(false);
        }
      }
    };

    loadDashboard();

    return () => {
      mounted = false;
    };
  }, []);

  const profile = dashboard?.profile || currentUser;
  const semesterLabel = profile?.semester ? `Semester ${profile.semester}` : "Semester not added";
  const branchLabel = profile?.branch || "Branch not added";
  const roleLine = [branchLabel, semesterLabel].filter(Boolean).join(" · ");
  const learningScore = dashboard?.stats.learningScore ?? 0;
  const modules = dashboard?.modules ?? [];
  const upcomingActivities = dashboard?.upcomingActivities ?? [];

  const _stats = [
    {
      label: "Registered courses",
      value: String(dashboard?.stats.registeredCourses ?? 0),
      change: String(dashboard?.stats.registeredCourses ?? 0),
      up: true,
      icon: "book" as IconName,
      bg: "#EEF2FF",
    },
    {
      label: "Completed",
      value: String(dashboard?.stats.completed ?? 0),
      change: String(dashboard?.stats.completed ?? 0),
      up: true,
      icon: "check" as IconName,
      bg: "#ECFDF5",
    },
    {
      label: "Pending",
      value: String(dashboard?.stats.pending ?? 0),
      change: String(dashboard?.stats.pending ?? 0),
      up: false,
      icon: "clock" as IconName,
      bg: "#FFF7ED",
    },
    {
      label: "Certificates",
      value: String(dashboard?.stats.certificates ?? 0),
      change: String(dashboard?.stats.certificates ?? 0),
      up: true,
      icon: "award" as IconName,
      bg: "#F0FDFA",
    },
  ];
  void _stats;

  const recommendedItems = [
    {
      title: modules[0]?.title || "Modern UI Fundamentals",
      category: modules[0]?.category || "DESIGN",
      progress: modules[0]?.progress ?? 42,
      description: "Build stronger frontend skills with practical, placement-focused learning.",
      icon: "wand" as IconName,
    },
    {
      title: modules[1]?.title || "Distributed Systems 101",
      category: modules[1]?.category || "BACKEND",
      progress: modules[1]?.progress ?? 25,
      description: "Understand scalable systems, APIs, databases, and backend architecture.",
      icon: "database" as IconName,
    },
  ];

  const dashboardNotifications = [
    {
      title: "AI Review is ready!",
      description: "Your AI profile review is available to check.",
      tone: "purple",
      icon: "sparkles" as IconName,
      time: "2h ago",
    },
    {
      title: "New Badge Unlocked",
      description: "You completed a new learning milestone.",
      tone: "blue",
      icon: "award" as IconName,
      time: "1 hour ago",
    },
    {
      title: "Community Invite",
      description: "You were invited to join a student community.",
      tone: "slate",
      icon: "users" as IconName,
      time: "Yesterday",
    },
  ];

  return (
    <StudentLayout
      sidebarItems={sidebarItems}
      sidebarHighlight="Dashboard"
      userSummary={{
        fullName,
        role: roleLine,
        status: "Placement track active",
      }}
      stats={{
        label: "Overall progress",
        value: String(learningScore),
        subtitle: semesterLabel,
        accent: semesterLabel,
      }}
      showAiButton
      onAiButtonClick={() => setAiOpen(true)}
    >
      <div className="min-h-full bg-[#faf9fb]">
        <div className="mx-auto max-w-[1450px] space-y-5 px-4 py-5 sm:px-6 lg:px-8">

          {dashboardError && (
            <div className="flex items-center gap-3 rounded-xl border border-rose-200 bg-rose-50 px-4 py-3 text-xs font-semibold text-rose-700">
              <Icon name="alert" className="h-4 w-4 flex-shrink-0" />
              {dashboardError}
            </div>
          )}

          {dashboardLoading && (
            <div className="flex items-center gap-3 rounded-xl border border-slate-200 bg-white px-4 py-3 text-xs font-semibold text-slate-500 shadow-sm">
              <Icon name="refresh" className="h-4 w-4 animate-spin text-purple-600" />
              Loading dashboard data...
            </div>
          )}

          <section className="rounded-2xl border border-purple-100 bg-white px-5 py-5 shadow-sm sm:px-7">
            <div className="flex flex-col gap-5 lg:flex-row lg:items-center lg:justify-between">
              <div>
                <div className="flex flex-wrap items-center gap-2">
                  <h1 className="text-2xl font-black tracking-tight text-slate-950 sm:text-[28px]">
                    Hey {firstName}, ready to level up today?
                  </h1>

                  <span className="inline-flex items-center gap-1.5 rounded-full bg-purple-50 px-2.5 py-1 text-[9px] font-bold text-purple-700 ring-1 ring-purple-100">
                    <Icon name="zap" className="h-3 w-3" />
                    12 Day Streak
                  </span>
                </div>

                <p className="mt-1 text-[11px] text-slate-400">
                  You're on the top 5% of active learners this week.
                </p>
              </div>

              <button
                type="button"
                onClick={() => setAiOpen(true)}
                className="inline-flex h-10 items-center justify-center gap-2 self-start rounded-lg bg-purple-700 px-5 text-[11px] font-bold text-white shadow-lg shadow-purple-200 transition hover:bg-purple-800 hover:shadow-purple-300 lg:self-center"
              >
                <Icon name="sparkles" className="h-3.5 w-3.5" />
                Start Quick Action
              </button>
            </div>
          </section>

          <section className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
            {[
              {
                label: "Roadmaps completed",
                value: `${learningScore}%`,
                icon: "map" as IconName,
                badge: "+4.2%",
                badgeClass: "bg-emerald-50 text-emerald-600",
              },
              {
                label: "Projects uploaded",
                value: String(dashboard?.stats.registeredCourses ?? 0),
                icon: "briefcase" as IconName,
                badge: "Milestone",
                badgeClass: "bg-purple-50 text-purple-600",
              },
              {
                label: "Applications sent",
                value: String(dashboard?.stats.appliedProjects ?? 0),
                icon: "send" as IconName,
                badge: `Pending ${dashboard?.stats.pending ?? 0}`,
                badgeClass: "bg-slate-100 text-slate-500",
              },
              {
                label: "AI reviews received",
                value: String(dashboard?.stats.certificates ?? 0),
                icon: "sparkles" as IconName,
                badge: `↗ ${learningScore}`,
                badgeClass: "bg-purple-50 text-purple-600",
              },
            ].map((item) => (
              <article
                key={item.label}
                className="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm transition hover:-translate-y-0.5 hover:border-purple-100 hover:shadow-md"
              >
                <div className="flex items-start justify-between">
                  <span className="flex h-9 w-9 items-center justify-center rounded-xl bg-purple-50 text-purple-600">
                    <Icon name={item.icon} className="h-4 w-4" />
                  </span>

                  <span className={`rounded-full px-2 py-1 text-[8px] font-bold ${item.badgeClass}`}>
                    {item.badge}
                  </span>
                </div>

                <p className="mt-3 text-[9px] font-bold uppercase tracking-[0.12em] text-slate-400">
                  {item.label}
                </p>

                <p className="mt-0.5 text-2xl font-black text-slate-950">
                  {item.value}
                </p>

                <div className="mt-2 h-1.5 overflow-hidden rounded-full bg-slate-100">
                  <div
                    className="h-full rounded-full bg-purple-600"
                    style={{ width: `${Math.min(100, Math.max(8, learningScore))}%` }}
                  />
                </div>
              </article>
            ))}
          </section>

          <div className="grid gap-5 xl:grid-cols-[minmax(0,1fr)_270px]">

            <div className="min-w-0 space-y-5">

              <section>
                <div className="mb-3 flex items-center justify-between">
                  <div>
                    <h2 className="text-base font-black text-slate-950">
                      Continue Where You Left Off
                    </h2>
                  </div>

                  <button
                    type="button"
                    onClick={() => navigate("/student/roadmap")}
                    className="flex items-center gap-1 text-[10px] font-bold text-purple-600 hover:text-purple-800"
                  >
                    View all learning
                    <Icon name="chevron-right" className="h-3 w-3" />
                  </button>
                </div>

                <div className="grid gap-4 md:grid-cols-2">
                  {(modules.length > 0 ? modules.slice(0, 2) : [
                    {
                      title: "Full Stack Developer",
                      category: "Next: Mastering Web Development",
                      progress: 72,
                      color: "#7c3aed",
                    },
                    {
                      title: "DSA Mastery",
                      category: "Next: Big O Notation and Array Manipulation",
                      progress: 38,
                      color: "#64748b",
                    },
                  ]).map((mod, index) => (
                    <article
                      key={`${mod.title}-${index}`}
                      className="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm"
                    >
                      <div className="flex items-start justify-between gap-3">
                        <span className="flex h-9 w-9 items-center justify-center rounded-xl bg-purple-50 text-purple-600">
                          <Icon
                            name={index === 0 ? "cpu" : "database"}
                            className="h-4 w-4"
                          />
                        </span>

                        <div className="text-right">
                          <p className="text-[9px] font-bold text-slate-400">
                            {mod.progress}% PROGRESS
                          </p>
                          <div className="mt-1 flex gap-1">
                            {[0, 1, 2, 3].map((bar) => (
                              <span
                                key={bar}
                                className={`h-1.5 w-5 rounded-full ${
                                  bar < Math.ceil(mod.progress / 25)
                                    ? "bg-purple-600"
                                    : "bg-slate-200"
                                }`}
                              />
                            ))}
                          </div>
                        </div>
                      </div>

                      <h3 className="mt-4 text-sm font-black text-slate-950">
                        {mod.title}
                      </h3>

                      <p className="mt-1 truncate text-[10px] text-slate-400">
                        {mod.category}
                      </p>

                      <div className="mt-4 h-1.5 overflow-hidden rounded-full bg-slate-100">
                        <div
                          className="h-full rounded-full"
                          style={{
                            width: `${mod.progress}%`,
                            background: mod.color || "#7c3aed",
                          }}
                        />
                      </div>

                      <button
                        type="button"
                        onClick={() => navigate("/student/roadmap")}
                        className="mt-4 flex w-full items-center justify-between rounded-lg bg-purple-50 px-3 py-2 text-[10px] font-bold text-purple-700 transition hover:bg-purple-100"
                      >
                        Continue learning
                        <Icon name="chevron-right" className="h-3 w-3" />
                      </button>
                    </article>
                  ))}
                </div>
              </section>

              <section>
                <div className="mb-3 flex items-center justify-between">
                  <h2 className="text-base font-black text-slate-950">
                    Recommended For You
                  </h2>

                  <div className="flex gap-1.5">
                    {["Engineering", "Design", "Business"].map((tag) => (
                      <span
                        key={tag}
                        className="hidden rounded-full border border-slate-200 bg-white px-2.5 py-1 text-[8px] font-semibold text-slate-500 sm:inline-flex"
                      >
                        {tag}
                      </span>
                    ))}
                  </div>
                </div>

                <div className="grid gap-4 md:grid-cols-2">
                  {recommendedItems.map((item) => (
                    <article
                      key={item.title}
                      className="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm transition hover:-translate-y-0.5 hover:shadow-md"
                    >
                      <div className="relative h-28 overflow-hidden bg-gradient-to-br from-purple-100 via-indigo-50 to-teal-50">
                        <div className="absolute -right-5 -top-7 h-28 w-28 rounded-full bg-purple-300/30 blur-xl" />
                        <div className="absolute -bottom-8 left-6 h-24 w-24 rounded-full bg-indigo-300/30 blur-xl" />

                        <div className="relative flex h-full items-center justify-center">
                          <div className="rounded-2xl border border-white/70 bg-white/70 p-4 shadow-sm backdrop-blur">
                            <Icon name={item.icon} className="h-8 w-8 text-purple-600" />
                          </div>
                        </div>
                      </div>

                      <div className="p-4">
                        <div className="flex items-center justify-between">
                          <span className="rounded-md bg-purple-50 px-2 py-1 text-[8px] font-bold text-purple-600">
                            {item.category}
                          </span>

                          <span className="text-[8px] font-semibold text-slate-400">
                            {item.progress} Lessons
                          </span>
                        </div>

                        <h3 className="mt-2 text-sm font-black text-slate-950">
                          {item.title}
                        </h3>

                        <p className="mt-1 line-clamp-2 text-[10px] leading-4 text-slate-400">
                          {item.description}
                        </p>

                        <button
                          type="button"
                          onClick={() => navigate("/student/roadmap")}
                          className="mt-3 flex w-full items-center justify-between text-[10px] font-bold text-purple-600"
                        >
                          Explore course
                          <span className="flex h-6 w-6 items-center justify-center rounded-full bg-purple-50">
                            <Icon name="chevron-right" className="h-3 w-3" />
                          </span>
                        </button>
                      </div>
                    </article>
                  ))}
                </div>
              </section>

              <DailyStreak />

              <BadgesSection />

              <section className="grid gap-5 xl:grid-cols-2">
                {/* Existing AI components remain available without changing their implementation. */}
                <div className="rounded-2xl border border-purple-100 bg-purple-50/40 p-5">
                  <div className="flex items-center gap-2">
                    <span className="flex h-8 w-8 items-center justify-center rounded-lg bg-purple-100 text-purple-600">
                      <Icon name="sparkles" className="h-4 w-4" />
                    </span>
                    <div>
                      <p className="text-[9px] font-bold uppercase tracking-wider text-purple-400">
                        AI Career Tools
                      </p>
                      <h3 className="text-sm font-black text-slate-950">
                        Ready to improve your placement profile?
                      </h3>
                    </div>
                  </div>

                  <p className="mt-3 text-[10px] leading-4 text-slate-500">
                    Use the AI tools already connected to this dashboard to plan your learning, analyze your profile, score your resume, and identify skill gaps.
                  </p>

                  <button
                    type="button"
                    onClick={() => setAiOpen(true)}
                    className="mt-4 rounded-lg bg-purple-700 px-4 py-2 text-[10px] font-bold text-white transition hover:bg-purple-800"
                  >
                    Open AI Career Coach
                  </button>
                </div>

                <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-[9px] font-bold uppercase tracking-wider text-slate-400">
                        Career Path
                      </p>
                      <h3 className="mt-1 text-sm font-black text-slate-950">
                        Roadmap to placement
                      </h3>
                    </div>

                    <span className="flex h-8 w-8 items-center justify-center rounded-lg bg-purple-50 text-purple-600">
                      <Icon name="target" className="h-4 w-4" />
                    </span>
                  </div>

                  <div className="mt-4 flex items-center gap-2 overflow-x-auto pb-1">
                    {roadmapSteps.slice(0, 5).map((step) => (
                      <div
                        key={step.step}
                        className="min-w-[105px] rounded-xl border border-slate-100 bg-slate-50 p-2.5"
                      >
                        <span className="flex h-7 w-7 items-center justify-center rounded-lg bg-purple-100 text-purple-600">
                          <Icon name={step.icon} className="h-3.5 w-3.5" />
                        </span>

                        <p className="mt-2 text-[9px] font-bold text-slate-800">
                          {step.title}
                        </p>

                        <p className="mt-0.5 text-[8px] text-slate-400">
                          {step.step}
                        </p>
                      </div>
                    ))}
                  </div>
                </section>
              </section>
            </div>

            <aside className="space-y-5">

              <section className="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
                <div className="flex items-center justify-between">
                  <h2 className="text-sm font-black text-slate-950">
                    Upcoming
                  </h2>

                  <Icon name="calendar" className="h-4 w-4 text-slate-400" />
                </div>

                <div className="mt-3 divide-y divide-slate-100">
                  {upcomingActivities.length > 0 ? (
                    upcomingActivities.slice(0, 4).map((activity, index) => (
                      <div
                        key={`${activity.title}-${index}`}
                        className="flex gap-2.5 py-3 first:pt-0 last:pb-0"
                      >
                        <div className="flex h-9 w-8 flex-shrink-0 flex-col items-center justify-center rounded-lg bg-purple-50 text-purple-700">
                          <span className="text-[7px] font-bold uppercase">
                            {activity.date?.split(" ")[0] || "UP"}
                          </span>
                          <Icon name="calendar" className="mt-0.5 h-3 w-3" />
                        </div>

                        <div className="min-w-0">
                          <p className="text-[10px] font-bold leading-4 text-slate-900">
                            {activity.title}
                          </p>
                          <p className="mt-0.5 line-clamp-2 text-[8px] leading-3.5 text-slate-400">
                            {activity.desc}
                          </p>
                          <p className="mt-1 text-[8px] font-semibold text-purple-600">
                            {activity.date}
                          </p>
                        </div>
                      </div>
                    ))
                  ) : (
                    <div className="py-5 text-center text-[10px] font-semibold text-slate-400">
                      No upcoming activities yet.
                    </div>
                  )}
                </div>

                <button
                  type="button"
                  onClick={() => navigate("/student/notifications")}
                  className="mt-3 flex w-full items-center justify-center rounded-lg border border-slate-200 py-2 text-[9px] font-bold text-slate-500 transition hover:border-purple-200 hover:text-purple-600"
                >
                  See Calendar
                </button>
              </section>

              <section className="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
                <div className="flex items-center justify-between">
                  <h2 className="text-sm font-black text-slate-950">
                    Notifications
                  </h2>

                  <span className="rounded-full bg-purple-50 px-2 py-1 text-[8px] font-bold text-purple-600">
                    {dashboard?.stats.unreadNotifications ?? 0} new
                  </span>
                </div>

                <div className="mt-3 space-y-2">
                  {dashboardNotifications.map((notification) => (
                    <button
                      type="button"
                      key={notification.title}
                      onClick={() => navigate("/student/notifications")}
                      className="flex w-full items-start gap-2.5 rounded-xl p-2 text-left transition hover:bg-slate-50"
                    >
                      <span
                        className={`flex h-7 w-7 flex-shrink-0 items-center justify-center rounded-full ${
                          notification.tone === "purple"
                            ? "bg-purple-100 text-purple-600"
                            : notification.tone === "blue"
                              ? "bg-indigo-50 text-indigo-600"
                              : "bg-slate-100 text-slate-500"
                        }`}
                      >
                        <Icon name={notification.icon} className="h-3 w-3" />
                      </span>

                      <span className="min-w-0">
                        <span className="block truncate text-[9px] font-bold text-slate-800">
                          {notification.title}
                        </span>

                        <span className="mt-0.5 block line-clamp-2 text-[8px] leading-3.5 text-slate-400">
                          {notification.description}
                        </span>

                        <span className="mt-1 block text-[7px] font-semibold uppercase text-slate-400">
                          {notification.time}
                        </span>
                      </span>
                    </button>
                  ))}
                </div>

                <button
                  type="button"
                  onClick={() => navigate("/student/notifications")}
                  className="mt-2 w-full text-[9px] font-bold text-purple-600 hover:text-purple-800"
                >
                  View all notifications
                </button>
              </section>

              <section className="rounded-2xl border border-purple-100 bg-purple-50/60 p-4">
                <div className="flex items-center gap-2">
                  <span className="flex h-8 w-8 items-center justify-center rounded-lg bg-purple-100 text-purple-600">
                    <Icon name="sparkles" className="h-4 w-4" />
                  </span>

                  <div>
                    <p className="text-[9px] font-bold uppercase tracking-wider text-purple-500">
                      Quick Insight
                    </p>
                    <p className="text-[11px] font-black text-slate-900">
                      Keep your momentum going
                    </p>
                  </div>
                </div>

                <p className="mt-3 text-[9px] leading-4 text-slate-500">
                  Complete one learning module and keep your profile updated before applying to your next opportunity.
                </p>

                <button
                  type="button"
                  onClick={() => navigate("/student/profile")}
                  className="mt-3 text-[9px] font-bold text-purple-700"
                >
                  Improve profile →
                </button>
              </section>
            </aside>
          </div>

          
        </div>
      </div>

      {aiOpen && (
        <div className="pointer-events-none fixed inset-0 z-50 flex items-end justify-end p-4 sm:items-start sm:pr-6 sm:pt-[72px]">
          <div className="pointer-events-auto flex h-[560px] w-full max-w-sm flex-col overflow-hidden rounded-2xl border border-slate-700 bg-slate-950 shadow-2xl shadow-slate-900/50">
            <AICareerCoachPanel onClose={() => setAiOpen(false)} />
          </div>
        </div>
      )}

      
    </StudentLayout>
  );
}

export default StudentDashboard;