import React from "react";
import { Building } from "lucide-react";

export const CompaniesView: React.FC = () => {
  const companies = [
    { name: "Stripe Tech", category: "Fintech / Payments", tier: "Tier 1", visits: 4, hires: 28, maxPkg: "22.0 LPA", status: "Active Partner" },
    { name: "Aether Commerce", category: "E-Commerce / Cloud", tier: "Tier 1", visits: 3, hires: 18, maxPkg: "18.5 LPA", status: "Active Partner" },
    { name: "Nexus Finance", category: "Investment Banking", tier: "Tier 1", visits: 2, hires: 12, maxPkg: "16.0 LPA", status: "Active Partner" },
    { name: "Google APAC", category: "Product / Tech", tier: "Dream", visits: 5, hires: 15, maxPkg: "34.0 LPA", status: "Dream Partner" },
    { name: "Microsoft India", category: "Cloud & AI", tier: "Dream", visits: 4, hires: 22, maxPkg: "28.0 LPA", status: "Dream Partner" },
  ];

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Recruiter Analytics & Corporate Network</h1>
          <p className="text-xs text-slate-500 font-medium mt-1">
            Track visiting companies, hiring conversion, and partnership tiers.
          </p>
        </div>
        <button className="bg-purple-600 hover:bg-purple-700 text-white font-semibold text-xs px-4 py-2.5 rounded-xl shadow-md shadow-purple-500/20 flex items-center gap-2">
          <Building className="w-4 h-4" /> Invite Recruiter
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-xs">
          <span className="text-xs font-bold text-slate-400 uppercase">Active Partnerships</span>
          <div className="text-3xl font-extrabold text-slate-900 mt-2">142</div>
          <span className="text-xs text-emerald-600 font-bold">+18 new this year</span>
        </div>
        <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-xs">
          <span className="text-xs font-bold text-slate-400 uppercase">Total Hires Made</span>
          <div className="text-3xl font-extrabold text-purple-700 mt-2">1,240</div>
          <span className="text-xs text-slate-500 font-medium">Avg Package: 12.8 LPA</span>
        </div>
        <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-xs">
          <span className="text-xs font-bold text-slate-400 uppercase">Dream Companies</span>
          <div className="text-3xl font-extrabold text-indigo-700 mt-2">32</div>
          <span className="text-xs text-purple-600 font-bold">&gt; 20 LPA Offers</span>
        </div>
      </div>

      <div className="bg-white rounded-2xl border border-slate-100 shadow-xs overflow-hidden">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="bg-slate-50/70 border-b border-slate-100 text-[11px] font-bold text-slate-400 uppercase tracking-wider">
              <th className="py-3.5 px-6">Company Name</th>
              <th className="py-3.5 px-4">Domain / Sector</th>
              <th className="py-3.5 px-4">Tier</th>
              <th className="py-3.5 px-4">Total Hires</th>
              <th className="py-3.5 px-4">Highest Package</th>
              <th className="py-3.5 px-6 text-right">Status</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100 text-xs font-medium">
            {companies.map((c, i) => (
              <tr key={i} className="hover:bg-purple-50/30 transition-colors">
                <td className="py-4 px-6 font-bold text-slate-900 flex items-center gap-3">
                  <div className="w-8 h-8 rounded-lg bg-purple-100 text-purple-700 font-extrabold flex items-center justify-center text-xs">
                    {c.name.charAt(0)}
                  </div>
                  <span>{c.name}</span>
                </td>
                <td className="py-4 px-4 text-slate-600">{c.category}</td>
                <td className="py-4 px-4">
                  <span className="bg-purple-50 text-purple-700 font-bold px-2 py-0.5 rounded-md text-[10px]">
                    {c.tier}
                  </span>
                </td>
                <td className="py-4 px-4 font-bold text-slate-900">{c.hires} candidates</td>
                <td className="py-4 px-4 font-extrabold text-emerald-600">{c.maxPkg}</td>
                <td className="py-4 px-6 text-right">
                  <span className="bg-emerald-100 text-emerald-700 font-bold px-3 py-1 rounded-full text-[10px]">
                    {c.status}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};
