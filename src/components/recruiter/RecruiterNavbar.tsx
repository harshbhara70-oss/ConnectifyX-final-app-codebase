import { useState, useEffect, useRef } from "react";
import { 
  Search, 
  Bell, 
  Settings as SettingsIcon, 
  ChevronDown, 
  User, 
  LogOut, 
  Briefcase, 
  FileText, 
  Users, 
  MessageSquare, 
  HelpCircle,
  X,
  Check,
  UserCheck,
  Building
} from "lucide-react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../../context/AuthContext";
import { cn } from "../../lib/utils";
import { pushRecruiterNotification } from "../../utils/recruiterNotifications";

interface RecruiterNavbarProps {
  title?: string;
  subtitle?: string;
}

const quickLinks = [
  { label: "Dashboard", route: "/recruiter/dashboard", icon: Briefcase },
  { label: "Post a Job", route: "/recruiter/post-job", icon: FileText },
  { label: "My Job Postings", route: "/recruiter/my-postings", icon: Briefcase },
  { label: "Applications & Reports", route: "/recruiter/applications", icon: Users },
  { label: "Shortlisted Candidates", route: "/recruiter/shortlisted-candidates", icon: UserCheck },
  { label: "Messages", route: "/recruiter/messages", icon: MessageSquare },
  { label: "Settings", route: "/recruiter/settings", icon: SettingsIcon },
];

const RecruiterNavbar = ({ title, subtitle }: RecruiterNavbarProps) => {
  const navigate = useNavigate();
  const { logout } = useAuth();

  // Search state
  const [searchQuery, setSearchQuery] = useState("");
  const [isSearchOpen, setIsSearchOpen] = useState(false);
  const searchInputRef = useRef<HTMLInputElement>(null);

  // Popover states
  const [showNotifs, setShowNotifs] = useState(false);
  const [showProfileMenu, setShowProfileMenu] = useState(false);

  // Ensure any dark class is removed on mount
  useEffect(() => {
    document.documentElement.classList.remove("dark");
    document.body.classList.remove("dark");
    document.documentElement.removeAttribute("data-theme");
    localStorage.removeItem("c2c_recruiter_theme");
  }, []);

  // Notifications state
  const [notifications, setNotifications] = useState<any[]>([]);

  const loadNotifications = () => {
    try {
      const stored = localStorage.getItem("c2c_recruiter_notifications");
      if (stored) {
        setNotifications(JSON.parse(stored));
      } else {
        setNotifications([]);
      }
    } catch (e) {
      console.error(e);
    }
  };

  useEffect(() => {
    loadNotifications();
    window.addEventListener("storage", loadNotifications);
    return () => window.removeEventListener("storage", loadNotifications);
  }, []);

  const unreadCount = notifications.filter(n => !n.read).length;

  const handleMarkAllRead = () => {
    const updated = notifications.map(n => ({ ...n, read: true }));
    setNotifications(updated);
    localStorage.setItem("c2c_recruiter_notifications", JSON.stringify(updated));
  };

  const handleClearAll = () => {
    setNotifications([]);
    localStorage.removeItem("c2c_recruiter_notifications");
  };

  // Press "/" or "Ctrl+K" to focus search bar
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.key === "/" || (e.ctrlKey && e.key === "k")) && document.activeElement?.tagName !== "INPUT" && document.activeElement?.tagName !== "TEXTAREA") {
        e.preventDefault();
        searchInputRef.current?.focus();
        setIsSearchOpen(true);
      }
      if (e.key === "Escape") {
        setIsSearchOpen(false);
      }
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, []);

  // Saved jobs & candidates from localStorage for search results
  const [storedJobs, setStoredJobs] = useState<any[]>([]);
  const [storedCandidates, setStoredCandidates] = useState<any[]>([]);

  useEffect(() => {
    try {
      const storedJ = localStorage.getItem("c2c_recruiter_jobs");
      if (storedJ) setStoredJobs(JSON.parse(storedJ));

      const storedC = localStorage.getItem("c2c_recruiter_candidates");
      if (storedC) setStoredCandidates(JSON.parse(storedC));
    } catch (e) {
      console.error(e);
    }
  }, [isSearchOpen]);

  const filteredLinks = quickLinks.filter(l => l.label.toLowerCase().includes(searchQuery.toLowerCase()));
  const filteredJobs = storedJobs.filter(j => j.title?.toLowerCase().includes(searchQuery.toLowerCase()));
  const filteredCandidates = storedCandidates.filter(c => 
    c.name?.toLowerCase().includes(searchQuery.toLowerCase()) || 
    c.role?.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!searchQuery.trim()) return;

    if (filteredLinks.length > 0) {
      navigate(filteredLinks[0].route);
    } else if (filteredJobs.length > 0) {
      navigate("/recruiter/my-postings");
    } else if (filteredCandidates.length > 0) {
      navigate("/recruiter/shortlisted-candidates");
    }
    setIsSearchOpen(false);
    setSearchQuery("");
  };

  return (
    <nav className="sticky top-0 z-30 flex items-center justify-between gap-4 border-b bg-white/90 px-6 py-3 backdrop-blur-md"
      style={{ borderColor: "var(--c2c-border)" }}
    >
      {/* Left — Title / Click redirects to Home page / */}
      <div 
        onClick={() => navigate("/")}
        className="min-w-0 cursor-pointer group"
        title="Click to go to Home Page"
      >
        {title && <h1 className="text-base font-extrabold text-slate-900 truncate group-hover:text-[#5e17eb] transition-colors">{title}</h1>}
        {subtitle && <p className="text-[13px] text-slate-500 mt-0.5 truncate">{subtitle}</p>}
      </div>

      {/* Right — Interactive Actions */}
      <div className="flex items-center gap-2.5 relative">
        {/* Interactive Global Search Input */}
        <div className="relative">
          <form onSubmit={handleSearchSubmit} className="flex items-center gap-2 h-10 min-w-[220px] sm:min-w-[280px] border rounded-xl bg-slate-50 px-3 text-[13px] text-slate-600 focus-within:bg-white focus-within:border-[#5e17eb] focus-within:ring-2 focus-within:ring-[#5e17eb]/20 transition-all"
            style={{ borderColor: "var(--c2c-border)" }}
          >
            <Search className="h-4 w-4 text-slate-400 shrink-0" />
            <input
              ref={searchInputRef}
              type="text"
              value={searchQuery}
              onChange={(e) => {
                setSearchQuery(e.target.value);
                setIsSearchOpen(true);
              }}
              onFocus={() => setIsSearchOpen(true)}
              placeholder="Search pages, candidates, jobs..."
              className="w-full bg-transparent focus:outline-none placeholder:text-slate-400 font-medium text-slate-800"
            />
            {searchQuery ? (
              <button 
                type="button" 
                onClick={() => {
                  setSearchQuery("");
                  setIsSearchOpen(false);
                }}
                className="text-slate-400 hover:text-slate-600 p-0.5"
              >
                <X className="w-3.5 h-3.5" />
              </button>
            ) : (
              <kbd className="hidden lg:inline-block px-1.5 py-0.5 text-[10px] font-bold text-slate-400 bg-white border border-slate-200 rounded-md">
                /
              </kbd>
            )}
          </form>

          {/* Search Dropdown Modal */}
          {isSearchOpen && (
            <>
              <div className="fixed inset-0 z-40" onClick={() => setIsSearchOpen(false)}></div>
              <div className="absolute right-0 top-12 w-80 sm:w-96 bg-white border border-slate-200 rounded-2xl shadow-xl z-50 overflow-hidden divide-y divide-slate-100 animate-in fade-in duration-150">
                <div className="p-3 bg-slate-50 flex items-center justify-between">
                  <span className="text-xs font-bold text-slate-600 uppercase tracking-wider">
                    {searchQuery.trim() ? `Search Results ("${searchQuery}")` : "Quick Navigation"}
                  </span>
                  <button onClick={() => setIsSearchOpen(false)} className="text-slate-400 hover:text-slate-600">
                    <X className="w-4 h-4" />
                  </button>
                </div>
                
                <div className="max-h-80 overflow-y-auto p-2 space-y-3">
                  {/* Pages Category */}
                  {filteredLinks.length > 0 && (
                    <div>
                      <p className="px-2 py-1 text-[10px] font-bold text-slate-400 uppercase">Portal Navigation</p>
                      {filteredLinks.map((link) => {
                        const Icon = link.icon;
                        return (
                          <button
                            key={link.route}
                            onClick={() => {
                              navigate(link.route);
                              setIsSearchOpen(false);
                              setSearchQuery("");
                            }}
                            className="w-full flex items-center gap-3 px-2.5 py-2 rounded-xl text-xs font-semibold text-slate-700 hover:bg-purple-50 hover:text-[#5e17eb] transition-colors text-left"
                          >
                            <Icon className="w-4 h-4 text-slate-400 shrink-0" />
                            <span>{link.label}</span>
                          </button>
                        );
                      })}
                    </div>
                  )}

                  {/* Candidates Category */}
                  {filteredCandidates.length > 0 && searchQuery.trim() !== "" && (
                    <div>
                      <p className="px-2 py-1 text-[10px] font-bold text-slate-400 uppercase">Shortlisted Candidates</p>
                      {filteredCandidates.slice(0, 4).map((c) => (
                        <button
                          key={c.id}
                          onClick={() => {
                            navigate("/recruiter/shortlisted-candidates");
                            setIsSearchOpen(false);
                            setSearchQuery("");
                          }}
                          className="w-full flex items-center justify-between px-2.5 py-2 rounded-xl text-xs font-semibold text-slate-800 hover:bg-purple-50 hover:text-[#5e17eb] transition-colors text-left"
                        >
                          <div>
                            <p className="font-bold text-slate-900">{c.name}</p>
                            <p className="text-[10px] text-slate-400 font-normal">{c.role} • {c.stage}</p>
                          </div>
                          <span className="text-[10px] font-bold text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded-md">
                            {c.score}% Match
                          </span>
                        </button>
                      ))}
                    </div>
                  )}

                  {/* Jobs Category */}
                  {filteredJobs.length > 0 && searchQuery.trim() !== "" && (
                    <div>
                      <p className="px-2 py-1 text-[10px] font-bold text-slate-400 uppercase">Job Vacancies</p>
                      {filteredJobs.slice(0, 4).map((job) => (
                        <button
                          key={job.id}
                          onClick={() => {
                            navigate("/recruiter/my-postings");
                            setIsSearchOpen(false);
                            setSearchQuery("");
                          }}
                          className="w-full flex items-center justify-between px-2.5 py-2 rounded-xl text-xs font-semibold text-slate-800 hover:bg-purple-50 hover:text-[#5e17eb] transition-colors text-left"
                        >
                          <div className="truncate">
                            <p className="truncate font-bold">{job.title}</p>
                            <p className="text-[10px] text-slate-400 font-normal">{job.location} • {job.status}</p>
                          </div>
                        </button>
                      ))}
                    </div>
                  )}

                  {filteredLinks.length === 0 && filteredJobs.length === 0 && filteredCandidates.length === 0 && (
                    <div className="p-4 text-center text-xs text-slate-400 font-medium">
                      No results matching "{searchQuery}"
                    </div>
                  )}
                </div>
              </div>
            </>
          )}
        </div>

        {/* Notification Bell Dropdown */}
        <div className="relative">
          <button 
            type="button" 
            onClick={() => {
              setShowNotifs(!showNotifs);
              setShowProfileMenu(false);
            }}
            className="grid w-10 h-10 place-items-center border rounded-xl bg-white text-slate-600 shadow-xs hover:bg-slate-50 hover:border-purple-300 transition-all relative"
            style={{ borderColor: "var(--c2c-border)" }}
            aria-label="Notifications"
          >
            <Bell className="h-4 w-4" />
            {unreadCount > 0 && (
              <span className="absolute -top-1 -right-1 flex h-4 w-4 items-center justify-center rounded-full bg-rose-500 text-[9px] font-black text-white ring-2 ring-white">
                {unreadCount}
              </span>
            )}
          </button>

          {showNotifs && (
            <>
              <div className="fixed inset-0 z-40" onClick={() => setShowNotifs(false)}></div>
              <div className="absolute right-0 top-12 w-80 sm:w-88 bg-white border border-slate-200 rounded-2xl shadow-xl z-50 overflow-hidden divide-y divide-slate-100 animate-in fade-in duration-150">
                <div className="p-3 bg-slate-50 flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <span className="text-xs font-bold text-slate-900">Notifications</span>
                    {unreadCount > 0 && (
                      <span className="px-1.5 py-0.5 bg-rose-100 text-rose-700 text-[10px] font-extrabold rounded-md">
                        {unreadCount} new
                      </span>
                    )}
                  </div>
                  <div className="flex items-center gap-2">
                    {unreadCount > 0 && (
                      <button 
                        onClick={handleMarkAllRead}
                        className="text-[11px] text-[#5e17eb] hover:underline font-semibold"
                      >
                        Mark all read
                      </button>
                    )}
                    {notifications.length > 0 && (
                      <button
                        onClick={handleClearAll}
                        className="text-[11px] text-slate-400 hover:text-rose-600 font-semibold"
                      >
                        Clear
                      </button>
                    )}
                  </div>
                </div>

                <div className="max-h-72 overflow-y-auto divide-y divide-slate-100">
                  {notifications.length > 0 ? (
                    notifications.map((n) => (
                      <div 
                        key={n.id} 
                        className={cn(
                          "p-3 text-xs flex items-start gap-3 transition-colors",
                          !n.read ? "bg-purple-50/50 hover:bg-purple-50" : "hover:bg-slate-50"
                        )}
                      >
                        <div className="p-2 rounded-xl bg-white border border-slate-200 shrink-0 text-slate-700 mt-0.5">
                          {n.type === "job" && <Briefcase className="w-4 h-4 text-[#5e17eb]" />}
                          {n.type === "candidate" && <Users className="w-4 h-4 text-blue-600" />}
                          {n.type === "message" && <MessageSquare className="w-4 h-4 text-emerald-600" />}
                          {n.type === "admin" && <SettingsIcon className="w-4 h-4 text-amber-600" />}
                        </div>
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center justify-between gap-1">
                            <p className="font-bold text-slate-900 truncate">{n.title}</p>
                            {!n.read && <span className="w-1.5 h-1.5 rounded-full bg-[#5e17eb] shrink-0"></span>}
                          </div>
                          <p className="text-slate-600 mt-0.5 leading-relaxed">{n.message}</p>
                          <span className="text-[10px] text-slate-400 mt-1 block">{n.time}</span>
                        </div>
                      </div>
                    ))
                  ) : (
                    <div className="p-6 text-center text-xs text-slate-400 font-medium">
                      No notifications yet
                    </div>
                  )}
                </div>
              </div>
            </>
          )}
        </div>

        {/* Settings Icon — Navigates to Settings */}
        <button 
          type="button" 
          onClick={() => navigate("/recruiter/settings")}
          className="grid w-10 h-10 place-items-center border rounded-xl bg-white text-slate-600 shadow-xs hover:bg-slate-50 hover:border-purple-300 transition-all"
          style={{ borderColor: "var(--c2c-border)" }}
          aria-label="Settings"
          title="Company & Account Settings"
        >
          <SettingsIcon className="h-4 w-4" />
        </button>

        {/* Profile Menu Dropdown */}
        <div className="relative">
          <button 
            type="button" 
            onClick={() => {
              setShowProfileMenu(!showProfileMenu);
              setShowNotifs(false);
            }}
            className="flex items-center gap-2 px-3 py-1.5 border rounded-xl bg-white hover:bg-slate-50 transition-all shadow-xs"
            style={{ borderColor: "var(--c2c-border)" }}
          >
            <div className="h-7 w-7 rounded-lg bg-[var(--c2c-primary)] text-white flex items-center justify-center text-xs font-bold shadow-xs">
              L
            </div>
            <span className="text-xs font-bold text-slate-800 hidden sm:inline-block">Company Profile</span>
            <ChevronDown className="h-3.5 w-3.5 text-slate-400" />
          </button>

          {showProfileMenu && (
            <>
              <div className="fixed inset-0 z-40" onClick={() => setShowProfileMenu(false)}></div>
              <div className="absolute right-0 top-12 w-56 bg-white border border-slate-200 rounded-2xl shadow-xl z-50 p-1.5 space-y-0.5">
                <div className="p-3 border-b border-slate-100">
                  <p className="text-xs font-bold text-slate-900">Lumina Nexus Tech</p>
                  <p className="text-[11px] text-slate-400">recruiter@luminanexus.com</p>
                </div>
                <button
                  onClick={() => {
                    navigate("/recruiter/settings?tab=company");
                    setShowProfileMenu(false);
                  }}
                  className="w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-semibold text-slate-700 hover:bg-purple-50 hover:text-[#5e17eb] transition-colors text-left"
                >
                  <User className="w-4 h-4 text-slate-400" />
                  Company Profile
                </button>
                <button
                  onClick={() => {
                    navigate("/recruiter/settings?tab=team");
                    setShowProfileMenu(false);
                  }}
                  className="w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-semibold text-slate-700 hover:bg-purple-50 hover:text-[#5e17eb] transition-colors text-left"
                >
                  <Users className="w-4 h-4 text-slate-400" />
                  Team Management
                </button>



                <div className="border-t border-slate-100 pt-1">
                  <button
                    onClick={() => {
                      setShowProfileMenu(false);
                      logout();
                    }}
                    className="w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-semibold text-rose-600 hover:bg-rose-50 transition-colors text-left"
                  >
                    <LogOut className="w-4 h-4 text-rose-500" />
                    Logout
                  </button>
                </div>
              </div>
            </>
          )}
        </div>
      </div>
    </nav>
  );
};

export default RecruiterNavbar;
