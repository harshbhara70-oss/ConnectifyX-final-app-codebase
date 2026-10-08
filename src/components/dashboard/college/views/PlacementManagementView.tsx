import React, { useState, useMemo } from "react";
import {
  Search,
  SlidersHorizontal,
  Plus,
  Video,
  Building2,
  ChevronRight,
  Sparkles,
  Calendar as CalendarIcon,
  X,
  CheckCircle2,
  Download,
  Send,
  TrendingUp,
  AlertCircle
} from "lucide-react";

export interface CampusDriveItem {
  id: string;
  companyName: string;
  logoText: string;
  logoBg: string;
  jobRole: string;
  mode: "Virtual" | "On-Campus";
  eligibility: string;
  appliedCount: number;
  capacityLimit: number;
  deadlineDate: string; // e.g. "24 Oct, 2023"
  isUrgentDeadline?: boolean;
  stageStatus: "INTERVIEWING" | "REGISTRATION OPEN" | "TESTING STAGE" | "OFFERS RELEASED";
  packageLPA: string; // e.g. "18.5 LPA"
  location: string;
  description: string;
  registeredStudents: {
    id: string;
    name: string;
    roll: string;
    cgpa: number;
    dept: string;
    status: "Shortlisted" | "Under Review" | "Rejected";
  }[];
}

const INITIAL_DRIVES: CampusDriveItem[] = [
  {
    id: "drive-1",
    companyName: "Nexus Systems",
    logoText: "NS",
    logoBg: "bg-[#4F46E5]",
    jobRole: "Senior Software Engineer",
    mode: "Virtual",
    eligibility: "CGPA > 8.5",
    appliedCount: 156,
    capacityLimit: 240,
    deadlineDate: "24 Oct, 2023",
    isUrgentDeadline: true,
    stageStatus: "INTERVIEWING",
    packageLPA: "22.0 LPA",
    location: "Bengaluru / Remote",
    description: "Architecting cloud-native distributed backend microservices and React dashboards.",
    registeredStudents: [
      { id: "s-1", name: "Arjun Mehta", roll: "CS2024-042", cgpa: 8.92, dept: "Computer Science", status: "Shortlisted" },
      { id: "s-2", name: "Priya Sharma", roll: "CS2024-099", cgpa: 9.60, dept: "Computer Science", status: "Shortlisted" },
      { id: "s-3", name: "Kavya Nair", roll: "CS2025-077", cgpa: 8.75, dept: "Computer Science", status: "Under Review" }
    ]
  },
  {
    id: "drive-2",
    companyName: "FinStrat Global",
    logoText: "FG",
    logoBg: "bg-[#0EA5E9]",
    jobRole: "Investment Analyst",
    mode: "On-Campus",
    eligibility: "Finance Major",
    appliedCount: 42,
    capacityLimit: 85,
    deadlineDate: "28 Oct, 2023",
    stageStatus: "REGISTRATION OPEN",
    packageLPA: "16.5 LPA",
    location: "Mumbai",
    description: "Quantitative risk modeling, corporate valuations, and capital markets analytics.",
    registeredStudents: [
      { id: "s-4", name: "Sarah Johnson", roll: "EC2024-118", cgpa: 7.45, dept: "Electronics", status: "Under Review" },
      { id: "s-5", name: "Rahul Verma", roll: "CE2025-015", cgpa: 7.20, dept: "Civil", status: "Under Review" }
    ]
  },
  {
    id: "drive-3",
    companyName: "CloudScale Solutions",
    logoText: "CS",
    logoBg: "bg-[#9333EA]",
    jobRole: "Cloud Architect Intern",
    mode: "Virtual",
    eligibility: "Any Tech",
    appliedCount: 312,
    capacityLimit: 500,
    deadlineDate: "30 Oct, 2023",
    stageStatus: "TESTING STAGE",
    packageLPA: "12.0 LPA",
    location: "Hyderabad / Remote",
    description: "AWS Infrastructure provisioning, Kubernetes orchestration, and CI/CD pipelines.",
    registeredStudents: [
      { id: "s-6", name: "Ananya Roy", roll: "ME2024-089", cgpa: 8.15, dept: "Mechanical", status: "Shortlisted" },
      { id: "s-7", name: "Dev Patel", roll: "EC2026-033", cgpa: 6.90, dept: "Electronics", status: "Under Review" }
    ]
  },
  {
    id: "drive-4",
    companyName: "Stripe APAC",
    logoText: "ST",
    logoBg: "bg-[#2563EB]",
    jobRole: "Full Stack Engineer",
    mode: "Virtual",
    eligibility: "CGPA > 8.0",
    appliedCount: 198,
    capacityLimit: 300,
    deadlineDate: "05 Nov, 2023",
    stageStatus: "REGISTRATION OPEN",
    packageLPA: "28.5 LPA",
    location: "Singapore / Remote",
    description: "Building next-generation global payment orchestration rails and developer APIs.",
    registeredStudents: [
      { id: "s-8", name: "Vikram Singh", roll: "CS2024-001", cgpa: 8.52, dept: "Computer Science", status: "Under Review" }
    ]
  },
  {
    id: "drive-5",
    companyName: "Aether Tech Labs",
    logoText: "AT",
    logoBg: "bg-[#10B981]",
    jobRole: "AI / ML Research Associate",
    mode: "On-Campus",
    eligibility: "CGPA > 8.5",
    appliedCount: 88,
    capacityLimit: 100,
    deadlineDate: "12 Nov, 2023",
    stageStatus: "OFFERS RELEASED",
    packageLPA: "24.0 LPA",
    location: "Bengaluru",
    description: "Large language model fine-tuning, computer vision pipelines, and edge inference.",
    registeredStudents: [
      { id: "s-9", name: "Neha Gupta", roll: "CS2024-055", cgpa: 9.40, dept: "Computer Science", status: "Shortlisted" }
    ]
  }
];

export const PlacementManagementView: React.FC = () => {
  // Drives state
  const [drives, setDrives] = useState<CampusDriveItem[]>(INITIAL_DRIVES);

  // Tab state: "active" vs "calendar"
  const [activeTab, setActiveTab] = useState<"active" | "calendar">("active");

  // Search & Filter bar state
  const [searchQuery, setSearchQuery] = useState("");
  const [isFilterPanelOpen, setIsFilterPanelOpen] = useState(false);
  const [selectedMode, setSelectedMode] = useState<"All" | "Virtual" | "On-Campus">("All");
  const [selectedStatus, setSelectedStatus] = useState<string>("All");

  // Drawer detail state
  const [selectedDriveDetail, setSelectedDriveDetail] = useState<CampusDriveItem | null>(null);

  // Add Drive Modal state
  const [isAddDriveOpen, setIsAddDriveOpen] = useState(false);
  const [newDriveForm, setNewDriveForm] = useState({
    companyName: "",
    jobRole: "",
    mode: "Virtual" as "Virtual" | "On-Campus",
    eligibility: "CGPA > 8.0",
    packageLPA: "18.0 LPA",
    location: "Bengaluru / Remote",
    capacityLimit: "250",
    deadlineDate: "15 Nov, 2023",
    description: "Role overview and candidate responsibilities..."
  });

  // Toast Notification state
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => {
      setToastMessage(null);
    }, 4000);
  };

  // Filtered Drives
  const filteredDrives = useMemo(() => {
    return drives.filter((d) => {
      const q = searchQuery.toLowerCase().trim();
      const matchesSearch =
        !q ||
        d.companyName.toLowerCase().includes(q) ||
        d.jobRole.toLowerCase().includes(q) ||
        d.stageStatus.toLowerCase().includes(q);

      const matchesMode = selectedMode === "All" || d.mode === selectedMode;
      const matchesStatus = selectedStatus === "All" || d.stageStatus === selectedStatus;

      return matchesSearch && matchesMode && matchesStatus;
    });
  }, [drives, searchQuery, selectedMode, selectedStatus]);

  // Handle Add New Drive Submit
  const handleAddDriveSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newDriveForm.companyName.trim() || !newDriveForm.jobRole.trim()) return;

    const logoLetters = newDriveForm.companyName
      .split(" ")
      .map((w) => w[0])
      .join("")
      .toUpperCase()
      .slice(0, 2) || "CO";

    const colors = ["bg-[#4F46E5]", "bg-[#0EA5E9]", "bg-[#9333EA]", "bg-[#10B981]", "bg-[#F59E0B]"];
    const randomBg = colors[Math.floor(Math.random() * colors.length)];

    const createdDrive: CampusDriveItem = {
      id: `drive-${Date.now()}`,
      companyName: newDriveForm.companyName,
      logoText: logoLetters,
      logoBg: randomBg,
      jobRole: newDriveForm.jobRole,
      mode: newDriveForm.mode,
      eligibility: newDriveForm.eligibility,
      appliedCount: 0,
      capacityLimit: parseInt(newDriveForm.capacityLimit) || 200,
      deadlineDate: newDriveForm.deadlineDate || "30 Nov, 2023",
      stageStatus: "REGISTRATION OPEN",
      packageLPA: newDriveForm.packageLPA,
      location: newDriveForm.location,
      description: newDriveForm.description,
      registeredStudents: []
    };

    setDrives([createdDrive, ...drives]);
    setIsAddDriveOpen(false);
    showToast(`Placement Drive for ${createdDrive.companyName} (${createdDrive.jobRole}) scheduled successfully!`);

    // Reset Form
    setNewDriveForm({
      companyName: "",
      jobRole: "",
      mode: "Virtual",
      eligibility: "CGPA > 8.0",
      packageLPA: "18.0 LPA",
      location: "Bengaluru / Remote",
      capacityLimit: "250",
      deadlineDate: "15 Nov, 2023",
      description: "Role overview and candidate responsibilities..."
    });
  };

  // Export Applicants CSV
  const handleExportApplicants = (drive: CampusDriveItem) => {
    if (drive.registeredStudents.length === 0) {
      showToast(`No candidate applications registered for ${drive.companyName} yet.`);
      return;
    }

    const headers = ["Student ID", "Full Name", "Roll Number", "CGPA", "Department", "Shortlist Status"];
    const csvRows = drive.registeredStudents.map((s) => [
      `"${s.id}"`,
      `"${s.name}"`,
      `"${s.roll}"`,
      s.cgpa,
      `"${s.dept}"`,
      `"${s.status}"`
    ]);

    const csvContent = [headers.join(","), ...csvRows.map((e) => e.join(","))].join("\n");
    const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.setAttribute("href", url);
    link.setAttribute("download", `${drive.companyName}_Applicants_Roster.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

    showToast(`Exported applicant roster for ${drive.companyName} (${drive.registeredStudents.length} candidates).`);
  };

  return (
    <div className="space-y-6 pb-12">
      {/* Global Toast Notification */}
      {toastMessage && (
        <div className="fixed bottom-6 right-6 z-50 bg-slate-900 text-white text-xs font-semibold px-4 py-3 rounded-2xl shadow-2xl flex items-center gap-3 border border-slate-800 animate-bounce">
          <CheckCircle2 className="w-5 h-5 text-emerald-400 shrink-0" />
          <span>{toastMessage}</span>
          <button onClick={() => setToastMessage(null)} className="text-slate-400 hover:text-white ml-2">
            <X className="w-4 h-4" />
          </button>
        </div>
      )}

      {/* 1. Top Action Toolbar & Header */}
      <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl md:text-3xl font-extrabold text-slate-900 tracking-tight">
            Placement Management
          </h1>

          {/* Primary View Navigation Tabs */}
          <div className="flex items-center gap-6 mt-3 border-b border-slate-200/80">
            <button
              onClick={() => setActiveTab("active")}
              className={`pb-2.5 text-xs md:text-sm font-extrabold transition-all cursor-pointer relative ${
                activeTab === "active"
                  ? "text-[#7C3AED]"
                  : "text-slate-500 hover:text-slate-800"
              }`}
            >
              <span>Active Drives</span>
              {activeTab === "active" && (
                <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-[#7C3AED] rounded-full" />
              )}
            </button>

            <button
              onClick={() => setActiveTab("calendar")}
              className={`pb-2.5 text-xs md:text-sm font-extrabold transition-all cursor-pointer relative ${
                activeTab === "calendar"
                  ? "text-[#7C3AED]"
                  : "text-slate-500 hover:text-slate-800"
              }`}
            >
              <span>Drive Calendar</span>
              {activeTab === "calendar" && (
                <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-[#7C3AED] rounded-full" />
              )}
            </button>
          </div>
        </div>

        {/* Primary Header Controls */}
        <div className="flex items-center gap-3 flex-wrap">
          {/* Search Bar Input */}
          <div className="relative min-w-[220px] sm:min-w-[280px]">
            <Search className="w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search companies, roles, status..."
              className="w-full bg-white text-xs md:text-sm pl-10 pr-4 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-purple-500/30 transition-all placeholder:text-slate-400 shadow-2xs"
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

          {/* Filters Toggle Button */}
          <button
            onClick={() => setIsFilterPanelOpen(!isFilterPanelOpen)}
            className={`bg-white hover:bg-slate-50 text-slate-700 font-bold px-4 py-2.5 rounded-xl border border-slate-200 text-xs md:text-sm flex items-center gap-2 transition-all cursor-pointer shadow-2xs ${
              isFilterPanelOpen ? "ring-2 ring-purple-500/30 border-purple-300" : ""
            }`}
          >
            <SlidersHorizontal className="w-4 h-4 text-slate-600" />
            <span>Filters</span>
          </button>

          {/* + Add New Drive Action Button */}
          <button
            onClick={() => setIsAddDriveOpen(true)}
            className="bg-[#7C3AED] hover:bg-[#6B21A8] active:bg-purple-900 text-white font-bold px-4 py-2.5 rounded-xl shadow-md shadow-purple-500/20 text-xs md:text-sm flex items-center gap-2 transition-all cursor-pointer transform hover:-translate-y-0.5"
          >
            <Plus className="w-4 h-4 stroke-[2.5]" />
            <span>Add New Drive</span>
          </button>
        </div>
      </div>

      {/* Expandable Filter Panel */}
      {isFilterPanelOpen && (
        <div className="bg-white rounded-2xl p-4 border border-slate-200/80 shadow-xs flex flex-wrap items-center justify-between gap-4 animate-in fade-in duration-200">
          <div className="flex flex-wrap items-center gap-4">
            <div>
              <label className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block mb-1">
                Mode
              </label>
              <div className="flex items-center gap-1 bg-slate-100 p-1 rounded-xl">
                {(["All", "Virtual", "On-Campus"] as const).map((m) => (
                  <button
                    key={m}
                    onClick={() => setSelectedMode(m)}
                    className={`px-3 py-1 rounded-lg text-xs font-bold transition-all ${
                      selectedMode === m
                        ? "bg-white text-purple-700 shadow-2xs"
                        : "text-slate-600 hover:text-slate-900"
                    }`}
                  >
                    {m}
                  </button>
                ))}
              </div>
            </div>

            <div>
              <label className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block mb-1">
                Stage Status
              </label>
              <select
                value={selectedStatus}
                onChange={(e) => setSelectedStatus(e.target.value)}
                className="bg-slate-50 border border-slate-200 text-slate-800 font-bold text-xs p-2 rounded-xl outline-none focus:ring-2 focus:ring-purple-500/30"
              >
                <option value="All">All Stages</option>
                <option value="INTERVIEWING">Interviewing</option>
                <option value="REGISTRATION OPEN">Registration Open</option>
                <option value="TESTING STAGE">Testing Stage</option>
                <option value="OFFERS RELEASED">Offers Released</option>
              </select>
            </div>
          </div>

          <button
            onClick={() => {
              setSelectedMode("All");
              setSelectedStatus("All");
              setSearchQuery("");
              showToast("Filters reset to default.");
            }}
            className="text-xs font-bold text-purple-700 hover:underline"
          >
            Clear Filters
          </button>
        </div>
      )}

      {/* 2. Top Metric Cards Row & AI Insights */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-5">
        {/* Metric Card 1: TOTAL ACTIVE DRIVES */}
        <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-xs flex flex-col justify-between space-y-3">
          <span className="text-xs font-extrabold text-slate-400 uppercase tracking-wider">
            TOTAL ACTIVE DRIVES
          </span>
          <div className="flex items-baseline gap-3">
            <span className="text-3xl font-black text-slate-900 tracking-tight">12</span>
            <span className="text-xs font-extrabold text-emerald-600 flex items-center gap-1">
              <TrendingUp className="w-3.5 h-3.5" /> +3 this week
            </span>
          </div>
        </div>

        {/* Metric Card 2: STUDENTS PLACED */}
        <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-xs flex flex-col justify-between space-y-3">
          <span className="text-xs font-extrabold text-slate-400 uppercase tracking-wider">
            STUDENTS PLACED
          </span>
          <div className="flex items-baseline gap-3">
            <span className="text-3xl font-black text-purple-700 tracking-tight">342</span>
            <span className="text-xs font-extrabold text-slate-400">Goal: 500</span>
          </div>
        </div>

        {/* Metric Card 3: UPCOMING INTERVIEWS */}
        <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-xs flex flex-col justify-between space-y-3">
          <span className="text-xs font-extrabold text-slate-400 uppercase tracking-wider">
            UPCOMING INTERVIEWS
          </span>
          <div className="flex items-baseline gap-3">
            <span className="text-3xl font-black text-slate-900 tracking-tight">86</span>
            <span className="text-xs font-semibold text-slate-400">Next 48 hrs</span>
          </div>
        </div>

        {/* Metric Card 4: AI INSIGHTS CARD */}
        <div className="bg-[#F7F5FF] p-5 rounded-2xl border border-purple-200/70 shadow-xs flex flex-col justify-between space-y-2 relative overflow-hidden">
          <div className="flex items-center justify-between">
            <span className="text-[11px] font-black text-purple-700 uppercase tracking-wider flex items-center gap-1.5">
              <Sparkles className="w-4 h-4 text-purple-600 fill-purple-600" />
              AI INSIGHTS
            </span>
          </div>
          <p className="text-xs text-slate-700 font-medium leading-relaxed">
            3 students are eligible for all active drives but haven&apos;t applied yet.
          </p>
          <button
            onClick={() => showToast("Broadcast notifications dispatched to 3 eligible candidates!")}
            className="text-xs font-extrabold text-purple-700 hover:text-purple-900 flex items-center gap-1 transition-colors pt-1 cursor-pointer"
          >
            <span>Notify Students</span>
            <span>➔</span>
          </button>
        </div>
      </div>

      {/* 3. Main Content: Active Drives List OR Drive Calendar View */}
      {activeTab === "active" ? (
        /* CAMPUS DRIVE CARDS LIST */
        <div className="space-y-4">
          {filteredDrives.length > 0 ? (
            filteredDrives.map((drive) => {
              // Status Badge color mapping
              const statusBadgeStyle =
                drive.stageStatus === "INTERVIEWING"
                  ? "bg-[#D1FAE5] text-[#10B981]"
                  : drive.stageStatus === "REGISTRATION OPEN"
                  ? "bg-[#DBEAFE] text-[#2563EB]"
                  : drive.stageStatus === "TESTING STAGE"
                  ? "bg-[#FEF3C7] text-[#D97706]"
                  : "bg-purple-100 text-purple-700";

              return (
                <div
                  key={drive.id}
                  onClick={() => setSelectedDriveDetail(drive)}
                  className="bg-white rounded-2xl border border-slate-100 shadow-xs hover:shadow-md transition-all p-5 flex flex-col lg:flex-row lg:items-center justify-between gap-4 cursor-pointer group"
                >
                  {/* Left: Company Identity */}
                  <div className="flex items-center gap-4 min-w-[260px]">
                    <div
                      className={`w-12 h-12 rounded-2xl ${drive.logoBg} text-white font-black text-base flex items-center justify-center shadow-xs shrink-0`}
                    >
                      {drive.logoText}
                    </div>
                    <div>
                      <h3 className="text-base font-extrabold text-slate-900 group-hover:text-purple-700 transition-colors leading-tight">
                        {drive.companyName}
                      </h3>
                      <div className="flex items-center gap-2 mt-1">
                        <span className="text-xs font-semibold text-slate-500">
                          {drive.jobRole}
                        </span>
                        <span className="text-slate-300">•</span>
                        {/* Mode Pill */}
                        <span
                          className={`text-[11px] font-bold px-2.5 py-0.5 rounded-full flex items-center gap-1 ${
                            drive.mode === "Virtual"
                              ? "bg-purple-100 text-purple-700"
                              : "bg-slate-100 text-slate-700"
                          }`}
                        >
                          {drive.mode === "Virtual" ? (
                            <>
                              <Video className="w-3 h-3 text-purple-600" /> Virtual
                            </>
                          ) : (
                            <>
                              <Building2 className="w-3 h-3 text-slate-600" /> On-Campus
                            </>
                          )}
                        </span>
                      </div>
                    </div>
                  </div>

                  {/* Middle Column 1: Eligibility Metric */}
                  <div className="flex flex-col lg:items-start min-w-[120px]">
                    <span className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider">
                      ELIGIBILITY
                    </span>
                    <span className="text-xs font-extrabold text-slate-800 mt-1">
                      {drive.eligibility}
                    </span>
                  </div>

                  {/* Middle Column 2: Applicants Tracker */}
                  <div className="flex flex-col lg:items-start min-w-[120px]">
                    <span className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider">
                      APPLICANTS
                    </span>
                    <span className="text-xs font-extrabold text-slate-800 mt-1">
                      {drive.appliedCount} / {drive.capacityLimit}
                    </span>
                  </div>

                  {/* Middle Column 3: Deadline Date */}
                  <div className="flex flex-col lg:items-start min-w-[120px]">
                    <span className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider">
                      DEADLINE
                    </span>
                    <span
                      className={`text-xs font-extrabold mt-1 ${
                        drive.isUrgentDeadline ? "text-rose-600 font-extrabold" : "text-slate-800"
                      }`}
                    >
                      {drive.deadlineDate}
                    </span>
                  </div>

                  {/* Right: Stage Status Pill & Interactive Chevron */}
                  <div className="flex items-center gap-4 justify-between lg:justify-end">
                    <span
                      className={`font-black text-[11px] uppercase tracking-wider px-3.5 py-1.5 rounded-full ${statusBadgeStyle}`}
                    >
                      {drive.stageStatus}
                    </span>

                    <ChevronRight className="w-5 h-5 text-slate-300 group-hover:text-purple-600 group-hover:translate-x-1 transition-all" />
                  </div>
                </div>
              );
            })
          ) : (
            <div className="bg-white p-12 rounded-2xl border border-slate-100 text-center space-y-3">
              <AlertCircle className="w-10 h-10 text-slate-300 mx-auto" />
              <h3 className="text-base font-bold text-slate-800">No Placement Drives Found</h3>
              <p className="text-xs text-slate-500 max-w-sm mx-auto">
                No active recruitment drives match your current search query or filter options.
              </p>
              <button
                onClick={() => {
                  setSearchQuery("");
                  setSelectedMode("All");
                  setSelectedStatus("All");
                }}
                className="bg-purple-50 text-purple-700 hover:bg-purple-100 text-xs font-bold px-4 py-2 rounded-xl transition-colors inline-block"
              >
                Clear All Search &amp; Filters
              </button>
            </div>
          )}
        </div>
      ) : (
        /* DRIVE CALENDAR VIEW */
        <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-xs space-y-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <CalendarIcon className="w-5 h-5 text-purple-600" />
              <h3 className="text-base font-extrabold text-slate-900">October - November 2023 Drive Schedule</h3>
            </div>
            <span className="text-xs font-bold text-purple-700 bg-purple-50 px-3 py-1 rounded-full border border-purple-200">
              5 Events Scheduled
            </span>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            {drives.map((d) => (
              <div
                key={d.id}
                onClick={() => setSelectedDriveDetail(d)}
                className="p-4 rounded-xl border border-slate-200/80 bg-slate-50 hover:bg-purple-50/50 hover:border-purple-200 transition-all cursor-pointer space-y-3"
              >
                <div className="flex items-center justify-between">
                  <span className="text-xs font-black text-purple-700">{d.deadlineDate}</span>
                  <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-white text-slate-600 border border-slate-200">
                    {d.mode}
                  </span>
                </div>
                <div>
                  <h4 className="text-sm font-extrabold text-slate-900">{d.companyName}</h4>
                  <p className="text-xs font-semibold text-slate-500">{d.jobRole}</p>
                </div>
                <div className="text-[11px] font-bold text-slate-600 flex items-center justify-between border-t border-slate-200/60 pt-2">
                  <span>Package: {d.packageLPA}</span>
                  <span className="text-purple-600">Details ➔</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* MODAL: + Add New Drive Wizard */}
      {isAddDriveOpen && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl space-y-5 animate-in zoom-in-95 duration-200">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-xl bg-purple-100 text-purple-700 flex items-center justify-center font-bold">
                  +
                </div>
                <h3 className="text-lg font-extrabold text-slate-900">Schedule New Recruitment Drive</h3>
              </div>
              <button
                onClick={() => setIsAddDriveOpen(false)}
                className="text-slate-400 hover:text-slate-600 p-1"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleAddDriveSubmit} className="space-y-4 text-xs font-medium">
              <div>
                <label className="font-bold text-slate-700 block mb-1">Company Name</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Nexus Systems / Stripe APAC"
                  value={newDriveForm.companyName}
                  onChange={(e) => setNewDriveForm({ ...newDriveForm, companyName: e.target.value })}
                  className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Job Role</label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. Senior Software Engineer"
                    value={newDriveForm.jobRole}
                    onChange={(e) => setNewDriveForm({ ...newDriveForm, jobRole: e.target.value })}
                    className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                  />
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Package (LPA)</label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. 18.5 LPA"
                    value={newDriveForm.packageLPA}
                    onChange={(e) => setNewDriveForm({ ...newDriveForm, packageLPA: e.target.value })}
                    className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Drive Mode</label>
                  <select
                    value={newDriveForm.mode}
                    onChange={(e) =>
                      setNewDriveForm({
                        ...newDriveForm,
                        mode: e.target.value as "Virtual" | "On-Campus"
                      })
                    }
                    className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                  >
                    <option value="Virtual">Virtual</option>
                    <option value="On-Campus">On-Campus</option>
                  </select>
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Eligibility Criteria</label>
                  <input
                    type="text"
                    placeholder="e.g. CGPA > 8.5"
                    value={newDriveForm.eligibility}
                    onChange={(e) => setNewDriveForm({ ...newDriveForm, eligibility: e.target.value })}
                    className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Application Deadline</label>
                  <input
                    type="text"
                    placeholder="e.g. 30 Oct, 2023"
                    value={newDriveForm.deadlineDate}
                    onChange={(e) => setNewDriveForm({ ...newDriveForm, deadlineDate: e.target.value })}
                    className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                  />
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Capacity / Applicant Limit</label>
                  <input
                    type="number"
                    placeholder="250"
                    value={newDriveForm.capacityLimit}
                    onChange={(e) => setNewDriveForm({ ...newDriveForm, capacityLimit: e.target.value })}
                    className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                  />
                </div>
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Location & Work Mode</label>
                <input
                  type="text"
                  placeholder="e.g. Bengaluru / Remote"
                  value={newDriveForm.location}
                  onChange={(e) => setNewDriveForm({ ...newDriveForm, location: e.target.value })}
                  className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                />
              </div>

              <div className="flex items-center justify-end gap-3 pt-4 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setIsAddDriveOpen(false)}
                  className="px-4 py-2.5 text-slate-600 font-bold hover:bg-slate-100 rounded-xl"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="bg-[#7C3AED] hover:bg-[#6B21A8] text-white font-bold px-5 py-2.5 rounded-xl shadow-md shadow-purple-500/20"
                >
                  Create Drive
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* DRAWER: Drive Details Slide-Over Drawer */}
      {selectedDriveDetail && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-end">
          <div className="bg-white h-full max-w-xl w-full p-6 shadow-2xl overflow-y-auto space-y-6 animate-in slide-in-from-right duration-300">
            <div className="flex items-center justify-between border-b border-slate-100 pb-4">
              <div className="flex items-center gap-3">
                <div className={`w-10 h-10 rounded-xl ${selectedDriveDetail.logoBg} text-white font-black text-sm flex items-center justify-center`}>
                  {selectedDriveDetail.logoText}
                </div>
                <div>
                  <h2 className="text-lg font-black text-slate-900">{selectedDriveDetail.companyName}</h2>
                  <p className="text-xs font-semibold text-purple-700">{selectedDriveDetail.jobRole}</p>
                </div>
              </div>
              <button
                onClick={() => setSelectedDriveDetail(null)}
                className="text-slate-400 hover:text-slate-600 p-1"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Quick Badges */}
            <div className="grid grid-cols-3 gap-3 text-center">
              <div className="bg-slate-50 p-3 rounded-xl border border-slate-100">
                <span className="text-[10px] font-bold text-slate-400 uppercase block">PACKAGE</span>
                <span className="text-xs font-black text-slate-900">{selectedDriveDetail.packageLPA}</span>
              </div>
              <div className="bg-slate-50 p-3 rounded-xl border border-slate-100">
                <span className="text-[10px] font-bold text-slate-400 uppercase block">MODE</span>
                <span className="text-xs font-black text-slate-900">{selectedDriveDetail.mode}</span>
              </div>
              <div className="bg-slate-50 p-3 rounded-xl border border-slate-100">
                <span className="text-[10px] font-bold text-slate-400 uppercase block">DEADLINE</span>
                <span className="text-xs font-black text-rose-600">{selectedDriveDetail.deadlineDate}</span>
              </div>
            </div>

            {/* Overview Description */}
            <div className="space-y-2">
              <h4 className="text-xs font-extrabold text-slate-400 uppercase tracking-wider">ROLE DESCRIPTION</h4>
              <p className="text-xs text-slate-700 leading-relaxed font-medium bg-slate-50 p-3.5 rounded-xl border border-slate-100">
                {selectedDriveDetail.description}
              </p>
            </div>

            {/* Registered Applicants Table */}
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <h4 className="text-xs font-extrabold text-slate-400 uppercase tracking-wider">
                  REGISTERED CANDIDATES ({selectedDriveDetail.registeredStudents.length})
                </h4>
                <button
                  onClick={() => handleExportApplicants(selectedDriveDetail)}
                  className="text-xs font-bold text-purple-700 hover:underline flex items-center gap-1"
                >
                  <Download className="w-3.5 h-3.5" /> Export Roster
                </button>
              </div>

              {selectedDriveDetail.registeredStudents.length > 0 ? (
                <div className="bg-white rounded-xl border border-slate-200 overflow-hidden text-xs">
                  <table className="w-full text-left border-collapse">
                    <thead>
                      <tr className="bg-slate-50 border-b border-slate-100 text-[10px] font-bold text-slate-400 uppercase">
                        <th className="py-2.5 px-3">Candidate</th>
                        <th className="py-2.5 px-3">CGPA</th>
                        <th className="py-2.5 px-3">Status</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-100 font-medium">
                      {selectedDriveDetail.registeredStudents.map((s) => (
                        <tr key={s.id}>
                          <td className="py-2.5 px-3">
                            <div className="font-extrabold text-slate-900">{s.name}</div>
                            <div className="text-[10px] text-slate-400">{s.roll}</div>
                          </td>
                          <td className="py-2.5 px-3 font-bold">{s.cgpa.toFixed(2)}</td>
                          <td className="py-2.5 px-3">
                            <span
                              className={`text-[10px] font-bold px-2 py-0.5 rounded-full ${
                                s.status === "Shortlisted"
                                  ? "bg-emerald-100 text-emerald-700"
                                  : "bg-slate-100 text-slate-600"
                              }`}
                            >
                              {s.status}
                            </span>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              ) : (
                <p className="text-xs text-slate-400 font-medium py-4 text-center bg-slate-50 rounded-xl">
                  No candidate applications recorded yet for this drive.
                </p>
              )}
            </div>

            {/* Footer Action Buttons */}
            <div className="pt-4 border-t border-slate-100 flex items-center gap-3">
              <button
                onClick={() => {
                  showToast(`Broadcast update sent to applicants of ${selectedDriveDetail.companyName}!`);
                }}
                className="flex-1 bg-purple-50 hover:bg-purple-100 text-purple-700 font-bold py-2.5 rounded-xl text-xs flex items-center justify-center gap-1.5 border border-purple-200"
              >
                <Send className="w-3.5 h-3.5" /> Broadcast Update
              </button>
              <button
                onClick={() => handleExportApplicants(selectedDriveDetail)}
                className="flex-1 bg-purple-600 hover:bg-purple-700 text-white font-bold py-2.5 rounded-xl text-xs flex items-center justify-center gap-1.5 shadow-md"
              >
                <Download className="w-3.5 h-3.5" /> Export Data
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default PlacementManagementView;
export const PlacementCellView = PlacementManagementView;
