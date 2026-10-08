import { useEffect, useState } from "react";
import { useAuth } from "../../context/AuthContext";
import StudentLayout from "../../components/student/StudentLayout";
import type { StudentSidebarIconName } from "../../components/student/StudentSidebar";
import {
  getApiErrorMessage,
  studentApi,
  unwrapData,
} from "../../services/studentApi";

// ─────────────────────────────────────────────────────────────────────────────
// ICON SYSTEM
// ─────────────────────────────────────────────────────────────────────────────

type IconName =
  | "activity"
  | "award"
  | "bell"
  | "briefcase"
  | "building"
  | "check"
  | "check-circle"
  | "clipboard"
  | "dashboard"
  | "eye"
  | "eye-off"
  | "file"
  | "info"
  | "interview"
  | "key"
  | "mail"
  | "map"
  | "megaphone"
  | "resume"
  | "settings"
  | "share2"
  | "shield"
  | "smartphone"
  | "target"
  | "trash"
  | "user-check"
  | "users"
  | "send";

const Icon = ({
  name,
  className = "h-4 w-4",
  style,
}: {
  name: IconName;
  className?: string;
  style?: React.CSSProperties;
}) => {
  const paths: Record<IconName, React.ReactNode> = {
    activity: (
      <path d="M4 12h3l2-6 4 12 2-6h5" />
    ),

    award: (
      <>
        <circle cx="12" cy="8" r="6" />
        <path d="m9 13.5-1 7.5 4-2 4 2-1-7.5" />
      </>
    ),

    bell: (
      <>
        <path d="M18 9a6 6 0 0 0-12 0c0 7-3 7-3 7h18s-3 0-3-7" />
        <path d="M10 20a2 2 0 0 0 4 0" />
      </>
    ),

    briefcase: (
      <>
        <path d="M9 7V5a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2v2" />
        <path d="M4 7h16v11a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V7Z" />
        <path d="M4 12h16" />
      </>
    ),

    building: (
      <>
        <path d="M5 21V5a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v16" />
        <path d="M3 21h18" />
        <path d="M9 7h1" />
        <path d="M14 7h1" />
        <path d="M9 11h1" />
        <path d="M14 11h1" />
      </>
    ),

    check: (
      <>
        <path d="M21 12a9 9 0 1 1-5-8" />
        <path d="m9 12 2 2 6-7" />
      </>
    ),

    "check-circle": (
      <>
        <circle cx="12" cy="12" r="9" />
        <path d="m8.5 12.5 2.3 2.3 4.7-5.1" />
      </>
    ),

    clipboard: (
      <>
        <rect x="6" y="4" width="12" height="17" rx="2" />
        <path d="M9 4V3a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v1" />
        <path d="m9 12 2 2 4-4" />
      </>
    ),

    dashboard: (
      <>
        <rect x="3" y="3" width="7" height="7" rx="1.5" />
        <rect x="14" y="3" width="7" height="7" rx="1.5" />
        <rect x="3" y="14" width="7" height="7" rx="1.5" />
        <rect x="14" y="14" width="7" height="7" rx="1.5" />
      </>
    ),

    eye: (
      <>
        <path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7Z" />
        <circle cx="12" cy="12" r="3" />
      </>
    ),

    "eye-off": (
      <>
        <path d="M3 3l18 18" />
        <path d="M10.6 5.1A9.9 9.9 0 0 1 12 5c6.5 0 10 7 10 7" />
        <path d="M6.6 6.6C4 8.3 2 12 2 12s3.5 7 10 7c1.4 0 2.7-.3 3.9-.8" />
        <path d="M9.9 9.9a3 3 0 0 0 4.2 4.2" />
      </>
    ),

    file: (
      <>
        <path d="M14 3H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9Z" />
        <path d="M14 3v6h6" />
        <path d="M8 13h8" />
        <path d="M8 17h5" />
      </>
    ),

    info: (
      <>
        <circle cx="12" cy="12" r="9" />
        <path d="M12 8h.01" />
        <path d="M11 12h1v5h1" />
      </>
    ),

    interview: (
      <>
        <path d="M6 7h12v8H9l-3 3V7Z" />
        <path d="M8 5h8" />
      </>
    ),

    key: (
      <>
        <circle cx="8" cy="15" r="4" />
        <path d="m10.8 12.2 7.7-7.7" />
        <path d="m16.5 5.5 2 2" />
        <path d="m14.5 7.5 2 2" />
      </>
    ),

    mail: (
      <>
        <rect x="3" y="5" width="18" height="14" rx="2" />
        <path d="m3 7 9 6 9-6" />
      </>
    ),

    map: (
      <>
        <path d="M4 6 9 3l6 3 5-3v15l-5 3-6-3-5 3V6Z" />
        <path d="M9 3v15" />
        <path d="M15 6v15" />
      </>
    ),

    megaphone: (
      <>
        <path d="m3 11 18-5v12L3 14v-3Z" />
        <path d="M11 15v5" />
        <path d="M7 16.2a4 4 0 0 0 4 3.8" />
      </>
    ),

    resume: (
      <>
        <path d="M6 3h9l5 5v13a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2Z" />
        <path d="M14 3v5h5" />
        <path d="M8 13h8" />
        <path d="M8 17h6" />
      </>
    ),

    settings: (
      <>
        <circle cx="12" cy="12" r="3" />
        <path d="M19 12a7.5 7.5 0 0 0-.1-1.2l2-1.5-2-3.5-2.4 1a7.5 7.5 0 0 0-2-1.2L14.2 3h-4.4l-.3 2.6a7.5 7.5 0 0 0-2 1.2l-2.4-1-2 3.5 2 1.5A7.5 7.5 0 0 0 5 12c0 .4 0 .8.1 1.2l-2 1.5 2 3.5 2.4-1a7.5 7.5 0 0 0 2 1.2l.3 2.6h4.4l.3-2.6a7.5 7.5 0 0 0 2-1.2l2.4 1 2-3.5-2-1.5c.1-.4.1-.8.1-1.2Z" />
      </>
    ),

    share2: (
      <>
        <circle cx="18" cy="5" r="3" />
        <circle cx="6" cy="12" r="3" />
        <circle cx="18" cy="19" r="3" />
        <path d="m8.6 10.6 6.8-3.8" />
        <path d="m8.6 13.4 6.8 3.8" />
      </>
    ),

    shield: (
      <>
        <path d="M12 3 20 6v6c0 5-3.4 8-8 9-4.6-1-8-4-8-9V6l8-3Z" />
        <path d="m9 12 2 2 4-5" />
      </>
    ),

    smartphone: (
      <>
        <rect x="6" y="2" width="12" height="20" rx="2" />
        <path d="M11 18h2" />
      </>
    ),

    target: (
      <>
        <circle cx="12" cy="12" r="8" />
        <circle cx="12" cy="12" r="4" />
        <path d="M12 2v3" />
        <path d="M12 19v3" />
        <path d="M2 12h3" />
        <path d="M19 12h3" />
      </>
    ),

    trash: (
      <>
        <path d="M3 6h18" />
        <path d="M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" />
        <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6" />
        <path d="M10 11v6" />
        <path d="M14 11v6" />
      </>
    ),

    "user-check": (
      <>
        <path d="M15 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" />
        <circle cx="8.5" cy="7" r="4" />
        <path d="m16 11 2 2 4-5" />
      </>
    ),

    users: (
      <>
        <path d="M16 21v-2a4 4 0 0 0-4-4H7a4 4 0 0 0-4 4v2" />
        <circle cx="9.5" cy="7" r="4" />
        <path d="M22 21v-2a4 4 0 0 0-3-3.8" />
        <path d="M16 3.2a4 4 0 0 1 0 7.6" />
      </>
    ),

    send: (
      <>
        <path d="m22 2-11 11" />
        <path d="m22 2-7 20-4-9-9-4 20-7z" />
      </>
    ),
  };

  return (
    <svg
      className={className}
      style={style}
      fill="none"
      stroke="currentColor"
      strokeLinecap="round"
      strokeLinejoin="round"
      strokeWidth="2"
      viewBox="0 0 24 24"
      aria-hidden="true"
    >
      {paths[name]}
    </svg>
  );
};

// ─────────────────────────────────────────────────────────────────────────────
// SIDEBAR
// ─────────────────────────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────────────────────
// TYPES
// ─────────────────────────────────────────────────────────────────────────────

type NotificationType =
  | "assignment"
  | "assessment"
  | "mentor"
  | "interview"
  | "system"
  | "achievement";

interface NotificationItem {
  id: string;
  type: NotificationType;
  title: string;
  desc: string;
  time: string;
  read: boolean;
}

interface NotificationPrefs {
  assignments: boolean;
  assessments: boolean;
  mentorSessions: boolean;
  interviews: boolean;
  achievements: boolean;
  email: boolean;
  push: boolean;
  sms: boolean;
}

interface PrivacyPrefs {
  profileVisibleToRecruiters: boolean;
  showActivityStatus: boolean;
  shareDataWithPartners: boolean;
  twoFactorAuth: boolean;
}

type FilterTab = "all" | "unread" | NotificationType;
type PageTab = "activity" | "preferences" | "privacy";

// ─────────────────────────────────────────────────────────────────────────────
// DEFAULT SETTINGS
// ─────────────────────────────────────────────────────────────────────────────

const defaultNotificationPrefs: NotificationPrefs = {
  assignments: true,
  assessments: true,
  mentorSessions: true,
  interviews: true,
  achievements: false,
  email: true,
  push: true,
  sms: false,
};

const defaultPrivacyPrefs: PrivacyPrefs = {
  profileVisibleToRecruiters: true,
  showActivityStatus: true,
  shareDataWithPartners: false,
  twoFactorAuth: false,
};

// ─────────────────────────────────────────────────────────────────────────────
// METADATA
// ─────────────────────────────────────────────────────────────────────────────

const typeMeta: Record<
  NotificationType,
  {
    icon: IconName;
    label: string;
    bg: string;
    fg: string;
  }
> = {
  assignment: {
    icon: "file",
    label: "Assignment",
    bg: "#F4EFFF",
    fg: "#5400D6",
  },
  assessment: {
    icon: "target",
    label: "Assessment",
    bg: "#FFF7ED",
    fg: "#F59E0B",
  },
  mentor: {
    icon: "users",
    label: "Mentor",
    bg: "#EEF2FF",
    fg: "#6366F1",
  },
  interview: {
    icon: "interview",
    label: "Interview",
    bg: "#FFF1F2",
    fg: "#F43F5E",
  },
  system: {
    icon: "info",
    label: "System",
    bg: "#F1F5F9",
    fg: "#64748B",
  },
  achievement: {
    icon: "award",
    label: "Achievement",
    bg: "#ECFDF5",
    fg: "#10B981",
  },
};

const filterTabs: { key: FilterTab; label: string }[] = [
  { key: "all", label: "All" },
  { key: "unread", label: "Unread" },
  { key: "assignment", label: "Assignments" },
  { key: "assessment", label: "Assessments" },
  { key: "mentor", label: "Mentor" },
  { key: "interview", label: "Interviews" },
  { key: "achievement", label: "Achievements" },
];

// ─────────────────────────────────────────────────────────────────────────────
// TOGGLE
// ─────────────────────────────────────────────────────────────────────────────

const Toggle = ({
  checked,
  onChange,
  label,
}: {
  checked: boolean;
  onChange: () => void;
  label: string;
}) => {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={checked}
      aria-label={label}
      onClick={onChange}
      className={`relative h-6 w-11 flex-shrink-0 rounded-full transition-colors ${
        checked ? "bg-[#5400D6]" : "bg-slate-300"
      }`}
    >
      <span
        className={`absolute top-1 h-4 w-4 rounded-full bg-white shadow-sm transition-all ${
          checked ? "left-6" : "left-1"
        }`}
      />
    </button>
  );
};

// ─────────────────────────────────────────────────────────────────────────────
// SETTING ROW
// ─────────────────────────────────────────────────────────────────────────────

const SettingRow = ({
  icon,
  iconBg,
  iconColor,
  title,
  description,
  checked,
  onChange,
}: {
  icon: IconName;
  iconBg: string;
  iconColor: string;
  title: string;
  description: string;
  checked: boolean;
  onChange: () => void;
}) => {
  return (
    <div className="flex items-center justify-between gap-5 border-b border-slate-100 py-4 last:border-b-0">
      <div className="flex min-w-0 items-center gap-3">
        <div
          className="flex h-9 w-9 flex-shrink-0 items-center justify-center rounded-xl"
          style={{ backgroundColor: iconBg }}
        >
          <Icon
            name={icon}
            className="h-4 w-4"
            style={{ color: iconColor } as React.CSSProperties}
          />
        </div>

        <div className="min-w-0">
          <p className="text-[13px] font-bold text-slate-800">
            {title}
          </p>
          <p className="mt-0.5 text-[11px] leading-4 text-slate-400">
            {description}
          </p>
        </div>
      </div>

      <Toggle
        checked={checked}
        onChange={onChange}
        label={title}
      />
    </div>
  );
};

// ─────────────────────────────────────────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────────────────────────────────────────

const SectionHeader = ({
  eyebrow,
  title,
  description,
  icon,
  iconColor = "#5400D6",
}: {
  eyebrow: string;
  title: string;
  description?: string;
  icon: IconName;
  iconColor?: string;
}) => {
  return (
    <div className="flex items-start justify-between gap-4">
      <div>
        <p className="text-[10px] font-bold uppercase tracking-widest text-slate-400">
          {eyebrow}
        </p>

        <h2 className="mt-1 flex items-center gap-2 text-lg font-black text-slate-900">
          <span style={{ color: iconColor }}>
            <Icon name={icon} className="h-4 w-4" />
          </span>
          {title}
        </h2>

        {description && (
          <p className="mt-1 text-xs leading-5 text-slate-400">
            {description}
          </p>
        )}
      </div>
    </div>
  );
};

// ─────────────────────────────────────────────────────────────────────────────
// MAIN PAGE
// ─────────────────────────────────────────────────────────────────────────────

export const StudentNotifications = () => {
  const { currentUser } = useAuth();

  const fullName =
    currentUser?.fullName ||
    currentUser?.name ||
    "Student";

  const email = currentUser?.email || "";

  const [items, setItems] = useState<NotificationItem[]>([]);
  const [activeFilter, setActiveFilter] =
    useState<FilterTab>("all");

  const [activePage, setActivePage] =
    useState<PageTab>("activity");

  const [notifPrefs, setNotifPrefs] =
    useState<NotificationPrefs>(
      defaultNotificationPrefs
    );

  const [privacyPrefs, setPrivacyPrefs] =
    useState<PrivacyPrefs>(
      defaultPrivacyPrefs
    );

  const [loading, setLoading] = useState(true);
  const [savingPrefs, setSavingPrefs] =
    useState(false);
  const [error, setError] = useState("");

  // ───────────────────────────────────────────────────────────────────────────
  // LOAD DATA
  // ───────────────────────────────────────────────────────────────────────────

  useEffect(() => {
    let mounted = true;

    const loadNotifications = async () => {
      setLoading(true);
      setError("");

      try {
        const response =
          await studentApi.getNotifications();

        const payload = unwrapData<{
          notifications: NotificationItem[];
          preferences?: Partial<NotificationPrefs>;
          privacy?: Partial<PrivacyPrefs>;
        }>(response);

        if (!mounted) return;

        setItems(payload.notifications || []);

        setNotifPrefs({
          ...defaultNotificationPrefs,
          ...(payload.preferences || {}),
        });

        setPrivacyPrefs({
          ...defaultPrivacyPrefs,
          ...(payload.privacy || {}),
        });
      } catch (loadError) {
        if (mounted) {
          setError(
            getApiErrorMessage(loadError)
          );
          setItems([]);
        }
      } finally {
        if (mounted) {
          setLoading(false);
        }
      }
    };

    void loadNotifications();

    return () => {
      mounted = false;
    };
  }, []);

  // ───────────────────────────────────────────────────────────────────────────
  // DERIVED DATA
  // ───────────────────────────────────────────────────────────────────────────

  const unreadCount = items.filter(
    (item) => !item.read
  ).length;

  const filteredItems = items.filter((item) => {
    if (activeFilter === "all") return true;

    if (activeFilter === "unread") {
      return !item.read;
    }

    return item.type === activeFilter;
  });

  // ───────────────────────────────────────────────────────────────────────────
  // NOTIFICATION ACTIONS
  // ───────────────────────────────────────────────────────────────────────────

  const markAsRead = async (id: string) => {
    setError("");

    try {
      const response =
        await studentApi.markNotificationRead(id);

      const payload = unwrapData<{
        notifications: NotificationItem[];
      }>(response);

      setItems(payload.notifications || []);
    } catch (readError) {
      setError(getApiErrorMessage(readError));
    }
  };

  const markAllAsRead = async () => {
    if (unreadCount === 0) return;

    setError("");

    try {
      const response =
        await studentApi.markAllNotificationsRead();

      const payload = unwrapData<{
        notifications: NotificationItem[];
      }>(response);

      setItems(payload.notifications || []);
    } catch (readError) {
      setError(getApiErrorMessage(readError));
    }
  };

  const dismiss = async (id: string) => {
    setError("");

    try {
      const response =
        await studentApi.deleteNotification(id);

      const payload = unwrapData<{
        notifications: NotificationItem[];
      }>(response);

      setItems(payload.notifications || []);
    } catch (deleteError) {
      setError(
        getApiErrorMessage(deleteError)
      );
    }
  };

  // ───────────────────────────────────────────────────────────────────────────
  // SETTINGS ACTIONS
  // ───────────────────────────────────────────────────────────────────────────

  const saveNotificationPrefs = async (
    next: NotificationPrefs
  ) => {
    setSavingPrefs(true);
    setError("");

    try {
      const response =
        await studentApi.updateSettings({
          settings: {
            notifications: next,
          },
        });

      const payload = unwrapData<{
        settings?: {
          notifications?: Partial<NotificationPrefs>;
        };
      }>(response);

      setNotifPrefs({
        ...defaultNotificationPrefs,
        ...(payload.settings?.notifications ||
          next),
      });
    } catch (saveError) {
      setError(
        getApiErrorMessage(saveError)
      );
    } finally {
      setSavingPrefs(false);
    }
  };

  const savePrivacyPrefs = async (
    next: PrivacyPrefs
  ) => {
    setSavingPrefs(true);
    setError("");

    try {
      const response =
        await studentApi.updateSettings({
          settings: {
            privacy: next,
          },
        });

      const payload = unwrapData<{
        settings?: {
          privacy?: Partial<PrivacyPrefs>;
        };
      }>(response);

      setPrivacyPrefs({
        ...defaultPrivacyPrefs,
        ...(payload.settings?.privacy || next),
      });
    } catch (saveError) {
      setError(
        getApiErrorMessage(saveError)
      );
    } finally {
      setSavingPrefs(false);
    }
  };

  const toggleNotifPref = (
    key: keyof NotificationPrefs
  ) => {
    const next = {
      ...notifPrefs,
      [key]: !notifPrefs[key],
    };

    setNotifPrefs(next);
    void saveNotificationPrefs(next);
  };

  const togglePrivacyPref = (
    key: keyof PrivacyPrefs
  ) => {
    const next = {
      ...privacyPrefs,
      [key]: !privacyPrefs[key],
    };

    setPrivacyPrefs(next);
    void savePrivacyPrefs(next);
  };

  // ───────────────────────────────────────────────────────────────────────────
  // PAGE
  // ───────────────────────────────────────────────────────────────────────────

  return (
    <StudentLayout
      sidebarItems={sidebarItems}
      sidebarHighlight="Notifications"
      userSummary={{
        fullName,
        role: "Student",
        status: "Placement track active",
      }}
      stats={{
        label: "Unread",
        value: String(unreadCount),
        subtitle: "Notifications",
        accent:
          unreadCount > 0
            ? "Needs attention"
            : "All caught up",
      }}
    >
      <div className="space-y-5">

        {/* ─────────────────────────────────────────────────────────────────── */}
        {/* PAGE HEADER */}
        {/* ─────────────────────────────────────────────────────────────────── */}

        <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
          <div className="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">

            <div className="flex items-start gap-3">
              <div className="flex h-11 w-11 flex-shrink-0 items-center justify-center rounded-xl bg-[#F4EFFF]">
                <Icon
                  name="bell"
                  className="h-5 w-5 text-[#5400D6]"
                />
              </div>

              <div>
                <p className="text-[10px] font-bold uppercase tracking-widest text-slate-400">
                  Student Activity
                </p>

                <h1 className="mt-1 text-2xl font-black tracking-tight text-slate-900">
                  Notifications
                </h1>

                <p className="mt-1 max-w-xl text-xs leading-5 text-slate-500">
                  Stay updated with assignments,
                  assessments, interviews, mentoring,
                  achievements, and placement activity.
                </p>
              </div>
            </div>

            <div className="flex items-center gap-2">
              <div className="rounded-xl border border-slate-200 bg-slate-50 px-4 py-2 text-center">
                <p className="text-lg font-black text-slate-900">
                  {items.length}
                </p>
                <p className="text-[10px] font-bold uppercase tracking-wide text-slate-400">
                  Total
                </p>
              </div>

              <div className="rounded-xl border border-[#E9DDFF] bg-[#F4EFFF] px-4 py-2 text-center">
                <p className="text-lg font-black text-[#5400D6]">
                  {unreadCount}
                </p>
                <p className="text-[10px] font-bold uppercase tracking-wide text-[#7C4DCE]">
                  Unread
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* ─────────────────────────────────────────────────────────────────── */}
        {/* ERROR */}
        {/* ─────────────────────────────────────────────────────────────────── */}

        {error && (
          <div className="flex items-center gap-3 rounded-xl border border-rose-100 bg-rose-50 px-4 py-3">
            <Icon
              name="info"
              className="h-4 w-4 flex-shrink-0 text-rose-500"
            />

            <p className="text-xs font-semibold text-rose-700">
              {error}
            </p>
          </div>
        )}

        {/* ─────────────────────────────────────────────────────────────────── */}
        {/* MAIN TABS */}
        {/* ─────────────────────────────────────────────────────────────────── */}

        <div className="rounded-2xl border border-slate-200 bg-white p-2 shadow-sm">
          <div className="grid grid-cols-3 gap-1">

            <button
              onClick={() => setActivePage("activity")}
              className={`flex items-center justify-center gap-2 rounded-xl px-3 py-2.5 text-xs font-bold transition ${
                activePage === "activity"
                  ? "bg-[#5400D6] text-white shadow-sm"
                  : "text-slate-500 hover:bg-slate-50 hover:text-slate-800"
              }`}
            >
              <Icon
                name="bell"
                className="h-3.5 w-3.5"
              />
              Activity
            </button>

            <button
              onClick={() => setActivePage("preferences")}
              className={`flex items-center justify-center gap-2 rounded-xl px-3 py-2.5 text-xs font-bold transition ${
                activePage === "preferences"
                  ? "bg-[#5400D6] text-white shadow-sm"
                  : "text-slate-500 hover:bg-slate-50 hover:text-slate-800"
              }`}
            >
              <Icon
                name="settings"
                className="h-3.5 w-3.5"
              />
              Preferences
            </button>

            <button
              onClick={() => setActivePage("privacy")}
              className={`flex items-center justify-center gap-2 rounded-xl px-3 py-2.5 text-xs font-bold transition ${
                activePage === "privacy"
                  ? "bg-[#5400D6] text-white shadow-sm"
                  : "text-slate-500 hover:bg-slate-50 hover:text-slate-800"
              }`}
            >
              <Icon
                name="shield"
                className="h-3.5 w-3.5"
              />
              Privacy
            </button>

          </div>
        </div>

        {/* ═══════════════════════════════════════════════════════════════════ */}
        {/* ACTIVITY */}
        {/* ═══════════════════════════════════════════════════════════════════ */}

        {activePage === "activity" && (
          <div className="space-y-5">

            {/* FILTERS */}
            <div className="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
              <div className="flex flex-col gap-3 lg:flex-row lg:items-center lg:justify-between">

                <div>
                  <p className="text-[10px] font-bold uppercase tracking-widest text-slate-400">
                    Activity Feed
                  </p>

                  <p className="mt-1 text-xs text-slate-500">
                    Review recent updates and placement activity.
                  </p>
                </div>

                <button
                  onClick={markAllAsRead}
                  disabled={unreadCount === 0}
                  className="inline-flex items-center justify-center gap-2 rounded-xl border border-slate-200 bg-white px-3.5 py-2 text-xs font-bold text-slate-600 transition hover:border-[#DCCBFF] hover:bg-[#F4EFFF] hover:text-[#5400D6] disabled:cursor-not-allowed disabled:opacity-40"
                >
                  <Icon
                    name="check-circle"
                    className="h-3.5 w-3.5"
                  />
                  Mark all as read
                </button>

              </div>

              <div className="mt-4 flex flex-wrap gap-1.5">
                {filterTabs.map((tab) => (
                  <button
                    key={tab.key}
                    onClick={() =>
                      setActiveFilter(tab.key)
                    }
                    className={`rounded-lg px-3 py-1.5 text-[11px] font-bold transition ${
                      activeFilter === tab.key
                        ? "bg-[#5400D6] text-white"
                        : "bg-slate-50 text-slate-500 hover:bg-slate-100 hover:text-slate-700"
                    }`}
                  >
                    {tab.label}

                    {tab.key === "unread" &&
                      unreadCount > 0 && (
                        <span
                          className={`ml-1.5 rounded-full px-1.5 py-0.5 text-[9px] ${
                            activeFilter === "unread"
                              ? "bg-white/20 text-white"
                              : "bg-[#F4EFFF] text-[#5400D6]"
                          }`}
                        >
                          {unreadCount}
                        </span>
                      )}
                  </button>
                ))}
              </div>
            </div>

            {/* NOTIFICATIONS */}
            <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">

              <SectionHeader
                eyebrow="Recent Updates"
                title={
                  activeFilter === "all"
                    ? "All notifications"
                    : filterTabs.find(
                        (tab) =>
                          tab.key === activeFilter
                      )?.label || "Notifications"
                }
                description={`${filteredItems.length} notification${
                  filteredItems.length === 1
                    ? ""
                    : "s"
                }`}
                icon="activity"
                iconColor="#5400D6"
              />

              {loading ? (
                <div className="mt-5 flex items-center gap-3 rounded-xl border border-slate-100 bg-slate-50 px-4 py-4">
                  <div className="h-4 w-4 animate-spin rounded-full border-2 border-slate-200 border-t-[#5400D6]" />

                  <p className="text-xs font-semibold text-slate-500">
                    Loading notifications...
                  </p>
                </div>
              ) : filteredItems.length === 0 ? (
                <div className="mt-5 flex flex-col items-center justify-center rounded-xl border border-dashed border-slate-200 bg-slate-50 px-6 py-12 text-center">
                  <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-white shadow-sm ring-1 ring-slate-200">
                    <Icon
                      name="bell"
                      className="h-5 w-5 text-slate-300"
                    />
                  </div>

                  <p className="mt-3 text-sm font-bold text-slate-700">
                    You're all caught up
                  </p>

                  <p className="mt-1 max-w-sm text-xs leading-5 text-slate-400">
                    There are no notifications matching
                    this filter right now.
                  </p>
                </div>
              ) : (
                <div className="mt-5 space-y-2">
                  {filteredItems.map((notification) => {
                    const meta =
                      typeMeta[notification.type];

                    return (
                      <div
                        key={notification.id}
                        className={`group rounded-xl border p-4 transition ${
                          notification.read
                            ? "border-slate-100 bg-white hover:border-slate-200 hover:bg-slate-50/50"
                            : "border-[#E9DDFF] bg-[#FDFCFF]"
                        }`}
                      >
                        <div className="flex items-start gap-3">

                          {/* ICON */}
                          <div
                            className="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-xl"
                            style={{
                              backgroundColor:
                                meta.bg,
                            }}
                          >
                            <Icon
                              name={meta.icon}
                              className="h-4 w-4"
                              style={
                                {
                                  color: meta.fg,
                                } as React.CSSProperties
                              }
                            />
                          </div>

                          {/* CONTENT */}
                          <div className="min-w-0 flex-1">

                            <div className="flex flex-wrap items-center gap-2">
                              {!notification.read && (
                                <span className="h-1.5 w-1.5 rounded-full bg-[#5400D6]" />
                              )}

                              <p className="text-[13px] font-bold text-slate-900">
                                {notification.title}
                              </p>

                              <span
                                className="rounded-md px-1.5 py-0.5 text-[9px] font-bold"
                                style={{
                                  backgroundColor:
                                    meta.bg,
                                  color: meta.fg,
                                }}
                              >
                                {meta.label}
                              </span>
                            </div>

                            <p className="mt-1 text-xs leading-5 text-slate-500">
                              {notification.desc}
                            </p>

                            <p className="mt-2 text-[10px] font-semibold text-slate-400">
                              {notification.time}
                            </p>
                          </div>

                          {/* ACTIONS */}
                          <div className="flex flex-shrink-0 items-center gap-1">

                            {!notification.read && (
                              <button
                                onClick={() =>
                                  markAsRead(
                                    notification.id
                                  )
                                }
                                title="Mark as read"
                                className="flex h-8 w-8 items-center justify-center rounded-lg text-slate-400 transition hover:bg-emerald-50 hover:text-emerald-600"
                              >
                                <Icon
                                  name="check"
                                  className="h-3.5 w-3.5"
                                />
                              </button>
                            )}

                            <button
                              onClick={() =>
                                dismiss(
                                  notification.id
                                )
                              }
                              title="Dismiss"
                              className="flex h-8 w-8 items-center justify-center rounded-lg text-slate-400 transition hover:bg-rose-50 hover:text-rose-600"
                            >
                              <Icon
                                name="trash"
                                className="h-3.5 w-3.5"
                              />
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
        )}

        {/* ═══════════════════════════════════════════════════════════════════ */}
        {/* PREFERENCES */}
        {/* ═══════════════════════════════════════════════════════════════════ */}

        {activePage === "preferences" && (
          <div className="grid gap-5 xl:grid-cols-2">

            {/* NOTIFICATION TYPES */}
            <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">

              <SectionHeader
                eyebrow="Notifications"
                title="What you receive"
                description="Choose which student activities should generate alerts."
                icon="bell"
                iconColor="#5400D6"
              />

              <div className="mt-3">

                <SettingRow
                  icon="file"
                  iconBg="#F4EFFF"
                  iconColor="#5400D6"
                  title="Assignment updates"
                  description="Deadlines, submissions, grading and module updates."
                  checked={notifPrefs.assignments}
                  onChange={() =>
                    toggleNotifPref(
                      "assignments"
                    )
                  }
                />

                <SettingRow
                  icon="target"
                  iconBg="#FFF7ED"
                  iconColor="#F59E0B"
                  title="Assessment reminders"
                  description="Aptitude tests and placement assessment alerts."
                  checked={notifPrefs.assessments}
                  onChange={() =>
                    toggleNotifPref(
                      "assessments"
                    )
                  }
                />

                <SettingRow
                  icon="users"
                  iconBg="#EEF2FF"
                  iconColor="#6366F1"
                  title="Mentor sessions"
                  description="Mentoring confirmations and upcoming session reminders."
                  checked={notifPrefs.mentorSessions}
                  onChange={() =>
                    toggleNotifPref(
                      "mentorSessions"
                    )
                  }
                />

                <SettingRow
                  icon="interview"
                  iconBg="#FFF1F2"
                  iconColor="#F43F5E"
                  title="Interview reminders"
                  description="Mock interviews and placement interview updates."
                  checked={notifPrefs.interviews}
                  onChange={() =>
                    toggleNotifPref(
                      "interviews"
                    )
                  }
                />

                <SettingRow
                  icon="award"
                  iconBg="#ECFDF5"
                  iconColor="#10B981"
                  title="Achievements"
                  description="Badges, milestones and placement progress."
                  checked={notifPrefs.achievements}
                  onChange={() =>
                    toggleNotifPref(
                      "achievements"
                    )
                  }
                />

              </div>
            </section>

            {/* DELIVERY */}
            <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">

              <SectionHeader
                eyebrow="Delivery"
                title="How you receive them"
                description="Control where important updates are delivered."
                icon="send"
                iconColor="#2563EB"
              />

              <div className="mt-3">

                <SettingRow
                  icon="mail"
                  iconBg="#EEF2FF"
                  iconColor="#2563EB"
                  title="Email notifications"
                  description={
                    email
                      ? `Sent to ${email}`
                      : "Receive important updates by email."
                  }
                  checked={notifPrefs.email}
                  onChange={() =>
                    toggleNotifPref("email")
                  }
                />

                <SettingRow
                  icon="bell"
                  iconBg="#F4EFFF"
                  iconColor="#5400D6"
                  title="Push notifications"
                  description="Real-time alerts in the browser and mobile app."
                  checked={notifPrefs.push}
                  onChange={() =>
                    toggleNotifPref("push")
                  }
                />

                <SettingRow
                  icon="smartphone"
                  iconBg="#ECFDF5"
                  iconColor="#10B981"
                  title="SMS alerts"
                  description="Only send critical placement and interview alerts."
                  checked={notifPrefs.sms}
                  onChange={() =>
                    toggleNotifPref("sms")
                  }
                />

              </div>

              {savingPrefs && (
                <div className="mt-4 flex items-center gap-2 rounded-xl border border-[#E9DDFF] bg-[#F4EFFF] px-3 py-2.5">
                  <div className="h-3.5 w-3.5 animate-spin rounded-full border-2 border-[#DCCBFF] border-t-[#5400D6]" />

                  <p className="text-[11px] font-semibold text-[#5400D6]">
                    Saving your preferences...
                  </p>
                </div>
              )}

            </section>
          </div>
        )}

        {/* ═══════════════════════════════════════════════════════════════════ */}
        {/* PRIVACY */}
        {/* ═══════════════════════════════════════════════════════════════════ */}

        {activePage === "privacy" && (
          <div className="grid gap-5 xl:grid-cols-2">

            {/* PRIVACY */}
            <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">

              <SectionHeader
                eyebrow="Visibility"
                title="Privacy controls"
                description="Control how your profile and activity are shared."
                icon="shield"
                iconColor="#10B981"
              />

              <div className="mt-3">

                <SettingRow
                  icon="eye"
                  iconBg="#ECFDF5"
                  iconColor="#10B981"
                  title="Profile visible to recruiters"
                  description="Allow approved hiring partners to view your profile and resume."
                  checked={
                    privacyPrefs.profileVisibleToRecruiters
                  }
                  onChange={() =>
                    togglePrivacyPref(
                      "profileVisibleToRecruiters"
                    )
                  }
                />

                <SettingRow
                  icon="activity"
                  iconBg="#F4EFFF"
                  iconColor="#5400D6"
                  title="Show activity status"
                  description="Allow mentors and admins to see your recent activity."
                  checked={
                    privacyPrefs.showActivityStatus
                  }
                  onChange={() =>
                    togglePrivacyPref(
                      "showActivityStatus"
                    )
                  }
                />

                <SettingRow
                  icon="share2"
                  iconBg="#FFF7ED"
                  iconColor="#F59E0B"
                  title="Share data with placement partners"
                  description="Share anonymized performance data to improve matching."
                  checked={
                    privacyPrefs.shareDataWithPartners
                  }
                  onChange={() =>
                    togglePrivacyPref(
                      "shareDataWithPartners"
                    )
                  }
                />

              </div>
            </section>

            {/* SECURITY */}
            <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">

              <SectionHeader
                eyebrow="Account Protection"
                title="Security"
                description="Keep your student account protected."
                icon="shield"
                iconColor="#2563EB"
              />

              <div className="mt-3">

                <SettingRow
                  icon="key"
                  iconBg="#EEF2FF"
                  iconColor="#2563EB"
                  title="Two-factor authentication"
                  description="Require an additional verification code when signing in."
                  checked={
                    privacyPrefs.twoFactorAuth
                  }
                  onChange={() =>
                    togglePrivacyPref(
                      "twoFactorAuth"
                    )
                  }
                />

              </div>

              <div className="mt-4 flex items-start gap-3 rounded-xl border border-slate-100 bg-slate-50 p-3.5">
                <div className="flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-lg bg-white ring-1 ring-slate-200">
                  <Icon
                    name="shield"
                    className="h-3.5 w-3.5 text-slate-500"
                  />
                </div>

                <div>
                  <p className="text-[11px] font-bold text-slate-700">
                    Your account security
                  </p>

                  <p className="mt-0.5 text-[10px] leading-4 text-slate-400">
                    Two-factor authentication adds an
                    additional verification step when
                    signing in from a new device.
                  </p>
                </div>
              </div>

              {savingPrefs && (
                <div className="mt-4 flex items-center gap-2 rounded-xl border border-[#E9DDFF] bg-[#F4EFFF] px-3 py-2.5">
                  <div className="h-3.5 w-3.5 animate-spin rounded-full border-2 border-[#DCCBFF] border-t-[#5400D6]" />

                  <p className="text-[11px] font-semibold text-[#5400D6]">
                    Saving security settings...
                  </p>
                </div>
              )}

            </section>
          </div>
        )}

        {/* ─────────────────────────────────────────────────────────────────── */}
        {/* FOOTER STATUS */}
        {/* ─────────────────────────────────────────────────────────────────── */}

        <div className="flex items-center justify-between rounded-xl border border-slate-100 bg-slate-50 px-4 py-3">
          <div className="flex items-center gap-2">
            <span className="h-2 w-2 rounded-full bg-emerald-500" />

            <p className="text-[11px] font-semibold text-slate-500">
              Notification system active
            </p>
          </div>

          <p className="text-[10px] font-medium text-slate-400">
            Preferences are saved automatically
          </p>
        </div>

      </div>
    </StudentLayout>
  );
};

export default StudentNotifications;