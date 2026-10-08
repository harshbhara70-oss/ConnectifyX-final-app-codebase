import React, { useState, useMemo, useRef } from "react";
import {
  Building2,
  Users,
  Bell,
  Network,
  CreditCard,
  Upload,
  ChevronDown,
  Plus,
  MoreVertical,
  Sparkles,
  Search,
  CheckCircle2,
  X,
  Laptop,
  Cpu,
  Wrench,
  Server
} from "lucide-react";

export interface DepartmentItem {
  id: string;
  name: string;
  code: string;
  facultyCount: number;
  studentCount: number;
  hodEmail: string;
  iconType: "cs" | "ece" | "mech" | "it";
}

const INITIAL_DEPARTMENTS: DepartmentItem[] = [
  {
    id: "dept-1",
    name: "Computer Science",
    code: "CSE",
    facultyCount: 12,
    studentCount: 240,
    hodEmail: "hod.cs@stxaviers.edu",
    iconType: "cs"
  },
  {
    id: "dept-[#2]",
    name: "Electronics & Communication",
    code: "ECE",
    facultyCount: 8,
    studentCount: 180,
    hodEmail: "hod.ece@stxaviers.edu",
    iconType: "ece"
  },
  {
    id: "dept-3",
    name: "Mechanical Engineering",
    code: "MECH",
    facultyCount: 10,
    studentCount: 150,
    hodEmail: "hod.mech@stxaviers.edu",
    iconType: "mech"
  },
  {
    id: "dept-4",
    name: "Information Technology",
    code: "IT",
    facultyCount: 9,
    studentCount: 160,
    hodEmail: "hod.it@stxaviers.edu",
    iconType: "it"
  }
];

export const SettingsView: React.FC = () => {
  // Navigation active tab: "profile" | "users" | "notifications" | "integrations" | "billing"
  const [activeTab, setActiveTab] = useState<"profile" | "users" | "notifications" | "integrations" | "billing">("profile");

  // Departments State
  const [departments, setDepartments] = useState<DepartmentItem[]>(INITIAL_DEPARTMENTS);

  // Search filter
  const [searchQuery, setSearchQuery] = useState("");

  // Institution Profile Form State
  const [profileForm, setProfileForm] = useState({
    institutionName: "St. Xavier's Institute of Technology",
    accreditation: "A++ (Active)",
    collegeType: "Autonomous Engineering",
    campusAddress: "12th Mile, Science City Road, Bangalore, Karnataka - 560032, India"
  });

  // Logo Preview State
  const [logoPreview, setLogoPreview] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Department Dropdown Menu open state
  const [openDeptMenuId, setOpenDeptMenuId] = useState<string | null>(null);

  // Add Department Modal State
  const [isAddDeptModalOpen, setIsAddDeptModalOpen] = useState(false);
  const [newDeptForm, setNewDeptForm] = useState({
    name: "",
    code: "",
    hodEmail: "",
    facultyCount: "6",
    studentCount: "120",
    iconType: "cs" as DepartmentItem["iconType"]
  });

  // Notification Toggles State
  const [notifyState, setNotifyState] = useState({
    emailDrives: true,
    smsAlerts: false,
    weeklyDigest: true,
    hodUpdates: true
  });

  // Toast State
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => {
      setToastMessage(null);
    }, 4000);
  };

  // Logo Upload File Handler
  const handleLogoUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const url = URL.createObjectURL(file);
      setLogoPreview(url);
      showToast("Institutional logo uploaded and previewed!");
    }
  };

  // Save Profile Form Submit
  const handleSaveProfileSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    showToast("College profile updated successfully!");
  };

  // Add Department Form Submit
  const handleAddDeptSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newDeptForm.name.trim()) return;

    const created: DepartmentItem = {
      id: `dept-${Date.now()}`,
      name: newDeptForm.name,
      code: newDeptForm.code || "DEPT",
      facultyCount: parseInt(newDeptForm.facultyCount) || 8,
      studentCount: parseInt(newDeptForm.studentCount) || 120,
      hodEmail: newDeptForm.hodEmail || `hod.${newDeptForm.name.toLowerCase().replace(/\s+/g, "")}@stxaviers.edu`,
      iconType: newDeptForm.iconType
    };

    setDepartments([...departments, created]);
    setIsAddDeptModalOpen(false);
    showToast(`New department "${created.name}" added successfully!`);

    // Reset Form
    setNewDeptForm({
      name: "",
      code: "",
      hodEmail: "",
      facultyCount: "6",
      studentCount: "120",
      iconType: "cs"
    });
  };

  // Delete Department Handler
  const handleDeleteDepartment = (id: string, name: string) => {
    setDepartments(departments.filter((d) => d.id !== id));
    setOpenDeptMenuId(null);
    showToast(`Department "${name}" removed.`);
  };

  // Filtered Departments based on search
  const filteredDepartments = useMemo(() => {
    return departments.filter((d) => {
      const q = searchQuery.toLowerCase().trim();
      return !q || d.name.toLowerCase().includes(q) || d.code.toLowerCase().includes(q) || d.hodEmail.toLowerCase().includes(q);
    });
  }, [departments, searchQuery]);

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

      {/* Floating Bottom Right AI Assistance FAB */}
      <button
        onClick={() => showToast("AI Governance Assistant ready! How can I help configure placement rules?")}
        title="Quick AI Governance Assistant"
        className="fixed bottom-6 right-6 z-40 w-12 h-12 rounded-2xl bg-[#7C3AED] hover:bg-[#6B21A8] active:bg-purple-900 text-white flex items-center justify-center shadow-xl transition-transform hover:scale-105 cursor-pointer"
      >
        <Sparkles className="w-6 h-6 text-amber-300 fill-amber-300" />
      </button>

      {/* 1. Top Search Bar */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl md:text-3xl font-extrabold text-slate-900 tracking-tight">
            College Profile &amp; Settings
          </h1>
          <p className="text-xs md:text-sm text-slate-500 font-medium mt-1">
            Manage your institution&apos;s public identity, accreditation details, and departmental structure.
          </p>
        </div>

        {/* Global Settings Search Bar */}
        <div className="relative min-w-[240px] sm:min-w-[280px]">
          <Search className="w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search settings, users, or logs..."
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
      </div>

      {/* 2-COLUMN CONFIGURATION WORKSPACE GRID */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
        {/* COLUMN 1: SYSTEM CONFIGURATION NAVIGATION PANE (LEFT SUB-SIDEBAR - 3 COLS) */}
        <div className="lg:col-span-3 bg-white p-4 rounded-2xl border border-slate-100 shadow-xs space-y-3">
          <span className="text-[10px] font-extrabold text-slate-400 uppercase tracking-widest block px-2 pt-1">
            SYSTEM CONFIGURATION
          </span>

          <nav className="space-y-1">
            {/* Tab 1: College Profile */}
            <button
              onClick={() => setActiveTab("profile")}
              className={`w-full flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-xs md:text-sm font-bold transition-all cursor-pointer ${
                activeTab === "profile"
                  ? "bg-[#F3E8FF] text-[#7C3AED] shadow-2xs"
                  : "text-slate-600 hover:bg-slate-50 hover:text-slate-900"
              }`}
            >
              <Building2 className={`w-4 h-4 ${activeTab === "profile" ? "text-[#7C3AED]" : "text-slate-400"}`} />
              <span>College Profile</span>
            </button>

            {/* Tab 2: User Management */}
            <button
              onClick={() => setActiveTab("users")}
              className={`w-full flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-xs md:text-sm font-bold transition-all cursor-pointer ${
                activeTab === "users"
                  ? "bg-[#F3E8FF] text-[#7C3AED] shadow-2xs"
                  : "text-slate-600 hover:bg-slate-50 hover:text-slate-900"
              }`}
            >
              <Users className={`w-4 h-4 ${activeTab === "users" ? "text-[#7C3AED]" : "text-slate-400"}`} />
              <span>User Management</span>
            </button>

            {/* Tab 3: Notifications */}
            <button
              onClick={() => setActiveTab("notifications")}
              className={`w-full flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-xs md:text-sm font-bold transition-all cursor-pointer ${
                activeTab === "notifications"
                  ? "bg-[#F3E8FF] text-[#7C3AED] shadow-2xs"
                  : "text-slate-600 hover:bg-slate-50 hover:text-slate-900"
              }`}
            >
              <Bell className={`w-4 h-4 ${activeTab === "notifications" ? "text-[#7C3AED]" : "text-slate-400"}`} />
              <span>Notifications</span>
            </button>

            {/* Tab 4: Integrations */}
            <button
              onClick={() => setActiveTab("integrations")}
              className={`w-full flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-xs md:text-sm font-bold transition-all cursor-pointer ${
                activeTab === "integrations"
                  ? "bg-[#F3E8FF] text-[#7C3AED] shadow-2xs"
                  : "text-slate-600 hover:bg-slate-50 hover:text-slate-900"
              }`}
            >
              <Network className={`w-4 h-4 ${activeTab === "integrations" ? "text-[#7C3AED]" : "text-slate-400"}`} />
              <span>Integrations</span>
            </button>

            {/* Tab 5: Billing */}
            <button
              onClick={() => setActiveTab("billing")}
              className={`w-full flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-xs md:text-sm font-bold transition-all cursor-pointer ${
                activeTab === "billing"
                  ? "bg-[#F3E8FF] text-[#7C3AED] shadow-2xs"
                  : "text-slate-600 hover:bg-slate-50 hover:text-slate-900"
              }`}
            >
              <CreditCard className={`w-4 h-4 ${activeTab === "billing" ? "text-[#7C3AED]" : "text-slate-400"}`} />
              <span>Billing</span>
            </button>
          </nav>
        </div>

        {/* COLUMN 2: MAIN WORKSPACE & CONFIGURATION PANELS (9 COLS) */}
        <div className="lg:col-span-9 space-y-6">
          {activeTab === "profile" && (
            /* COLLEGE PROFILE WORKSPACE */
            <div className="space-y-6">
              {/* Workspace Header */}
              <div>
                <h2 className="text-xl font-extrabold text-slate-900">College Profile</h2>
                <p className="text-xs text-slate-500 font-medium mt-1">
                  Manage your institution&apos;s public identity, accreditation details, and departmental structure for recruitment drives.
                </p>
              </div>

              {/* Institution Profile Card */}
              <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-xs space-y-6">
                <form onSubmit={handleSaveProfileSubmit} className="space-y-6">
                  <div className="flex flex-col md:flex-row items-start gap-6">
                    {/* Logo Dropzone Upload Box (Left Side) */}
                    <div
                      onClick={() => fileInputRef.current?.click()}
                      className="w-32 h-32 rounded-2xl border-2 border-dashed border-slate-300 bg-slate-100/70 hover:bg-purple-50/50 flex flex-col items-center justify-center cursor-pointer text-center p-3 transition-all relative group shrink-0"
                    >
                      {logoPreview ? (
                        <img
                          src={logoPreview}
                          alt="College Logo Preview"
                          className="w-full h-full object-contain rounded-xl"
                        />
                      ) : (
                        <>
                          <div className="w-10 h-10 rounded-xl bg-purple-100 text-purple-700 flex items-center justify-center mb-2 group-hover:scale-105 transition-transform">
                            <Upload className="w-5 h-5 text-[#7C3AED]" />
                          </div>
                          <span className="text-[10px] font-extrabold text-[#7C3AED]">
                            Change Logo
                          </span>
                        </>
                      )}
                      <input
                        ref={fileInputRef}
                        type="file"
                        accept="image/*"
                        onChange={handleLogoUpload}
                        className="hidden"
                      />
                    </div>

                    {/* Form Grid Fields (Right Side) */}
                    <div className="flex-1 w-full space-y-4 text-xs font-medium">
                      {/* Institution Name */}
                      <div>
                        <label className="font-extrabold text-slate-600 block mb-1">
                          Institution Name
                        </label>
                        <input
                          type="text"
                          required
                          value={profileForm.institutionName}
                          onChange={(e) =>
                            setProfileForm({ ...profileForm, institutionName: e.target.value })
                          }
                          className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none text-slate-800 font-bold"
                        />
                      </div>

                      {/* Grid Row: Accreditation & College Type */}
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        {/* Accreditation (NAAC Grade) */}
                        <div>
                          <label className="font-extrabold text-slate-600 block mb-1">
                            Accreditation (NAAC Grade)
                          </label>
                          <div className="relative">
                            <select
                              value={profileForm.accreditation}
                              onChange={(e) =>
                                setProfileForm({ ...profileForm, accreditation: e.target.value })
                              }
                              className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none font-bold text-slate-800 appearance-none pr-8 cursor-pointer"
                            >
                              <option value="A++ (Active)">A++ (Active)</option>
                              <option value="A+">A+</option>
                              <option value="A">A</option>
                              <option value="B++">B++</option>
                              <option value="Unaccredited">Unaccredited</option>
                            </select>
                            <ChevronDown className="w-4 h-4 text-slate-400 absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none" />
                          </div>
                        </div>

                        {/* College Type */}
                        <div>
                          <label className="font-extrabold text-slate-600 block mb-1">
                            College Type
                          </label>
                          <input
                            type="text"
                            value={profileForm.collegeType}
                            onChange={(e) =>
                              setProfileForm({ ...profileForm, collegeType: e.target.value })
                            }
                            className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none font-bold text-slate-800"
                          />
                        </div>
                      </div>

                      {/* Campus Address */}
                      <div>
                        <label className="font-extrabold text-slate-600 block mb-1">
                          Campus Address
                        </label>
                        <textarea
                          rows={3}
                          value={profileForm.campusAddress}
                          onChange={(e) =>
                            setProfileForm({ ...profileForm, campusAddress: e.target.value })
                          }
                          className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none font-medium text-slate-800 leading-relaxed"
                        />
                      </div>
                    </div>
                  </div>

                  {/* Save Profile Settings Button */}
                  <div className="pt-2 border-t border-slate-100 flex justify-end">
                    <button
                      type="submit"
                      className="bg-[#7C3AED] hover:bg-[#6B21A8] active:bg-purple-900 text-white font-bold px-6 py-2.5 rounded-xl shadow-md shadow-purple-500/20 text-xs md:text-sm transition-all cursor-pointer transform hover:-translate-y-0.5"
                    >
                      Save Profile Settings
                    </button>
                  </div>
                </form>
              </div>

              {/* Department Management Module */}
              <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-xs space-y-4">
                <div className="flex items-center justify-between">
                  <h3 className="text-base font-extrabold text-slate-900">
                    Department Management
                  </h3>
                  <button
                    onClick={() => setIsAddDeptModalOpen(true)}
                    className="text-xs font-extrabold text-[#7C3AED] hover:underline flex items-center gap-1 cursor-pointer"
                  >
                    <Plus className="w-4 h-4 stroke-[2.5]" />
                    <span>Add Department</span>
                  </button>
                </div>

                {/* Department Grid Cards */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {filteredDepartments.map((dept) => (
                    <div
                      key={dept.id}
                      className="p-4 rounded-2xl border border-slate-200/80 bg-slate-50/50 hover:bg-purple-50/30 transition-all flex items-center justify-between gap-3 relative group"
                    >
                      <div className="flex items-center gap-3.5 min-w-0">
                        {/* Purple Icon Box */}
                        <div className="w-10 h-10 rounded-xl bg-purple-100 text-[#7C3AED] flex items-center justify-center shrink-0">
                          {dept.iconType === "cs" && <Laptop className="w-5 h-5" />}
                          {dept.iconType === "ece" && <Cpu className="w-5 h-5" />}
                          {dept.iconType === "mech" && <Wrench className="w-5 h-5" />}
                          {dept.iconType === "it" && <Server className="w-5 h-5" />}
                        </div>

                        <div className="min-w-0">
                          <h4 className="text-sm font-extrabold text-slate-900 truncate">
                            {dept.name}
                          </h4>
                          <p className="text-xs text-slate-400 font-semibold mt-0.5">
                            {dept.facultyCount} Faculty • {dept.studentCount} Students
                          </p>
                        </div>
                      </div>

                      {/* Options Menu (⋮) */}
                      <div className="relative">
                        <button
                          onClick={() =>
                            setOpenDeptMenuId(openDeptMenuId === dept.id ? null : dept.id)
                          }
                          className="text-slate-400 hover:text-slate-700 p-1.5 rounded-lg hover:bg-slate-100 transition-colors"
                        >
                          <MoreVertical className="w-4 h-4" />
                        </button>

                        {openDeptMenuId === dept.id && (
                          <div className="absolute right-0 top-8 bg-white border border-slate-200 rounded-xl shadow-xl p-1 z-20 min-w-[140px] text-xs font-semibold">
                            <button
                              onClick={() => {
                                setOpenDeptMenuId(null);
                                showToast(`Editing department ${dept.name}...`);
                              }}
                              className="w-full text-left px-3 py-1.5 hover:bg-purple-50 hover:text-purple-700 rounded-lg"
                            >
                              Edit Department
                            </button>
                            <button
                              onClick={() => {
                                setOpenDeptMenuId(null);
                                showToast(`Managing faculty roster for ${dept.name}...`);
                              }}
                              className="w-full text-left px-3 py-1.5 hover:bg-purple-50 hover:text-purple-700 rounded-lg"
                            >
                              Manage Faculty
                            </button>
                            <button
                              onClick={() => handleDeleteDepartment(dept.id, dept.name)}
                              className="w-full text-left px-3 py-1.5 hover:bg-rose-50 hover:text-rose-600 rounded-lg text-rose-600"
                            >
                              Delete
                            </button>
                          </div>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          {activeTab === "users" && (
            /* USER MANAGEMENT SUB-TAB PANEL */
            <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-xs space-y-5">
              <div className="flex items-center justify-between border-b border-slate-100 pb-4">
                <div>
                  <h3 className="text-lg font-extrabold text-slate-900">User Management &amp; Access Controls</h3>
                  <p className="text-xs text-slate-500 font-medium mt-0.5">
                    Assign role permissions for faculty, TPO coordinators, and HOD administrators.
                  </p>
                </div>
                <button
                  onClick={() => showToast("Invite user dialog opened.")}
                  className="bg-purple-600 hover:bg-purple-700 text-white font-bold text-xs px-4 py-2 rounded-xl shadow-xs"
                >
                  + Invite Member
                </button>
              </div>

              {/* Roles Table */}
              <div className="overflow-x-auto text-xs">
                <table className="w-full text-left border-collapse">
                  <thead>
                    <tr className="bg-slate-50 text-[11px] font-bold text-slate-400 uppercase border-b border-slate-100">
                      <th className="py-3 px-4">User Name</th>
                      <th className="py-3 px-4">Assigned Role</th>
                      <th className="py-3 px-4">Department</th>
                      <th className="py-3 px-4">Access Level</th>
                      <th className="py-3 px-4 text-right">Status</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100 font-medium text-slate-700">
                    <tr>
                      <td className="py-3.5 px-4 font-bold text-slate-900">Dr. Sarah Jenkins</td>
                      <td className="py-3.5 px-4 font-semibold text-purple-700">Super Administrator</td>
                      <td className="py-3.5 px-4">Central Placement Cell</td>
                      <td className="py-3.5 px-4">Full System Control</td>
                      <td className="py-3.5 px-4 text-right">
                        <span className="bg-emerald-100 text-emerald-700 text-[10px] font-black uppercase px-2.5 py-0.5 rounded-full">
                          Active
                        </span>
                      </td>
                    </tr>
                    <tr>
                      <td className="py-3.5 px-4 font-bold text-slate-900">Prof. Rajesh Kumar</td>
                      <td className="py-3.5 px-4 font-semibold text-purple-700">Senior TPO Officer</td>
                      <td className="py-3.5 px-4">Computer Science</td>
                      <td className="py-3.5 px-4">Drive &amp; Student Admin</td>
                      <td className="py-3.5 px-4 text-right">
                        <span className="bg-emerald-100 text-emerald-700 text-[10px] font-black uppercase px-2.5 py-0.5 rounded-full">
                          Active
                        </span>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {activeTab === "notifications" && (
            /* NOTIFICATIONS SUB-TAB PANEL */
            <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-xs space-y-6">
              <div className="border-b border-slate-100 pb-4">
                <h3 className="text-lg font-extrabold text-slate-900">Notification Alert Rules</h3>
                <p className="text-xs text-slate-500 font-medium mt-0.5">
                  Configure automated email and SMS notification triggers for students and recruiters.
                </p>
              </div>

              <div className="space-y-4 text-xs font-semibold">
                <div className="flex items-center justify-between p-3.5 bg-slate-50 rounded-xl border border-slate-100">
                  <div>
                    <div className="font-extrabold text-slate-900">New Placement Drive Email Broadcasts</div>
                    <div className="text-[11px] text-slate-500 font-normal">Automatically notify eligible candidates when a new drive opens.</div>
                  </div>
                  <input
                    type="checkbox"
                    checked={notifyState.emailDrives}
                    onChange={(e) => setNotifyState({ ...notifyState, emailDrives: e.target.checked })}
                    className="w-4 h-4 accent-purple-600 rounded cursor-pointer"
                  />
                </div>

                <div className="flex items-center justify-between p-3.5 bg-slate-50 rounded-xl border border-slate-100">
                  <div>
                    <div className="font-extrabold text-slate-900">SMS Reminders for Interview Slots</div>
                    <div className="text-[11px] text-slate-500 font-normal">Send instant SMS notifications 2 hours prior to scheduled interviews.</div>
                  </div>
                  <input
                    type="checkbox"
                    checked={notifyState.smsAlerts}
                    onChange={(e) => setNotifyState({ ...notifyState, smsAlerts: e.target.checked })}
                    className="w-4 h-4 accent-purple-600 rounded cursor-pointer"
                  />
                </div>
              </div>
            </div>
          )}

          {activeTab === "integrations" && (
            /* INTEGRATIONS SUB-TAB PANEL */
            <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-xs space-y-6">
              <div className="border-b border-slate-100 pb-4">
                <h3 className="text-lg font-extrabold text-slate-900">API Keys &amp; Webhook Integrations</h3>
                <p className="text-xs text-slate-500 font-medium mt-0.5">
                  Connect Campus2Corporate with your university ERP, LMS, and Slack communications.
                </p>
              </div>

              <div className="p-4 bg-slate-50 rounded-xl border border-slate-200 text-xs space-y-2">
                <span className="font-extrabold text-slate-800">University ERP Webhook Endpoint</span>
                <div className="font-mono text-[11px] bg-slate-200/80 p-2.5 rounded-lg text-slate-700">
                  https://api.campus2corporate.io/v1/webhooks/college-erp-sync
                </div>
              </div>
            </div>
          )}

          {activeTab === "billing" && (
            /* BILLING SUB-TAB PANEL */
            <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-xs space-y-6">
              <div className="border-b border-slate-100 pb-4">
                <h3 className="text-lg font-extrabold text-slate-900">Subscription Plan &amp; Billing Metrics</h3>
                <p className="text-xs text-slate-500 font-medium mt-0.5">
                  Your campus is currently enrolled on the Enterprise University Tier.
                </p>
              </div>

              <div className="grid grid-cols-2 gap-4 text-xs">
                <div className="p-4 bg-purple-50 border border-purple-200 rounded-xl space-y-1">
                  <span className="font-extrabold text-purple-700">ACTIVE PLAN</span>
                  <div className="text-xl font-black text-slate-900">Enterprise Campus Tier</div>
                </div>
                <div className="p-4 bg-slate-50 border border-slate-200 rounded-xl space-y-1">
                  <span className="font-extrabold text-slate-400">STUDENT CAPACITY</span>
                  <div className="text-xl font-black text-slate-900">5,000 / 10,000 Seats</div>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* MODAL: Add Department Modal */}
      {isAddDeptModalOpen && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl space-y-5 animate-in zoom-in-95 duration-200">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-xl bg-purple-100 text-purple-700 flex items-center justify-center font-bold">
                  +
                </div>
                <h3 className="text-lg font-extrabold text-slate-900">Add New Academic Department</h3>
              </div>
              <button
                onClick={() => setIsAddDeptModalOpen(false)}
                className="text-slate-400 hover:text-slate-600 p-1"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleAddDeptSubmit} className="space-y-4 text-xs font-medium">
              <div>
                <label className="font-bold text-slate-700 block mb-1">Department Name</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Civil Engineering / Artificial Intelligence"
                  value={newDeptForm.name}
                  onChange={(e) => setNewDeptForm({ ...newDeptForm, name: e.target.value })}
                  className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none font-bold"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Department Code</label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. AI / CIVIL"
                    value={newDeptForm.code}
                    onChange={(e) => setNewDeptForm({ ...newDeptForm, code: e.target.value })}
                    className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                  />
                </div>

                <div>
                  <label className="font-bold text-slate-700 block mb-1">Icon Style</label>
                  <select
                    value={newDeptForm.iconType}
                    onChange={(e) =>
                      setNewDeptForm({
                        ...newDeptForm,
                        iconType: e.target.value as DepartmentItem["iconType"]
                      })
                    }
                    className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                  >
                    <option value="cs">Computer (Laptop)</option>
                    <option value="ece">Electronics (CPU)</option>
                    <option value="mech">Mechanical (Wrench)</option>
                    <option value="it">Information Tech (Server)</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">HOD Email Address</label>
                <input
                  type="email"
                  placeholder="hod.dept@stxaviers.edu"
                  value={newDeptForm.hodEmail}
                  onChange={(e) => setNewDeptForm({ ...newDeptForm, hodEmail: e.target.value })}
                  className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Faculty Count</label>
                  <input
                    type="number"
                    value={newDeptForm.facultyCount}
                    onChange={(e) => setNewDeptForm({ ...newDeptForm, facultyCount: e.target.value })}
                    className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                  />
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Student Capacity</label>
                  <input
                    type="number"
                    value={newDeptForm.studentCount}
                    onChange={(e) => setNewDeptForm({ ...newDeptForm, studentCount: e.target.value })}
                    className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                  />
                </div>
              </div>

              <div className="flex items-center justify-end gap-3 pt-4 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setIsAddDeptModalOpen(false)}
                  className="px-4 py-2.5 text-slate-600 font-bold hover:bg-slate-100 rounded-xl"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="bg-[#7C3AED] hover:bg-[#6B21A8] text-white font-bold px-5 py-2.5 rounded-xl shadow-md shadow-purple-500/20"
                >
                  Save Department
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default SettingsView;
