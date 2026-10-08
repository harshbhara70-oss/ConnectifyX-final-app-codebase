import React, { useState } from 'react';
import {
  Settings,
  Shield,
  Bell,
  Lock,
  Plug,
  AlertOctagon,
  Brain,
  Share2,
  Video,
  Code2,
  Power
} from 'lucide-react';

export const SettingsView: React.FC = () => {
  const [activeCategory, setActiveCategory] = useState<
    'general' | 'policies' | 'ai' | 'notifications' | 'security' | 'integrations' | 'maintenance'
  >('ai');

  // Sliders State for AI Readiness Weights
  const [academicWeight, setAcademicWeight] = useState(40);
  const [softSkillsWeight, setSoftSkillsWeight] = useState(30);
  const [techProjectsWeight, setTechProjectsWeight] = useState(20);
  const [extracurricularWeight, setExtracurricularWeight] = useState(10);

  // Maintenance Mode Toggle State
  const [maintenanceEnabled, setMaintenanceEnabled] = useState(false);

  const categories = [
    { id: 'general' as const, label: 'General Settings', icon: Settings },
    { id: 'policies' as const, label: 'User Policies', icon: Shield },
    { id: 'ai' as const, label: 'AI Configuration', icon: Brain },
    { id: 'notifications' as const, label: 'Email & Notifications', icon: Bell },
    { id: 'security' as const, label: 'Security', icon: Lock },
    { id: 'integrations' as const, label: 'Integrations', icon: Plug },
    { id: 'maintenance' as const, label: 'Maintenance', icon: AlertOctagon, alert: true },
  ];

  return (
    <div className="space-y-8 font-sans text-slate-800 pb-12">
      {/* Page Header */}
      <div>
        <h1 className="text-2xl font-black text-slate-900 tracking-tight">Platform Settings & Configuration</h1>
        <p className="text-xs font-semibold text-slate-500 mt-1">
          Manage global system parameters, integrations, and security protocols.
        </p>
      </div>

      {/* Split Settings Layout */}
      <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
        {/* Left Category Sub-Sidebar */}
        <div className="bg-white rounded-2xl border border-purple-100/70 shadow-xs p-3 space-y-1 self-start">
          {categories.map((cat) => {
            const IconComp = cat.icon;
            const isActive = activeCategory === cat.id;
            return (
              <button
                key={cat.id}
                onClick={() => setActiveCategory(cat.id)}
                className={`w-full flex items-center justify-between px-3.5 py-2.5 rounded-xl text-xs font-bold transition-all cursor-pointer ${
                  isActive
                    ? 'bg-[#6D28D9] text-white shadow-md shadow-purple-600/20'
                    : 'text-slate-600 hover:bg-purple-50 hover:text-purple-900'
                }`}
              >
                <div className="flex items-center gap-2.5">
                  <IconComp className={`w-4 h-4 ${isActive ? 'text-white' : 'text-purple-700/70'}`} />
                  <span>{cat.label}</span>
                </div>
                {cat.alert && (
                  <span className={`w-2 h-2 rounded-full ${isActive ? 'bg-red-300' : 'bg-red-500'}`}></span>
                )}
              </button>
            );
          })}
        </div>

        {/* Right Detail Settings Panels */}
        <div className="lg:col-span-3 space-y-6">
          {/* AI Configuration: Readiness Score Weights */}
          <div className="bg-white rounded-2xl border border-purple-100/70 shadow-xs p-6 space-y-6">
            <div className="flex items-center justify-between border-b border-slate-100 pb-4">
              <div className="flex items-center gap-2.5">
                <Brain className="w-5 h-5 text-purple-700" />
                <h3 className="text-base font-bold text-slate-900">AI Configuration: Readiness Score Weights</h3>
              </div>
            </div>

            <div className="space-y-5 text-xs font-bold text-slate-700">
              {/* Slider 1 */}
              <div className="space-y-2">
                <div className="flex justify-between items-center">
                  <span>Academic Performance</span>
                  <span className="font-mono text-purple-700 font-extrabold">{academicWeight}%</span>
                </div>
                <input
                  type="range"
                  min="0"
                  max="100"
                  value={academicWeight}
                  onChange={(e) => setAcademicWeight(Number(e.target.value))}
                  className="w-full accent-[#6D28D9] cursor-pointer"
                />
              </div>

              {/* Slider 2 */}
              <div className="space-y-2">
                <div className="flex justify-between items-center">
                  <span>Soft Skills Assessment</span>
                  <span className="font-mono text-purple-700 font-extrabold">{softSkillsWeight}%</span>
                </div>
                <input
                  type="range"
                  min="0"
                  max="100"
                  value={softSkillsWeight}
                  onChange={(e) => setSoftSkillsWeight(Number(e.target.value))}
                  className="w-full accent-[#6D28D9] cursor-pointer"
                />
              </div>

              {/* Slider 3 */}
              <div className="space-y-2">
                <div className="flex justify-between items-center">
                  <span>Technical Project Portfolio</span>
                  <span className="font-mono text-purple-700 font-extrabold">{techProjectsWeight}%</span>
                </div>
                <input
                  type="range"
                  min="0"
                  max="100"
                  value={techProjectsWeight}
                  onChange={(e) => setTechProjectsWeight(Number(e.target.value))}
                  className="w-full accent-[#6D28D9] cursor-pointer"
                />
              </div>

              {/* Slider 4 */}
              <div className="space-y-2">
                <div className="flex justify-between items-center">
                  <span>Extracurricular Leadership</span>
                  <span className="font-mono text-purple-700 font-extrabold">{extracurricularWeight}%</span>
                </div>
                <input
                  type="range"
                  min="0"
                  max="100"
                  value={extracurricularWeight}
                  onChange={(e) => setExtracurricularWeight(Number(e.target.value))}
                  className="w-full accent-[#6D28D9] cursor-pointer"
                />
              </div>
            </div>
          </div>

          {/* API Integrations Status Grid */}
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            {/* LinkedIn Card */}
            <div className="bg-white rounded-2xl p-5 border border-purple-100/70 shadow-xs flex flex-col justify-between space-y-3 text-center">
              <div className="flex justify-center">
                <div className="w-10 h-10 rounded-xl bg-purple-50 flex items-center justify-center text-purple-700">
                  <Share2 className="w-5 h-5" />
                </div>
              </div>
              <div>
                <p className="text-xs font-bold text-slate-900">LinkedIn API</p>
                <p className="text-[10px] text-slate-400 font-medium">Profile Sync Active</p>
              </div>
              <span className="py-1 px-3 bg-purple-50 text-purple-700 rounded-xl text-[10px] font-bold block">
                Connected
              </span>
            </div>

            {/* YouTube Data Card */}
            <div className="bg-white rounded-2xl p-5 border border-purple-100/70 shadow-xs flex flex-col justify-between space-y-3 text-center">
              <div className="flex justify-center">
                <div className="w-10 h-10 rounded-xl bg-purple-50 flex items-center justify-center text-purple-700">
                  <Video className="w-5 h-5" />
                </div>
              </div>
              <div>
                <p className="text-xs font-bold text-slate-900">YouTube Data</p>
                <p className="text-[10px] text-slate-400 font-medium">Learning content sync</p>
              </div>
              <span className="py-1 px-3 bg-purple-50 text-purple-700 rounded-xl text-[10px] font-bold block">
                Connected
              </span>
            </div>

            {/* LeetCode Stats Card */}
            <div className="bg-white rounded-2xl p-5 border border-purple-100/70 shadow-xs flex flex-col justify-between space-y-3 text-center">
              <div className="flex justify-center">
                <div className="w-10 h-10 rounded-xl bg-slate-50 flex items-center justify-center text-slate-600">
                  <Code2 className="w-5 h-5" />
                </div>
              </div>
              <div>
                <p className="text-xs font-bold text-slate-900">LeetCode Stats</p>
                <p className="text-[10px] text-slate-400 font-medium">Coding skill verifier</p>
              </div>
              <button className="py-1 px-3 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-[10px] font-bold block cursor-pointer transition-colors">
                Configure
              </button>
            </div>
          </div>

          {/* Security Audit Log */}
          <div className="bg-white rounded-2xl border border-purple-100/70 shadow-xs p-6 space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <h3 className="text-base font-bold text-slate-900 flex items-center gap-2">
                <Shield className="w-4 h-4 text-purple-700" />
                <span>Security Audit Log</span>
              </h3>
              <button className="text-xs font-bold text-purple-700 hover:underline cursor-pointer">View All</button>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs font-semibold text-slate-700">
                <thead className="bg-slate-50 text-[10px] uppercase tracking-wider font-extrabold text-slate-400 border-y border-slate-100">
                  <tr>
                    <th className="py-3 px-4">Timestamp</th>
                    <th className="py-3 px-4">Event</th>
                    <th className="py-3 px-4">User</th>
                    <th className="py-3 px-4 font-mono">IP Address</th>
                    <th className="py-3 px-4 text-right">Status</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100 font-mono text-[11px]">
                  {[
                    { time: '2025-10-15 14:32:01', event: 'API Key Rotated', user: 'sysadmin_core', ip: '192.168.1.104', status: 'Success', color: 'bg-purple-50 text-purple-700 border-purple-200' },
                    { time: '2025-10-15 09:15:22', event: 'Failed Login Attempt', user: 'unknown', ip: '45.22.11.9', status: 'Blocked', color: 'bg-red-50 text-red-600 border-red-200' },
                    { time: '2025-10-14 18:45:10', event: 'Policy Updated: Data Ret.', user: 'j.smith (Admin)', ip: '10.0.0.52', status: 'Success', color: 'bg-purple-50 text-purple-700 border-purple-200' },
                  ].map((row, idx) => (
                    <tr key={idx} className="hover:bg-purple-50/30 transition-colors">
                      <td className="py-3 px-4 text-slate-500">{row.time}</td>
                      <td className="py-3 px-4 font-sans font-bold text-slate-900">{row.event}</td>
                      <td className="py-3 px-4 text-slate-600 font-sans">{row.user}</td>
                      <td className="py-3 px-4 text-slate-500">{row.ip}</td>
                      <td className="py-3 px-4 text-right">
                        <span className={`px-2 py-0.5 border rounded text-[10px] font-bold ${row.color}`}>
                          {row.status}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>

          {/* Maintenance Mode Toggle Panel */}
          <div className="bg-white rounded-2xl border-l-4 border-l-red-500 border border-purple-100/70 shadow-xs p-6 space-y-4">
            <div>
              <h3 className="text-base font-bold text-slate-900">Maintenance Mode</h3>
              <p className="text-xs text-slate-500 font-medium mt-1">
                Activating maintenance mode will immediately terminate all active student and corporate recruiter sessions. Only Super Admins will retain access.
              </p>
            </div>

            <div className="bg-slate-50/70 border border-slate-200 rounded-xl p-4 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
              <div>
                <p className="text-xs font-bold text-slate-900">System Status</p>
                <p className="text-xs text-slate-500 font-medium">
                  {maintenanceEnabled ? 'Maintenance mode is currently ACTIVE.' : 'Currently operating normally.'}
                </p>
              </div>

              <button
                onClick={() => setMaintenanceEnabled(!maintenanceEnabled)}
                className={`px-5 py-2.5 rounded-xl font-bold text-xs flex items-center gap-2 transition-all cursor-pointer ${
                  maintenanceEnabled
                    ? 'bg-red-600 hover:bg-red-700 text-white shadow-md'
                    : 'bg-white border border-slate-200 hover:bg-slate-100 text-slate-800 shadow-2xs'
                }`}
              >
                <Power className="w-4 h-4" />
                <span>{maintenanceEnabled ? 'Disable Maintenance' : '⚡ Enable Maintenance'}</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default SettingsView;
