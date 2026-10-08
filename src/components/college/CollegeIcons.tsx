
export type IconName =
  | "activity"
  | "alert"
  | "arrow-up"
  | "arrow-down"
  | "bell"
  | "briefcase"
  | "building"
  | "calendar"
  | "chart"
  | "check"
  | "clock"
  | "dashboard"
  | "database"
  | "file"
  | "graduation"
  | "lock"
  | "plug"
  | "search"
  | "settings"
  | "shield"
  | "sparkles"
  | "target"
  | "user-check"
  | "users"
  | "ai-brain"
  | "placement"
  | "resume"
  | "interview"
  | "risk"
  | "campus"
  | "automation"
  | "monitor"
  | "send"
  | "refresh"
  | "close"
  | "chevron-right"
  | "wand"
  | "zap"
  | "trending-up"
  | "cpu"
  | "mail"
  | "phone"
  | "book"
  | "award"
  | "upload"
  | "eye"
  | "message"
  | "chevron-down"
  | "lightbulb"
  | "clipboard"
  | "map-pin"
  | "logout";

export const Icon = ({
  name,
  className = "h-4 w-4",
}: {
  name: IconName;
  className?: string;
}) => {
  const icons: Record<IconName, string> = {
    activity: "M4 12h3l2-6 4 12 2-6h5",
    alert: "M12 4 3.5 18.5h17L12 4ZM12 9v4M12 16h.01",
    "arrow-up": "M7 17 17 7M9 7h8v8",
    "arrow-down": "M7 7 17 17M17 9v8H9",
    bell: "M18 9a6 6 0 0 0-12 0c0 7-3 7-3 7h18s-3 0-3-7M10 20a2 2 0 0 0 4 0",
    briefcase: "M9 7V5a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2v2M4 7h16v11a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V7M4 12h16",
    building: "M5 21V5a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v16M3 21h18",
    calendar: "M7 3v4M17 3v4M4 5h16v16H4zM4 10h16",
    chart: "M4 19V5M4 19h16M8 16v-5M12 16V8M16 16v-7",
    check: "M21 12a9 9 0 1 1-5-8M9 12l2 2 6-7",
    clock: "M12 7v5l3 2M12 3a9 9 0 1 0 0 18",
    dashboard: "M3 3h7v7H3zM14 3h7v7h-7zM3 14h7v7H3zM14 14h7v7h-7z",
    database: "M5 5c0-2 14-2 14 0v14c0 2-14 2-14 0V5",
    file: "M14 3H6v18h12V9zM14 3v6h6",
    graduation: "M22 10 12 5 2 10l10 5 10-5M6 12v5c3 2 9 2 12 0v-5",
    lock: "M8 11V8a4 4 0 0 1 8 0v3M4 11h16v10H4z",
    plug: "M8 3v5M16 3v5M6 8h12v4a6 6 0 0 1-12 0z",
    search: "M16 16l4 4M11 18a7 7 0 1 1 0-14",
    settings: "M12 9a3 3 0 1 0 0 6a3 3 0 0 0 0-6",
    shield: "M12 3 20 6v6c0 5-3.4 8-8 9-4.6-1-8-4-8-9V6z",
    sparkles: "M12 3 10.5 8.5 5 10l5.5 1.5L12 17l1.5-5.5L19 10l-5.5-1.5z",
    target: "M12 2v3M12 19v3M2 12h3M19 12h3M12 12m-8 0a8 8 0 1 0 16 0a8 8 0 1 0-16 0",
    "user-check": "M15 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2M16 11l2 2 4-5",
    users: "M16 21v-2a4 4 0 0 0-4-4H7a4 4 0 0 0-4 4v2M9.5 11a4 4 0 1 0 0-8",
    "ai-brain": "M12 2v3M12 19v3M2 12h3M19 12h3",
    placement: "M12 4v12M8 12l4-4 4 4",
    resume: "M6 3h9l5 5v13H6z",
    interview: "M6 7h12v8H9l-3 3z",
    risk: "M12 3 3 19h18z",
    campus: "M4 21V9l8-5 8 5v12",
    automation: "M12 2v2M12 20v2M2 12h2M20 12h2",
    monitor: "M4 5h16v12H4zM8 21h8",
    send: "M22 2 11 13M22 2l-7 20-4-9-9-4z",
    refresh: "M3 12a9 9 0 0 1 15-6l3 2",
    close: "M18 6 6 18M6 6l12 12",
    "chevron-right": "M9 18l6-6-6-6",
    wand: "M15 5l4 4",
    zap: "M13 2 3 14h9l-1 8 10-12h-9z",
    "trending-up": "M22 7 13.5 15.5 8.5 10.5 2 17",
    cpu: "M4 4h16v16H4z",
    mail: "M3 5h18v14H3zM3 7l9 6 9-6",
    phone: "M6.6 10.8a15.9 15.9 0 0 0 6.6 6.6",
    book: "M4 5a2 2 0 0 1 2-2h9v16H6",
    award: "M12 2a6 6 0 1 0 0 12",
    upload: "M12 3v12M7 8l5-5 5 5",
    eye: "M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7z",
    message: "M21 15a2 2 0 0 1-2 2H7l-4 4V5h18z",
    "chevron-down": "M6 9l6 6 6-6",
    lightbulb: "M12 3a6 6 0 0 0-4 10.5",
    clipboard: "M6 4h12v17H6z",
    "map-pin": "M12 21s7-6.3 7-11.5a7 7 0 1 0-14 0c0 5.2 7 11.5 7 11.5z M12 13a3 3 0 1 0 0-6 3 3 0 0 0 0 6",
    logout: "M9 21H5V3h4M16 17l5-5-5-5M21 12H9",
  };

  return (
    <svg
      className={className}
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      viewBox="0 0 24 24"
    >
      {icons[name].split("M").filter(Boolean).map((path, i) => (
        <path key={i} d={`M${path}`} />
      ))}
    </svg>
  );
};

export const collegeSidebarItems = [
  {
    label: "Dashboard",
    icon: "dashboard",
    route: "/college/dashboard",
  },
  {
    label: "Student Management",
    icon: "users",
    route: "/college/student-management",
  },
  {
    label: "Recruiter Management",
    icon: "building",
    route: "/college/recruiter-management",
  },
  {
    label: "Placement Statistics",
    icon: "briefcase",
    route: "/college/placement-statistics",
  },
  {
    label: "Notifications",
    icon: "bell",
    route: "/college/notifications",
    badge: 3,
  },
  {
    label: "Profile & Settings",
    icon: "settings",
    route: "/college/profile-settings",
  },
] as const;

export const getInitials = (name: string) =>
  name
    .trim()
    .split(/\s+/)
    .map((word) => word[0])
    .join("")
    .toUpperCase()
    .slice(0, 2) || "TP";