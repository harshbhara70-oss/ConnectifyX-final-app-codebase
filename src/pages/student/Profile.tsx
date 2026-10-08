import { useEffect, useState } from "react";
import { useAuth } from "../../context/AuthContext";
import StudentLayout from "../../components/student/StudentLayout";
import type { StudentSidebarIconName } from "../../components/student/StudentSidebar";
import {
  getApiErrorMessage,
  studentApi,
  unwrapData,
  type StudentProfile as StudentProfileType,
} from "../../services/studentApi";

type IconName =
  | "activity" | "alert" | "arrow-up" | "arrow-down" | "bell" | "briefcase"
  | "building" | "calendar" | "chart" | "check" | "clock" | "dashboard"
  | "database" | "file" | "graduation" | "lock" | "plug" | "search"
  | "settings" | "shield" | "sparkles" | "target" | "user-check" | "users"
  | "ai-brain" | "placement" | "resume" | "interview" | "risk" | "campus"
  | "automation" | "monitor" | "send" | "refresh" | "close" | "chevron-right"
  | "wand" | "zap" | "trending-up" | "cpu" | "mail" | "phone" | "book"
  | "award" | "upload" | "eye" | "message" | "chevron-down" | "lightbulb"
  | "clipboard" | "logout" | "camera" | "edit" | "trash" | "link" | "github"
  | "linkedin" | "globe" | "key" | "sun" | "moon" | "download" | "plus" | "megaphone";

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
    camera: <><path d="M4 8h3l1.5-2h7L17 8h3a1 1 0 0 1 1 1v10a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V9a1 1 0 0 1 1-1Z" /><circle cx="12" cy="13" r="3.5" /></>,
    edit: <><path d="M12 20h9" /><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L8 18l-4 1 1-4Z" /></>,
    trash: <><path d="M4 7h16" /><path d="M10 11v6" /><path d="M14 11v6" /><path d="M6 7l1 13a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2l1-13" /><path d="M9 7V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v3" /></>,
    link: <><path d="M9 15 15 9" /><path d="M11 6.5 13 4.5a4 4 0 0 1 5.5 5.5L16.5 12" /><path d="M13 17.5 11 19.5a4 4 0 0 1-5.5-5.5L7.5 12" /></>,
    github: <path d="M12 2a10 10 0 0 0-3.16 19.5c.5.1.68-.22.68-.48v-1.7c-2.78.6-3.37-1.34-3.37-1.34-.46-1.16-1.11-1.47-1.11-1.47-.9-.62.07-.6.07-.6 1 .07 1.53 1.03 1.53 1.03.9 1.53 2.34 1.09 2.91.83.09-.65.35-1.09.63-1.34-2.22-.25-4.56-1.11-4.56-4.94 0-1.09.39-1.98 1.03-2.68-.1-.25-.45-1.27.1-2.65 0 0 .84-.27 2.75 1.02a9.6 9.6 0 0 1 5 0c1.91-1.3 2.75-1.02 2.75-1.02.55 1.38.2 2.4.1 2.65.64.7 1.03 1.59 1.03 2.68 0 3.84-2.35 4.68-4.58 4.93.36.31.68.92.68 1.85v2.74c0 .27.18.58.69.48A10 10 0 0 0 12 2Z" />,
    linkedin: <><rect x="3" y="3" width="18" height="18" rx="2" /><path d="M7 10v7" /><path d="M7 7v.01" /><path d="M11 17v-4a2 2 0 0 1 4 0v4" /><path d="M11 10v7" /></>,
    globe: <><circle cx="12" cy="12" r="9" /><path d="M3 12h18" /><path d="M12 3a15 15 0 0 1 0 18" /><path d="M12 3a15 15 0 0 0 0 18" /></>,
    key: <><circle cx="8" cy="15" r="4" /><path d="m10.5 12.5 8-8" /><path d="M16 7l2 2" /><path d="M13.5 9.5l2 2" /></>,
    sun: <><circle cx="12" cy="12" r="4" /><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4" /></>,
    moon: <path d="M20 14.5A8.5 8.5 0 1 1 9.5 4a7 7 0 0 0 10.5 10.5Z" />,
    download: <><path d="M12 3v12" /><path d="m7 11 5 5 5-5" /><path d="M4 20h16" /></>,
    plus: <path d="M12 5v14M5 12h14" />,
    megaphone: <><path d="m3 11 16-5v12L3 13v-2Z" /><path d="M19 9v6" /><path d="M7 14.5 8.5 20H12l-1.5-5" /></>,
  };
  return (
    <svg className={className} style={style} fill="none" stroke="currentColor" strokeLinecap="round"
      strokeLinejoin="round" strokeWidth="2" viewBox="0 0 24 24" aria-hidden="true">
      {paths[name]}
    </svg>
  );
};

const getInitials = (name: string) =>
  name.trim().split(/\s+/).map((n) => n[0]).join("").toUpperCase().slice(0, 2) || "YS";

const useStudentProfile = () => {
  const { currentUser, updateCurrentUser } = useAuth();
  const fullName = currentUser?.fullName || currentUser?.name || "Student";
  const firstName = fullName.split(" ")[0] || "Student";
  const initials = getInitials(fullName);
  const email = currentUser?.email || "";
  const phone = currentUser?.phone || "";
  return { fullName, firstName, initials, email, phone, currentUser, updateCurrentUser };
};

const SectionHeader = ({ eyebrow, title, sub, icon, iconColor = "#8b5cf6" }:
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

interface EditableField {
  key: string; label: string; icon: IconName; value: string; type?: string; disabled?: boolean;
}

const InputRow = ({ field, editing, onChange }: {
  field: EditableField; editing: boolean; onChange: (key: string, value: string) => void;
}) => (
  <div>
    <label className="mb-1.5 flex items-center gap-1.5 text-[11px] font-bold text-slate-500">
      <Icon name={field.icon} className="h-3.5 w-3.5 text-slate-400" />
      {field.label}
    </label>
    <input
      type={field.type || "text"}
      value={field.value}
      disabled={!editing || field.disabled}
      onChange={(e) => onChange(field.key, e.target.value)}
      className={`w-full rounded-xl border px-3.5 py-2.5 text-sm outline-none transition ${
        editing && !field.disabled
          ? "border-slate-200 bg-white text-slate-800 focus:border-purple-300 focus:ring-2 focus:ring-purple-50"
          : "border-slate-100 bg-slate-50 text-slate-500"
      }`}
    />
  </div>
);

export const StudentProfile = () => {
  const { fullName, initials, email, phone, currentUser, updateCurrentUser } = useStudentProfile();
  const [editing, setEditing] = useState(false);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");
  const [profile, setProfile] = useState<StudentProfileType | null>(
    currentUser ? (currentUser as unknown as StudentProfileType) : null
  );

  const [personal, setPersonal] = useState<EditableField[]>([
    { key: "fullName", label: "Full Name", icon: "user-check", value: fullName },
    { key: "email", label: "Email Address", icon: "mail", value: email, disabled: true },
    { key: "phone", label: "Phone Number", icon: "phone", value: phone },
    { key: "college", label: "College", icon: "graduation", value: "" },
    { key: "branch", label: "Branch", icon: "book", value: "" },
    { key: "semester", label: "Current Semester", icon: "campus", value: "" },
    { key: "location", label: "Location", icon: "building", value: "" },
  ]);

  const [links, setLinks] = useState<EditableField[]>([
    { key: "github", label: "GitHub", icon: "github", value: "" },
    { key: "linkedIn", label: "LinkedIn", icon: "linkedin", value: "" },
    { key: "portfolio", label: "Portfolio", icon: "globe", value: "" },
  ]);

  const [bio, setBio] = useState("");

  const [skills, setSkills] = useState<string[]>([]);
  const [newSkill, setNewSkill] = useState("");

  const [resumeName, setResumeName] = useState("");

  useEffect(() => {
    let mounted = true;

    const loadProfile = async () => {
      setLoading(true);
      setError("");

      try {
        const response = await studentApi.getProfile();
        const student = unwrapData<{ student: StudentProfileType }>(response).student;
        if (!mounted) return;

        setProfile(student);
        setPersonal([
          { key: "fullName", label: "Full Name", icon: "user-check", value: student.fullName || student.name || "" },
          { key: "email", label: "Email Address", icon: "mail", value: student.email || "", disabled: true },
          { key: "phone", label: "Phone Number", icon: "phone", value: student.phone || "" },
          { key: "college", label: "College", icon: "graduation", value: String(student.college || "") },
          { key: "branch", label: "Branch", icon: "book", value: student.branch || "" },
          { key: "semester", label: "Current Semester", icon: "campus", value: student.semester ? String(student.semester) : "" },
          { key: "location", label: "Location", icon: "building", value: student.location || "" },
        ]);
        setLinks([
          { key: "github", label: "GitHub", icon: "github", value: student.github || "" },
          { key: "linkedIn", label: "LinkedIn", icon: "linkedin", value: student.linkedIn || "" },
          { key: "portfolio", label: "Portfolio", icon: "globe", value: student.portfolio || "" },
        ]);
        setBio(student.bio || "");
        setSkills(student.skills || []);
        setResumeName(student.resumeUrl || student.resume || "");
      } catch (loadError) {
        if (mounted) setError(getApiErrorMessage(loadError));
      } finally {
        if (mounted) setLoading(false);
      }
    };

    loadProfile();

    return () => {
      mounted = false;
    };
  }, []);

  const updateField = (list: EditableField[], setList: (f: EditableField[]) => void, key: string, value: string) => {
    setList(list.map((f) => (f.key === key ? { ...f, value } : f)));
  };

  const addSkill = () => {
    const s = newSkill.trim();
    if (s && !skills.includes(s)) setSkills([...skills, s]);
    setNewSkill("");
  };

  const removeSkill = (s: string) => setSkills(skills.filter((k) => k !== s));

  const fieldValue = (fields: EditableField[], key: string) =>
    fields.find((field) => field.key === key)?.value || "";

  const saveProfile = async () => {
    setSaving(true);
    setError("");

    try {
      const payload = {
        fullName: fieldValue(personal, "fullName"),
        phone: fieldValue(personal, "phone"),
        branch: fieldValue(personal, "branch"),
        semester: fieldValue(personal, "semester"),
        location: fieldValue(personal, "location"),
        bio,
        github: fieldValue(links, "github"),
        linkedIn: fieldValue(links, "linkedIn"),
        portfolio: fieldValue(links, "portfolio"),
        skills,
        resumeUrl: resumeName,
      };

      const response = await studentApi.updateProfile(payload);
      const student = unwrapData<{ student: StudentProfileType }>(response).student;
      setProfile(student);
      updateCurrentUser?.({
        ...(currentUser || {}),
        ...student,
        id: student.id,
        fullName: student.fullName || student.name || "",
        name: student.name || student.fullName || "",
        email: student.email,
        phone: student.phone || "",
        role: "student",
        semester: student.semester ? String(student.semester) : undefined,
      });
      setEditing(false);
    } catch (saveError) {
      setError(getApiErrorMessage(saveError));
    } finally {
      setSaving(false);
    }
  };

  return (
    <StudentLayout
      sidebarItems={sidebarItems}
      sidebarHighlight="My Profile"
      userSummary={{
        fullName,
        role:
          [profile?.branch, profile?.semester ? `Semester ${profile.semester}` : ""]
            .filter(Boolean)
            .join(" · ") || "Student",
        status: "Placement track active",
      }}
      stats={{
        label: "Profile completeness",
        value: String(
          Math.min(
            100,
            [
              profile?.name,
              profile?.email,
              profile?.phone,
              profile?.bio,
              profile?.github,
              profile?.portfolio,
            ].filter(Boolean).length * 16,
          ),
        ),
        subtitle: profile?.portfolio ? "Portfolio added" : "Add portfolio",
        accent: profile?.portfolio ? "Complete" : "Add portfolio",
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
            Loading profile...
          </div>
        )}

        {/* Profile hero */}
        <section className="relative overflow-hidden rounded-3xl border border-[#e8e0ed] bg-white shadow-sm">
          <div className="h-28 bg-[#5400D6]" />

          <div className="relative px-5 pb-5 sm:px-7 sm:pb-7">
            <div className="flex flex-col gap-5 lg:flex-row lg:items-end lg:justify-between">

              <div className="flex min-w-0 items-end gap-4">
                <div className="relative -mt-11 flex h-20 w-20 flex-shrink-0 items-center justify-center rounded-2xl border-4 border-white bg-slate-900 text-2xl font-black text-white shadow-lg">
                  {initials}

                  <button
                    type="button"
                    className="absolute -bottom-2 -right-2 flex h-7 w-7 items-center justify-center rounded-full border-2 border-white bg-[#5400D6] text-white shadow-md transition hover:bg-[#4500ad]"
                  >
                    <Icon name="camera" className="h-3.5 w-3.5" />
                  </button>
                </div>

                <div className="min-w-0 pb-1">
                  <div className="flex flex-wrap items-center gap-2">
                    <h1 className="truncate text-xl font-black text-slate-900 sm:text-2xl">
                      {fullName}
                    </h1>

                    <span className="rounded-full bg-[#5400D6]/10 px-2.5 py-1 text-[9px] font-bold text-[#5400D6]">
                      STUDENT
                    </span>
                  </div>

                  <p className="mt-1 text-xs text-slate-500">
                    {[profile?.branch, profile?.semester ? `Semester ${profile.semester}` : ""]
                      .filter(Boolean)
                      .join(" · ") || "Academic details not added"}
                  </p>
                </div>
              </div>

              <button
                type="button"
                onClick={() => (editing ? saveProfile() : setEditing(true))}
                disabled={saving}
                className={`inline-flex items-center justify-center gap-2 rounded-xl px-4 py-2.5 text-xs font-bold transition ${
                  editing
                    ? "bg-emerald-600 text-white hover:bg-emerald-500"
                    : "border border-slate-200 bg-white text-slate-700 hover:border-[#5400D6]/20 hover:bg-[#5400D6]/5 hover:text-[#5400D6]"
                }`}
              >
                <Icon name={editing ? "check" : "edit"} className="h-3.5 w-3.5" />
                {saving ? "Saving..." : editing ? "Save changes" : "Edit profile"}
              </button>
            </div>

            {/* Profile metrics */}
            <div className="mt-6 grid grid-cols-2 gap-3 sm:grid-cols-4">
              {[
                {
                  label: "Skills",
                  value: String(skills.length),
                  icon: "target" as IconName,
                  accent: "#10b981",
                },
                {
                  label: "Education",
                  value: String(profile?.education?.length || 0),
                  icon: "graduation" as IconName,
                  accent: "#5400D6",
                },
                {
                  label: "Certificates",
                  value: String(profile?.resumeUrl || profile?.resume ? 1 : 0),
                  icon: "award" as IconName,
                  accent: "#f59e0b",
                },
                {
                  label: "Resume",
                  value: resumeName ? "Yes" : "No",
                  icon: "resume" as IconName,
                  accent: "#f43f5e",
                },
              ].map((item) => (
                <div
                  key={item.label}
                  className="rounded-xl border border-slate-100 bg-slate-50 p-3"
                >
                  <div className="flex items-center gap-2">
                    <Icon
                      name={item.icon}
                      className="h-4 w-4"
                      style={{ color: item.accent } as React.CSSProperties}
                    />
                    <span
                      className="text-lg font-black"
                      style={{ color: item.accent }}
                    >
                      {item.value}
                    </span>
                  </div>
                  <p className="mt-1 text-[10px] font-semibold text-slate-400">
                    {item.label}
                  </p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* Main profile information */}
        <section className="grid gap-5 xl:grid-cols-[1.15fr_0.85fr]">

          <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm sm:p-6">
            <SectionHeader
              eyebrow="Account"
              title="Personal information"
              sub="Keep your academic and contact information current."
              icon="user-check"
              iconColor="#5400D6"
            />

            <div className="mt-5 grid gap-4 sm:grid-cols-2">
              {personal.map((field) => (
                <InputRow
                  key={field.key}
                  field={field}
                  editing={editing}
                  onChange={(key, value) =>
                    updateField(personal, setPersonal, key, value)
                  }
                />
              ))}
            </div>
          </div>

          <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm sm:p-6">
            <SectionHeader
              eyebrow="About"
              title="Professional summary"
              sub="A short introduction recruiters can understand quickly."
              icon="message"
              iconColor="#5400D6"
            />

            <textarea
              value={bio}
              disabled={!editing}
              onChange={(e) => setBio(e.target.value)}
              rows={8}
              placeholder="Tell recruiters about your interests, technical strengths and career goals..."
              className={`mt-5 w-full resize-none rounded-xl border px-4 py-3 text-xs leading-6 outline-none transition ${
                editing
                  ? "border-slate-200 bg-white text-slate-700 focus:border-[#5400D6]/30 focus:ring-2 focus:ring-[#5400D6]/10"
                  : "border-slate-100 bg-slate-50 text-slate-500"
              }`}
            />

            <div className="mt-3 flex items-center gap-2 rounded-xl bg-[#5400D6]/5 px-3 py-2.5">
              <Icon name="sparkles" className="h-3.5 w-3.5 text-[#5400D6]" />
              <p className="text-[10px] font-semibold text-slate-500">
                A complete summary helps your AI Resume and placement analysis.
              </p>
            </div>
          </div>
        </section>

        {/* Skills + online presence */}
        <section className="grid gap-5 xl:grid-cols-2">

          <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm sm:p-6">
            <SectionHeader
              eyebrow="Expertise"
              title="Skills"
              sub="These skills can be used across project and job matching."
              icon="sparkles"
              iconColor="#10b981"
            />

            <div className="mt-5 flex min-h-[92px] flex-wrap content-start gap-2">
              {skills.length > 0 ? (
                skills.map((skill) => (
                  <span
                    key={skill}
                    className="inline-flex items-center gap-1.5 rounded-full bg-[#5400D6]/10 px-3 py-1.5 text-[10px] font-bold text-[#5400D6]"
                  >
                    {skill}

                    {editing && (
                      <button
                        type="button"
                        onClick={() => removeSkill(skill)}
                        className="text-[#5400D6]/50 transition hover:text-rose-500"
                      >
                        <Icon name="close" className="h-2.5 w-2.5" />
                      </button>
                    )}
                  </span>
                ))
              ) : (
                <div className="w-full rounded-xl border border-dashed border-slate-200 bg-slate-50 p-5 text-center">
                  <Icon name="sparkles" className="mx-auto h-5 w-5 text-slate-300" />
                  <p className="mt-2 text-xs font-semibold text-slate-500">
                    No skills added yet
                  </p>
                </div>
              )}
            </div>

            {editing && (
              <div className="mt-4 flex gap-2">
                <input
                  value={newSkill}
                  onChange={(e) => setNewSkill(e.target.value)}
                  onKeyDown={(e) => e.key === "Enter" && addSkill()}
                  placeholder="Add a skill..."
                  className="min-w-0 flex-1 rounded-xl border border-slate-200 bg-white px-3.5 py-2.5 text-xs outline-none focus:border-[#5400D6]/30 focus:ring-2 focus:ring-[#5400D6]/10"
                />

                <button
                  type="button"
                  onClick={addSkill}
                  className="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-xl bg-[#5400D6] text-white transition hover:bg-[#4500ad]"
                >
                  <Icon name="plus" className="h-4 w-4" />
                </button>
              </div>
            )}
          </div>

          <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm sm:p-6">
            <SectionHeader
              eyebrow="Professional presence"
              title="Social & portfolio links"
              sub="Connect your work so recruiters can verify your projects."
              icon="link"
              iconColor="#f59e0b"
            />

            <div className="mt-5 space-y-4">
              {links.map((field) => (
                <InputRow
                  key={field.key}
                  field={field}
                  editing={editing}
                  onChange={(key, value) =>
                    updateField(links, setLinks, key, value)
                  }
                />
              ))}
            </div>
          </div>
        </section>

        {/* Resume + profile readiness */}
        <section className="grid gap-5 xl:grid-cols-[0.85fr_1.15fr]">

          <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm sm:p-6">
            <SectionHeader
              eyebrow="Documents"
              title="Resume"
              sub="Keep the resume connected to your student profile."
              icon="resume"
              iconColor="#f43f5e"
            />

            <div className="mt-5 rounded-2xl border border-dashed border-slate-200 bg-slate-50 p-5">
              <div className="flex items-start gap-3">
                <div className="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-xl bg-white text-[#5400D6] ring-1 ring-slate-200">
                  <Icon name="file" className="h-5 w-5" />
                </div>

                <div className="min-w-0 flex-1">
                  <p className="text-xs font-black text-slate-800">
                    {resumeName || "No resume uploaded"}
                  </p>
                  <p className="mt-1 text-[10px] leading-4 text-slate-400">
                    {resumeName
                      ? "Resume is connected to your profile."
                      : "Upload your latest resume to improve placement readiness."}
                  </p>
                </div>
              </div>

              <div className="mt-4 flex flex-wrap gap-2">
                {resumeName && (
                  <button
                    type="button"
                    className="inline-flex items-center gap-1.5 rounded-lg border border-slate-200 bg-white px-3 py-2 text-[10px] font-bold text-slate-600 hover:bg-slate-50"
                  >
                    <Icon name="download" className="h-3 w-3" />
                    Download
                  </button>
                )}

                <label className="inline-flex cursor-pointer items-center gap-1.5 rounded-lg bg-[#5400D6] px-3 py-2 text-[10px] font-bold text-white hover:bg-[#4500ad]">
                  <Icon name="upload" className="h-3 w-3" />
                  {resumeName ? "Replace resume" : "Upload resume"}
                  <input
                    type="file"
                    accept=".pdf,.doc,.docx"
                    className="hidden"
                    onChange={(e) =>
                      e.target.files?.[0] &&
                      setResumeName(e.target.files[0].name)
                    }
                  />
                </label>
              </div>
            </div>
          </div>

          <div className="rounded-2xl border border-[#5400D6]/10 bg-white p-5 shadow-sm sm:p-6">
            <SectionHeader
              eyebrow="Placement readiness"
              title="Profile readiness"
              sub="Complete these areas before applying to opportunities."
              icon="target"
              iconColor="#5400D6"
            />

            <div className="mt-5 space-y-4">
              {[
                {
                  label: "Basic information",
                  complete: Boolean(
                    fieldValue(personal, "fullName") &&
                      fieldValue(personal, "email") &&
                      fieldValue(personal, "phone"),
                  ),
                  detail: "Name, email and phone",
                },
                {
                  label: "Academic details",
                  complete: Boolean(
                    fieldValue(personal, "college") &&
                      fieldValue(personal, "branch") &&
                      fieldValue(personal, "semester"),
                  ),
                  detail: "College, branch and semester",
                },
                {
                  label: "Skills",
                  complete: skills.length >= 3,
                  detail: `${skills.length} skills added`,
                },
                {
                  label: "Professional links",
                  complete: Boolean(
                    fieldValue(links, "github") ||
                      fieldValue(links, "linkedIn") ||
                      fieldValue(links, "portfolio"),
                  ),
                  detail: "GitHub, LinkedIn or portfolio",
                },
                {
                  label: "Resume",
                  complete: Boolean(resumeName),
                  detail: resumeName ? "Resume connected" : "Resume missing",
                },
              ].map((item) => (
                <div
                  key={item.label}
                  className="flex items-center gap-3 rounded-xl border border-slate-100 bg-slate-50 p-3"
                >
                  <div
                    className={`flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-lg ${
                      item.complete
                        ? "bg-emerald-50 text-emerald-600"
                        : "bg-amber-50 text-amber-600"
                    }`}
                  >
                    <Icon
                      name={item.complete ? "check" : "alert"}
                      className="h-3.5 w-3.5"
                    />
                  </div>

                  <div className="min-w-0 flex-1">
                    <p className="text-xs font-bold text-slate-700">
                      {item.label}
                    </p>
                    <p className="mt-0.5 truncate text-[10px] text-slate-400">
                      {item.detail}
                    </p>
                  </div>

                  <span
                    className={`text-[9px] font-black ${
                      item.complete ? "text-emerald-600" : "text-amber-600"
                    }`}
                  >
                    {item.complete ? "READY" : "ADD"}
                  </span>
                </div>
              ))}
            </div>
          </div>
        </section>

      </div>
    </StudentLayout>
  );

};

export default StudentProfile;