import CollegeNavbar from "./CollegeNavbar";
import CollegeSidebar, { type CollegeSidebarIconName } from "./CollegeSidebar";

interface CollegeLayoutProps {
  children: React.ReactNode;
  sidebarItems?: Array<{ label: string; icon: CollegeSidebarIconName; route: string; badge?: string | number }>;
  sidebarHighlight?: string;
  userSummary?: { fullName?: string; role?: string; status?: string };
  stats?: { label: string; value: string; subtitle?: string; accent?: string };
  showAiButton?: boolean;
  onAiButtonClick?: () => void;
}

const CollegeLayout = ({ children, sidebarItems, sidebarHighlight, userSummary, stats, showAiButton = true, onAiButtonClick }: CollegeLayoutProps) => {
  return (
    <div className="min-h-screen bg-slate-50 text-slate-900">
      <CollegeNavbar showAiButton={showAiButton} onAiButtonClick={onAiButtonClick} />

      <div className="mx-auto max-w-7xl px-4 py-6 sm:px-6 lg:px-8">
        <div className="flex gap-6">
          <CollegeSidebar items={sidebarItems} highlight={sidebarHighlight} userSummary={userSummary} stats={stats} />
          <main className="min-w-0 flex-1 space-y-5">{children}</main>
        </div>
      </div>
    </div>
  );
};

export default CollegeLayout;