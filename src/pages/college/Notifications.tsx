import { useMemo, useState } from "react";
import { useAuth } from "../../context/AuthContext";
import {
  PieChart,
  Pie,
  Cell,
  Legend,
  Tooltip,
  ResponsiveContainer,
} from "recharts";
import CollegeLayout from "../../components/college/CollegeLayout";

// ─── Icon System (matches Admin / Dashboard) ──────────────────────────────────
type IconName =
  | "activity" | "alert" | "arrow-up" | "arrow-down" | "bell" | "briefcase"
  | "building" | "calendar" | "chart" | "check" | "clock" | "dashboard"
  | "database" | "file" | "graduation" | "lock" | "plug" | "search"
  | "settings" | "shield" | "sparkles" | "target" | "user-check" | "users"
  | "ai-brain" | "placement" | "resume" | "interview" | "risk" | "campus"
  | "automation" | "monitor" | "send" | "refresh" | "close" | "chevron-right"
  | "wand" | "zap" | "trending-up" | "cpu" | "mail" | "phone" | "book"
  | "award" | "upload" | "eye" | "message" | "chevron-down" | "lightbulb"
  | "clipboard" | "logout" | "trash" | "dot";

const Icon = ({ name, className = "h-4 w-4" }: { name: IconName; className?: string }) => {
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
    trash: <><path d="M4 7h16" /><path d="M9 7V4h6v3" /><path d="M6 7l1 13a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2l1-13" /><path d="M10 11v6" /><path d="M14 11v6" /></>,
    dot: <circle cx="12" cy="12" r="4" />,
  };
  return (
    <svg className={className} fill="none" stroke="currentColor" strokeLinecap="round"
      strokeLinejoin="round" strokeWidth="2" viewBox="0 0 24 24" aria-hidden="true">
      {paths[name]}
    </svg>
  );
};

const getInitials = (name: string) =>
  name.trim().split(/\s+/).map((n) => n[0]).join("").toUpperCase().slice(0, 2) || "TP";

// Sidebar kept identical to Dashboard Home so navigation stays consistent.
export const sidebarItems: Array<{
  label: string;
  icon: IconName;
  route: string;
  active?: boolean;
  badge?: number;
}> = [
  { label: "Dashboard", icon: "dashboard", route: "/college-dashboard" },
  { label: "Student Management", icon: "users", route: "/college/students-management" },
  { label: "Recruiter Management", icon: "building", route: "/college/recruiter-management" },
  { label: "Placement Statistics", icon: "briefcase", route: "/college/placement-statistics", badge: 5 },
  { label: "Notifications", icon: "bell", route: "/college/notifications", badge: 3 },
  { label: "Profile", icon: "settings", route: "/college/profile" },
  { label: "Settings", icon: "settings", route: "/college/settings" },
];

const useCollegeProfile = () => {
  const { currentUser } = useAuth();
  const fullName = currentUser?.fullName || "BITS Pilani Placement Cell Admin";
  const firstName = fullName.split(" ")[0] || "Admin";
  const initials = getInitials(fullName);
  return { fullName, firstName, initials };
};

// ─── Types & seed data ───────────────────────────────────────────────────────
type NotifCategory = "placement" | "recruiter" | "student" | "system";

interface Notification {
  id: string;
  category: NotifCategory;
  icon: IconName;
  tone: "blue" | "emerald" | "amber" | "rose" | "violet";
  title: string;
  message: string;
  time: string;
  read: boolean;
}

const initialNotifications: Notification[] = [
  { id: "n1", category: "placement", icon: "check", tone: "emerald", title: "Ishaan Verma became placement eligible", message: "Skill score crossed the 70 threshold after this week's mock test.", time: "5 min ago", read: false },
  { id: "n2", category: "recruiter", icon: "building", tone: "blue", title: "New recruiter registered: Deloitte", message: "Deloitte has completed onboarding and can now post drives.", time: "22 min ago", read: false },
  { id: "n3", category: "placement", icon: "briefcase", tone: "violet", title: "TCS drive shortlist published", message: "142 students shortlisted for the aptitude round on 28 Jun.", time: "38 min ago", read: false },
  { id: "n4", category: "student", icon: "resume", tone: "amber", title: "36 students updated their resumes", message: "Review the CSE and IT batch resumes before the next drive.", time: "1 hr ago", read: true },
  { id: "n5", category: "recruiter", icon: "eye", tone: "blue", title: "Recruiter from TCS viewed 12 profiles", message: "Profiles viewed from the CSE final-year shortlist.", time: "2 hr ago", read: true },
  { id: "n6", category: "placement", icon: "calendar", tone: "rose", title: "Upcoming placement drive: Infosys", message: "Final interview round scheduled for 5 Jul, 10:00 AM onward.", time: "3 hr ago", read: true },
  { id: "n7", category: "system", icon: "shield", tone: "blue", title: "Scheduled maintenance tonight", message: "The placement portal will be briefly unavailable from 1–2 AM IST.", time: "5 hr ago", read: true },
  { id: "n8", category: "student", icon: "alert", tone: "rose", title: "22 students inactive for 2+ weeks", message: "No learning activity recorded since the last skill assessment.", time: "6 hr ago", read: false },
  { id: "n9", category: "recruiter", icon: "check", tone: "emerald", title: "Wipro confirmed drive date", message: "On-campus recruitment confirmed for 24 May, CSE and ECE eligible.", time: "1 day ago", read: true },
  { id: "n10", category: "system", icon: "database", tone: "violet", title: "Weekly data backup completed", message: "All student and placement records backed up successfully.", time: "1 day ago", read: true },
];

const toneCls: Record<Notification["tone"], string> = {
  emerald: "bg-emerald-50 text-emerald-600",
  blue: "bg-blue-50 text-blue-600",
  violet: "bg-violet-50 text-violet-600",
  amber: "bg-amber-50 text-amber-600",
  rose: "bg-rose-50 text-rose-600",
};

const categoryLabel: Record<NotifCategory, string> = {
  placement: "Placement",
  recruiter: "Recruiter",
  student: "Student",
  system: "System",
};

const categoryColor: Record<NotifCategory, string> = {
  placement: "#2563eb",
  recruiter: "#10b981",
  student: "#f59e0b",
  system: "#8b5cf6",
};

// ═══════════════════════════════════════════════════════════════════════════
// PAGE
// ═══════════════════════════════════════════════════════════════════════════
export const Notifications = () => {
  const { fullName, firstName } = useCollegeProfile();
  const [notifications, setNotifications] = useState<Notification[]>(initialNotifications);
  const [filter, setFilter] = useState<"all" | "unread" | NotifCategory>("all");

  const unreadCount = notifications.filter((n) => !n.read).length;

  const filtered = useMemo(() => {
    if (filter === "all") return notifications;
    if (filter === "unread") return notifications.filter((n) => !n.read);
    return notifications.filter((n) => n.category === filter);
  }, [notifications, filter]);

  const categoryBreakdown = useMemo(() => {
    const counts: Record<NotifCategory, number> = { placement: 0, recruiter: 0, student: 0, system: 0 };
    notifications.forEach((n) => { counts[n.category] += 1; });
    return (Object.keys(counts) as NotifCategory[]).map((c) => ({
      name: categoryLabel[c],
      value: counts[c],
      color: categoryColor[c],
    }));
  }, [notifications]);

  const markAsRead = (id: string) =>
    setNotifications((prev) => prev.map((n) => (n.id === id ? { ...n, read: true } : n)));

  const markAllAsRead = () =>
    setNotifications((prev) => prev.map((n) => ({ ...n, read: true })));

  const dismiss = (id: string) =>
    setNotifications((prev) => prev.filter((n) => n.id !== id));

  const filterTabs: Array<{ key: typeof filter; label: string }> = [
    { key: "all", label: "All" },
    { key: "unread", label: `Unread${unreadCount ? ` (${unreadCount})` : ""}` },
    { key: "placement", label: "Placement" },
    { key: "recruiter", label: "Recruiter" },
    { key: "student", label: "Student" },
    { key: "system", label: "System" },
  ];

  return (
    <CollegeLayout
      
      sidebarHighlight="Notifications"
      userSummary={{ fullName, role: "Training & Placement Officer", status: "Placement cycle active" }}
      stats={{ label: "Unread notifications", value: String(unreadCount), subtitle: "Needs review", accent: "Live" }}
    >
      <>
        {/* Hero banner */}
        <div className="relative overflow-hidden rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(#e0e7ff_1px,transparent_1px)] opacity-60 [background-size:18px_18px]" />
          <div className="pointer-events-none absolute right-0 top-0 h-48 w-48 rounded-full bg-blue-100/60 blur-3xl" />
          <div className="relative flex flex-wrap items-start justify-between gap-4">
            <div>
              <span className="inline-flex items-center gap-1.5 rounded-full border border-blue-100 bg-blue-50 px-3 py-1 text-[11px] font-bold text-blue-700">
                <Icon name="bell" className="h-3 w-3" />
                Notification center
              </span>
              <h1 className="mt-3 text-2xl font-black tracking-tight text-slate-900 sm:text-3xl">
                Notifications
              </h1>
              <p className="mt-2 max-w-2xl text-sm leading-6 text-slate-500">
                Hi {firstName}, stay on top of placement drives, recruiter activity, and student updates as they happen.
              </p>
            </div>
            <button onClick={markAllAsRead} disabled={unreadCount === 0}
              className="flex items-center gap-2 rounded-xl bg-slate-900 px-4 py-2.5 text-xs font-bold text-white transition hover:bg-slate-800 disabled:cursor-not-allowed disabled:opacity-40">
              <Icon name="check" className="h-3.5 w-3.5" />
              Mark all as read
            </button>
          </div>
        </div>

        {/* Summary row + category chart */}
        <div className="grid gap-5 xl:grid-cols-[1.3fr_0.7fr]">
          <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
            {[
              { label: "Total notifications", value: String(notifications.length), icon: "bell" as IconName, bg: "#eff6ff" },
              { label: "Unread", value: String(unreadCount), icon: "alert" as IconName, bg: "#fef2f2" },
              { label: "Placement related", value: String(notifications.filter((n) => n.category === "placement").length), icon: "briefcase" as IconName, bg: "#f5f3ff" },
              { label: "Recruiter activity", value: String(notifications.filter((n) => n.category === "recruiter").length), icon: "building" as IconName, bg: "#ecfdf5" },
            ].map((s) => (
              <article key={s.label} className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
                <div className="flex h-10 w-10 items-center justify-center rounded-xl" style={{ background: s.bg }}>
                  <Icon name={s.icon} className="h-4.5 w-4.5 text-slate-700" />
                </div>
                <p className="mt-4 text-[11px] font-bold uppercase tracking-wider text-slate-400">{s.label}</p>
                <p className="mt-0.5 text-2xl font-black tracking-tight text-slate-900">{s.value}</p>
              </article>
            ))}
          </div>

          <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
            <p className="text-[10px] font-bold uppercase tracking-widest text-slate-400">Breakdown</p>
            <h2 className="mt-0.5 text-sm font-black text-slate-900">Notifications by category</h2>
            <div className="mt-2" style={{ height: 150 }}>
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie data={categoryBreakdown} dataKey="value" nameKey="name" innerRadius={40} outerRadius={60} paddingAngle={3}>
                    {categoryBreakdown.map((entry, i) => (
                      <Cell key={i} fill={entry.color} />
                    ))}
                  </Pie>
                  <Legend verticalAlign="bottom" height={20} iconType="circle" wrapperStyle={{ fontSize: "10px" }} />
                  <Tooltip contentStyle={{ backgroundColor: "#0f172a", borderRadius: "8px", border: "none", color: "#f8fafc", fontSize: "12px" }} />
                </PieChart>
              </ResponsiveContainer>
            </div>
          </section>
        </div>

        {/* Filter tabs + list */}
        <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
          <div className="flex flex-wrap items-center gap-1.5">
            {filterTabs.map((t) => (
              <button key={t.key} onClick={() => setFilter(t.key)}
                className={`rounded-full px-3 py-1.5 text-[11px] font-bold transition ${
                  filter === t.key ? "bg-slate-900 text-white" : "border border-slate-200 text-slate-500 hover:bg-slate-50"
                }`}>
                {t.label}
              </button>
            ))}
          </div>

          <div className="mt-4 overflow-hidden rounded-xl border border-slate-200">
            {filtered.length === 0 && (
              <div className="flex flex-col items-center gap-2 p-10 text-center">
                <Icon name="bell" className="h-6 w-6 text-slate-300" />
                <p className="text-xs font-semibold text-slate-400">No notifications in this view.</p>
              </div>
            )}
            {filtered.map((n, i) => (
              <div key={n.id}
                className={`flex items-start gap-3 p-4 ${i < filtered.length - 1 ? "border-b border-slate-100" : ""} ${
                  n.read ? "bg-white" : "bg-blue-50/30"
                } transition hover:bg-slate-50/60`}>
                <div className={`flex h-9 w-9 flex-shrink-0 items-center justify-center rounded-lg ${toneCls[n.tone]}`}>
                  <Icon name={n.icon} className="h-4 w-4" />
                </div>
                <div className="min-w-0 flex-1">
                  <div className="flex items-center gap-2">
                    {!n.read && <span className="h-1.5 w-1.5 flex-shrink-0 rounded-full bg-blue-600" />}
                    <p className={`truncate text-[13px] ${n.read ? "font-semibold text-slate-700" : "font-bold text-slate-900"}`}>{n.title}</p>
                  </div>
                  <p className="mt-0.5 text-[11px] leading-5 text-slate-500">{n.message}</p>
                  <div className="mt-1.5 flex items-center gap-2">
                    <span className="rounded-full bg-slate-100 px-2 py-0.5 text-[10px] font-bold text-slate-500">
                      {categoryLabel[n.category]}
                    </span>
                    <span className="text-[10px] font-semibold text-slate-400">{n.time}</span>
                  </div>
                </div>
                <div className="flex flex-shrink-0 items-center gap-1">
                  {!n.read && (
                    <button onClick={() => markAsRead(n.id)} title="Mark as read"
                      className="flex h-7 w-7 items-center justify-center rounded-lg text-slate-400 transition hover:bg-emerald-50 hover:text-emerald-600">
                      <Icon name="check" className="h-3.5 w-3.5" />
                    </button>
                  )}
                  <button onClick={() => dismiss(n.id)} title="Dismiss"
                    className="flex h-7 w-7 items-center justify-center rounded-lg text-slate-400 transition hover:bg-rose-50 hover:text-rose-600">
                    <Icon name="trash" className="h-3.5 w-3.5" />
                  </button>
                </div>
              </div>
            ))}
          </div>
        </section>
      </>
    </CollegeLayout>
  );
};

export default Notifications;