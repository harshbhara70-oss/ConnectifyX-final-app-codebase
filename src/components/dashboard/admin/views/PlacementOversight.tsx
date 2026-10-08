import React, { useState } from 'react';
import {
  Briefcase,
  Building2,
  Users,
  Award,
  Calendar as CalendarIcon,
  Download,
  Search,
  MoreVertical,
  ChevronLeft,
  ChevronRight
} from 'lucide-react';

export const PlacementOversight: React.FC = () => {
  const [selectedCollege, setSelectedCollege] = useState('all');
  const [selectedCompany, setSelectedCompany] = useState('all');
  const [dateQuery, setDateQuery] = useState('');
  const [searchDriveQuery, setSearchDriveQuery] = useState('');

  // Sample Active Drives Data
  const drivesData = [
    {
      id: 'drv_1',
      college: 'Engineering Institute',
      company: 'TechNova Corp',
      role: 'SDE I',
      type: 'On-Campus',
      deadline: 'Oct 20, 2024',
      applicants: 450,
      status: 'In Progress',
      statusColor: 'bg-[#6D28D9]/10 text-[#6D28D9] border-[#6D28D9]/20'
    },
    {
      id: 'drv_2',
      college: 'State University Business',
      company: 'Global Finance Inc',
      role: 'Financial Analyst',
      type: 'Pooled',
      deadline: 'Oct 18, 2024',
      applicants: 820,
      status: 'Assessment Phase',
      statusColor: 'bg-emerald-50 text-emerald-700 border-emerald-200'
    },
    {
      id: 'drv_3',
      college: 'Tech Arts College',
      company: 'DesignHub',
      role: 'UX Designer',
      type: 'On-Campus',
      deadline: 'Oct 12, 2024',
      applicants: 120,
      status: 'Completed',
      statusColor: 'bg-slate-100 text-slate-600 border-slate-200'
    }
  ];

  return (
    <div className="space-y-8 font-sans text-slate-800 pb-12">
      {/* Header Banner & Filters */}
      <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-black text-slate-900 tracking-tight">Placement Oversight</h1>
          <p className="text-xs font-semibold text-slate-500 mt-1">
            Master control for all ongoing and upcoming placement drives.
          </p>
        </div>

        {/* Filter Controls */}
        <div className="flex flex-wrap items-center gap-3">
          <select
            value={selectedCollege}
            onChange={(e) => setSelectedCollege(e.target.value)}
            className="px-3.5 py-2 bg-white border border-slate-200 rounded-xl text-xs font-bold text-slate-700 focus:outline-none cursor-pointer shadow-2xs"
          >
            <option value="all">All Colleges</option>
            <option value="eng_inst">Engineering Institute</option>
            <option value="state_u">State University</option>
          </select>

          <select
            value={selectedCompany}
            onChange={(e) => setSelectedCompany(e.target.value)}
            className="px-3.5 py-2 bg-white border border-slate-200 rounded-xl text-xs font-bold text-slate-700 focus:outline-none cursor-pointer shadow-2xs"
          >
            <option value="all">All Companies</option>
            <option value="technova">TechNova Corp</option>
            <option value="global_fin">Global Finance</option>
          </select>

          <input
            type="date"
            value={dateQuery}
            onChange={(e) => setDateQuery(e.target.value)}
            className="px-3.5 py-2 bg-white border border-slate-200 rounded-xl text-xs font-bold text-slate-700 focus:outline-none cursor-pointer shadow-2xs"
          />

          <button className="bg-[#6D28D9] hover:bg-[#5B21B6] text-white font-bold px-4 py-2 rounded-xl text-xs flex items-center gap-2 shadow-md shadow-purple-500/20 transition-all cursor-pointer">
            <Download className="w-3.5 h-3.5" />
            <span>Export Report</span>
          </button>
        </div>
      </div>

      {/* Metric Summary Tiles (4 Cards) */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        <div className="bg-white rounded-2xl p-5 border border-purple-100/70 shadow-xs flex items-center justify-between">
          <div className="space-y-1">
            <div className="flex items-center gap-2 text-[10px] font-extrabold uppercase tracking-wider text-slate-400">
              <Briefcase className="w-3.5 h-3.5 text-purple-600" />
              <span>Active Drives</span>
            </div>
            <p className="text-2xl font-black text-slate-900">142</p>
          </div>
        </div>

        <div className="bg-white rounded-2xl p-5 border border-purple-100/70 shadow-xs flex items-center justify-between">
          <div className="space-y-1">
            <div className="flex items-center gap-2 text-[10px] font-extrabold uppercase tracking-wider text-slate-400">
              <Building2 className="w-3.5 h-3.5 text-purple-600" />
              <span>Participating Colleges</span>
            </div>
            <p className="text-2xl font-black text-slate-900">38</p>
          </div>
        </div>

        <div className="bg-white rounded-2xl p-5 border border-purple-100/70 shadow-xs flex items-center justify-between">
          <div className="space-y-1">
            <div className="flex items-center gap-2 text-[10px] font-extrabold uppercase tracking-wider text-slate-400">
              <Users className="w-3.5 h-3.5 text-purple-600" />
              <span>Total Applicants</span>
            </div>
            <p className="text-2xl font-black text-slate-900">12,450</p>
          </div>
        </div>

        <div className="bg-white rounded-2xl p-5 border border-purple-100/70 shadow-xs flex items-center justify-between">
          <div className="space-y-1">
            <div className="flex items-center gap-2 text-[10px] font-extrabold uppercase tracking-wider text-slate-400">
              <Award className="w-3.5 h-3.5 text-purple-600" />
              <span>Offers Extended</span>
            </div>
            <p className="text-2xl font-black text-slate-900">2,105</p>
          </div>
        </div>
      </div>

      {/* Calendar & Upcoming Critical Events Feed Section */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Master Placement Calendar Widget */}
        <div className="lg:col-span-2 bg-white rounded-2xl p-6 border border-purple-100/70 shadow-xs space-y-4">
          <div className="flex items-center justify-between">
            <h3 className="text-base font-bold text-slate-900">Master Placement Calendar</h3>
            <div className="flex items-center gap-2 text-xs font-bold text-slate-600">
              <button className="p-1 hover:bg-slate-100 rounded-lg cursor-pointer">
                <ChevronLeft className="w-4 h-4 text-slate-400" />
              </button>
              <span>October 2024</span>
              <button className="p-1 hover:bg-slate-100 rounded-lg cursor-pointer">
                <ChevronRight className="w-4 h-4 text-slate-400" />
              </button>
            </div>
          </div>

          {/* Interactive Calendar Placeholder Graphics */}
          <div className="bg-slate-50 border border-slate-200/70 rounded-2xl p-12 flex flex-col items-center justify-center text-center space-y-3 min-h-[220px]">
            <div className="w-12 h-12 rounded-2xl bg-white border border-purple-100 shadow-xs flex items-center justify-center text-purple-600">
              <CalendarIcon className="w-6 h-6" />
            </div>
            <div>
              <p className="text-sm font-bold text-slate-900">Interactive Calendar View</p>
              <p className="text-xs text-slate-400 mt-1 font-medium">Loading placement drive schedules and interview slots...</p>
            </div>
          </div>
        </div>

        {/* Upcoming Critical Events Feed */}
        <div className="bg-white rounded-2xl p-6 border border-purple-100/70 shadow-xs space-y-4">
          <h3 className="text-base font-bold text-slate-900">Upcoming Critical Events</h3>

          <div className="space-y-4 pt-1">
            {[
              {
                title: 'Final Interview - TechNova',
                desc: 'Engineering Institute • Tomorrow, 9:00 AM',
                color: 'bg-red-500'
              },
              {
                title: 'Assessment Test - Global Fin',
                desc: 'State University • Oct 15, 2:00 PM',
                color: 'bg-[#6D28D9]'
              },
              {
                title: 'Pre-placement Talk - InnovateCo',
                desc: 'Tech Arts College • Oct 16, 10:00 AM',
                color: 'bg-emerald-500'
              }
            ].map((evt, idx) => (
              <div key={idx} className="flex items-start gap-3 p-3 rounded-xl hover:bg-purple-50/40 transition-colors">
                <span className={`w-2.5 h-2.5 rounded-full ${evt.color} shrink-0 mt-1.5`}></span>
                <div className="space-y-0.5">
                  <p className="text-xs font-bold text-slate-900">{evt.title}</p>
                  <p className="text-[11px] font-medium text-slate-400">{evt.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Active Drives Oversight Table */}
      <div className="bg-white rounded-2xl border border-purple-100/70 shadow-xs overflow-hidden space-y-4 p-6">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-slate-100 pb-4">
          <h3 className="text-base font-bold text-slate-900">Active Drives Oversight</h3>
          <div className="relative w-64">
            <input
              type="text"
              placeholder="Filter drives..."
              value={searchDriveQuery}
              onChange={(e) => setSearchDriveQuery(e.target.value)}
              className="w-full px-3.5 py-1.5 pl-9 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold text-slate-800 focus:outline-none"
            />
            <Search className="w-3.5 h-3.5 text-slate-400 absolute left-3 top-2.5" />
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs font-semibold text-slate-700">
            <thead className="bg-slate-50 text-[10px] uppercase tracking-wider font-extrabold text-slate-400 border-y border-slate-100">
              <tr>
                <th className="py-3.5 px-4">College Name</th>
                <th className="py-3.5 px-4">Company</th>
                <th className="py-3.5 px-4">Role</th>
                <th className="py-3.5 px-4">Type</th>
                <th className="py-3.5 px-4">Deadline</th>
                <th className="py-3.5 px-4 font-mono">Applicants</th>
                <th className="py-3.5 px-4">Status</th>
                <th className="py-3.5 px-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {drivesData.map((drive) => (
                <tr key={drive.id} className="hover:bg-purple-50/30 transition-colors">
                  <td className="py-3.5 px-4 font-bold text-slate-900">{drive.college}</td>
                  <td className="py-3.5 px-4 font-bold text-purple-700">{drive.company}</td>
                  <td className="py-3.5 px-4 text-slate-600">{drive.role}</td>
                  <td className="py-3.5 px-4 text-slate-500">{drive.type}</td>
                  <td className="py-3.5 px-4 font-mono text-slate-500">{drive.deadline}</td>
                  <td className="py-3.5 px-4 font-mono font-bold text-slate-900">{drive.applicants}</td>
                  <td className="py-3.5 px-4">
                    <span className={`px-2.5 py-1 rounded-full text-[10px] font-bold border ${drive.statusColor}`}>
                      {drive.status}
                    </span>
                  </td>
                  <td className="py-3.5 px-4 text-right">
                    <button className="p-1 text-slate-400 hover:text-slate-700 rounded cursor-pointer">
                      <MoreVertical className="w-4 h-4" />
                    </button>
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

export default PlacementOversight;
