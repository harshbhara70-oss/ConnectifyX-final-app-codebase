import React, { useState } from 'react';
import {
  CheckCircle2,
  AlertTriangle,
  Download,
  ExternalLink,
  Sparkles
} from 'lucide-react';

export const VerificationQueue: React.FC = () => {
  const [activeQueueTab, setActiveQueueTab] = useState<'colleges' | 'recruiters' | 'flagged'>('colleges');
  const [verificationCards, setVerificationCards] = useState([
    {
      id: 'v_1',
      title: 'Tech Institute of Innovation',
      priority: 'HIGH PRIORITY',
      submitted: 'Submitted: 2 hrs ago by admin@tii.edu',
      domainMatch: true,
      accreditationDoc: true,
      linkedinStatus: 'LinkedIn Vague',
      linkedinOk: false,
      domainUrl: 'tii.edu',
      status: 'pending'
    },
    {
      id: 'v_2',
      title: 'Northern University',
      priority: '',
      submitted: 'Submitted: 5 hrs ago by j.smith@northern.edu',
      domainMatch: true,
      taxIdVerified: true,
      linkedinStatus: 'LinkedIn Active',
      linkedinOk: true,
      domainUrl: 'northern.edu',
      status: 'pending'
    }
  ]);

  const handleVerify = (id: string) => {
    setVerificationCards((prev) =>
      prev.map((c) => (c.id === id ? { ...c, status: 'approved' } : c))
    );
  };

  const handleReject = (id: string) => {
    setVerificationCards((prev) =>
      prev.map((c) => (c.id === id ? { ...c, status: 'rejected' } : c))
    );
  };

  return (
    <div className="space-y-8 font-sans text-slate-800 pb-12">
      {/* Top Banner Header & Audit Log Export Button */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <span className="text-[11px] font-bold text-slate-400 uppercase tracking-wider">Admin &gt; Oversight &gt; Verification Queue</span>
          <h1 className="text-2xl font-black text-slate-900 tracking-tight mt-0.5">Verification Queue</h1>
          <p className="text-xs font-semibold text-slate-500 mt-1">
            Manage and audit pending institutional approvals and flagged content.
          </p>
        </div>

        <button className="bg-white border border-slate-200 hover:bg-slate-50 text-slate-700 font-bold px-4 py-2.5 rounded-xl text-xs flex items-center gap-2 shadow-2xs transition-colors cursor-pointer self-start sm:self-auto">
          <Download className="w-4 h-4 text-purple-700" />
          <span>Export Audit Log</span>
        </button>
      </div>

      {/* Queue Filter Pills */}
      <div className="flex items-center gap-3 border-b border-purple-100/70 pb-3">
        {[
          { id: 'colleges' as const, label: 'Pending Colleges', count: 12 },
          { id: 'recruiters' as const, label: 'Pending Recruiters', count: 4 },
          { id: 'flagged' as const, label: 'Flagged Content', count: 3 },
        ].map((pill) => {
          const isActive = activeQueueTab === pill.id;
          return (
            <button
              key={pill.id}
              onClick={() => setActiveQueueTab(pill.id)}
              className={`px-4 py-2 rounded-xl text-xs font-bold transition-all duration-200 cursor-pointer flex items-center gap-2 ${
                isActive
                  ? 'bg-[#6D28D9] text-white shadow-md shadow-purple-600/20'
                  : 'bg-white text-slate-600 hover:bg-purple-50 border border-slate-200/60'
              }`}
            >
              <span>{pill.label}</span>
              <span
                className={`px-2 py-0.5 rounded-full text-[10px] font-mono font-bold ${
                  isActive ? 'bg-white/20 text-white' : 'bg-purple-50 text-purple-700'
                }`}
              >
                {pill.count}
              </span>
            </button>
          );
        })}
      </div>

      {/* Split Layout: Left Filters & Right Cards */}
      <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
        {/* Left Column: Queue Status & Auto-Check Filters */}
        <div className="space-y-6">
          {/* Queue Status Widget */}
          <div className="bg-white rounded-2xl p-5 border border-purple-100/70 shadow-xs space-y-3">
            <h3 className="text-xs font-extrabold uppercase tracking-wider text-slate-400">Queue Status</h3>
            <div className="space-y-2 text-xs font-bold text-slate-700">
              <div className="flex justify-between items-center">
                <span className="text-slate-500">High Priority</span>
                <span className="font-mono text-red-500 font-extrabold">5</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-slate-500">Standard</span>
                <span className="font-mono text-slate-800">7</span>
              </div>
              <div className="flex justify-between items-center pt-2 border-t border-slate-100">
                <span className="text-slate-500">Avg. Wait Time</span>
                <span className="font-mono text-purple-700">2.4 hrs</span>
              </div>
            </div>
          </div>

          {/* Auto-Check Filters */}
          <div className="bg-white rounded-2xl p-5 border border-purple-100/70 shadow-xs space-y-3">
            <h3 className="text-xs font-extrabold uppercase tracking-wider text-slate-400">Auto-Check Filters</h3>
            <div className="space-y-2 text-xs font-bold text-slate-700">
              <label className="flex items-center gap-2.5 cursor-pointer">
                <input type="checkbox" defaultChecked className="rounded text-[#6D28D9] focus:ring-[#6D28D9]" />
                <span>Domain Verified (8)</span>
              </label>
              <label className="flex items-center gap-2.5 cursor-pointer">
                <input type="checkbox" defaultChecked className="rounded text-[#6D28D9] focus:ring-[#6D28D9]" />
                <span>Docs Provided (11)</span>
              </label>
              <label className="flex items-center gap-2.5 cursor-pointer">
                <input type="checkbox" className="rounded text-[#6D28D9] focus:ring-[#6D28D9]" />
                <span>Flagged by AI (3)</span>
              </label>
            </div>
          </div>
        </div>

        {/* Right Column: Verification Cards Feed */}
        <div className="lg:col-span-3 space-y-6">
          {verificationCards.map((card) => (
            <div
              key={card.id}
              className={`bg-white rounded-2xl p-6 border transition-all duration-300 shadow-xs space-y-4 ${
                card.status === 'approved'
                  ? 'border-emerald-200 bg-emerald-50/20'
                  : card.status === 'rejected'
                  ? 'border-red-200 bg-red-50/20'
                  : 'border-purple-100/80 hover:border-purple-300'
              }`}
            >
              {/* Card Header */}
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 border-b border-slate-100 pb-4">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-2xl bg-purple-50 border border-purple-100 flex items-center justify-center text-purple-700 font-bold text-sm">
                    {card.title.charAt(0)}
                  </div>
                  <div>
                    <div className="flex items-center gap-2">
                      <h3 className="text-base font-black text-slate-900">{card.title}</h3>
                      {card.priority && (
                        <span className="px-2 py-0.5 bg-red-50 text-red-600 border border-red-200 rounded text-[9px] font-extrabold uppercase">
                          {card.priority}
                        </span>
                      )}
                    </div>
                    <p className="text-xs text-slate-400 font-medium mt-0.5">{card.submitted}</p>
                  </div>
                </div>

                {card.status !== 'pending' && (
                  <span
                    className={`px-3 py-1 rounded-full text-xs font-bold uppercase ${
                      card.status === 'approved' ? 'bg-emerald-100 text-emerald-700' : 'bg-red-100 text-red-700'
                    }`}
                  >
                    {card.status}
                  </span>
                )}
              </div>

              {/* Automated Audit Check Pills */}
              <div className="flex flex-wrap items-center gap-2 pt-1">
                {card.domainMatch && (
                  <span className="px-3 py-1 bg-emerald-50 border border-emerald-200 text-emerald-700 rounded-full text-xs font-bold flex items-center gap-1.5">
                    <CheckCircle2 className="w-3.5 h-3.5 text-emerald-600" />
                    <span>Domain Match</span>
                  </span>
                )}

                {card.accreditationDoc && (
                  <span className="px-3 py-1 bg-emerald-50 border border-emerald-200 text-emerald-700 rounded-full text-xs font-bold flex items-center gap-1.5">
                    <CheckCircle2 className="w-3.5 h-3.5 text-emerald-600" />
                    <span>Accreditation Doc</span>
                  </span>
                )}

                {card.taxIdVerified && (
                  <span className="px-3 py-1 bg-emerald-50 border border-emerald-200 text-emerald-700 rounded-full text-xs font-bold flex items-center gap-1.5">
                    <CheckCircle2 className="w-3.5 h-3.5 text-emerald-600" />
                    <span>Tax ID Verified</span>
                  </span>
                )}

                <span
                  className={`px-3 py-1 border rounded-full text-xs font-bold flex items-center gap-1.5 ${
                    card.linkedinOk
                      ? 'bg-emerald-50 border-emerald-200 text-emerald-700'
                      : 'bg-amber-50 border-amber-200 text-amber-700'
                  }`}
                >
                  {card.linkedinOk ? (
                    <CheckCircle2 className="w-3.5 h-3.5 text-emerald-600" />
                  ) : (
                    <AlertTriangle className="w-3.5 h-3.5 text-amber-600" />
                  )}
                  <span>{card.linkedinStatus}</span>
                </span>

                <a
                  href={`https://${card.domainUrl}`}
                  target="_blank"
                  rel="noreferrer"
                  className="px-3 py-1 bg-purple-50 border border-purple-200 text-purple-700 rounded-full text-xs font-bold flex items-center gap-1 hover:bg-purple-100 transition-colors ml-auto"
                >
                  <span>{card.domainUrl}</span>
                  <ExternalLink className="w-3 h-3" />
                </a>
              </div>

              {/* Action Buttons */}
              {card.status === 'pending' && (
                <div className="flex items-center justify-end gap-3 pt-3 border-t border-slate-100">
                  <button className="px-4 py-2 bg-slate-50 hover:bg-slate-100 text-slate-700 font-bold rounded-xl text-xs border border-slate-200 transition-colors cursor-pointer">
                    Request Info
                  </button>
                  <button
                    onClick={() => handleReject(card.id)}
                    className="px-4 py-2 bg-red-50 hover:bg-red-100 text-red-600 font-bold rounded-xl text-xs border border-red-200 transition-colors cursor-pointer"
                  >
                    Reject
                  </button>
                  <button
                    onClick={() => handleVerify(card.id)}
                    className="px-4 py-2 bg-[#6D28D9] hover:bg-[#5B21B6] text-white font-bold rounded-xl text-xs shadow-md shadow-purple-500/20 transition-all cursor-pointer flex items-center gap-1.5"
                  >
                    <Sparkles className="w-3.5 h-3.5 fill-white" />
                    <span>Quick Verify</span>
                  </button>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default VerificationQueue;
