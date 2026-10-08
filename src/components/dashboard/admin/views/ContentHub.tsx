import React, { useState } from 'react';
import {
  Plus,
  Star,
  Search,
  MoreVertical,
  X
} from 'lucide-react';

export const ContentHub: React.FC = () => {
  const [activeTab, setActiveTab] = useState<'roadmaps' | 'resources'>('roadmaps');
  const [showAddModal, setShowAddModal] = useState(false);
  const [newRoadmapTitle, setNewRoadmapTitle] = useState('');
  const [newCategory, setNewCategory] = useState('Tech');

  // Sample Content Data
  const roadmaps = [
    {
      id: 'rm_1',
      title: 'Full-Stack Engineering 2025',
      starred: true,
      category: 'Tech',
      status: 'Published',
      enrollments: '4,281',
      completion: 68,
      lastUpdated: 'Oct 12, 2024'
    },
    {
      id: 'rm_2',
      title: 'Data Analytics Foundations',
      starred: true,
      category: 'Tech',
      status: 'Published',
      enrollments: '2,105',
      completion: 45,
      lastUpdated: 'Oct 10, 2024'
    },
    {
      id: 'rm_3',
      title: 'Product Management Essentials',
      starred: false,
      category: 'Business',
      status: 'Under Review',
      enrollments: '0',
      completion: 0,
      lastUpdated: 'Oct 15, 2024'
    },
    {
      id: 'rm_4',
      title: 'Corporate Communication',
      starred: false,
      category: 'Non-Tech',
      status: 'Draft',
      enrollments: '--',
      completion: 0,
      lastUpdated: 'Oct 18, 2024'
    }
  ];

  return (
    <div className="space-y-6 font-sans text-slate-800 pb-12">
      {/* Top Banner Header & Add Roadmap Button */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-black text-slate-900 tracking-tight">Content Hub</h1>
          <p className="text-xs font-semibold text-slate-500 mt-1">
            Manage career roadmaps, skill modules, and global resource libraries.
          </p>
        </div>
        <button
          onClick={() => setShowAddModal(true)}
          className="bg-[#6D28D9] hover:bg-[#5B21B6] text-white font-bold px-4 py-2.5 rounded-xl text-xs flex items-center gap-2 shadow-md shadow-purple-500/20 transition-all cursor-pointer self-start sm:self-auto"
        >
          <Plus className="w-4 h-4" />
          <span>Add New Roadmap</span>
        </button>
      </div>

      {/* Navigation Sub-Tabs */}
      <div className="flex items-center gap-3 border-b border-purple-100/70 pb-3">
        <button
          onClick={() => setActiveTab('roadmaps')}
          className={`px-4 py-2 rounded-xl text-xs font-bold transition-all cursor-pointer ${
            activeTab === 'roadmaps'
              ? 'bg-[#6D28D9] text-white shadow-md shadow-purple-600/20'
              : 'bg-white text-slate-600 hover:bg-purple-50 border border-slate-200/60'
          }`}
        >
          Roadmaps
        </button>
        <button
          onClick={() => setActiveTab('resources')}
          className={`px-4 py-2 rounded-xl text-xs font-bold transition-all cursor-pointer ${
            activeTab === 'resources'
              ? 'bg-[#6D28D9] text-white shadow-md shadow-purple-600/20'
              : 'bg-white text-slate-600 hover:bg-purple-50 border border-slate-200/60'
          }`}
        >
          Resource Library
        </button>
      </div>

      {/* Filter Bar */}
      <div className="bg-white rounded-2xl p-4 border border-purple-100/70 shadow-xs flex flex-wrap items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <select className="px-3 py-1.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold text-slate-700 focus:outline-none cursor-pointer">
            <option>All Categories</option>
            <option>Tech</option>
            <option>Business</option>
            <option>Non-Tech</option>
          </select>
          <select className="px-3 py-1.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold text-slate-700 focus:outline-none cursor-pointer">
            <option>Status: All</option>
            <option>Published</option>
            <option>Under Review</option>
            <option>Draft</option>
          </select>
        </div>

        <div className="relative w-64">
          <input
            type="text"
            placeholder="Filter content..."
            className="w-full px-3.5 py-1.5 pl-9 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold text-slate-800 focus:outline-none"
          />
          <Search className="w-3.5 h-3.5 text-slate-400 absolute left-3 top-2.5" />
        </div>
      </div>

      {/* Content Data Grid Table */}
      <div className="bg-white rounded-2xl border border-purple-100/70 shadow-xs overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs font-semibold text-slate-700">
            <thead className="bg-slate-50 text-[10px] uppercase tracking-wider font-extrabold text-slate-400 border-b border-slate-100">
              <tr>
                <th className="py-3.5 px-4 w-10">
                  <input type="checkbox" className="rounded text-[#6D28D9] focus:ring-[#6D28D9]" />
                </th>
                <th className="py-3.5 px-4">Roadmap Title</th>
                <th className="py-3.5 px-4">Category</th>
                <th className="py-3.5 px-4">Status</th>
                <th className="py-3.5 px-4">Enrollments</th>
                <th className="py-3.5 px-4 w-32">Completion</th>
                <th className="py-3.5 px-4">Last Updated</th>
                <th className="py-3.5 px-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {roadmaps.map((row) => (
                <tr key={row.id} className="hover:bg-purple-50/30 transition-colors">
                  <td className="py-3.5 px-4">
                    <input type="checkbox" className="rounded text-[#6D28D9] focus:ring-[#6D28D9]" />
                  </td>
                  <td className="py-3.5 px-4">
                    <div className="flex items-center gap-2.5">
                      <Star
                        className={`w-4 h-4 cursor-pointer ${
                          row.starred ? 'fill-amber-400 text-amber-400' : 'text-slate-300 hover:text-amber-400'
                        }`}
                      />
                      <span className="font-bold text-slate-900">{row.title}</span>
                    </div>
                  </td>
                  <td className="py-3.5 px-4 font-bold text-slate-600">{row.category}</td>
                  <td className="py-3.5 px-4">
                    <span
                      className={`px-2.5 py-1 rounded-full text-[10px] font-bold ${
                        row.status === 'Published'
                          ? 'bg-emerald-50 text-emerald-700 border border-emerald-200'
                          : row.status === 'Under Review'
                          ? 'bg-amber-50 text-amber-700 border border-amber-200'
                          : 'bg-slate-100 text-slate-600 border border-slate-200'
                      }`}
                    >
                      {row.status}
                    </span>
                  </td>
                  <td className="py-3.5 px-4 font-mono font-bold">{row.enrollments}</td>
                  <td className="py-3.5 px-4">
                    <div className="flex items-center gap-2">
                      <div className="flex-1 h-2 bg-slate-100 rounded-full overflow-hidden">
                        <div
                          className="h-full bg-[#6D28D9] rounded-full"
                          style={{ width: `${row.completion}%` }}
                        ></div>
                      </div>
                      <span className="text-[10px] font-bold text-slate-500 w-8">{row.completion}%</span>
                    </div>
                  </td>
                  <td className="py-3.5 px-4 text-slate-500 font-mono text-[11px]">{row.lastUpdated}</td>
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

        {/* Footer info */}
        <div className="p-4 bg-slate-50/60 border-t border-slate-100 flex items-center justify-between text-xs text-slate-500 font-medium">
          <span>Showing 1 to 4 of 24 results</span>
          <div className="flex items-center gap-1 font-bold">
            <button className="w-7 h-7 rounded bg-[#6D28D9] text-white flex items-center justify-center">1</button>
            <button className="w-7 h-7 rounded bg-white border border-slate-200 hover:bg-slate-50 text-slate-700 flex items-center justify-center">2</button>
            <button className="w-7 h-7 rounded bg-white border border-slate-200 hover:bg-slate-50 text-slate-700 flex items-center justify-center">3</button>
          </div>
        </div>
      </div>

      {/* Add New Roadmap Modal */}
      {showAddModal && (
        <div className="fixed inset-0 z-50 bg-slate-900/50 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl p-6 sm:p-8 w-full max-w-md border border-purple-100 shadow-2xl space-y-6 animate-in fade-in zoom-in-95">
            <div className="flex items-center justify-between border-b border-slate-100 pb-4">
              <h2 className="text-lg font-black text-slate-900">Create New Roadmap</h2>
              <button
                onClick={() => setShowAddModal(false)}
                className="p-1 text-slate-400 hover:text-slate-600 rounded-full hover:bg-slate-100"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="space-y-4 text-xs font-bold text-slate-700">
              <div className="space-y-1">
                <label className="block text-[10px] uppercase tracking-wider font-extrabold text-slate-500">
                  Roadmap Title
                </label>
                <input
                  type="text"
                  placeholder="e.g., AI & Machine Learning Track 2026"
                  value={newRoadmapTitle}
                  onChange={(e) => setNewRoadmapTitle(e.target.value)}
                  className="w-full px-3.5 py-2.5 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#6D28D9]/30 text-xs font-semibold text-slate-800"
                />
              </div>

              <div className="space-y-1">
                <label className="block text-[10px] uppercase tracking-wider font-extrabold text-slate-500">
                  Category
                </label>
                <select
                  value={newCategory}
                  onChange={(e) => setNewCategory(e.target.value)}
                  className="w-full px-3.5 py-2.5 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#6D28D9]/30 text-xs font-semibold text-slate-800"
                >
                  <option value="Tech">Tech</option>
                  <option value="Business">Business</option>
                  <option value="Non-Tech">Non-Tech</option>
                </select>
              </div>
            </div>

            <div className="flex items-center justify-end gap-3 pt-4 border-t border-slate-100">
              <button
                onClick={() => setShowAddModal(false)}
                className="px-4 py-2 border border-slate-200 text-slate-600 font-bold rounded-xl text-xs hover:bg-slate-50"
              >
                Cancel
              </button>
              <button
                onClick={() => {
                  setShowAddModal(false);
                  setNewRoadmapTitle('');
                }}
                className="px-4 py-2 bg-[#6D28D9] text-white font-bold rounded-xl text-xs hover:bg-[#5B21B6] shadow-md shadow-purple-500/20"
              >
                Create Roadmap
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default ContentHub;
