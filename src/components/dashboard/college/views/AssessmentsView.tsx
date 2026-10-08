import React from "react";

export const AssessmentsView: React.FC = () => {
  const tests = [
    { title: "National Level DSA & Algorithm Mock Test", count: 480, avg: "82/100", topScorer: "Priya Patel (98)" },
    { title: "Full Stack Development Coding Challenge", count: 320, avg: "76/100", topScorer: "Rahul Sharma (95)" },
    { title: "System Design & Architecture Evaluation", count: 210, avg: "71/100", topScorer: "Sneha Reddy (94)" },
    { title: "Quantitative Aptitude & Logical Reasoning", count: 640, avg: "85/100", topScorer: "Ananya Mehta (100)" },
  ];

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Test & Coding Scores</h1>
          <p className="text-xs text-slate-500 font-medium mt-1">
            Standardized technical assessments, live coding leaderboards, and score logs.
          </p>
        </div>
        <button className="bg-purple-600 hover:bg-purple-700 text-white font-semibold text-xs px-4 py-2.5 rounded-xl shadow-md shadow-purple-500/20">
          + Create New Test
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {tests.map((t, idx) => (
          <div key={idx} className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm">
            <h2 className="text-base font-bold text-slate-900">{t.title}</h2>
            <div className="grid grid-cols-3 gap-2 my-4 bg-purple-50/50 p-3 rounded-xl text-center text-xs">
              <div>
                <span className="text-[10px] text-slate-400 font-bold uppercase">Taken By</span>
                <div className="font-extrabold text-slate-800">{t.count}</div>
              </div>
              <div>
                <span className="text-[10px] text-slate-400 font-bold uppercase">Average Score</span>
                <div className="font-extrabold text-purple-700">{t.avg}</div>
              </div>
              <div>
                <span className="text-[10px] text-slate-400 font-bold uppercase">Top Ranker</span>
                <div className="font-extrabold text-emerald-600 truncate">{t.topScorer}</div>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
