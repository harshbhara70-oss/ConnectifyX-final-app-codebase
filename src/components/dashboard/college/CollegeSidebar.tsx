import React from "react";
import {
  LayoutDashboard,
  GraduationCap,
  Briefcase,
  Megaphone,
  Handshake,
  Users,
  BarChart3,
  Settings,
  Plus,
  Sparkles
} from "lucide-react";

export type ViewType =
  | "dashboard"
  | "students"
  | "departments"
  | "placement-cell"
  | "companies"
  | "jobs"
  | "readiness"
  | "at-risk"
  | "forecast"
  | "comparisons"
  | "assessments"
  | "mentors"
  | "reports"
  | "communications"
  | "broadcasts"
  | "settings";

interface CollegeSidebarProps {
  activeView: ViewType;
  onSelectView: (view: ViewType) => void;
  onNewDriveClick: () => void;
  isMobileOpen?: boolean;
  onCloseMobile?: () => void;
}

interface MenuItem {
  id: ViewType;
  label: string;
  icon: React.ElementType;
}

const MENU_ITEMS: MenuItem[] = [
  { id: "dashboard", label: "Dashboard", icon: LayoutDashboard },
  { id: "students", label: "Student Records", icon: GraduationCap },
  { id: "placement-cell", label: "Placement Management", icon: Briefcase },
  { id: "broadcasts", label: "Broadcast Center", icon: Megaphone },
  { id: "companies", label: "Recruiter Coordination", icon: Handshake },
  { id: "departments", label: "Batch Groups", icon: Users },
  { id: "reports", label: "Reports & Analytics", icon: BarChart3 },
  { id: "settings", label: "Settings", icon: Settings },
];

export const CollegeSidebar: React.FC<CollegeSidebarProps> = ({
  activeView,
  onSelectView,
  onNewDriveClick,
  isMobileOpen = false,
  onCloseMobile,
}) => {
  const handleItemClick = (id: ViewType) => {
    onSelectView(id);
    if (onCloseMobile) onCloseMobile();
  };

  return (
    <>
      {/* Mobile Backdrop */}
      {isMobileOpen && (
        <div
          className="fixed inset-0 bg-slate-900/40 backdrop-blur-xs z-40 lg:hidden"
          onClick={onCloseMobile}
        />
      )}

      <aside
        className={`fixed lg:sticky top-0 left-0 z-50 h-screen w-64 bg-white border-r border-slate-100 flex flex-col justify-between p-4 transition-transform duration-300 ease-in-out lg:translate-x-0 ${
          isMobileOpen ? "translate-x-0 shadow-2xl" : "-translate-x-full lg:translate-x-0"
        }`}
      >
        <div className="flex-1 overflow-y-auto space-y-6 scrollbar-thin scrollbar-thumb-slate-200 pr-1">
          {/* Header Branding */}
          <div className="flex items-center justify-between px-2 pt-1 pb-3 border-b border-slate-100">
            <div className="flex items-center gap-2.5">
              <div className="w-9 h-9 rounded-xl bg-gradient-to-tr from-purple-700 via-purple-600 to-indigo-600 flex items-center justify-center text-white shadow-md shadow-purple-500/20">
                <Sparkles className="w-5 h-5" />
              </div>
              <div>
                <h1 className="text-base font-extrabold tracking-tight text-slate-900 leading-tight">
                  Campus2Corporate
                </h1>
                <span className="block text-[10px] font-bold text-purple-600 tracking-wide uppercase">
                  College Admin Portal
                </span>
              </div>
            </div>

            {isMobileOpen && (
              <button
                onClick={onCloseMobile}
                className="lg:hidden text-slate-400 hover:text-slate-600 p-1"
              >
                ✕
              </button>
            )}
          </div>

          {/* Navigation Menu */}
          <nav className="space-y-1">
            {MENU_ITEMS.map((item) => {
              const Icon = item.icon;
              const isActive = activeView === item.id;

              return (
                <button
                  key={item.id}
                  onClick={() => handleItemClick(item.id)}
                  className={`w-full flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-xs md:text-sm font-semibold transition-all cursor-pointer ${
                    isActive
                      ? "bg-[#F3E8FF] text-[#7C3AED] shadow-xs"
                      : "text-slate-600 hover:bg-slate-50 hover:text-purple-700"
                  }`}
                >
                  <Icon className={`w-4 h-4 ${isActive ? "text-[#7C3AED]" : "text-slate-400"}`} />
                  <span>{item.label}</span>
                </button>
              );
            })}
          </nav>
        </div>

        {/* Bottom Action CTA */}
        <div className="pt-4 border-t border-slate-100 bg-white">
          <button
            onClick={onNewDriveClick}
            className="w-full bg-[#7C3AED] hover:bg-[#6B21A8] active:bg-purple-900 text-white font-bold py-3 px-4 rounded-xl flex items-center justify-center gap-2 shadow-md shadow-purple-500/20 transition-all transform hover:-translate-y-0.5 cursor-pointer text-xs md:text-sm"
          >
            <Plus className="w-4 h-4 stroke-[2.5]" />
            <span>Launch New Drive</span>
          </button>
        </div>
      </aside>
    </>
  );
};

