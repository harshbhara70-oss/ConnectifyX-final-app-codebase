import React, { useState, useMemo } from "react";
import {
  Send,
  Search,
  Megaphone,
  FileText,
  Eye,
  AlertTriangle,
  Upload,
  X,
  CheckCircle2,
  Users
} from "lucide-react";

export interface BroadcastLogItem {
  id: string;
  type: "megaphone" | "document";
  title: string;
  snippet: string;
  fullBody?: string;
  isUrgent?: boolean;
  targetAudience: string;
  dateSent: string;
  readCount: number;
  totalCount: number;
  status: "Sent" | "Draft";
}

export interface BatchGroupItem {
  id: string;
  name: string;
  description: string;
  memberCount: number;
  coordinator: string;
  tagColor: string;
}

const INITIAL_BROADCASTS: BroadcastLogItem[] = [
  {
    id: "bcast-1",
    type: "megaphone",
    title: "Google Recruitment Drive - Preliminary Shortlist",
    snippet: "Please review the preliminary shortlist for the upcoming Google engineering interviews scheduled for next week...",
    fullBody: "Please review the preliminary shortlist for the upcoming Google engineering interviews scheduled for next week. Shortlisted candidates must report to Seminar Hall B at 9:00 AM.",
    isUrgent: true,
    targetAudience: "CS & IT 2024 Batch",
    dateSent: "Oct 12, 2023",
    readCount: 145,
    totalCount: 200,
    status: "Sent"
  },
  {
    id: "bcast-2",
    type: "document",
    title: "Weekly Placement Readiness Mock Test",
    snippet: "The mock test platform is now open for the weekly DSA & System Design assessment module...",
    fullBody: "The mock test platform is now open for the weekly DSA & System Design assessment module. Ensure test submission before Sunday midnight.",
    isUrgent: false,
    targetAudience: "All Final Years",
    dateSent: "Oct 10, 2023",
    readCount: 833,
    totalCount: 850,
    status: "Sent"
  },
  {
    id: "bcast-3",
    type: "megaphone",
    title: "Stripe Technical Assessment Slot Allotment",
    snippet: "Individual test access credentials and online proctoring links have been dispatched...",
    fullBody: "Individual test access credentials and online proctoring links have been dispatched to shortlisted candidates. Check your student email portal.",
    isUrgent: true,
    targetAudience: "Shortlisted Candidates",
    dateSent: "Oct 08, 2023",
    readCount: 42,
    totalCount: 45,
    status: "Sent"
  },
  {
    id: "bcast-4",
    type: "document",
    title: "Mandatory Resume Verification Reminder",
    snippet: "All unplaced candidates must update their project links and GitHub profiles before Friday...",
    fullBody: "All unplaced candidates must update their project links and GitHub profiles before Friday 5:00 PM for upcoming recruiter shortlist submissions.",
    isUrgent: false,
    targetAudience: "Unplaced Candidates",
    dateSent: "Oct 05, 2023",
    readCount: 310,
    totalCount: 350,
    status: "Sent"
  }
];

const INITIAL_DRAFTS: BroadcastLogItem[] = [
  {
    id: "draft-1",
    type: "document",
    title: "Draft: Amazon APAC Campus Hiring Timeline 2024",
    snippet: "Initial details regarding eligibility cutoff and registration window...",
    fullBody: "Initial details regarding eligibility cutoff and registration window for Amazon SDE 1 campus placement drive.",
    isUrgent: false,
    targetAudience: "All Final Years",
    dateSent: "Draft (Saved 2 hrs ago)",
    readCount: 0,
    totalCount: 850,
    status: "Draft"
  },
  {
    id: "draft-2",
    type: "megaphone",
    title: "Draft: Placement Cell Feedback Survey Q3",
    snippet: "Collecting feedback regarding recent campus pre-placement talks...",
    fullBody: "Collecting feedback regarding recent campus pre-placement talks and interview experience.",
    isUrgent: false,
    targetAudience: "All Students",
    dateSent: "Draft (Saved yesterday)",
    readCount: 0,
    totalCount: 1200,
    status: "Draft"
  }
];

const MOCK_BATCH_GROUPS: BatchGroupItem[] = [
  {
    id: "grp-1",
    name: "CS & IT 2024 Batch",
    description: "Computer Science and Information Technology graduating seniors",
    memberCount: 200,
    coordinator: "Prof. Rajesh Kumar",
    tagColor: "bg-purple-100 text-purple-700 border-purple-200"
  },
  {
    id: "grp-2",
    name: "All Final Years",
    description: "Entire 2024 graduating batch across all engineering departments",
    memberCount: 850,
    coordinator: "Dr. Sarah Jenkins",
    tagColor: "bg-indigo-100 text-indigo-700 border-indigo-200"
  },
  {
    id: "grp-3",
    name: "Electronics 2024 Batch",
    description: "ECE & Electrical Engineering placement candidates",
    memberCount: 180,
    coordinator: "Dr. Ananya Rao",
    tagColor: "bg-blue-100 text-blue-700 border-blue-200"
  },
  {
    id: "grp-4",
    name: "Corporate Recruiters & HRs",
    description: "Verified corporate talent acquisition contacts and TPO liaisons",
    memberCount: 65,
    coordinator: "Central TPO Cell",
    tagColor: "bg-emerald-100 text-emerald-700 border-emerald-200"
  }
];

export const BroadcastCenterView: React.FC = () => {
  // State
  const [broadcasts, setBroadcasts] = useState<BroadcastLogItem[]>(INITIAL_BROADCASTS);
  const [drafts, setDrafts] = useState<BroadcastLogItem[]>(INITIAL_DRAFTS);
  const [activeTab, setActiveTab] = useState<"all" | "drafts" | "batches">("all");

  // Search state
  const [searchQuery, setSearchQuery] = useState("");

  // Modal composition wizard state
  const [isComposeModalOpen, setIsComposeModalOpen] = useState(false);
  const [composeForm, setComposeForm] = useState({
    title: "",
    targetAudience: "CS & IT 2024 Batch",
    isUrgent: false,
    body: ""
  });

  // Selected Broadcast detail drawer / view modal
  const [viewingBroadcast, setViewingBroadcast] = useState<BroadcastLogItem | null>(null);

  // Toast Notification
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => {
      setToastMessage(null);
    }, 4000);
  };

  // Filtered Broadcasts based on search query
  const filteredBroadcasts = useMemo(() => {
    return broadcasts.filter((b) => {
      const q = searchQuery.toLowerCase().trim();
      return (
        !q ||
        b.title.toLowerCase().includes(q) ||
        b.targetAudience.toLowerCase().includes(q) ||
        b.snippet.toLowerCase().includes(q)
      );
    });
  }, [broadcasts, searchQuery]);

  // Filtered Drafts
  const filteredDrafts = useMemo(() => {
    return drafts.filter((d) => {
      const q = searchQuery.toLowerCase().trim();
      return !q || d.title.toLowerCase().includes(q) || d.targetAudience.toLowerCase().includes(q);
    });
  }, [drafts, searchQuery]);

  // Total Sent Counter Calculation
  const totalSentCount = useMemo(() => {
    return 1248 + (broadcasts.length - INITIAL_BROADCASTS.length);
  }, [broadcasts]);

  // Send New Broadcast Handler
  const handleSendBroadcast = (e: React.FormEvent) => {
    e.preventDefault();
    if (!composeForm.title.trim() || !composeForm.body.trim()) return;

    let estCount = 200;
    if (composeForm.targetAudience === "All Final Years") estCount = 850;
    else if (composeForm.targetAudience === "All Students") estCount = 1200;
    else if (composeForm.targetAudience === "Corporate Recruiters & HRs") estCount = 65;

    const newBroadcast: BroadcastLogItem = {
      id: `bcast-${Date.now()}`,
      type: composeForm.isUrgent ? "megaphone" : "document",
      title: composeForm.title,
      snippet: composeForm.body.length > 80 ? `${composeForm.body.slice(0, 80)}...` : composeForm.body,
      fullBody: composeForm.body,
      isUrgent: composeForm.isUrgent,
      targetAudience: composeForm.targetAudience,
      dateSent: "Just now",
      readCount: 1,
      totalCount: estCount,
      status: "Sent"
    };

    setBroadcasts([newBroadcast, ...broadcasts]);
    setIsComposeModalOpen(false);
    showToast(`Broadcast "${newBroadcast.title}" dispatched to ${estCount} recipients!`);

    // Reset Form
    setComposeForm({
      title: "",
      targetAudience: "CS & IT 2024 Batch",
      isUrgent: false,
      body: ""
    });
  };

  // Save Draft Handler
  const handleSaveDraft = () => {
    if (!composeForm.title.trim()) return;

    const newDraft: BroadcastLogItem = {
      id: `draft-${Date.now()}`,
      type: "document",
      title: composeForm.title.startsWith("Draft:") ? composeForm.title : `Draft: ${composeForm.title}`,
      snippet: composeForm.body.length > 80 ? `${composeForm.body.slice(0, 80)}...` : composeForm.body || "No message body written...",
      fullBody: composeForm.body,
      isUrgent: composeForm.isUrgent,
      targetAudience: composeForm.targetAudience,
      dateSent: "Draft (Saved just now)",
      readCount: 0,
      totalCount: 200,
      status: "Draft"
    };

    setDrafts([newDraft, ...drafts]);
    setIsComposeModalOpen(false);
    showToast("Broadcast message saved to Drafts.");

    // Reset Form
    setComposeForm({
      title: "",
      targetAudience: "CS & IT 2024 Batch",
      isUrgent: false,
      body: ""
    });
  };

  // Publish Draft immediately
  const handlePublishDraft = (draft: BroadcastLogItem) => {
    const published: BroadcastLogItem = {
      ...draft,
      title: draft.title.replace(/^Draft:\s*/i, ""),
      dateSent: "Just now",
      readCount: 1,
      status: "Sent"
    };

    setBroadcasts([published, ...broadcasts]);
    setDrafts(drafts.filter((d) => d.id !== draft.id));
    showToast(`Draft "${published.title}" published and sent successfully!`);
  };

  return (
    <div className="space-y-6 pb-12">
      {/* Global Toast Notification */}
      {toastMessage && (
        <div className="fixed bottom-6 right-6 z-50 bg-slate-900 text-white text-xs font-semibold px-4 py-3 rounded-2xl shadow-2xl flex items-center gap-3 border border-slate-800 animate-bounce">
          <CheckCircle2 className="w-5 h-5 text-emerald-400 shrink-0" />
          <span>{toastMessage}</span>
          <button onClick={() => setToastMessage(null)} className="text-slate-400 hover:text-white ml-2">
            <X className="w-4 h-4" />
          </button>
        </div>
      )}

      {/* 1. Top Action Toolbar & Header */}
      <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl md:text-3xl font-extrabold text-slate-900 tracking-tight">
            Broadcast Center
          </h1>
          <p className="text-xs md:text-sm text-slate-500 font-medium mt-1">
            Communicate with students, batches, and corporate partners across the campus.
          </p>
        </div>

        <div className="flex items-center gap-3 flex-wrap">
          {/* Global Search Bar */}
          <div className="relative min-w-[240px] sm:min-w-[300px]">
            <Search className="w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search broadcasts, batches, or recruiters..."
              className="w-full bg-white text-xs md:text-sm pl-10 pr-8 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-purple-500/30 transition-all placeholder:text-slate-400 shadow-2xs"
            />
            {searchQuery && (
              <button
                onClick={() => setSearchQuery("")}
                className="absolute right-3.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 p-1"
              >
                <X className="w-3.5 h-3.5" />
              </button>
            )}
          </div>

          {/* New Broadcast CTA Button */}
          <button
            onClick={() => setIsComposeModalOpen(true)}
            className="bg-[#7C3AED] hover:bg-[#6B21A8] active:bg-purple-900 text-white font-bold px-4 py-2.5 rounded-xl shadow-md shadow-purple-500/20 text-xs md:text-sm flex items-center gap-2 transition-all cursor-pointer transform hover:-translate-y-0.5"
          >
            <Send className="w-4 h-4 stroke-[2.5]" />
            <span>New Broadcast</span>
          </button>
        </div>
      </div>

      {/* 2. Interactive Navigation Tabs */}
      <div className="flex items-center gap-6 border-b border-slate-200/80">
        <button
          onClick={() => setActiveTab("all")}
          className={`pb-2.5 text-xs md:text-sm font-extrabold transition-all cursor-pointer relative ${
            activeTab === "all" ? "text-[#7C3AED]" : "text-slate-500 hover:text-slate-800"
          }`}
        >
          <span>All Broadcasts</span>
          {activeTab === "all" && (
            <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-[#7C3AED] rounded-full" />
          )}
        </button>

        <button
          onClick={() => setActiveTab("drafts")}
          className={`pb-2.5 text-xs md:text-sm font-extrabold transition-all cursor-pointer relative flex items-center gap-1.5 ${
            activeTab === "drafts" ? "text-[#7C3AED]" : "text-slate-500 hover:text-slate-800"
          }`}
        >
          <span>Drafts</span>
          {drafts.length > 0 && (
            <span className="bg-purple-100 text-purple-700 text-[10px] font-black px-2 py-0.5 rounded-full">
              {drafts.length}
            </span>
          )}
          {activeTab === "drafts" && (
            <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-[#7C3AED] rounded-full" />
          )}
        </button>

        <button
          onClick={() => setActiveTab("batches")}
          className={`pb-2.5 text-xs md:text-sm font-extrabold transition-all cursor-pointer relative ${
            activeTab === "batches" ? "text-[#7C3AED]" : "text-slate-500 hover:text-slate-800"
          }`}
        >
          <span>Batch Groups</span>
          {activeTab === "batches" && (
            <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-[#7C3AED] rounded-full" />
          )}
        </button>
      </div>

      {/* 3. Key Metrics Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
        {/* Card 1: TOTAL SENT */}
        <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-xs flex flex-col justify-between space-y-4">
          <div className="flex items-center justify-between">
            <div className="w-10 h-10 rounded-xl bg-purple-50 text-[#7C3AED] flex items-center justify-center">
              <Upload className="w-5 h-5" />
            </div>
            <span className="bg-[#7C3AED] text-white text-[10px] font-black uppercase px-2.5 py-1 rounded-full tracking-wider">
              TOTAL SENT
            </span>
          </div>
          <div>
            <div className="text-3xl font-black text-slate-900 tracking-tight">
              {totalSentCount.toLocaleString()}
            </div>
            <p className="text-xs font-semibold text-slate-400 mt-1">Broadcasts this semester</p>
          </div>
        </div>

        {/* Card 2: AVG OPEN RATE */}
        <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-xs flex flex-col justify-between space-y-4">
          <div className="flex items-center justify-between">
            <div className="w-10 h-10 rounded-xl bg-purple-50 text-[#7C3AED] flex items-center justify-center">
              <Eye className="w-5 h-5" />
            </div>
            <span className="bg-purple-100 text-purple-700 text-[10px] font-black uppercase px-2.5 py-1 rounded-full tracking-wider">
              AVG OPEN RATE
            </span>
          </div>
          <div>
            <div className="text-3xl font-black text-slate-900 tracking-tight">92.4%</div>
            <p className="text-xs font-semibold text-emerald-600 mt-1 flex items-center gap-1">
              <span>+4.2% from last month</span>
            </p>
          </div>
        </div>

        {/* Card 3: URGENT PENDING CARD (RED BORDER & BADGE) */}
        <div className="bg-white p-5 rounded-2xl border-2 border-rose-400/90 shadow-xs flex flex-col justify-between space-y-4 relative overflow-hidden bg-rose-50/10">
          <div className="flex items-center justify-between">
            <div className="w-10 h-10 rounded-xl bg-rose-100 text-rose-600 flex items-center justify-center">
              <AlertTriangle className="w-5 h-5" />
            </div>
            <span className="bg-rose-100 text-rose-600 text-[10px] font-black uppercase px-2.5 py-1 rounded-full tracking-wider">
              URGENT PENDING
            </span>
          </div>
          <div>
            <div className="text-3xl font-black text-slate-900 tracking-tight">03</div>
            <p className="text-xs font-semibold text-slate-500 mt-1">Requiring immediate action</p>
          </div>
        </div>
      </div>

      {/* 4. Main Tab View Panels */}
      {activeTab === "all" && (
        /* BROADCAST DATA TABLE & FEED */
        <div className="bg-white rounded-2xl border border-slate-100 shadow-xs overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="border-b border-slate-100 bg-slate-50/50 text-[11px] font-extrabold text-slate-400 uppercase tracking-wider">
                  <th className="py-4 px-5">MESSAGE DETAIL</th>
                  <th className="py-4 px-4">TARGET AUDIENCE</th>
                  <th className="py-4 px-4">DATE SENT</th>
                  <th className="py-4 px-5 text-right pr-8">READ RECEIPTS</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 text-xs font-medium">
                {filteredBroadcasts.length > 0 ? (
                  filteredBroadcasts.map((item) => {
                    const readPercentage = Math.round((item.readCount / item.totalCount) * 100);

                    return (
                      <tr
                        key={item.id}
                        onClick={() => setViewingBroadcast(item)}
                        className="hover:bg-slate-50/80 transition-colors cursor-pointer group"
                      >
                        {/* Message Detail Column */}
                        <td className="py-4 px-5">
                          <div className="flex items-center gap-3.5">
                            {/* Icon container */}
                            <div
                              className={`w-10 h-10 rounded-2xl flex items-center justify-center shrink-0 ${
                                item.type === "megaphone"
                                  ? "bg-purple-100 text-purple-600"
                                  : "bg-slate-100 text-slate-500"
                              }`}
                            >
                              {item.type === "megaphone" ? (
                                <Megaphone className="w-5 h-5" />
                              ) : (
                                <FileText className="w-5 h-5" />
                              )}
                            </div>

                            <div>
                              <div className="flex items-center gap-2">
                                <h3 className="text-sm font-extrabold text-slate-900 group-hover:text-purple-700 transition-colors">
                                  {item.title}
                                </h3>
                                {item.isUrgent && (
                                  <span className="bg-rose-100 text-rose-600 font-black text-[10px] uppercase px-2 py-0.5 rounded-md tracking-wider">
                                    URGENT
                                  </span>
                                )}
                              </div>
                              <p className="text-xs text-slate-400 font-normal mt-0.5 max-w-md truncate">
                                {item.snippet}
                              </p>
                            </div>
                          </div>
                        </td>

                        {/* Target Audience Column */}
                        <td className="py-4 px-4">
                          <span className="bg-slate-100 text-slate-700 text-xs font-semibold px-3 py-1.5 rounded-full inline-block">
                            {item.targetAudience}
                          </span>
                        </td>

                        {/* Date Sent Column */}
                        <td className="py-4 px-4 text-slate-500 font-semibold">
                          {item.dateSent}
                        </td>

                        {/* Read Receipts Column */}
                        <td className="py-4 px-5 text-right pr-8">
                          <div className="inline-flex flex-col items-end min-w-[140px]">
                            {/* Progress bar container */}
                            <div className="w-32 bg-slate-100 h-2 rounded-full overflow-hidden mb-1">
                              <div
                                className="h-full bg-[#7C3AED] rounded-full transition-all duration-500"
                                style={{ width: `${readPercentage}%` }}
                              />
                            </div>
                            <span className="text-[11px] font-bold text-slate-400">
                              {item.readCount} / {item.totalCount} Read
                            </span>
                          </div>
                        </td>
                      </tr>
                    );
                  })
                ) : (
                  <tr>
                    <td colSpan={4} className="py-12 text-center text-slate-400 text-xs">
                      No broadcast records found matching your search.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {activeTab === "drafts" && (
        /* DRAFTS TAB PANEL */
        <div className="bg-white rounded-2xl border border-slate-100 p-6 shadow-xs space-y-4">
          <div className="flex items-center justify-between">
            <h3 className="text-base font-extrabold text-slate-900">Saved Broadcast Drafts</h3>
            <span className="text-xs text-slate-400 font-semibold">{filteredDrafts.length} Pending Drafts</span>
          </div>

          {filteredDrafts.length > 0 ? (
            <div className="space-y-3">
              {filteredDrafts.map((d) => (
                <div
                  key={d.id}
                  className="p-4 rounded-2xl border border-slate-200/80 bg-slate-50 hover:bg-purple-50/40 transition-all flex flex-col md:flex-row md:items-center justify-between gap-4"
                >
                  <div className="flex items-center gap-3.5">
                    <div className="w-10 h-10 rounded-2xl bg-amber-100 text-amber-700 flex items-center justify-center shrink-0">
                      <FileText className="w-5 h-5" />
                    </div>
                    <div>
                      <h4 className="text-sm font-extrabold text-slate-900">{d.title}</h4>
                      <p className="text-xs text-slate-500 font-medium">{d.snippet}</p>
                      <div className="flex items-center gap-2 mt-1">
                        <span className="text-[10px] font-bold bg-slate-200 text-slate-700 px-2 py-0.5 rounded-md">
                          Audience: {d.targetAudience}
                        </span>
                        <span className="text-[10px] text-slate-400 font-semibold">{d.dateSent}</span>
                      </div>
                    </div>
                  </div>

                  <div className="flex items-center gap-2 justify-end">
                    <button
                      onClick={() => handlePublishDraft(d)}
                      className="bg-[#7C3AED] hover:bg-[#6B21A8] text-white font-bold text-xs px-4 py-2 rounded-xl shadow-xs transition-all flex items-center gap-1.5 cursor-pointer"
                    >
                      <Send className="w-3.5 h-3.5" /> Send Now
                    </button>
                    <button
                      onClick={() => {
                        setDrafts(drafts.filter((item) => item.id !== d.id));
                        showToast("Draft deleted.");
                      }}
                      className="text-slate-400 hover:text-rose-600 p-2 rounded-xl"
                    >
                      <X className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-xs text-slate-400 font-medium py-8 text-center bg-slate-50 rounded-xl">
              No draft messages saved. Click &quot;New Broadcast&quot; to compose a message.
            </p>
          )}
        </div>
      )}

      {activeTab === "batches" && (
        /* BATCH GROUPS PANEL */
        <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
          {MOCK_BATCH_GROUPS.map((grp) => (
            <div
              key={grp.id}
              className="bg-white p-5 rounded-2xl border border-slate-100 shadow-xs flex flex-col justify-between space-y-4 hover:shadow-md transition-all"
            >
              <div className="flex items-start justify-between gap-3">
                <div>
                  <span className={`text-[10px] font-black uppercase px-2.5 py-0.5 rounded-full border ${grp.tagColor}`}>
                    {grp.memberCount} MEMBERS
                  </span>
                  <h3 className="text-base font-extrabold text-slate-900 mt-2">{grp.name}</h3>
                  <p className="text-xs text-slate-500 font-medium mt-0.5">{grp.description}</p>
                </div>
                <div className="w-10 h-10 rounded-2xl bg-purple-50 text-purple-600 flex items-center justify-center shrink-0">
                  <Users className="w-5 h-5" />
                </div>
              </div>

              <div className="pt-3 border-t border-slate-100 flex items-center justify-between text-xs">
                <span className="text-slate-400 font-semibold">
                  Coordinator: <strong className="text-slate-700">{grp.coordinator}</strong>
                </span>
                <button
                  onClick={() => {
                    setComposeForm((prev) => ({ ...prev, targetAudience: grp.name }));
                    setIsComposeModalOpen(true);
                  }}
                  className="bg-purple-50 hover:bg-purple-100 text-purple-700 font-bold px-3 py-1.5 rounded-xl transition-colors cursor-pointer flex items-center gap-1"
                >
                  <Send className="w-3 h-3" /> New Message
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* MODAL: + New Broadcast Composition Wizard */}
      {isComposeModalOpen && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl space-y-5 animate-in zoom-in-95 duration-200">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-xl bg-purple-100 text-purple-700 flex items-center justify-center font-bold">
                  <Send className="w-4 h-4" />
                </div>
                <h3 className="text-lg font-extrabold text-slate-900">Compose New Broadcast</h3>
              </div>
              <button
                onClick={() => setIsComposeModalOpen(false)}
                className="text-slate-400 hover:text-slate-600 p-1"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleSendBroadcast} className="space-y-4 text-xs font-medium">
              <div>
                <label className="font-bold text-slate-700 block mb-1">Broadcast Subject / Title</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Google Recruitment Drive - Preliminary Shortlist"
                  value={composeForm.title}
                  onChange={(e) => setComposeForm({ ...composeForm, title: e.target.value })}
                  className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Target Audience</label>
                  <select
                    value={composeForm.targetAudience}
                    onChange={(e) => setComposeForm({ ...composeForm, targetAudience: e.target.value })}
                    className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                  >
                    <option value="CS & IT 2024 Batch">CS &amp; IT 2024 Batch</option>
                    <option value="All Final Years">All Final Years</option>
                    <option value="Electronics 2024 Batch">Electronics 2024 Batch</option>
                    <option value="Corporate Recruiters & HRs">Corporate Recruiters &amp; HRs</option>
                    <option value="All Students">All Students</option>
                  </select>
                </div>

                <div>
                  <label className="font-bold text-slate-700 block mb-1">Priority Flag</label>
                  <div className="flex items-center gap-2 pt-1">
                    <button
                      type="button"
                      onClick={() => setComposeForm({ ...composeForm, isUrgent: false })}
                      className={`flex-1 py-2 rounded-xl font-bold transition-all ${
                        !composeForm.isUrgent
                          ? "bg-slate-200 text-slate-800"
                          : "bg-slate-100 text-slate-500"
                      }`}
                    >
                      Normal
                    </button>
                    <button
                      type="button"
                      onClick={() => setComposeForm({ ...composeForm, isUrgent: true })}
                      className={`flex-1 py-2 rounded-xl font-bold transition-all ${
                        composeForm.isUrgent
                          ? "bg-rose-100 text-rose-600 border border-rose-200"
                          : "bg-slate-100 text-slate-500"
                      }`}
                    >
                      Urgent
                    </button>
                  </div>
                </div>
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Message Body</label>
                <textarea
                  rows={4}
                  required
                  placeholder="Write message details for the selected student or recruiter audience..."
                  value={composeForm.body}
                  onChange={(e) => setComposeForm({ ...composeForm, body: e.target.value })}
                  className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                />
              </div>

              <div className="flex items-center justify-end gap-3 pt-4 border-t border-slate-100">
                <button
                  type="button"
                  onClick={handleSaveDraft}
                  className="px-4 py-2.5 text-slate-600 font-bold hover:bg-slate-100 rounded-xl"
                >
                  Save as Draft
                </button>
                <button
                  type="submit"
                  className="bg-[#7C3AED] hover:bg-[#6B21A8] text-white font-bold px-5 py-2.5 rounded-xl shadow-md shadow-purple-500/20 flex items-center gap-1.5"
                >
                  <Send className="w-3.5 h-3.5" /> Send Broadcast Now
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* DRAWER / VIEW MODAL: Read Receipts & Message Detail */}
      {viewingBroadcast && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <Megaphone className="w-5 h-5 text-purple-600" />
                <h3 className="text-base font-extrabold text-slate-900">Broadcast Log Detail</h3>
              </div>
              <button
                onClick={() => setViewingBroadcast(null)}
                className="text-slate-400 hover:text-slate-600 p-1"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="space-y-3 text-xs">
              <div>
                <span className="text-[10px] font-bold text-slate-400 uppercase">SUBJECT</span>
                <h4 className="text-sm font-extrabold text-slate-900 mt-0.5">{viewingBroadcast.title}</h4>
              </div>

              <div className="flex justify-between items-center bg-slate-50 p-3 rounded-xl">
                <div>
                  <span className="text-[10px] font-bold text-slate-400 uppercase">AUDIENCE</span>
                  <div className="font-bold text-slate-800">{viewingBroadcast.targetAudience}</div>
                </div>
                <div>
                  <span className="text-[10px] font-bold text-slate-400 uppercase">DATE</span>
                  <div className="font-bold text-slate-800">{viewingBroadcast.dateSent}</div>
                </div>
              </div>

              <div>
                <span className="text-[10px] font-bold text-slate-400 uppercase">MESSAGE CONTENT</span>
                <p className="p-3 bg-slate-50 rounded-xl text-slate-700 font-medium leading-relaxed mt-1">
                  {viewingBroadcast.fullBody || viewingBroadcast.snippet}
                </p>
              </div>

              <div className="pt-2 border-t border-slate-100">
                <div className="flex justify-between items-center mb-1">
                  <span className="font-bold text-slate-700">Read Receipt Progress</span>
                  <span className="font-black text-purple-700">
                    {Math.round((viewingBroadcast.readCount / viewingBroadcast.totalCount) * 100)}%
                  </span>
                </div>
                <div className="w-full bg-slate-100 h-2.5 rounded-full overflow-hidden">
                  <div
                    className="h-full bg-[#7C3AED] rounded-full"
                    style={{
                      width: `${(viewingBroadcast.readCount / viewingBroadcast.totalCount) * 100}%`
                    }}
                  />
                </div>
                <div className="text-[10px] font-semibold text-slate-400 text-right mt-1">
                  {viewingBroadcast.readCount} of {viewingBroadcast.totalCount} recipients read
                </div>
              </div>
            </div>

            <div className="pt-3 border-t border-slate-100 flex justify-end">
              <button
                onClick={() => setViewingBroadcast(null)}
                className="bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold px-4 py-2 rounded-xl text-xs"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default BroadcastCenterView;
export const CommunicationsView = BroadcastCenterView;
