
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../../context/AuthContext";
import CollegeLayout from "../../components/college/CollegeLayout";

// ─── Icon System (matches Admin Dashboard / College Dashboard) ───────────────
type IconName =
  | "activity" | "alert" | "bell" | "briefcase" | "building" | "calendar"
  | "check" | "clock" | "dashboard" | "graduation" | "lock" | "settings"
  | "shield" | "sparkles" | "target" | "users" | "refresh" | "close"
  | "chevron-right" | "mail" | "phone" | "book" | "eye" | "eye-off"
  | "lightbulb" | "clipboard" | "logout" | "download" | "trash" | "key"
  | "smartphone" | "user-check";

const Icon = ({ name, className = "h-4 w-4" }: { name: IconName; className?: string }) => {
  const paths: Record<IconName, React.ReactNode> = {
    activity: <path d="M4 12h3l2-6 4 12 2-6h5" />,
    alert: <><path d="M12 4 3.5 18.5h17L12 4Z" /><path d="M12 9v4" /><path d="M12 16h.01" /></>,
    bell: <><path d="M18 9a6 6 0 0 0-12 0c0 7-3 7-3 7h18s-3 0-3-7" /><path d="M10 20a2 2 0 0 0 4 0" /></>,
    briefcase: <><path d="M9 7V5a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2v2" /><path d="M4 7h16v11a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V7Z" /><path d="M4 12h16" /></>,
    building: <><path d="M5 21V5a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v16" /><path d="M3 21h18" /><path d="M9 7h1" /><path d="M14 7h1" /><path d="M9 11h1" /><path d="M14 11h1" /></>,
    calendar: <><path d="M7 3v4" /><path d="M17 3v4" /><rect x="4" y="5" width="16" height="16" rx="2" /><path d="M4 10h16" /></>,
    check: <><path d="M21 12a9 9 0 1 1-5-8" /><path d="m9 12 2 2 6-7" /></>,
    clock: <><circle cx="12" cy="12" r="9" /><path d="M12 7v5l3 2" /></>,
    dashboard: <><rect x="3" y="3" width="7" height="7" rx="1.5" /><rect x="14" y="3" width="7" height="7" rx="1.5" /><rect x="3" y="14" width="7" height="7" rx="1.5" /><rect x="14" y="14" width="7" height="7" rx="1.5" /></>,
    graduation: <><path d="m22 10-10-5-10 5 10 5 10-5Z" /><path d="M6 12v5c3 2 9 2 12 0v-5" /></>,
    lock: <><rect x="4" y="11" width="16" height="10" rx="2" /><path d="M8 11V8a4 4 0 0 1 8 0v3" /></>,
    settings: <><circle cx="12" cy="12" r="3" /><path d="M19 12a7.5 7.5 0 0 0-.1-1.2l2-1.5-2-3.5-2.4 1a7.5 7.5 0 0 0-2-1.2L14.2 3h-4.4l-.3 2.6a7.5 7.5 0 0 0-2 1.2l-2.4-1-2 3.5 2 1.5A7.5 7.5 0 0 0 5 12c0 .4 0 .8.1 1.2l-2 1.5 2 3.5 2.4-1a7.5 7.5 0 0 0 2 1.2l.3 2.6h4.4l.3-2.6a7.5 7.5 0 0 0 2-1.2l2.4 1 2-3.5-2-1.5c.1-.4.1-.8.1-1.2Z" /></>,
    shield: <><path d="M12 3 20 6v6c0 5-3.4 8-8 9-4.6-1-8-4-8-9V6l8-3Z" /><path d="m9 12 2 2 4-5" /></>,
    sparkles: <><path d="M12 3 10.5 8.5 5 10l5.5 1.5L12 17l1.5-5.5L19 10l-5.5-1.5L12 3Z" /><path d="M5 16v4" /><path d="M3 18h4" /><path d="M19 3v3" /><path d="M17.5 4.5h3" /></>,
    target: <><circle cx="12" cy="12" r="8" /><circle cx="12" cy="12" r="4" /><path d="M12 2v3" /><path d="M12 19v3" /><path d="M2 12h3" /><path d="M19 12h3" /></>,
    users: <><path d="M16 21v-2a4 4 0 0 0-4-4H7a4 4 0 0 0-4 4v2" /><circle cx="9.5" cy="7" r="4" /><path d="M22 21v-2a4 4 0 0 0-3-3.8" /><path d="M16 3.2a4 4 0 0 1 0 7.6" /></>,
    refresh: <><path d="M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8" /><path d="M21 3v5h-5" /><path d="M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16" /><path d="M8 16H3v5" /></>,
    close: <><path d="M18 6 6 18" /><path d="m6 6 12 12" /></>,
    "chevron-right": <path d="m9 18 6-6-6-6" />,
    mail: <><rect x="3" y="5" width="18" height="14" rx="2" /><path d="m3 7 9 6 9-6" /></>,
    phone: <path d="M6.6 10.8a15.9 15.9 0 0 0 6.6 6.6l2.2-2.2c.3-.3.7-.4 1-.3 1.1.4 2.3.6 3.6.6.6 0 1 .4 1 1V21c0 .6-.4 1-1 1C10.6 22 2 13.4 2 3c0-.6.4-1 1-1h3.5c.6 0 1 .4 1 1 0 1.3.2 2.5.6 3.6.1.3 0 .7-.3 1L6.6 10.8Z" />,
    book: <><path d="M4 5a2 2 0 0 1 2-2h9v16H6a2 2 0 0 0-2 2V5Z" /><path d="M15 3h3a2 2 0 0 1 2 2v14a2 2 0 0 0-2-2h-3" /></>,
    eye: <><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7Z" /><circle cx="12" cy="12" r="3" /></>,
    "eye-off": <><path d="M17.9 17.9A10.6 10.6 0 0 1 12 20c-6.5 0-10-7-10-7a18.4 18.4 0 0 1 4.2-5.2M9.9 4.2A9.6 9.6 0 0 1 12 4c6.5 0 10 7 10 7a18.5 18.5 0 0 1-2.2 3.1" /><path d="m2 2 20 20" /><path d="M9.5 9.5a3 3 0 0 0 4.2 4.2" /></>,
    lightbulb: <><path d="M9 18h6" /><path d="M10 21h4" /><path d="M12 3a6 6 0 0 0-4 10.5c.6.5 1 1.3 1 2.1V16h6v-.4c0-.8.4-1.6 1-2.1A6 6 0 0 0 12 3Z" /></>,
    clipboard: <><rect x="6" y="4" width="12" height="17" rx="2" /><path d="M9 4V3a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v1" /><path d="m9 12 2 2 4-4" /></>,
    logout: <><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" /><path d="m16 17 5-5-5-5" /><path d="M21 12H9" /></>,
    download: <><path d="M12 3v12" /><path d="m7 12 5 5 5-5" /><path d="M4 21h16" /></>,
    trash: <><path d="M4 7h16" /><path d="M10 11v6" /><path d="M14 11v6" /><path d="M6 7l1 13a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2l1-13" /><path d="M9 7V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v3" /></>,
    key: <><circle cx="8" cy="15" r="4" /><path d="m10.5 12.5 8-8" /><path d="M16.5 6.5 19 4" /><path d="m14.5 8.5 2 2" /></>,
    smartphone: <><rect x="6" y="2" width="12" height="20" rx="2" /><path d="M11 18h2" /></>,
    "user-check": <><path d="M15 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" /><circle cx="8.5" cy="7" r="4" /><path d="m16 11 2 2 4-5" /></>,
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

const useCollegeProfile = () => {
  const { currentUser, logout } = useAuth();
  const fullName = currentUser?.fullName || "BITS Pilani Placement Cell Admin";
  const initials = getInitials(fullName);
  const email = currentUser?.email || "placement@pilani.bits-pilani.ac.in";
  const phone = currentUser?.phone || "+91 9876543210";
  return { fullName, initials, email, phone, logout };
};

// ─── Reusable toggle switch ───────────────────────────────────────────────────
const ToggleSwitch = ({ checked, onChange }: { checked: boolean; onChange: (v: boolean) => void }) => (
  <button
    role="switch"
    aria-checked={checked}
    onClick={() => onChange(!checked)}
    className={`relative h-6 w-11 flex-shrink-0 rounded-full transition-colors duration-200 ${checked ? "bg-blue-600" : "bg-slate-200"}`}>
    <span
      className={`absolute top-0.5 h-5 w-5 rounded-full bg-white shadow transition-transform duration-200 ${checked ? "translate-x-[22px]" : "translate-x-0.5"}`}
    />
  </button>
);

// ─── Reusable settings row ────────────────────────────────────────────────────
const SettingRow = ({
  icon, title, description, control,
}: { icon: IconName; title: string; description: string; control: React.ReactNode }) => (
  <div className="flex items-center justify-between gap-4 py-3.5">
    <div className="flex items-start gap-3">
      <div className="mt-0.5 flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-lg bg-slate-50 ring-1 ring-slate-100">
        <Icon name={icon} className="h-3.5 w-3.5 text-slate-500" />
      </div>
      <div>
        <p className="text-[13px] font-bold text-slate-800">{title}</p>
        <p className="mt-0.5 text-[11px] leading-4 text-slate-400">{description}</p>
      </div>
    </div>
    <div className="flex-shrink-0">{control}</div>
  </div>
);

const SectionHeader = ({ eyebrow, title, icon, iconColor = "#2563eb" }:
  { eyebrow: string; title: string; icon: IconName; iconColor?: string }) => (
  <div className="flex items-center justify-between">
    <div>
      <p className="text-[10px] font-bold uppercase tracking-widest text-slate-400">{eyebrow}</p>
      <h2 className="mt-0.5 flex items-center gap-2 text-lg font-black text-slate-900">
        <span style={{ color: iconColor }}><Icon name={icon} className="h-4 w-4" /></span>
        {title}
      </h2>
    </div>
  </div>
);

// ═══════════════════════════════════════════════════════════════════════════
// MAIN PAGE
// ═══════════════════════════════════════════════════════════════════════════
export const CollegeSettings = () => {
  const { fullName, email, phone, logout } = useCollegeProfile();
  const navigate = useNavigate();

  // Notification preferences
  const [notifyEmail, setNotifyEmail] = useState(true);
  const [notifySms, setNotifySms] = useState(false);
  const [notifyRecruiter, setNotifyRecruiter] = useState(true);
  const [notifyDigest, setNotifyDigest] = useState(true);
  const [notifyDrives, setNotifyDrives] = useState(true);

  // Security
  const [twoFactor, setTwoFactor] = useState(false);
  const [showCurrentPw, setShowCurrentPw] = useState(false);
  const [showNewPw, setShowNewPw] = useState(false);
  const [currentPw, setCurrentPw] = useState("");
  const [newPw, setNewPw] = useState("");
  const [confirmPw, setConfirmPw] = useState("");
  const [pwSaved, setPwSaved] = useState(false);
  const [pwError, setPwError] = useState("");

  // Placement cycle configuration
  const [eligibilityThreshold, setEligibilityThreshold] = useState(70);
  const [autoNotifyEligible, setAutoNotifyEligible] = useState(true);

  // Danger zone
  const [confirmingDeactivate, setConfirmingDeactivate] = useState(false);

  const passwordsMismatch = newPw.length > 0 && confirmPw.length > 0 && newPw !== confirmPw;
  const pwStrength = newPw.length === 0 ? 0 : newPw.length < 6 ? 1 : newPw.length < 10 ? 2 : 3;
  const pwStrengthMeta = [
    { label: "", color: "#e2e8f0" },
    { label: "Weak", color: "#ef4444" },
    { label: "Okay", color: "#f59e0b" },
    { label: "Strong", color: "#10b981" },
  ][pwStrength];

  const handlePasswordSave = () => {
    if (!currentPw || !newPw || !confirmPw) {
      setPwError("Fill in all password fields.");
      return;
    }
    if (passwordsMismatch) {
      setPwError("New password and confirmation don't match.");
      return;
    }
    // Wired to the auth API in production; UI-only here.
    setPwError("");
    setCurrentPw(""); setNewPw(""); setConfirmPw("");
    setPwSaved(true);
    setTimeout(() => setPwSaved(false), 2500);
  };

  return (
    <CollegeLayout
      
      sidebarHighlight="Settings"
      userSummary={{ fullName, role: "Training & Placement Officer", status: "Placement cycle active" }}
      stats={{ label: "Overall placement rate", value: "82", subtitle: "This cycle", accent: "This cycle" }}
    >
      <>
        {/* Header */}
        <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="flex items-center gap-2.5">
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-slate-100">
              <Icon name="settings" className="h-4.5 w-4.5 text-slate-600" />
            </div>
            <div>
              <h1 className="text-xl font-black tracking-tight text-slate-900">Settings</h1>
              <p className="mt-0.5 text-xs text-slate-500">Manage your account, security, notifications and placement cycle preferences.</p>
            </div>
          </div>
        </div>

        {/* Account information */}
        <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
          <SectionHeader eyebrow="Account" title="Account information" icon="user-check" iconColor="#2563eb" />
          <div className="mt-4 grid gap-4 sm:grid-cols-2">
            <div>
              <label className="mb-1.5 flex items-center gap-1.5 text-[11px] font-bold uppercase tracking-wider text-slate-400">
                <Icon name="mail" className="h-3 w-3" />
                Email address
              </label>
              <div className="flex items-center justify-between rounded-lg bg-slate-50 px-3 py-2.5">
                <p className="text-sm font-semibold text-slate-800">{email}</p>
                <span className="rounded-full bg-emerald-50 px-2 py-0.5 text-[10px] font-bold text-emerald-700 ring-1 ring-emerald-100">Verified</span>
              </div>
            </div>
            <div>
              <label className="mb-1.5 flex items-center gap-1.5 text-[11px] font-bold uppercase tracking-wider text-slate-400">
                <Icon name="phone" className="h-3 w-3" />
                Phone number
              </label>
              <p className="rounded-lg bg-slate-50 px-3 py-2.5 text-sm font-semibold text-slate-800">{phone}</p>
            </div>
          </div>
          <p className="mt-3 text-[11px] text-slate-400">To update your name, phone, or designation, head to your Profile page.</p>
        </section>

        {/* Change password */}
        <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
          <SectionHeader eyebrow="Security" title="Change password" icon="key" iconColor="#8b5cf6" />
          <div className="mt-4 grid gap-4 sm:grid-cols-2">
            <div className="sm:col-span-2">
              <label className="mb-1.5 block text-[11px] font-bold uppercase tracking-wider text-slate-400">Current password</label>
              <div className="relative">
                <input
                  type={showCurrentPw ? "text" : "password"}
                  value={currentPw}
                  onChange={(e) => setCurrentPw(e.target.value)}
                  placeholder="Enter current password"
                  className="w-full rounded-lg border border-slate-200 bg-white px-3 py-2.5 pr-10 text-sm text-slate-700 placeholder-slate-400 outline-none focus:border-blue-300 focus:ring-2 focus:ring-blue-50"
                />
                <button type="button" onClick={() => setShowCurrentPw((v) => !v)}
                  className="absolute right-2.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600">
                  <Icon name={showCurrentPw ? "eye-off" : "eye"} className="h-4 w-4" />
                </button>
              </div>
            </div>

            <div>
              <label className="mb-1.5 block text-[11px] font-bold uppercase tracking-wider text-slate-400">New password</label>
              <div className="relative">
                <input
                  type={showNewPw ? "text" : "password"}
                  value={newPw}
                  onChange={(e) => setNewPw(e.target.value)}
                  placeholder="At least 8 characters"
                  className="w-full rounded-lg border border-slate-200 bg-white px-3 py-2.5 pr-10 text-sm text-slate-700 placeholder-slate-400 outline-none focus:border-blue-300 focus:ring-2 focus:ring-blue-50"
                />
                <button type="button" onClick={() => setShowNewPw((v) => !v)}
                  className="absolute right-2.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600">
                  <Icon name={showNewPw ? "eye-off" : "eye"} className="h-4 w-4" />
                </button>
              </div>
              {newPw.length > 0 && (
                <div className="mt-1.5 flex items-center gap-1.5">
                  <div className="h-1 flex-1 overflow-hidden rounded-full bg-slate-100">
                    <div className="h-1 rounded-full transition-all" style={{ width: `${(pwStrength / 3) * 100}%`, background: pwStrengthMeta.color }} />
                  </div>
                  <span className="text-[10px] font-semibold" style={{ color: pwStrengthMeta.color }}>{pwStrengthMeta.label}</span>
                </div>
              )}
            </div>

            <div>
              <label className="mb-1.5 block text-[11px] font-bold uppercase tracking-wider text-slate-400">Confirm new password</label>
              <input
                type={showNewPw ? "text" : "password"}
                value={confirmPw}
                onChange={(e) => setConfirmPw(e.target.value)}
                placeholder="Re-enter new password"
                className={`w-full rounded-lg border bg-white px-3 py-2.5 text-sm text-slate-700 placeholder-slate-400 outline-none focus:ring-2 ${
                  passwordsMismatch ? "border-rose-300 focus:border-rose-400 focus:ring-rose-50" : "border-slate-200 focus:border-blue-300 focus:ring-blue-50"
                }`}
              />
              {passwordsMismatch && <p className="mt-1 text-[11px] font-semibold text-rose-500">Passwords don't match.</p>}
            </div>
          </div>

          {pwError && (
            <div className="mt-3 flex items-center gap-2 rounded-lg border border-rose-100 bg-rose-50 px-3 py-2 text-xs text-rose-600">
              <Icon name="alert" className="h-3.5 w-3.5 flex-shrink-0" />
              {pwError}
            </div>
          )}
          {pwSaved && (
            <div className="mt-3 flex items-center gap-2 rounded-lg border border-emerald-100 bg-emerald-50 px-3 py-2 text-xs font-semibold text-emerald-700">
              <Icon name="check" className="h-3.5 w-3.5" />
              Password updated successfully.
            </div>
          )}

          <button onClick={handlePasswordSave}
            className="mt-4 flex items-center gap-1.5 rounded-xl bg-slate-900 px-4 py-2.5 text-xs font-bold text-white transition hover:bg-slate-800">
            <Icon name="key" className="h-3.5 w-3.5" />
            Update password
          </button>
        </section>

        {/* Two-factor authentication */}
        <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
          <SectionHeader eyebrow="Security" title="Two-factor authentication" icon="shield" iconColor="#10b981" />
          <div className="mt-2 divide-y divide-slate-100">
            <SettingRow
              icon="smartphone"
              title="SMS-based verification"
              description={`Send a one-time code to ${phone} when signing in from a new device.`}
              control={<ToggleSwitch checked={twoFactor} onChange={setTwoFactor} />}
            />
          </div>
          <div className={`mt-2 flex items-center gap-2 rounded-lg px-3 py-2 text-[11px] font-semibold ${
            twoFactor ? "bg-emerald-50 text-emerald-700" : "bg-slate-50 text-slate-500"
          }`}>
            <Icon name={twoFactor ? "check" : "alert"} className="h-3.5 w-3.5 flex-shrink-0" />
            {twoFactor ? "Two-factor authentication is enabled." : "Two-factor authentication is currently disabled."}
          </div>
        </section>

        {/* Notification preferences */}
        <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
          <SectionHeader eyebrow="Notifications" title="Notification preferences" icon="bell" iconColor="#f59e0b" />
          <div className="mt-2 divide-y divide-slate-100">
            <SettingRow icon="mail" title="Email notifications" description="Get key placement cell updates by email."
              control={<ToggleSwitch checked={notifyEmail} onChange={setNotifyEmail} />} />
            <SettingRow icon="phone" title="SMS alerts" description="Receive urgent alerts as text messages."
              control={<ToggleSwitch checked={notifySms} onChange={setNotifySms} />} />
            <SettingRow icon="building" title="Recruiter activity alerts" description="Notify me when recruiters view or shortlist student profiles."
              control={<ToggleSwitch checked={notifyRecruiter} onChange={setNotifyRecruiter} />} />
            <SettingRow icon="book" title="Weekly digest email" description="A weekly summary of placement progress and skill scores."
              control={<ToggleSwitch checked={notifyDigest} onChange={setNotifyDigest} />} />
            <SettingRow icon="calendar" title="Drive reminders" description="Remind me ahead of upcoming placement drives and deadlines."
              control={<ToggleSwitch checked={notifyDrives} onChange={setNotifyDrives} />} />
          </div>
        </section>

        {/* Placement cycle configuration */}
        <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
          <SectionHeader eyebrow="Placement Cycle" title="Placement cycle configuration" icon="target" iconColor="#2563eb" />
          <div className="mt-4">
            <div className="flex items-center justify-between">
              <label className="text-[11px] font-bold uppercase tracking-wider text-slate-400">Eligibility skill-score threshold</label>
              <span className="text-sm font-black text-blue-700">{eligibilityThreshold}</span>
            </div>
            <input
              type="range"
              min={40}
              max={95}
              step={1}
              value={eligibilityThreshold}
              onChange={(e) => setEligibilityThreshold(Number(e.target.value))}
              className="mt-2 w-full accent-blue-600"
            />
            <p className="mt-1 text-[11px] text-slate-400">Students scoring at or above this threshold are marked placement-eligible.</p>
          </div>

          <div className="mt-4 divide-y divide-slate-100 border-t border-slate-100">
            <SettingRow icon="bell" title="Auto-notify students when eligible" description="Automatically email students once their skill score crosses the threshold."
              control={<ToggleSwitch checked={autoNotifyEligible} onChange={setAutoNotifyEligible} />} />
          </div>
        </section>

        {/* Data & privacy */}
        <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
          <SectionHeader eyebrow="Data" title="Data & privacy" icon="clipboard" iconColor="#0ea5e9" />
          <div className="mt-4 grid gap-3 sm:grid-cols-2">
            <button className="flex items-center justify-between rounded-xl border border-slate-200 bg-slate-50 p-4 text-left transition hover:bg-slate-100">
              <div className="flex items-center gap-2.5">
                <Icon name="download" className="h-4 w-4 text-slate-500" />
                <div>
                  <p className="text-xs font-bold text-slate-800">Export institution data</p>
                  <p className="text-[11px] text-slate-400">Download student &amp; placement records as CSV</p>
                </div>
              </div>
              <Icon name="chevron-right" className="h-3.5 w-3.5 text-slate-300" />
            </button>
            <button onClick={logout}
              className="flex items-center justify-between rounded-xl border border-slate-200 bg-slate-50 p-4 text-left transition hover:bg-slate-100">
              <div className="flex items-center gap-2.5">
                <Icon name="logout" className="h-4 w-4 text-slate-500" />
                <div>
                  <p className="text-xs font-bold text-slate-800">Log out of all devices</p>
                  <p className="text-[11px] text-slate-400">End all active sessions, including this one</p>
                </div>
              </div>
              <Icon name="chevron-right" className="h-3.5 w-3.5 text-slate-300" />
            </button>
          </div>
        </section>

        {/* Danger zone */}
        <section className="rounded-2xl border border-rose-100 bg-rose-50/40 p-5 shadow-sm">
          <SectionHeader eyebrow="Danger Zone" title="Deactivate account" icon="alert" iconColor="#ef4444" />
          <p className="mt-3 text-xs leading-5 text-slate-500">
            Deactivating your admin account removes your access to the placement cell workspace. Student and placement data is retained and can be reassigned by another admin.
          </p>

          {!confirmingDeactivate ? (
            <button onClick={() => setConfirmingDeactivate(true)}
              className="mt-4 flex items-center gap-1.5 rounded-xl border border-rose-200 bg-white px-4 py-2.5 text-xs font-bold text-rose-600 transition hover:bg-rose-50">
              <Icon name="trash" className="h-3.5 w-3.5" />
              Deactivate my account
            </button>
          ) : (
            <div className="mt-4 rounded-xl border border-rose-200 bg-white p-4">
              <p className="text-xs font-bold text-rose-700">Are you sure? This action can be reversed only by a super-admin.</p>
              <div className="mt-3 flex gap-2">
                <button onClick={() => setConfirmingDeactivate(false)}
                  className="rounded-lg border border-slate-200 px-3.5 py-2 text-xs font-bold text-slate-600 transition hover:bg-slate-50">
                  Cancel
                </button>
                <button onClick={() => { setConfirmingDeactivate(false); navigate("/college-dashboard"); }}
                  className="rounded-lg bg-rose-600 px-3.5 py-2 text-xs font-bold text-white transition hover:bg-rose-700">
                  Yes, deactivate
                </button>
              </div>
            </div>
          )}
        </section>
      </>
    </CollegeLayout>
  );
};

export default CollegeSettings;
