import React from "react";
import { Download, FileText } from "lucide-react";

export const ReportsView: React.FC = () => {
  const reports = [
    { title: "2026 Season Placement Master Audit", type: "PDF / Excel", size: "4.2 MB", date: "Jul 31, 2026" },
    { title: "NAAC & NBA Accreditation Compliance Report", type: "PDF Document", size: "12.8 MB", date: "Jul 25, 2026" },
    { title: "Department-Wise Salary & Offer Distribution", type: "Excel Spreadsheet", size: "1.8 MB", date: "Jul 20, 2026" },
    { title: "Recruiter Engagement & Conversion Funnel", type: "PDF Analytics", size: "3.1 MB", date: "Jul 15, 2026" },
  ];

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Performance Reports & Export Hub</h1>
          <p className="text-xs text-slate-500 font-medium mt-1">
            Generate executive PDFs, raw Excel data exports, and accreditation summaries.
          </p>
        </div>
        <button className="bg-purple-600 hover:bg-purple-700 text-white font-semibold text-xs px-4 py-2.5 rounded-xl shadow-md shadow-purple-500/20 flex items-center gap-2">
          <Download className="w-4 h-4" /> Generate Custom Report
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {reports.map((r, i) => (
          <div key={i} className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm flex items-center justify-between">
            <div className="flex items-center gap-3.5">
              <div className="w-10 h-10 rounded-xl bg-purple-50 text-purple-700 flex items-center justify-center">
                <FileText className="w-5 h-5" />
              </div>
              <div>
                <h2 className="text-sm font-bold text-slate-900">{r.title}</h2>
                <span className="text-[11px] text-slate-400 font-medium">{r.type} • {r.size} • Generated {r.date}</span>
              </div>
            </div>
            <button className="p-2.5 bg-slate-50 hover:bg-purple-50 text-slate-700 hover:text-purple-700 rounded-xl transition-colors border border-slate-200">
              <Download className="w-4 h-4" />
            </button>
          </div>
        ))}
      </div>
    </div>
  );
};
