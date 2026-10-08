import React from "react";
import { Plus, Calendar, MapPin, DollarSign, Users, ArrowUpRight } from "lucide-react";

export const JobsView: React.FC = () => {
  const jobs = [
    { title: "Full Stack Engineer", company: "Stripe Tech", location: "Bangalore / Remote", package: "18.5 LPA", applicants: 142, deadline: "Mar 10, 2026", status: "Active" },
    { title: "Product Analyst", company: "Aether Commerce", location: "Gurgaon", package: "12.0 LPA", applicants: 98, deadline: "Mar 14, 2026", status: "Active" },
    { title: "Risk Auditor", company: "Nexus Finance", location: "Mumbai", package: "14.2 LPA", applicants: 76, deadline: "Mar 18, 2026", status: "Active" },
    { title: "Cloud Solutions Architect", company: "Microsoft", location: "Hyderabad", package: "22.0 LPA", applicants: 210, deadline: "Apr 05, 2026", status: "Upcoming" },
  ];

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Active Job Postings & Drive Openings</h1>
          <p className="text-xs text-slate-500 font-medium mt-1">
            Monitor applicant pipelines, eligibility filters, and job descriptions.
          </p>
        </div>
        <button className="bg-purple-600 hover:bg-purple-700 text-white font-semibold text-xs px-4 py-2.5 rounded-xl shadow-md shadow-purple-500/20 flex items-center gap-2">
          <Plus className="w-4 h-4" /> Post New Job
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {jobs.map((j, idx) => (
          <div key={idx} className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm hover:shadow-md transition-shadow">
            <div className="flex items-start justify-between">
              <div>
                <span className="text-[10px] font-bold uppercase text-purple-700 bg-purple-50 px-2 py-0.5 rounded-md">
                  {j.company}
                </span>
                <h2 className="text-base font-bold text-slate-900 mt-1">{j.title}</h2>
              </div>
              <span className="bg-emerald-100 text-emerald-700 text-[10px] font-bold px-2.5 py-1 rounded-full">
                {j.status}
              </span>
            </div>

            <div className="grid grid-cols-2 gap-2 my-4 text-xs text-slate-600">
              <div className="flex items-center gap-1.5">
                <MapPin className="w-3.5 h-3.5 text-slate-400" /> {j.location}
              </div>
              <div className="flex items-center gap-1.5 font-bold text-slate-900">
                <DollarSign className="w-3.5 h-3.5 text-emerald-600" /> {j.package}
              </div>
              <div className="flex items-center gap-1.5">
                <Users className="w-3.5 h-3.5 text-purple-600" /> {j.applicants} Applicants
              </div>
              <div className="flex items-center gap-1.5">
                <Calendar className="w-3.5 h-3.5 text-slate-400" /> Due: {j.deadline}
              </div>
            </div>

            <div className="pt-3 border-t border-slate-100 flex items-center justify-between">
              <span className="text-[11px] text-slate-400 font-medium">Eligible: B.Tech CSE / IT / ECE</span>
              <button className="text-xs font-bold text-purple-600 hover:text-purple-700 flex items-center gap-1">
                Manage Applicants <ArrowUpRight className="w-3.5 h-3.5" />
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
