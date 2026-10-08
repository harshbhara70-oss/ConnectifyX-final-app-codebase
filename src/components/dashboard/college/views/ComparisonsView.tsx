import React from "react";

export const ComparisonsView: React.FC = () => {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-slate-900">Stream-Wise Comparative Analytics</h1>
        <p className="text-xs text-slate-500 font-medium mt-1">
          Comparative benchmark of Computer Science, Circuit, Core, and Allied branches.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm text-center">
          <span className="text-xs font-bold text-slate-400 uppercase">Highest Placement Rate</span>
          <div className="text-3xl font-extrabold text-purple-700 mt-2">85.7%</div>
          <p className="text-xs font-bold text-slate-700 mt-1">Computer Science & IT</p>
        </div>
        <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm text-center">
          <span className="text-xs font-bold text-slate-400 uppercase">Highest Package Branch</span>
          <div className="text-3xl font-extrabold text-emerald-600 mt-2">34.0 LPA</div>
          <p className="text-xs font-bold text-slate-700 mt-1">Computer Science (Google)</p>
        </div>
        <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm text-center">
          <span className="text-xs font-bold text-slate-400 uppercase">Fastest Placement Velocity</span>
          <div className="text-3xl font-extrabold text-indigo-700 mt-2">12 Days</div>
          <p className="text-xs font-bold text-slate-700 mt-1">Electronics & Comm</p>
        </div>
      </div>
    </div>
  );
};
