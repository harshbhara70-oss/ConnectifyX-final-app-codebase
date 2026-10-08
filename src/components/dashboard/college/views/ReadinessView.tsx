import React from "react";
import { ResponsiveContainer, RadarChart, Radar, PolarGrid, PolarAngleAxis, PolarRadiusAxis, BarChart, Bar, XAxis, YAxis, Tooltip } from "recharts";

export const ReadinessView: React.FC = () => {
  const radarData = [
    { subject: 'Data Structures', score: 85 },
    { subject: 'System Design', score: 72 },
    { subject: 'Web Dev', score: 90 },
    { subject: 'Aptitude', score: 88 },
    { subject: 'Core CS', score: 82 },
    { subject: 'Communication', score: 78 },
  ];

  const branchScores = [
    { branch: 'CSE', score: 88 },
    { branch: 'ECE', score: 82 },
    { branch: 'IT', score: 86 },
    { branch: 'ME', score: 68 },
    { branch: 'CE', score: 64 },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-slate-900">Skill Readiness Engine</h1>
        <p className="text-xs text-slate-500 font-medium mt-1">
          Deep AI diagnostic analysis of candidate competencies across technical and cognitive domains.
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Radar Chart */}
        <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm">
          <h2 className="text-base font-bold text-slate-900 mb-4">Overall Skill Competency Matrix</h2>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <RadarChart outerRadius="75%" data={radarData}>
                <PolarGrid stroke="#E2E8F0" />
                <PolarAngleAxis dataKey="subject" stroke="#64748B" fontSize={11} />
                <PolarRadiusAxis angle={30} domain={[0, 100]} stroke="#CBD5E1" />
                <Radar name="Readiness Score" dataKey="score" stroke="#7C3AED" fill="#7C3AED" fillOpacity={0.4} />
              </RadarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Branch Readiness Bar Chart */}
        <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm">
          <h2 className="text-base font-bold text-slate-900 mb-4">Branch-Wise Average Readiness</h2>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={branchScores}>
                <XAxis dataKey="branch" stroke="#64748B" fontSize={12} />
                <YAxis domain={[0, 100]} stroke="#64748B" fontSize={12} />
                <Tooltip />
                <Bar dataKey="score" fill="#7C3AED" radius={[8, 8, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>
    </div>
  );
};
