import React, { useState } from 'react';
import {
  GraduationCap,
  Landmark,
  Briefcase,
  ClipboardList,
  BookOpen,
  DollarSign,
  TrendingUp,
  CheckCircle2,
  AlertTriangle,
  UserPlus,
  Download,
  Play,
  Check,
  ChevronDown,
  X,
  Server,
  Activity,
  Wifi,
  ShieldCheck,
  Building2,
  FileCheck,
  Megaphone,
  Sparkles
} from 'lucide-react';

export const AdminOverview: React.FC = () => {
  // Interactive State Management
  const [selectedPlatform, setSelectedPlatform] = useState<'All Platforms' | 'Web' | 'Mobile'>('All Platforms');
  const [hoveredPointIndex, setHoveredPointIndex] = useState<number | null>(null);

  // Approval counts state
  const [collegePending, setCollegePending] = useState(12);
  const [recruiterUrgent, setRecruiterUrgent] = useState(5);
  const [broadcastDrafts, setBroadcastDrafts] = useState(2);
  const [isApprovedAll, setIsApprovedAll] = useState(false);

  // Modal and Toast States
  const [showDiagnosticsModal, setShowDiagnosticsModal] = useState(false);
  const [showBroadcastModal, setShowBroadcastModal] = useState(false);
  const [broadcastMessage, setBroadcastMessage] = useState('');
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  // Function to show toast notification
  const triggerToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => {
      setToastMessage(null);
    }, 4000);
  };

  // Handler for Approve All action
  const handleApproveAll = () => {
    setCollegePending(0);
    setRecruiterUrgent(0);
    setBroadcastDrafts(0);
    setIsApprovedAll(true);
    triggerToast('✅ All pending onboarding requests, recruiter verifications & broadcasts approved successfully!');
  };

  // Handler for Exporting Weekly Report
  const handleExportReport = () => {
    const csvContent =
      'data:text/csv;charset=utf-8,' +
      'Metric,Value,Status,Period\n' +
      'Total Students,142500,+12%,This Month\n' +
      'Colleges,342,Active Partnerships,Current\n' +
      'Recruiters,1284,+5%,This Week\n' +
      'Active Jobs,8492,45 Sectors,Current\n' +
      'Roadmaps Done,45200,High Completion Rate,Current\n' +
      'MRR Revenue,$2.4M,Target Exceeded,Current\n';

    const encodedUri = encodeURI(csvContent);
    const link = document.createElement('a');
    link.setAttribute('href', encodedUri);
    link.setAttribute('download', 'C2C_Executive_Admin_Report_2026.csv');
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

    triggerToast('📥 Executive Weekly Report CSV generated and downloaded.');
  };

  // Handler for Submitting Broadcast
  const handleSendBroadcast = (e: React.FormEvent) => {
    e.preventDefault();
    if (!broadcastMessage.trim()) return;
    setShowBroadcastModal(false);
    triggerToast(`📢 Platform Broadcast dispatched: "${broadcastMessage.trim().substring(0, 40)}..."`);
    setBroadcastMessage('');
  };

  // Traffic Chart Data Sets mapped by Platform Selection
  const chartDatasets: Record<'All Platforms' | 'Web' | 'Mobile', { label: string; value: number; pointStr: string; displayVal: string }[]> = {
    'All Platforms': [
      { label: 'May 01', value: 1.0, pointStr: '1.0k', displayVal: '1,000 visits' },
      { label: 'May 08', value: 5.5, pointStr: '5.5k', displayVal: '5,500 visits' },
      { label: 'May 15', value: 7.2, pointStr: '7.2k', displayVal: '7,200 visits' },
      { label: 'May 22', value: 4.0, pointStr: '4.0k', displayVal: '4,000 visits' },
      { label: 'May 30', value: 9.2, pointStr: '9.2k', displayVal: '9,200 visits' },
    ],
    'Web': [
      { label: 'May 01', value: 0.7, pointStr: '700', displayVal: '700 visits' },
      { label: 'May 08', value: 4.0, pointStr: '4.0k', displayVal: '4,000 visits' },
      { label: 'May 15', value: 5.5, pointStr: '5.5k', displayVal: '5,500 visits' },
      { label: 'May 22', value: 3.0, pointStr: '3.0k', displayVal: '3,000 visits' },
      { label: 'May 30', value: 6.8, pointStr: '6.8k', displayVal: '6,800 visits' },
    ],
    'Mobile': [
      { label: 'May 01', value: 0.3, pointStr: '300', displayVal: '300 visits' },
      { label: 'May 08', value: 1.5, pointStr: '1.5k', displayVal: '1,500 visits' },
      { label: 'May 15', value: 1.7, pointStr: '1.7k', displayVal: '1,700 visits' },
      { label: 'May 22', value: 1.0, pointStr: '1.0k', displayVal: '1,000 visits' },
      { label: 'May 30', value: 2.4, pointStr: '2.4k', displayVal: '2,400 visits' },
    ],
  };

  const currentPoints = chartDatasets[selectedPlatform];

  // SVG Coordinates calculation (viewBox 0 0 600 200)
  // X values for 5 points: 30, 165, 300, 435, 570
  // Y values mapped from 0k-10k scale (Y=170 is 0k, Y=20 is 10k => height 150px)
  const getSvgCoordinates = (data: typeof currentPoints) => {
    const xCoords = [30, 165, 300, 435, 570];
    return data.map((d, idx) => {
      const y = 170 - (d.value / 10.0) * 150;
      return { x: xCoords[idx], y, label: d.label, displayVal: d.displayVal };
    });
  };

  const coords = getSvgCoordinates(currentPoints);

  // Generate smooth cubic bezier path string for SVG
  const pathD = `M ${coords[0].x},${coords[0].y} ` +
    `C ${coords[0].x + 60},${coords[0].y} ${coords[1].x - 60},${coords[1].y} ${coords[1].x},${coords[1].y} ` +
    `C ${coords[1].x + 60},${coords[1].y} ${coords[2].x - 60},${coords[2].y} ${coords[2].x},${coords[2].y} ` +
    `C ${coords[2].x + 60},${coords[2].y} ${coords[3].x - 60},${coords[3].y} ${coords[3].x},${coords[3].y} ` +
    `C ${coords[3].x + 60},${coords[3].y} ${coords[4].x - 60},${coords[4].y} ${coords[4].x},${coords[4].y}`;

  const areaD = `${pathD} L ${coords[4].x},175 L ${coords[0].x},175 Z`;

  return (
    <div className="space-y-6 font-sans text-slate-800 selection:bg-purple-100 selection:text-purple-900 pb-12">
      {/* Toast Notification Banner */}
      {toastMessage && (
        <div className="fixed top-20 right-6 z-50 bg-slate-900 text-white px-4 py-3 rounded-2xl shadow-2xl border border-slate-700 flex items-center gap-3 text-xs font-bold animate-in fade-in slide-in-from-top duration-300">
          <Sparkles className="w-4 h-4 text-purple-400 shrink-0" />
          <span>{toastMessage}</span>
          <button
            onClick={() => setToastMessage(null)}
            className="ml-2 p-1 text-slate-400 hover:text-white rounded-lg cursor-pointer"
          >
            <X className="w-3.5 h-3.5" />
          </button>
        </div>
      )}

      {/* 1. System Health Banner (Top Bar) */}
      <div className="bg-[#ECFDF5]/80 border border-emerald-200/90 rounded-2xl p-4 sm:p-5 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 shadow-2xs transition-all">
        <div className="flex items-center gap-3.5">
          <div className="w-9 h-9 rounded-full bg-emerald-100 flex items-center justify-center text-emerald-600 shrink-0 shadow-2xs">
            <CheckCircle2 className="w-5 h-5" />
          </div>
          <div>
            <h2 className="text-base font-black text-slate-900 tracking-tight flex items-center gap-2">
              <span>System Status: Healthy</span>
            </h2>
            <p className="text-xs font-medium text-slate-600 mt-0.5">
              {"All core services are operational. Latency is within normal parameters."}
            </p>
          </div>
        </div>
        <button
          onClick={() => setShowDiagnosticsModal(true)}
          className="text-xs font-extrabold text-[#7C3AED] hover:text-[#6D28D9] bg-white hover:bg-purple-50/60 px-3.5 py-2 rounded-xl border border-emerald-200/80 shadow-2xs transition-all cursor-pointer whitespace-nowrap self-end sm:self-center"
        >
          View Detailed Status
        </button>
      </div>

      {/* 2. KPI Metrics Grid & Pending Approvals (Row 1) */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-5">
        {/* Stat Card 1: Total Students */}
        <div className="bg-white rounded-2xl p-5 border border-purple-100/70 shadow-xs flex flex-col justify-between hover:border-purple-200 transition-all">
          <div className="flex items-center justify-between">
            <span className="text-[10px] font-extrabold uppercase tracking-wider text-slate-400">
              TOTAL STUDENTS
            </span>
            <div className="w-8 h-8 rounded-xl bg-purple-50 flex items-center justify-center text-purple-700">
              <GraduationCap className="w-4 h-4" />
            </div>
          </div>
          <div className="mt-4 space-y-1">
            <div className="text-3xl font-black text-slate-900 tracking-tight">142.5k</div>
            <div className="flex items-center gap-1 text-xs font-bold text-emerald-600">
              <TrendingUp className="w-3.5 h-3.5 text-emerald-600" />
              <span>+12% this month</span>
            </div>
          </div>
        </div>

        {/* Stat Card 2: Colleges */}
        <div className="bg-white rounded-2xl p-5 border border-purple-100/70 shadow-xs flex flex-col justify-between hover:border-purple-200 transition-all">
          <div className="flex items-center justify-between">
            <span className="text-[10px] font-extrabold uppercase tracking-wider text-slate-400">
              COLLEGES
            </span>
            <div className="w-8 h-8 rounded-xl bg-purple-50 flex items-center justify-center text-purple-700">
              <Landmark className="w-4 h-4" />
            </div>
          </div>
          <div className="mt-4 space-y-1">
            <div className="text-3xl font-black text-slate-900 tracking-tight">342</div>
            <div className="text-xs font-semibold text-slate-500">
              Active partnerships
            </div>
          </div>
        </div>

        {/* Stat Card 3: Recruiters */}
        <div className="bg-white rounded-2xl p-5 border border-purple-100/70 shadow-xs flex flex-col justify-between hover:border-purple-200 transition-all">
          <div className="flex items-center justify-between">
            <span className="text-[10px] font-extrabold uppercase tracking-wider text-slate-400">
              RECRUITERS
            </span>
            <div className="w-8 h-8 rounded-xl bg-purple-50 flex items-center justify-center text-purple-700">
              <Briefcase className="w-4 h-4" />
            </div>
          </div>
          <div className="mt-4 space-y-1">
            <div className="text-3xl font-black text-slate-900 tracking-tight">1,284</div>
            <div className="flex items-center gap-1 text-xs font-bold text-emerald-600">
              <TrendingUp className="w-3.5 h-3.5 text-emerald-600" />
              <span>+5% this week</span>
            </div>
          </div>
        </div>

        {/* Pending Approvals Card (Right Box) */}
        <div className="bg-white rounded-2xl p-5 border border-purple-100/70 shadow-xs flex flex-col justify-between">
          <h3 className="text-[11px] font-black uppercase tracking-wider text-slate-700 border-b border-slate-100 pb-2.5">
            PENDING APPROVALS
          </h3>

          <div className="space-y-2.5 py-1">
            {/* Row 1: College Onboarding */}
            <div className="flex items-center justify-between text-xs">
              <div className="flex items-center gap-2 font-bold text-slate-700">
                <Building2 className="w-3.5 h-3.5 text-slate-400 shrink-0" />
                <span className="truncate">New College Onboarding</span>
              </div>
              <span className="bg-amber-100/90 text-amber-900 border border-amber-200/80 font-bold px-2.5 py-0.5 rounded-md text-[11px] font-mono shrink-0">
                {collegePending} pending
              </span>
            </div>

            {/* Row 2: Recruiter Verification */}
            <div className="flex items-center justify-between text-xs">
              <div className="flex items-center gap-2 font-bold text-slate-700">
                <FileCheck className="w-3.5 h-3.5 text-slate-400 shrink-0" />
                <span className="truncate">Recruiter Verification</span>
              </div>
              <span className="bg-rose-100/90 text-rose-800 border border-rose-200/80 font-bold px-2.5 py-0.5 rounded-md text-[11px] font-mono shrink-0">
                {recruiterUrgent} urgent
              </span>
            </div>

            {/* Row 3: Broadcast Approval */}
            <div className="flex items-center justify-between text-xs">
              <div className="flex items-center gap-2 font-bold text-slate-700">
                <Megaphone className="w-3.5 h-3.5 text-slate-400 shrink-0" />
                <span className="truncate">Broadcast Approval</span>
              </div>
              <span className="bg-slate-100 text-slate-700 border border-slate-200/80 font-bold px-2.5 py-0.5 rounded-md text-[11px] font-mono shrink-0">
                {broadcastDrafts} drafts
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* 3. Secondary Metrics Grid & Quick Actions (Row 2) */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-5">
        {/* Stat Card 4: Active Jobs */}
        <div className="bg-white rounded-2xl p-5 border border-purple-100/70 shadow-xs flex flex-col justify-between hover:border-purple-200 transition-all">
          <div className="flex items-center justify-between">
            <span className="text-[10px] font-extrabold uppercase tracking-wider text-slate-400">
              ACTIVE JOBS
            </span>
            <div className="w-8 h-8 rounded-xl bg-purple-50 flex items-center justify-center text-purple-700">
              <ClipboardList className="w-4 h-4" />
            </div>
          </div>
          <div className="mt-4 space-y-1">
            <div className="text-3xl font-black text-slate-900 tracking-tight">8,492</div>
            <div className="text-xs font-semibold text-slate-500">
              Across 45 sectors
            </div>
          </div>
        </div>

        {/* Stat Card 5: Roadmaps Done */}
        <div className="bg-white rounded-2xl p-5 border border-purple-100/70 shadow-xs flex flex-col justify-between hover:border-purple-200 transition-all">
          <div className="flex items-center justify-between">
            <span className="text-[10px] font-extrabold uppercase tracking-wider text-slate-400">
              ROADMAPS DONE
            </span>
            <div className="w-8 h-8 rounded-xl bg-purple-50 flex items-center justify-center text-purple-700">
              <BookOpen className="w-4 h-4" />
            </div>
          </div>
          <div className="mt-4 space-y-1">
            <div className="text-3xl font-black text-slate-900 tracking-tight">45.2k</div>
            <div className="text-xs font-bold text-emerald-600">
              High completion rate
            </div>
          </div>
        </div>

        {/* Stat Card 6: MRR Revenue */}
        <div className="bg-white rounded-2xl p-5 border border-purple-100/70 shadow-xs flex flex-col justify-between hover:border-purple-200 transition-all">
          <div className="flex items-center justify-between">
            <span className="text-[10px] font-extrabold uppercase tracking-wider text-slate-400">
              MRR REVENUE
            </span>
            <div className="w-8 h-8 rounded-xl bg-purple-50 flex items-center justify-center text-purple-700">
              <DollarSign className="w-4 h-4" />
            </div>
          </div>
          <div className="mt-4 space-y-1">
            <div className="text-3xl font-black text-slate-900 tracking-tight">$2.4M</div>
            <div className="flex items-center gap-1 text-xs font-bold text-emerald-600">
              <TrendingUp className="w-3.5 h-3.5 text-emerald-600" />
              <span>Target exceeded</span>
            </div>
          </div>
        </div>

        {/* Quick Actions Card (Right Box) */}
        <div className="bg-white rounded-2xl p-5 border border-purple-100/70 shadow-xs flex flex-col justify-between space-y-3">
          <h3 className="text-[11px] font-black uppercase tracking-wider text-slate-700 border-b border-slate-100 pb-2">
            QUICK ACTIONS
          </h3>

          <div className="space-y-2.5">
            {/* Button Row 1 */}
            <div className="grid grid-cols-2 gap-2">
              <button
                onClick={handleApproveAll}
                disabled={isApprovedAll}
                className="py-2.5 px-3 bg-[#7C3AED] hover:bg-[#6D28D9] disabled:bg-purple-300 text-white font-extrabold rounded-xl text-xs flex items-center justify-center gap-1.5 shadow-sm shadow-purple-600/20 transition-all cursor-pointer disabled:cursor-not-allowed"
              >
                <Check className="w-3.5 h-3.5" />
                <span>{isApprovedAll ? 'Approved' : 'Approve All'}</span>
              </button>

              <button
                onClick={() => setShowBroadcastModal(true)}
                className="py-2.5 px-3 border border-slate-200 hover:border-purple-200 bg-white hover:bg-purple-50/50 text-slate-800 font-extrabold rounded-xl text-xs flex items-center justify-center gap-1.5 transition-all cursor-pointer"
              >
                <Play className="w-3 h-3 text-slate-700 fill-slate-700" />
                <span>Broadcast</span>
              </button>
            </div>

            {/* Button Row 2 */}
            <button
              onClick={handleExportReport}
              className="w-full py-2.5 px-3 border border-slate-200 hover:border-purple-200 bg-white hover:bg-purple-50/50 text-slate-800 font-extrabold rounded-xl text-xs flex items-center justify-center gap-2 transition-all cursor-pointer"
            >
              <Download className="w-3.5 h-3.5 text-slate-600" />
              <span>Export Weekly Report</span>
            </button>
          </div>
        </div>
      </div>

      {/* 4. Live Activity Stream & Traffic Overview (Row 3) */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-5">
        {/* Left Container — Live Activity Stream (4 Cols) */}
        <div className="lg:col-span-4 bg-white rounded-2xl p-5 border border-purple-100/70 shadow-xs flex flex-col justify-between space-y-4">
          <div className="flex items-center justify-between border-b border-slate-100 pb-3">
            <h3 className="text-[11px] font-black uppercase tracking-wider text-slate-700 flex items-center gap-2">
              <span>LIVE ACTIVITY STREAM</span>
              <span className="relative flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                <span className="relative inline-flex rounded-full h-2 w-2 bg-emerald-500"></span>
              </span>
            </h3>
          </div>

          <div className="space-y-4 pt-1 flex-1">
            {/* Log 1 */}
            <div className="flex items-start gap-3 text-xs font-semibold text-slate-800">
              <div className="w-7 h-7 rounded-lg bg-purple-50 border border-purple-100 flex items-center justify-center text-purple-700 shrink-0 mt-0.5">
                <UserPlus className="w-3.5 h-3.5" />
              </div>
              <div className="space-y-0.5">
                <p className="leading-snug">
                  {"50 new students registered from Tech University."}
                </p>
                <span className="text-[11px] font-medium text-slate-400">Just now</span>
              </div>
            </div>

            {/* Log 2 */}
            <div className="flex items-start gap-3 text-xs font-semibold text-slate-800">
              <div className="w-7 h-7 rounded-lg bg-purple-50 border border-purple-100 flex items-center justify-center text-purple-700 shrink-0 mt-0.5">
                <Briefcase className="w-3.5 h-3.5" />
              </div>
              <div className="space-y-0.5">
                <p className="leading-snug">
                  {"GlobalCorp posted 15 new engineering roles."}
                </p>
                <span className="text-[11px] font-medium text-slate-400">2 mins ago</span>
              </div>
            </div>

            {/* Log 3 */}
            <div className="flex items-start gap-3 text-xs font-semibold text-slate-800">
              <div className="w-7 h-7 rounded-lg bg-amber-50 border border-amber-200/80 flex items-center justify-center text-amber-600 shrink-0 mt-0.5">
                <AlertTriangle className="w-3.5 h-3.5" />
              </div>
              <div className="space-y-0.5">
                <p className="leading-snug">
                  {"API rate limit warning on "}
                  <code className="bg-slate-100 text-slate-700 px-1 py-0.5 rounded font-mono text-[11px]">
                    /v1/placements
                  </code>
                  {"."}
                </p>
                <span className="text-[11px] font-medium text-slate-400">15 mins ago</span>
              </div>
            </div>

            {/* Log 4 */}
            <div className="flex items-start gap-3 text-xs font-semibold text-slate-800">
              <div className="w-7 h-7 rounded-lg bg-emerald-50 border border-emerald-200/80 flex items-center justify-center text-emerald-600 shrink-0 mt-0.5">
                <CheckCircle2 className="w-3.5 h-3.5" />
              </div>
              <div className="space-y-0.5">
                <p className="leading-snug">
                  {"Batch roadmap generation completed for 500 users."}
                </p>
                <span className="text-[11px] font-medium text-slate-400">1 hour ago</span>
              </div>
            </div>
          </div>
        </div>

        {/* Right Container — Traffic Overview (30 Days) (8 Cols) */}
        <div className="lg:col-span-8 bg-white rounded-2xl p-5 border border-purple-100/70 shadow-xs flex flex-col justify-between space-y-4">
          {/* Header & Dropdown */}
          <div className="flex items-center justify-between border-b border-slate-100 pb-3">
            <h3 className="text-[11px] font-black uppercase tracking-wider text-slate-700">
              TRAFFIC OVERVIEW (30 DAYS)
            </h3>

            {/* Custom Dropdown Selector */}
            <div className="relative">
              <select
                value={selectedPlatform}
                onChange={(e) => setSelectedPlatform(e.target.value as 'All Platforms' | 'Web' | 'Mobile')}
                className="appearance-none bg-slate-50 hover:bg-slate-100 border border-slate-200 text-slate-800 text-xs font-bold py-1.5 pl-3 pr-8 rounded-xl focus:outline-none focus:ring-2 focus:ring-purple-600/30 transition-colors cursor-pointer"
              >
                <option value="All Platforms">All Platforms</option>
                <option value="Web">Web</option>
                <option value="Mobile">Mobile</option>
              </select>
              <ChevronDown className="w-3.5 h-3.5 text-slate-400 absolute right-2.5 top-2.5 pointer-events-none" />
            </div>
          </div>

          {/* Interactive SVG Area Chart */}
          <div className="relative w-full pt-2">
            {/* Hover Tooltip Overlay */}
            {hoveredPointIndex !== null && (
              <div
                className="absolute z-20 bg-slate-900 text-white text-[10px] font-bold px-2.5 py-1 rounded-lg shadow-lg pointer-events-none transform -translate-x-1/2 -translate-y-full transition-all duration-150"
                style={{
                  left: `${(coords[hoveredPointIndex].x / 600) * 100}%`,
                  top: `${(coords[hoveredPointIndex].y / 200) * 100 - 4}%`,
                }}
              >
                {`${coords[hoveredPointIndex].label}: ${coords[hoveredPointIndex].displayVal}`}
              </div>
            )}

            <div className="w-full h-56 relative">
              <svg className="w-full h-full overflow-visible" viewBox="0 0 600 200" preserveAspectRatio="none">
                <defs>
                  <linearGradient id="purpleAreaGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="#7C3AED" stopOpacity="0.35" />
                    <stop offset="100%" stopColor="#7C3AED" stopOpacity="0.02" />
                  </linearGradient>
                </defs>

                {/* Y-Axis Horizontal Grid Lines */}
                <line x1="20" y1="20" x2="580" y2="20" stroke="#f1f5f9" strokeWidth="1" strokeDasharray="3 3" />
                <line x1="20" y1="57.5" x2="580" y2="57.5" stroke="#f1f5f9" strokeWidth="1" strokeDasharray="3 3" />
                <line x1="20" y1="95" x2="580" y2="95" stroke="#f1f5f9" strokeWidth="1" strokeDasharray="3 3" />
                <line x1="20" y1="132.5" x2="580" y2="132.5" stroke="#f1f5f9" strokeWidth="1" strokeDasharray="3 3" />
                <line x1="20" y1="170" x2="580" y2="170" stroke="#e2e8f0" strokeWidth="1" />

                {/* Y-Axis Labels */}
                <text x="5" y="24" className="text-[10px] font-bold fill-slate-400 font-mono">10k</text>
                <text x="5" y="61.5" className="text-[10px] font-bold fill-slate-400 font-mono">7.5k</text>
                <text x="5" y="99" className="text-[10px] font-bold fill-slate-400 font-mono">5k</text>
                <text x="5" y="136.5" className="text-[10px] font-bold fill-slate-400 font-mono">2.5k</text>
                <text x="5" y="174" className="text-[10px] font-bold fill-slate-400 font-mono">0</text>

                {/* Smooth Gradient Area Fill */}
                <path d={areaD} fill="url(#purpleAreaGradient)" />

                {/* Smooth Curve Stroke Line */}
                <path
                  d={pathD}
                  fill="none"
                  stroke="#7C3AED"
                  strokeWidth="4"
                  strokeLinecap="round"
                  className="transition-all duration-300"
                />

                {/* Interactive Data Points */}
                {coords.map((pt, i) => (
                  <g key={i} className="cursor-pointer">
                    <circle
                      cx={pt.x}
                      cy={pt.y}
                      r="7"
                      className="fill-white stroke-[#7C3AED] stroke-[3.5] transition-all hover:r-9 hover:stroke-purple-900"
                      onMouseEnter={() => setHoveredPointIndex(i)}
                      onMouseLeave={() => setHoveredPointIndex(null)}
                    />
                  </g>
                ))}
              </svg>

              {/* X-Axis Dates */}
              <div className="flex justify-between text-[11px] font-bold text-slate-400 mt-2 px-6">
                <span>May 01</span>
                <span>May 08</span>
                <span>May 15</span>
                <span>May 22</span>
                <span>May 30</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Footer Metadata Row */}
      <div className="pt-6 border-t border-slate-200/60 flex flex-col sm:flex-row items-center justify-between text-xs font-semibold text-slate-400 gap-2">
        <div>
          {"\u00A9 2025 Verified Industry Partnership Network \u2022 College Module"}
        </div>
        <div className="flex items-center space-x-3">
          <a href="#" className="hover:text-purple-600 transition-colors">Privacy Policy</a>
          <span>•</span>
          <a href="#" className="hover:text-purple-600 transition-colors">Terms of Service</a>
          <span>•</span>
          <a href="#" className="hover:text-purple-600 transition-colors">API Status</a>
        </div>
      </div>

      {/* Modal 1: System Diagnostics Modal */}
      {showDiagnosticsModal && (
        <div className="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl shadow-2xl border border-purple-100 max-w-md w-full p-6 space-y-5 animate-in fade-in zoom-in-95">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <Server className="w-5 h-5 text-purple-700" />
                <h3 className="text-base font-black text-slate-900">System Diagnostics</h3>
              </div>
              <button
                onClick={() => setShowDiagnosticsModal(false)}
                className="p-1 rounded-full text-slate-400 hover:text-slate-600 hover:bg-slate-100 cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="space-y-3 text-xs font-semibold">
              <div className="p-3 bg-emerald-50 border border-emerald-200 rounded-xl flex items-center justify-between">
                <div className="flex items-center gap-2 text-emerald-800 font-bold">
                  <Wifi className="w-4 h-4 text-emerald-600" />
                  <span>API Gateway Cluster</span>
                </div>
                <span className="font-mono text-emerald-700 font-bold">12ms (100%)</span>
              </div>

              <div className="p-3 bg-emerald-50 border border-emerald-200 rounded-xl flex items-center justify-between">
                <div className="flex items-center gap-2 text-emerald-800 font-bold">
                  <Activity className="w-4 h-4 text-emerald-600" />
                  <span>MongoDB Atlas Cluster</span>
                </div>
                <span className="font-mono text-emerald-700 font-bold">Connected (4ms)</span>
              </div>

              <div className="p-3 bg-emerald-50 border border-emerald-200 rounded-xl flex items-center justify-between">
                <div className="flex items-center gap-2 text-emerald-800 font-bold">
                  <ShieldCheck className="w-4 h-4 text-emerald-600" />
                  <span>JWT Auth & Key Vault</span>
                </div>
                <span className="font-mono text-emerald-700 font-bold">Operational</span>
              </div>
            </div>

            <div className="pt-2 flex justify-end">
              <button
                onClick={() => setShowDiagnosticsModal(false)}
                className="py-2.5 px-4 bg-purple-700 hover:bg-purple-800 text-white font-bold text-xs rounded-xl shadow-md cursor-pointer"
              >
                Close Diagnostics
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Modal 2: Quick Broadcast Modal */}
      {showBroadcastModal && (
        <div className="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl shadow-2xl border border-purple-100 max-w-lg w-full p-6 space-y-4 animate-in fade-in zoom-in-95">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <Megaphone className="w-5 h-5 text-purple-700" />
                <h3 className="text-base font-black text-slate-900">Compose System Broadcast</h3>
              </div>
              <button
                onClick={() => setShowBroadcastModal(false)}
                className="p-1 rounded-full text-slate-400 hover:text-slate-600 hover:bg-slate-100 cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <form onSubmit={handleSendBroadcast} className="space-y-4 text-xs font-bold text-slate-700">
              <div className="space-y-1.5">
                <label className="block text-[10px] uppercase tracking-wider font-extrabold text-slate-500">
                  Broadcast Message
                </label>
                <textarea
                  rows={4}
                  value={broadcastMessage}
                  onChange={(e) => setBroadcastMessage(e.target.value)}
                  placeholder="Enter platform notification to dispatch to all active students, recruiters, and colleges..."
                  className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium text-slate-900 focus:outline-none focus:ring-2 focus:ring-purple-600/30 focus:border-purple-600"
                  required
                />
              </div>

              <div className="flex items-center justify-end gap-2 pt-2">
                <button
                  type="button"
                  onClick={() => setShowBroadcastModal(false)}
                  className="py-2.5 px-4 border border-slate-200 hover:bg-slate-50 text-slate-700 font-bold rounded-xl text-xs cursor-pointer"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="py-2.5 px-4 bg-purple-700 hover:bg-purple-800 text-white font-bold rounded-xl text-xs shadow-md cursor-pointer flex items-center gap-1.5"
                >
                  <Play className="w-3 h-3 fill-white" />
                  <span>Dispatch Broadcast</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default AdminOverview;
