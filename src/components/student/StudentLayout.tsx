import type { ReactNode } from "react";

import StudentNavbar from "./StudentNavbar";
import StudentSidebar, {
  type StudentSidebarNavItem,
} from "./StudentSidebar";

interface StudentLayoutProps {
  children: ReactNode;

  sidebarItems?: StudentSidebarNavItem[];

  sidebarHighlight?: string;

  userSummary?: {
    fullName?: string;
    role?: string;
    status?: string;
  };

  stats?: {
    label: string;
    value: string;
    subtitle?: string;
    accent?: string;
  };

  showAiButton?: boolean;

  onAiButtonClick?: () => void;

  onNavigate?: (route: string) => void;

  onUpgradeClick?: () => void;

  onSettingsClick?: () => void;

  onHelpClick?: () => void;
}

const StudentFooter = () => {
  const year = new Date().getFullYear();

  return (
    <footer className="border-t border-[#E6E0EA] bg-[#FCF9F8]">
      <div className="flex min-h-[58px] w-full items-center justify-between gap-4 px-5 py-3 sm:px-6 lg:px-8">
        <div className="flex min-w-0 items-center gap-3">
          <span className="flex-shrink-0 text-[13px] font-bold tracking-[-0.3px] text-[#5400D6]">
            C2C
          </span>

          <span className="hidden h-3 w-px bg-[#CBC3DA] sm:block" />

          <p className="hidden truncate text-[9px] leading-4 text-[#494457] sm:block">
            © {year} C2C Career Readiness Platform. Empowering the next
            generation of tech talent.
          </p>
        </div>

        <div className="flex flex-shrink-0 items-center gap-3 sm:gap-4">
          <button
            type="button"
            className="text-[9px] text-[#494457] transition-colors hover:text-[#5400D6]"
          >
            Privacy Policy
          </button>

          <button
            type="button"
            className="text-[9px] text-[#494457] transition-colors hover:text-[#5400D6]"
          >
            Terms of Service
          </button>

          <button
            type="button"
            className="hidden text-[9px] text-[#494457] transition-colors hover:text-[#5400D6] sm:block"
          >
            Contact Support
          </button>
        </div>
      </div>
    </footer>
  );
};

const FloatingAIButton = ({
  onClick,
}: {
  onClick?: () => void;
}) => {
  return (
    <button
      type="button"
      onClick={onClick}
      aria-label="Open AI Career Coach"
      className="fixed bottom-5 right-5 z-40 flex h-11 w-11 items-center justify-center rounded-full bg-[#5400D6] text-white shadow-lg shadow-purple-200 transition-all duration-200 hover:scale-105 hover:bg-[#4700B8] focus:outline-none focus-visible:ring-2 focus-visible:ring-[#5400D6] focus-visible:ring-offset-2 sm:bottom-6 sm:right-6"
    >
      <svg
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
        strokeLinejoin="round"
        className="h-5 w-5"
        aria-hidden="true"
      >
        <path d="M12 3v4" />
        <path d="M12 17v4" />
        <path d="M3 12h4" />
        <path d="M17 12h4" />
        <path d="m5.6 5.6 2.8 2.8" />
        <path d="m15.6 15.6 2.8 2.8" />
        <path d="m18.4 5.6-2.8 2.8" />
        <path d="m8.4 15.6-2.8 2.8" />
        <circle cx="12" cy="12" r="3.5" />
      </svg>
    </button>
  );
};

const StudentLayout = ({
  children,
  sidebarItems,
  sidebarHighlight: _sidebarHighlight = "Dashboard",
  userSummary,
  stats: _stats,
  showAiButton = true,
  onAiButtonClick,
  onNavigate,
  onUpgradeClick,
  onSettingsClick,
  onHelpClick,
}: StudentLayoutProps) => {
  const user = {
    fullName: userSummary?.fullName || "Student",
    role: userSummary?.role || "Career-Ready Student",
    status: userSummary?.status || "Active",
  };

  return (
    <div className="flex min-h-screen w-full overflow-x-hidden bg-[#FCF9F8]">
      <StudentSidebar
        items={sidebarItems}
        user={user}
        onNavigate={onNavigate}
        onUpgradeClick={onUpgradeClick}
        onSettingsClick={onSettingsClick}
        onHelpClick={onHelpClick}
      />

      <div className="flex min-h-screen min-w-0 flex-1 flex-col bg-[#FCF9F8]">
        <StudentNavbar
          showAiButton={showAiButton}
          onAiButtonClick={onAiButtonClick}
        />

        <main className="min-w-0 flex-1 overflow-x-hidden bg-[#FCF9F8]">
          <div className="w-full px-4 py-5 sm:px-5 sm:py-6 lg:px-7 lg:py-7">
            {children}
          </div>
        </main>

        <StudentFooter />
      </div>

      {showAiButton && (
        <FloatingAIButton onClick={onAiButtonClick} />
      )}
    </div>
  );
};

export default StudentLayout;