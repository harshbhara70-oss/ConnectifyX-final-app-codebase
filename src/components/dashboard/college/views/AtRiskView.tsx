import React from "react";
import { ArrowRight, Send } from "lucide-react";

export const AtRiskView: React.FC = () => {
  const atRiskStudents = [
    { name: "Aniket Verma", rollNo: "2021-ME-055", dept: "Mechanical Engg", issue: "DSA score < 50% & 2 failed mock tests", riskLevel: "High Risk" },
    { name: "Karan Singh", rollNo: "2021-ECE-090", dept: "Electronics & Comm", issue: "Low attendance (62%) in placement training", riskLevel: "High Risk" },
    { name: "Rohan Das", rollNo: "2021-CE-012", dept: "Civil Engg", issue: "Aptitude cut-off missed in 3 drives", riskLevel: "Medium Risk" },
    { name: "Pooja Hegde", rollNo: "2021-IT-044", dept: "Information Tech", issue: "Resume verification pending & incomplete profile", riskLevel: "Medium Risk" },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">At-Risk Student Monitoring</h1>
          <p className="text-xs text-slate-500 font-medium mt-1">
            Early warning system identifying candidates needing immediate remedial intervention.
          </p>
        </div>
        <button className="bg-amber-600 hover:bg-amber-700 text-white font-semibold text-xs px-4 py-2.5 rounded-xl shadow-md flex items-center gap-2">
          <Send className="w-4 h-4" /> Trigger Remedial Workshop
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {atRiskStudents.map((st, i) => (
          <div key={i} className="bg-white p-5 rounded-2xl border border-amber-100 shadow-sm flex flex-col justify-between">
            <div>
              <div className="flex items-center justify-between mb-2">
                <span className="text-xs font-bold text-slate-900">{st.name}</span>
                <span className="bg-amber-100 text-amber-700 text-[10px] font-bold px-2.5 py-0.5 rounded-full">
                  {st.riskLevel}
                </span>
              </div>
              <p className="text-xs font-mono text-slate-400 mb-2">{st.rollNo} • {st.dept}</p>
              <div className="p-3 bg-amber-50/70 rounded-xl border border-amber-100 text-xs text-amber-900 font-medium">
                ⚠️ {st.issue}
              </div>
            </div>

            <div className="mt-4 pt-3 border-t border-slate-100 flex items-center justify-between text-xs">
              <span className="text-slate-500 font-medium">Mentor: Assigned</span>
              <button className="text-purple-600 font-bold hover:underline flex items-center gap-1">
                Assign Remediation <ArrowRight className="w-3.5 h-3.5" />
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
