import React from "react";
import { Search, Bell, HelpCircle, Menu } from "lucide-react";

interface CollegeHeaderProps {
  searchQuery: string;
  onSearchChange: (query: string) => void;
  onQuickActionClick?: () => void;
  onOpenMobileSidebar?: () => void;
  userName?: string;
  userRole?: string;
}

export const CollegeHeader: React.FC<CollegeHeaderProps> = ({
  searchQuery,
  onSearchChange,
  onOpenMobileSidebar,
  userName = "Dr. Sarah Jenkins",
  userRole = "COLLEGE ADMINISTRATOR",
}) => {
  return (
    <header className="sticky top-0 z-30 bg-white/95 backdrop-blur-md border-b border-slate-100 px-4 md:px-6 py-3 flex items-center justify-between gap-4">
      {/* Left section: Mobile menu toggle */}
      <div className="flex items-center gap-3">
        <button
          onClick={onOpenMobileSidebar}
          className="lg:hidden p-2 rounded-xl text-slate-600 hover:bg-slate-100 transition-colors"
          aria-label="Open Navigation Menu"
        >
          <Menu className="w-5 h-5" />
        </button>
      </div>

      {/* Center: Global Search Input Pill */}
      <div className="flex-1 max-w-xl">
        <div className="relative">
          <Search className="w-4 h-4 absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => onSearchChange(e.target.value)}
            placeholder="Search students, records, or drives..."
            className="w-full bg-slate-50 hover:bg-slate-100/80 focus:bg-white text-slate-800 text-xs md:text-sm pl-11 pr-4 py-2.5 rounded-full border border-slate-200/80 focus:outline-none focus:ring-2 focus:ring-[#7C3AED]/30 focus:border-[#7C3AED] transition-all placeholder:text-slate-400 font-medium"
          />
        </div>
      </div>

      {/* Right controls: Bell (🔔), Help (❓), Profile Badge */}
      <div className="flex items-center gap-2 md:gap-3">
        {/* Notifications Bell Icon */}
        <button
          title="Notifications"
          className="w-9 h-9 rounded-full bg-slate-50 hover:bg-purple-50 text-slate-600 hover:text-[#7C3AED] border border-slate-200/80 flex items-center justify-center transition-all cursor-pointer relative"
        >
          <Bell className="w-4 h-4" />
          <span className="absolute top-1.5 right-1.5 w-2 h-2 rounded-full bg-[#7C3AED]"></span>
        </button>

        {/* Help Button */}
        <button
          title="Help & Support"
          className="w-9 h-9 rounded-full bg-slate-50 hover:bg-purple-50 text-slate-600 hover:text-[#7C3AED] border border-slate-200/80 flex items-center justify-center transition-all cursor-pointer"
        >
          <HelpCircle className="w-4 h-4" />
        </button>

        {/* College Administrator Profile Badge */}
        <div className="flex items-center gap-2.5 pl-2 border-l border-slate-200">
          <div className="relative cursor-pointer">
            <div className="w-9 h-9 rounded-full bg-[#7C3AED] text-white font-extrabold text-xs flex items-center justify-center shadow-xs ring-2 ring-purple-100">
              SJ
            </div>
            <span className="absolute bottom-0 right-0 w-2.5 h-2.5 rounded-full bg-emerald-500 border-2 border-white"></span>
          </div>

          <div className="hidden md:block text-left">
            <div className="text-xs font-extrabold text-slate-900 leading-tight">
              {userName}
            </div>
            <div className="text-[9px] font-extrabold text-[#7C3AED] tracking-wider uppercase">
              {userRole}
            </div>
          </div>
        </div>
      </div>
    </header>
  );
};

