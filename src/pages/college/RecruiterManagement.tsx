
import { useMemo, useState } from "react";
import { useAuth } from "../../context/AuthContext";
import CollegeLayout from "../../components/college/CollegeLayout";
import type { CollegeSidebarIconName } from "../../components/college/CollegeSidebar";

// ─── Icon System (matches Admin / College Dashboard) ──────────────────────────
type IconName =
  | "building" | "briefcase" | "search" | "chevron-down" | "chevron-right" | "chevron-left"
  | "download" | "plus" | "mail" | "phone" | "eye" | "check" | "alert" | "arrow-up"
  | "arrow-down" | "close" | "calendar" | "users" | "globe" | "map-pin" | "target" | "clock";

const Icon = ({ name, className = "h-4 w-4" }: { name: IconName; className?: string }) => {
  const paths: Record<IconName, React.ReactNode> = {
    building: <><path d="M5 21V5a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v16" /><path d="M3 21h18" /><path d="M9 7h1" /><path d="M14 7h1" /><path d="M9 11h1" /><path d="M14 11h1" /></>,
    briefcase: <><path d="M9 7V5a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2v2" /><path d="M4 7h16v11a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V7Z" /><path d="M4 12h16" /></>,
    search: <><circle cx="11" cy="11" r="7" /><path d="m16 16 4 4" /></>,
    "chevron-down": <path d="m6 9 6 6 6-6" />,
    "chevron-right": <path d="m9 18 6-6-6-6" />,
    "chevron-left": <path d="m15 18-6-6 6-6" />,
    download: <><path d="M12 3v12" /><path d="m7 10 5 5 5-5" /><path d="M4 21h16" /></>,
    plus: <path d="M12 5v14M5 12h14" />,
    mail: <><rect x="3" y="5" width="18" height="14" rx="2" /><path d="m3 7 9 6 9-6" /></>,
    phone: <path d="M6.6 10.8a15.9 15.9 0 0 0 6.6 6.6l2.2-2.2c.3-.3.7-.4 1-.3 1.1.4 2.3.6 3.6.6.6 0 1 .4 1 1V21c0 .6-.4 1-1 1C10.6 22 2 13.4 2 3c0-.6.4-1 1-1h3.5c.6 0 1 .4 1 1 0 1.3.2 2.5.6 3.6.1.3 0 .7-.3 1L6.6 10.8Z" />,
    eye: <><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7Z" /><circle cx="12" cy="12" r="3" /></>,
    check: <><path d="M21 12a9 9 0 1 1-5-8" /><path d="m9 12 2 2 6-7" /></>,
    alert: <><path d="M12 4 3.5 18.5h17L12 4Z" /><path d="M12 9v4" /><path d="M12 16h.01" /></>,
    "arrow-up": <><path d="M7 17 17 7" /><path d="M9 7h8v8" /></>,
    "arrow-down": <><path d="M7 7 17 17" /><path d="M17 9v8H9" /></>,
    close: <><path d="M18 6 6 18" /><path d="m6 6 12 12" /></>,
    calendar: <><path d="M7 3v4" /><path d="M17 3v4" /><rect x="4" y="5" width="16" height="16" rx="2" /><path d="M4 10h16" /></>,
    users: <><path d="M16 21v-2a4 4 0 0 0-4-4H7a4 4 0 0 0-4 4v2" /><circle cx="9.5" cy="7" r="4" /><path d="M22 21v-2a4 4 0 0 0-3-3.8" /><path d="M16 3.2a4 4 0 0 1 0 7.6" /></>,
    globe: <><circle cx="12" cy="12" r="9" /><path d="M3 12h18" /><path d="M12 3a15 15 0 0 1 0 18 15 15 0 0 1 0-18Z" /></>,
    "map-pin": <><path d="M12 21s7-6.5 7-11.5a7 7 0 1 0-14 0C5 14.5 12 21 12 21Z" /><circle cx="12" cy="9.5" r="2.5" /></>,
    target: <><circle cx="12" cy="12" r="8" /><circle cx="12" cy="12" r="4" /><path d="M12 2v3" /><path d="M12 19v3" /><path d="M2 12h3" /><path d="M19 12h3" /></>,
    clock: <><circle cx="12" cy="12" r="9" /><path d="M12 7v5l3 2" /></>,
  };
  return (
    <svg className={className} fill="none" stroke="currentColor" strokeLinecap="round"
      strokeLinejoin="round" strokeWidth="2" viewBox="0 0 24 24" aria-hidden="true">
      {paths[name]}
    </svg>
  );
};

const getInitials = (name: string) =>
  name.trim().split(/\s+/).map((n) => n[0]).join("").toUpperCase().slice(0, 2) || "CO";

// Sidebar — identical to College Dashboard, "Recruiter Management" highlighted
const sidebarItems: Array<{ label: string; icon: CollegeSidebarIconName; route: string; badge?: number }> = [
  { label: "Dashboard", icon: "target", route: "/college-dashboard" },
  { label: "Student Management", icon: "users", route: "/college/students-management" },
  { label: "Recruiter Management", icon: "building", route: "/college/recruiter-management" },
  { label: "Placement Statistics", icon: "briefcase", route: "/college/placement-statistics", badge: 5 },
  { label: "Notifications", icon: "alert", route: "/college/notifications", badge: 3 },
  { label: "Profile", icon: "users", route: "/college/profile" },
  { label: "Settings", icon: "users", route: "/college/settings" },
];

// ─── Types ──────────────────────────────────────────────────────────────────
interface Recruiter {
  id: string;
  company: string;
  industry: string;
  location: string;
  driveStatus: "Active" | "Upcoming" | "Completed" | "Not Scheduled";
  positionsOffered: number;
  applied: number;
  shortlisted: number;
  hired: number;
  contactName: string;
  email: string;
  phone: string;
  nextDrive?: string;
}

type RecruiterForm = {
  company: string;
  industry: Recruiter["industry"];
  location: string;
  driveStatus: Recruiter["driveStatus"];
  positionsOffered: string;
  applied: string;
  shortlisted: string;
  hired: string;
  contactName: string;
  email: string;
  phone: string;
  nextDrive: string;
};

// ─── Mock Data ──────────────────────────────────────────────────────────────
const RECRUITERS: Recruiter[] = [
  { id: "REC001", company: "TCS", industry: "IT Services", location: "Pune, IN", driveStatus: "Active", positionsOffered: 120, applied: 410, shortlisted: 180, hired: 62, contactName: "Sameer Kulkarni", email: "sameer.k@tcs.com", phone: "+91 98220 11001", nextDrive: "25 Jun 2026" },
  { id: "REC002", company: "Infosys", industry: "IT Services", location: "Bengaluru, IN", driveStatus: "Upcoming", positionsOffered: 90, applied: 350, shortlisted: 140, hired: 0, contactName: "Neha Bansal", email: "neha.b@infosys.com", phone: "+91 98220 11002", nextDrive: "5 Jul 2026" },
  { id: "REC003", company: "Microsoft", industry: "Technology", location: "Hyderabad, IN", driveStatus: "Completed", positionsOffered: 8, applied: 220, shortlisted: 34, hired: 8, contactName: "Aakash Verma", email: "aakash.v@microsoft.com", phone: "+91 98220 11003" },
  { id: "REC004", company: "Google", industry: "Technology", location: "Bengaluru, IN", driveStatus: "Completed", positionsOffered: 5, applied: 260, shortlisted: 28, hired: 5, contactName: "Ritika Chawla", email: "ritika.c@google.com", phone: "+91 98220 11004" },
  { id: "REC005", company: "Deloitte", industry: "Consulting", location: "Gurugram, IN", driveStatus: "Not Scheduled", positionsOffered: 45, applied: 0, shortlisted: 0, hired: 0, contactName: "Manav Singh", email: "manav.s@deloitte.com", phone: "+91 98220 11005" },
  { id: "REC006", company: "Accenture", industry: "IT Services", location: "Mumbai, IN", driveStatus: "Active", positionsOffered: 75, applied: 300, shortlisted: 110, hired: 22, contactName: "Pooja Iyer", email: "pooja.i@accenture.com", phone: "+91 98220 11006", nextDrive: "28 Jun 2026" },
  { id: "REC007", company: "Wipro", industry: "IT Services", location: "Chennai, IN", driveStatus: "Upcoming", positionsOffered: 60, applied: 180, shortlisted: 0, hired: 0, contactName: "Farhan Ali", email: "farhan.a@wipro.com", phone: "+91 98220 11007", nextDrive: "12 Jul 2026" },
  { id: "REC008", company: "Amazon", industry: "E-commerce", location: "Hyderabad, IN", driveStatus: "Completed", positionsOffered: 12, applied: 290, shortlisted: 40, hired: 12, contactName: "Divya Menon", email: "divya.m@amazon.com", phone: "+91 98220 11008" },
];

const industries = ["All Industries", "IT Services", "Technology", "Consulting", "E-commerce"] as const;
const driveStatuses = ["All Status", "Active", "Upcoming", "Completed", "Not Scheduled"] as const;

const driveStatusStyle: Record<Recruiter["driveStatus"], string> = {
  Active: "bg-emerald-50 text-emerald-700 ring-emerald-100",
  Upcoming: "bg-blue-50 text-blue-700 ring-blue-100",
  Completed: "bg-slate-100 text-slate-600 ring-slate-200",
  "Not Scheduled": "bg-amber-50 text-amber-700 ring-amber-100",
};

const emptyRecruiterForm = (): RecruiterForm => ({
  company: "",
  industry: "IT Services",
  location: "",
  driveStatus: "Not Scheduled",
  positionsOffered: "0",
  applied: "0",
  shortlisted: "0",
  hired: "0",
  contactName: "",
  email: "",
  phone: "",
  nextDrive: "",
});

const toNumber = (value: string) => {
  const parsed = Number(value);
  return Number.isFinite(parsed) && parsed >= 0 ? parsed : 0;
};

const escapeCsv = (value: string | number | undefined) => {
  const text = String(value ?? "");
  return /[",\n]/.test(text) ? `"${text.replace(/"/g, '""')}"` : text;
};

const downloadRecruitersCsv = (recruiters: Recruiter[]) => {
  const headers = [
    "ID",
    "Company",
    "Industry",
    "Location",
    "Drive Status",
    "Positions Offered",
    "Applied",
    "Shortlisted",
    "Hired",
    "Contact Name",
    "Email",
    "Phone",
    "Next Drive",
  ];
  const rows = recruiters.map((r) => [
    r.id,
    r.company,
    r.industry,
    r.location,
    r.driveStatus,
    r.positionsOffered,
    r.applied,
    r.shortlisted,
    r.hired,
    r.contactName,
    r.email,
    r.phone,
    r.nextDrive ?? "",
  ]);
  const csv = [headers, ...rows].map((row) => row.map(escapeCsv).join(",")).join("\n");
  const blob = new Blob([csv], { type: "text/csv;charset=utf-8" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = "college-recruiters.csv";
  document.body.appendChild(link);
  link.click();
  link.remove();
  URL.revokeObjectURL(url);
};

// ─── Recruiter Detail Drawer ────────────────────────────────────────────────
const RecruiterDrawer = ({ recruiter, onClose }: { recruiter: Recruiter; onClose: () => void }) => {
  const conversion = recruiter.applied > 0 ? Math.round((recruiter.shortlisted / recruiter.applied) * 100) : 0;
  return (
    <div className="fixed inset-0 z-50 flex justify-end">
      <div className="absolute inset-0 bg-slate-900/40 backdrop-blur-[2px]" onClick={onClose} />
      <div className="relative flex h-full w-full max-w-sm flex-col overflow-y-auto border-l border-slate-200 bg-white shadow-2xl">
        <div className="flex items-center justify-between border-b border-slate-100 p-5">
          <p className="text-sm font-black text-slate-900">Recruiter profile</p>
          <button onClick={onClose} className="rounded-lg p-1.5 text-slate-400 transition hover:bg-slate-100 hover:text-slate-700">
            <Icon name="close" className="h-4 w-4" />
          </button>
        </div>

        <div className="p-5">
          <div className="flex items-center gap-4">
            <div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-slate-900 text-lg font-black text-white">
              {getInitials(recruiter.company)}
            </div>
            <div>
              <p className="text-base font-black text-slate-900">{recruiter.company}</p>
              <p className="mt-0.5 text-xs text-slate-500">{recruiter.industry}</p>
              <span className={`mt-1.5 inline-block rounded-full px-2 py-0.5 text-[10px] font-bold ring-1 ${driveStatusStyle[recruiter.driveStatus]}`}>
                {recruiter.driveStatus}
              </span>
            </div>
          </div>

          <div className="mt-5 grid grid-cols-3 gap-2.5">
            <div className="rounded-xl border border-slate-100 bg-slate-50 p-3 text-center">
              <p className="text-[10px] font-semibold text-slate-400">Applied</p>
              <p className="mt-1 text-lg font-black text-slate-900">{recruiter.applied}</p>
            </div>
            <div className="rounded-xl border border-slate-100 bg-slate-50 p-3 text-center">
              <p className="text-[10px] font-semibold text-slate-400">Shortlisted</p>
              <p className="mt-1 text-lg font-black text-blue-700">{recruiter.shortlisted}</p>
            </div>
            <div className="rounded-xl border border-slate-100 bg-slate-50 p-3 text-center">
              <p className="text-[10px] font-semibold text-slate-400">Hired</p>
              <p className="mt-1 text-lg font-black text-emerald-700">{recruiter.hired}</p>
            </div>
          </div>

          <div className="mt-4 rounded-xl border border-blue-100 bg-blue-50 p-3">
            <div className="flex items-center justify-between text-[11px] font-semibold">
              <span className="text-blue-500">Shortlist conversion</span>
              <span className="text-blue-700">{conversion}%</span>
            </div>
            <div className="mt-2 h-1.5 overflow-hidden rounded-full bg-blue-100">
              <div className="h-1.5 rounded-full bg-blue-600" style={{ width: `${conversion}%` }} />
            </div>
          </div>

          <div className="mt-5 space-y-3.5 border-t border-slate-100 pt-4">
            {[
              { icon: "map-pin" as IconName, label: "Location", value: recruiter.location },
              { icon: "briefcase" as IconName, label: "Positions offered", value: String(recruiter.positionsOffered) },
              { icon: "users" as IconName, label: "Contact person", value: recruiter.contactName },
              { icon: "mail" as IconName, label: "Email", value: recruiter.email },
              { icon: "phone" as IconName, label: "Phone", value: recruiter.phone },
              ...(recruiter.nextDrive ? [{ icon: "calendar" as IconName, label: "Next drive", value: recruiter.nextDrive }] : []),
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

          <div className="mt-6 flex gap-2.5">
            <button className="flex-1 rounded-xl bg-slate-900 py-2.5 text-xs font-bold text-white transition hover:bg-slate-800">
              Schedule drive
            </button>
            <button className="flex-1 rounded-xl border border-slate-200 py-2.5 text-xs font-bold text-slate-600 transition hover:bg-slate-50">
              Contact
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

// ═══════════════════════════════════════════════════════════════════════════
// MAIN — Recruiter Management
// ═══════════════════════════════════════════════════════════════════════════
export const RecruiterManagement = () => {
  const { currentUser } = useAuth();
  const fullName = currentUser?.fullName || "BITS Pilani Placement Cell Admin";

  const [query, setQuery] = useState("");
  const [industry, setIndustry] = useState<(typeof industries)[number]>("All Industries");
  const [driveStatus, setDriveStatus] = useState<(typeof driveStatuses)[number]>("All Status");
  const [page, setPage] = useState(1);
  const [selected, setSelected] = useState<Recruiter | null>(null);
  const [recruiters, setRecruiters] = useState<Recruiter[]>(RECRUITERS);
  const [addOpen, setAddOpen] = useState(false);
  const [form, setForm] = useState<RecruiterForm>(() => emptyRecruiterForm());
  const [formError, setFormError] = useState("");
  const pageSize = 8;

  const filtered = useMemo(() => {
    return recruiters.filter((r) => {
      const matchesQuery =
        query.trim() === "" ||
        r.company.toLowerCase().includes(query.toLowerCase()) ||
        r.contactName.toLowerCase().includes(query.toLowerCase());
      const matchesIndustry = industry === "All Industries" || r.industry === industry;
      const matchesStatus = driveStatus === "All Status" || r.driveStatus === driveStatus;
      return matchesQuery && matchesIndustry && matchesStatus;
    });
  }, [recruiters, query, industry, driveStatus]);

  const paged = filtered.slice((page - 1) * pageSize, page * pageSize);
  const totalPages = Math.max(1, Math.ceil(filtered.length / pageSize));

  const summary = {
    total: recruiters.length,
    active: recruiters.filter((r) => r.driveStatus === "Active").length,
    positions: recruiters.reduce((sum, r) => sum + r.positionsOffered, 0),
    hired: recruiters.reduce((sum, r) => sum + r.hired, 0),
  };

  const updateForm = <K extends keyof RecruiterForm>(field: K, value: RecruiterForm[K]) => {
    setForm((current) => ({ ...current, [field]: value }));
    setFormError("");
  };

  const closeAddRecruiter = () => {
    setAddOpen(false);
    setForm(emptyRecruiterForm());
    setFormError("");
  };

  const handleAddRecruiter = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    if (!form.company.trim() || !form.contactName.trim() || !form.email.trim()) {
      setFormError("Company, contact name, and email are required.");
      return;
    }

    const nextNumber = recruiters.reduce((max, r) => {
      const numericId = Number(r.id.replace(/\D/g, ""));
      return Number.isFinite(numericId) ? Math.max(max, numericId) : max;
    }, 0) + 1;

    const newRecruiter: Recruiter = {
      id: `REC${String(nextNumber).padStart(3, "0")}`,
      company: form.company.trim(),
      industry: form.industry.trim() || "IT Services",
      location: form.location.trim() || "Not specified",
      driveStatus: form.driveStatus,
      positionsOffered: toNumber(form.positionsOffered),
      applied: toNumber(form.applied),
      shortlisted: toNumber(form.shortlisted),
      hired: toNumber(form.hired),
      contactName: form.contactName.trim(),
      email: form.email.trim(),
      phone: form.phone.trim() || "Not provided",
      nextDrive: form.nextDrive.trim() || undefined,
    };

    setRecruiters((current) => [newRecruiter, ...current]);
    setPage(1);
    closeAddRecruiter();
  };

  return (
    <CollegeLayout
      sidebarItems={sidebarItems}
      sidebarHighlight="Recruiter Management"
      userSummary={{ fullName, role: "Training & Placement Officer", status: "Placement cycle active" }}
      stats={{ label: "Overall placement rate", value: "82", subtitle: "This cycle", accent: "This cycle" }}
    >
      <>
        {/* Header */}
        <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <p className="text-[10px] font-bold uppercase tracking-widest text-slate-400">Recruiter Records</p>
            <h1 className="mt-0.5 text-2xl font-black tracking-tight text-slate-900">Recruiter management</h1>
            <p className="mt-1 text-sm text-slate-500">Track onboarded companies, active drives, and hiring outcomes.</p>
          </div>
          <div className="flex gap-2.5">
            <button
              onClick={() => downloadRecruitersCsv(filtered)}
              disabled={filtered.length === 0}
              className="flex items-center gap-1.5 rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-xs font-bold text-slate-600 shadow-sm transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-40"
            >
              <Icon name="download" className="h-3.5 w-3.5" />
              Export
            </button>
            <button
              onClick={() => setAddOpen(true)}
              className="flex items-center gap-1.5 rounded-xl bg-slate-900 px-4 py-2.5 text-xs font-bold text-white shadow-sm transition hover:bg-slate-800"
            >
              <Icon name="plus" className="h-3.5 w-3.5" />
              Add recruiter
            </button>
          </div>
        </div>

        {/* Stats row */}
        <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
          {[
            { label: "Companies onboarded", value: String(summary.total), icon: "building" as IconName, bg: "#eff6ff", change: "+6", up: true },
            { label: "Active drives", value: String(summary.active), icon: "briefcase" as IconName, bg: "#ecfdf5", change: "+1", up: true },
            { label: "Positions offered", value: String(summary.positions), icon: "target" as IconName, bg: "#fffbeb", change: "+34", up: true },
            { label: "Students hired", value: String(summary.hired), icon: "check" as IconName, bg: "#f5f3ff", change: "+22", up: true },
          ].map((s) => (
            <article key={s.label} className="group cursor-default rounded-2xl border border-slate-200 bg-white p-5 shadow-sm transition hover:-translate-y-0.5 hover:shadow-md">
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

        {/* Filters + Table */}
        <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
          <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
            <div className="relative flex-1 sm:max-w-xs">
              <Icon name="search" className="pointer-events-none absolute left-3 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-slate-400" />
              <input
                type="text"
                value={query}
                onChange={(e) => { setQuery(e.target.value); setPage(1); }}
                placeholder="Search by company or contact"
                className="w-full rounded-lg border border-slate-200 bg-slate-50 py-2.5 pl-9 pr-3 text-xs text-slate-700 placeholder-slate-400 outline-none focus:border-blue-300 focus:bg-white focus:ring-2 focus:ring-blue-50"
              />
            </div>
            <div className="flex flex-wrap gap-2.5">
              <div className="relative">
                <select
                  value={industry}
                  onChange={(e) => { setIndustry(e.target.value as typeof industry); setPage(1); }}
                  className="appearance-none rounded-lg border border-slate-200 bg-white py-2.5 pl-3 pr-8 text-xs font-semibold text-slate-600 outline-none focus:border-blue-300">
                  {industries.map((d) => <option key={d} value={d}>{d}</option>)}
                </select>
                <Icon name="chevron-down" className="pointer-events-none absolute right-2.5 top-1/2 h-3 w-3 -translate-y-1/2 text-slate-400" />
              </div>
              <div className="relative">
                <select
                  value={driveStatus}
                  onChange={(e) => { setDriveStatus(e.target.value as typeof driveStatus); setPage(1); }}
                  className="appearance-none rounded-lg border border-slate-200 bg-white py-2.5 pl-3 pr-8 text-xs font-semibold text-slate-600 outline-none focus:border-blue-300">
                  {driveStatuses.map((s) => <option key={s} value={s}>{s}</option>)}
                </select>
                <Icon name="chevron-down" className="pointer-events-none absolute right-2.5 top-1/2 h-3 w-3 -translate-y-1/2 text-slate-400" />
              </div>
            </div>
          </div>

          {/* Table */}
          <div className="mt-4 overflow-x-auto rounded-xl border border-slate-200">
            <table className="w-full min-w-[820px] text-left">
              <thead>
                <tr className="border-b border-slate-100 bg-slate-50">
                  {["Company", "Industry", "Positions", "Applied / Shortlisted", "Hired", "Drive status", ""].map((h) => (
                    <th key={h} className="px-4 py-3 text-[10px] font-bold uppercase tracking-wider text-slate-400">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {paged.map((r, i) => (
                  <tr key={r.id} className={`transition hover:bg-slate-50/60 ${i < paged.length - 1 ? "border-b border-slate-100" : ""}`}>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-3">
                        <div className="flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-lg bg-slate-900 text-[10px] font-black text-white">
                          {getInitials(r.company)}
                        </div>
                        <div className="min-w-0">
                          <p className="truncate text-[12px] font-bold text-slate-900">{r.company}</p>
                          <p className="text-[10px] text-slate-400">{r.location}</p>
                        </div>
                      </div>
                    </td>
                    <td className="px-4 py-3 text-[11px] font-semibold text-slate-600">{r.industry}</td>
                    <td className="px-4 py-3 text-[11px] font-bold text-slate-700">{r.positionsOffered}</td>
                    <td className="px-4 py-3 text-[11px] text-slate-600">
                      <span className="font-bold text-slate-700">{r.applied}</span> / <span className="font-bold text-blue-700">{r.shortlisted}</span>
                    </td>
                    <td className="px-4 py-3 text-[11px] font-bold text-emerald-700">{r.hired}</td>
                    <td className="px-4 py-3">
                      <span className={`inline-block rounded-full px-2.5 py-0.5 text-[10px] font-bold ring-1 ${driveStatusStyle[r.driveStatus]}`}>
                        {r.driveStatus}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-right">
                      <button onClick={() => setSelected(r)}
                        className="rounded-lg p-1.5 text-slate-400 transition hover:bg-slate-100 hover:text-slate-700">
                        <Icon name="eye" className="h-3.5 w-3.5" />
                      </button>
                    </td>
                  </tr>
                ))}
                {paged.length === 0 && (
                  <tr>
                    <td colSpan={7} className="px-4 py-10 text-center text-xs text-slate-400">
                      No recruiters match these filters.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>

          {/* Pagination */}
          <div className="mt-4 flex items-center justify-between">
            <p className="text-[11px] text-slate-400">
              Showing <span className="font-semibold text-slate-600">{paged.length}</span> of{" "}
              <span className="font-semibold text-slate-600">{filtered.length}</span> recruiters
            </p>
            <div className="flex items-center gap-1.5">
              <button onClick={() => setPage((p) => Math.max(1, p - 1))} disabled={page === 1}
                className="flex h-7 w-7 items-center justify-center rounded-lg border border-slate-200 text-slate-500 transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-40">
                <Icon name="chevron-left" className="h-3.5 w-3.5" />
              </button>
              <span className="px-2 text-[11px] font-semibold text-slate-500">{page} / {totalPages}</span>
              <button onClick={() => setPage((p) => Math.min(totalPages, p + 1))} disabled={page === totalPages}
                className="flex h-7 w-7 items-center justify-center rounded-lg border border-slate-200 text-slate-500 transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-40">
                <Icon name="chevron-right" className="h-3.5 w-3.5" />
              </button>
            </div>
          </div>
        </section>
      </>

      {selected && <RecruiterDrawer recruiter={selected} onClose={() => setSelected(null)} />}
      {addOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div className="absolute inset-0 bg-slate-900/40 backdrop-blur-[2px]" onClick={closeAddRecruiter} />
          <form
            onSubmit={handleAddRecruiter}
            className="relative flex max-h-[90vh] w-full max-w-3xl flex-col overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-2xl"
          >
            <div className="flex items-center justify-between border-b border-slate-100 p-5">
              <div>
                <p className="text-sm font-black text-slate-900">Add recruiter</p>
                <p className="mt-0.5 text-xs text-slate-500">Create a frontend-only recruiter record for this session.</p>
              </div>
              <button type="button" onClick={closeAddRecruiter} className="rounded-lg p-1.5 text-slate-400 transition hover:bg-slate-100 hover:text-slate-700">
                <Icon name="close" className="h-4 w-4" />
              </button>
            </div>

            <div className="overflow-y-auto p-5">
              {formError && (
                <div className="mb-4 rounded-xl border border-rose-100 bg-rose-50 px-3 py-2 text-xs font-semibold text-rose-700">
                  {formError}
                </div>
              )}

              <div className="grid gap-4 md:grid-cols-2">
                <label className="space-y-1.5">
                  <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Company</span>
                  <input
                    value={form.company}
                    onChange={(e) => updateForm("company", e.target.value)}
                    placeholder="Company name"
                    className="w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm outline-none focus:border-blue-300 focus:bg-white focus:ring-2 focus:ring-blue-50"
                  />
                </label>
                <label className="space-y-1.5">
                  <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Industry</span>
                  <select
                    value={form.industry}
                    onChange={(e) => updateForm("industry", e.target.value)}
                    className="w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm outline-none focus:border-blue-300 focus:bg-white focus:ring-2 focus:ring-blue-50"
                  >
                    {industries.filter((item) => item !== "All Industries").map((item) => (
                      <option key={item} value={item}>{item}</option>
                    ))}
                  </select>
                </label>
                <label className="space-y-1.5">
                  <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Location</span>
                  <input
                    value={form.location}
                    onChange={(e) => updateForm("location", e.target.value)}
                    placeholder="City, country"
                    className="w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm outline-none focus:border-blue-300 focus:bg-white focus:ring-2 focus:ring-blue-50"
                  />
                </label>
                <label className="space-y-1.5">
                  <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Drive status</span>
                  <select
                    value={form.driveStatus}
                    onChange={(e) => updateForm("driveStatus", e.target.value as Recruiter["driveStatus"])}
                    className="w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm outline-none focus:border-blue-300 focus:bg-white focus:ring-2 focus:ring-blue-50"
                  >
                    {driveStatuses.filter((item) => item !== "All Status").map((item) => (
                      <option key={item} value={item}>{item}</option>
                    ))}
                  </select>
                </label>
                {[
                  ["positionsOffered", "Positions offered"],
                  ["applied", "Applied"],
                  ["shortlisted", "Shortlisted"],
                  ["hired", "Hired"],
                ].map(([field, label]) => (
                  <label key={field} className="space-y-1.5">
                    <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400">{label}</span>
                    <input
                      type="number"
                      min="0"
                      value={form[field as keyof RecruiterForm]}
                      onChange={(e) => updateForm(field as keyof RecruiterForm, e.target.value)}
                      className="w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm outline-none focus:border-blue-300 focus:bg-white focus:ring-2 focus:ring-blue-50"
                    />
                  </label>
                ))}
                <label className="space-y-1.5">
                  <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Contact name</span>
                  <input
                    value={form.contactName}
                    onChange={(e) => updateForm("contactName", e.target.value)}
                    placeholder="Recruiter contact"
                    className="w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm outline-none focus:border-blue-300 focus:bg-white focus:ring-2 focus:ring-blue-50"
                  />
                </label>
                <label className="space-y-1.5">
                  <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Email</span>
                  <input
                    type="email"
                    value={form.email}
                    onChange={(e) => updateForm("email", e.target.value)}
                    placeholder="name@company.com"
                    className="w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm outline-none focus:border-blue-300 focus:bg-white focus:ring-2 focus:ring-blue-50"
                  />
                </label>
                <label className="space-y-1.5">
                  <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Phone</span>
                  <input
                    value={form.phone}
                    onChange={(e) => updateForm("phone", e.target.value)}
                    placeholder="+91 90000 00000"
                    className="w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm outline-none focus:border-blue-300 focus:bg-white focus:ring-2 focus:ring-blue-50"
                  />
                </label>
                <label className="space-y-1.5">
                  <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Next drive</span>
                  <input
                    value={form.nextDrive}
                    onChange={(e) => updateForm("nextDrive", e.target.value)}
                    placeholder="15 Jul 2026"
                    className="w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm outline-none focus:border-blue-300 focus:bg-white focus:ring-2 focus:ring-blue-50"
                  />
                </label>
              </div>
            </div>

            <div className="flex justify-end gap-2.5 border-t border-slate-100 p-5">
              <button type="button" onClick={closeAddRecruiter}
                className="rounded-xl border border-slate-200 px-4 py-2.5 text-xs font-bold text-slate-600 transition hover:bg-slate-50">
                Cancel
              </button>
              <button type="submit"
                className="rounded-xl bg-slate-900 px-4 py-2.5 text-xs font-bold text-white shadow-sm transition hover:bg-slate-800">
                Add recruiter
              </button>
            </div>
          </form>
        </div>
      )}
    </CollegeLayout>
  );
};

export default RecruiterManagement;
