import { useMemo, useState } from "react";
import { useAuth } from "../../context/AuthContext";
import CollegeLayout from "../../components/college/CollegeLayout";

// ─── Icon System (matches Admin / College Dashboard) ──────────────────────────
type IconName =
  | "users" | "user-check" | "search" | "filter" | "chevron-down" | "chevron-right"
  | "download" | "plus" | "mail" | "phone" | "eye" | "edit" | "more" | "check"
  | "alert" | "arrow-up" | "arrow-down" | "x" | "graduation" | "target" | "resume"
  | "briefcase" | "sparkles" | "close" | "chevron-left";

const Icon = ({ name, className = "h-4 w-4" }: { name: IconName; className?: string }) => {
  const paths: Record<IconName, React.ReactNode> = {
    users: <><path d="M16 21v-2a4 4 0 0 0-4-4H7a4 4 0 0 0-4 4v2" /><circle cx="9.5" cy="7" r="4" /><path d="M22 21v-2a4 4 0 0 0-3-3.8" /><path d="M16 3.2a4 4 0 0 1 0 7.6" /></>,
    "user-check": <><path d="M15 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" /><circle cx="8.5" cy="7" r="4" /><path d="m16 11 2 2 4-5" /></>,
    search: <><circle cx="11" cy="11" r="7" /><path d="m16 16 4 4" /></>,
    filter: <path d="M4 5h16M7 12h10M10 19h4" />,
    "chevron-down": <path d="m6 9 6 6 6-6" />,
    "chevron-right": <path d="m9 18 6-6-6-6" />,
    "chevron-left": <path d="m15 18-6-6 6-6" />,
    download: <><path d="M12 3v12" /><path d="m7 10 5 5 5-5" /><path d="M4 21h16" /></>,
    plus: <path d="M12 5v14M5 12h14" />,
    mail: <><rect x="3" y="5" width="18" height="14" rx="2" /><path d="m3 7 9 6 9-6" /></>,
    phone: <path d="M6.6 10.8a15.9 15.9 0 0 0 6.6 6.6l2.2-2.2c.3-.3.7-.4 1-.3 1.1.4 2.3.6 3.6.6.6 0 1 .4 1 1V21c0 .6-.4 1-1 1C10.6 22 2 13.4 2 3c0-.6.4-1 1-1h3.5c.6 0 1 .4 1 1 0 1.3.2 2.5.6 3.6.1.3 0 .7-.3 1L6.6 10.8Z" />,
    eye: <><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7Z" /><circle cx="12" cy="12" r="3" /></>,
    edit: <><path d="M11 4H6a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-5" /><path d="M18.4 2.6a2 2 0 1 1 2.8 2.8L11 15.7l-4 1 1-4 10.4-9.4Z" /></>,
    more: <><circle cx="12" cy="5" r="1.2" /><circle cx="12" cy="12" r="1.2" /><circle cx="12" cy="19" r="1.2" /></>,
    check: <><path d="M21 12a9 9 0 1 1-5-8" /><path d="m9 12 2 2 6-7" /></>,
    alert: <><path d="M12 4 3.5 18.5h17L12 4Z" /><path d="M12 9v4" /><path d="M12 16h.01" /></>,
    "arrow-up": <><path d="M7 17 17 7" /><path d="M9 7h8v8" /></>,
    "arrow-down": <><path d="M7 7 17 17" /><path d="M17 9v8H9" /></>,
    x: <><path d="M18 6 6 18" /><path d="m6 6 12 12" /></>,
    graduation: <><path d="m22 10-10-5-10 5 10 5 10-5Z" /><path d="M6 12v5c3 2 9 2 12 0v-5" /></>,
    target: <><circle cx="12" cy="12" r="8" /><circle cx="12" cy="12" r="4" /><path d="M12 2v3" /><path d="M12 19v3" /><path d="M2 12h3" /><path d="M19 12h3" /></>,
    resume: <><path d="M6 3h9l5 5v13a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2Z" /><path d="M14 3v5h5" /><path d="M8 13h8" /><path d="M8 17h6" /></>,
    briefcase: <><path d="M9 7V5a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2v2" /><path d="M4 7h16v11a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V7Z" /><path d="M4 12h16" /></>,
    sparkles: <><path d="M12 3 10.5 8.5 5 10l5.5 1.5L12 17l1.5-5.5L19 10l-5.5-1.5L12 3Z" /><path d="M5 16v4" /><path d="M3 18h4" /><path d="M19 3v3" /><path d="M17.5 4.5h3" /></>,
    close: <><path d="M18 6 6 18" /><path d="m6 6 12 12" /></>,
  };
  return (
    <svg className={className} fill="none" stroke="currentColor" strokeLinecap="round"
      strokeLinejoin="round" strokeWidth="2" viewBox="0 0 24 24" aria-hidden="true">
      {paths[name]}
    </svg>
  );
};

const getInitials = (name: string) =>
  name.trim().split(/\s+/).map((n) => n[0]).join("").toUpperCase().slice(0, 2) || "ST";

// Sidebar — identical to College Dashboard, "Student Management" highlighted
const sidebarItems: Array<{ label: string; icon: IconName | any; route: string; badge?: number }> = [
  { label: "Dashboard", icon: "target", route: "/college-dashboard" },
  { label: "Student Management", icon: "users", route: "/college/students-management" },
  { label: "Recruiter Management", icon: "briefcase", route: "/college/recruiter-management" },
  { label: "Placement Statistics", icon: "briefcase", route: "/college/placement-statistics", badge: 5 },
  { label: "Notifications", icon: "alert", route: "/college/notifications", badge: 3 },
  { label: "Profile", icon: "user-check", route: "/college/profile" },
  { label: "Settings", icon: "user-check", route: "/college/settings" },
];

// ─── Types ──────────────────────────────────────────────────────────────────
interface Student {
  id: string;
  name: string;
  rollNo: string;
  department: "CSE" | "ECE" | "Mechanical" | "IT";
  year: string;
  skillScore: number;
  profileScore: number;
  status: "Placed" | "Eligible" | "Not Eligible" | "In Process";
  company?: string;
  email: string;
  phone: string;
}

// ─── Mock Data ──────────────────────────────────────────────────────────────
const STUDENTS: Student[] = [
  { id: "BIT2201", name: "Ananya Sharma", rollNo: "2021A7PS001P", department: "CSE", year: "Final Year", skillScore: 98, profileScore: 94, status: "Placed", company: "Microsoft", email: "ananya.s@pilani.bits-pilani.ac.in", phone: "+91 90011 22001" },
  { id: "BIT2202", name: "Rohan Mehta", rollNo: "2021A7PS014P", department: "IT", year: "Final Year", skillScore: 95, profileScore: 90, status: "Placed", company: "Google", email: "rohan.m@pilani.bits-pilani.ac.in", phone: "+91 90011 22002" },
  { id: "BIT2203", name: "Kavya Iyer", rollNo: "2021A7PS027P", department: "CSE", year: "Final Year", skillScore: 93, profileScore: 89, status: "In Process", email: "kavya.i@pilani.bits-pilani.ac.in", phone: "+91 90011 22003" },
  { id: "BIT2204", name: "Arjun Nair", rollNo: "2021A3PS009P", department: "Mechanical", year: "Final Year", skillScore: 47, profileScore: 51, status: "Not Eligible", email: "arjun.n@pilani.bits-pilani.ac.in", phone: "+91 90011 22004" },
  { id: "BIT2205", name: "Priya Nair", rollNo: "2021A7PS033P", department: "IT", year: "Final Year", skillScore: 88, profileScore: 82, status: "Eligible", email: "priya.n@pilani.bits-pilani.ac.in", phone: "+91 90011 22005" },
  { id: "BIT2206", name: "Ishaan Verma", rollNo: "2021A4PS041P", department: "ECE", year: "Final Year", skillScore: 71, profileScore: 68, status: "Eligible", email: "ishaan.v@pilani.bits-pilani.ac.in", phone: "+91 90011 22006" },
  { id: "BIT2207", name: "Diya Patel", rollNo: "2021A3PS017P", department: "Mechanical", year: "Final Year", skillScore: 44, profileScore: 49, status: "Not Eligible", email: "diya.p@pilani.bits-pilani.ac.in", phone: "+91 90011 22007" },
  { id: "BIT2208", name: "Vihaan Kapoor", rollNo: "2021A7PS052P", department: "CSE", year: "Final Year", skillScore: 90, profileScore: 87, status: "Placed", company: "TCS", email: "vihaan.k@pilani.bits-pilani.ac.in", phone: "+91 90011 22008" },
  { id: "BIT2209", name: "Meera Joshi", rollNo: "2021A4PS023P", department: "ECE", year: "Final Year", skillScore: 66, profileScore: 61, status: "Eligible", email: "meera.j@pilani.bits-pilani.ac.in", phone: "+91 90011 22009" },
  { id: "BIT2210", name: "Aditya Rao", rollNo: "2021A3PS038P", department: "Mechanical", year: "Final Year", skillScore: 58, profileScore: 55, status: "Eligible", email: "aditya.r@pilani.bits-pilani.ac.in", phone: "+91 90011 22010" },
  { id: "BIT2211", name: "Sneha Reddy", rollNo: "2021A7PS061P", department: "IT", year: "Final Year", skillScore: 84, profileScore: 79, status: "Eligible", email: "sneha.r@pilani.bits-pilani.ac.in", phone: "+91 90011 22011" },
  { id: "BIT2212", name: "Karan Malhotra", rollNo: "2021A4PS048P", department: "ECE", year: "Final Year", skillScore: 38, profileScore: 42, status: "Not Eligible", email: "karan.m@pilani.bits-pilani.ac.in", phone: "+91 90011 22012" },
];

const departments = ["All Departments", "CSE", "ECE", "Mechanical", "IT"] as const;
const statuses = ["All Status", "Placed", "Eligible", "Not Eligible", "In Process"] as const;

const statusStyle: Record<Student["status"], string> = {
  Placed: "bg-emerald-50 text-emerald-700 ring-emerald-100",
  Eligible: "bg-blue-50 text-blue-700 ring-blue-100",
  "Not Eligible": "bg-rose-50 text-rose-700 ring-rose-100",
  "In Process": "bg-amber-50 text-amber-700 ring-amber-100",
};

const scoreColor = (s: number) => (s >= 75 ? "#10b981" : s >= 50 ? "#f59e0b" : "#ef4444");

// ─── Student Detail Drawer ──────────────────────────────────────────────────
const StudentDrawer = ({ student, onClose }: { student: Student; onClose: () => void }) => (
  <div className="fixed inset-0 z-50 flex justify-end">
    <div className="absolute inset-0 bg-slate-900/40 backdrop-blur-[2px]" onClick={onClose} />
    <div className="relative flex h-full w-full max-w-sm flex-col overflow-y-auto border-l border-slate-200 bg-white shadow-2xl">
      <div className="flex items-center justify-between border-b border-slate-100 p-5">
        <p className="text-sm font-black text-slate-900">Student profile</p>
        <button onClick={onClose} className="rounded-lg p-1.5 text-slate-400 transition hover:bg-slate-100 hover:text-slate-700">
          <Icon name="close" className="h-4 w-4" />
        </button>
      </div>

      <div className="p-5">
        <div className="flex items-center gap-4">
          <div className="flex h-14 w-14 items-center justify-center rounded-full bg-slate-900 text-lg font-black text-white">
            {getInitials(student.name)}
          </div>
          <div>
            <p className="text-base font-black text-slate-900">{student.name}</p>
            <p className="mt-0.5 text-xs text-slate-500">{student.rollNo}</p>
            <span className={`mt-1.5 inline-block rounded-full px-2 py-0.5 text-[10px] font-bold ring-1 ${statusStyle[student.status]}`}>
              {student.status}
            </span>
          </div>
        </div>

        <div className="mt-5 grid grid-cols-2 gap-3">
          <div className="rounded-xl border border-slate-100 bg-slate-50 p-3.5 text-center">
            <p className="text-[10px] font-semibold text-slate-400">Skill score</p>
            <p className="mt-1 text-xl font-black" style={{ color: scoreColor(student.skillScore) }}>{student.skillScore}</p>
          </div>
          <div className="rounded-xl border border-slate-100 bg-slate-50 p-3.5 text-center">
            <p className="text-[10px] font-semibold text-slate-400">Profile score</p>
            <p className="mt-1 text-xl font-black" style={{ color: scoreColor(student.profileScore) }}>{student.profileScore}</p>
          </div>
        </div>

        <div className="mt-5 space-y-3.5 border-t border-slate-100 pt-4">
          {[
            { icon: "graduation" as IconName, label: "Department", value: `${student.department} · ${student.year}` },
            { icon: "mail" as IconName, label: "Email", value: student.email },
            { icon: "phone" as IconName, label: "Phone", value: student.phone },
            ...(student.company ? [{ icon: "briefcase" as IconName, label: "Placed at", value: student.company }] : []),
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
            View full report
          </button>
          <button className="flex-1 rounded-xl border border-slate-200 py-2.5 text-xs font-bold text-slate-600 transition hover:bg-slate-50">
            Message
          </button>
        </div>
      </div>
    </div>
  </div>
);

// ═══════════════════════════════════════════════════════════════════════════
// MAIN — Student Management
// ═══════════════════════════════════════════════════════════════════════════
export const StudentsManagement = () => {
  const { currentUser } = useAuth();
  const fullName = currentUser?.fullName || "BITS Pilani Placement Cell Admin";

  const [query, setQuery] = useState("");
  const [department, setDepartment] = useState<(typeof departments)[number]>("All Departments");
  const [status, setStatus] = useState<(typeof statuses)[number]>("All Status");
  const [page, setPage] = useState(1);
  const [selected, setSelected] = useState<Student | null>(null);
  const pageSize = 8;

  const filtered = useMemo(() => {
    return STUDENTS.filter((s) => {
      const matchesQuery =
        query.trim() === "" ||
        s.name.toLowerCase().includes(query.toLowerCase()) ||
        s.rollNo.toLowerCase().includes(query.toLowerCase());
      const matchesDept = department === "All Departments" || s.department === department;
      const matchesStatus = status === "All Status" || s.status === status;
      return matchesQuery && matchesDept && matchesStatus;
    });
  }, [query, department, status]);

  const paged = filtered.slice((page - 1) * pageSize, page * pageSize);
  const totalPages = Math.max(1, Math.ceil(filtered.length / pageSize));

  const summary = {
    total: STUDENTS.length,
    placed: STUDENTS.filter((s) => s.status === "Placed").length,
    eligible: STUDENTS.filter((s) => s.status === "Eligible").length,
    notEligible: STUDENTS.filter((s) => s.status === "Not Eligible").length,
  };

  return (
    <CollegeLayout
      sidebarItems={sidebarItems}
      sidebarHighlight="Student Management"
      userSummary={{ fullName, role: "Training & Placement Officer", status: "Placement cycle active" }}
      stats={{ label: "Overall placement rate", value: "82", subtitle: "This cycle", accent: "This cycle" }}
    >
      <>
        {/* Header */}
        <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <p className="text-[10px] font-bold uppercase tracking-widest text-slate-400">Student Records</p>
            <h1 className="mt-0.5 text-2xl font-black tracking-tight text-slate-900">Student management</h1>
            <p className="mt-1 text-sm text-slate-500">Track every registered student's placement readiness and status.</p>
          </div>
          <div className="flex gap-2.5">
            <button className="flex items-center gap-1.5 rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-xs font-bold text-slate-600 shadow-sm transition hover:bg-slate-50">
              <Icon name="download" className="h-3.5 w-3.5" />
              Export
            </button>
            <button className="flex items-center gap-1.5 rounded-xl bg-slate-900 px-4 py-2.5 text-xs font-bold text-white shadow-sm transition hover:bg-slate-800">
              <Icon name="plus" className="h-3.5 w-3.5" />
              Add student
            </button>
          </div>
        </div>

        {/* Stats row */}
        <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
          {[
            { label: "Total students", value: String(summary.total), icon: "users" as IconName, bg: "#eff6ff", change: "+38", up: true },
            { label: "Placed students", value: String(summary.placed), icon: "check" as IconName, bg: "#ecfdf5", change: "+42", up: true },
            { label: "Eligible students", value: String(summary.eligible), icon: "user-check" as IconName, bg: "#fffbeb", change: "+54", up: true },
            { label: "Not eligible", value: String(summary.notEligible), icon: "alert" as IconName, bg: "#fef2f2", change: "-54", up: false },
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
                placeholder="Search by name or roll no."
                className="w-full rounded-lg border border-slate-200 bg-slate-50 py-2.5 pl-9 pr-3 text-xs text-slate-700 placeholder-slate-400 outline-none focus:border-blue-300 focus:bg-white focus:ring-2 focus:ring-blue-50"
              />
            </div>
            <div className="flex flex-wrap gap-2.5">
              <div className="relative">
                <select
                  value={department}
                  onChange={(e) => { setDepartment(e.target.value as typeof department); setPage(1); }}
                  className="appearance-none rounded-lg border border-slate-200 bg-white py-2.5 pl-3 pr-8 text-xs font-semibold text-slate-600 outline-none focus:border-blue-300">
                  {departments.map((d) => <option key={d} value={d}>{d}</option>)}
                </select>
                <Icon name="chevron-down" className="pointer-events-none absolute right-2.5 top-1/2 h-3 w-3 -translate-y-1/2 text-slate-400" />
              </div>
              <div className="relative">
                <select
                  value={status}
                  onChange={(e) => { setStatus(e.target.value as typeof status); setPage(1); }}
                  className="appearance-none rounded-lg border border-slate-200 bg-white py-2.5 pl-3 pr-8 text-xs font-semibold text-slate-600 outline-none focus:border-blue-300">
                  {statuses.map((s) => <option key={s} value={s}>{s}</option>)}
                </select>
                <Icon name="chevron-down" className="pointer-events-none absolute right-2.5 top-1/2 h-3 w-3 -translate-y-1/2 text-slate-400" />
              </div>
            </div>
          </div>

          {/* Table */}
          <div className="mt-4 overflow-x-auto rounded-xl border border-slate-200">
            <table className="w-full min-w-[720px] text-left">
              <thead>
                <tr className="border-b border-slate-100 bg-slate-50">
                  {["Student", "Department", "Skill score", "Profile score", "Status", ""].map((h) => (
                    <th key={h} className="px-4 py-3 text-[10px] font-bold uppercase tracking-wider text-slate-400">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {paged.map((s, i) => (
                  <tr key={s.id} className={`transition hover:bg-slate-50/60 ${i < paged.length - 1 ? "border-b border-slate-100" : ""}`}>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-3">
                        <div className="flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-full bg-slate-900 text-[10px] font-black text-white">
                          {getInitials(s.name)}
                        </div>
                        <div className="min-w-0">
                          <p className="truncate text-[12px] font-bold text-slate-900">{s.name}</p>
                          <p className="text-[10px] text-slate-400">{s.rollNo}</p>
                        </div>
                      </div>
                    </td>
                    <td className="px-4 py-3 text-[11px] font-semibold text-slate-600">{s.department}</td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-2">
                        <div className="h-1.5 w-16 overflow-hidden rounded-full bg-slate-100">
                          <div className="h-1.5 rounded-full" style={{ width: `${s.skillScore}%`, background: scoreColor(s.skillScore) }} />
                        </div>
                        <span className="text-[11px] font-bold text-slate-700">{s.skillScore}</span>
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-2">
                        <div className="h-1.5 w-16 overflow-hidden rounded-full bg-slate-100">
                          <div className="h-1.5 rounded-full" style={{ width: `${s.profileScore}%`, background: scoreColor(s.profileScore) }} />
                        </div>
                        <span className="text-[11px] font-bold text-slate-700">{s.profileScore}</span>
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      <span className={`inline-block rounded-full px-2.5 py-0.5 text-[10px] font-bold ring-1 ${statusStyle[s.status]}`}>
                        {s.status}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-right">
                      <button onClick={() => setSelected(s)}
                        className="rounded-lg p-1.5 text-slate-400 transition hover:bg-slate-100 hover:text-slate-700">
                        <Icon name="eye" className="h-3.5 w-3.5" />
                      </button>
                    </td>
                  </tr>
                ))}
                {paged.length === 0 && (
                  <tr>
                    <td colSpan={6} className="px-4 py-10 text-center text-xs text-slate-400">
                      No students match these filters.
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
              <span className="font-semibold text-slate-600">{filtered.length}</span> students
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

      {selected && <StudentDrawer student={selected} onClose={() => setSelected(null)} />}
    </CollegeLayout>
  );
};

export default StudentsManagement;