import { type ReactNode } from "react";
import {
  useLocation,
  useNavigate,
} from "react-router-dom";

// ─── Icon System ──────────────────────────────────────────────────────────────

export type StudentSidebarIconName =
  | "dashboard"
  | "map"
  | "clipboard"
  | "graduation"
  | "briefcase"
  | "broadcast"
  | "building"
  | "settings"
  | "help"
  | "user-check"
  | "bell"
  | "award"
  | "resume"
  | "megaphone"
  | "search"
  | "logout"
  | "message"
  | "phone";

const Icon = ({
  name,
  className = "h-5 w-5",
}: {
  name: StudentSidebarIconName | string;
  className?: string;
}) => {
  const paths: Record<string, ReactNode> = {
    phone: (
      <path d="M6.6 10.8a15.9 15.9 0 0 0 6.6 6.6l2.2-2.2c.3-.3.7-.4 1-.3 1.1.4 2.3.6 3.6.6.6 0 1 .4 1 1V21c0 .6-.4 1-1 1C10.6 22 2 13.4 2 3c0-.6.4-1 1-1h3.5c.6 0 1 .4 1 1 0 1.3.2 2.5.6 3.6.1.3 0 .7-.3 1L6.6 10.8Z" />
    ),

    message: (
      <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v10Z" />
    ),

    logout: (
      <>
        <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" />
        <path d="m16 17 5-5-5-5" />
        <path d="M21 12H9" />
      </>
    ),

    search: (
      <>
        <circle cx="11" cy="11" r="6.5" />
        <path d="m16 16 4 4" />
      </>
    ),

    // Dashboard
    dashboard: (
      <>
        <rect x="3" y="3" width="7" height="7" rx="1.5" />
        <rect x="14" y="3" width="7" height="7" rx="1.5" />
        <rect x="3" y="14" width="7" height="7" rx="1.5" />
        <rect x="14" y="14" width="7" height="7" rx="1.5" />
      </>
    ),

    // Student Roadmap
    map: (
      <>
        <path d="M9 18 3 21V6l6-3 6 3 6-3v15l-6 3-6-3Z" />
        <path d="M9 3v15M15 6v15" />
      </>
    ),

    // Applied Projects
    clipboard: (
      <>
        <rect x="5" y="4" width="14" height="17" rx="2" />
        <path d="M9 4V2h6v2" />
        <path d="M9 9h6" />
        <path d="M9 13h6" />
        <path d="M9 17h4" />
      </>
    ),

    // Graduation
    graduation: (
      <>
        <path d="m3 9 9-5 9 5-9 5-9-5Z" />
        <path d="M7 11v5c2.5 2 7.5 2 10 0v-5" />
        <path d="M21 9v6" />
      </>
    ),

    // Projects
    briefcase: (
      <>
        <rect x="3" y="7" width="18" height="13" rx="2" />
        <path d="M8 7V5a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" />
        <path d="M3 12h18" />
      </>
    ),

    //Building
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
    // AI Hiring
    broadcast: (
      <>
        <circle cx="12" cy="12" r="2" />
        <path d="M8.5 16.5a6 6 0 0 1 0-9" />
        <path d="M15.5 7.5a6 6 0 0 1 0 9" />
        <path d="M5.5 19.5a10 10 0 0 1 0-15" />
        <path d="M18.5 4.5a10 10 0 0 1 0 15" />
      </>
    ),

    // Settings
    settings: (
      <>
        <circle cx="12" cy="12" r="3.2" />
        <path d="M19.4 15a1.7 1.7 0 0 0 .3 1.9l.1.1-1.8 1.8-.1-.1a1.7 1.7 0 0 0-1.9-.3 1.7 1.7 0 0 0-1 1.6v.2h-2.6V20a1.7 1.7 0 0 0-1-1.6 1.7 1.7 0 0 0-1.9.3l-.1.1-1.8-1.8.1-.1a1.7 1.7 0 0 0 .3-1.9 1.7 1.7 0 0 0-1.6-1H6v-2.6h.2a1.7 1.7 0 0 0 1.6-1 1.7 1.7 0 0 0-.3-1.9l-.1-.1 1.8-1.8.1.1a1.7 1.7 0 0 0 1.9.3 1.7 1.7 0 0 0 1-1.6V5h2.6v.2a1.7 1.7 0 0 0 1 1.6 1.7 1.7 0 0 0 1.9-.3l.1-.1 1.8 1.8-.1.1a1.7 1.7 0 0 0-.3 1.9 1.7 1.7 0 0 0 1.6 1h.2v2.6H21a1.7 1.7 0 0 0-1.6 1Z" />
      </>
    ),

    // Help
    help: (
      <>
        <circle cx="12" cy="12" r="9" />
        <path d="M9.8 9a2.3 2.3 0 1 1 4.2 1.3c-.8 1-2 1.2-2 2.7" />
        <path d="M12 16h.01" />
      </>
    ),

    // Profile
    "user-check": (
      <>
        <circle cx="9" cy="8" r="3" />
        <path d="M3.5 20a5.5 5.5 0 0 1 11 0" />
        <path d="M15 12l2 2 4-4" />
      </>
    ),

    // Notifications
    bell: (
      <>
        <path d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9Z" />
        <path d="M10 21h4" />
      </>
    ),

    // Certificates
    award: (
      <>
        <circle cx="12" cy="8" r="5" />
        <path d="m8.5 12.5-1.5 9 5-3 5 3-1.5-9" />
        <path d="M10 8l1.3 1.2L14 7" />
      </>
    ),

    // AI Resume
    resume: (
      <>
        <rect x="5" y="3" width="14" height="18" rx="2" />
        <path d="M9 7h6" />
        <path d="M9 11h6" />
        <path d="M9 15h4" />
        <path d="M9 18h6" />
      </>
    ),
    //Megaphone
    megaphone: (
      <>
        <path d="m3 11 18-5v12L3 14v-3Z" />
        <path d="M11 15v5" />
        <path d="M7 16.2a4 4 0 0 0 4 3.8" />
      </>
    ),
  };

  return (
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.8"
      strokeLinecap="round"
      strokeLinejoin="round"
      className={className}
      aria-hidden="true"
    >
      {paths[name] || paths.dashboard}
    </svg>
  );
};

// ─── Helpers ─────────────────────────────────────────────────────────────────

const getInitials = (name: string) =>
  name
    .trim()
    .split(/\s+/)
    .map((part) => part[0])
    .join("")
    .toUpperCase()
    .slice(0, 2) || "ST";

// ─── Types ───────────────────────────────────────────────────────────────────

export interface StudentSidebarNavItem {
  label: string;
  icon: StudentSidebarIconName | string;
  route: string;
  badge?: number;
}

export interface StudentSidebarProps {
  items?: StudentSidebarNavItem[];

  user?: {
    fullName: string;
    role: string;
    status?: string;
  };

  onNavigate?: (route: string) => void;

  onUpgradeClick?: () => void;

  onSettingsClick?: () => void;

  onHelpClick?: () => void;

  mobileOpen?: boolean;

  onMobileClose?: () => void;
}

const defaultStudentSidebarItems: Array<{
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

interface NavItemProps {
  item: StudentSidebarNavItem;
  active: boolean;
  onNavigate: (route: string) => void;
}

const NavItem = ({
  item,
  active,
  onNavigate,
}: NavItemProps) => {
  return (
    <li>
      <button
        type="button"
        onClick={() => onNavigate(item.route)}
        aria-current={active ? "page" : undefined}
        className={[
          "group relative flex w-full items-center gap-3 rounded-xl px-3 py-2.5",
          "text-left transition-all duration-200",
          "focus:outline-none focus-visible:ring-2",
          "focus-visible:ring-indigo-500 focus-visible:ring-offset-1",
          active
            ? "bg-purple-50 text-purple-700 shadow-sm ring-1 ring-purple-100"
            : "text-slate-500 hover:bg-slate-50 hover:text-slate-900",
        ].join(" ")}
      >
        {active && (
          <span className="absolute -left-3 top-1/2 h-7 w-1 -translate-y-1/2 rounded-r-full bg-purple-600" />
        )}

        <span
          className={[
            "flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-lg",
            "transition-all duration-200",
            active
              ? "bg-white text-purple-600 shadow-sm ring-1 ring-purple-100"
              : "text-slate-400 group-hover:bg-white group-hover:text-purple-500",
          ].join(" ")}
        >
          <Icon
            name={item.icon}
            className="h-[17px] w-[17px]"
          />
        </span>

        <span
          className={[
            "min-w-0 flex-1 truncate text-[12px] leading-5",
            active ? "font-bold" : "font-medium",
          ].join(" ")}
        >
          {item.label}
        </span>

        {item.badge !== undefined && (
          <span
            className={[
              "flex h-5 min-w-5 items-center justify-center",
              "rounded-full px-1.5 text-[9px] font-bold",
              active
                ? "bg-purple-600 text-white"
                : "bg-slate-100 text-slate-500 group-hover:bg-purple-50 group-hover:text-purple-600",
            ].join(" ")}
          >
            {item.badge}
          </span>
        )}
      </button>
    </li>
  );
};

const StudentSidebar = ({
  items = defaultStudentSidebarItems,

  user = {
    fullName: "Student",
    role: "Student",
    status: "Active",
  },

  onNavigate,
  onUpgradeClick,
  onSettingsClick,
  onHelpClick,

  mobileOpen = false,
  onMobileClose,
}: StudentSidebarProps) => {
  const navigate = useNavigate();
  const location = useLocation();

  const isActiveRoute = (route: string) => {
    if (route === "/student-dashboard") {
      return location.pathname === "/student-dashboard";
    }

    return (
      location.pathname === route ||
      location.pathname.startsWith(`${route}/`)
    );
  };

  const handleNavigate = (route: string) => {
    onNavigate?.(route);
    navigate(route);
    onMobileClose?.();
  };

  const handleSettings = () => {
    if (onSettingsClick) {
      onSettingsClick();
      onMobileClose?.();
      return;
    }

    handleNavigate("/student/settings");
  };

  const handleHelp = () => {
    if (onHelpClick) {
      onHelpClick();
      onMobileClose?.();
      return;
    }

    handleNavigate("/student/help");
  };

  const initials = getInitials(user.fullName);

  return (
    <>
      {mobileOpen && (
        <button
          type="button"
          aria-label="Close navigation"
          onClick={onMobileClose}
          className="fixed inset-0 z-40 bg-slate-950/30 backdrop-blur-[1px] md:hidden"
        />
      )}

      <aside
        className={[
          "fixed inset-y-0 left-0 z-50 flex w-[252px]",
          "flex-shrink-0 flex-col border-r border-[#E9E6EC] bg-[#FCF9F8]",
          "transition-transform duration-300 ease-in-out",
          "md:static md:translate-x-0",
          mobileOpen
            ? "translate-x-0"
            : "-translate-x-full",
        ].join(" ")}
      >
        <div className="flex h-[78px] flex-shrink-0 items-center border-b border-slate-100 px-5">
          <button
            type="button"
            onClick={() =>
              handleNavigate("/student-dashboard")
            }
            className="group flex min-w-0 items-center gap-3 rounded-xl focus:outline-none focus-visible:ring-2 focus-visible:ring-purple-500"
            aria-label="Go to student dashboard"
          >
            <span className="flex h-9 w-9 flex-shrink-0 items-center justify-center rounded-xl bg-[#5400D6] text-sm font-black text-white shadow-md shadow-purple-200 transition-transform group-hover:scale-105">
              C
            </span>

            <span className="truncate text-[18px] font-black tracking-tight text-[#5400D6]">
              C
              <span className="text-[#5400D6]">2</span>
              C
            </span>
          </button>
        </div>

        <div className="flex min-h-0 flex-1 flex-col overflow-y-auto px-3 py-5">
          <nav aria-label="Student navigation">
            <ul className="flex flex-col gap-1">
              {items.map((item) => (
                <NavItem
                  key={`${item.label}-${item.route}`}
                  item={item}
                  active={isActiveRoute(item.route)}
                  onNavigate={handleNavigate}
                />
              ))}
            </ul>
          </nav>
        </div>

        <div className="flex-shrink-0 px-3 pb-3">
          <div className="overflow-hidden rounded-2xl border border-slate-200 bg-slate-50">
            <div className="p-3.5">
              <button
                type="button"
                onClick={() =>
                  handleNavigate("/student/profile")
                }
                className="group flex w-full items-center gap-2.5 rounded-xl text-left focus:outline-none focus-visible:ring-2 focus-visible:ring-purple-500"
                title="Open My Profile"
              >
                <div className="flex h-9 w-9 flex-shrink-0 items-center justify-center rounded-xl bg-gradient-to-br from-indigo-600 to-teal-500 text-[11px] font-black text-white shadow-sm">
                  {initials}
                </div>

                <div className="min-w-0 flex-1">
                  <p className="truncate text-[11px] font-bold text-slate-900 group-hover:text-purple-700">
                    {user.fullName}
                  </p>

                  <div className="mt-0.5 flex items-center gap-1.5">
                    <p className="truncate text-[9px] text-slate-500">
                      {user.role}
                    </p>

                    {user.status && (
                      <>
                        <span className="h-1 w-1 rounded-full bg-emerald-400" />

                        <span className="text-[8px] font-semibold text-emerald-600">
                          {user.status}
                        </span>
                      </>
                    )}
                  </div>
                </div>

                <span className="text-slate-300 transition group-hover:translate-x-0.5 group-hover:text-purple-500">
                  →
                </span>
              </button>

              {onUpgradeClick && (
                <button
                  type="button"
                  onClick={onUpgradeClick}
                  className="mt-3 flex h-8 w-full items-center justify-center gap-2 rounded-lg bg-purple-700 text-[10px] font-bold text-white shadow-sm shadow-purple-200 transition hover:bg-purple-800 active:scale-[0.98] focus:outline-none focus-visible:ring-2 focus-visible:ring-purple-500 focus-visible:ring-offset-2"
                >
                  <span aria-hidden="true">✦</span>
                  Upgrade to Pro
                </button>
              )}
            </div>
          </div>
        </div>

        <div className="flex-shrink-0 border-t border-slate-100 px-3 py-3">
          <div className="grid grid-cols-2 gap-1">
            <button
              type="button"
              onClick={handleSettings}
              className="group flex items-center justify-center gap-2 rounded-xl px-2 py-2.5 text-[10px] font-semibold text-slate-500 transition hover:bg-slate-50 hover:text-purple-600 focus:outline-none focus-visible:ring-2 focus-visible:ring-purple-500"
            >
              <Icon
                name="settings"
                className="h-[15px] w-[15px] text-slate-400 group-hover:text-purple-500"
              />

              Settings
            </button>

            <button
              type="button"
              onClick={handleHelp}
              className="group flex items-center justify-center gap-2 rounded-xl px-2 py-2.5 text-[10px] font-semibold text-slate-500 transition hover:bg-slate-50 hover:text-purple-600 focus:outline-none focus-visible:ring-2 focus-visible:ring-purple-500"
            >
              <Icon
                name="help"
                className="h-[15px] w-[15px] text-slate-400 group-hover:text-purple-500"
              />

              Help
            </button>
          </div>
        </div>
      </aside>
    </>
  );
};

export default StudentSidebar;