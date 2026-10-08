import React, { useState } from 'react';
import {
  TrendingUp,
  Download,
  Users,
  Clock,
  Activity,
  CheckCircle2,
  ArrowUpRight
} from 'lucide-react';

export const AnalyticsView: React.FC = () => {
  const [dateRange, setDateRange] = useState('30_days');

  return (
    <div className="space-y-8 font-sans text-slate-800 pb-12">
      {/* Top Banner */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-black text-slate-900 tracking-tight">Platform Analytics</h1>
          <p className="text-xs font-semibold text-slate-500 mt-1">
            Real-time enterprise metrics and performance insights.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <select
            value={dateRange}
            onChange={(e) => setDateRange(e.target.value)}
            className="bg-white border border-slate-200 px-3.5 py-2 rounded-xl text-xs font-bold text-slate-700 focus:outline-none cursor-pointer shadow-2xs"
          >
            <option value="30_days">Last 30 Days: Oct 1 - Oct 31</option>
            <option value="7_days">Last 7 Days</option>
            <option value="90_days">Last Quarter</option>
          </select>

          <button className="bg-[#6D28D9] hover:bg-[#5B21B6] text-white font-bold px-4 py-2 rounded-xl text-xs flex items-center gap-2 shadow-md shadow-purple-500/20 transition-all cursor-pointer">
            <Download className="w-3.5 h-3.5" />
            <span>Export Report</span>
          </button>
        </div>
      </div>

      {/* Analytics KPI Tiles */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white rounded-2xl p-6 border border-purple-100/70 shadow-xs flex justify-between items-start">
          <div className="space-y-2">
            <p className="text-[10px] font-extrabold uppercase tracking-wider text-slate-400">Total Active Users</p>
            <h2 className="text-3xl font-black text-slate-900 tracking-tight">124,592</h2>
            <div className="flex items-center gap-1 text-xs font-bold text-purple-700">
              <TrendingUp className="w-3.5 h-3.5" />
              <span>+14.2% from last month</span>
            </div>
          </div>
          <div className="w-10 h-10 rounded-xl bg-purple-50 border border-purple-100 flex items-center justify-center text-purple-600">
            <Users className="w-5 h-5" />
          </div>
        </div>

        <div className="bg-white rounded-2xl p-6 border border-purple-100/70 shadow-xs flex justify-between items-start">
          <div className="space-y-2">
            <p className="text-[10px] font-extrabold uppercase tracking-wider text-slate-400">Avg Session Duration</p>
            <h2 className="text-3xl font-black text-slate-900 tracking-tight">18m 42s</h2>
            <div className="flex items-center gap-1 text-xs font-bold text-purple-700">
              <TrendingUp className="w-3.5 h-3.5" />
              <span>+2.1% from last month</span>
            </div>
          </div>
          <div className="w-10 h-10 rounded-xl bg-purple-50 border border-purple-100 flex items-center justify-center text-purple-600">
            <Clock className="w-5 h-5" />
          </div>
        </div>

        <div className="bg-white rounded-2xl p-6 border border-purple-100/70 shadow-xs flex justify-between items-start">
          <div className="space-y-2">
            <p className="text-[10px] font-extrabold uppercase tracking-wider text-slate-400">System Health</p>
            <h2 className="text-3xl font-black text-slate-900 tracking-tight">99.98%</h2>
            <div className="flex items-center gap-1 text-xs font-bold text-emerald-600">
              <CheckCircle2 className="w-3.5 h-3.5" />
              <span>All services operational</span>
            </div>
          </div>
          <div className="w-10 h-10 rounded-xl bg-emerald-50 border border-emerald-100 flex items-center justify-center text-emerald-600">
            <Activity className="w-5 h-5" />
          </div>
        </div>
      </div>

      {/* User Growth Trajectory & Engagement Donut */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 bg-white rounded-2xl p-6 border border-purple-100/70 shadow-xs space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-base font-bold text-slate-900">User Growth Trajectory</h3>
              <p className="text-xs text-slate-400 font-medium">Weekly registration trend analysis</p>
            </div>
            <ArrowUpRight className="w-4 h-4 text-slate-400" />
          </div>

          <div className="w-full h-56 pt-4">
            <svg className="w-full h-full overflow-visible" viewBox="0 0 500 150">
              <defs>
                <linearGradient id="purpleGradientAnalytics" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="#7C3AED" stopOpacity="0.3" />
                  <stop offset="100%" stopColor="#7C3AED" stopOpacity="0.0" />
                </linearGradient>
              </defs>
              <line x1="0" y1="30" x2="500" y2="30" stroke="#f1f5f9" strokeWidth="1" strokeDasharray="4 4" />
              <line x1="0" y1="75" x2="500" y2="75" stroke="#f1f5f9" strokeWidth="1" strokeDasharray="4 4" />
              <line x1="0" y1="120" x2="500" y2="120" stroke="#f1f5f9" strokeWidth="1" strokeDasharray="4 4" />
              <path
                d="M 10,120 C 100,100 150,70 240,60 C 330,50 380,30 490,20 L 490,140 L 10,140 Z"
                fill="url(#purpleGradientAnalytics)"
              />
              <path
                d="M 10,120 C 100,100 150,70 240,60 C 330,50 380,30 490,20"
                fill="none"
                stroke="#7C3AED"
                strokeWidth="3.5"
                strokeLinecap="round"
              />
            </svg>
            <div className="flex justify-between text-[11px] font-bold text-slate-400 mt-2 px-2">
              <span>Week 1</span>
              <span>Week 2</span>
              <span>Week 3</span>
              <span>Week 4</span>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-2xl p-6 border border-purple-100/70 shadow-xs flex flex-col justify-between text-center">
          <div>
            <h3 className="text-base font-bold text-slate-900 text-left">Engagement (DAU/MAU)</h3>
            <p className="text-xs text-slate-400 font-medium text-left">Daily vs Monthly Active Users</p>
          </div>

          <div className="my-6 relative flex justify-center items-center">
            <svg className="w-44 h-44 transform -rotate-90">
              <circle cx="88" cy="88" r="68" stroke="#F1F5F9" strokeWidth="16" fill="transparent" />
              <circle
                cx="88"
                cy="88"
                r="68"
                stroke="#6D28D9"
                strokeWidth="16"
                fill="transparent"
                strokeDasharray="427"
                strokeDashoffset="247"
                strokeLinecap="round"
              />
            </svg>
            <div className="absolute inset-0 flex flex-col items-center justify-center">
              <span className="text-3xl font-black text-slate-900">42%</span>
              <span className="text-[10px] font-extrabold uppercase tracking-widest text-slate-400">Ratio</span>
            </div>
          </div>

          <p className="text-xs text-slate-500 font-medium leading-relaxed">
            {"High daily retention indicative of core platform utility."}
          </p>
        </div>
      </div>

      {/* Placement Funnel & Top Content Roadmaps */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-2xl p-6 border border-purple-100/70 shadow-xs space-y-4">
          <div>
            <h3 className="text-base font-bold text-slate-900">Placement Funnel</h3>
            <p className="text-xs text-slate-400 font-medium">Conversion progression across active batches</p>
          </div>

          <div className="space-y-3.5 pt-2">
            {[
              { stage: 'Profile Created', percent: 100, count: '45,210', color: 'bg-[#6D28D9]' },
              { stage: 'Assessment', percent: 78, count: '35,263', color: 'bg-purple-300' },
              { stage: 'Interview', percent: 45, count: '20,344', color: 'bg-purple-200' },
              { stage: 'Placed', percent: 22, count: '9,946', color: 'bg-slate-200' },
            ].map((f, idx) => (
              <div key={idx} className="space-y-1.5">
                <div className="flex justify-between text-xs font-bold text-slate-700">
                  <span className="w-32">{f.stage}</span>
                  <div className="flex items-center gap-3">
                    <span className="text-purple-700">{f.percent}%</span>
                    <span className="text-slate-400 font-mono w-16 text-right">{f.count}</span>
                  </div>
                </div>
                <div className="w-full h-3.5 bg-slate-100 rounded-full overflow-hidden flex">
                  <div className={`h-full ${f.color} rounded-full`} style={{ width: `${f.percent}%` }}></div>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="bg-white rounded-2xl p-6 border border-purple-100/70 shadow-xs space-y-4">
          <div>
            <h3 className="text-base font-bold text-slate-900">Top Content Roadmaps</h3>
            <p className="text-xs text-slate-400 font-medium">Most enrolled career development tracks</p>
          </div>

          <div className="h-52 pt-4 flex items-end justify-between gap-4 px-4">
            {[
              { label: 'Tech Found.', height: '40%', value: '12.4k' },
              { label: 'Software Eng.', height: '85%', value: '28.1k', active: true },
              { label: 'Data Analytics', height: '60%', value: '18.6k' },
              { label: 'Prod Mgmt', height: '35%', value: '9.2k' },
              { label: 'UX Design', height: '50%', value: '14.8k' },
            ].map((bar, i) => (
              <div key={i} className="flex-1 flex flex-col items-center gap-2 h-full justify-end group">
                <span className="text-[10px] font-bold text-slate-400">{bar.value}</span>
                <div className="w-full bg-slate-100 rounded-t-xl overflow-hidden flex items-end h-full">
                  <div
                    className={`w-full rounded-t-xl ${bar.active ? 'bg-[#6D28D9]' : 'bg-purple-200'}`}
                    style={{ height: bar.height }}
                  ></div>
                </div>
                <span className="text-[10px] font-bold text-slate-600 truncate w-full text-center">{bar.label}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

export default AnalyticsView;
