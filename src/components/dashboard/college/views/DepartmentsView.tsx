import React from "react";
import { ChevronRight } from "lucide-react";

export const DepartmentsView: React.FC = () => {
  const departments = [
    { code: "CSE", name: "Computer Science & Engineering", hod: "Dr. Ananya Rao", total: 420, placed: 360, avgLpa: 14.5, topSkill: "Full Stack & DSA" },
    { code: "ECE", name: "Electronics & Communication", hod: "Dr. Ramesh Gupta", total: 310, placed: 240, avgLpa: 11.2, topSkill: "Embedded Systems & VLSI" },
    { code: "ME", name: "Mechanical Engineering", hod: "Prof. Vikram Malhotra", total: 280, placed: 180, avgLpa: 8.4, topSkill: "CAD/CAM & Mechatronics" },
    { code: "IT", name: "Information Technology", hod: "Dr. Priya Nair", total: 350, placed: 310, avgLpa: 13.8, topSkill: "Cloud & DevOps" },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-slate-900">Department Performance & Analytics</h1>
        <p className="text-xs text-slate-500 font-medium mt-1">
          Branch-wise placement statistics, HOD governance, and skill metrics.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {departments.map((dept) => {
          const placementRate = Math.round((dept.placed / dept.total) * 100);
          return (
            <div key={dept.code} className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm shadow-purple-500/5 hover:shadow-md transition-shadow">
              <div className="flex items-center justify-between border-b border-slate-100 pb-4 mb-4">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-purple-50 text-purple-700 font-bold flex items-center justify-center text-sm">
                    {dept.code}
                  </div>
                  <div>
                    <h2 className="text-base font-bold text-slate-900">{dept.name}</h2>
                    <p className="text-xs text-slate-400 font-medium">HOD: {dept.hod}</p>
                  </div>
                </div>
                <span className="text-xs font-bold text-purple-600 bg-purple-50 px-2.5 py-1 rounded-full">
                  {placementRate}% Placed
                </span>
              </div>

              <div className="grid grid-cols-3 gap-4 text-center py-2 bg-slate-50/60 rounded-xl p-3 mb-4">
                <div>
                  <span className="text-[10px] uppercase font-bold text-slate-400">Total</span>
                  <div className="text-lg font-extrabold text-slate-900">{dept.total}</div>
                </div>
                <div>
                  <span className="text-[10px] uppercase font-bold text-slate-400">Placed</span>
                  <div className="text-lg font-extrabold text-emerald-600">{dept.placed}</div>
                </div>
                <div>
                  <span className="text-[10px] uppercase font-bold text-slate-400">Avg LPA</span>
                  <div className="text-lg font-extrabold text-purple-700">{dept.avgLpa}</div>
                </div>
              </div>

              <div className="flex items-center justify-between text-xs text-slate-500 pt-2">
                <span>Top Skill Focus: <strong className="text-slate-800">{dept.topSkill}</strong></span>
                <button className="text-purple-600 hover:text-purple-700 font-semibold flex items-center gap-1">
                  Details <ChevronRight className="w-3.5 h-3.5" />
                </button>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};
