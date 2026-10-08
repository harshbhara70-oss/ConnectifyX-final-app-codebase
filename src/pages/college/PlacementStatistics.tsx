import { useState } from "react";
import { useAuth } from "../../context/AuthContext";
import {
  AreaChart,
  Area,
  BarChart,
  Bar,
  PieChart,
  Pie,
  Cell,
  Legend,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  CartesianGrid,
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
  | "clipboard" | "logout" | "coin" | "filter";

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
    coin: <><circle cx="12" cy="12" r="9" /><path d="M9 9.5a3 2.2 0 0 1 3-1.5 3 2.2 0 0 1 3 1.5c0 1.2-1.3 1.7-3 2.2s-3 1-3 2.2a3 2.2 0 0 0 3 1.6 3 2.2 0 0 0 3-1.5" /><path d="M12 6.5v11" /></>,
    filter: <path d="M4 5h16l-6 8v5l-4 2v-7L4 5Z" />,
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

// ─── Data ──────────────────────────────────────────────────────────────────
const kpiCards = [
  { label: "Registered students", value: "1240", change: "+38", up: true, icon: "users" as IconName, bg: "#eff6ff" },
  { label: "Placed students", value: "610", change: "+42", up: true, icon: "check" as IconName, bg: "#ecfdf5" },
  { label: "Placement rate", value: "71%", change: "+4%", up: true, icon: "target" as IconName, bg: "#f5f3ff" },
  { label: "Companies visited", value: "34", change: "+6", up: true, icon: "building" as IconName, bg: "#fffbeb" },
  { label: "Average CTC", value: "₹6.8 LPA", change: "+0.6", up: true, icon: "coin" as IconName, bg: "#eff6ff" },
  { label: "Highest CTC", value: "₹42 LPA", change: "+2", up: true, icon: "award" as IconName, bg: "#fdf2f8" },
  { label: "Offers this month", value: "86", change: "+21", up: true, icon: "briefcase" as IconName, bg: "#ecfdf5" },
  { label: "Active drives", value: "5", change: "+1", up: true, icon: "clipboard" as IconName, bg: "#f5f3ff" },
];

const placementTrend = [
  { month: "Jan", rate: 60, offers: 48 },
  { month: "Feb", rate: 66, offers: 61 },
  { month: "Mar", rate: 71, offers: 74 },
  { month: "Apr", rate: 77, offers: 88 },
  { month: "May", rate: 82, offers: 96 },
];

const departmentPlacement = [
  { dept: "CSE", rate: 82, color: "#2563eb" },
  { dept: "IT", rate: 76, color: "#f59e0b" },
  { dept: "ECE", rate: 68, color: "#10b981" },
  { dept: "Mech", rate: 54, color: "#8b5cf6" },
];

const eligibleVsPlaced = [
  { name: "Placed", value: 610, color: "#2563eb" },
  { name: "Eligible, not placed", value: 250, color: "#f59e0b" },
  { name: "Not yet eligible", value: 380, color: "#e2e8f0" },
];

const ctcDistribution = [
  { band: "< ₹4 LPA", count: 96 },
  { band: "₹4–6 LPA", count: 214 },
  { band: "₹6–8 LPA", count: 178 },
  { band: "₹8–10 LPA", count: 82 },
  { band: "₹10–15 LPA", count: 30 },
  { band: "₹15+ LPA", count: 10 },
];

const companyOffers = [
  { company: "TCS", offers: 142 },
  { company: "Infosys", offers: 118 },
  { company: "Accenture", offers: 96 },
  { company: "Microsoft", offers: 34 },
  { company: "Deloitte", offers: 58 },
  { company: "Wipro", offers: 88 },
];

const branchAvgCtc = [
  { title: "Computer Science & Engg.", value: "₹8.4 LPA", progress: 88, color: "#2563eb" },
  { title: "Information Technology", value: "₹7.1 LPA", progress: 74, color: "#f59e0b" },
  { title: "Electronics & Communication", value: "₹6.0 LPA", progress: 62, color: "#10b981" },
  { title: "Mechanical Engineering", value: "₹4.8 LPA", progress: 48, color: "#8b5cf6" },
];

const driveSummary = [
  { company: "TCS", date: "25 Jun 2026", appeared: 420, selected: 142, conversion: 34 },
  { company: "Infosys", date: "12 Jun 2026", appeared: 380, selected: 118, conversion: 31 },
  { company: "Accenture", date: "02 Jun 2026", appeared: 310, selected: 96, conversion: 31 },
  { company: "Wipro", date: "24 May 2026", appeared: 265, selected: 88, conversion: 33 },
  { company: "Deloitte", date: "14 May 2026", appeared: 190, selected: 58, conversion: 31 },
  { company: "Microsoft", date: "05 May 2026", appeared: 140, selected: 34, conversion: 24 },
];

// ─── Section header ────────────────────────────────────────────────────────
const SectionHeader = ({ eyebrow, title, sub, icon, iconColor = "#2563eb" }:
  { eyebrow: string; title: string; sub?: string; icon: IconName; iconColor?: string }) => (
  <div className="flex items-start justify-between">
    <div>
      <p className="text-[10px] font-bold uppercase tracking-widest text-slate-400">{eyebrow}</p>
      <h2 className="mt-0.5 flex items-center gap-2 text-lg font-black text-slate-900">
        <span style={{ color: iconColor }}>
          <Icon name={icon} className="h-4 w-4" />
        </span>
        {title}
      </h2>
      {sub && <p className="mt-1 text-xs text-slate-400">{sub}</p>}
    </div>
  </div>
);

// ═══════════════════════════════════════════════════════════════════════════
// PAGE
// ═══════════════════════════════════════════════════════════════════════════
export const PlacementStatistics = () => {
  const { fullName, firstName } = useCollegeProfile();
  const [driveFilter, setDriveFilter] = useState<"all" | "high" | "low">("all");

  const filteredDrives = driveSummary.filter((d) => {
    if (driveFilter === "high") return d.conversion >= 32;
    if (driveFilter === "low") return d.conversion < 32;
    return true;
  });

  return (
    <CollegeLayout
      sidebarHighlight="Placement Statistics"
      userSummary={{ fullName, role: "Training & Placement Officer", status: "Placement cycle active" }}
      stats={{ label: "Overall placement rate", value: "82", subtitle: "This cycle", accent: "This cycle" }}
    >
      <>
        {/* Hero banner */}
        <div className="relative overflow-hidden rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(#e0e7ff_1px,transparent_1px)] opacity-60 [background-size:18px_18px]" />
          <div className="pointer-events-none absolute right-0 top-0 h-48 w-48 rounded-full bg-blue-100/60 blur-3xl" />
          <div className="relative">
            <span className="inline-flex items-center gap-1.5 rounded-full border border-blue-100 bg-blue-50 px-3 py-1 text-[11px] font-bold text-blue-700">
              <Icon name="chart" className="h-3 w-3" />
              Placement analytics
            </span>
            <h1 className="mt-3 text-2xl font-black tracking-tight text-slate-900 sm:text-3xl">
              Placement Statistics
            </h1>
            <p className="mt-2 max-w-2xl text-sm leading-6 text-slate-500">
              Hi {firstName}, here's a full breakdown of placement rate, package distribution, and drive-wise
              conversion across departments for the current cycle.
            </p>
          </div>
        </div>

        {/* KPI grid */}
        <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
          {kpiCards.map((s) => (
            <article key={s.label}
              className="group cursor-default rounded-2xl border border-slate-200 bg-white p-5 shadow-sm transition hover:-translate-y-0.5 hover:shadow-md">
              <div className="flex items-start justify-between">
                <div className="flex h-10 w-10 items-center justify-center rounded-xl" style={{ background: s.bg }}>
                  <Icon name={s.icon} className="h-4.5 w-4.5 text-slate-700" />
                </div>
                <span className={`inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[11px] font-bold ${s.up ? "bg-emerald-50 text-emerald-700 ring-1 ring-emerald-100" : "bg-rose-50 text-rose-700 ring-1 ring-rose-100"}`}>
                  <Icon name={s.up ? "arrow-up" : "arrow-down"} className="h-3 w-3" />
                  {s.change}
                </span>
              </div>
              <p className="mt-4 text-[11px] font-bold uppercase tracking-wider text-slate-400">{s.label}</p>
              <p className="mt-0.5 text-3xl font-black tracking-tight text-slate-900">{s.value}</p>
            </article>
          ))}
        </div>

        {/* Placement rate + offers trend */}
        <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
          <SectionHeader eyebrow="Cycle Trend" title="Placement rate & offers over time" icon="trending-up" iconColor="#2563eb" />
          <div className="mt-4 grid gap-4 lg:grid-cols-2">
            <div>
              <p className="mb-2 text-[11px] font-bold text-slate-500">Placement rate (%)</p>
              <div style={{ height: 200 }}>
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={placementTrend} margin={{ top: 5, right: 10, left: -20, bottom: 0 }}>
                    <defs>
                      <linearGradient id="rateColor" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#2563eb" stopOpacity={0.25} />
                        <stop offset="95%" stopColor="#2563eb" stopOpacity={0} />
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                    <XAxis dataKey="month" axisLine={false} tickLine={false} tick={{ fill: "#94a3b8", fontSize: 11 }} />
                    <YAxis axisLine={false} tickLine={false} tick={{ fill: "#94a3b8", fontSize: 11 }} />
                    <Tooltip contentStyle={{ backgroundColor: "#0f172a", borderRadius: "8px", border: "none", color: "#f8fafc", fontSize: "12px" }} />
                    <Area type="monotone" dataKey="rate" stroke="#2563eb" strokeWidth={2} fillOpacity={1} fill="url(#rateColor)" />
                  </AreaChart>
                </ResponsiveContainer>
              </div>
            </div>
            <div>
              <p className="mb-2 text-[11px] font-bold text-slate-500">Offers rolled out</p>
              <div style={{ height: 200 }}>
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={placementTrend} margin={{ top: 5, right: 10, left: -20, bottom: 0 }}>
                    <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                    <XAxis dataKey="month" axisLine={false} tickLine={false} tick={{ fill: "#94a3b8", fontSize: 11 }} />
                    <YAxis axisLine={false} tickLine={false} tick={{ fill: "#94a3b8", fontSize: 11 }} />
                    <Tooltip contentStyle={{ backgroundColor: "#0f172a", borderRadius: "8px", border: "none", color: "#f8fafc", fontSize: "12px" }} />
                    <Bar dataKey="offers" radius={[6, 6, 0, 0]} fill="#10b981" />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </div>
          </div>
        </section>

        {/* Department placement + eligibility split */}
        <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
          <SectionHeader eyebrow="Department Breakdown" title="Placement rate by department" icon="book" iconColor="#8b5cf6" />
          <div className="mt-4 grid gap-6 lg:grid-cols-2">
            <div style={{ height: 220 }}>
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={departmentPlacement} margin={{ top: 5, right: 10, left: -20, bottom: 0 }}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                  <XAxis dataKey="dept" axisLine={false} tickLine={false} tick={{ fill: "#94a3b8", fontSize: 11 }} />
                  <YAxis axisLine={false} tickLine={false} tick={{ fill: "#94a3b8", fontSize: 11 }} />
                  <Tooltip contentStyle={{ backgroundColor: "#0f172a", borderRadius: "8px", border: "none", color: "#f8fafc", fontSize: "12px" }} />
                  <Bar dataKey="rate" radius={[6, 6, 0, 0]}>
                    {departmentPlacement.map((d, i) => (
                      <Cell key={i} fill={d.color} />
                    ))}
                  </Bar>
                </BarChart>
              </ResponsiveContainer>
            </div>
            <div>
              <p className="mb-2 text-[11px] font-bold text-slate-500">Eligible students — placed vs pending</p>
              <div style={{ height: 190 }}>
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie data={eligibleVsPlaced} dataKey="value" nameKey="name" innerRadius={50} outerRadius={75} paddingAngle={3}>
                      {eligibleVsPlaced.map((entry, i) => (
                        <Cell key={i} fill={entry.color} />
                      ))}
                    </Pie>
                    <Legend verticalAlign="bottom" height={24} iconType="circle" wrapperStyle={{ fontSize: "11px" }} />
                    <Tooltip contentStyle={{ backgroundColor: "#0f172a", borderRadius: "8px", border: "none", color: "#f8fafc", fontSize: "12px" }} />
                  </PieChart>
                </ResponsiveContainer>
              </div>
            </div>
          </div>
        </section>

        {/* CTC distribution + company-wise offers */}
        <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
          <SectionHeader eyebrow="Compensation" title="Package distribution & top recruiters" icon="coin" iconColor="#f59e0b" />
          <div className="mt-4 grid gap-6 lg:grid-cols-2">
            <div>
              <p className="mb-2 text-[11px] font-bold text-slate-500">CTC distribution (offers)</p>
              <div style={{ height: 210 }}>
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={ctcDistribution} margin={{ top: 5, right: 5, left: -20, bottom: 0 }}>
                    <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                    <XAxis dataKey="band" axisLine={false} tickLine={false} tick={{ fill: "#94a3b8", fontSize: 9 }} interval={0} angle={-15} textAnchor="end" height={40} />
                    <YAxis axisLine={false} tickLine={false} tick={{ fill: "#94a3b8", fontSize: 10 }} />
                    <Tooltip contentStyle={{ backgroundColor: "#0f172a", borderRadius: "8px", border: "none", color: "#f8fafc", fontSize: "12px" }} />
                    <Bar dataKey="count" radius={[6, 6, 0, 0]} fill="#f59e0b" />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </div>
            <div>
              <p className="mb-2 text-[11px] font-bold text-slate-500">Offers by company</p>
              <div style={{ height: 210 }}>
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={companyOffers} layout="vertical" margin={{ top: 5, right: 20, left: 10, bottom: 0 }}>
                    <CartesianGrid strokeDasharray="3 3" horizontal={false} stroke="#f1f5f9" />
                    <XAxis type="number" axisLine={false} tickLine={false} tick={{ fill: "#94a3b8", fontSize: 10 }} />
                    <YAxis type="category" dataKey="company" axisLine={false} tickLine={false} width={70} tick={{ fill: "#94a3b8", fontSize: 11 }} />
                    <Tooltip contentStyle={{ backgroundColor: "#0f172a", borderRadius: "8px", border: "none", color: "#f8fafc", fontSize: "12px" }} />
                    <Bar dataKey="offers" radius={[0, 6, 6, 0]} fill="#2563eb" />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </div>
          </div>
        </section>

        {/* Branch-wise average CTC */}
        <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
          <SectionHeader eyebrow="Branch Comparison" title="Average CTC by branch" icon="graduation" iconColor="#10b981" />
          <div className="mt-4 space-y-4">
            {branchAvgCtc.map((b, i) => (
              <div key={i}>
                <div className="mb-1 flex items-center justify-between">
                  <span className="text-xs font-semibold text-slate-600">{b.title}</span>
                  <span className="text-xs font-black text-slate-700">{b.value}</span>
                </div>
                <div className="h-2 w-full overflow-hidden rounded-full bg-slate-100">
                  <div className="h-2 rounded-full transition-all duration-500" style={{ width: `${b.progress}%`, background: b.color }} />
                </div>
              </div>
            ))}
          </div>
        </section>

        {/* Drive-wise conversion table */}
        <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
          <div className="flex flex-wrap items-center justify-between gap-3">
            <SectionHeader eyebrow="Drive Log" title="Drive-wise conversion" icon="briefcase" iconColor="#f43f5e" />
            <div className="flex gap-1.5 rounded-xl border border-slate-200 bg-slate-50 p-1">
              {[
                { key: "all" as const, label: "All" },
                { key: "high" as const, label: "High conv." },
                { key: "low" as const, label: "Low conv." },
              ].map((f) => (
                <button key={f.key} onClick={() => setDriveFilter(f.key)}
                  className={`rounded-lg px-3 py-1.5 text-[11px] font-bold transition ${
                    driveFilter === f.key ? "bg-slate-900 text-white" : "text-slate-500 hover:bg-white"
                  }`}>
                  {f.label}
                </button>
              ))}
            </div>
          </div>

          <div className="mt-4 overflow-x-auto rounded-xl border border-slate-200">
            <table className="w-full text-left text-xs">
              <thead>
                <tr className="border-b border-slate-200 bg-slate-50 text-[10px] font-bold uppercase tracking-wider text-slate-400">
                  <th className="px-4 py-3">Company</th>
                  <th className="px-4 py-3">Drive date</th>
                  <th className="px-4 py-3">Appeared</th>
                  <th className="px-4 py-3">Selected</th>
                  <th className="px-4 py-3">Conversion</th>
                </tr>
              </thead>
              <tbody>
                {filteredDrives.map((d, i) => (
                  <tr key={d.company} className={i < filteredDrives.length - 1 ? "border-b border-slate-100" : ""}>
                    <td className="px-4 py-3 font-bold text-slate-900">{d.company}</td>
                    <td className="px-4 py-3 text-slate-500">{d.date}</td>
                    <td className="px-4 py-3 text-slate-600">{d.appeared}</td>
                    <td className="px-4 py-3 text-slate-600">{d.selected}</td>
                    <td className="px-4 py-3">
                      <span className={`inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[10px] font-bold ring-1 ${
                        d.conversion >= 32 ? "bg-emerald-50 text-emerald-700 ring-emerald-100" : "bg-amber-50 text-amber-700 ring-amber-100"
                      }`}>
                        {d.conversion}%
                      </span>
                    </td>
                  </tr>
                ))}
                {filteredDrives.length === 0 && (
                  <tr>
                    <td colSpan={5} className="px-4 py-6 text-center text-slate-400">No drives match this filter.</td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </section>
      </>
    </CollegeLayout>
  );
};

export default PlacementStatistics;