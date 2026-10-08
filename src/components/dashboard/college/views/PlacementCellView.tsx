import React, { useState } from "react";
import { UserPlus, ShieldCheck, CheckCircle2, Trash2, Plus, Building, Users } from "lucide-react";

export interface StaffMember {
  id: string;
  name: string;
  designation: string;
  role: "TPO Officer" | "HOD Admin" | "System Admin";
  department: string;
  email: string;
  phone: string;
  accessLevel: "Full Access" | "Department Level" | "Read Only";
  status: "Active" | "Pending Approval";
}

export const PlacementCellView: React.FC = () => {
  const [staffList, setStaffList] = useState<StaffMember[]>([
    {
      id: "STF-101",
      name: "Dr. Sarah Jenkins",
      designation: "Head of Training & Placement",
      role: "System Admin",
      department: "Central Placement Cell",
      email: "sarah.jenkins@apex.edu",
      phone: "+91 98765 43210",
      accessLevel: "Full Access",
      status: "Active"
    },
    {
      id: "STF-102",
      name: "Prof. Rajesh Kumar",
      designation: "Senior TPO Officer",
      role: "TPO Officer",
      department: "Computer Science & IT",
      email: "rajesh.k@apex.edu",
      phone: "+91 98123 45678",
      accessLevel: "Full Access",
      status: "Active"
    },
    {
      id: "STF-103",
      name: "Dr. Ananya Rao",
      designation: "Head of Department (CSE)",
      role: "HOD Admin",
      department: "Computer Science",
      email: "ananya.rao@apex.edu",
      phone: "+91 97654 32109",
      accessLevel: "Department Level",
      status: "Active"
    },
    {
      id: "STF-104",
      name: "Prof. Vikram Malhotra",
      designation: "Head of Department (ME)",
      role: "HOD Admin",
      department: "Mechanical Engineering",
      email: "vikram.m@apex.edu",
      phone: "+91 98989 12345",
      accessLevel: "Department Level",
      status: "Active"
    }
  ]);

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [newMember, setNewMember] = useState({
    name: "",
    designation: "",
    role: "TPO Officer" as StaffMember["role"],
    department: "Computer Science",
    email: "",
    phone: "",
    accessLevel: "Full Access" as StaffMember["accessLevel"]
  });

  const handleAddMember = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newMember.name || !newMember.email) return;

    const created: StaffMember = {
      id: `STF-${100 + staffList.length + 1}`,
      name: newMember.name,
      designation: newMember.designation || "TPO Member",
      role: newMember.role,
      department: newMember.department,
      email: newMember.email,
      phone: newMember.phone || "+91 90000 00000",
      accessLevel: newMember.accessLevel,
      status: "Active"
    };

    setStaffList([...staffList, created]);
    setIsModalOpen(false);
    setNewMember({
      name: "",
      designation: "",
      role: "TPO Officer",
      department: "Computer Science",
      email: "",
      phone: "",
      accessLevel: "Full Access"
    });
  };

  const handleDelete = (id: string) => {
    setStaffList(staffList.filter((s) => s.id !== id));
  };

  return (
    <div className="space-y-6">
      {/* Banner / College Header Governance Box */}
      <div className="bg-gradient-to-r from-purple-700 via-indigo-700 to-purple-900 rounded-2xl p-6 text-white shadow-lg shadow-purple-500/15 flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 mb-2">
            <span className="bg-emerald-400/20 text-emerald-300 text-[10px] font-extrabold px-2.5 py-0.5 rounded-full border border-emerald-400/30 flex items-center gap-1">
              <CheckCircle2 className="w-3 h-3 text-emerald-400" /> Verification Status: Admin Approved
            </span>
            <span className="text-xs text-purple-200 font-mono">AISHE Code: C-41209</span>
          </div>
          <h1 className="text-2xl md:text-3xl font-extrabold tracking-tight">
            Apex Institute of Technology & Engineering
          </h1>
          <p className="text-xs text-purple-200 font-medium mt-1">
            Verified Autonomous University • NAAC A+ Grade • NBA Accredited Programs
          </p>
        </div>

        <button
          onClick={() => setIsModalOpen(true)}
          className="bg-white hover:bg-purple-50 text-purple-700 font-bold text-xs md:text-sm px-5 py-3 rounded-xl shadow-md transition-all flex items-center gap-2 cursor-pointer whitespace-nowrap"
        >
          <UserPlus className="w-4 h-4" /> Add Staff Member
        </button>
      </div>

      {/* KPI Governance Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-slate-400 uppercase">Authorized Staff</span>
            <Users className="w-4 h-4 text-purple-600" />
          </div>
          <div className="text-2xl font-black text-slate-900 mt-2">{staffList.length}</div>
          <span className="text-[11px] font-bold text-emerald-600">100% Verified Accounts</span>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-slate-400 uppercase">Active TPO Officers</span>
            <Building className="w-4 h-4 text-purple-600" />
          </div>
          <div className="text-2xl font-black text-slate-900 mt-2">
            {staffList.filter((s) => s.role === "TPO Officer" || s.role === "System Admin").length}
          </div>
          <span className="text-[11px] font-medium text-slate-500">Managing Drives & Placements</span>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-slate-400 uppercase">HOD Department Admins</span>
            <ShieldCheck className="w-4 h-4 text-purple-600" />
          </div>
          <div className="text-2xl font-black text-slate-900 mt-2">
            {staffList.filter((s) => s.role === "HOD Admin").length}
          </div>
          <span className="text-[11px] font-medium text-slate-500">Academic Stream Oversight</span>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-slate-400 uppercase">Compliance Audit</span>
            <ShieldCheck className="w-4 h-4 text-emerald-600" />
          </div>
          <div className="text-2xl font-black text-emerald-600 mt-2">Pass</div>
          <span className="text-[11px] font-medium text-slate-500">All Security Audits Up to Date</span>
        </div>
      </div>

      {/* Authorized Staff Table */}
      <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
          <div>
            <h2 className="text-lg font-bold text-slate-900">
              Authorized Staff & Department Governance
            </h2>
            <p className="text-xs text-slate-500 font-medium">
              Manage TPO members, HOD admins, and internal access permissions.
            </p>
          </div>
          <button
            onClick={() => setIsModalOpen(true)}
            className="bg-purple-50 hover:bg-purple-100 text-purple-700 font-bold text-xs px-4 py-2 rounded-xl border border-purple-200 flex items-center gap-1.5 cursor-pointer"
          >
            <Plus className="w-4 h-4" /> Add TPO / HOD Member
          </button>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="border-b border-slate-100 text-[11px] font-bold text-slate-400 uppercase tracking-wider bg-slate-50/50">
                <th className="py-3 px-4">Staff Member</th>
                <th className="py-3 px-4">Role / Designation</th>
                <th className="py-3 px-4">Department</th>
                <th className="py-3 px-4">Contact Info</th>
                <th className="py-3 px-4">Access Level</th>
                <th className="py-3 px-4">Status</th>
                <th className="py-3 px-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-xs font-medium">
              {staffList.map((st) => (
                <tr key={st.id} className="hover:bg-slate-50/80 transition-colors">
                  <td className="py-4 px-4 font-bold text-slate-900">
                    <div>{st.name}</div>
                    <div className="text-[10px] text-slate-400 font-mono font-normal">{st.id}</div>
                  </td>
                  <td className="py-4 px-4">
                    <div className="text-slate-800 font-medium">{st.designation}</div>
                    <span className="inline-block mt-0.5 text-[10px] font-bold px-2 py-0.5 rounded-md bg-purple-50 text-purple-700">
                      {st.role}
                    </span>
                  </td>
                  <td className="py-4 px-4 text-slate-700">{st.department}</td>
                  <td className="py-4 px-4">
                    <div className="text-slate-700">{st.email}</div>
                    <div className="text-[10px] text-slate-400">{st.phone}</div>
                  </td>
                  <td className="py-4 px-4">
                    <span className="bg-slate-100 text-slate-700 text-[10px] font-bold px-2.5 py-1 rounded-md">
                      {st.accessLevel}
                    </span>
                  </td>
                  <td className="py-4 px-4">
                    <span className="bg-emerald-100 text-emerald-700 text-[10px] font-bold px-2.5 py-1 rounded-full">
                      {st.status}
                    </span>
                  </td>
                  <td className="py-4 px-4 text-right">
                    <button
                      onClick={() => handleDelete(st.id)}
                      className="text-slate-400 hover:text-red-600 p-1.5 rounded-lg hover:bg-red-50 transition-colors"
                      title="Remove Member"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Add Staff Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl space-y-4">
            <h3 className="text-lg font-bold text-slate-900">Add Staff / TPO Member</h3>

            <form onSubmit={handleAddMember} className="space-y-3">
              <div>
                <label className="text-xs font-bold text-slate-700 block mb-1">Full Name</label>
                <input
                  type="text"
                  required
                  value={newMember.name}
                  onChange={(e) => setNewMember({ ...newMember, name: e.target.value })}
                  placeholder="e.g. Dr. Sarah Jenkins"
                  className="w-full text-xs p-2.5 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                />
              </div>

              <div>
                <label className="text-xs font-bold text-slate-700 block mb-1">Designation</label>
                <input
                  type="text"
                  value={newMember.designation}
                  onChange={(e) => setNewMember({ ...newMember, designation: e.target.value })}
                  placeholder="e.g. Senior TPO Officer"
                  className="w-full text-xs p-2.5 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="text-xs font-bold text-slate-700 block mb-1">Role</label>
                  <select
                    value={newMember.role}
                    onChange={(e) => setNewMember({ ...newMember, role: e.target.value as StaffMember["role"] })}
                    className="w-full text-xs p-2.5 border border-slate-200 rounded-xl outline-none"
                  >
                    <option value="TPO Officer">TPO Officer</option>
                    <option value="HOD Admin">HOD Admin</option>
                    <option value="System Admin">System Admin</option>
                  </select>
                </div>

                <div>
                  <label className="text-xs font-bold text-slate-700 block mb-1">Access Level</label>
                  <select
                    value={newMember.accessLevel}
                    onChange={(e) => setNewMember({ ...newMember, accessLevel: e.target.value as StaffMember["accessLevel"] })}
                    className="w-full text-xs p-2.5 border border-slate-200 rounded-xl outline-none"
                  >
                    <option value="Full Access">Full Access</option>
                    <option value="Department Level">Department Level</option>
                    <option value="Read Only">Read Only</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="text-xs font-bold text-slate-700 block mb-1">Email Address</label>
                <input
                  type="email"
                  required
                  value={newMember.email}
                  onChange={(e) => setNewMember({ ...newMember, email: e.target.value })}
                  placeholder="name@apex.edu"
                  className="w-full text-xs p-2.5 border border-slate-200 rounded-xl outline-none"
                />
              </div>

              <div className="flex items-center justify-end gap-3 pt-4 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="text-xs font-semibold text-slate-600 px-4 py-2 hover:bg-slate-100 rounded-xl"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="text-xs font-semibold bg-purple-600 hover:bg-purple-700 text-white px-5 py-2.5 rounded-xl shadow-md"
                >
                  Save Member
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
