
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../../context/AuthContext";
import CollegeLayout from "../../components/college/CollegeLayout";

// ─── Icon System (matches Admin Dashboard / College Dashboard) ───────────────
type IconName =
  | "activity" | "alert" | "arrow-up" | "arrow-down" | "bell" | "briefcase"
  | "building" | "calendar" | "chart" | "check" | "clock" | "dashboard"
  | "database" | "file" | "graduation" | "lock" | "plug" | "search"
  | "settings" | "shield" | "sparkles" | "target" | "user-check" | "users"
  | "placement" | "monitor" | "send" | "refresh" | "close" | "chevron-right"
  | "zap" | "trending-up" | "cpu" | "mail" | "phone" | "book" | "award"
  | "upload" | "eye" | "message" | "chevron-down" | "lightbulb" | "clipboard"
  | "logout" | "edit" | "camera" | "badge-check";

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
    placement: <><path d="M12 4v12" /><path d="m8 12 4-4 4 4" /><path d="M8 20h8" /></>,
    monitor: <><rect x="4" y="5" width="16" height="12" rx="2" /><path d="M8 21h8" /><path d="M12 17v4" /></>,
    send: <><path d="m22 2-11 11" /><path d="m22 2-7 20-4-9-9-4 20-7z" /></>,
    refresh: <><path d="M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8" /><path d="M21 3v5h-5" /><path d="M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16" /><path d="M8 16H3v5" /></>,
    close: <><path d="M18 6 6 18" /><path d="m6 6 12 12" /></>,
    "chevron-right": <path d="m9 18 6-6-6-6" />,
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
    edit: <><path d="M12 20h9" /><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4Z" /></>,
    camera: <><path d="M4 8a2 2 0 0 1 2-2h1.2l1-1.6A2 2 0 0 1 9.9 3.5h4.2a2 2 0 0 1 1.7 1l1 1.5H18a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2Z" /><circle cx="12" cy="13" r="3.5" /></>,
    "badge-check": <><path d="m9 12 2 2 4-4" /><path d="M12 2 9.4 4H6v3.4L4 10l2 2.6V16h3.4L12 18l2.6-2H18v-3.4L20 10l-2-2.6V4h-3.4Z" /></>,
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

// Sidebar kept identical to CollegeDashboard.tsx
export const sidebarItems: Array<{
  label: string; icon: IconName; route: string; active?: boolean; badge?: number;
}> = [
  { label: "Dashboard", icon: "dashboard", route: "/college-dashboard" },
  { label: "Student Management", icon: "users", route: "/college/students-management" },
  { label: "Recruiter Management", icon: "building", route: "/college/recruiter-management" },
  { label: "Placement Statistics", icon: "briefcase", route: "/college/placement-statistics", badge: 5 },
  { label: "Notifications", icon: "bell", route: "/college/notifications", badge: 3 },
  { label: "Profile", icon: "settings", route: "/college/profile" },
  { label: "Settings", icon: "settings", route: "/college/settings" },
];

const buildCollegeContext = (name: string) => `
Institution Admin: ${name}
College: BITS Pilani, Pilani Campus
Total Registered Students: 1240
Placement-Eligible Students: 860
Placed Students: 610 (71%)
Companies Onboarded: 34 (+6 this quarter)
Active Placement Drives: 5
`;

const useCollegeProfile = () => {
  const { currentUser, logout } = useAuth();
  const fullName = currentUser?.fullName || "BITS Pilani Placement Cell Admin";
  const firstName = fullName.split(" ")[0] || "Admin";
  const initials = getInitials(fullName);
  const email = currentUser?.email || "placement@pilani.bits-pilani.ac.in";
  const phone = currentUser?.phone || "+91 9876543210";
  const context = buildCollegeContext(fullName);
  return { fullName, firstName, initials, email, phone, context, logout };
};

// ─── Static reference data ────────────────────────────────────────────────────
const quickStats = [
  { label: "Registered students", value: "1240", icon: "users" as IconName, bg: "#eff6ff" },
  { label: "Placed students", value: "610", icon: "check" as IconName, bg: "#ecfdf5" },
  { label: "Companies onboarded", value: "34", icon: "building" as IconName, bg: "#fffbeb" },
  { label: "Active drives", value: "5", icon: "briefcase" as IconName, bg: "#f5f3ff" },
];

const profileActivity: Array<{ icon: IconName; text: string; time: string; tone: string }> = [
  { icon: "edit", text: "Updated contact phone number", time: "2 days ago", tone: "blue" },
  { icon: "lock", text: "Changed account password", time: "1 week ago", tone: "violet" },
  { icon: "camera", text: "Updated profile photo", time: "3 weeks ago", tone: "emerald" },
  { icon: "building", text: "Updated institution details", time: "1 month ago", tone: "amber" },
];

interface ProfileFormState {
  fullName: string;
  email: string;
  phone: string;
  designation: string;
  department: string;
}

// ─── Reusable field ───────────────────────────────────────────────────────────
const Field = ({
  label, icon, value, name, editing, onChange, type = "text", readOnly = false,
}: {
  label: string; icon: IconName; value: string; name: keyof ProfileFormState;
  editing: boolean; onChange: (name: keyof ProfileFormState, value: string) => void;
  type?: string; readOnly?: boolean;
}) => (
  <div>
    <label className="mb-1.5 flex items-center gap-1.5 text-[11px] font-bold uppercase tracking-wider text-slate-400">
      <Icon name={icon} className="h-3 w-3" />
      {label}
    </label>
    {editing && !readOnly ? (
      <input
        type={type}
        value={value}
        onChange={(e) => onChange(name, e.target.value)}
        className="w-full rounded-lg border border-slate-200 bg-white px-3 py-2.5 text-sm text-slate-700 outline-none focus:border-blue-300 focus:ring-2 focus:ring-blue-50"
      />
    ) : (
      <p className={`rounded-lg px-3 py-2.5 text-sm font-semibold ${readOnly ? "bg-slate-50 text-slate-500" : "bg-slate-50 text-slate-800"}`}>
        {value}
      </p>
    )}
  </div>
);

// ═══════════════════════════════════════════════════════════════════════════
// MAIN PAGE
// ═══════════════════════════════════════════════════════════════════════════
export const CollegeProfile = () => {
  const { fullName, initials, email, phone } = useCollegeProfile();
  const navigate = useNavigate();

  const [editing, setEditing] = useState(false);
  const [saved, setSaved] = useState(false);
  const [form, setForm] = useState<ProfileFormState>({
    fullName,
    email,
    phone,
    designation: "Training & Placement Officer",
    department: "Central Placement Cell",
  });

  const handleChange = (name: keyof ProfileFormState, value: string) => {
    setForm((f) => ({ ...f, [name]: value }));
    setSaved(false);
  };

  const handleSave = () => {
    // Persisted via the auth/profile API in production; UI-only here.
    setEditing(false);
    setSaved(true);
    setTimeout(() => setSaved(false), 2500);
  };

  const handleCancel = () => {
    setForm({
      fullName,
      email,
      phone,
      designation: "Training & Placement Officer",
      department: "Central Placement Cell",
    });
    setEditing(false);
  };

  const toneCls: Record<string, string> = {
    emerald: "bg-emerald-50 text-emerald-600",
    blue: "bg-blue-50 text-blue-600",
    violet: "bg-violet-50 text-violet-600",
    amber: "bg-amber-50 text-amber-600",
  };

  return (
    <CollegeLayout
      
      sidebarHighlight="Profile"
      userSummary={{ fullName, role: "Training & Placement Officer", status: "Placement cycle active" }}
      stats={{ label: "Overall placement rate", value: "82", subtitle: "This cycle", accent: "This cycle" }}
    >
      <>
        {/* Header card */}
        <div className="relative overflow-hidden rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(#e0e7ff_1px,transparent_1px)] opacity-60 [background-size:18px_18px]" />
          <div className="pointer-events-none absolute right-0 top-0 h-48 w-48 rounded-full bg-blue-100/60 blur-3xl" />
          <div className="relative flex flex-col gap-6 sm:flex-row sm:items-center sm:justify-between">
            <div className="flex items-center gap-4">
              <div className="relative flex-shrink-0">
                <div className="flex h-16 w-16 items-center justify-center rounded-full bg-slate-900 text-xl font-black text-white shadow-inner">
                  {initials}
                </div>
                <button
                  aria-label="Change profile photo"
                  className="absolute -bottom-1 -right-1 flex h-6 w-6 items-center justify-center rounded-full border-2 border-white bg-blue-600 text-white shadow transition hover:bg-blue-700">
                  <Icon name="camera" className="h-3 w-3" />
                </button>
              </div>
              <div>
                <div className="flex flex-wrap items-center gap-2">
                  <h1 className="text-xl font-black tracking-tight text-slate-900">{form.fullName}</h1>
                  <span className="rounded-full border border-blue-100 bg-blue-50 px-2 py-0.5 text-[10px] font-bold text-blue-700">TPO001</span>
                </div>
                <p className="mt-0.5 text-xs text-slate-500">{form.designation} · BITS Pilani, Pilani Campus</p>
                <div className="mt-2 flex items-center gap-1.5">
                  <span className="flex items-center gap-1 rounded-full bg-emerald-50 px-2 py-0.5 text-[10px] font-bold text-emerald-700 ring-1 ring-emerald-100">
                    <Icon name="badge-check" className="h-3 w-3" />
                    Verified admin
                  </span>
                </div>
              </div>
            </div>

            <div className="flex flex-shrink-0 gap-2">
              {!editing ? (
                <button onClick={() => setEditing(true)}
                  className="flex items-center gap-1.5 rounded-xl bg-slate-900 px-4 py-2.5 text-xs font-bold text-white transition hover:bg-slate-800">
                  <Icon name="edit" className="h-3.5 w-3.5" />
                  Edit profile
                </button>
              ) : (
                <>
                  <button onClick={handleCancel}
                    className="rounded-xl border border-slate-200 px-4 py-2.5 text-xs font-bold text-slate-600 transition hover:bg-slate-50">
                    Cancel
                  </button>
                  <button onClick={handleSave}
                    className="flex items-center gap-1.5 rounded-xl bg-blue-600 px-4 py-2.5 text-xs font-bold text-white transition hover:bg-blue-700">
                    <Icon name="check" className="h-3.5 w-3.5" />
                    Save changes
                  </button>
                </>
              )}
            </div>
          </div>

          {saved && (
            <div className="relative mt-4 flex items-center gap-2 rounded-lg border border-emerald-100 bg-emerald-50 px-3 py-2 text-xs font-semibold text-emerald-700">
              <Icon name="check" className="h-3.5 w-3.5" />
              Profile changes saved.
            </div>
          )}
        </div>

        {/* Quick stats */}
        <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
          {quickStats.map((s) => (
            <article key={s.label} className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
              <div className="flex h-10 w-10 items-center justify-center rounded-xl" style={{ background: s.bg }}>
                <Icon name={s.icon} className="h-4.5 w-4.5 text-slate-700" />
              </div>
              <p className="mt-4 text-[11px] font-bold uppercase tracking-wider text-slate-400">{s.label}</p>
              <p className="mt-0.5 text-2xl font-black tracking-tight text-slate-900">{s.value}</p>
            </article>
          ))}
        </div>

        {/* Personal information + Institution overview */}
        <div className="grid gap-5 xl:grid-cols-[1.1fr_0.9fr]">
          <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-[10px] font-bold uppercase tracking-widest text-slate-400">Account</p>
                <h2 className="mt-0.5 text-lg font-black text-slate-900">Personal information</h2>
              </div>
              <Icon name="user-check" className="h-4 w-4 text-slate-300" />
            </div>
            <div className="mt-4 grid gap-4 sm:grid-cols-2">
              <Field label="Full name" icon="user-check" name="fullName" value={form.fullName} editing={editing} onChange={handleChange} />
              <Field label="Designation" icon="briefcase" name="designation" value={form.designation} editing={editing} onChange={handleChange} />
              <Field label="Email" icon="mail" name="email" value={form.email} editing={editing} onChange={handleChange} type="email" readOnly />
              <Field label="Phone" icon="phone" name="phone" value={form.phone} editing={editing} onChange={handleChange} />
              <Field label="Department" icon="graduation" name="department" value={form.department} editing={editing} onChange={handleChange} />
              <Field label="Employee ID" icon="clipboard" name="department" value="TPO001" editing={false} onChange={handleChange} readOnly />
            </div>
            {editing && (
              <p className="mt-3 text-[11px] text-slate-400">Email changes require verification — manage this from Settings.</p>
            )}
          </section>

          <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-[10px] font-bold uppercase tracking-widest text-slate-400">Institution</p>
                <h2 className="mt-0.5 text-lg font-black text-slate-900">Institution overview</h2>
              </div>
              <Icon name="building" className="h-4 w-4 text-slate-300" />
            </div>
            <div className="mt-4 space-y-3.5">
              {[
                { icon: "graduation" as IconName, label: "Institution", value: "BITS Pilani, Pilani Campus" },
                { icon: "calendar" as IconName, label: "Cycle started", value: "01-01-2026" },
                { icon: "clock" as IconName, label: "Member since", value: "Aug 2023" },
                { icon: "activity" as IconName, label: "Last login", value: "Today, 9:42 AM" },
              ].map((f) => (
                <div key={f.label} className="flex items-center gap-3 text-xs">
                  <Icon name={f.icon} className="h-4 w-4 flex-shrink-0 text-slate-400" />
                  <div>
                    <p className="text-slate-400">{f.label}</p>
                    <p className="font-semibold text-slate-700">{f.value}</p>
                  </div>
                </div>
              ))}
            </div>

            <div className="mt-5 flex items-center justify-between rounded-xl border border-blue-100 bg-blue-50 p-3.5">
              <div className="flex items-center gap-2.5">
                <Icon name="shield" className="h-4 w-4 text-blue-600" />
                <div>
                  <p className="text-xs font-bold text-blue-800">Security &amp; preferences</p>
                  <p className="text-[11px] text-blue-600">Manage password, 2FA and notifications</p>
                </div>
              </div>
              <button onClick={() => navigate("/college/settings")}
                className="flex flex-shrink-0 items-center gap-1 rounded-lg bg-white px-2.5 py-1.5 text-[11px] font-bold text-blue-700 shadow-sm ring-1 ring-blue-100 transition hover:bg-blue-100">
                Go to Settings
                <Icon name="chevron-right" className="h-3 w-3" />
              </button>
            </div>
          </section>
        </div>

        {/* Recent profile activity */}
        <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-[10px] font-bold uppercase tracking-widest text-slate-400">Activity</p>
              <h2 className="mt-0.5 text-lg font-black text-slate-900">Recent profile activity</h2>
            </div>
            <Icon name="activity" className="h-4 w-4 text-slate-300" />
          </div>
          <div className="mt-4 overflow-hidden rounded-xl border border-slate-200">
            {profileActivity.map((a, i) => (
              <div key={i} className={`flex items-center gap-3 p-3.5 ${i < profileActivity.length - 1 ? "border-b border-slate-100" : ""} transition hover:bg-slate-50/60`}>
                <div className={`flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-lg ${toneCls[a.tone]}`}>
                  <Icon name={a.icon} className="h-3.5 w-3.5" />
                </div>
                <p className="min-w-0 flex-1 truncate text-[12px] font-semibold text-slate-700">{a.text}</p>
                <span className="flex-shrink-0 text-[10px] font-semibold text-slate-400">{a.time}</span>
              </div>
            ))}
          </div>
        </section>
      </>
    </CollegeLayout>
  );
};

export default CollegeProfile;
