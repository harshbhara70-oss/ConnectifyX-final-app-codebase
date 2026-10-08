import React from 'react';
import {
  LayoutDashboard,
  Users,
  BookOpen,
  Briefcase,
  CheckCircle2,
  Megaphone,
  BarChart3,
  HelpCircle,
  Settings,
  ShieldCheck,
  Info,
  Zap,
  Building2,
  LogOut
} from 'lucide-react';

export type AdminTabType =
  | 'overview'
  | 'users'
  | 'content'
  | 'placement'
  | 'verification'
  | 'broadcast'
  | 'analytics'
  | 'support'
  | 'settings';

interface AdminSidebarProps {
  activeTab: AdminTabType;
  setActiveTab: (tab: AdminTabType) => void;
  onOpenCommandCenter?: () => void;
  onLogout?: () => void;
}

export const AdminSidebar: React.FC<AdminSidebarProps> = ({
  activeTab,
  setActiveTab,
  onOpenCommandCenter,
  onLogout
}) => {
  const navItems = [
    { id: 'overview' as const, label: 'Dashboard', icon: LayoutDashboard },
    { id: 'users' as const, label: 'User Management', icon: Users },
    { id: 'content' as const, label: 'Content Hub', icon: BookOpen },
    { id: 'placement' as const, label: 'Placement Oversight', icon: Briefcase },
    { id: 'verification' as const, label: 'Verification Queue', icon: CheckCircle2 },
    { id: 'broadcast' as const, label: 'Broadcast Control', icon: Megaphone },
    { id: 'analytics' as const, label: 'Analytics', icon: BarChart3 },
    { id: 'support' as const, label: 'Support', icon: HelpCircle },
    { id: 'settings' as const, label: 'Settings', icon: Settings }
  ];

  return (
    <aside className="w-64 bg-[#EFEBF9] border-r border-purple-100/70 flex flex-col justify-between h-screen sticky top-0 z-30 select-none font-sans text-slate-700">
      {/* Top Section */}
      <div className="p-5 space-y-6">
        {/* Brand Mark */}
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-2xl bg-gradient-to-br from-[#7C3AED] to-[#6D28D9] flex items-center justify-center text-white shadow-md shadow-purple-500/20">
            <Building2 className="w-5 h-5" />
          </div>
          <div>
            <h1 className="text-base font-black text-slate-900 tracking-tight leading-none">
              C2C Admin
            </h1>
            <p className="text-[10px] font-bold text-purple-700 uppercase tracking-widest mt-1">
              Enterprise Portal
            </p>
          </div>
        </div>

        {/* Command Center Action Button */}
        <button
          onClick={onOpenCommandCenter}
          className="w-full py-2.5 px-4 bg-gradient-to-r from-[#7C3AED] to-[#6D28D9] hover:from-[#6D28D9] hover:to-[#5B21B6] text-white font-bold rounded-xl text-xs shadow-md shadow-purple-500/20 transition-all duration-200 cursor-pointer flex items-center justify-center gap-2 group"
        >
          <Zap className="w-4 h-4 fill-white text-white group-hover:scale-110 transition-transform" />
          <span>Command Center</span>
        </button>

        {/* Navigation Items */}
        <nav className="space-y-1 pt-2">
          {navItems.map((item) => {
            const IconComponent = item.icon;
            const isActive = activeTab === item.id;
            return (
              <button
                key={item.id}
                onClick={() => setActiveTab(item.id)}
                className={`w-full flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-xs font-bold transition-all duration-200 cursor-pointer ${
                  isActive
                    ? 'bg-[#6D28D9] text-white shadow-md shadow-purple-600/20 translate-x-0.5'
                    : 'text-slate-600 hover:bg-white/60 hover:text-purple-900'
                }`}
              >
                <IconComponent className={`w-4 h-4 ${isActive ? 'text-white' : 'text-purple-700/70'}`} />
                <span>{item.label}</span>
              </button>
            );
          })}
        </nav>
      </div>

      {/* Footer Section & Logout */}
      <div className="p-4 border-t border-purple-100/60 bg-purple-50/40 space-y-3">
        {onLogout && (
          <button
            onClick={onLogout}
            className="w-full py-2 px-3 bg-red-50 hover:bg-red-100 text-red-600 border border-red-200/80 font-bold rounded-xl text-xs flex items-center justify-center gap-2 transition-colors cursor-pointer"
          >
            <LogOut className="w-3.5 h-3.5" />
            <span>Log Out Admin</span>
          </button>
        )}

        <div className="flex items-center justify-between text-[11px] font-bold text-slate-500 pt-1">
          <div className="flex items-center gap-1.5 text-slate-600">
            <ShieldCheck className="w-4 h-4 text-emerald-600" />
            <span>Security</span>
          </div>
          <div className="flex items-center gap-1 bg-white/80 px-2 py-0.5 rounded-md border border-purple-100 text-[10px] text-purple-700 font-mono">
            <Info className="w-3 h-3 text-purple-600" />
            <span>V3.2</span>
          </div>
        </div>
      </div>
    </aside>
  );
};

export default AdminSidebar;
