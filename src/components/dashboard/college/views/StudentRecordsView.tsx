import React, { useState, useMemo } from "react";
import {
  Download,
  UserPlus,
  Search,
  RotateCcw,
  LayoutGrid,
  List,
  Mail,
  X,
  CheckCircle2,
  ChevronDown,
  Sparkles,
  AlertCircle
} from "lucide-react";

export interface StudentRecordItem {
  id: string;
  name: string;
  rollNumber: string;
  avatar: string;
  department: string;
  graduationYear: string;
  cgpa: number;
  projectsCount: number;
  projectsTag: string; // e.g. "+2 recent", "Avg", "Critical"
  projectsTagType: "success" | "neutral" | "danger";
  readinessScore: number; // 0 to 100
  placementStatus: "PLACED" | "UNPLACED" | "PENDING";
  hiredBy?: string;
  hiredLogos?: string[];
  skills: string[];
  email: string;
  phone: string;
}

const INITIAL_STUDENT_RECORDS: StudentRecordItem[] = [
  {
    id: "stu-101",
    name: "Arjun Mehta",
    rollNumber: "Roll: CS2024-042",
    avatar: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200",
    department: "Computer Science",
    graduationYear: "2024 (Current)",
    cgpa: 8.92,
    projectsCount: 12,
    projectsTag: "+2 recent",
    projectsTagType: "success",
    readinessScore: 94,
    placementStatus: "UNPLACED",
    skills: ["React.js", "Node.js", "Python", "TypeScript", "SQL", "Docker", "AWS"],
    email: "arjun.mehta@college.edu",
    phone: "+91 98765 43210"
  },
  {
    id: "stu-102",
    name: "Sarah Johnson",
    rollNumber: "Roll: EC2024-118",
    avatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200",
    department: "Electronics",
    graduationYear: "2024 (Current)",
    cgpa: 7.45,
    projectsCount: 8,
    projectsTag: "Avg",
    projectsTagType: "neutral",
    readinessScore: 68,
    placementStatus: "PLACED",
    hiredBy: "Google",
    hiredLogos: ["G", "M"],
    skills: ["Embedded C", "Python", "IoT", "MATLAB", "Signal Proc"],
    email: "sarah.j@college.edu",
    phone: "+91 98123 45678"
  },
  {
    id: "stu-103",
    name: "Vikram Singh",
    rollNumber: "Roll: CS2024-001",
    avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200",
    department: "Computer Science",
    graduationYear: "2024 (Current)",
    cgpa: 5.82,
    projectsCount: 4,
    projectsTag: "Critical",
    projectsTagType: "danger",
    readinessScore: 42,
    placementStatus: "UNPLACED",
    skills: ["C++", "HTML/CSS", "Java", "SQL"],
    email: "vikram.singh@college.edu",
    phone: "+91 97654 32109"
  },
  {
    id: "stu-104",
    name: "Priya Sharma",
    rollNumber: "Roll: CS2024-099",
    avatar: "https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&q=80&w=200",
    department: "Computer Science",
    graduationYear: "2024 (Current)",
    cgpa: 9.60,
    projectsCount: 15,
    projectsTag: "+3 recent",
    projectsTagType: "success",
    readinessScore: 98,
    placementStatus: "PLACED",
    hiredBy: "Microsoft",
    hiredLogos: ["MS", "AZ"],
    skills: ["Python", "DSA", "System Design", "React.js", "GraphQL"],
    email: "priya.sharma@college.edu",
    phone: "+91 98989 12345"
  },
  {
    id: "stu-105",
    name: "Ananya Roy",
    rollNumber: "Roll: ME2024-089",
    avatar: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=200",
    department: "Mechanical",
    graduationYear: "2024 (Current)",
    cgpa: 8.15,
    projectsCount: 10,
    projectsTag: "+1 recent",
    projectsTagType: "success",
    readinessScore: 88,
    placementStatus: "PLACED",
    hiredBy: "Tesla",
    hiredLogos: ["T"],
    skills: ["SolidWorks", "CAD", "Python", "Robotics", "FEA"],
    email: "ananya.roy@college.edu",
    phone: "+91 98456 78901"
  },
  {
    id: "stu-106",
    name: "Rahul Verma",
    rollNumber: "Roll: CE2025-015",
    avatar: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=200",
    department: "Civil",
    graduationYear: "2025",
    cgpa: 7.20,
    projectsCount: 6,
    projectsTag: "Avg",
    projectsTagType: "neutral",
    readinessScore: 62,
    placementStatus: "PENDING",
    skills: ["AutoCAD", "STAAD Pro", "Project Mgmt", "Surveying"],
    email: "rahul.verma@college.edu",
    phone: "+91 91234 56789"
  },
  {
    id: "stu-107",
    name: "Dev Patel",
    rollNumber: "Roll: EC2026-033",
    avatar: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=200",
    department: "Electronics",
    graduationYear: "2026",
    cgpa: 6.90,
    projectsCount: 5,
    projectsTag: "Avg",
    projectsTagType: "neutral",
    readinessScore: 55,
    placementStatus: "UNPLACED",
    skills: ["Arduino", "C++", "Python", "Sensors"],
    email: "dev.patel@college.edu",
    phone: "+91 98000 11122"
  },
  {
    id: "stu-108",
    name: "Kavya Nair",
    rollNumber: "Roll: CS2025-077",
    avatar: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200",
    department: "Computer Science",
    graduationYear: "2025",
    cgpa: 8.75,
    projectsCount: 11,
    projectsTag: "+2 recent",
    projectsTagType: "success",
    readinessScore: 91,
    placementStatus: "PLACED",
    hiredBy: "Amazon",
    hiredLogos: ["A", "AWS"],
    skills: ["Java", "Spring Boot", "AWS", "Docker", "Microservices"],
    email: "kavya.nair@college.edu",
    phone: "+91 97111 22233"
  }
];

const AVAILABLE_MENTORS = [
  { id: "m-1", name: "Dr. Rajesh Kumar", area: "Data Structures & Backend Architecture" },
  { id: "m-2", name: "Prof. Anita Sharma", area: "Embedded Systems & Hardware" },
  { id: "m-3", name: "Alex Mercer", area: "Full-Stack Development & System Design" },
  { id: "m-4", name: "Dr. Sunita Deshmukh", area: "Machine Learning & Algorithms" }
];

export const StudentRecordsView: React.FC = () => {
  // State
  const [students, setStudents] = useState<StudentRecordItem[]>(INITIAL_STUDENT_RECORDS);

  // Filters state
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedDept, setSelectedDept] = useState("All Departments");
  const [selectedYear, setSelectedYear] = useState("2024 (Current)");
  const [minCgpa, setMinCgpa] = useState<number>(7.5);
  const [statusFilter, setStatusFilter] = useState<"All" | "Placed" | "Pending">("All");

  // View Mode: grid vs list
  const [viewMode, setViewMode] = useState<"grid" | "list">("grid");

  // Modal states
  const [isAddStudentOpen, setIsAddStudentOpen] = useState(false);
  const [assignMentorStudent, setAssignMentorStudent] = useState<StudentRecordItem | null>(null);
  const [emailStudent, setEmailStudent] = useState<StudentRecordItem | null>(null);

  // Form states
  const [newStudentForm, setNewStudentForm] = useState({
    name: "",
    rollNumber: "",
    department: "Computer Science",
    graduationYear: "2024 (Current)",
    cgpa: "8.50",
    placementStatus: "UNPLACED" as "PLACED" | "UNPLACED" | "PENDING",
    skillsStr: "React.js, Node.js, Python",
    email: "",
    phone: ""
  });

  const [mentorSelected, setMentorSelected] = useState(AVAILABLE_MENTORS[0].name);
  const [mentorNotes, setMentorNotes] = useState("");
  const [emailSubject, setEmailSubject] = useState("Placement Assistance & Career Guidance");
  const [emailBody, setEmailBody] = useState("");

  // Toast message
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => {
      setToastMessage(null);
    }, 4000);
  };

  // Reset Filters
  const handleResetFilters = () => {
    setSearchQuery("");
    setSelectedDept("All Departments");
    setSelectedYear("2024 (Current)");
    setMinCgpa(7.5);
    setStatusFilter("All");
    showToast("Filters reset to default settings.");
  };

  // Filtered Students Calculation
  const filteredStudents = useMemo(() => {
    return students.filter((stu) => {
      // Search
      const query = searchQuery.toLowerCase().trim();
      const matchesSearch =
        !query ||
        stu.name.toLowerCase().includes(query) ||
        stu.rollNumber.toLowerCase().includes(query) ||
        stu.department.toLowerCase().includes(query) ||
        stu.skills.some((sk) => sk.toLowerCase().includes(query));

      // Department
      const matchesDept = selectedDept === "All Departments" || stu.department === selectedDept;

      // Graduation Year
      const matchesYear = selectedYear === "All Batches" || stu.graduationYear === selectedYear;

      // Min CGPA
      const matchesCgpa = stu.cgpa >= minCgpa;

      // Placement Status
      let matchesStatus = true;
      if (statusFilter === "Placed") matchesStatus = stu.placementStatus === "PLACED";
      else if (statusFilter === "Pending") matchesStatus = stu.placementStatus === "UNPLACED" || stu.placementStatus === "PENDING";

      return matchesSearch && matchesDept && matchesYear && matchesCgpa && matchesStatus;
    });
  }, [students, searchQuery, selectedDept, selectedYear, minCgpa, statusFilter]);

  // Export CSV Handler
  const handleExportCSV = () => {
    if (filteredStudents.length === 0) {
      showToast("No student records available to export.");
      return;
    }

    const headers = [
      "ID",
      "Roll Number",
      "Name",
      "Department",
      "Graduation Year",
      "CGPA",
      "Projects Count",
      "Readiness Score (%)",
      "Placement Status",
      "Hired By",
      "Skills",
      "Email"
    ];

    const csvRows = filteredStudents.map((s) => [
      `"${s.id}"`,
      `"${s.rollNumber}"`,
      `"${s.name}"`,
      `"${s.department}"`,
      `"${s.graduationYear}"`,
      s.cgpa,
      s.projectsCount,
      s.readinessScore,
      `"${s.placementStatus}"`,
      `"${s.hiredBy || "N/A"}"`,
      `"${s.skills.join("; ")}"`,
      `"${s.email}"`
    ]);

    const csvContent = [headers.join(","), ...csvRows.map((e) => e.join(","))].join("\n");
    const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.setAttribute("href", url);
    link.setAttribute("download", `Student_Records_Export_${new Date().toISOString().slice(0, 10)}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

    showToast(`Successfully exported ${filteredStudents.length} candidate records to CSV.`);
  };

  // Add Student Handler
  const handleAddStudentSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newStudentForm.name.trim() || !newStudentForm.rollNumber.trim()) return;

    const parsedCgpa = parseFloat(newStudentForm.cgpa) || 8.0;
    const readinessCalc = Math.min(Math.round(parsedCgpa * 10), 99);
    const skillsArr = newStudentForm.skillsStr.split(",").map((s) => s.trim()).filter(Boolean);

    const newRecord: StudentRecordItem = {
      id: `stu-${Date.now()}`,
      name: newStudentForm.name,
      rollNumber: newStudentForm.rollNumber.startsWith("Roll:") ? newStudentForm.rollNumber : `Roll: ${newStudentForm.rollNumber}`,
      avatar: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200",
      department: newStudentForm.department,
      graduationYear: newStudentForm.graduationYear,
      cgpa: parsedCgpa,
      projectsCount: 6,
      projectsTag: "+1 recent",
      projectsTagType: "success",
      readinessScore: readinessCalc,
      placementStatus: newStudentForm.placementStatus,
      skills: skillsArr.length > 0 ? skillsArr : ["React.js", "Node.js", "Python"],
      email: newStudentForm.email || `${newStudentForm.name.toLowerCase().replace(/\s+/g, ".")}@college.edu`,
      phone: newStudentForm.phone || "+91 98765 00000"
    };

    setStudents([newRecord, ...students]);
    setIsAddStudentOpen(false);
    showToast(`New student record for ${newRecord.name} added successfully!`);

    // Reset Form
    setNewStudentForm({
      name: "",
      rollNumber: "",
      department: "Computer Science",
      graduationYear: "2024 (Current)",
      cgpa: "8.50",
      placementStatus: "UNPLACED",
      skillsStr: "React.js, Node.js, Python",
      email: "",
      phone: ""
    });
  };

  // Assign Mentor Submit
  const handleAssignMentorSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!assignMentorStudent) return;
    showToast(`Mentor ${mentorSelected} assigned to ${assignMentorStudent.name}.`);
    setAssignMentorStudent(null);
    setMentorNotes("");
  };

  // Email Submit
  const handleSendEmailSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!emailStudent) return;
    showToast(`Email successfully sent to ${emailStudent.name} (${emailStudent.email}).`);
    setEmailStudent(null);
    setEmailBody("");
  };

  return (
    <div className="space-y-6 pb-12">
      {/* Toast Notification */}
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
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl md:text-3xl font-extrabold text-slate-900 tracking-tight">
            Student Records
          </h1>
          <p className="text-xs md:text-sm text-slate-500 font-medium mt-1">
            Manage, filter, and analyze candidate performance across departments.
          </p>
        </div>

        <div className="flex items-center gap-3">
          {/* Export CSV CTA */}
          <button
            onClick={handleExportCSV}
            className="bg-white hover:bg-slate-50 text-slate-700 font-bold px-4 py-2.5 rounded-xl border border-slate-200 shadow-xs text-xs md:text-sm flex items-center gap-2 transition-all cursor-pointer hover:border-slate-300"
          >
            <Download className="w-4 h-4 text-slate-600" />
            <span>Export CSV</span>
          </button>

          {/* Add Student CTA */}
          <button
            onClick={() => setIsAddStudentOpen(true)}
            className="bg-[#7C3AED] hover:bg-[#6B21A8] active:bg-purple-900 text-white font-bold px-4 py-2.5 rounded-xl shadow-md shadow-purple-500/20 text-xs md:text-sm flex items-center gap-2 transition-all cursor-pointer transform hover:-translate-y-0.5"
          >
            <UserPlus className="w-4 h-4 stroke-[2.5]" />
            <span>Add Student</span>
          </button>
        </div>
      </div>

      {/* 2. Interactive Dynamic Filter & View Control Bar */}
      <div className="bg-white rounded-2xl border border-slate-100 p-4 sm:p-5 shadow-xs space-y-4">
        {/* Top Search Bar */}
        <div className="relative w-full">
          <Search className="w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search student records, roll numbers, skills..."
            className="w-full bg-slate-50 hover:bg-slate-100/70 focus:bg-white text-xs md:text-sm pl-10 pr-10 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-purple-500/30 transition-all placeholder:text-slate-400 text-slate-800"
          />
          {searchQuery && (
            <button
              onClick={() => setSearchQuery("")}
              className="absolute right-3.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 p-1"
            >
              <X className="w-4 h-4" />
            </button>
          )}
        </div>

        {/* Filter Controls Row */}
        <div className="flex flex-wrap items-center justify-between gap-4">
          <div className="flex flex-wrap items-center gap-4 flex-1">
            {/* Department Selector */}
            <div className="min-w-[170px]">
              <label className="text-[11px] font-extrabold text-slate-400 block mb-1 uppercase tracking-wider">
                Department
              </label>
              <div className="relative">
                <select
                  value={selectedDept}
                  onChange={(e) => setSelectedDept(e.target.value)}
                  className="w-full bg-white text-slate-800 font-bold text-xs py-2 px-3 pr-8 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-purple-500/30 cursor-pointer appearance-none shadow-2xs"
                >
                  <option value="All Departments">All Departments</option>
                  <option value="Computer Science">Computer Science</option>
                  <option value="Electronics">Electronics</option>
                  <option value="Mechanical">Mechanical</option>
                  <option value="Civil">Civil</option>
                </select>
                <ChevronDown className="w-4 h-4 text-slate-400 absolute right-2.5 top-1/2 -translate-y-1/2 pointer-events-none" />
              </div>
            </div>

            {/* Graduation Year Selector */}
            <div className="min-w-[170px]">
              <label className="text-[11px] font-extrabold text-slate-400 block mb-1 uppercase tracking-wider">
                Graduation Year
              </label>
              <div className="relative">
                <select
                  value={selectedYear}
                  onChange={(e) => setSelectedYear(e.target.value)}
                  className="w-full bg-white text-slate-800 font-bold text-xs py-2 px-3 pr-8 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-purple-500/30 cursor-pointer appearance-none shadow-2xs"
                >
                  <option value="2024 (Current)">2024 (Current)</option>
                  <option value="2025">2025</option>
                  <option value="2026">2026</option>
                  <option value="All Batches">All Batches</option>
                </select>
                <ChevronDown className="w-4 h-4 text-slate-400 absolute right-2.5 top-1/2 -translate-y-1/2 pointer-events-none" />
              </div>
            </div>

            {/* Min CGPA Range Slider / Input */}
            <div className="min-w-[180px] flex-1 max-w-[240px]">
              <div className="flex items-center justify-between mb-1">
                <label className="text-[11px] font-extrabold text-slate-400 uppercase tracking-wider">
                  Min CGPA
                </label>
                <span className="text-xs font-black text-slate-800">{minCgpa.toFixed(1)}</span>
              </div>
              <input
                type="range"
                min="0.0"
                max="10.0"
                step="0.1"
                value={minCgpa}
                onChange={(e) => setMinCgpa(parseFloat(e.target.value))}
                className="w-full accent-purple-600 h-1.5 bg-slate-200 rounded-lg cursor-pointer"
              />
            </div>

            {/* Placement Status Pill Toggle */}
            <div>
              <label className="text-[11px] font-extrabold text-slate-400 block mb-1 uppercase tracking-wider">
                Placement Status
              </label>
              <div className="bg-slate-100 p-1 rounded-xl flex items-center gap-1 border border-slate-200/60">
                {(["All", "Placed", "Pending"] as const).map((status) => {
                  const isActive = statusFilter === status;
                  return (
                    <button
                      key={status}
                      onClick={() => setStatusFilter(status)}
                      className={`px-3 py-1 rounded-lg text-xs font-bold transition-all cursor-pointer ${
                        isActive
                          ? "bg-white text-purple-700 shadow-xs"
                          : "text-slate-600 hover:text-slate-900"
                      }`}
                    >
                      {status}
                    </button>
                  );
                })}
              </div>
            </div>
          </div>

          {/* Utility Controls (Reset & Layout Switcher) */}
          <div className="flex items-center gap-2 pt-2 sm:pt-0 border-t sm:border-t-0 border-slate-100 w-full sm:w-auto justify-end">
            {/* Reset Button */}
            <button
              onClick={handleResetFilters}
              className="bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold px-3 py-2 rounded-xl text-xs flex items-center gap-1.5 transition-colors cursor-pointer"
            >
              <RotateCcw className="w-3.5 h-3.5 text-slate-600" />
              <span>Reset</span>
            </button>

            {/* Layout Switcher Icons */}
            <div className="bg-slate-100 p-1 rounded-xl flex items-center gap-1 border border-slate-200/60">
              <button
                onClick={() => setViewMode("grid")}
                title="Grid View"
                className={`p-1.5 rounded-lg transition-all cursor-pointer ${
                  viewMode === "grid"
                    ? "bg-white text-purple-700 shadow-xs"
                    : "text-slate-400 hover:text-slate-600"
                }`}
              >
                <LayoutGrid className="w-4 h-4" />
              </button>
              <button
                onClick={() => setViewMode("list")}
                title="List View"
                className={`p-1.5 rounded-lg transition-all cursor-pointer ${
                  viewMode === "list"
                    ? "bg-white text-purple-700 shadow-xs"
                    : "text-slate-400 hover:text-slate-600"
                }`}
              >
                <List className="w-4 h-4" />
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* 3. Student Record Cards / Rows View */}
      {viewMode === "grid" ? (
        /* GRID VIEW MODE */
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-5">
          {filteredStudents.length > 0 ? (
            filteredStudents.map((student) => {
              const isUnplaced = student.placementStatus === "UNPLACED";
              const isPlaced = student.placementStatus === "PLACED";

              // CGPA Color badge logic
              const cgpaColorDot =
                student.cgpa >= 8.0
                  ? "bg-emerald-500"
                  : student.cgpa >= 7.0
                  ? "bg-amber-500"
                  : "bg-rose-500";

              // Readiness Score Color logic
              const readinessProgressColor =
                student.readinessScore >= 80
                  ? "bg-[#7C3AED]"
                  : student.readinessScore >= 50
                  ? "bg-indigo-600"
                  : "bg-[#EF4444]";

              const readinessTextColor =
                student.readinessScore >= 80
                  ? "text-purple-700"
                  : student.readinessScore >= 50
                  ? "text-indigo-700"
                  : "text-rose-600";

              return (
                <div
                  key={student.id}
                  className="bg-white rounded-2xl border border-slate-100 shadow-xs hover:shadow-md transition-all p-5 flex flex-col justify-between space-y-4 relative group"
                >
                  {/* Card Header: Avatar, Name, Roll, Placement Badge */}
                  <div className="flex items-start justify-between gap-3">
                    <div className="flex items-center gap-3">
                      <img
                        src={student.avatar}
                        alt={student.name}
                        className="w-12 h-12 rounded-2xl object-cover border border-slate-100 shadow-xs"
                      />
                      <div>
                        <h3 className="text-base font-extrabold text-slate-900 leading-tight">
                          {student.name}
                        </h3>
                        <p className="text-xs font-semibold text-slate-400 mt-0.5">
                          {student.rollNumber}
                        </p>
                      </div>
                    </div>

                    {/* Status Badge */}
                    <div>
                      {isUnplaced && (
                        <span className="bg-[#FEE2E2] text-[#EF4444] font-black text-[10px] tracking-wider uppercase px-2.5 py-1 rounded-md inline-block">
                          UNPLACED
                        </span>
                      )}
                      {isPlaced && (
                        <span className="bg-[#D1FAE5] text-[#10B981] font-black text-[10px] tracking-wider uppercase px-2.5 py-1 rounded-md inline-block">
                          PLACED
                        </span>
                      )}
                      {student.placementStatus === "PENDING" && (
                        <span className="bg-amber-100 text-amber-700 font-black text-[10px] tracking-wider uppercase px-2.5 py-1 rounded-md inline-block">
                          PENDING
                        </span>
                      )}
                    </div>
                  </div>

                  {/* Metric Chips Row */}
                  <div className="grid grid-cols-2 gap-3">
                    {/* CGPA Chip */}
                    <div className="bg-slate-50 p-3 rounded-xl border border-slate-100 flex flex-col justify-between">
                      <span className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider">
                        CGPA
                      </span>
                      <div className="flex items-center gap-2 mt-1">
                        <span className={`w-2 h-2 rounded-full ${cgpaColorDot}`} />
                        <span className="text-sm font-black text-slate-800">
                          {student.cgpa.toFixed(2)}
                        </span>
                      </div>
                    </div>

                    {/* Projects Chip */}
                    <div className="bg-slate-50 p-3 rounded-xl border border-slate-100 flex flex-col justify-between">
                      <span className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider">
                        PROJECTS
                      </span>
                      <div className="flex items-center justify-between mt-1">
                        <span className="text-sm font-black text-slate-800">
                          {student.projectsCount < 10 ? `0${student.projectsCount}` : student.projectsCount}
                        </span>
                        <span
                          className={`text-[10px] font-extrabold px-1.5 py-0.5 rounded ${
                            student.projectsTagType === "success"
                              ? "bg-emerald-100 text-emerald-700"
                              : student.projectsTagType === "danger"
                              ? "bg-rose-100 text-rose-600"
                              : "bg-slate-200 text-slate-600"
                          }`}
                        >
                          {student.projectsTag}
                        </span>
                      </div>
                    </div>
                  </div>

                  {/* Readiness Score Bar */}
                  <div className="space-y-1.5">
                    <div className="flex items-center justify-between text-xs">
                      <span className="font-extrabold text-slate-500">Readiness Score</span>
                      <span className={`font-black ${readinessTextColor}`}>
                        {student.readinessScore}%
                      </span>
                    </div>
                    <div className="w-full bg-slate-100 rounded-full h-2 overflow-hidden">
                      <div
                        className={`h-full rounded-full transition-all duration-500 ${readinessProgressColor}`}
                        style={{ width: `${student.readinessScore}%` }}
                      />
                    </div>
                  </div>

                  {/* Card Footer / Badges & Intervention Actions */}
                  <div className="pt-2 border-t border-slate-100 space-y-3">
                    {/* Placed Student: Recruiter Logo Badge */}
                    {isPlaced && (
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-1.5">
                          {student.hiredLogos?.map((logo, idx) => (
                            <span
                              key={idx}
                              className="w-5 h-5 rounded-full bg-slate-200 text-slate-700 font-extrabold text-[10px] flex items-center justify-center border border-white shadow-2xs"
                            >
                              {logo}
                            </span>
                          ))}
                        </div>
                        <span className="text-xs font-semibold text-slate-500">
                          Hired by: <strong className="text-slate-800">{student.hiredBy}</strong>
                        </span>
                      </div>
                    )}

                    {/* Skill Chips */}
                    <div className="flex flex-wrap items-center gap-1.5">
                      {student.skills.slice(0, 3).map((skill, sIdx) => (
                        <span
                          key={sIdx}
                          className="bg-slate-100 hover:bg-slate-200 text-slate-700 text-[11px] font-semibold px-2.5 py-1 rounded-lg transition-colors"
                        >
                          {skill}
                        </span>
                      ))}
                      {student.skills.length > 3 && (
                        <span className="bg-slate-100 text-slate-500 text-[11px] font-bold px-2 py-1 rounded-lg">
                          +{student.skills.length - 3} more
                        </span>
                      )}
                    </div>

                    {/* Unplaced / At-Risk Student Action Controls */}
                    {!isPlaced && (
                      <div className="flex items-center gap-2 pt-1">
                        <button
                          onClick={() => setAssignMentorStudent(student)}
                          className="bg-[#F3E8FF] hover:bg-[#E9D5FF] text-[#7C3AED] font-extrabold py-2 px-3 rounded-xl text-xs flex-1 transition-colors flex items-center justify-center gap-1.5 cursor-pointer"
                        >
                          <span>Assign Mentor</span>
                        </button>
                        <button
                          onClick={() => setEmailStudent(student)}
                          title="Send Email"
                          className="border border-slate-200 hover:bg-slate-50 text-slate-600 p-2 rounded-xl transition-colors cursor-pointer flex items-center justify-center"
                        >
                          <Mail className="w-4 h-4" />
                        </button>
                      </div>
                    )}
                  </div>
                </div>
              );
            })
          ) : (
            <div className="col-span-full bg-white p-12 rounded-2xl border border-slate-100 text-center space-y-3">
              <AlertCircle className="w-10 h-10 text-slate-300 mx-auto" />
              <h3 className="text-base font-bold text-slate-800">No Student Records Found</h3>
              <p className="text-xs text-slate-500 max-w-sm mx-auto">
                No students match your selected department, graduation year, or min CGPA filter. Try resetting your search or adjusting filters.
              </p>
              <button
                onClick={handleResetFilters}
                className="bg-purple-50 text-purple-700 hover:bg-purple-100 text-xs font-bold px-4 py-2 rounded-xl transition-colors inline-block"
              >
                Reset All Filters
              </button>
            </div>
          )}
        </div>
      ) : (
        /* LIST VIEW MODE (COMPACT TABLE) */
        <div className="bg-white rounded-2xl border border-slate-100 shadow-xs overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="bg-slate-50 border-b border-slate-100 text-[11px] font-extrabold text-slate-400 uppercase tracking-wider">
                  <th className="py-3.5 px-4">Candidate</th>
                  <th className="py-3.5 px-4">Roll Number</th>
                  <th className="py-3.5 px-4">Department</th>
                  <th className="py-3.5 px-4 text-center">CGPA</th>
                  <th className="py-3.5 px-4 text-center">Projects</th>
                  <th className="py-3.5 px-4 text-center">Readiness</th>
                  <th className="py-3.5 px-4">Placement Status</th>
                  <th className="py-3.5 px-4 text-right pr-6">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 text-xs font-medium text-slate-700">
                {filteredStudents.length > 0 ? (
                  filteredStudents.map((stu) => (
                    <tr key={stu.id} className="hover:bg-slate-50/70 transition-colors">
                      <td className="py-3.5 px-4">
                        <div className="flex items-center gap-3">
                          <img
                            src={stu.avatar}
                            alt={stu.name}
                            className="w-8 h-8 rounded-xl object-cover border border-slate-200"
                          />
                          <div>
                            <div className="font-extrabold text-slate-900">{stu.name}</div>
                            <div className="text-[10px] text-slate-400">{stu.email}</div>
                          </div>
                        </div>
                      </td>
                      <td className="py-3.5 px-4 font-mono font-semibold text-slate-500">
                        {stu.rollNumber}
                      </td>
                      <td className="py-3.5 px-4 font-semibold text-slate-800">
                        {stu.department} ({stu.graduationYear})
                      </td>
                      <td className="py-3.5 px-4 text-center font-black text-slate-900">
                        {stu.cgpa.toFixed(2)}
                      </td>
                      <td className="py-3.5 px-4 text-center font-bold">
                        {stu.projectsCount}
                      </td>
                      <td className="py-3.5 px-4 text-center">
                        <span
                          className={`font-black px-2 py-0.5 rounded-full text-[11px] ${
                            stu.readinessScore >= 80
                              ? "bg-purple-100 text-purple-700"
                              : stu.readinessScore >= 50
                              ? "bg-indigo-100 text-indigo-700"
                              : "bg-rose-100 text-rose-600"
                          }`}
                        >
                          {stu.readinessScore}%
                        </span>
                      </td>
                      <td className="py-3.5 px-4">
                        {stu.placementStatus === "PLACED" && (
                          <span className="bg-[#D1FAE5] text-[#10B981] font-black text-[10px] uppercase px-2.5 py-1 rounded-md">
                            PLACED ({stu.hiredBy})
                          </span>
                        )}
                        {stu.placementStatus === "UNPLACED" && (
                          <span className="bg-[#FEE2E2] text-[#EF4444] font-black text-[10px] uppercase px-2.5 py-1 rounded-md">
                            UNPLACED
                          </span>
                        )}
                        {stu.placementStatus === "PENDING" && (
                          <span className="bg-amber-100 text-amber-700 font-black text-[10px] uppercase px-2.5 py-1 rounded-md">
                            PENDING
                          </span>
                        )}
                      </td>
                      <td className="py-3.5 px-4 text-right pr-6">
                        <div className="flex items-center justify-end gap-2">
                          <button
                            onClick={() => setAssignMentorStudent(stu)}
                            className="bg-purple-50 text-purple-700 hover:bg-purple-100 font-bold px-2.5 py-1 rounded-lg text-[11px] transition-colors"
                          >
                            Mentor
                          </button>
                          <button
                            onClick={() => setEmailStudent(stu)}
                            className="text-slate-400 hover:text-slate-700 p-1"
                          >
                            <Mail className="w-4 h-4" />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))
                ) : (
                  <tr>
                    <td colSpan={8} className="py-12 text-center text-slate-400 text-xs">
                      No records match the current filter parameters.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* MODAL 1: Add Student Slide-Over Modal */}
      {isAddStudentOpen && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-end">
          <div className="bg-white h-full max-w-lg w-full p-6 shadow-2xl overflow-y-auto space-y-5 animate-in slide-in-from-right duration-300">
            <div className="flex items-center justify-between border-b border-slate-100 pb-4">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-xl bg-purple-100 text-purple-700 flex items-center justify-center font-bold">
                  <UserPlus className="w-4 h-4" />
                </div>
                <h3 className="text-lg font-extrabold text-slate-900">Register New Candidate</h3>
              </div>
              <button
                onClick={() => setIsAddStudentOpen(false)}
                className="text-slate-400 hover:text-slate-600 p-1"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleAddStudentSubmit} className="space-y-4 text-xs font-medium">
              <div>
                <label className="font-extrabold text-slate-700 block mb-1">Student Full Name</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Arjun Mehta"
                  value={newStudentForm.name}
                  onChange={(e) => setNewStudentForm({ ...newStudentForm, name: e.target.value })}
                  className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-extrabold text-slate-700 block mb-1">Roll Number</label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. CS2024-042"
                    value={newStudentForm.rollNumber}
                    onChange={(e) => setNewStudentForm({ ...newStudentForm, rollNumber: e.target.value })}
                    className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                  />
                </div>
                <div>
                  <label className="font-extrabold text-slate-700 block mb-1">CGPA</label>
                  <input
                    type="number"
                    step="0.01"
                    min="0"
                    max="10"
                    required
                    placeholder="8.92"
                    value={newStudentForm.cgpa}
                    onChange={(e) => setNewStudentForm({ ...newStudentForm, cgpa: e.target.value })}
                    className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-extrabold text-slate-700 block mb-1">Department</label>
                  <select
                    value={newStudentForm.department}
                    onChange={(e) => setNewStudentForm({ ...newStudentForm, department: e.target.value })}
                    className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                  >
                    <option value="Computer Science">Computer Science</option>
                    <option value="Electronics">Electronics</option>
                    <option value="Mechanical">Mechanical</option>
                    <option value="Civil">Civil</option>
                  </select>
                </div>
                <div>
                  <label className="font-extrabold text-slate-700 block mb-1">Graduation Year</label>
                  <select
                    value={newStudentForm.graduationYear}
                    onChange={(e) => setNewStudentForm({ ...newStudentForm, graduationYear: e.target.value })}
                    className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                  >
                    <option value="2024 (Current)">2024 (Current)</option>
                    <option value="2025">2025</option>
                    <option value="2026">2026</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="font-extrabold text-slate-700 block mb-1">Placement Status</label>
                <select
                  value={newStudentForm.placementStatus}
                  onChange={(e) =>
                    setNewStudentForm({
                      ...newStudentForm,
                      placementStatus: e.target.value as "PLACED" | "UNPLACED" | "PENDING"
                    })
                  }
                  className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                >
                  <option value="UNPLACED">UNPLACED</option>
                  <option value="PLACED">PLACED</option>
                  <option value="PENDING">PENDING</option>
                </select>
              </div>

              <div>
                <label className="font-extrabold text-slate-700 block mb-1">Skills (comma separated)</label>
                <input
                  type="text"
                  placeholder="React.js, Node.js, Python, AWS"
                  value={newStudentForm.skillsStr}
                  onChange={(e) => setNewStudentForm({ ...newStudentForm, skillsStr: e.target.value })}
                  className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-extrabold text-slate-700 block mb-1">Email</label>
                  <input
                    type="email"
                    placeholder="student@college.edu"
                    value={newStudentForm.email}
                    onChange={(e) => setNewStudentForm({ ...newStudentForm, email: e.target.value })}
                    className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                  />
                </div>
                <div>
                  <label className="font-extrabold text-slate-700 block mb-1">Phone</label>
                  <input
                    type="text"
                    placeholder="+91 98765 00000"
                    value={newStudentForm.phone}
                    onChange={(e) => setNewStudentForm({ ...newStudentForm, phone: e.target.value })}
                    className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                  />
                </div>
              </div>

              <div className="flex items-center justify-end gap-3 pt-4 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setIsAddStudentOpen(false)}
                  className="px-4 py-2.5 rounded-xl text-slate-600 font-bold hover:bg-slate-100"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="bg-[#7C3AED] hover:bg-[#6B21A8] text-white font-bold px-5 py-2.5 rounded-xl shadow-md shadow-purple-500/20"
                >
                  Save Record
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* MODAL 2: Assign Mentor Modal */}
      {assignMentorStudent && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <Sparkles className="w-5 h-5 text-purple-600" />
                <h3 className="text-base font-extrabold text-slate-900">
                  Assign Mentor: {assignMentorStudent.name}
                </h3>
              </div>
              <button
                onClick={() => setAssignMentorStudent(null)}
                className="text-slate-400 hover:text-slate-600"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleAssignMentorSubmit} className="space-y-4 text-xs font-medium">
              <div>
                <label className="font-bold text-slate-700 block mb-1">Select Mentor</label>
                <select
                  value={mentorSelected}
                  onChange={(e) => setMentorSelected(e.target.value)}
                  className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none text-slate-800"
                >
                  {AVAILABLE_MENTORS.map((m) => (
                    <option key={m.id} value={m.name}>
                      {m.name} ({m.area})
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Intervention Focus Notes</label>
                <textarea
                  rows={3}
                  value={mentorNotes}
                  onChange={(e) => setMentorNotes(e.target.value)}
                  placeholder="e.g. Needs 1-on-1 interview practice and mock coding tests..."
                  className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                />
              </div>

              <div className="flex items-center justify-end gap-3 pt-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setAssignMentorStudent(null)}
                  className="px-4 py-2 rounded-xl text-slate-600 font-bold hover:bg-slate-100"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="bg-[#7C3AED] hover:bg-[#6B21A8] text-white font-bold px-4 py-2 rounded-xl shadow-md"
                >
                  Confirm Mentor
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* MODAL 3: Email Compose Modal */}
      {emailStudent && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <Mail className="w-5 h-5 text-purple-600" />
                <h3 className="text-base font-extrabold text-slate-900">
                  Email Candidate: {emailStudent.name}
                </h3>
              </div>
              <button onClick={() => setEmailStudent(null)} className="text-slate-400 hover:text-slate-600">
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleSendEmailSubmit} className="space-y-4 text-xs font-medium">
              <div>
                <label className="font-bold text-slate-700 block mb-1">To Email</label>
                <input
                  type="text"
                  disabled
                  value={emailStudent.email}
                  className="w-full p-3 bg-slate-100 border border-slate-200 rounded-xl text-slate-500 cursor-not-allowed"
                />
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Subject</label>
                <input
                  type="text"
                  required
                  value={emailSubject}
                  onChange={(e) => setEmailSubject(e.target.value)}
                  className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                />
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Message Body</label>
                <textarea
                  rows={4}
                  required
                  placeholder={`Hi ${emailStudent.name},\nWe noticed your profile readiness score is ${emailStudent.readinessScore}%. Please complete your pending mock tests...`}
                  value={emailBody}
                  onChange={(e) => setEmailBody(e.target.value)}
                  className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                />
              </div>

              <div className="flex items-center justify-end gap-3 pt-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setEmailStudent(null)}
                  className="px-4 py-2 rounded-xl text-slate-600 font-bold hover:bg-slate-100"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="bg-[#7C3AED] hover:bg-[#6B21A8] text-white font-bold px-4 py-2 rounded-xl shadow-md flex items-center gap-1.5"
                >
                  <Mail className="w-3.5 h-3.5" />
                  <span>Send Email</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default StudentRecordsView;
export const StudentsView = StudentRecordsView;
