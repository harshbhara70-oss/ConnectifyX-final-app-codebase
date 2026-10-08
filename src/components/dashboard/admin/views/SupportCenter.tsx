import React, { useState } from 'react';
import {
  Search,
  CheckCircle2,
  Clock,
  UserCheck,
  Paperclip,
  Download,
  Send,
  ShieldCheck
} from 'lucide-react';

export const SupportCenter: React.FC = () => {
  const [selectedTicketId, setSelectedTicketId] = useState('TCK-8921');
  const [filterMode, setFilterMode] = useState<'all' | 'high' | 'disputes'>('all');
  const [replyText, setReplyText] = useState('');
  const [isInternalNote, setIsInternalNote] = useState(false);
  const [ticketResolved, setTicketResolved] = useState(false);

  const tickets = [
    {
      id: 'TCK-8921',
      title: 'Placement Offer Dispute - Data Mismatch',
      requester: 'J. Doe (Student)',
      org: 'State University',
      priority: 'Critical Priority',
      type: 'Dispute',
      sla: '2h 14m SLA',
      created: 'Oct 24, 09:41 AM',
      unread: true
    },
    {
      id: 'TCK-8910',
      title: 'API Key Rotation Request',
      requester: 'Corp IT Dept',
      org: 'TechCorp',
      priority: 'Standard',
      type: 'Request',
      sla: '14h ago',
      created: 'Oct 24, 07:15 AM',
      unread: false
    },
    {
      id: 'TCK-8905',
      title: 'Bulk Verification Export Failing',
      requester: 'Admin Staff',
      org: 'Northern University',
      priority: 'Escalated',
      type: 'System Issue',
      sla: 'Yesterday',
      created: 'Oct 23, 04:30 PM',
      unread: false
    }
  ];

  return (
    <div className="space-y-6 font-sans text-slate-800 pb-12">
      {/* Top Banner Header & Metric Badges */}
      <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-black text-slate-900 tracking-tight">Support Center</h1>
          <p className="text-xs font-semibold text-slate-500 mt-1">
            Manage platform inquiries, disputes, and technical support requests.
          </p>
        </div>

        {/* Ticket Metrics Badges */}
        <div className="flex items-center gap-3">
          <div className="bg-white border border-purple-100 rounded-2xl px-5 py-2.5 shadow-2xs text-center">
            <span className="text-xl font-black text-purple-700 block leading-none">124</span>
            <span className="text-[9px] font-extrabold uppercase tracking-widest text-slate-400 mt-1 block">OPEN</span>
          </div>
          <div className="bg-white border border-purple-100 rounded-2xl px-5 py-2.5 shadow-2xs text-center">
            <span className="text-xl font-black text-slate-800 block leading-none">38</span>
            <span className="text-[9px] font-extrabold uppercase tracking-widest text-slate-400 mt-1 block">IN PROGRESS</span>
          </div>
          <div className="bg-white border border-purple-100 rounded-2xl px-5 py-2.5 shadow-2xs text-center">
            <span className="text-xl font-black text-emerald-600 block leading-none">892</span>
            <span className="text-[9px] font-extrabold uppercase tracking-widest text-slate-400 mt-1 block">RESOLVED</span>
          </div>
        </div>
      </div>

      {/* Split Workspace Layout */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left Column: Ticket List Feed */}
        <div className="bg-white rounded-2xl border border-purple-100/70 shadow-xs p-4 space-y-4">
          {/* Search & Filter bar */}
          <div className="space-y-3">
            <div className="relative">
              <input
                type="text"
                placeholder="Search tickets, users, IDs..."
                className="w-full px-3.5 py-2 pl-9 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold text-slate-800 focus:outline-none"
              />
              <Search className="w-3.5 h-3.5 text-slate-400 absolute left-3 top-2.5" />
            </div>

            <div className="flex items-center gap-1.5">
              {[
                { id: 'all' as const, label: 'All Active' },
                { id: 'high' as const, label: 'High Priority' },
                { id: 'disputes' as const, label: 'Disputes' },
              ].map((f) => (
                <button
                  key={f.id}
                  onClick={() => setFilterMode(f.id)}
                  className={`px-3 py-1 rounded-lg text-[11px] font-bold transition-colors cursor-pointer ${
                    filterMode === f.id
                      ? 'bg-[#6D28D9] text-white'
                      : 'bg-slate-50 text-slate-600 hover:bg-purple-50'
                  }`}
                >
                  {f.label}
                </button>
              ))}
            </div>
          </div>

          {/* Ticket Cards */}
          <div className="space-y-2 pt-1">
            {tickets.map((t) => {
              const isSelected = selectedTicketId === t.id;
              return (
                <div
                  key={t.id}
                  onClick={() => setSelectedTicketId(t.id)}
                  className={`p-3.5 rounded-xl border transition-all cursor-pointer ${
                    isSelected
                      ? 'bg-purple-50/70 border-purple-300 shadow-xs'
                      : 'bg-white border-slate-100 hover:border-purple-200 hover:bg-slate-50/50'
                  }`}
                >
                  <div className="flex items-center justify-between">
                    <span className="text-[10px] font-mono font-bold text-slate-400">#{t.id}</span>
                    <span
                      className={`px-2 py-0.5 rounded text-[9px] font-extrabold uppercase ${
                        t.priority === 'Critical Priority'
                          ? 'bg-red-50 text-red-600 border border-red-200'
                          : t.priority === 'Escalated'
                          ? 'bg-amber-50 text-amber-600 border border-amber-200'
                          : 'bg-slate-100 text-slate-600'
                      }`}
                    >
                      {t.priority}
                    </span>
                  </div>

                  <h4 className="text-xs font-bold text-slate-900 mt-1.5 leading-snug">{t.title}</h4>
                  <div className="flex items-center justify-between text-[10px] text-slate-400 font-medium mt-2">
                    <span>{t.requester}</span>
                    <span className="font-mono text-purple-700 font-bold">{t.sla}</span>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Right Column: Ticket Detail Inspector */}
        <div className="lg:col-span-2 bg-white rounded-2xl border border-purple-100/70 shadow-xs p-6 space-y-6 flex flex-col justify-between">
          <div className="space-y-6">
            {/* Ticket Header & Status */}
            <div className="flex flex-wrap items-center justify-between gap-4 border-b border-slate-100 pb-4">
              <div>
                <div className="flex items-center gap-2">
                  <span className="text-xs font-mono font-bold text-slate-400">#TCK-8921</span>
                  <span className="px-2 py-0.5 bg-red-50 text-red-600 border border-red-200 rounded text-[9px] font-extrabold uppercase">
                    Critical Priority
                  </span>
                  <span className="px-2 py-0.5 bg-purple-50 text-purple-700 border border-purple-200 rounded text-[9px] font-extrabold uppercase">
                    Dispute
                  </span>
                </div>
                <h2 className="text-lg font-black text-slate-900 mt-1">
                  Placement Offer Dispute - Data Mismatch
                </h2>
              </div>

              <div className="flex items-center gap-2">
                <button className="px-3 py-1.5 bg-slate-50 hover:bg-slate-100 text-slate-700 font-bold border border-slate-200 rounded-xl text-xs flex items-center gap-1.5 cursor-pointer">
                  <UserCheck className="w-3.5 h-3.5" />
                  <span>Assign</span>
                </button>
                <button
                  onClick={() => setTicketResolved(!ticketResolved)}
                  className={`px-4 py-1.5 font-bold rounded-xl text-xs flex items-center gap-1.5 transition-all cursor-pointer ${
                    ticketResolved
                      ? 'bg-emerald-600 text-white shadow-md'
                      : 'bg-[#6D28D9] hover:bg-[#5B21B6] text-white shadow-md shadow-purple-500/20'
                  }`}
                >
                  <CheckCircle2 className="w-3.5 h-3.5" />
                  <span>{ticketResolved ? 'Resolved' : 'Resolve'}</span>
                </button>
              </div>
            </div>

            {/* Requester Metadata & SLA Timer Bar */}
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 p-3.5 bg-slate-50/70 border border-slate-100 rounded-xl text-xs">
              <div>
                <span className="text-[10px] font-extrabold uppercase tracking-wider text-slate-400 block">REQUESTER</span>
                <span className="font-bold text-slate-900">John Doe (Student)</span>
              </div>
              <div>
                <span className="text-[10px] font-extrabold uppercase tracking-wider text-slate-400 block">ORGANIZATION</span>
                <span className="font-bold text-slate-800">State University</span>
              </div>
              <div>
                <span className="text-[10px] font-extrabold uppercase tracking-wider text-slate-400 block">CREATED</span>
                <span className="font-mono text-slate-600">Oct 24, 09:41 AM</span>
              </div>
              <div>
                <span className="text-[10px] font-extrabold uppercase tracking-wider text-slate-400 block">SLA TARGET</span>
                <span className="font-mono text-red-500 font-extrabold flex items-center gap-1">
                  <Clock className="w-3 h-3" />
                  <span>2h 14m remaining</span>
                </span>
              </div>
            </div>

            {/* Ticket Message Thread */}
            <div className="space-y-4 pt-2">
              <div className="flex items-start gap-3 p-4 bg-slate-50/50 border border-slate-100 rounded-2xl">
                <img
                  src="https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&auto=format&fit=crop&q=80"
                  alt="John Doe"
                  className="w-8 h-8 rounded-full object-cover border border-purple-100 shrink-0"
                />
                <div className="space-y-2 flex-1 text-xs">
                  <div className="flex items-center justify-between">
                    <span className="font-bold text-slate-900">John Doe</span>
                    <span className="text-[10px] font-mono text-slate-400">Oct 24, 09:41 AM</span>
                  </div>
                  <p className="text-slate-700 leading-relaxed font-medium">
                    {"Hello,"}
                  </p>
                  <p className="text-slate-700 leading-relaxed font-medium">
                    {"The placement offer letter generated in the portal for my position at TechCorp Inc. has the incorrect starting salary listed. It shows $65,000 but my signed agreement was for $70,000."}
                  </p>
                  <p className="text-slate-700 leading-relaxed font-medium">
                    {"This needs to be corrected before I can officially accept the transition packet through the university portal. I have attached the original offer email for reference."}
                  </p>

                  {/* Attachment Pill */}
                  <div className="pt-2">
                    <div className="inline-flex items-center gap-2 bg-white border border-slate-200/80 px-3 py-1.5 rounded-xl text-xs font-bold text-slate-700 hover:border-purple-300 shadow-2xs">
                      <Paperclip className="w-3.5 h-3.5 text-purple-600" />
                      <span>Offer_Email_Thread.pdf</span>
                      <span className="text-[10px] font-mono text-slate-400">1.2 MB</span>
                      <Download className="w-3.5 h-3.5 text-slate-400 hover:text-purple-700 cursor-pointer ml-1" />
                    </div>
                  </div>
                </div>
              </div>

              {/* Automated System Check Pill */}
              <div className="flex items-center justify-center">
                <div className="bg-purple-50 border border-purple-100 px-4 py-1.5 rounded-full text-[11px] font-bold text-purple-700 flex items-center gap-2">
                  <ShieldCheck className="w-3.5 h-3.5" />
                  <span>Automated System Check: Offer ID #89214 Verified</span>
                </div>
              </div>
            </div>
          </div>

          {/* Reply Composition Area */}
          <div className="space-y-3 pt-4 border-t border-slate-100">
            {/* Editor Toolbar */}
            <div className="flex items-center justify-between text-xs text-slate-500 font-bold">
              <div className="flex items-center gap-2">
                <button className="px-2 py-1 bg-slate-100 rounded hover:bg-slate-200 text-slate-700">B</button>
                <button className="px-2 py-1 bg-slate-100 rounded hover:bg-slate-200 text-slate-700 italic">I</button>
                <button className="px-2 py-1 bg-slate-100 rounded hover:bg-slate-200 text-slate-700 font-mono">List</button>
              </div>

              <div className="flex items-center gap-3">
                <button className="text-purple-700 hover:underline cursor-pointer">Templates</button>
                <label className="flex items-center gap-1.5 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={isInternalNote}
                    onChange={(e) => setIsInternalNote(e.target.checked)}
                    className="rounded text-[#6D28D9] focus:ring-[#6D28D9]"
                  />
                  <span>Internal Note</span>
                </label>
              </div>
            </div>

            <textarea
              rows={3}
              placeholder="Type your reply here..."
              value={replyText}
              onChange={(e) => setReplyText(e.target.value)}
              className="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium text-slate-800 focus:outline-none focus:ring-2 focus:ring-[#6D28D9]/30 resize-none"
            ></textarea>

            <div className="flex justify-end">
              <button
                onClick={() => setReplyText('')}
                className="px-5 py-2 bg-[#6D28D9] hover:bg-[#5B21B6] text-white font-bold rounded-xl text-xs flex items-center gap-2 shadow-md shadow-purple-500/20 cursor-pointer"
              >
                <Send className="w-3.5 h-3.5" />
                <span>Send Reply</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default SupportCenter;
