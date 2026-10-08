import React, { useState, useMemo } from "react";
import {
  Download,
  Calendar as CalendarIcon,
  FileText,
  Search,
  SlidersHorizontal,
  TrendingUp,
  Sparkles,
  ChevronDown,
  X,
  CheckCircle2,
  Cloud,
  Layers,
  Zap,
  ArrowRight,
  BarChart3,
  DollarSign
} from "lucide-react";

export interface DrivePerformanceRow {
  id: string;
  companyName: string;
  logoType: "cloud" | "atlassian" | "bank" | "zap";
  logoBg: string;
  role: string;
  applicants: number;
  selected: number;
  conversionPct: number;
  avgCtcLpa: string;
  status: "CLOSED" | "IN PROGRESS" | "UPCOMING";
}

export interface DepartmentPlacementMetric {
  dept: string;
  placed: number;
  total: number;
  pct: number;
}

const SESSION_DATASETS: Record<
  string,
  {
    placedPct: number;
    eligibleCount: number;
    offersCount: number;
    tierDist: { tier1: number; tier2: number; tier3: number; others: number };
    monthlyAvg: number;
    aiMastery: number;
    codeQuality: number;
    archDesign: number;
    scalability: number;
    departments: DepartmentPlacementMetric[];
    drives: DrivePerformanceRow[];
  }
> = {
  "2023-24": {
    placedPct: 82,
    eligibleCount: 1240,
    offersCount: 1016,
    tierDist: { tier1: 25, tier2: 35, tier3: 30, others: 10 },
    monthlyAvg: 2841,
    aiMastery: 88.4,
    codeQuality: 92,
    archDesign: 84,
    scalability: 76,
    departments: [
      { dept: "CS/IT", placed: 420, total: 450, pct: 93 },
      { dept: "ECE", placed: 260, total: 300, pct: 86 },
      { dept: "Mech", placed: 180, total: 220, pct: 81 },
      { dept: "MBA", placed: 110, total: 140, pct: 78 },
      { dept: "Civil", placed: 46, total: 130, pct: 35 }
    ],
    drives: [
      {
        id: "d-1",
        companyName: "Salesforce",
        logoType: "cloud",
        logoBg: "bg-purple-50 text-[#7C3AED]",
        role: "MTS-1 Software",
        applicants: 840,
        selected: 24,
        conversionPct: 2.8,
        avgCtcLpa: "28.5 LPA",
        status: "CLOSED"
      },
      {
        id: "d-2",
        companyName: "Atlassian",
        logoType: "atlassian",
        logoBg: "bg-[#0052CC]/10 text-[#0052CC]",
        role: "Product Engineer",
        applicants: 520,
        selected: 12,
        conversionPct: 2.3,
        avgCtcLpa: "42.0 LPA",
        status: "CLOSED"
      },
      {
        id: "d-3",
        companyName: "Goldman Sachs",
        logoType: "bank",
        logoBg: "bg-[#7399C6]/15 text-[#2563EB]",
        role: "Analyst",
        applicants: 1150,
        selected: 45,
        conversionPct: 3.9,
        avgCtcLpa: "22.0 LPA",
        status: "IN PROGRESS"
      },
      {
        id: "d-4",
        companyName: "Razorpay",
        logoType: "zap",
        logoBg: "bg-purple-100 text-purple-700",
        role: "Frontend SDE",
        applicants: 410,
        selected: 8,
        conversionPct: 1.9,
        avgCtcLpa: "18.0 LPA",
        status: "UPCOMING"
      }
    ]
  },
  "2024-25": {
    placedPct: 88,
    eligibleCount: 1350,
    offersCount: 1188,
    tierDist: { tier1: 30, tier2: 38, tier3: 24, others: 8 },
    monthlyAvg: 3120,
    aiMastery: 91.2,
    codeQuality: 95,
    archDesign: 88,
    scalability: 82,
    departments: [
      { dept: "CS/IT", placed: 470, total: 490, pct: 95 },
      { dept: "ECE", placed: 290, total: 320, pct: 90 },
      { dept: "Mech", placed: 200, total: 230, pct: 87 },
      { dept: "MBA", placed: 130, total: 150, pct: 86 },
      { dept: "Civil", placed: 98, total: 160, pct: 61 }
    ],
    drives: [
      {
        id: "d-5",
        companyName: "Salesforce",
        logoType: "cloud",
        logoBg: "bg-purple-50 text-[#7C3AED]",
        role: "MTS-2 Software",
        applicants: 920,
        selected: 30,
        conversionPct: 3.2,
        avgCtcLpa: "30.0 LPA",
        status: "CLOSED"
      },
      {
        id: "d-6",
        companyName: "Atlassian",
        logoType: "atlassian",
        logoBg: "bg-[#0052CC]/10 text-[#0052CC]",
        role: "Senior Product Engineer",
        applicants: 600,
        selected: 18,
        conversionPct: 3.0,
        avgCtcLpa: "45.0 LPA",
        status: "IN PROGRESS"
      }
    ]
  },
  "2025-26": {
    placedPct: 92,
    eligibleCount: 1420,
    offersCount: 1306,
    tierDist: { tier1: 35, tier2: 40, tier3: 20, others: 5 },
    monthlyAvg: 3450,
    aiMastery: 93.8,
    codeQuality: 97,
    archDesign: 92,
    scalability: 88,
    departments: [
      { dept: "CS/IT", placed: 510, total: 520, pct: 98 },
      { dept: "ECE", placed: 310, total: 330, pct: 93 },
      { dept: "Mech", placed: 220, total: 240, pct: 91 },
      { dept: "MBA", placed: 145, total: 160, pct: 90 },
      { dept: "Civil", placed: 121, total: 170, pct: 71 }
    ],
    drives: [
      {
        id: "d-7",
        companyName: "Goldman Sachs",
        logoType: "bank",
        logoBg: "bg-[#7399C6]/15 text-[#2563EB]",
        role: "Quantitative Analyst",
        applicants: 1100,
        selected: 48,
        conversionPct: 4.3,
        avgCtcLpa: "26.0 LPA",
        status: "IN PROGRESS"
      }
    ]
  }
};

export const ReportsAnalyticsView: React.FC = () => {
  // Session selector state
  const [academicSession, setAcademicSession] = useState<"2023-24" | "2024-25" | "2025-26">("2023-24");

  // Search query
  const [searchQuery, setSearchQuery] = useState("");

  // Hover states for tooltips
  const [hoveredTier, setHoveredTier] = useState<string | null>(null);
  const [hoveredDept, setHoveredDept] = useState<string | null>(null);

  // Modal State
  const [isGenerateModalOpen, setIsGenerateModalOpen] = useState(false);
  const [reportFormat, setReportFormat] = useState<"pdf" | "excel">("pdf");
  const [includeAiScores, setIncludeAiScores] = useState(true);
  const [selectedDepts, setSelectedDepts] = useState<string[]>(["CS/IT", "ECE", "Mech", "MBA", "Civil"]);

  // Toast message
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => {
      setToastMessage(null);
    }, 4000);
  };

  // Current session dataset
  const dataset = useMemo(() => {
    return SESSION_DATASETS[academicSession] || SESSION_DATASETS["2023-24"];
  }, [academicSession]);

  // Filtered Drives
  const filteredDrives = useMemo(() => {
    return dataset.drives.filter((d) => {
      const q = searchQuery.toLowerCase().trim();
      return (
        !q ||
        d.companyName.toLowerCase().includes(q) ||
        d.role.toLowerCase().includes(q) ||
        d.status.toLowerCase().includes(q)
      );
    });
  }, [dataset, searchQuery]);

  // Export CSV Handler for Table
  const handleExportCSV = () => {
    const headers = ["Company", "Role", "Applicants", "Selected", "Conversion %", "Avg CTC", "Status"];
    const csvRows = filteredDrives.map((d) => [
      `"${d.companyName}"`,
      `"${d.role}"`,
      d.applicants,
      d.selected,
      `"${d.conversionPct}%"`,
      `"${d.avgCtcLpa}"`,
      `"${d.status}"`
    ]);

    const csvContent = [headers.join(","), ...csvRows.map((e) => e.join(","))].join("\n");
    const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.setAttribute("href", url);
    link.setAttribute("download", `Hiring_Drive_Performance_${academicSession}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

    showToast(`Exported hiring drive performance dataset for Session ${academicSession} to CSV.`);
  };

  // Generate Executive Report Submit
  const handleGenerateReportSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setIsGenerateModalOpen(false);
    showToast(`Executive Placement Intelligence Report (${academicSession}) generated successfully! Downloading ${reportFormat.toUpperCase()}...`);
  };

  return (
    <div className="space-y-6 pb-20 relative">
      {/* Global Toast Notification */}
      {toastMessage && (
        <div className="fixed bottom-6 right-20 z-50 bg-slate-900 text-white text-xs font-semibold px-4 py-3 rounded-2xl shadow-2xl flex items-center gap-3 border border-slate-800 animate-bounce">
          <CheckCircle2 className="w-5 h-5 text-emerald-400 shrink-0" />
          <span>{toastMessage}</span>
          <button onClick={() => setToastMessage(null)} className="text-slate-400 hover:text-white ml-2">
            <X className="w-4 h-4" />
          </button>
        </div>
      )}

      {/* Floating Bottom-Right Action Button */}
      <button
        onClick={() => showToast("Quick Analytics & Intelligence Drawer opened.")}
        title="Quick Reports & Analytics"
        className="fixed bottom-6 right-6 z-40 w-12 h-12 rounded-2xl bg-[#7C3AED] hover:bg-[#6B21A8] active:bg-purple-900 text-white flex items-center justify-center shadow-xl transition-transform hover:scale-105 cursor-pointer"
      >
        <BarChart3 className="w-6 h-6" />
      </button>

      {/* 1. Top Action Toolbar & Header */}
      <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl md:text-3xl font-extrabold text-slate-900 tracking-tight">
            College Performance Reports
          </h1>
          <p className="text-xs md:text-sm text-slate-500 font-medium mt-1">
            Detailed academic and placement intelligence for the {academicSession} Session.
          </p>
        </div>

        <div className="flex items-center gap-3 flex-wrap">
          {/* Live Search Bar Input */}
          <div className="relative min-w-[220px] sm:min-w-[280px]">
            <Search className="w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search analytics, students, or reports..."
              className="w-full bg-white text-xs md:text-sm pl-10 pr-8 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-purple-500/30 transition-all placeholder:text-slate-400 shadow-2xs"
            />
            {searchQuery && (
              <button
                onClick={() => setSearchQuery("")}
                className="absolute right-3.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 p-1"
              >
                <X className="w-3.5 h-3.5" />
              </button>
            )}
          </div>

          {/* Academic Year Dropdown Selector */}
          <div className="relative">
            <div className="flex items-center gap-2 bg-white border border-slate-200 px-3.5 py-2.5 rounded-xl shadow-2xs cursor-pointer">
              <CalendarIcon className="w-4 h-4 text-purple-600 shrink-0" />
              <select
                value={academicSession}
                onChange={(e) =>
                  setAcademicSession(e.target.value as "2023-24" | "2024-25" | "2025-26")
                }
                className="bg-transparent text-slate-800 font-bold text-xs md:text-sm outline-none cursor-pointer pr-4 appearance-none"
              >
                <option value="2023-24">Academic Year 2023-24</option>
                <option value="2024-25">Academic Year 2024-25</option>
                <option value="2025-26">Academic Year 2025-26</option>
              </select>
              <ChevronDown className="w-4 h-4 text-slate-400 pointer-events-none" />
            </div>
          </div>

          {/* Generate Report Primary Action CTA */}
          <button
            onClick={() => setIsGenerateModalOpen(true)}
            className="bg-[#7C3AED] hover:bg-[#6B21A8] active:bg-purple-900 text-white font-bold px-4 py-2.5 rounded-xl shadow-md shadow-purple-500/20 text-xs md:text-sm flex items-center gap-2 transition-all cursor-pointer transform hover:-translate-y-0.5"
          >
            <FileText className="w-4 h-4 stroke-[2.5]" />
            <span>Generate Report</span>
          </button>
        </div>
      </div>

      {/* 2. ROW 1: PLACEMENT OVERVIEW & DEPARTMENT BREAKDOWN */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-5">
        {/* CARD 1: OVERALL PLACEMENT DOUGHNUT GAUGE (LEFT BOX - 4 COLS) */}
        <div className="lg:col-span-4 bg-white p-6 rounded-2xl border border-slate-100 shadow-xs flex flex-col justify-between space-y-6">
          <div className="flex items-center justify-between">
            <span className="text-xs font-black text-slate-400 uppercase tracking-wider">
              OVERALL PLACEMENT
            </span>
            <span className="bg-purple-100 text-purple-700 font-black text-[10px] uppercase px-2.5 py-1 rounded-full">
              +12% vs LY
            </span>
          </div>

          {/* Central Donut SVG Gauge */}
          <div className="flex flex-col items-center justify-center my-2">
            <div className="relative w-44 h-44 flex items-center justify-center">
              <svg className="w-44 h-44 transform -rotate-90">
                {/* Background Ring */}
                <circle
                  cx="88"
                  cy="88"
                  r="70"
                  stroke="#F3E8FF"
                  strokeWidth="16"
                  fill="transparent"
                />
                {/* Dynamic Placed Progress Stroke */}
                <circle
                  cx="88"
                  cy="88"
                  r="70"
                  stroke="#7C3AED"
                  strokeWidth="16"
                  strokeDasharray={439.8}
                  strokeDashoffset={439.8 - (439.8 * dataset.placedPct) / 100}
                  strokeLinecap="round"
                  fill="transparent"
                  className="transition-all duration-700"
                />
              </svg>
              {/* Inner Label */}
              <div className="absolute text-center flex flex-col items-center justify-center">
                <span className="text-3xl font-black text-slate-900 tracking-tight">
                  {dataset.placedPct}%
                </span>
                <span className="text-[10px] font-black text-slate-400 tracking-widest uppercase mt-0.5">
                  PLACED
                </span>
              </div>
            </div>
          </div>

          {/* Metrics Footer (Eligible & Offers) */}
          <div className="grid grid-cols-2 gap-4 pt-4 border-t border-slate-100 text-left">
            <div>
              <span className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block">
                ELIGIBLE
              </span>
              <span className="text-lg font-black text-slate-900 mt-0.5 block">
                {dataset.eligibleCount.toLocaleString()}
              </span>
            </div>
            <div>
              <span className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block">
                OFFERS
              </span>
              <span className="text-lg font-black text-purple-700 mt-0.5 block">
                {dataset.offersCount.toLocaleString()}
              </span>
            </div>
          </div>
        </div>

        {/* CARD 2: PLACEMENT BY DEPARTMENT BAR CHART (RIGHT BOX - 8 COLS) */}
        <div className="lg:col-span-8 bg-white p-6 rounded-2xl border border-slate-100 shadow-xs flex flex-col justify-between space-y-6">
          <div className="flex items-center justify-between">
            <span className="text-xs font-black text-slate-400 uppercase tracking-wider">
              PLACEMENT BY DEPARTMENT
            </span>
            {/* Chart Legend */}
            <div className="flex items-center gap-4 text-xs font-bold">
              <span className="flex items-center gap-1.5 text-slate-700">
                <span className="w-2.5 h-2.5 rounded-full bg-[#7C3AED]" /> PLACED
              </span>
              <span className="flex items-center gap-1.5 text-slate-400">
                <span className="w-2.5 h-2.5 rounded-full bg-purple-100" /> TOTAL
              </span>
            </div>
          </div>

          {/* Comparative Bar Graph Area */}
          <div className="h-48 flex items-end justify-between gap-4 pt-6 pb-2 px-4 relative border-b border-slate-100">
            {dataset.departments.map((item) => {
              const totalHeightPct = 90;
              const placedHeightPct = Math.round((item.placed / item.total) * 90);
              const isHovered = hoveredDept === item.dept;

              return (
                <div
                  key={item.dept}
                  onMouseEnter={() => setHoveredDept(item.dept)}
                  onMouseLeave={() => setHoveredDept(null)}
                  className="flex-1 flex flex-col items-center h-full justify-end group cursor-pointer relative"
                >
                  {/* Tooltip on hover */}
                  {isHovered && (
                    <div className="absolute -top-10 bg-slate-900 text-white text-[10px] font-bold px-2.5 py-1 rounded-lg shadow-lg whitespace-nowrap z-10 animate-fade-in">
                      {item.dept}: {item.placed} Placed / {item.total} Total ({item.pct}%)
                    </div>
                  )}

                  {/* Dual Bars Side-by-Side */}
                  <div className="flex items-end justify-center gap-1.5 w-full h-full">
                    {/* Placed Bar */}
                    <div
                      className="w-4 sm:w-6 bg-[#7C3AED] rounded-t-lg transition-all duration-500 group-hover:bg-[#6B21A8]"
                      style={{ height: `${placedHeightPct}%` }}
                    />
                    {/* Total Bar */}
                    <div
                      className="w-4 sm:w-6 bg-purple-100 rounded-t-lg transition-all duration-500 group-hover:bg-purple-200"
                      style={{ height: `${totalHeightPct}%` }}
                    />
                  </div>

                  {/* Dept Label */}
                  <span className="text-xs font-extrabold text-slate-600 mt-3">{item.dept}</span>
                </div>
              );
            })}
          </div>
        </div>
      </div>

      {/* 3. ROW 2: COMPANY TIER DISTRIBUTION BAR */}
      <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-xs space-y-4">
        <div className="flex items-center justify-between">
          <span className="text-xs font-black text-slate-400 uppercase tracking-wider">
            COMPANY TIER DISTRIBUTION
          </span>
          <span className="text-xs font-semibold text-slate-400">Salary Band Breakdown</span>
        </div>

        {/* Multi-segmented Horizontal Stacked Bar */}
        <div className="w-full h-8 bg-slate-100 rounded-xl overflow-hidden flex items-center p-1 gap-1">
          {/* Tier 1: 25% */}
          <div
            onMouseEnter={() => setHoveredTier("Tier 1")}
            onMouseLeave={() => setHoveredTier(null)}
            className="h-full bg-[#7C3AED] rounded-lg text-white font-extrabold text-[11px] flex items-center justify-center transition-all cursor-pointer hover:opacity-90"
            style={{ width: `${dataset.tierDist.tier1}%` }}
          >
            {dataset.tierDist.tier1}%
          </div>

          {/* Tier 2: 35% */}
          <div
            onMouseEnter={() => setHoveredTier("Tier 2")}
            onMouseLeave={() => setHoveredTier(null)}
            className="h-full bg-[#8B5CF6] rounded-lg text-white font-extrabold text-[11px] flex items-center justify-center transition-all cursor-pointer hover:opacity-90"
            style={{ width: `${dataset.tierDist.tier2}%` }}
          >
            {dataset.tierDist.tier2}%
          </div>

          {/* Tier 3: 30% */}
          <div
            onMouseEnter={() => setHoveredTier("Tier 3")}
            onMouseLeave={() => setHoveredTier(null)}
            className="h-full bg-[#C4B5FD] rounded-lg text-slate-800 font-extrabold text-[11px] flex items-center justify-center transition-all cursor-pointer hover:opacity-90"
            style={{ width: `${dataset.tierDist.tier3}%` }}
          >
            {dataset.tierDist.tier3}%
          </div>

          {/* Others: 10% */}
          <div
            onMouseEnter={() => setHoveredTier("Others")}
            onMouseLeave={() => setHoveredTier(null)}
            className="h-full bg-[#E2E8F0] rounded-lg text-slate-600 font-extrabold text-[11px] flex items-center justify-center transition-all cursor-pointer hover:opacity-90"
            style={{ width: `${dataset.tierDist.others}%` }}
          >
            {dataset.tierDist.others}%
          </div>
        </div>

        {/* Interactive Legend Row */}
        <div className="flex flex-wrap items-center justify-between gap-4 text-xs font-bold pt-1">
          <span
            className={`flex items-center gap-1.5 ${
              hoveredTier === "Tier 1" ? "text-purple-700 font-black scale-105" : "text-slate-700"
            } transition-all`}
          >
            <span className="w-2.5 h-2.5 rounded-full bg-[#7C3AED]" /> Tier 1: 12-40 LPA
          </span>

          <span
            className={`flex items-center gap-1.5 ${
              hoveredTier === "Tier 2" ? "text-purple-700 font-black scale-105" : "text-slate-700"
            } transition-all`}
          >
            <span className="w-2.5 h-2.5 rounded-full bg-[#8B5CF6]" /> Tier 2: 7-12 LPA
          </span>

          <span
            className={`flex items-center gap-1.5 ${
              hoveredTier === "Tier 3" ? "text-purple-700 font-black scale-105" : "text-slate-700"
            } transition-all`}
          >
            <span className="w-2.5 h-2.5 rounded-full bg-[#C4B5FD]" /> Tier 3: 4-7 LPA
          </span>

          <span
            className={`flex items-center gap-1.5 ${
              hoveredTier === "Others" ? "text-purple-700 font-black scale-105" : "text-slate-500"
            } transition-all`}
          >
            <span className="w-2.5 h-2.5 rounded-full bg-[#E2E8F0]" /> Others: Startup/NGO
          </span>
        </div>
      </div>

      {/* 4. ROW 3: ACTIVE STUDENT TREND & AI MASTERY SCORE */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-5 items-stretch">
        {/* CARD 1: ACTIVE MONTHLY TREND (LEFT BOX - 8 COLS) */}
        <div className="lg:col-span-8 bg-white p-6 rounded-2xl border border-slate-100 shadow-xs flex flex-col justify-between space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <span className="text-xs font-black text-slate-400 uppercase tracking-wider block">
                ACTIVE STUDENTS
              </span>
              <div className="flex items-baseline gap-2 mt-0.5">
                <span className="text-2xl font-black text-slate-900">
                  {dataset.monthlyAvg.toLocaleString()}
                </span>
                <span className="text-xs font-semibold text-slate-500">Monthly Avg</span>
              </div>
            </div>
            <div className="w-10 h-10 rounded-xl bg-purple-50 text-purple-700 flex items-center justify-center">
              <TrendingUp className="w-5 h-5" />
            </div>
          </div>

          {/* Area/Line Graph Graphic SVG matching Image 2 */}
          <div className="h-40 w-full pt-4 relative">
            <svg className="w-full h-full overflow-visible" viewBox="0 0 500 120">
              <defs>
                <linearGradient id="purpleGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="#7C3AED" stopOpacity="0.35" />
                  <stop offset="100%" stopColor="#7C3AED" stopOpacity="0.0" />
                </linearGradient>
              </defs>

              {/* Gradient Area Fill */}
              <path
                d="M 0,75 Q 75,55 150,75 T 300,30 T 400,85 T 500,50 L 500,120 L 0,120 Z"
                fill="url(#purpleGradient)"
              />

              {/* Trend Curve Line */}
              <path
                d="M 0,75 Q 75,55 150,75 T 300,30 T 400,85 T 500,50"
                fill="none"
                stroke="#7C3AED"
                strokeWidth="3.5"
                strokeLinecap="round"
              />

              {/* End Circle Indicator */}
              <circle cx="496" cy="52" r="4.5" fill="#7C3AED" className="animate-ping" />
              <circle cx="496" cy="52" r="4.5" fill="#7C3AED" />
            </svg>
          </div>

          {/* Month Labels Footer */}
          <div className="flex items-center justify-between text-[11px] font-extrabold text-slate-400 tracking-wider px-2 pt-2 border-t border-slate-100">
            <span>SEP</span>
            <span>OCT</span>
            <span>NOV</span>
            <span>DEC</span>
            <span>JAN</span>
            <span>FEB</span>
          </div>
        </div>

        {/* CARD 2: AVERAGE AI MASTERY SCORE (SOLID PURPLE RIGHT BOX - 4 COLS) */}
        <div className="lg:col-span-4 bg-[#7C3AED] text-white p-6 rounded-2xl shadow-md flex flex-col justify-between space-y-5">
          <div className="flex items-center justify-between">
            <span className="text-xs font-black tracking-wider uppercase text-purple-200 flex items-center gap-1.5">
              <Sparkles className="w-4 h-4 text-amber-300 fill-amber-300" />
              AVG AI MASTERY SCORE
            </span>
          </div>

          <div>
            <div className="text-4xl font-black tracking-tight text-white">
              {dataset.aiMastery.toFixed(1)}{" "}
              <span className="text-sm font-semibold text-purple-200">/ 100</span>
            </div>
          </div>

          {/* Competency Progress Bars */}
          <div className="space-y-3.5 pt-2 border-t border-purple-400/40">
            {/* Code Quality */}
            <div className="space-y-1">
              <div className="flex items-center justify-between text-xs font-bold text-purple-100">
                <span>Code Quality</span>
                <span>{dataset.codeQuality}%</span>
              </div>
              <div className="w-full bg-purple-900/50 h-2 rounded-full overflow-hidden">
                <div
                  className="h-full bg-white rounded-full transition-all duration-500"
                  style={{ width: `${dataset.codeQuality}%` }}
                />
              </div>
            </div>

            {/* Architecture Design */}
            <div className="space-y-1">
              <div className="flex items-center justify-between text-xs font-bold text-purple-100">
                <span>Architecture Design</span>
                <span>{dataset.archDesign}%</span>
              </div>
              <div className="w-full bg-purple-900/50 h-2 rounded-full overflow-hidden">
                <div
                  className="h-full bg-white rounded-full transition-all duration-500"
                  style={{ width: `${dataset.archDesign}%` }}
                />
              </div>
            </div>

            {/* Scalability Analysis */}
            <div className="space-y-1">
              <div className="flex items-center justify-between text-xs font-bold text-purple-100">
                <span>Scalability Analysis</span>
                <span>{dataset.scalability}%</span>
              </div>
              <div className="w-full bg-purple-900/50 h-2 rounded-full overflow-hidden">
                <div
                  className="h-full bg-white rounded-full transition-all duration-500"
                  style={{ width: `${dataset.scalability}%` }}
                />
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* 5. ROW 4: HIRING DRIVE PERFORMANCE DATA TABLE */}
      <div className="bg-white rounded-2xl border border-slate-100 shadow-xs overflow-hidden">
        {/* Table Header Controls */}
        <div className="p-5 border-b border-slate-100 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <h3 className="text-base font-extrabold text-slate-900">
            Hiring Drive Performance
          </h3>

          <div className="flex items-center gap-2">
            <button
              onClick={() => showToast("Table filter options opened.")}
              className="p-2 bg-slate-50 hover:bg-slate-100 text-slate-600 rounded-xl border border-slate-200 transition-colors cursor-pointer"
              title="Filter Table"
            >
              <SlidersHorizontal className="w-4 h-4" />
            </button>
            <button
              onClick={handleExportCSV}
              className="p-2 bg-slate-50 hover:bg-slate-100 text-slate-600 rounded-xl border border-slate-200 transition-colors cursor-pointer"
              title="Export CSV"
            >
              <Download className="w-4 h-4" />
            </button>
          </div>
        </div>

        {/* Data Table */}
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-slate-50/70 border-b border-slate-100 text-[11px] font-extrabold text-slate-400 uppercase tracking-wider">
                <th className="py-4 px-6">COMPANY</th>
                <th className="py-4 px-4">ROLE</th>
                <th className="py-4 px-4 text-center">APPLICANTS</th>
                <th className="py-4 px-4 text-center">SELECTED</th>
                <th className="py-4 px-4 text-center">CONVERSION %</th>
                <th className="py-4 px-4">AVG CTC</th>
                <th className="py-4 px-6 text-right">STATUS</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-xs font-medium">
              {filteredDrives.length > 0 ? (
                filteredDrives.map((d) => (
                  <tr key={d.id} className="hover:bg-purple-50/30 transition-colors">
                    <td className="py-4 px-6">
                      <div className="flex items-center gap-3">
                        <div
                          className={`w-9 h-9 rounded-xl ${d.logoBg} font-black text-xs flex items-center justify-center shadow-2xs shrink-0`}
                        >
                          {d.logoType === "cloud" && <Cloud className="w-5 h-5" />}
                          {d.logoType === "atlassian" && <Layers className="w-5 h-5" />}
                          {d.logoType === "bank" && <DollarSign className="w-5 h-5" />}
                          {d.logoType === "zap" && <Zap className="w-5 h-5" />}
                        </div>
                        <span className="font-extrabold text-slate-900">{d.companyName}</span>
                      </div>
                    </td>
                    <td className="py-4 px-4 text-slate-600 font-semibold">{d.role}</td>
                    <td className="py-4 px-4 text-center font-bold text-slate-800">
                      {d.applicants.toLocaleString()}
                    </td>
                    <td className="py-4 px-4 text-center font-black text-[#7C3AED]">
                      {d.selected}
                    </td>
                    <td className="py-4 px-4 text-center font-bold text-slate-700">
                      <div className="flex items-center justify-center gap-1.5">
                        <div className="w-12 bg-slate-100 h-1.5 rounded-full overflow-hidden">
                          <div
                            className="bg-[#7C3AED] h-full rounded-full"
                            style={{ width: `${d.conversionPct * 15}%` }}
                          />
                        </div>
                        <span>{d.conversionPct}%</span>
                      </div>
                    </td>
                    <td className="py-4 px-4 font-black text-slate-900">{d.avgCtcLpa}</td>
                    <td className="py-4 px-6 text-right">
                      <span
                        className={`text-[10px] font-black uppercase px-2.5 py-1 rounded-md ${
                          d.status === "CLOSED"
                            ? "bg-emerald-100 text-emerald-700"
                            : d.status === "IN PROGRESS"
                            ? "bg-purple-100 text-purple-700"
                            : "bg-rose-100 text-rose-600"
                        }`}
                      >
                        {d.status}
                      </span>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={7} className="py-12 text-center text-slate-400 text-xs">
                    No hiring drive records match your search query.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>

        {/* Footer Link */}
        <div className="p-4 bg-slate-50/50 border-t border-slate-100 text-center">
          <button
            onClick={() => showToast("Navigating to Placement Drives Management...")}
            className="text-xs font-extrabold text-purple-700 hover:text-purple-900 inline-flex items-center gap-1 transition-colors cursor-pointer"
          >
            <span>View All Active Drives</span>
            <ArrowRight className="w-3.5 h-3.5" />
          </button>
        </div>
      </div>

      {/* MODAL: Generate Report Wizard */}
      {isGenerateModalOpen && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl space-y-5 animate-in zoom-in-95 duration-200">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <FileText className="w-5 h-5 text-purple-600" />
                <h3 className="text-lg font-extrabold text-slate-900">
                  Generate Executive Placement Report
                </h3>
              </div>
              <button
                onClick={() => setIsGenerateModalOpen(false)}
                className="text-slate-400 hover:text-slate-600 p-1"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleGenerateReportSubmit} className="space-y-4 text-xs font-medium">
              <div>
                <label className="font-bold text-slate-700 block mb-1">Target Academic Session</label>
                <select
                  value={academicSession}
                  onChange={(e) =>
                    setAcademicSession(e.target.value as "2023-24" | "2024-25" | "2025-26")
                  }
                  className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                >
                  <option value="2023-24">Academic Year 2023-24</option>
                  <option value="2024-25">Academic Year 2024-25</option>
                  <option value="2025-26">Academic Year 2025-26</option>
                </select>
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Include Departments</label>
                <div className="grid grid-cols-3 gap-2 pt-1">
                  {["CS/IT", "ECE", "Mech", "MBA", "Civil"].map((dept) => {
                    const isChecked = selectedDepts.includes(dept);

                    return (
                      <button
                        type="button"
                        key={dept}
                        onClick={() => {
                          if (isChecked) {
                            setSelectedDepts(selectedDepts.filter((d) => d !== dept));
                          } else {
                            setSelectedDepts([...selectedDepts, dept]);
                          }
                        }}
                        className={`p-2 rounded-xl text-xs font-bold border transition-all text-center ${
                          isChecked
                            ? "bg-purple-100 text-purple-700 border-purple-300"
                            : "bg-slate-50 text-slate-600 border-slate-200"
                        }`}
                      >
                        {dept}
                      </button>
                    );
                  })}
                </div>
              </div>

              <div className="flex items-center gap-2 pt-1">
                <input
                  type="checkbox"
                  id="incAi"
                  checked={includeAiScores}
                  onChange={(e) => setIncludeAiScores(e.target.checked)}
                  className="w-4 h-4 accent-purple-600 rounded cursor-pointer"
                />
                <label htmlFor="incAi" className="font-bold text-slate-700 cursor-pointer">
                  Include AI Candidate Mastery &amp; Competency Scores
                </label>
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Export Format</label>
                <div className="grid grid-cols-2 gap-3">
                  <button
                    type="button"
                    onClick={() => setReportFormat("pdf")}
                    className={`p-3 rounded-xl border font-bold text-xs flex items-center justify-center gap-2 transition-all ${
                      reportFormat === "pdf"
                        ? "bg-[#7C3AED] text-white border-[#7C3AED]"
                        : "bg-slate-50 text-slate-700 border-slate-200"
                    }`}
                  >
                    <Download className="w-4 h-4" /> PDF Executive Report
                  </button>
                  <button
                    type="button"
                    onClick={() => setReportFormat("excel")}
                    className={`p-3 rounded-xl border font-bold text-xs flex items-center justify-center gap-2 transition-all ${
                      reportFormat === "excel"
                        ? "bg-emerald-600 text-white border-emerald-600"
                        : "bg-slate-50 text-slate-700 border-slate-200"
                    }`}
                  >
                    <Download className="w-4 h-4" /> Excel Raw Dataset
                  </button>
                </div>
              </div>

              <div className="flex items-center justify-end gap-3 pt-4 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setIsGenerateModalOpen(false)}
                  className="px-4 py-2.5 text-slate-600 font-bold hover:bg-slate-100 rounded-xl"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="bg-[#7C3AED] hover:bg-[#6B21A8] text-white font-bold px-5 py-2.5 rounded-xl shadow-md shadow-purple-500/20"
                >
                  Generate &amp; Download Report
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default ReportsAnalyticsView;
export const ReportsView = ReportsAnalyticsView;
