import React, { useState } from 'react';
import {
  Megaphone,
  Send,
  Save,
  Building2,
  CheckCircle2
} from 'lucide-react';

export const BroadcastControl: React.FC = () => {
  const [targetAudience, setTargetAudience] = useState('all_students');
  const [priorityLevel, setPriorityLevel] = useState('standard');
  const [broadcastTitle, setBroadcastTitle] = useState('');
  const [messageContent, setMessageContent] = useState('');
  const [sentSuccess, setSentSuccess] = useState(false);

  const handleBroadcast = (e: React.FormEvent) => {
    e.preventDefault();
    if (!broadcastTitle || !messageContent) return;
    setSentSuccess(true);
    setTimeout(() => {
      setSentSuccess(false);
      setBroadcastTitle('');
      setMessageContent('');
    }, 2000);
  };

  return (
    <div className="space-y-8 font-sans text-slate-800 pb-12">
      {/* Page Title */}
      <div>
        <h1 className="text-2xl font-black text-slate-900 tracking-tight">Refined Communication Center</h1>
        <p className="text-xs font-semibold text-slate-500 mt-1">
          Issue platform-wide announcements and monitor institutional broadcast logs.
        </p>
      </div>

      {/* Main Grid: Left Composer & Right College Oversight */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left Column: Composer Form */}
        <div className="lg:col-span-2 bg-white rounded-2xl p-6 border border-purple-100/70 shadow-xs space-y-6">
          <div className="flex items-center gap-2 text-purple-700 font-extrabold text-sm border-b border-purple-50 pb-3">
            <Send className="w-4 h-4" />
            <h2>Send Platform-Wide Broadcast</h2>
          </div>

          {sentSuccess && (
            <div className="bg-emerald-50 border border-emerald-200 text-emerald-700 rounded-xl p-3.5 text-xs font-bold flex items-center gap-2 animate-in fade-in">
              <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />
              <span>Broadcast dispatched successfully to target audience!</span>
            </div>
          )}

          <form onSubmit={handleBroadcast} className="space-y-4 text-xs font-bold text-slate-700">
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div className="space-y-1">
                <label className="block text-[10px] uppercase tracking-wider font-extrabold text-slate-500">
                  Target Audience
                </label>
                <select
                  value={targetAudience}
                  onChange={(e) => setTargetAudience(e.target.value)}
                  className="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-[#6D28D9]/30"
                >
                  <option value="all_students">All Registered Students (Global)</option>
                  <option value="all_colleges">All Partner Institutions</option>
                  <option value="all_recruiters">All Corporate Recruiters</option>
                  <option value="mentors">Mentors & Advisors</option>
                </select>
              </div>

              <div className="space-y-1">
                <label className="block text-[10px] uppercase tracking-wider font-extrabold text-slate-500">
                  Priority Level
                </label>
                <select
                  value={priorityLevel}
                  onChange={(e) => setPriorityLevel(e.target.value)}
                  className="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-[#6D28D9]/30"
                >
                  <option value="standard">Standard Notification</option>
                  <option value="high">High Priority Banner</option>
                  <option value="urgent">Urgent System Alert</option>
                </select>
              </div>
            </div>

            <div className="space-y-1">
              <label className="block text-[10px] uppercase tracking-wider font-extrabold text-slate-500">
                Broadcast Title
              </label>
              <input
                type="text"
                placeholder="Enter broadcast title..."
                value={broadcastTitle}
                onChange={(e) => setBroadcastTitle(e.target.value)}
                className="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-[#6D28D9]/30"
                required
              />
            </div>

            <div className="space-y-1">
              <label className="block text-[10px] uppercase tracking-wider font-extrabold text-slate-500">
                Message Content
              </label>
              <textarea
                rows={5}
                placeholder="Compose message here..."
                value={messageContent}
                onChange={(e) => setMessageContent(e.target.value)}
                className="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-[#6D28D9]/30 resize-none"
                required
              ></textarea>
            </div>

            <div className="flex items-center justify-end gap-3 pt-2">
              <button
                type="button"
                className="px-4 py-2.5 bg-white hover:bg-slate-50 text-slate-700 font-bold border border-slate-200 rounded-xl text-xs flex items-center gap-1.5 transition-colors cursor-pointer"
              >
                <Save className="w-3.5 h-3.5" />
                <span>Save Draft</span>
              </button>
              <button
                type="submit"
                className="px-5 py-2.5 bg-[#6D28D9] hover:bg-[#5B21B6] text-white font-bold rounded-xl text-xs flex items-center gap-2 shadow-md shadow-purple-500/20 transition-all cursor-pointer"
              >
                <Megaphone className="w-4 h-4 fill-white" />
                <span>Broadcast Now</span>
              </button>
            </div>
          </form>
        </div>

        {/* Right Column: College Oversight Widget */}
        <div className="bg-white rounded-2xl p-6 border border-purple-100/70 shadow-xs flex flex-col justify-between space-y-4">
          <div>
            <div className="flex items-center gap-2 text-slate-900 font-bold text-sm">
              <Building2 className="w-4 h-4 text-purple-700" />
              <h3>College Oversight</h3>
            </div>
            <p className="text-xs text-slate-400 font-medium mt-1">
              Monitor recent broadcasts initiated by institutional administrators.
            </p>

            <div className="space-y-3 pt-4">
              {[
                { college: 'Tech University', title: 'Spring Internship Fair Registration', target: 'Target: Seniors', vol: '4.2k' },
                { college: 'State Business School', title: 'Resume Review Workshop Series', target: 'Target: All Majors', vol: '1.8k' },
                { college: 'Global Engineering Inst.', title: 'Urgent: Career Portal Maintenance', target: 'Target: Global', vol: '12.5k' },
              ].map((b, idx) => (
                <div key={idx} className="p-3 bg-slate-50/70 border border-slate-100 rounded-xl space-y-1">
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-bold text-slate-900">{b.college}</span>
                    <span className="text-[10px] font-mono text-purple-700 font-bold">Vol: {b.vol}</span>
                  </div>
                  <p className="text-[11px] text-slate-600 font-medium">{b.title}</p>
                  <p className="text-[9px] font-bold text-slate-400 uppercase tracking-wider">{b.target}</p>
                </div>
              ))}
            </div>
          </div>

          <button className="w-full py-2.5 bg-slate-50 hover:bg-slate-100 text-slate-700 font-bold border border-slate-200 rounded-xl text-xs transition-colors cursor-pointer">
            View Institutional Logs
          </button>
        </div>
      </div>

      {/* Broadcast History Table */}
      <div className="bg-white rounded-2xl border border-purple-100/70 shadow-xs overflow-hidden space-y-4 p-6">
        <div className="flex items-center justify-between border-b border-slate-100 pb-4">
          <h3 className="text-base font-bold text-slate-900">Broadcast History</h3>
          <button className="text-xs font-bold text-[#6D28D9] hover:underline cursor-pointer">View All</button>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs font-semibold text-slate-700">
            <thead className="bg-slate-50 text-[10px] uppercase tracking-wider font-extrabold text-slate-400 border-y border-slate-100">
              <tr>
                <th className="py-3.5 px-4">Title</th>
                <th className="py-3.5 px-4">Target</th>
                <th className="py-3.5 px-4">Sent Date</th>
                <th className="py-3.5 px-4">Metrics</th>
                <th className="py-3.5 px-4 text-right">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {[
                { title: 'Q3 Platform Updates & New Features', target: 'All Users', date: 'Oct 24, 09:00', open: '68%', click: '12%', status: 'Delivered' },
                { title: 'Scheduled Maintenance Window', target: 'Institutions', date: 'Oct 20, 22:00', open: '84%', click: '--', status: 'Delivered' },
                { title: 'Welcome to the Fall Career Fair Series', target: 'Students', date: 'Oct 15, 10:20', open: '42%', click: '18%', status: 'Delivered' },
              ].map((row, idx) => (
                <tr key={idx} className="hover:bg-purple-50/30 transition-colors">
                  <td className="py-3.5 px-4 font-bold text-slate-900">{row.title}</td>
                  <td className="py-3.5 px-4 font-bold text-slate-600">{row.target}</td>
                  <td className="py-3.5 px-4 text-slate-500 font-mono text-[11px]">{row.date}</td>
                  <td className="py-3.5 px-4 font-mono text-[11px]">
                    <span className="text-purple-700 font-bold">{row.open} Open</span>
                    {row.click !== '--' && <span className="text-slate-400 ml-2">{row.click} Click</span>}
                  </td>
                  <td className="py-3.5 px-4 text-right">
                    <span className="px-2.5 py-1 bg-emerald-50 text-emerald-700 border border-emerald-200 rounded-full text-[10px] font-bold">
                      {row.status}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default BroadcastControl;
