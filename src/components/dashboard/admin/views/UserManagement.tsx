import React, { useState } from 'react';
import {
  Search,
  Download,
  Trash2,
  Ban,
  Eye,
  Edit2,
  Building,
  Briefcase,
  GraduationCap
} from 'lucide-react';

export const UserManagement: React.FC = () => {
  const [activeRoleTab, setActiveRoleTab] = useState<'students' | 'colleges' | 'recruiters'>('students');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCollegeFilter, setSelectedCollegeFilter] = useState('all');
  const [selectedYearFilter, setSelectedYearFilter] = useState('all');
  const [selectedStatusFilter, setSelectedStatusFilter] = useState('all');

  // Sample User Directory Data
  const studentData = [
    {
      id: 'usr_1',
      name: 'Rahul Sharma',
      email: 'rahul.s@techinst.edu',
      avatar: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&auto=format&fit=crop&q=80',
      college: 'Tech Institute A',
      branch: 'Computer Science',
      cgpa: '8.9',
      rms: '3 RMs',
      prjs: '5 PRJs',
      placementStatus: 'Placed',
      activeStatus: 'Active'
    },
    {
      id: 'usr_2',
      name: 'Priya Patel',
      email: 'p.patel@stateuniv.edu',
      avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&auto=format&fit=crop&q=80',
      college: 'State University',
      branch: 'Information Tech',
      cgpa: '7.5',
      rms: '1 RMs',
      prjs: '2 PRJs',
      placementStatus: 'Seeking',
      activeStatus: 'Active'
    },
    {
      id: 'usr_3',
      name: 'Aarav Kumar',
      email: 'a.kumar@bits.edu',
      avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&auto=format&fit=crop&q=80',
      college: 'BITS Engineering',
      branch: 'Electronics',
      cgpa: '9.2',
      rms: '4 RMs',
      prjs: '6 PRJs',
      placementStatus: 'Placed',
      activeStatus: 'Active'
    },
    {
      id: 'usr_4',
      name: 'Sneha Verma',
      email: 'sneha.v@global.edu',
      avatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&auto=format&fit=crop&q=80',
      college: 'Global Tech College',
      branch: 'Mechanical Eng.',
      cgpa: '6.8',
      rms: '2 RMs',
      prjs: '1 PRJs',
      placementStatus: 'Seeking',
      activeStatus: 'Suspended'
    }
  ];

  return (
    <div className="space-y-6 font-sans text-slate-800 pb-12">
      {/* Page Title & Search Bar */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-black text-slate-900 tracking-tight">User Management</h1>
          <p className="text-xs font-semibold text-slate-500 mt-1">
            Master Directory Oversight across Students, Institutions, and Recruiters.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <div className="relative w-64">
            <input
              type="text"
              placeholder="Global Search Cmd+K"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full px-3.5 py-2 pl-9 bg-white border border-slate-200 rounded-xl text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-[#6D28D9]/30 focus:border-[#6D28D9] shadow-2xs"
            />
            <Search className="w-3.5 h-3.5 text-slate-400 absolute left-3 top-2.5" />
          </div>
          <button className="bg-white border border-slate-200 hover:bg-slate-50 text-slate-700 font-bold px-3.5 py-2 rounded-xl text-xs flex items-center gap-2 shadow-2xs cursor-pointer transition-colors">
            <Download className="w-3.5 h-3.5 text-purple-700" />
            <span>Export All</span>
          </button>
        </div>
      </div>

      {/* Role Sub-Tabs */}
      <div className="flex items-center gap-2 border-b border-purple-100/70 pb-3">
        {[
          { id: 'students' as const, label: 'Students', icon: GraduationCap },
          { id: 'colleges' as const, label: 'Colleges', icon: Building },
          { id: 'recruiters' as const, label: 'Recruiters', icon: Briefcase },
        ].map((tab) => {
          const IconComp = tab.icon;
          const isActive = activeRoleTab === tab.id;
          return (
            <button
              key={tab.id}
              onClick={() => setActiveRoleTab(tab.id)}
              className={`px-4 py-2 rounded-xl text-xs font-bold transition-all duration-200 cursor-pointer flex items-center gap-2 ${
                isActive
                  ? 'bg-[#6D28D9] text-white shadow-md shadow-purple-600/20'
                  : 'text-slate-500 bg-white hover:bg-purple-50 hover:text-purple-900 border border-slate-200/60'
              }`}
            >
              <IconComp className="w-3.5 h-3.5" />
              <span>{tab.label}</span>
            </button>
          );
        })}
      </div>

      {/* Action Toolbar & Filters */}
      <div className="bg-white rounded-2xl p-4 border border-purple-100/70 shadow-xs flex flex-wrap items-center justify-between gap-4">
        {/* Bulk Action Buttons */}
        <div className="flex items-center gap-2">
          <button className="px-3 py-1.5 bg-red-50 hover:bg-red-100 text-red-600 border border-red-200/60 rounded-xl text-xs font-bold transition-colors cursor-pointer flex items-center gap-1.5">
            <Ban className="w-3.5 h-3.5" />
            <span>Suspend</span>
          </button>
          <button className="px-3 py-1.5 bg-slate-50 hover:bg-slate-100 text-slate-600 border border-slate-200/60 rounded-xl text-xs font-bold transition-colors cursor-pointer flex items-center gap-1.5">
            <Trash2 className="w-3.5 h-3.5" />
            <span>Delete</span>
          </button>
          <button className="px-3 py-1.5 bg-purple-50 hover:bg-purple-100 text-[#6D28D9] border border-purple-200/60 rounded-xl text-xs font-bold transition-colors cursor-pointer flex items-center gap-1.5">
            <Download className="w-3.5 h-3.5" />
            <span>Export Selected</span>
          </button>
        </div>

        {/* Filter Dropdowns */}
        <div className="flex items-center gap-3">
          <select
            value={selectedCollegeFilter}
            onChange={(e) => setSelectedCollegeFilter(e.target.value)}
            className="px-3 py-1.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold text-slate-700 focus:outline-none cursor-pointer"
          >
            <option value="all">All Colleges</option>
            <option value="tech_a">Tech Institute A</option>
            <option value="state_u">State University</option>
          </select>

          <select
            value={selectedYearFilter}
            onChange={(e) => setSelectedYearFilter(e.target.value)}
            className="px-3 py-1.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold text-slate-700 focus:outline-none cursor-pointer"
          >
            <option value="all">All Years</option>
            <option value="2025">2025</option>
            <option value="2026">2026</option>
          </select>

          <select
            value={selectedStatusFilter}
            onChange={(e) => setSelectedStatusFilter(e.target.value)}
            className="px-3 py-1.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold text-slate-700 focus:outline-none cursor-pointer"
          >
            <option value="all">Status: All</option>
            <option value="active">Active</option>
            <option value="suspended">Suspended</option>
          </select>
        </div>
      </div>

      {/* Master Directory Data Table */}
      <div className="bg-white rounded-2xl border border-purple-100/70 shadow-xs overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs font-semibold text-slate-700">
            <thead className="bg-slate-50 text-[10px] uppercase tracking-wider font-extrabold text-slate-400 border-b border-slate-100">
              <tr>
                <th className="py-3.5 px-4 w-10">
                  <input type="checkbox" className="rounded text-[#6D28D9] focus:ring-[#6D28D9]" />
                </th>
                <th className="py-3.5 px-4">Student</th>
                <th className="py-3.5 px-4">College / Branch</th>
                <th className="py-3.5 px-4">CGPA</th>
                <th className="py-3.5 px-4">Progress</th>
                <th className="py-3.5 px-4">Status</th>
                <th className="py-3.5 px-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {studentData.map((row) => (
                <tr key={row.id} className="hover:bg-purple-50/30 transition-colors">
                  <td className="py-3.5 px-4">
                    <input type="checkbox" className="rounded text-[#6D28D9] focus:ring-[#6D28D9]" />
                  </td>
                  <td className="py-3.5 px-4">
                    <div className="flex items-center gap-3">
                      <img
                        src={row.avatar}
                        alt={row.name}
                        className="w-8 h-8 rounded-full object-cover border border-purple-100"
                      />
                      <div>
                        <p className="font-bold text-slate-900 leading-tight">{row.name}</p>
                        <p className="text-[10px] text-slate-400 font-medium">{row.email}</p>
                      </div>
                    </div>
                  </td>
                  <td className="py-3.5 px-4">
                    <p className="font-bold text-slate-800">{row.college}</p>
                    <p className="text-[10px] text-slate-400">{row.branch}</p>
                  </td>
                  <td className="py-3.5 px-4 font-mono font-bold text-slate-900">{row.cgpa}</td>
                  <td className="py-3.5 px-4">
                    <div className="flex items-center gap-1.5">
                      <span className="bg-slate-100 border border-slate-200 px-2 py-0.5 rounded text-[10px] font-mono font-bold text-slate-700">
                        {row.rms}
                      </span>
                      <span className="bg-slate-100 border border-slate-200 px-2 py-0.5 rounded text-[10px] font-mono font-bold text-slate-700">
                        {row.prjs}
                      </span>
                    </div>
                  </td>
                  <td className="py-3.5 px-4">
                    <div className="flex flex-col items-start gap-1">
                      <span
                        className={`px-2 py-0.5 rounded-full text-[10px] font-bold ${
                          row.placementStatus === 'Placed'
                            ? 'bg-emerald-50 text-emerald-700 border border-emerald-200'
                            : 'bg-amber-50 text-amber-700 border border-amber-200'
                        }`}
                      >
                        {row.placementStatus}
                      </span>
                      <span
                        className={`text-[9px] font-extrabold uppercase ${
                          row.activeStatus === 'Active' ? 'text-slate-500' : 'text-red-500'
                        }`}
                      >
                        {row.activeStatus}
                      </span>
                    </div>
                  </td>
                  <td className="py-3.5 px-4 text-right">
                    <div className="flex items-center justify-end gap-1.5">
                      <button className="p-1.5 text-slate-400 hover:text-purple-700 hover:bg-purple-50 rounded-lg transition-colors cursor-pointer">
                        <Eye className="w-3.5 h-3.5" />
                      </button>
                      <button className="p-1.5 text-slate-400 hover:text-purple-700 hover:bg-purple-50 rounded-lg transition-colors cursor-pointer">
                        <Edit2 className="w-3.5 h-3.5" />
                      </button>
                      <button className="p-1.5 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-colors cursor-pointer">
                        <Trash2 className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Pagination Bar */}
        <div className="p-4 bg-slate-50/60 border-t border-slate-100 flex items-center justify-between text-xs text-slate-500 font-medium">
          <span>Showing 1 to 4 of 245 entries</span>
          <div className="flex items-center gap-1">
            <button className="px-3 py-1 bg-white border border-slate-200 rounded-lg font-bold text-slate-400 hover:text-slate-600 cursor-pointer">
              Prev
            </button>
            <button className="px-3 py-1 bg-[#6D28D9] text-white rounded-lg font-bold shadow-xs cursor-pointer">
              1
            </button>
            <button className="px-3 py-1 bg-white border border-slate-200 rounded-lg font-bold text-slate-600 hover:bg-slate-50 cursor-pointer">
              2
            </button>
            <button className="px-3 py-1 bg-white border border-slate-200 rounded-lg font-bold text-slate-600 hover:bg-slate-50 cursor-pointer">
              Next
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default UserManagement;
