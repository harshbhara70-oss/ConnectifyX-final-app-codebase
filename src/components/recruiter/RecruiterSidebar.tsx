import { useLocation, useNavigate } from "react-router-dom";
import { useAuth } from "../../context/AuthContext";
import {
  LayoutDashboard,
  FilePlus2,
  Briefcase,
  FileBarChart2,
  UserCheck,
  MessageSquare,
  Settings,
  HelpCircle,
  LogOut,
  GraduationCap,
  ChevronRight,
} from "lucide-react";

const navItems = [
  { label: "Dashboard", icon: LayoutDashboard, route: "/recruiter/dashboard" },
  { label: "Post a Job", icon: FilePlus2, route: "/recruiter/post-job" },
  { label: "My Job Postings", icon: Briefcase, route: "/recruiter/my-postings" },
  { label: "Applications & Reports", icon: FileBarChart2, route: "/recruiter/applications" },
  { label: "Shortlisted Candidates", icon: UserCheck, route: "/recruiter/shortlisted-candidates" },
  { label: "Messages", icon: MessageSquare, route: "/recruiter/messages" },
  { label: "Settings", icon: Settings, route: "/recruiter/settings" },
];

interface RecruiterSidebarProps {
  highlight?: string;
}

const RecruiterSidebar = ({ highlight }: RecruiterSidebarProps) => {
  const location = useLocation();
  const navigate = useNavigate();
  const { logout } = useAuth();

  const isActive = (route: string) => {
    if (highlight) return highlight === route;
    return location.pathname === route || location.pathname.startsWith(route + "/");
  };

  return (
    <aside className="hidden lg:flex w-64 min-h-screen flex-shrink-0 flex-col border-r border-white/8"
      style={{
        background: "linear-gradient(180deg, #0f172a 0%, #111827 100%)",
        color: "white",
      }}
    >
      {/* Brand Logo — Click redirects to home page / */}
      <div 
        onClick={() => navigate("/")}
        className="flex items-center gap-3 px-5 py-4 border-b border-white/8 cursor-pointer hover:bg-white/5 transition-colors group"
        title="Go to Home Page"
      >
        <div className="grid w-10 h-10 place-items-center rounded-[14px] group-hover:scale-105 transition-transform"
          style={{ background: "linear-gradient(135deg, #5e17eb, #7c3aed)", boxShadow: "0 10px 24px rgb(37 99 235 / 0.22)" }}
        >
          <GraduationCap className="h-5 w-5 text-white" />
        </div>
        <div>
          <h2 className="text-lg font-extrabold leading-tight group-hover:text-purple-300 transition-colors">C2C</h2>
          <p className="text-xs font-semibold text-slate-400 mt-0.5">Recruiter Portal</p>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 flex flex-col gap-1 overflow-y-auto px-3 py-4" aria-label="Recruiter navigation">
        {navItems.map((item) => {
          const Icon = item.icon;
          const active = isActive(item.route);
          return (
            <button
              key={item.route}
              type="button"
              onClick={() => navigate(item.route)}
              className={`flex w-full items-center justify-between gap-2 rounded-xl px-3 py-2.5 text-sm font-semibold transition-all duration-150
                ${active
                  ? "bg-white/11 text-white shadow-[inset_0_0_0_1px_rgb(255_255_255/0.08)]"
                  : "text-slate-300 hover:bg-white/7 hover:text-white"
                }`}
              aria-current={active ? "page" : undefined}
            >
              <span className="inline-flex items-center gap-3">
                <Icon className="h-4 w-4" />
                {item.label}
              </span>
              {active && <ChevronRight className="h-3.5 w-3.5 text-blue-300" />}
            </button>
          );
        })}
      </nav>

      {/* Footer */}
      <div className="border-t border-white/8 px-3 py-3 space-y-1">
        <button
          type="button"
          onClick={() => {}}
          className="flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-semibold text-slate-400 hover:bg-white/7 hover:text-white transition-all duration-150"
        >
          <HelpCircle className="h-4 w-4" />
          Help Center
        </button>
        <button
          type="button"
          onClick={logout}
          className="flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-semibold text-slate-400 hover:bg-red-500/20 hover:text-red-300 transition-all duration-150"
        >
          <LogOut className="h-4 w-4" />
          Logout
        </button>
      </div>
    </aside>
  );
};

export default RecruiterSidebar;
