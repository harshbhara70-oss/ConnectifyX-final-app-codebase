import React from 'react';
import { Search, Bell, Settings, Command, Activity, ShieldAlert, Wifi, LogOut } from 'lucide-react';

interface AdminHeaderProps {
  onOpenCommandCenter?: () => void;
  activeTabTitle?: string;
  onLogout?: () => void;
}

export const AdminHeader: React.FC<AdminHeaderProps> = ({
  onOpenCommandCenter,
  activeTabTitle = 'Dashboard',
  onLogout
}) => {
  return (
    <header className="bg-white border-b border-purple-100/70 h-16 px-6 flex items-center justify-between sticky top-0 z-20 shadow-xs font-sans">
      {/* Left side: Brand Title / Breadcrumb & Search */}
      <div className="flex items-center gap-6">
        <div className="hidden sm:block">
          <span className="text-[11px] font-bold uppercase tracking-wider text-purple-600">Campus2Corporate</span>
          <span className="text-xs text-slate-300 mx-2">/</span>
          <span className="text-xs font-black text-slate-800">{activeTabTitle}</span>
        </div>

        {/* Search trigger */}
        <div 
          onClick={onOpenCommandCenter}
          className="relative w-64 md:w-80 cursor-pointer group"
        >
          <div className="flex items-center gap-2 bg-slate-50 border border-slate-200/80 group-hover:border-purple-300 rounded-xl px-3.5 py-2 text-xs text-slate-400 font-medium transition-colors shadow-2xs">
            <Search className="w-3.5 h-3.5 text-slate-400 group-hover:text-purple-600" />
            <span className="truncate">Search students, records, or drives...</span>
            <div className="ml-auto flex items-center gap-0.5 bg-white border border-slate-200 px-1.5 py-0.5 rounded text-[10px] font-mono text-slate-400 font-bold">
              <Command className="w-2.5 h-2.5" />
              <span>K</span>
            </div>
          </div>
        </div>
      </div>

      {/* Right side: System Status + Notifications + Profile + Logout */}
      <div className="flex items-center gap-4 text-xs font-bold text-slate-600">
        {/* System Health Indicators */}
        <div className="hidden lg:flex items-center gap-4 border-r border-slate-100 pr-5 text-[11px]">
          <div className="flex items-center gap-1.5">
            <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
            <span className="text-purple-700 font-extrabold underline underline-offset-4 decoration-purple-300">Health</span>
          </div>
          <div className="flex items-center gap-1.5 text-slate-500">
            <Activity className="w-3 h-3 text-slate-400" />
            <span>System</span>
          </div>
          <div className="flex items-center gap-1.5 text-slate-500">
            <Wifi className="w-3 h-3 text-slate-400" />
            <span>Network</span>
          </div>
        </div>

        {/* Icon Action Buttons */}
        <div className="flex items-center gap-2">
          <button 
            onClick={onOpenCommandCenter}
            className="p-2 rounded-xl text-slate-400 hover:text-purple-700 hover:bg-purple-50 transition-colors relative cursor-pointer"
            title="Notifications"
          >
            <Bell className="w-4.5 h-4.5" />
            <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-purple-600 rounded-full ring-2 ring-white"></span>
          </button>
          <button 
            className="p-2 rounded-xl text-slate-400 hover:text-purple-700 hover:bg-purple-50 transition-colors cursor-pointer"
            title="Security Audit"
          >
            <ShieldAlert className="w-4.5 h-4.5" />
          </button>
          <button 
            className="p-2 rounded-xl text-slate-400 hover:text-purple-700 hover:bg-purple-50 transition-colors cursor-pointer"
            title="Settings"
          >
            <Settings className="w-4.5 h-4.5" />
          </button>
        </div>

        {/* Profile Avatar & Logout */}
        <div className="flex items-center gap-3 border-l border-slate-100 pl-4">
          <div className="text-right hidden md:block">
            <p className="text-xs font-black text-slate-900 leading-tight">Admin Profile</p>
            <p className="text-[9px] font-extrabold text-purple-700 uppercase tracking-wider mt-0.5">ROLE: SUPER ADMIN</p>
          </div>
          <div className="w-9 h-9 rounded-xl bg-purple-100 border border-purple-200 flex items-center justify-center overflow-hidden shadow-xs cursor-pointer">
            <img 
              src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop&q=80" 
              alt="Super Admin Avatar" 
              className="w-full h-full object-cover"
            />
          </div>

          {onLogout && (
            <button
              onClick={onLogout}
              className="p-2 rounded-xl text-slate-400 hover:text-red-600 hover:bg-red-50 transition-colors cursor-pointer ml-1"
              title="Log Out Admin"
            >
              <LogOut className="w-4.5 h-4.5" />
            </button>
          )}
        </div>
      </div>
    </header>
  );
};

export default AdminHeader;
