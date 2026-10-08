import { useEffect, useRef, useState } from "react";
import { useAuth } from "../../context/AuthContext";
import { useLocation, useNavigate } from "react-router-dom";

type IconName =
  | "search"
  | "bell"
  | "chevron-down"
  | "user"
  | "settings"
  | "logout";

const Icon = ({
  name,
  className = "h-4 w-4",
}: {
  name: IconName;
  className?: string;
}) => {
  const paths: Record<IconName, React.ReactNode> = {
    search: (
      <>
        <circle cx="11" cy="11" r="6.5" />
        <path d="m16 16 4 4" />
      </>
    ),

    bell: (
      <>
        <path d="M18 9a6 6 0 0 0-12 0c0 7-3 7-3 7h18s-3 0-3-7" />
        <path d="M10 20a2 2 0 0 0 4 0" />
      </>
    ),

    "chevron-down": <path d="m6 9 6 6 6-6" />,

    user: (
      <>
        <circle cx="12" cy="8" r="3.5" />
        <path d="M5 20a7 7 0 0 1 14 0" />
      </>
    ),

    settings: (
      <>
        <circle cx="12" cy="12" r="3" />
        <path d="M19 12a7.5 7.5 0 0 0-.1-1.2l2-1.5-2-3.5-2.4 1a7.5 7.5 0 0 0-2-1.2L14.2 3h-4.4l-.3 2.6a7.5 7.5 0 0 0-2 1.2l-2.4-1-2 3.5 2 1.5A7.5 7.5 0 0 0 5 12c0 .4 0 .8.1 1.2l-2 1.5 2 3.5 2.4-1a7.5 7.5 0 0 0 2 1.2l.3 2.6h4.4l.3-2.6a7.5 7.5 0 0 0 2-1.2l2.4 1 2-3.5-2-1.5c.1-.4.1-.8.1-1.2Z" />
      </>
    ),

    logout: (
      <>
        <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" />
        <path d="m16 17 5-5-5-5" />
        <path d="M21 12H9" />
      </>
    ),
  };

  return (
    <svg
      className={className}
      fill="none"
      stroke="currentColor"
      strokeWidth="1.7"
      strokeLinecap="round"
      strokeLinejoin="round"
      viewBox="0 0 24 24"
      aria-hidden="true"
    >
      {paths[name]}
    </svg>
  );
};

const getInitials = (name: string) =>
  name
    .trim()
    .split(/\s+/)
    .map((part) => part[0])
    .join("")
    .toUpperCase()
    .slice(0, 2) || "ST";

interface StudentNavbarProps {
  showAiButton?: boolean;
  onAiButtonClick?: () => void;
}

const StudentNavbar = (_props: StudentNavbarProps = {}) => {
  const { currentUser, logout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const [profileOpen, setProfileOpen] = useState(false);
  const profileRef = useRef<HTMLDivElement>(null);

  const fullName =
    currentUser?.fullName ||
    currentUser?.name ||
    "Student";

  const firstName =
    fullName.split(" ")[0] || "Student";

  const initials = getInitials(fullName);

  const email = currentUser?.email || "";

  const unreadCount = 0;

  useEffect(() => {
    const handleOutsideClick = (event: MouseEvent) => {
      if (
        profileRef.current &&
        !profileRef.current.contains(event.target as Node)
      ) {
        setProfileOpen(false);
      }
    };

    document.addEventListener("mousedown", handleOutsideClick);

    return () => {
      document.removeEventListener("mousedown", handleOutsideClick);
    };
  }, []);

  useEffect(() => {
    setProfileOpen(false);
  }, [location.pathname]);

  const handleLogout = async () => {
    try {
      await logout?.();
      navigate("/");
    } catch (error) {
      console.error("Logout failed:", error);
    }
  };

  return (
    <header className="sticky top-0 z-40 w-full border-b border-[#E5DDE9] bg-[#FCF9F8]">
      <div className="flex min-h-[68px] w-full items-center gap-4 px-4 sm:px-6 lg:px-7">

        <div className="hidden min-w-[170px] flex-shrink-0 md:block">
          <p className="text-[9px] font-bold uppercase tracking-[0.18em] text-[#918899]">
            Student Workspace
          </p>

          <p className="mt-1 truncate text-[13px] font-bold tracking-[-0.2px] text-[#292631]">
            Welcome back, {firstName}
          </p>
        </div>

        <div className="mx-auto flex h-[40px] min-w-0 w-full max-w-[560px] items-center rounded-xl border border-[#E1D9E5] bg-white px-3 shadow-[0_2px_8px_rgba(73,68,87,0.035)] transition-all duration-200 hover:border-[#CFC4D7] focus-within:border-[#5400D6] focus-within:shadow-[0_0_0_3px_rgba(84,0,214,0.07)]">
          <Icon
            name="search"
            className="h-[16px] w-[16px] flex-shrink-0 text-[#827989]"
          />

          <input
            type="search"
            aria-label="Search"
            placeholder="Search roadmaps, projects, jobs..."
            className="ml-2 min-w-0 flex-1 border-none bg-transparent p-0 text-[11px] text-[#494457] outline-none placeholder:text-[#A19AA7]"
          />

          <span className="hidden rounded-md border border-[#E8E1EC] bg-[#FAF7FB] px-1.5 py-1 text-[8px] font-semibold text-[#9A919F] lg:block">
            /
          </span>
        </div>

        <div className="ml-auto flex flex-shrink-0 items-center gap-1.5">

          <button
            type="button"
            onClick={() => navigate("/student/notifications")}
            aria-label="Notifications"
            title="Notifications"
            className="relative flex h-[40px] w-[40px] items-center justify-center rounded-xl text-[#5D5664] transition-all duration-200 hover:bg-white hover:text-[#5400D6] active:scale-95 focus:outline-none focus:ring-2 focus:ring-[#5400D6]/20"
          >
            <Icon
              name="bell"
              className="h-[18px] w-[18px]"
            />

            {unreadCount > 0 && (
              <span className="absolute right-[8px] top-[7px] h-[7px] w-[7px] rounded-full bg-[#5400D6] ring-2 ring-[#FCF9F8]" />
            )}
          </button>

          <div
            ref={profileRef}
            className="relative"
          >
            <button
              type="button"
              onClick={() => setProfileOpen((value) => !value)}
              aria-expanded={profileOpen}
              aria-haspopup="menu"
              aria-label={`Open ${fullName} profile menu`}
              className={[
                "flex h-[44px] items-center gap-2 rounded-xl px-1.5 pr-2",
                "transition-all duration-200",
                "focus:outline-none focus:ring-2 focus:ring-[#5400D6]/20",
                profileOpen
                  ? "bg-white shadow-sm ring-1 ring-[#E4DCE8]"
                  : "hover:bg-white",
              ].join(" ")}
            >
              <span className="flex h-[34px] w-[34px] items-center justify-center rounded-xl bg-[#E8D9FA] text-[10px] font-black text-[#5400D6] ring-1 ring-[#DCC9F0]">
                {initials}
              </span>

              <span className="hidden min-w-0 text-left lg:block">
                <span className="block max-w-[110px] truncate text-[10px] font-bold text-[#292631]">
                  {fullName}
                </span>

                <span className="block text-[8px] text-[#8B8491]">
                  Student
                </span>
              </span>

              <Icon
                name="chevron-down"
                className={[
                  "h-[12px] w-[12px] text-[#7C7383] transition-transform duration-200",
                  profileOpen ? "rotate-180" : "",
                ].join(" ")}
              />
            </button>

            {profileOpen && (
              <div
                role="menu"
                className="absolute right-0 top-[52px] z-50 w-[250px] overflow-hidden rounded-2xl border border-[#E2D9E7] bg-white shadow-[0_16px_40px_rgba(52,39,63,0.14)]"
              >
                <div className="flex items-center gap-3 border-b border-[#EEE8F0] bg-[#FCF9F8] px-4 py-4">
                  <span className="flex h-[40px] w-[40px] flex-shrink-0 items-center justify-center rounded-xl bg-[#E8D9FA] text-[11px] font-black text-[#5400D6]">
                    {initials}
                  </span>

                  <div className="min-w-0">
                    <p className="truncate text-[11px] font-bold text-[#292631]">
                      {fullName}
                    </p>

                    {email && (
                      <p className="mt-0.5 truncate text-[9px] text-[#8B8491]">
                        {email}
                      </p>
                    )}
                  </div>
                </div>

                <div className="p-2">
                  <button
                    type="button"
                    role="menuitem"
                    onClick={() => {
                      navigate("/student/profile");
                      setProfileOpen(false);
                    }}
                    className="group flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-left text-[10px] font-medium text-[#494457] transition hover:bg-[#F5EFF9] hover:text-[#5400D6]"
                  >
                    <span className="flex h-8 w-8 items-center justify-center rounded-lg bg-[#F5EFF9] text-[#756C7D] group-hover:bg-[#EBDDFA] group-hover:text-[#5400D6]">
                      <Icon
                        name="user"
                        className="h-[15px] w-[15px]"
                      />
                    </span>

                    <span>My Profile</span>
                  </button>

                  <button
                    type="button"
                    role="menuitem"
                    onClick={() => {
                      navigate("/student/settings");
                      setProfileOpen(false);
                    }}
                    className="group flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-left text-[10px] font-medium text-[#494457] transition hover:bg-[#F5EFF9] hover:text-[#5400D6]"
                  >
                    <span className="flex h-8 w-8 items-center justify-center rounded-lg bg-[#F5EFF9] text-[#756C7D] group-hover:bg-[#EBDDFA] group-hover:text-[#5400D6]">
                      <Icon
                        name="settings"
                        className="h-[15px] w-[15px]"
                      />
                    </span>

                    <span>Settings</span>
                  </button>

                  <div className="my-2 border-t border-[#EEE8F0]" />

                  <button
                    type="button"
                    role="menuitem"
                    onClick={handleLogout}
                    className="group flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-left text-[10px] font-medium text-[#494457] transition hover:bg-[#F5EFF9] hover:text-[#5400D6]"
                  >
                    <span className="flex h-8 w-8 items-center justify-center rounded-lg bg-[#F5EFF9] text-[#756C7D] group-hover:bg-[#EBDDFA] group-hover:text-[#5400D6]">
                      <Icon
                        name="logout"
                        className="h-[15px] w-[15px]"
                      />
                    </span>

                    <span>Logout</span>
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </header>
  );
};

export default StudentNavbar;