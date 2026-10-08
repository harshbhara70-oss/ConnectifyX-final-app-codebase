import React, { useState, useEffect } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { AdminSidebar } from '../components/dashboard/admin/AdminSidebar';
import type { AdminTabType } from '../components/dashboard/admin/AdminSidebar';
import { AdminHeader } from '../components/dashboard/admin/AdminHeader';

// 9 Modular Sub-Views
import { AdminOverview } from '../components/dashboard/admin/views/AdminOverview';
import { UserManagement } from '../components/dashboard/admin/views/UserManagement';
import { ContentHub } from '../components/dashboard/admin/views/ContentHub';
import { PlacementOversight } from '../components/dashboard/admin/views/PlacementOversight';
import { VerificationQueue } from '../components/dashboard/admin/views/VerificationQueue';
import { BroadcastControl } from '../components/dashboard/admin/views/BroadcastControl';
import { AnalyticsView } from '../components/dashboard/admin/views/AnalyticsView';
import { SupportCenter } from '../components/dashboard/admin/views/SupportCenter';
import { SettingsView } from '../components/dashboard/admin/views/SettingsView';

import {
  Search,
  X,
  LayoutDashboard,
  Users,
  BookOpen,
  Briefcase,
  CheckCircle2,
  Megaphone,
  BarChart3,
  HelpCircle,
  Settings
} from 'lucide-react';

import { useAuth } from '../context/AuthContext';

export const AdminDashboard: React.FC = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const { logout } = useAuth();
  const [activeAdminTab, setActiveAdminTab] = useState<AdminTabType>('overview');
  const [showCommandCenter, setShowCommandCenter] = useState(false);
  const [commandSearch, setCommandSearch] = useState('');

  const handleLogout = () => {
    localStorage.removeItem('c2c_admin_token');
    localStorage.removeItem('c2c_admin_session');
    localStorage.removeItem('c2c_local_session');
    logout();
    navigate('/admin/login', { replace: true });
  };

  // Sync active tab with URL path
  useEffect(() => {
    const path = location.pathname.toLowerCase();
    if (path.includes('/user-management') || path.includes('/users')) setActiveAdminTab('users');
    else if (path.includes('/content-hub') || path.includes('/content')) setActiveAdminTab('content');
    else if (path.includes('/placement-oversight') || path.includes('/placement')) setActiveAdminTab('placement');
    else if (path.includes('/verification-queue') || path.includes('/verification')) setActiveAdminTab('verification');
    else if (path.includes('/broadcast-control') || path.includes('/broadcast')) setActiveAdminTab('broadcast');
    else if (path.includes('/analytics')) setActiveAdminTab('analytics');
    else if (path.includes('/support')) setActiveAdminTab('support');
    else if (path.includes('/settings')) setActiveAdminTab('settings');
    else setActiveAdminTab('overview');
  }, [location.pathname]);

  const handleTabChange = (tab: AdminTabType) => {
    setActiveAdminTab(tab);
    const isUnderAdminPrefix = location.pathname.toLowerCase().startsWith('/admin/');
    const prefix = isUnderAdminPrefix ? '/admin' : '/admin-dashboard';

    const tabRouteMap: Record<AdminTabType, string> = {
      overview: isUnderAdminPrefix ? '/admin/dashboard' : '/admin-dashboard',
      users: isUnderAdminPrefix ? '/admin/user-management' : '/admin-dashboard/users',
      content: isUnderAdminPrefix ? '/admin/content-hub' : '/admin-dashboard/content',
      placement: isUnderAdminPrefix ? '/admin/placement-oversight' : '/admin-dashboard/placement',
      verification: isUnderAdminPrefix ? '/admin/verification-queue' : '/admin-dashboard/verification',
      broadcast: isUnderAdminPrefix ? '/admin/broadcast-control' : '/admin-dashboard/broadcast',
      analytics: isUnderAdminPrefix ? '/admin/analytics' : '/admin-dashboard/analytics',
      support: isUnderAdminPrefix ? '/admin/support' : '/admin-dashboard/support',
      settings: isUnderAdminPrefix ? '/admin/settings' : '/admin-dashboard/settings',
    };

    navigate(tabRouteMap[tab] || prefix);
  };

  // Keyboard shortcut listener (Cmd+K / Ctrl+K) for Command Center
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
        e.preventDefault();
        setShowCommandCenter((prev) => !prev);
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, []);

  // Title dictionary for Header breadcrumb
  const tabTitles: Record<AdminTabType, string> = {
    overview: 'Overview & Analytics',
    users: 'User Management',
    content: 'Content Hub',
    placement: 'Placement Oversight',
    verification: 'Verification Queue',
    broadcast: 'Broadcast Control',
    analytics: 'Platform Analytics',
    support: 'Support Center',
    settings: 'Global Settings'
  };

  const commandItems = [
    { tab: 'overview' as const, label: 'Go to Overview Dashboard', icon: LayoutDashboard },
    { tab: 'users' as const, label: 'Manage Users & Directory', icon: Users },
    { tab: 'content' as const, label: 'Open Content Hub & Roadmaps', icon: BookOpen },
    { tab: 'placement' as const, label: 'Placement Pipeline & Drives', icon: Briefcase },
    { tab: 'verification' as const, label: 'Review Verification Approvals', icon: CheckCircle2 },
    { tab: 'broadcast' as const, label: 'Compose Platform Broadcast', icon: Megaphone },
    { tab: 'analytics' as const, label: 'View Deep Platform Analytics', icon: BarChart3 },
    { tab: 'support' as const, label: 'Open Support & Dispute Desk', icon: HelpCircle },
    { tab: 'settings' as const, label: 'Adjust System Settings & AI Weights', icon: Settings },
  ];

  const filteredCommands = commandItems.filter(item =>
    item.label.toLowerCase().includes(commandSearch.toLowerCase())
  );

  return (
    <div className="min-h-screen bg-[#F8FAFC] flex font-sans text-slate-800 selection:bg-purple-100 selection:text-purple-900">
      {/* Standardized Left Navigation Sidebar (Mandatory Across All 9 Views) */}
      <AdminSidebar
        activeTab={activeAdminTab}
        setActiveTab={handleTabChange}
        onOpenCommandCenter={() => setShowCommandCenter(true)}
        onLogout={handleLogout}
      />

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col min-w-0">
        {/* Top Header Bar */}
        <AdminHeader
          activeTabTitle={tabTitles[activeAdminTab]}
          onOpenCommandCenter={() => setShowCommandCenter(true)}
          onLogout={handleLogout}
        />

        {/* Dynamic Sub-Portal Route Container */}
        <main className="flex-1 p-6 md:p-8 overflow-y-auto max-w-7xl w-full mx-auto">
          {activeAdminTab === 'overview' && <AdminOverview />}
          {activeAdminTab === 'users' && <UserManagement />}
          {activeAdminTab === 'content' && <ContentHub />}
          {activeAdminTab === 'placement' && <PlacementOversight />}
          {activeAdminTab === 'verification' && <VerificationQueue />}
          {activeAdminTab === 'broadcast' && <BroadcastControl />}
          {activeAdminTab === 'analytics' && <AnalyticsView />}
          {activeAdminTab === 'support' && <SupportCenter />}
          {activeAdminTab === 'settings' && <SettingsView />}
        </main>
      </div>

      {/* Command Center Modal (Cmd+K) */}
      {showCommandCenter && (
        <div className="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-xs flex items-start justify-center pt-20 p-4 transition-all duration-200">
          <div className="bg-white rounded-3xl shadow-2xl border border-purple-100 w-full max-w-lg overflow-hidden animate-in fade-in zoom-in-95">
            {/* Search Input Bar */}
            <div className="p-4 border-b border-slate-100 flex items-center gap-3 bg-slate-50/50">
              <Search className="w-4 h-4 text-purple-700" />
              <input
                type="text"
                placeholder="Type a command or search portal..."
                value={commandSearch}
                onChange={(e) => setCommandSearch(e.target.value)}
                autoFocus
                className="w-full bg-transparent border-none text-xs font-semibold text-slate-800 focus:outline-none"
              />
              <button
                onClick={() => setShowCommandCenter(false)}
                className="p-1 rounded-full text-slate-400 hover:text-slate-600 hover:bg-slate-200/60"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            {/* Command Results List */}
            <div className="p-3 max-h-80 overflow-y-auto space-y-1">
              <p className="text-[10px] font-extrabold uppercase tracking-widest text-slate-400 px-3 py-1.5">
                Quick Navigation
              </p>

              {filteredCommands.map((item) => {
                const IconC = item.icon;
                return (
                  <button
                    key={item.tab}
                    onClick={() => {
                      handleTabChange(item.tab);
                      setShowCommandCenter(false);
                      setCommandSearch('');
                    }}
                    className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-bold text-slate-700 hover:bg-purple-50 hover:text-purple-900 transition-colors cursor-pointer text-left"
                  >
                    <div className="w-7 h-7 rounded-lg bg-purple-100/60 flex items-center justify-center text-purple-700">
                      <IconC className="w-3.5 h-3.5" />
                    </div>
                    <span>{item.label}</span>
                  </button>
                );
              })}

              {filteredCommands.length === 0 && (
                <div className="p-6 text-center text-xs text-slate-400 font-bold">
                  No matching commands found.
                </div>
              )}
            </div>

            {/* Modal Footer */}
            <div className="p-3 bg-slate-50 border-t border-slate-100 flex items-center justify-between text-[10px] text-slate-400 font-medium">
              <span>Use ↑↓ to navigate, Enter to select</span>
              <span className="font-mono">ESC to close</span>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default AdminDashboard;
