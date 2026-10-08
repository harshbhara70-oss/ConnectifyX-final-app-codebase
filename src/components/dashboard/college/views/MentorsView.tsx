import React from "react";
import { Star, Plus } from "lucide-react";

export const MentorsView: React.FC = () => {
  const mentors = [
    { name: "Dr. Ananya Rao", domain: "DSA & Machine Learning", assigned: 45, rating: 4.9, sessions: 120 },
    { name: "Prof. Rajesh Kumar", domain: "Full Stack & Web Dev", assigned: 50, rating: 4.8, sessions: 145 },
    { name: "Vikram Malhotra", domain: "CAD & Mechatronics", assigned: 35, rating: 4.7, sessions: 90 },
    { name: "Neha Mehta", domain: "Aptitude & Soft Skills", assigned: 60, rating: 4.9, sessions: 180 },
  ];

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Mentor Allocations</h1>
          <p className="text-xs text-slate-500 font-medium mt-1">
            Track student-mentor mappings, 1-on-1 mock interview sessions, and feedback.
          </p>
        </div>
        <button className="bg-purple-600 hover:bg-purple-700 text-white font-semibold text-xs px-4 py-2.5 rounded-xl shadow-md shadow-purple-500/20 flex items-center gap-2">
          <Plus className="w-4 h-4" /> Assign Mentor
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {mentors.map((m, i) => (
          <div key={i} className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-2xl bg-purple-100 text-purple-700 font-bold flex items-center justify-center text-base">
                {m.name.charAt(0)}
              </div>
              <div>
                <h2 className="text-base font-bold text-slate-900">{m.name}</h2>
                <p className="text-xs text-slate-500 font-medium">{m.domain}</p>
                <div className="flex items-center gap-3 text-xs text-slate-600 mt-1">
                  <span>Mentees: <strong>{m.assigned}</strong></span>
                  <span>Sessions: <strong>{m.sessions}</strong></span>
                </div>
              </div>
            </div>
            <div className="text-right">
              <div className="flex items-center gap-1 bg-amber-50 text-amber-700 px-2.5 py-1 rounded-full text-xs font-bold">
                <Star className="w-3.5 h-3.5 fill-amber-400 stroke-amber-400" /> {m.rating}
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
