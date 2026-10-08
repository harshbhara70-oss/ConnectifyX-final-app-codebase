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
  | "clipboard" | "logout" | "download" | "share" | "lock-open";

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
    download: <><path d="M12 3v12" /><path d="m7 10 5 5 5-5" /><path d="M4 21h16" /></>,
    share: <><circle cx="18" cy="5" r="3" /><circle cx="6" cy="12" r="3" /><circle cx="18" cy="19" r="3" /><path d="m8.6 10.6 6.8-3.8" /><path d="m8.6 13.4 6.8 3.8" /></>,
    "lock-open": <><rect x="4" y="11" width="16" height="10" rx="2" /><path d="M8 11V8a4 4 0 0 1 7.4-2" /></>,
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
// ─── Certificate Data ───────────────────────────────────────────────────────
interface EarnedCertificate {
  id: string;
  title: string;
  issuer: string;
  issuedOn: string;
  credentialId: string;
  downloadUrl?: string;
  shareUrl?: string;
  color: string;
  icon: IconName;
}

interface InProgressCertificate {
  id: string;
  title: string;
  progress: number;
  color: string;
  icon: IconName;
}

type FilterTab = "all" | "earned" | "in-progress";
const filterTabs: { key: FilterTab; label: string }[] = [
  { key: "all", label: "All" },
  { key: "earned", label: "Earned" },
  { key: "in-progress", label: "In progress" },
];

const toIconName = (icon?: string): IconName => {
  const allowed = new Set<IconName>([
    "activity", "alert", "arrow-up", "arrow-down", "bell", "briefcase",
    "building", "calendar", "chart", "check", "clock", "dashboard",
    "database", "file", "graduation", "lock", "plug", "search",
    "settings", "shield", "sparkles", "target", "user-check", "users",
    "ai-brain", "placement", "resume", "interview", "risk", "campus",
    "automation", "monitor", "send", "refresh", "close", "chevron-right",
    "wand", "zap", "trending-up", "cpu", "mail", "phone", "book",
    "award", "upload", "eye", "message", "chevron-down", "lightbulb",
    "clipboard", "logout", "download", "share", "lock-open",
  ]);

  return allowed.has(icon as IconName) ? (icon as IconName) : "award";
};
// ═══════════════════════════════════════════════════════════════════════════
// MAIN PAGE
// ═══════════════════════════════════════════════════════════════════════════
export const StudentCertificates = () => {
  const { currentUser } = useAuth();
  const fullName = currentUser?.fullName || currentUser?.name || "Student";

  const [activeTab, setActiveTab] = useState<FilterTab>("all");
  const [earnedCertificates, setEarnedCertificates] = useState<EarnedCertificate[]>([]);
  const [inProgressCertificates, setInProgressCertificates] = useState<InProgressCertificate[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    let mounted = true;

    const loadCertificates = async () => {
      setLoading(true);
      setError("");

      try {
        const response = await studentApi.getCertificates();
        const payload = unwrapData<{
          earned: Array<Omit<EarnedCertificate, "icon"> & { icon?: string }>;
          inProgress: Array<Omit<InProgressCertificate, "icon"> & { icon?: string }>;
        }>(response);

        if (!mounted) return;
        setEarnedCertificates((payload.earned || []).map((certificate) => ({
          ...certificate,
          icon: toIconName(certificate.icon),
        })));
        setInProgressCertificates((payload.inProgress || []).map((certificate) => ({
          ...certificate,
          progress: Math.max(0, Math.min(100, Number(certificate.progress) || 0)),
          icon: toIconName(certificate.icon),
        })));
      } catch (loadError) {
        if (mounted) {
          setError(getApiErrorMessage(loadError));
          setEarnedCertificates([]);
          setInProgressCertificates([]);
        }
      } finally {
        if (mounted) setLoading(false);
      }
    };

    loadCertificates();

    return () => {
      mounted = false;
    };
  }, []);

  const showEarned = activeTab === "all" || activeTab === "earned";
  const showInProgress = activeTab === "all" || activeTab === "in-progress";

  return (
    <StudentLayout
      sidebarItems={sidebarItems}
      sidebarHighlight="Certificates"
      userSummary={{ fullName, role: "Student", status: "Placement track active" }}
      stats={{
        label: "Certificate count",
        value: String(earnedCertificates.length + inProgressCertificates.length),
        subtitle: "Verified",
        accent: "Verified",
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
            Loading certificates...
          </div>
        )}

        <section className="relative overflow-hidden rounded-3xl bg-[#5400D6] p-6 text-white shadow-lg sm:p-8">
          <div className="pointer-events-none absolute -right-16 -top-20 h-64 w-64 rounded-full bg-white/10 blur-3xl" />
          <div className="pointer-events-none absolute -bottom-24 left-1/3 h-48 w-48 rounded-full bg-white/10 blur-3xl" />

          <div className="relative flex flex-col gap-7 lg:flex-row lg:items-end lg:justify-between">
            <div className="max-w-2xl">
              <span className="inline-flex items-center gap-1.5 rounded-full border border-white/20 bg-white/10 px-3 py-1.5 text-[10px] font-bold uppercase tracking-wider">
                <Icon name="award" className="h-3.5 w-3.5" />
                Achievement center
              </span>

              <h1 className="mt-4 text-3xl font-black tracking-tight sm:text-4xl">
                Your Certificates
              </h1>

              <p className="mt-3 max-w-xl text-sm leading-6 text-white/75">
                Keep track of your verified achievements, share your credentials,
                and see which certifications you're currently working toward.
              </p>
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div className="min-w-[125px] rounded-2xl border border-white/15 bg-white/10 p-4 backdrop-blur">
                <Icon name="award" className="h-5 w-5 text-white/80" />
                <p className="mt-3 text-2xl font-black">{earnedCertificates.length}</p>
                <p className="mt-0.5 text-[9px] font-bold uppercase tracking-wider text-white/60">
                  Earned
                </p>
              </div>

              <div className="min-w-[125px] rounded-2xl border border-white/15 bg-white/10 p-4 backdrop-blur">
                <Icon name="clock" className="h-5 w-5 text-white/80" />
                <p className="mt-3 text-2xl font-black">{inProgressCertificates.length}</p>
                <p className="mt-0.5 text-[9px] font-bold uppercase tracking-wider text-white/60">
                  In progress
                </p>
              </div>
            </div>
          </div>
        </section>

        <section className="grid gap-3 sm:grid-cols-3">
          {[
            {
              label: "Total credentials",
              value: earnedCertificates.length + inProgressCertificates.length,
              icon: "award" as IconName,
              text: "#5400D6",
              bg: "#F4EFFF",
            },
            {
              label: "Verified achievements",
              value: earnedCertificates.length,
              icon: "check-circle" as IconName,
              text: "#059669",
              bg: "#ECFDF5",
            },
            {
              label: "Learning in progress",
              value: inProgressCertificates.length,
              icon: "trending-up" as IconName,
              text: "#D97706",
              bg: "#FFFBEB",
            },
          ].map((item) => (
            <div
              key={item.label}
              className="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm"
            >
              <div className="flex items-center gap-3">
                <div
                  className="flex h-10 w-10 items-center justify-center rounded-xl"
                  style={{ background: item.bg, color: item.text }}
                >
                  <Icon name={item.icon} className="h-4 w-4" />
                </div>
                <div>
                  <p className="text-2xl font-black text-slate-900">{item.value}</p>
                  <p className="text-[9px] font-bold uppercase tracking-wider text-slate-400">
                    {item.label}
                  </p>
                </div>
              </div>
            </div>
          ))}
        </section>

        <section className="rounded-2xl border border-slate-200 bg-white p-2 shadow-sm">
          <div className="flex flex-wrap gap-1.5">
            {filterTabs.map((tab) => (
              <button
                key={tab.key}
                onClick={() => setActiveTab(tab.key)}
                className={`rounded-xl px-4 py-2.5 text-xs font-bold transition ${
                  activeTab === tab.key
                    ? "bg-[#5400D6] text-white shadow-sm"
                    : "text-slate-500 hover:bg-[#F4EFFF] hover:text-[#5400D6]"
                }`}
              >
                {tab.label}
              </button>
            ))}
          </div>
        </section>

        {showEarned && (
          <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm sm:p-6">
            <div className="flex flex-col gap-2 sm:flex-row sm:items-end sm:justify-between">
              <div>
                <p className="text-[10px] font-bold uppercase tracking-widest text-[#5400D6]">
                  Verified achievements
                </p>
                <h2 className="mt-1 text-xl font-black text-slate-900">
                  Earned certificates
                </h2>
              </div>
              <p className="text-xs font-semibold text-slate-400">
                {earnedCertificates.length} credential{earnedCertificates.length === 1 ? "" : "s"}
              </p>
            </div>

            {earnedCertificates.length === 0 ? (
              <div className="mt-6 flex flex-col items-center rounded-2xl border border-dashed border-[#DCCBFF] bg-[#F4EFFF] py-14 text-center">
                <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-white text-[#5400D6] shadow-sm">
                  <Icon name="lock" className="h-5 w-5" />
                </div>
                <p className="mt-3 text-sm font-bold text-slate-700">No certificates yet</p>
                <p className="mt-1 max-w-sm text-xs leading-5 text-slate-400">
                  Complete your learning modules and assessments to earn your first verified credential.
                </p>
              </div>
            ) : (
              <div className="mt-5 grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
                {earnedCertificates.map((c) => (
                  <article
                    key={c.id}
                    className="group overflow-hidden rounded-2xl border border-slate-200 bg-white transition hover:-translate-y-0.5 hover:border-[#DCCBFF] hover:shadow-md"
                  >
                    <div
                      className="relative flex h-36 items-center justify-center overflow-hidden"
                      style={{ background: `linear-gradient(135deg, #5400D6, ${c.color})` }}
                    >
                      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(white_1px,transparent_1px)] opacity-10 [background-size:14px_14px]" />

                      <div className="relative flex h-16 w-16 items-center justify-center rounded-2xl bg-white/15 ring-1 ring-white/30 backdrop-blur">
                        <Icon name={c.icon} className="h-7 w-7 text-white" />
                      </div>

                      <span className="absolute right-3 top-3 inline-flex items-center gap-1 rounded-full bg-white/15 px-2.5 py-1 text-[8px] font-black uppercase tracking-wider text-white ring-1 ring-white/20 backdrop-blur">
                        <Icon name="check" className="h-2.5 w-2.5" />
                        Verified
                      </span>
                    </div>

                    <div className="p-4">
                      <h3 className="text-sm font-black leading-5 text-slate-900">
                        {c.title}
                      </h3>

                      <p className="mt-1 text-xs text-slate-400">{c.issuer}</p>

                      <div className="mt-4 grid grid-cols-2 gap-2">
                        <div className="rounded-xl bg-slate-50 p-2.5">
                          <p className="text-[8px] font-bold uppercase tracking-wider text-slate-400">
                            Issued
                          </p>
                          <p className="mt-1 text-[10px] font-bold text-slate-700">
                            {c.issuedOn}
                          </p>
                        </div>

                        <div className="rounded-xl bg-slate-50 p-2.5">
                          <p className="text-[8px] font-bold uppercase tracking-wider text-slate-400">
                            Credential
                          </p>
                          <p className="mt-1 truncate font-mono text-[9px] font-bold text-slate-700">
                            {c.credentialId}
                          </p>
                        </div>
                      </div>

                      <div className="mt-4 flex gap-2">
                        <button
                          type="button"
                          className="flex flex-1 items-center justify-center gap-1.5 rounded-xl bg-[#5400D6] py-2.5 text-[10px] font-bold text-white transition hover:bg-[#4500AD]"
                        >
                          <Icon name="download" className="h-3 w-3" />
                          Download
                        </button>

                        <button
                          type="button"
                          className="flex items-center justify-center gap-1.5 rounded-xl border border-slate-200 px-3 py-2.5 text-[10px] font-bold text-slate-600 transition hover:border-[#DCCBFF] hover:bg-[#F4EFFF] hover:text-[#5400D6]"
                        >
                          <Icon name="share" className="h-3 w-3" />
                          Share
                        </button>
                      </div>
                    </div>
                  </article>
                ))}
              </div>
            )}
          </section>
        )}

        {showInProgress && (
          <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm sm:p-6">
            <div className="flex items-end justify-between gap-3">
              <div>
                <p className="text-[10px] font-bold uppercase tracking-widest text-[#5400D6]">
                  Keep learning
                </p>
                <h2 className="mt-1 text-xl font-black text-slate-900">
                  Certificates in progress
                </h2>
              </div>
              <Icon name="lock-open" className="h-5 w-5 text-[#5400D6]" />
            </div>

            {inProgressCertificates.length === 0 ? (
              <div className="mt-5 rounded-2xl border border-dashed border-slate-200 bg-slate-50 p-8 text-center">
                <p className="text-xs font-semibold text-slate-500">
                  No certifications are currently in progress.
                </p>
              </div>
            ) : (
              <div className="mt-5 grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
                {inProgressCertificates.map((c) => (
                  <article
                    key={c.id}
                    className="rounded-2xl border border-slate-200 bg-slate-50 p-4 transition hover:border-[#DCCBFF] hover:bg-[#F4EFFF]/50"
                  >
                    <div className="flex items-start gap-3">
                      <div className="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-xl bg-white shadow-sm ring-1 ring-slate-200">
                        <Icon
                          name={c.icon}
                          className="h-4 w-4"
                          style={{ color: c.color } as React.CSSProperties}
                        />
                      </div>

                      <div className="min-w-0 flex-1">
                        <h3 className="text-xs font-black leading-5 text-slate-800">
                          {c.title}
                        </h3>
                        <p className="mt-0.5 text-[9px] text-slate-400">
                          Certificate progress
                        </p>
                      </div>

                      <span className="text-sm font-black text-[#5400D6]">
                        {c.progress}%
                      </span>
                    </div>

                    <div className="mt-4 h-2 overflow-hidden rounded-full bg-slate-200">
                      <div
                        className="h-full rounded-full transition-all duration-500"
                        style={{
                          width: `${c.progress}%`,
                          background: "#5400D6",
                        }}
                      />
                    </div>

                    <div className="mt-3 flex items-center justify-between">
                      <p className="text-[9px] font-semibold text-slate-400">
                        {c.progress >= 80
                          ? "Almost there"
                          : "Continue the module to unlock your certificate."}
                      </p>
                      <Icon name="chevron-right" className="h-3 w-3 text-slate-300" />
                    </div>
                  </article>
                ))}
              </div>
            )}
          </section>
        )}
      </div>
    </StudentLayout>
  );
};

export default StudentCertificates;