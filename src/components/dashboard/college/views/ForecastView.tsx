import React from "react";
import { Sparkles } from "lucide-react";
import { ResponsiveContainer, AreaChart, Area, XAxis, YAxis, Tooltip, CartesianGrid } from "recharts";

export const ForecastView: React.FC = () => {
  const forecastData = [
    { month: "Jan", actual: 120, predicted: 125 },
    { month: "Feb", actual: 180, predicted: 175 },
    { month: "Mar", actual: 240, predicted: 235 },
    { month: "Apr", actual: null, predicted: 310 },
    { month: "May", actual: null, predicted: 380 },
    { month: "Jun", actual: null, predicted: 420 },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-slate-900">Placement Predictive Models</h1>
        <p className="text-xs text-slate-500 font-medium mt-1">
          Machine learning forecasts predicting hiring demand, salary trends, and placement completion milestones.
        </p>
      </div>

      <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-base font-bold text-slate-900">Cumulative Offer Projection (2026 Season)</h2>
          <span className="text-xs font-bold text-purple-700 bg-purple-50 px-2.5 py-1 rounded-full border border-purple-100 flex items-center gap-1">
            <Sparkles className="w-3.5 h-3.5" /> AI Confidence: 94.2%
          </span>
        </div>
        <div className="h-72">
          <ResponsiveContainer width="100%" height="100%">
            <AreaChart data={forecastData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#F1F5F9" />
              <XAxis dataKey="month" stroke="#64748B" fontSize={12} />
              <YAxis stroke="#64748B" fontSize={12} />
              <Tooltip />
              <Area type="monotone" dataKey="actual" stroke="#7C3AED" fill="#7C3AED" fillOpacity={0.2} name="Actual Offers" />
              <Area type="monotone" dataKey="predicted" stroke="#6366F1" strokeDasharray="5 5" fill="#6366F1" fillOpacity={0.1} name="Predicted Offers" />
            </AreaChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  );
};
