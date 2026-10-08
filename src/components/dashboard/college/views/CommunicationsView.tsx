import React from "react";
import { Bell, Megaphone } from "lucide-react";

export const CommunicationsView: React.FC = () => {
  const broadcasts = [
    { title: "Google APAC Pre-Placement Talk Announcement", target: "All CSE & ECE Final Year Students", date: "Jul 30, 2026", status: "Sent (820 Delivered)" },
    { title: "Mandatory Resume Verification Drive", target: "Unplaced Final Year Candidates", date: "Jul 28, 2026", status: "Sent (310 Delivered)" },
    { title: "Stripe Tech Interview Slot Allotment", target: "Shortlisted Candidates", date: "Jul 25, 2026", status: "Sent (42 Delivered)" },
  ];

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Broadcasts & Campus Communications</h1>
          <p className="text-xs text-slate-500 font-medium mt-1">
            Send bulk email/SMS announcements to students, recruiters, and HODs.
          </p>
        </div>
        <button className="bg-purple-600 hover:bg-purple-700 text-white font-semibold text-xs px-4 py-2.5 rounded-xl shadow-md shadow-purple-500/20 flex items-center gap-2">
          <Megaphone className="w-4 h-4" /> New Broadcast
        </button>
      </div>

      <div className="space-y-4">
        {broadcasts.map((b, i) => (
          <div key={i} className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className="w-10 h-10 rounded-xl bg-purple-50 text-purple-600 flex items-center justify-center">
                <Bell className="w-5 h-5" />
              </div>
              <div>
                <h2 className="text-sm font-bold text-slate-900">{b.title}</h2>
                <p className="text-xs text-slate-500 font-medium mt-0.5">Audience: {b.target}</p>
              </div>
            </div>
            <div className="text-right">
              <span className="bg-emerald-100 text-emerald-700 text-[10px] font-bold px-2.5 py-1 rounded-full">
                {b.status}
              </span>
              <span className="block text-[10px] text-slate-400 mt-1">{b.date}</span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
