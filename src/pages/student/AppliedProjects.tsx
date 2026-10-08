import { useState } from "react";
import { useAuth } from "../../context/AuthContext";
import StudentLayout from "../../components/student/StudentLayout";

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

const sidebarItems: Array<{ label: string; icon: IconName; route: string; badge?: number }> = [
  { label: "Dashboard", icon: "dashboard", route: "/student-dashboard" },
  { label: "My Profile", icon: "user-check", route: "/student/profile" },
  { label: "Project List", icon: "briefcase", route: "/student/projects" },
  { label: "Applied Projects", icon: "clipboard", route: "/student/applied-projects", badge: 2 },
  { label: "Notifications", icon: "bell", route: "/student/notifications", badge: 3 },
  { label: "Certificates", icon: "award", route: "/student/certificates" },
  { label: "Settings", icon: "settings", route: "/student/settings" },
  { label: "AI Resume Builder", icon: "resume" , route: "/student/airesume" },
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

const appliedProjects: AppliedProject[] = [
  {
    id: "p1", title: "Frontend Developer Intern", company: "Nexbyte Technologies", location: "Bengaluru, IN",
    appliedOn: "18 Jun 2026", status: "Interview Scheduled", stipend: "₹15,000/mo",
    skills: ["React", "Tailwind CSS", "JavaScript"],
  },
  {
    id: "p2", title: "Data Analyst Trainee", company: "Insight Grid Analytics", location: "Remote",
    appliedOn: "10 Jun 2026", status: "Under Review", stipend: "₹12,000/mo",
    skills: ["Python", "SQL", "Power BI"],
  },
  {
    id: "p3", title: "Backend Engineer Intern", company: "CloudForge Systems", location: "Pune, IN",
    appliedOn: "02 Jun 2026", status: "Applied", stipend: "₹18,000/mo",
    skills: ["Node.js", "MongoDB", "REST APIs"],
  },
  {
    id: "p4", title: "Full Stack Developer", company: "Verve Software Labs", location: "Hyderabad, IN",
    appliedOn: "24 May 2026", status: "Accepted", stipend: "₹20,000/mo",
    skills: ["React", "Express", "PostgreSQL"],
  },
  {
    id: "p5", title: "QA Automation Intern", company: "Pixel Forge Studio", location: "Remote",
    appliedOn: "15 May 2026", status: "Rejected", stipend: "₹10,000/mo",
    skills: ["Selenium", "Java", "Testing"],
  },
];

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
// MAIN PAGE
// ═══════════════════════════════════════════════════════════════════════════
export const StudentAppliedProjects = () => {
  const { currentUser } = useAuth();
  const fullName = currentUser?.fullName || "Yuvraj Singh";

  const [activeTab, setActiveTab] = useState<FilterTab>("all");

  const filtered = appliedProjects.filter((p) => activeTab === "all" || p.status === activeTab);

  const counts: Record<FilterTab, number> = {
    all: appliedProjects.length,
    Applied: appliedProjects.filter((p) => p.status === "Applied").length,
    "Under Review": appliedProjects.filter((p) => p.status === "Under Review").length,
    "Interview Scheduled": appliedProjects.filter((p) => p.status === "Interview Scheduled").length,
    Accepted: appliedProjects.filter((p) => p.status === "Accepted").length,
    Rejected: appliedProjects.filter((p) => p.status === "Rejected").length,
  };

  return (
    <StudentLayout
      sidebarItems={sidebarItems}
      sidebarHighlight="Applied Projects"
      userSummary={{ fullName, role: "B.Tech CSE · 4th Year", status: "Placement track active" }}
      stats={{ label: "Application success", value: "75%", subtitle: "3 of 4 progressing", accent: "Good" }}
      showAiButton={false}
    >
      <div className="space-y-5">

            {/* Page header banner */}
            <div className="relative overflow-hidden rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
              <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(#e0e7ff_1px,transparent_1px)] opacity-60 [background-size:18px_18px]" />
              <div className="pointer-events-none absolute right-0 top-0 h-48 w-48 rounded-full bg-blue-100/60 blur-3xl" />
              <div className="relative">
                <span className="inline-flex items-center gap-1.5 rounded-full border border-blue-100 bg-blue-50 px-3 py-1 text-[11px] font-bold text-blue-700">
                  <Icon name="clipboard" className="h-3 w-3" />
                  Track your applications
                </span>
                <h1 className="mt-3 text-2xl font-black tracking-tight text-slate-900 sm:text-3xl">Applied Projects</h1>
                <p className="mt-2 max-w-xl text-sm leading-6 text-slate-500">
                  Follow the status of every project you've applied to, from submission through offer.
                </p>
              </div>
            </div>

            {/* Stats row */}
            <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-5">
              {(["Applied", "Under Review", "Interview Scheduled", "Accepted", "Rejected"] as AppStatus[]).map((s) => (
                <article key={s} className="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
                  <div className="flex items-center gap-2.5">
                    <div className="flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-lg" style={{ background: `${statusMeta[s].dot}1a` }}>
                      <Icon name={statusMeta[s].icon} className="h-3.5 w-3.5" style={{ color: statusMeta[s].dot } as React.CSSProperties} />
                    </div>
                    <p className="text-[11px] font-bold leading-4 text-slate-500">{s}</p>
                  </div>
                  <p className="mt-2 text-2xl font-black text-slate-900">{counts[s]}</p>
                </article>
              ))}
            </div>

            {/* Filter tabs */}
            <div className="rounded-2xl border border-slate-200 bg-white p-2 shadow-sm">
              <div className="flex flex-wrap gap-1.5">
                {filterTabs.map((tab) => (
                  <button key={tab.key} onClick={() => setActiveTab(tab.key)}
                    className={`rounded-xl px-3.5 py-2 text-xs font-bold transition ${
                      activeTab === tab.key ? "bg-slate-900 text-white shadow-sm" : "text-slate-500 hover:bg-slate-50 hover:text-slate-800"
                    }`}>
                    {tab.label} <span className="ml-1 opacity-60">{counts[tab.key]}</span>
                  </button>
                ))}
              </div>
            </div>

            {/* Applied project list */}
            <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-[10px] font-bold uppercase tracking-widest text-slate-400">Applications</p>
                  <h2 className="mt-0.5 text-lg font-black text-slate-900">
                    {activeTab === "all" ? "All applications" : activeTab}
                  </h2>
                </div>
                <Icon name="briefcase" className="h-4 w-4 text-slate-300" />
              </div>

              {filtered.length === 0 ? (
                <div className="mt-6 flex flex-col items-center gap-2 rounded-xl border border-dashed border-slate-200 bg-slate-50 py-12 text-center">
                  <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-white ring-1 ring-slate-200">
                    <Icon name="clipboard" className="h-4 w-4 text-slate-300" />
                  </div>
                  <p className="text-sm font-bold text-slate-600">No applications here</p>
                  <p className="text-xs text-slate-400">Nothing matches this filter yet.</p>
                </div>
              ) : (
                <div className="mt-4 space-y-3">
                  {filtered.map((p) => {
                    const meta = statusMeta[p.status];
                    return (
                      <div key={p.id} className="rounded-xl border border-slate-100 bg-slate-50 p-4 transition hover:border-slate-200">
                        <div className="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
                          <div className="min-w-0 flex-1">
                            <div className="flex items-center gap-2">
                              <h3 className="text-[14px] font-bold text-slate-900">{p.title}</h3>
                              <span className={`inline-flex flex-shrink-0 items-center gap-1 rounded-full px-2 py-0.5 text-[10px] font-bold ring-1 ${meta.cls}`}>
                                <Icon name={meta.icon} className="h-3 w-3" />
                                {p.status}
                              </span>
                            </div>
                            <div className="mt-1.5 flex flex-wrap items-center gap-x-3 gap-y-1 text-[11px] text-slate-500">
                              <span className="flex items-center gap-1"><Icon name="building" className="h-3 w-3" />{p.company}</span>
                              <span className="flex items-center gap-1"><Icon name="map-pin" className="h-3 w-3" />{p.location}</span>
                              <span className="flex items-center gap-1"><Icon name="calendar" className="h-3 w-3" />Applied {p.appliedOn}</span>
                            </div>
                            <div className="mt-2.5 flex flex-wrap gap-1.5">
                              {p.skills.map((sk) => (
                                <span key={sk} className="rounded-full bg-white px-2 py-0.5 text-[10px] font-semibold text-slate-600 ring-1 ring-slate-200">{sk}</span>
                              ))}
                            </div>
                          </div>
                          <div className="flex flex-shrink-0 flex-col items-start gap-2 sm:items-end">
                            <span className="text-sm font-black text-slate-900">{p.stipend}</span>
                            <button className="inline-flex items-center gap-1.5 rounded-lg border border-slate-200 bg-white px-3 py-1.5 text-[11px] font-bold text-slate-600 transition hover:border-blue-200 hover:bg-blue-50 hover:text-blue-700">
                              <Icon name="eye" className="h-3 w-3" />
                              View details
                            </button>
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </section>
      </div>
    </StudentLayout>
  );
};

export default StudentAppliedProjects;