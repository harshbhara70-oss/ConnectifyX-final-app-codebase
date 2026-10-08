import { useEffect, useState } from "react";
import { useAuth } from "../../context/AuthContext";
import StudentLayout from "../../components/student/StudentLayout";
import type { StudentSidebarIconName } from "../../components/student/StudentSidebar";
import { getApiErrorMessage, studentApi, unwrapData } from "../../services/studentApi";

// ─── Icon System (matches Admin Dashboard / Student Dashboard) ───────────────
type IconName =
  | "activity" | "alert" | "arrow-up" | "arrow-down" | "bell" | "briefcase"
  | "building" | "calendar" | "chart" | "check" | "clock" | "dashboard"
  | "database" | "file" | "graduation" | "lock" | "plug" | "search"
  | "settings" | "shield" | "sparkles" | "target" | "user-check" | "users"
  | "ai-brain" | "placement" | "resume" | "interview" | "risk" | "campus"
  | "automation" | "monitor" | "send" | "refresh" | "close" | "chevron-right"
  | "wand" | "zap" | "trending-up" | "cpu" | "mail" | "phone" | "book"
  | "award" | "upload" | "eye" | "message" | "chevron-down" | "lightbulb"
  | "clipboard" | "logout" | "x-circle" | "hourglass" | "map-pin";

const Icon = ({ name, className = "h-4 w-4", style }: { name: IconName; className?: string; style?: React.CSSProperties }) => {
  const paths: Record<IconName, React.ReactNode> = {
    activity: <path d="M4 12h3l2-6 4 12 2-6h5" />,
    alert: <><path d="M12 4 3.5 18.5h17L12 4Z" /><path d="M12 9v4" /><path d="M12 16h.01" /></>,
    "arrow-up": <><path d="M7 17 17 7" /><path d="M9 7h8v8" /></>,
    "arrow-down": <><path d="M7 7 17 17" /><path d="M17 9v8H9" /></>,
    bell: <><path d="M18 9a6 6 0 0 0-12 0c0 7-3 7-3 7h18s-3 0-3-7" /><path d="M10 20a2 2 0 0 0 4 0" /></>,
    briefcase: <><path d="M9 7V5a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2v2" /><path d="M4 7h16v11a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V7Z" /><path d="M4 12h16" /></>,
    building: <><path d="M5 21V5a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v16" /><path d="M3 21h18" /><path d="M9 7h1" /><path d="M14 7h1" /><path d="M9 11h1" /><path d="M14 11h1" /></>,
    calendar: <><path d="M7 3v4" /><path d="M17 3v4" /><rect x="4" y="5" width="16" height="16" rx="2" /><path d="M4 10h16" /></>,
    chart: <><path d="M4 19V5" /><path d="M4 19h16" /><path d="M8 16v-5" /><path d="M12 16V8" /><path d="M16 16v-7" /></>,
    check: <><path d="M21 12a9 9 0 1 1-5-8" /><path d="m9 12 2 2 6-7" /></>,
    clock: <><circle cx="12" cy="12" r="9" /><path d="M12 7v5l3 2" /></>,
    dashboard: <><rect x="3" y="3" width="7" height="7" rx="1.5" /><rect x="14" y="3" width="7" height="7" rx="1.5" /><rect x="3" y="14" width="7" height="7" rx="1.5" /><rect x="14" y="14" width="7" height="7" rx="1.5" /></>,
    database: <><ellipse cx="12" cy="5" rx="7" ry="3" /><path d="M5 5v7c0 1.7 3.1 3 7 3s7-1.3 7-3V5" /><path d="M5 12v7c0 1.7 3.1 3 7 3s7-1.3 7-3v-7" /></>,
    file: <><path d="M14 3H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9Z" /><path d="M14 3v6h6" /><path d="M8 13h8" /><path d="M8 17h5" /></>,
    graduation: <><path d="m22 10-10-5-10 5 10 5 10-5Z" /><path d="M6 12v5c3 2 9 2 12 0v-5" /></>,
    lock: <><rect x="4" y="11" width="16" height="10" rx="2" /><path d="M8 11V8a4 4 0 0 1 8 0v3" /></>,
    plug: <><path d="M8 3v5" /><path d="M16 3v5" /><path d="M6 8h12v4a6 6 0 0 1-12 0V8Z" /><path d="M12 18v3" /></>,
    search: <><circle cx="11" cy="11" r="7" /><path d="m16 16 4 4" /></>,
    settings: <><circle cx="12" cy="12" r="3" /><path d="M19 12a7.5 7.5 0 0 0-.1-1.2l2-1.5-2-3.5-2.4 1a7.5 7.5 0 0 0-2-1.2L14.2 3h-4.4l-.3 2.6a7.5 7.5 0 0 0-2 1.2l-2.4-1-2 3.5 2 1.5A7.5 7.5 0 0 0 5 12c0 .4 0 .8.1 1.2l-2 1.5 2 3.5 2.4-1a7.5 7.5 0 0 0 2 1.2l.3 2.6h4.4l.3-2.6a7.5 7.5 0 0 0 2-1.2l2.4 1 2-3.5-2-1.5c.1-.4.1-.8.1-1.2Z" /></>,
    shield: <><path d="M12 3 20 6v6c0 5-3.4 8-8 9-4.6-1-8-4-8-9V6l8-3Z" /><path d="m9 12 2 2 4-5" /></>,
    sparkles: <><path d="M12 3 10.5 8.5 5 10l5.5 1.5L12 17l1.5-5.5L19 10l-5.5-1.5L12 3Z" /><path d="M5 16v4" /><path d="M3 18h4" /><path d="M19 3v3" /><path d="M17.5 4.5h3" /></>,
    target: <><circle cx="12" cy="12" r="8" /><circle cx="12" cy="12" r="4" /><path d="M12 2v3" /><path d="M12 19v3" /><path d="M2 12h3" /><path d="M19 12h3" /></>,
    "user-check": <><path d="M15 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" /><circle cx="8.5" cy="7" r="4" /><path d="m16 11 2 2 4-5" /></>,
    users: <><path d="M16 21v-2a4 4 0 0 0-4-4H7a4 4 0 0 0-4 4v2" /><circle cx="9.5" cy="7" r="4" /><path d="M22 21v-2a4 4 0 0 0-3-3.8" /><path d="M16 3.2a4 4 0 0 1 0 7.6" /></>,
    "ai-brain": <><circle cx="12" cy="12" r="5" /><path d="M12 2v3M12 19v3M2 12h3M19 12h3" /><path d="m4.9 4.9 2.1 2.1M16.9 16.9l2.1 2.1M4.9 19.1l2.1-2.1M16.9 7.1l2.1-2.1" /></>,
    placement: <><path d="M12 4v12" /><path d="m8 12 4-4 4 4" /><path d="M8 20h8" /></>,
    resume: <><path d="M6 3h9l5 5v13a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2Z" /><path d="M14 3v5h5" /><path d="M8 13h8" /><path d="M8 17h6" /></>,
    interview: <><path d="M6 7h12v8H9l-3 3V7Z" /><path d="M8 5h8" /></>,
    risk: <><path d="M12 3 3 19h18L12 3Z" /><path d="M12 9v4" /><path d="M12 17h.01" /></>,
    campus: <><path d="M4 21V9l8-5 8 5v12" /><path d="M12 3v18" /><path d="M8 12h8" /></>,
    automation: <><circle cx="12" cy="12" r="5" /><path d="M12 2v2M12 20v2M2 12h2M20 12h2" /><path d="m4.9 4.9 1.4 1.4M17.7 17.7l1.4 1.4M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4" /></>,
    monitor: <><rect x="4" y="5" width="16" height="12" rx="2" /><path d="M8 21h8" /><path d="M12 17v4" /></>,
    send: <><path d="m22 2-11 11" /><path d="m22 2-7 20-4-9-9-4 20-7z" /></>,
    refresh: <><path d="M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8" /><path d="M21 3v5h-5" /><path d="M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16" /><path d="M8 16H3v5" /></>,
    close: <><path d="M18 6 6 18" /><path d="m6 6 12 12" /></>,
    "chevron-right": <path d="m9 18 6-6-6-6" />,
    wand: <><path d="m15 5 4 4" /><path d="M13 7 8.7 2.7a2.41 2.41 0 0 0-3.4 3.43L9.6 10.1" /><path d="m9.6 10.1-4.3 4.3a2.41 2.41 0 0 0 3.43 3.4L13 13.4" /><path d="m13 13.4 4.3 4.3a2.41 2.41 0 0 0 3.4-3.43L16.6 10" /><path d="m16.6 10 1.7-1.7" /></>,
    zap: <><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2" /></>,
    "trending-up": <><polyline points="22 7 13.5 15.5 8.5 10.5 2 17" /><polyline points="16 7 22 7 22 13" /></>,
    cpu: <><rect x="4" y="4" width="16" height="16" rx="2" /><rect x="9" y="9" width="6" height="6" /><path d="M15 2v2M9 2v2M2 15h2M2 9h2M15 20v2M9 20v2M20 15h2M20 9h2" /></>,
    mail: <><rect x="3" y="5" width="18" height="14" rx="2" /><path d="m3 7 9 6 9-6" /></>,
    phone: <path d="M6.6 10.8a15.9 15.9 0 0 0 6.6 6.6l2.2-2.2c.3-.3.7-.4 1-.3 1.1.4 2.3.6 3.6.6.6 0 1 .4 1 1V21c0 .6-.4 1-1 1C10.6 22 2 13.4 2 3c0-.6.4-1 1-1h3.5c.6 0 1 .4 1 1 0 1.3.2 2.5.6 3.6.1.3 0 .7-.3 1L6.6 10.8Z" />,
    book: <><path d="M4 5a2 2 0 0 1 2-2h9v16H6a2 2 0 0 0-2 2V5Z" /><path d="M15 3h3a2 2 0 0 1 2 2v14a2 2 0 0 0-2-2h-3" /></>,
    award: <><circle cx="12" cy="8" r="6" /><path d="m9 13.5-1 7.5 4-2 4 2-1-7.5" /></>,
    upload: <><path d="M12 3v12" /><path d="m7 8 5-5 5 5" /><path d="M4 17v2a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-2" /></>,
    eye: <><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7Z" /><circle cx="12" cy="12" r="3" /></>,
    message: <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v10Z" />,
    "chevron-down": <path d="m6 9 6 6 6-6" />,
    lightbulb: <><path d="M9 18h6" /><path d="M10 21h4" /><path d="M12 3a6 6 0 0 0-4 10.5c.6.5 1 1.3 1 2.1V16h6v-.4c0-.8.4-1.6 1-2.1A6 6 0 0 0 12 3Z" /></>,
    clipboard: <><rect x="6" y="4" width="12" height="17" rx="2" /><path d="M9 4V3a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v1" /><path d="m9 12 2 2 4-4" /></>,
    logout: <><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" /><path d="m16 17 5-5-5-5" /><path d="M21 12H9" /></>,
    "x-circle": <><circle cx="12" cy="12" r="9" /><path d="m9.5 9.5 5 5" /><path d="m14.5 9.5-5 5" /></>,
    hourglass: <><path d="M6 3h12" /><path d="M6 21h12" /><path d="M7 3c0 5 5 5 5 9s-5 4-5 9" /><path d="M17 3c0 5-5 5-5 9s5 4 5 9" /></>,
    "map-pin": <><path d="M12 21s7-6.3 7-11.5a7 7 0 1 0-14 0C5 14.7 12 21 12 21Z" /><circle cx="12" cy="9.5" r="2.3" /></>,
  };
  return (
    <svg className={className} style={style} fill="none" stroke="currentColor" strokeLinecap="round"
      strokeLinejoin="round" strokeWidth="2" viewBox="0 0 24 24" aria-hidden="true">
      {paths[name]}
    </svg>
  );
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
// ─── Applied Project Data ───────────────────────────────────────────────────
type AppStatus = "Applied" | "Under Review" | "Interview Scheduled" | "Accepted" | "Rejected";

interface AppliedProject {
  id: string;
  title: string;
  company: string;
  location: string;
  appliedOn: string;
  status: AppStatus;
  stipend: string;
  skills: string[];
}

const statusMeta: Record<AppStatus, { icon: IconName; cls: string; dot: string }> = {
  Applied: { icon: "send", cls: "bg-blue-50 text-blue-700 ring-blue-100", dot: "#2563eb" },
  "Under Review": { icon: "hourglass", cls: "bg-amber-50 text-amber-700 ring-amber-100", dot: "#f59e0b" },
  "Interview Scheduled": { icon: "interview", cls: "bg-violet-50 text-violet-700 ring-violet-100", dot: "#8b5cf6" },
  Accepted: { icon: "check", cls: "bg-emerald-50 text-emerald-700 ring-emerald-100", dot: "#10b981" },
  Rejected: { icon: "x-circle", cls: "bg-rose-50 text-rose-700 ring-rose-100", dot: "#ef4444" },
};

type FilterTab = "all" | AppStatus;
const filterTabs: { key: FilterTab; label: string }[] = [
  { key: "all", label: "All" },
  { key: "Applied", label: "Applied" },
  { key: "Under Review", label: "Under Review" },
  { key: "Interview Scheduled", label: "Interview Scheduled" },
  { key: "Accepted", label: "Accepted" },
  { key: "Rejected", label: "Rejected" },
];

// ═══════════════════════════════════════════════════════════════════════════
// REDESIGNED APPLICATION TRACKER
// ═══════════════════════════════════════════════════════════════════════════

type ApplicationWithMeta = AppliedProject & {
  matchScore: number;
  nextAction: string;
  timeline: string[];
};

const getMatchScore = (p: AppliedProject) => {
  const skills = p.skills.length;
  if (p.status === "Accepted") return Math.min(96, 82 + skills * 2);
  if (p.status === "Interview Scheduled") return Math.min(94, 78 + skills * 2);
  if (p.status === "Under Review") return Math.min(91, 70 + skills * 3);
  if (p.status === "Rejected") return Math.min(78, 58 + skills * 3);
  return Math.min(88, 65 + skills * 3);
};

const getNextAction = (status: AppStatus) => {
  switch (status) {
    case "Applied":
      return "Wait for recruiter review";
    case "Under Review":
      return "Keep your resume and interview prep ready";
    case "Interview Scheduled":
      return "Prepare for your upcoming interview";
    case "Accepted":
      return "Complete onboarding requirements";
    case "Rejected":
      return "Use the feedback and target the next role";
  }
};

const getTimeline = (status: AppStatus) => {
  const base = ["Application submitted"];

  if (status !== "Applied") base.push("Application reviewed");
  if (status === "Interview Scheduled" || status === "Accepted") {
    base.push("Interview scheduled");
  }
  if (status === "Accepted") base.push("Offer received");
  if (status === "Rejected") base.push("Application closed");

  return base;
};

export const StudentApplication = () => {
  const { currentUser } = useAuth();
  const fullName = currentUser?.fullName || currentUser?.name || "Student";

  const [appliedProjects, setAppliedProjects] = useState<AppliedProject[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [activeTab, setActiveTab] = useState<FilterTab>("all");
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [search, setSearch] = useState("");

  useEffect(() => {
    let mounted = true;

    const loadApplications = async () => {
      setLoading(true);
      setError("");

      try {
        const response = await studentApi.getApplications();
        const payload = unwrapData<{ applications: AppliedProject[] }>(response);

        if (mounted) {
          const applications = payload.applications || [];
          setAppliedProjects(applications);
          setSelectedId(applications[0]?.id || null);
        }
      } catch (loadError) {
        if (mounted) {
          setError(getApiErrorMessage(loadError));
          setAppliedProjects([]);
        }
      } finally {
        if (mounted) setLoading(false);
      }
    };

    loadApplications();

    return () => {
      mounted = false;
    };
  }, []);

  const counts: Record<FilterTab, number> = {
    all: appliedProjects.length,
    Applied: appliedProjects.filter((p) => p.status === "Applied").length,
    "Under Review": appliedProjects.filter((p) => p.status === "Under Review").length,
    "Interview Scheduled": appliedProjects.filter((p) => p.status === "Interview Scheduled").length,
    Accepted: appliedProjects.filter((p) => p.status === "Accepted").length,
    Rejected: appliedProjects.filter((p) => p.status === "Rejected").length,
  };

  const filtered = appliedProjects.filter((p) => {
    const matchesTab = activeTab === "all" || p.status === activeTab;
    const q = search.trim().toLowerCase();

    if (!q) return matchesTab;

    return (
      matchesTab &&
      `${p.title} ${p.company} ${p.location} ${p.skills.join(" ")}`
        .toLowerCase()
        .includes(q)
    );
  });

  const selected =
    appliedProjects.find((p) => p.id === selectedId) ||
    filtered[0] ||
    appliedProjects[0];

  const selectedMeta: ApplicationWithMeta | null = selected
    ? {
        ...selected,
        matchScore: getMatchScore(selected),
        nextAction: getNextAction(selected.status),
        timeline: getTimeline(selected.status),
      }
    : null;

  const totalActive =
    counts.Applied + counts["Under Review"] + counts["Interview Scheduled"];

  const responseRate =
    appliedProjects.length > 0
      ? Math.round(
          ((appliedProjects.length - counts.Rejected) / appliedProjects.length) *
            100,
        )
      : 0;

  return (
    <StudentLayout
      sidebarItems={sidebarItems}
      sidebarHighlight="Applied Projects"
      userSummary={{
        fullName,
        role: "Student",
        status: "Placement track active",
      }}
      stats={{
        label: "Applications",
        value: String(appliedProjects.length),
        subtitle: "Total submitted",
        accent: "Live",
      }}
    >
      <div className="space-y-5">

        {error && (
          <div className="rounded-2xl border border-rose-100 bg-rose-50 px-4 py-3 text-sm font-semibold text-rose-700">
            {error}
          </div>
        )}

        {loading && (
          <div className="rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-500 shadow-sm">
            Loading your applications...
          </div>
        )}

        {/* Header */}
        <section className="relative overflow-hidden rounded-3xl border border-[#e8e0ed] bg-white p-6 shadow-sm sm:p-8">
          <div className="pointer-events-none absolute -right-20 -top-24 h-64 w-64 rounded-full bg-[#5400D6]/10 blur-3xl" />
          <div className="pointer-events-none absolute bottom-0 left-1/3 h-32 w-64 rounded-full bg-blue-50 blur-3xl" />

          <div className="relative flex flex-col gap-6 lg:flex-row lg:items-end lg:justify-between">
            <div className="max-w-2xl">
              <span className="inline-flex items-center gap-2 rounded-full bg-[#5400D6]/10 px-3 py-1.5 text-[11px] font-bold text-[#5400D6]">
                <Icon name="clipboard" className="h-3.5 w-3.5" />
                APPLICATION CENTER
              </span>

              <h1 className="mt-4 text-3xl font-black tracking-tight text-slate-900 sm:text-4xl">
                My Applications
              </h1>

              <p className="mt-3 text-sm leading-6 text-slate-500 sm:text-base">
                Track every opportunity you applied for, understand your current
                stage, and see what you should do next.
              </p>
            </div>

            <div className="rounded-2xl border border-[#5400D6]/10 bg-[#5400D6]/5 p-4 lg:min-w-[240px]">
              <div className="flex items-center gap-3">
                <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-[#5400D6] text-white">
                  <Icon name="target" className="h-5 w-5" />
                </div>
                <div>
                  <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400">
                    Active applications
                  </p>
                  <p className="mt-0.5 text-xl font-black text-slate-900">
                    {totalActive}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Summary cards */}
        <section className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
          <article className="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
            <div className="flex items-center gap-3">
              <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-blue-50 text-blue-600">
                <Icon name="send" className="h-4 w-4" />
              </div>
              <div>
                <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400">
                  Submitted
                </p>
                <p className="text-2xl font-black text-slate-900">
                  {counts.all}
                </p>
              </div>
            </div>
          </article>

          <article className="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
            <div className="flex items-center gap-3">
              <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-amber-50 text-amber-600">
                <Icon name="hourglass" className="h-4 w-4" />
              </div>
              <div>
                <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400">
                  In progress
                </p>
                <p className="text-2xl font-black text-slate-900">
                  {counts["Under Review"] + counts["Interview Scheduled"]}
                </p>
              </div>
            </div>
          </article>

          <article className="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
            <div className="flex items-center gap-3">
              <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-emerald-50 text-emerald-600">
                <Icon name="check" className="h-4 w-4" />
              </div>
              <div>
                <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400">
                  Accepted
                </p>
                <p className="text-2xl font-black text-slate-900">
                  {counts.Accepted}
                </p>
              </div>
            </div>
          </article>

          <article className="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
            <div className="flex items-center gap-3">
              <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-[#5400D6]/10 text-[#5400D6]">
                <Icon name="trending-up" className="h-4 w-4" />
              </div>
              <div>
                <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400">
                  Response rate
                </p>
                <p className="text-2xl font-black text-slate-900">
                  {responseRate}%
                </p>
              </div>
            </div>
          </article>
        </section>

        {/* Filters */}
        <section className="rounded-2xl border border-slate-200 bg-white p-3 shadow-sm">
          <div className="flex flex-col gap-3 lg:flex-row lg:items-center lg:justify-between">
            <div className="flex flex-wrap gap-1.5">
              {filterTabs.map((tab) => (
                <button
                  key={tab.key}
                  type="button"
                  onClick={() => setActiveTab(tab.key)}
                  className={`rounded-xl px-3 py-2 text-xs font-bold transition ${
                    activeTab === tab.key
                      ? "bg-[#5400D6] text-white shadow-sm"
                      : "text-slate-500 hover:bg-slate-50 hover:text-slate-800"
                  }`}
                >
                  {tab.label}
                  <span className="ml-1.5 opacity-60">
                    {counts[tab.key]}
                  </span>
                </button>
              ))}
            </div>

            <div className="relative w-full lg:w-64">
              <Icon
                name="search"
                className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400"
              />
              <input
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Search applications..."
                className="h-10 w-full rounded-xl border border-slate-200 bg-slate-50 pl-9 pr-3 text-xs outline-none focus:border-[#5400D6]/30 focus:ring-2 focus:ring-[#5400D6]/10"
              />
            </div>
          </div>
        </section>

        {/* Main application workspace */}
        <section className="grid gap-5 xl:grid-cols-[minmax(0,0.95fr)_minmax(390px,1.05fr)]">

          {/* Application list */}
          <div className="min-w-0 rounded-2xl border border-slate-200 bg-white shadow-sm">
            <div className="border-b border-slate-100 p-5">
              <p className="text-[10px] font-bold uppercase tracking-widest text-slate-400">
                Your applications
              </p>
              <div className="mt-1 flex items-center justify-between gap-3">
                <h2 className="text-lg font-black text-slate-900">
                  {activeTab === "all" ? "All applications" : activeTab}
                </h2>
                <span className="rounded-full bg-slate-100 px-2.5 py-1 text-[10px] font-bold text-slate-500">
                  {filtered.length} results
                </span>
              </div>
            </div>

            {filtered.length === 0 && !loading ? (
              <div className="m-5 flex flex-col items-center rounded-2xl border border-dashed border-slate-200 bg-slate-50 py-14 text-center">
                <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-white ring-1 ring-slate-200">
                  <Icon name="clipboard" className="h-5 w-5 text-slate-300" />
                </div>
                <p className="mt-3 text-sm font-bold text-slate-600">
                  No applications found
                </p>
                <p className="mt-1 text-xs text-slate-400">
                  Try another filter or search term.
                </p>
              </div>
            ) : (
              <div className="space-y-2 p-3">
                {filtered.map((p) => {
                  const meta = statusMeta[p.status];
                  const active = selected?.id === p.id;
                  const score = getMatchScore(p);

                  return (
                    <button
                      key={p.id}
                      type="button"
                      onClick={() => setSelectedId(p.id)}
                      className={`w-full rounded-2xl border p-4 text-left transition ${
                        active
                          ? "border-[#5400D6]/25 bg-[#5400D6]/5 shadow-sm"
                          : "border-transparent bg-slate-50 hover:border-slate-200 hover:bg-white"
                      }`}
                    >
                      <div className="flex items-start gap-3">
                        <div
                          className={`flex h-11 w-11 flex-shrink-0 items-center justify-center rounded-xl ${
                            active
                              ? "bg-[#5400D6] text-white"
                              : "bg-white text-slate-500 ring-1 ring-slate-200"
                          }`}
                        >
                          <Icon name="briefcase" className="h-5 w-5" />
                        </div>

                        <div className="min-w-0 flex-1">
                          <div className="flex flex-wrap items-center gap-2">
                            <h3 className="truncate text-sm font-black text-slate-900">
                              {p.title}
                            </h3>

                            <span
                              className={`inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[9px] font-bold ring-1 ${meta.cls}`}
                            >
                              <Icon name={meta.icon} className="h-3 w-3" />
                              {p.status}
                            </span>
                          </div>

                          <div className="mt-1.5 flex flex-wrap gap-x-3 gap-y-1 text-[10px] text-slate-500">
                            <span className="flex items-center gap-1">
                              <Icon name="building" className="h-3 w-3" />
                              {p.company}
                            </span>
                            <span className="flex items-center gap-1">
                              <Icon name="map-pin" className="h-3 w-3" />
                              {p.location}
                            </span>
                            <span className="flex items-center gap-1">
                              <Icon name="calendar" className="h-3 w-3" />
                              {p.appliedOn}
                            </span>
                          </div>

                          <div className="mt-3 flex items-center gap-3">
                            <div className="h-1.5 flex-1 overflow-hidden rounded-full bg-slate-200">
                              <div
                                className="h-full rounded-full bg-[#5400D6]"
                                style={{ width: `${score}%` }}
                              />
                            </div>
                            <span className="text-[10px] font-black text-[#5400D6]">
                              {score}% match
                            </span>
                          </div>
                        </div>

                        <Icon
                          name="chevron-right"
                          className={`mt-2 h-4 w-4 flex-shrink-0 ${
                            active ? "text-[#5400D6]" : "text-slate-300"
                          }`}
                        />
                      </div>
                    </button>
                  );
                })}
              </div>
            )}
          </div>

          {/* Application details */}
          {selectedMeta ? (
            <aside className="min-w-0 rounded-2xl border border-slate-200 bg-white shadow-sm">
              <div className="border-b border-slate-100 p-5 sm:p-6">
                <div className="flex items-start justify-between gap-4">
                  <div>
                    <span className="text-[10px] font-bold uppercase tracking-widest text-slate-400">
                      Application details
                    </span>
                    <h2 className="mt-1.5 text-xl font-black text-slate-900">
                      {selectedMeta.title}
                    </h2>
                    <p className="mt-1 text-sm font-bold text-[#5400D6]">
                      {selectedMeta.company}
                    </p>
                  </div>

                  <span
                    className={`inline-flex items-center gap-1.5 rounded-full px-3 py-1.5 text-[10px] font-bold ring-1 ${statusMeta[selectedMeta.status].cls}`}
                  >
                    <Icon
                      name={statusMeta[selectedMeta.status].icon}
                      className="h-3 w-3"
                    />
                    {selectedMeta.status}
                  </span>
                </div>

                <div className="mt-5 grid grid-cols-2 gap-3">
                  <div className="rounded-xl bg-slate-50 p-3">
                    <p className="text-[9px] font-bold uppercase tracking-wider text-slate-400">
                      Stipend
                    </p>
                    <p className="mt-1 text-sm font-black text-slate-900">
                      {selectedMeta.stipend}
                    </p>
                  </div>

                  <div className="rounded-xl bg-slate-50 p-3">
                    <p className="text-[9px] font-bold uppercase tracking-wider text-slate-400">
                      Applied on
                    </p>
                    <p className="mt-1 text-sm font-black text-slate-900">
                      {selectedMeta.appliedOn}
                    </p>
                  </div>
                </div>
              </div>

              <div className="space-y-5 p-5 sm:p-6">

                {/* AI match */}
                <div className="rounded-2xl bg-[#5400D6]/5 p-5">
                  <div className="flex items-start justify-between gap-4">
                    <div>
                      <div className="flex items-center gap-2">
                        <Icon
                          name="sparkles"
                          className="h-4 w-4 text-[#5400D6]"
                        />
                        <p className="text-xs font-black text-slate-900">
                          AI compatibility
                        </p>
                      </div>

                      <p className="mt-2 text-3xl font-black text-[#5400D6]">
                        {selectedMeta.matchScore}%
                      </p>

                      <p className="mt-1 text-[10px] font-semibold text-slate-500">
                        Based on the skills attached to this application
                      </p>
                    </div>

                    <div className="flex h-20 w-20 items-center justify-center rounded-full border-[8px] border-[#5400D6]/10">
                      <Icon
                        name="target"
                        className="h-7 w-7 text-[#5400D6]"
                      />
                    </div>
                  </div>

                  <div className="mt-4 h-2 overflow-hidden rounded-full bg-white">
                    <div
                      className="h-full rounded-full bg-[#5400D6]"
                      style={{ width: `${selectedMeta.matchScore}%` }}
                    />
                  </div>
                </div>

                {/* Skills */}
                <div>
                  <div className="flex items-center justify-between">
                    <h3 className="text-sm font-black text-slate-900">
                      Skills submitted
                    </h3>
                    <span className="text-[10px] font-bold text-slate-400">
                      {selectedMeta.skills.length} skills
                    </span>
                  </div>

                  <div className="mt-3 flex flex-wrap gap-2">
                    {selectedMeta.skills.map((skill) => (
                      <span
                        key={skill}
                        className="inline-flex items-center gap-1.5 rounded-full bg-slate-100 px-2.5 py-1.5 text-[10px] font-bold text-slate-600"
                      >
                        <Icon name="check" className="h-3 w-3 text-emerald-500" />
                        {skill}
                      </span>
                    ))}
                  </div>
                </div>

                {/* Timeline */}
                <div>
                  <h3 className="text-sm font-black text-slate-900">
                    Application progress
                  </h3>

                  <div className="mt-4 space-y-0">
                    {selectedMeta.timeline.map((step, index) => {
                      const last = index === selectedMeta.timeline.length - 1;

                      return (
                        <div key={`${step}-${index}`} className="flex gap-3">
                          <div className="flex flex-col items-center">
                            <div
                              className={`flex h-7 w-7 items-center justify-center rounded-full ${
                                last
                                  ? "bg-[#5400D6] text-white"
                                  : "bg-emerald-50 text-emerald-600"
                              }`}
                            >
                              <Icon
                                name={last ? "clock" : "check"}
                                className="h-3.5 w-3.5"
                              />
                            </div>

                            {!last && (
                              <div className="h-8 w-px bg-slate-200" />
                            )}
                          </div>

                          <div className="pt-1">
                            <p className="text-xs font-bold text-slate-700">
                              {step}
                            </p>
                            {last && (
                              <p className="mt-0.5 text-[10px] text-slate-400">
                                Current stage
                              </p>
                            )}
                          </div>
                        </div>
                      );
                    })}
                  </div>
                </div>

                {/* Next action */}
                <div className="rounded-2xl border border-amber-100 bg-amber-50/60 p-4">
                  <div className="flex gap-3">
                    <div className="flex h-9 w-9 flex-shrink-0 items-center justify-center rounded-xl bg-white text-amber-600">
                      <Icon name="lightbulb" className="h-4 w-4" />
                    </div>

                    <div>
                      <p className="text-xs font-black text-slate-900">
                        What should you do next?
                      </p>
                      <p className="mt-1 text-xs leading-5 text-slate-600">
                        {selectedMeta.nextAction}.
                      </p>
                    </div>
                  </div>
                </div>

                {/* Details */}
                <div className="grid gap-3 sm:grid-cols-2">
                  <div className="rounded-xl border border-slate-200 p-3">
                    <p className="text-[9px] font-bold uppercase tracking-wider text-slate-400">
                      Location
                    </p>
                    <p className="mt-1 flex items-center gap-1.5 text-xs font-bold text-slate-700">
                      <Icon name="map-pin" className="h-3.5 w-3.5 text-slate-400" />
                      {selectedMeta.location}
                    </p>
                  </div>

                  <div className="rounded-xl border border-slate-200 p-3">
                    <p className="text-[9px] font-bold uppercase tracking-wider text-slate-400">
                      Application ID
                    </p>
                    <p className="mt-1 truncate text-xs font-bold text-slate-700">
                      {selectedMeta.id}
                    </p>
                  </div>
                </div>

                <button
                  type="button"
                  className="flex w-full items-center justify-center gap-2 rounded-xl border border-[#5400D6]/20 bg-[#5400D6]/5 py-3 text-xs font-bold text-[#5400D6] transition hover:bg-[#5400D6]/10"
                >
                  <Icon name="eye" className="h-4 w-4" />
                  View full application
                  <Icon name="chevron-right" className="h-3.5 w-3.5" />
                </button>
              </div>
            </aside>
          ) : (
            <aside className="flex min-h-[420px] items-center justify-center rounded-2xl border border-dashed border-slate-200 bg-slate-50 p-6 text-center">
              <div>
                <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-white ring-1 ring-slate-200">
                  <Icon name="clipboard" className="h-5 w-5 text-slate-300" />
                </div>
                <p className="mt-3 text-sm font-bold text-slate-600">
                  Select an application
                </p>
                <p className="mt-1 text-xs text-slate-400">
                  Its status, AI match and next action will appear here.
                </p>
              </div>
            </aside>
          )}
        </section>
      </div>
    </StudentLayout>
  );
};

export default StudentApplication;