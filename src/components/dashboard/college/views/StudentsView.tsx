import React, { useState, useMemo } from "react";
import {
  Search,
  SlidersHorizontal,
  RotateCcw,
  Sparkles,
  X,
  FileText,
  AlertTriangle,
  Flame,
  Moon,
  Mail,
  Download,
  UserCheck,
  CheckCircle2
} from "lucide-react";

export interface StudentRecord {
  id: string;
  studentIdTag: string;
  name: string;
  avatar: string;
  department: string;
  yearBatch: string;
  batchYear: string; // e.g. "2024 - 2025"
  readinessScore: number;
  codingStreak: number;
  resumeStatus: "VERIFIED" | "MISSING" | "DRAFT";
  placementStatus: "PLACED" | "UNPLACED" | "IN INTERVIEW";
  skills: string[];
  email: string;
  phone: string;
  gpa: number;
  leetcodeCount: number;
  githubCommits: number;
  companyTarget?: string;
}

const MOCK_STUDENTS: StudentRecord[] = [
  {
    id: "stu-1",
    studentIdTag: "ID: C2C-2024-8821",
    name: "Arjun Mehta",
    avatar: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200",
    department: "Comp. Science",
    yearBatch: "Final Year • Batch A",
    batchYear: "2024 - 2025",
    readinessScore: 92,
    codingStreak: 14,
    resumeStatus: "VERIFIED",
    placementStatus: "PLACED",
    skills: ["Python", "DSA", "React", "Node.js"],
    email: "arjun.m@apex.edu",
    phone: "+91 98765 43210",
    gpa: 9.1,
    leetcodeCount: 340,
    githubCommits: 410,
    companyTarget: "Stripe Tech"
  },
  {
    id: "stu-2",
    studentIdTag: "ID: C2C-2024-9104",
    name: "Sara Khan",
    avatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200",
    department: "Information Tech",
    yearBatch: "Final Year • Batch C",
    batchYear: "2024 - 2025",
    readinessScore: 64,
    codingStreak: 0,
    resumeStatus: "MISSING",
    placementStatus: "UNPLACED",
    skills: ["Java", "SQL", "HTML/CSS"],
    email: "sara.k@apex.edu",
    phone: "+91 98123 45678",
    gpa: 7.8,
    leetcodeCount: 120,
    githubCommits: 85
  },
  {
    id: "stu-3",
    studentIdTag: "ID: C2C-2024-7742",
    name: "Leo George",
    avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200",
    department: "Electronics",
    yearBatch: "Third Year • Batch B",
    batchYear: "2024 - 2025",
    readinessScore: 81,
    codingStreak: 28,
    resumeStatus: "DRAFT",
    placementStatus: "IN INTERVIEW",
    skills: ["C++", "VLSI", "Embedded Systems", "Python"],
    email: "leo.g@apex.edu",
    phone: "+91 97654 32109",
    gpa: 8.5,
    leetcodeCount: 280,
    githubCommits: 290,
    companyTarget: "Aether Commerce"
  },
  {
    id: "stu-4",
    studentIdTag: "ID: C2C-2024-6612",
    name: "Neha Gupta",
    avatar: "https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&q=80&w=200",
    department: "Comp. Science",
    yearBatch: "Final Year • Batch A",
    batchYear: "2024 - 2025",
    readinessScore: 95,
    codingStreak: 42,
    resumeStatus: "VERIFIED",
    placementStatus: "PLACED",
    skills: ["Python", "Machine Learning", "PyTorch", "System Design"],
    email: "neha.g@apex.edu",
    phone: "+91 98989 12345",
    gpa: 9.4,
    leetcodeCount: 450,
    githubCommits: 620,
    companyTarget: "Google APAC"
  },
  {
    id: "stu-5",
    studentIdTag: "ID: C2C-2024-5541",
    name: "Rohan Verma",
    avatar: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=200",
    department: "Information Tech",
    yearBatch: "Final Year • Batch B",
    batchYear: "2024 - 2025",
    readinessScore: 78,
    codingStreak: 7,
    resumeStatus: "VERIFIED",
    placementStatus: "IN INTERVIEW",
    skills: ["JavaScript", "React", "AWS", "Docker"],
    email: "rohan.v@apex.edu",
    phone: "+91 91234 56789",
    gpa: 8.2,
    leetcodeCount: 190,
    githubCommits: 210,
    companyTarget: "Nexus Finance"
  },
  {
    id: "stu-6",
    studentIdTag: "ID: C2C-2024-4422",
    name: "Aarav Sharma",
    avatar: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=200",
    department: "Electronics",
    yearBatch: "Final Year • Batch C",
    batchYear: "2024 - 2025",
    readinessScore: 45,
    codingStreak: 0,
    resumeStatus: "MISSING",
    placementStatus: "UNPLACED",
    skills: ["C", "MATLAB", "Microcontrollers"],
    email: "aarav.s@apex.edu",
    phone: "+91 98000 11122",
    gpa: 6.8,
    leetcodeCount: 45,
    githubCommits: 30
  },
  {
    id: "stu-7",
    studentIdTag: "ID: C2C-2025-3319",
    name: "Ananya Patel",
    avatar: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=200",
    department: "Comp. Science",
    yearBatch: "Third Year • Batch A",
    batchYear: "2025 - 2026",
    readinessScore: 89,
    codingStreak: 18,
    resumeStatus: "VERIFIED",
    placementStatus: "PLACED",
    skills: ["Java", "Spring Boot", "PostgreSQL", "System Design"],
    email: "ananya.p@apex.edu",
    phone: "+91 97111 22233",
    gpa: 9.0,
    leetcodeCount: 310,
    githubCommits: 380,
    companyTarget: "Microsoft"
  },
  {
    id: "stu-8",
    studentIdTag: "ID: C2C-2025-2210",
    name: "Vikram Desai",
    avatar: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&q=80&w=200",
    department: "Information Tech",
    yearBatch: "Third Year • Batch B",
    batchYear: "2025 - 2026",
    readinessScore: 52,
    codingStreak: 3,
    resumeStatus: "DRAFT",
    placementStatus: "UNPLACED",
    skills: ["HTML/CSS", "JavaScript", "PHP"],
    email: "vikram.d@apex.edu",
    phone: "+91 96555 44433",
    gpa: 7.2,
    leetcodeCount: 80,
    githubCommits: 65
  }
];

export const StudentsView: React.FC = () => {
  // Search & Filter State
  const [searchTerm, setSearchTerm] = useState("");
  const [batchFilter, setBatchFilter] = useState("2024 - 2025");
  const [deptFilter, setDeptFilter] = useState("All Departments");
  const [readinessFilter, setReadinessFilter] = useState("Any Score");
  const [resumeFilter, setResumeFilter] = useState("All");
  const [statusFilter, setStatusFilter] = useState("All");

  // Pagination State
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 3;

  // Selection State
  const [selectedIds, setSelectedIds] = useState<string[]>([]);

  // Drawer & Modal State
  const [isAiModalOpen, setIsAiModalOpen] = useState(false);
  const [isFilterDrawerOpen, setIsFilterDrawerOpen] = useState(false);
  const [activeStudentDetail, setActiveStudentDetail] = useState<StudentRecord | null>(null);
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 3500);
  };

  // Reset Filters
  const handleResetFilters = () => {
    setSearchTerm("");
    setBatchFilter("2024 - 2025");
    setDeptFilter("All Departments");
    setReadinessFilter("Any Score");
    setResumeFilter("All");
    setStatusFilter("All");
    setCurrentPage(1);
    showToast("Filters reset to default.");
  };

  // Filter Logic
  const filteredStudents = useMemo(() => {
    return MOCK_STUDENTS.filter((st) => {
      // Search
      const matchesSearch =
        st.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        st.studentIdTag.toLowerCase().includes(searchTerm.toLowerCase()) ||
        st.skills.some((s) => s.toLowerCase().includes(searchTerm.toLowerCase()));

      // Batch
      const matchesBatch =
        batchFilter === "All Batches" || st.batchYear === batchFilter;

      // Department
      const matchesDept =
        deptFilter === "All Departments" || st.department === deptFilter;

      // Readiness Score
      let matchesReadiness = true;
      if (readinessFilter === "High Readiness (80%+)") matchesReadiness = st.readinessScore >= 80;
      else if (readinessFilter === "Medium (50-79%)") matchesReadiness = st.readinessScore >= 50 && st.readinessScore < 80;
      else if (readinessFilter === "At Risk (<50%)") matchesReadiness = st.readinessScore < 50;

      // Resume Filter
      const matchesResume = resumeFilter === "All" || st.resumeStatus === resumeFilter;

      // Placement Status Filter
      const matchesStatus = statusFilter === "All" || st.placementStatus === statusFilter;

      return matchesSearch && matchesBatch && matchesDept && matchesReadiness && matchesResume && matchesStatus;
    });
  }, [searchTerm, batchFilter, deptFilter, readinessFilter, resumeFilter, statusFilter]);

  // Paginated Students
  const totalPages = Math.ceil(filteredStudents.length / itemsPerPage) || 1;
  const paginatedStudents = useMemo(() => {
    const start = (currentPage - 1) * itemsPerPage;
    return filteredStudents.slice(start, start + itemsPerPage);
  }, [filteredStudents, currentPage]);

  // Checkbox handlers
  const handleSelectAll = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.checked) {
      const allPageIds = paginatedStudents.map((s) => s.id);
      setSelectedIds(Array.from(new Set([...selectedIds, ...allPageIds])));
    } else {
      const pageIdSet = new Set(paginatedStudents.map((s) => s.id));
      setSelectedIds(selectedIds.filter((id) => !pageIdSet.has(id)));
    }
  };

  const handleSelectRow = (id: string) => {
    if (selectedIds.includes(id)) {
      setSelectedIds(selectedIds.filter((i) => i !== id));
    } else {
      setSelectedIds([...selectedIds, id]);
    }
  };

  const isAllPageSelected =
    paginatedStudents.length > 0 &&
    paginatedStudents.every((s) => selectedIds.includes(s.id));

  return (
    <div className="space-y-6 pb-8">
      {/* Toast Notification */}
      {toastMessage && (
        <div className="fixed bottom-6 right-6 z-50 bg-slate-900 text-white text-xs font-bold px-4 py-3 rounded-2xl shadow-2xl flex items-center gap-2 border border-slate-800 animate-bounce">
          <CheckCircle2 className="w-4 h-4 text-emerald-400" />
          <span>{toastMessage}</span>
        </div>
      )}

      {/* Top Header & AI Candidate Highlight Banner Container */}
      <div className="flex flex-col xl:flex-row xl:items-start justify-between gap-6">
        {/* Left Title & Subtitle */}
        <div className="max-w-2xl">
          <h1 className="text-2xl md:text-3xl font-extrabold text-slate-900 tracking-tight">
            Student Directory
          </h1>
          <p className="text-xs md:text-sm text-slate-500 font-medium mt-1.5 leading-relaxed">
            {"Manage and monitor the career readiness of the 2024-25 graduating batch. Use AI-driven insights to identify top talent and students needing intervention."}
          </p>
        </div>

        {/* Right: AI Candidate Highlight Card (Matching image_08e69e.png) */}
        <div
          onClick={() => setIsAiModalOpen(true)}
          className="bg-gradient-to-r from-purple-50/90 via-purple-50/50 to-white p-4 md:p-5 rounded-2xl border border-purple-200/80 shadow-xs shadow-purple-500/10 hover:shadow-md transition-all cursor-pointer group relative overflow-hidden max-w-lg w-full"
        >
          {/* Top Row: Title + BETA Badge */}
          <div className="flex items-center justify-between mb-3">
            <div className="flex items-center gap-1.5">
              <Sparkles className="w-4 h-4 text-purple-600 fill-purple-600" />
              <span className="text-xs font-extrabold text-purple-700 tracking-wider uppercase">
                AI CANDIDATE HIGHLIGHT
              </span>
            </div>
            <span className="text-[10px] font-extrabold px-2 py-0.5 rounded-full bg-purple-100/90 text-purple-700 uppercase tracking-widest">
              BETA
            </span>
          </div>

          {/* Middle Row: Candidate Profile Info + Match Score */}
          <div className="flex items-center justify-between gap-4">
            <div className="flex items-center gap-3">
              <img
                src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200"
                alt="Priya Sharma"
                className="w-11 h-11 rounded-xl object-cover border-2 border-purple-300 shadow-sm"
              />
              <div>
                <h3 className="text-sm font-extrabold text-slate-900 group-hover:text-purple-700 transition-colors">
                  Priya Sharma
                </h3>
                <p className="text-[11px] font-medium text-slate-500">
                  Ready for Google, Stripe, Meta
                </p>
              </div>
            </div>

            <div className="text-right">
              <div className="text-xl md:text-2xl font-black text-purple-700 tracking-tight leading-none">
                98%
              </div>
              <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">
                MATCH
              </span>
            </div>
          </div>

          {/* Bottom Row: Skill Badges */}
          <div className="flex flex-wrap items-center gap-2 mt-3.5 pt-3 border-t border-purple-100/80">
            <span className="text-[10px] font-bold bg-slate-200/80 text-slate-700 px-2.5 py-1 rounded-md">
              Python Expert
            </span>
            <span className="text-[10px] font-bold bg-slate-200/80 text-slate-700 px-2.5 py-1 rounded-md">
              300+ LeetCode
            </span>
            <span className="text-[10px] font-bold bg-slate-200/80 text-slate-700 px-2.5 py-1 rounded-md">
              4 Internships
            </span>
          </div>
        </div>
      </div>

      {/* Dynamic Filter Control Toolbar (Matching image_08e69e.png) */}
      <div className="bg-white p-4 rounded-2xl border border-slate-100 shadow-xs space-y-4">
        {/* Global Search Bar */}
        <div className="relative w-full">
          <Search className="w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
          <input
            type="text"
            value={searchTerm}
            onChange={(e) => {
              setSearchTerm(e.target.value);
              setCurrentPage(1);
            }}
            placeholder="Search students, skills, or records..."
            className="w-full bg-slate-100/70 hover:bg-slate-100 focus:bg-white text-xs md:text-sm pl-10 pr-4 py-2.5 rounded-xl border border-slate-200/70 focus:outline-none focus:ring-2 focus:ring-purple-500/30 transition-all placeholder:text-slate-400"
          />
          {searchTerm && (
            <button
              onClick={() => setSearchTerm("")}
              className="absolute right-3.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 text-xs"
            >
              ✕
            </button>
          )}
        </div>

        {/* Dropdown Filters Row */}
        <div className="flex flex-wrap items-end gap-3 justify-between">
          <div className="flex flex-wrap items-center gap-3 flex-1">
            {/* Batch Selector */}
            <div className="flex-1 min-w-[140px] max-w-[180px]">
              <label className="text-[11px] font-bold text-slate-400 block mb-1.5">
                Batch
              </label>
              <select
                value={batchFilter}
                onChange={(e) => {
                  setBatchFilter(e.target.value);
                  setCurrentPage(1);
                }}
                className="w-full bg-slate-100/80 hover:bg-slate-100 text-slate-700 font-semibold text-xs py-2.5 px-3 rounded-xl border border-slate-200/80 focus:outline-none focus:ring-2 focus:ring-purple-500/30 cursor-pointer"
              >
                <option value="2024 - 2025">2024 - 2025</option>
                <option value="2025 - 2026">2025 - 2026</option>
                <option value="All Batches">All Batches</option>
              </select>
            </div>

            {/* Department Selector */}
            <div className="flex-1 min-w-[160px] max-w-[210px]">
              <label className="text-[11px] font-bold text-slate-400 block mb-1.5">
                Department
              </label>
              <select
                value={deptFilter}
                onChange={(e) => {
                  setDeptFilter(e.target.value);
                  setCurrentPage(1);
                }}
                className="w-full bg-slate-100/80 hover:bg-slate-100 text-slate-700 font-semibold text-xs py-2.5 px-3 rounded-xl border border-slate-200/80 focus:outline-none focus:ring-2 focus:ring-purple-500/30 cursor-pointer"
              >
                <option value="All Departments">All Departments</option>
                <option value="Comp. Science">Comp. Science</option>
                <option value="Information Tech">Information Tech</option>
                <option value="Electronics">Electronics</option>
              </select>
            </div>

            {/* Readiness Score Selector */}
            <div className="flex-1 min-w-[160px] max-w-[210px]">
              <label className="text-[11px] font-bold text-slate-400 block mb-1.5">
                Readiness Score
              </label>
              <select
                value={readinessFilter}
                onChange={(e) => {
                  setReadinessFilter(e.target.value);
                  setCurrentPage(1);
                }}
                className="w-full bg-slate-100/80 hover:bg-slate-100 text-slate-700 font-semibold text-xs py-2.5 px-3 rounded-xl border border-slate-200/80 focus:outline-none focus:ring-2 focus:ring-purple-500/30 cursor-pointer"
              >
                <option value="Any Score">Any Score</option>
                <option value="High Readiness (80%+)">High Readiness (80%+)</option>
                <option value="Medium (50-79%)">Medium (50-79%)</option>
                <option value="At Risk (<50%)">At Risk (&lt;50%)</option>
              </select>
            </div>
          </div>

          {/* Action Buttons: More Filters & Reset */}
          <div className="flex items-center gap-2">
            <button
              onClick={() => setIsFilterDrawerOpen(true)}
              className="bg-slate-100/80 hover:bg-slate-200 text-slate-700 font-bold text-xs py-2.5 px-4 rounded-xl border border-slate-200/80 flex items-center gap-2 transition-colors cursor-pointer"
            >
              <SlidersHorizontal className="w-3.5 h-3.5 text-slate-600" />
              <span>More Filters</span>
            </button>

            <button
              onClick={handleResetFilters}
              title="Reset all filters"
              className="w-9 h-9 rounded-xl bg-purple-50 hover:bg-purple-100 text-purple-700 border border-purple-200/80 flex items-center justify-center transition-all cursor-pointer"
            >
              <RotateCcw className="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>

      {/* Floating Bulk Actions Toolbar */}
      {selectedIds.length > 0 && (
        <div className="bg-purple-900 text-white px-5 py-3 rounded-2xl shadow-xl flex items-center justify-between text-xs font-semibold animate-fade-in">
          <div className="flex items-center gap-3">
            <span className="bg-purple-700 px-2.5 py-1 rounded-lg text-white font-extrabold text-[11px]">
              {selectedIds.length} Selected
            </span>
            <span>Perform bulk operation on candidate records</span>
          </div>

          <div className="flex items-center gap-2">
            <button
              onClick={() => {
                showToast(`Exported ${selectedIds.length} candidate profiles to CSV.`);
                setSelectedIds([]);
              }}
              className="bg-white text-purple-900 hover:bg-purple-50 px-3 py-1.5 rounded-xl font-bold transition-all flex items-center gap-1.5"
            >
              <Download className="w-3.5 h-3.5" /> Export Selected
            </button>

            <button
              onClick={() => {
                showToast(`Broadcast email sent to ${selectedIds.length} candidates.`);
                setSelectedIds([]);
              }}
              className="bg-purple-700 hover:bg-purple-600 text-white px-3 py-1.5 rounded-xl font-bold transition-all flex items-center gap-1.5"
            >
              <Mail className="w-3.5 h-3.5" /> Send Email
            </button>

            <button
              onClick={() => setSelectedIds([])}
              className="text-purple-300 hover:text-white px-2 py-1"
            >
              Cancel
            </button>
          </div>
        </div>
      )}

      {/* Student Management Data Table */}
      <div className="bg-white rounded-2xl border border-slate-100 shadow-xs overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-slate-50/70 border-b border-slate-100 text-[11px] font-bold text-slate-400 uppercase tracking-wider">
                <th className="py-4 px-4 w-10 text-center">
                  <input
                    type="checkbox"
                    checked={isAllPageSelected}
                    onChange={handleSelectAll}
                    className="w-4 h-4 accent-purple-600 rounded cursor-pointer"
                  />
                </th>
                <th className="py-4 px-4 font-bold">STUDENT NAME</th>
                <th className="py-4 px-4 font-bold">DEPT &amp; YEAR</th>
                <th className="py-4 px-4 font-bold text-center">READINESS</th>
                <th className="py-4 px-4 font-bold text-center">CODING STREAK</th>
                <th className="py-4 px-4 font-bold text-center">RESUME</th>
                <th className="py-4 px-4 font-bold text-right pr-6">STATUS</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-xs font-medium">
              {paginatedStudents.length > 0 ? (
                paginatedStudents.map((st) => {
                  const isSelected = selectedIds.includes(st.id);

                  return (
                    <tr
                      key={st.id}
                      className={`hover:bg-purple-50/40 transition-colors cursor-pointer ${
                        isSelected ? "bg-purple-50/60" : ""
                      }`}
                      onClick={() => setActiveStudentDetail(st)}
                    >
                      {/* Checkbox Column */}
                      <td
                        className="py-4 px-4 text-center"
                        onClick={(e) => e.stopPropagation()}
                      >
                        <input
                          type="checkbox"
                          checked={isSelected}
                          onChange={() => handleSelectRow(st.id)}
                          className="w-4 h-4 accent-purple-600 rounded cursor-pointer"
                        />
                      </td>

                      {/* Student Name & Avatar */}
                      <td className="py-4 px-4">
                        <div className="flex items-center gap-3">
                          <img
                            src={st.avatar}
                            alt={st.name}
                            className="w-9 h-9 rounded-xl object-cover border border-slate-200 shadow-xs"
                          />
                          <div>
                            <div className="font-extrabold text-slate-900 text-sm hover:text-purple-700 transition-colors">
                              {st.name}
                            </div>
                            <div className="text-[10px] text-slate-400 font-mono font-medium mt-0.5">
                              {st.studentIdTag}
                            </div>
                          </div>
                        </div>
                      </td>

                      {/* Dept & Year */}
                      <td className="py-4 px-4">
                        <div className="font-bold text-slate-800 text-xs">
                          {st.department}
                        </div>
                        <div className="text-[10px] text-slate-400 font-normal mt-0.5">
                          {st.yearBatch}
                        </div>
                      </td>

                      {/* Readiness Circular Ring Gauge */}
                      <td className="py-4 px-4 text-center">
                        <div className="inline-flex items-center justify-center relative w-10 h-10">
                          <svg className="w-10 h-10 transform -rotate-90">
                            <circle
                              cx="20"
                              cy="20"
                              r="15"
                              stroke="#F1F5F9"
                              strokeWidth="3.5"
                              fill="transparent"
                            />
                            <circle
                              cx="20"
                              cy="20"
                              r="15"
                              stroke={
                                st.readinessScore >= 80
                                  ? "#7C3AED"
                                  : st.readinessScore >= 50
                                  ? "#6366F1"
                                  : "#F59E0B"
                              }
                              strokeWidth="3.5"
                              strokeDasharray={94.2}
                              strokeDashoffset={
                                94.2 - (94.2 * st.readinessScore) / 100
                              }
                              strokeLinecap="round"
                              fill="transparent"
                            />
                          </svg>
                          <span className="absolute text-[10px] font-black text-slate-900">
                            {st.readinessScore}%
                          </span>
                        </div>
                      </td>

                      {/* Coding Streak Badge */}
                      <td className="py-4 px-4 text-center">
                        {st.codingStreak > 0 ? (
                          <span className="inline-flex items-center gap-1.5 bg-purple-100/80 text-purple-700 font-extrabold text-[10px] uppercase px-3 py-1.5 rounded-full border border-purple-200/60 shadow-xs">
                            <Flame className="w-3 h-3 text-purple-600 fill-purple-600" />
                            <span>{st.codingStreak} DAY STREAK</span>
                          </span>
                        ) : (
                          <span className="inline-flex items-center gap-1.5 bg-slate-100 text-slate-400 font-bold text-[10px] uppercase px-3 py-1.5 rounded-full border border-slate-200/60">
                            <Moon className="w-3 h-3 text-slate-400" />
                            <span>0 DAYS</span>
                          </span>
                        )}
                      </td>

                      {/* Resume Status Badge */}
                      <td className="py-4 px-4 text-center">
                        {st.resumeStatus === "VERIFIED" && (
                          <span className="inline-flex items-center gap-1 bg-slate-100 text-slate-700 font-bold px-2.5 py-1 rounded-md text-[10px] border border-slate-200/60">
                            <CheckCircle2 className="w-3 h-3 text-emerald-600" />
                            <span>VERIFIED</span>
                          </span>
                        )}
                        {st.resumeStatus === "MISSING" && (
                          <span className="inline-flex items-center gap-1 bg-rose-50 text-rose-600 font-bold px-2.5 py-1 rounded-md text-[10px] border border-rose-100">
                            <AlertTriangle className="w-3 h-3 text-rose-500" />
                            <span>MISSING</span>
                          </span>
                        )}
                        {st.resumeStatus === "DRAFT" && (
                          <span className="inline-flex items-center gap-1 bg-purple-100 text-purple-700 font-bold px-2.5 py-1 rounded-md text-[10px]">
                            <FileText className="w-3 h-3 text-purple-600" />
                            <span>DRAFT</span>
                          </span>
                        )}
                      </td>

                      {/* Placement Status Badge */}
                      <td className="py-4 px-4 text-right pr-6">
                        {st.placementStatus === "PLACED" && (
                          <span className="inline-block bg-purple-100 text-purple-700 font-extrabold px-3 py-1 rounded-full text-[10px] uppercase tracking-wide">
                            PLACED
                          </span>
                        )}
                        {st.placementStatus === "UNPLACED" && (
                          <span className="inline-block bg-slate-100 text-slate-600 font-bold px-3 py-1 rounded-full text-[10px] uppercase tracking-wide">
                            UNPLACED
                          </span>
                        )}
                        {st.placementStatus === "IN INTERVIEW" && (
                          <span className="inline-block bg-purple-100/70 text-purple-700 font-extrabold px-3 py-1 rounded-full text-[10px] uppercase tracking-wide border border-purple-200/80">
                            IN INTERVIEW
                          </span>
                        )}
                      </td>
                    </tr>
                  );
                })
              ) : (
                <tr>
                  <td colSpan={7} className="py-12 text-center text-slate-400 font-medium text-xs">
                    No student records found matching the selected filters.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>

        {/* Table Pagination & Footer Status (Matching image_08e69e.png) */}
        <div className="p-4 bg-slate-50/50 border-t border-slate-100 flex flex-col sm:flex-row items-center justify-between gap-4">
          {/* Results Counter */}
          <div className="text-xs text-slate-500 font-semibold">
            Showing {paginatedStudents.length} of {filteredStudents.length} students
          </div>

          {/* Pagination Controls */}
          <div className="flex items-center gap-2">
            <button
              onClick={() => setCurrentPage((p) => Math.max(p - 1, 1))}
              disabled={currentPage === 1}
              className="bg-white hover:bg-slate-100 text-slate-700 disabled:opacity-40 disabled:cursor-not-allowed font-semibold text-xs px-3.5 py-1.5 rounded-xl border border-slate-200 transition-all cursor-pointer"
            >
              Previous
            </button>

            <span className="text-xs font-bold text-slate-600 px-2">
              Page {currentPage} of {totalPages}
            </span>

            <button
              onClick={() => setCurrentPage((p) => Math.min(p + 1, totalPages))}
              disabled={currentPage === totalPages}
              className="bg-white hover:bg-slate-100 text-slate-700 disabled:opacity-40 disabled:cursor-not-allowed font-semibold text-xs px-3.5 py-1.5 rounded-xl border border-slate-200 transition-all cursor-pointer"
            >
              Next
            </button>
          </div>
        </div>
      </div>

      {/* Slide-over Modal: Priya Sharma AI Candidate Highlight */}
      {isAiModalOpen && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-end">
          <div className="bg-white h-full max-w-md w-full p-6 shadow-2xl overflow-y-auto space-y-6 animate-slide-left">
            <div className="flex items-center justify-between border-b border-slate-100 pb-4">
              <div className="flex items-center gap-2">
                <Sparkles className="w-5 h-5 text-purple-600 fill-purple-600" />
                <h2 className="text-base font-extrabold text-slate-900">
                  AI Talent Spotlight
                </h2>
              </div>
              <button
                onClick={() => setIsAiModalOpen(false)}
                className="text-slate-400 hover:text-slate-600 p-1"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Profile Header */}
            <div className="flex items-center gap-4 bg-purple-50/60 p-4 rounded-2xl border border-purple-100">
              <img
                src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200"
                alt="Priya Sharma"
                className="w-16 h-16 rounded-2xl object-cover border-2 border-purple-400 shadow-md"
              />
              <div>
                <h3 className="text-lg font-black text-slate-900">Priya Sharma</h3>
                <p className="text-xs text-slate-500 font-medium">CS Final Year • 9.8 CGPA</p>
                <span className="inline-block mt-1 bg-purple-600 text-white font-bold text-[10px] px-2.5 py-0.5 rounded-full">
                  98% AI Match Index
                </span>
              </div>
            </div>

            {/* AI Diagnostics Summary */}
            <div className="space-y-3">
              <h4 className="text-xs font-extrabold text-slate-400 uppercase tracking-wider">
                Target Compatibility
              </h4>
              <div className="p-3.5 bg-slate-50 rounded-xl text-xs text-slate-700 leading-relaxed font-medium">
                Priya ranks in the top 1% of the 2024-25 batch with 300+ LeetCode problems solved, 4 software engineering internships (Stripe, Amazon), and a 98% predictive readiness score for tier-1 product tech companies.
              </div>
            </div>

            {/* Skill Matrix */}
            <div className="space-y-3">
              <h4 className="text-xs font-extrabold text-slate-400 uppercase tracking-wider">
                Verified Skill Matrix
              </h4>
              <div className="flex flex-wrap gap-2">
                <span className="bg-purple-100 text-purple-700 font-bold text-xs px-3 py-1 rounded-xl">
                  Python (Expert)
                </span>
                <span className="bg-purple-100 text-purple-700 font-bold text-xs px-3 py-1 rounded-xl">
                  DSA &amp; Algos
                </span>
                <span className="bg-purple-100 text-purple-700 font-bold text-xs px-3 py-1 rounded-xl">
                  System Design
                </span>
                <span className="bg-purple-100 text-purple-700 font-bold text-xs px-3 py-1 rounded-xl">
                  React &amp; Next.js
                </span>
              </div>
            </div>

            {/* Actions */}
            <div className="pt-4 border-t border-slate-100 flex flex-col gap-3">
              <button
                onClick={() => {
                  setIsAiModalOpen(false);
                  showToast("Priya Sharma shortlisted for Google APAC drive!");
                }}
                className="w-full py-3 bg-purple-600 hover:bg-purple-700 text-white font-bold text-xs rounded-xl shadow-md flex items-center justify-center gap-2"
              >
                <UserCheck className="w-4 h-4" /> Fast-Track to Placement Drive
              </button>
              <button
                onClick={() => setIsAiModalOpen(false)}
                className="w-full py-3 border border-slate-200 text-slate-700 font-semibold text-xs rounded-xl hover:bg-slate-50"
              >
                Close Drawer
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Student Detail View Modal */}
      {activeStudentDetail && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-3">
                <img
                  src={activeStudentDetail.avatar}
                  alt={activeStudentDetail.name}
                  className="w-10 h-10 rounded-xl object-cover border border-slate-200"
                />
                <div>
                  <h3 className="text-base font-extrabold text-slate-900">
                    {activeStudentDetail.name}
                  </h3>
                  <p className="text-xs text-slate-400 font-mono">
                    {activeStudentDetail.studentIdTag}
                  </p>
                </div>
              </div>
              <button
                onClick={() => setActiveStudentDetail(null)}
                className="text-slate-400 hover:text-slate-600 p-1"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="grid grid-cols-2 gap-3 text-xs bg-slate-50 p-4 rounded-xl">
              <div>
                <span className="text-slate-400 font-bold uppercase text-[10px]">Department</span>
                <div className="font-extrabold text-slate-800">{activeStudentDetail.department}</div>
              </div>
              <div>
                <span className="text-slate-400 font-bold uppercase text-[10px]">GPA</span>
                <div className="font-extrabold text-slate-800">{activeStudentDetail.gpa} / 10.0</div>
              </div>
              <div>
                <span className="text-slate-400 font-bold uppercase text-[10px]">LeetCode Solved</span>
                <div className="font-extrabold text-purple-700">{activeStudentDetail.leetcodeCount} problems</div>
              </div>
              <div>
                <span className="text-slate-400 font-bold uppercase text-[10px]">GitHub Commits</span>
                <div className="font-extrabold text-purple-700">{activeStudentDetail.githubCommits} commits</div>
              </div>
            </div>

            <div>
              <span className="text-xs font-bold text-slate-700 block mb-2">Verified Skill Tags</span>
              <div className="flex flex-wrap gap-1.5">
                {activeStudentDetail.skills.map((s, idx) => (
                  <span key={idx} className="bg-purple-100 text-purple-700 font-bold text-[10px] px-2.5 py-1 rounded-md">
                    {s}
                  </span>
                ))}
              </div>
            </div>

            <div className="pt-3 border-t border-slate-100 flex justify-end gap-3">
              <button
                onClick={() => setActiveStudentDetail(null)}
                className="px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold text-xs rounded-xl"
              >
                Close
              </button>
              <button
                onClick={() => {
                  showToast(`Email invitation sent to ${activeStudentDetail.email}`);
                  setActiveStudentDetail(null);
                }}
                className="px-4 py-2 bg-purple-600 hover:bg-purple-700 text-white font-bold text-xs rounded-xl shadow-md"
              >
                Contact Student
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Advanced Filter Drawer */}
      {isFilterDrawerOpen && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-end">
          <div className="bg-white h-full max-w-md w-full p-6 shadow-2xl overflow-y-auto space-y-6">
            <div className="flex items-center justify-between border-b border-slate-100 pb-4">
              <h2 className="text-base font-bold text-slate-900">Advanced Filter Controls</h2>
              <button onClick={() => setIsFilterDrawerOpen(false)} className="text-slate-400 hover:text-slate-600">
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="space-y-4 text-xs">
              <div>
                <label className="font-bold text-slate-700 block mb-1.5">Resume Verification Status</label>
                <select
                  value={resumeFilter}
                  onChange={(e) => setResumeFilter(e.target.value)}
                  className="w-full p-2.5 bg-slate-50 border border-slate-200 rounded-xl outline-none"
                >
                  <option value="All">All Document States</option>
                  <option value="VERIFIED">Verified Only</option>
                  <option value="MISSING">Missing Only</option>
                  <option value="DRAFT">Draft Only</option>
                </select>
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1.5">Placement Stage</label>
                <select
                  value={statusFilter}
                  onChange={(e) => setStatusFilter(e.target.value)}
                  className="w-full p-2.5 bg-slate-50 border border-slate-200 rounded-xl outline-none"
                >
                  <option value="All">All Placement Stages</option>
                  <option value="PLACED">Placed</option>
                  <option value="UNPLACED">Unplaced</option>
                  <option value="IN INTERVIEW">In Interview Pipeline</option>
                </select>
              </div>
            </div>

            <div className="pt-4 border-t border-slate-100 flex justify-end gap-3">
              <button
                onClick={() => {
                  handleResetFilters();
                  setIsFilterDrawerOpen(false);
                }}
                className="px-4 py-2 border border-slate-200 text-slate-600 rounded-xl font-semibold"
              >
                Reset
              </button>
              <button
                onClick={() => setIsFilterDrawerOpen(false)}
                className="px-5 py-2 bg-purple-600 text-white rounded-xl font-bold shadow-md"
              >
                Apply Filters
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
