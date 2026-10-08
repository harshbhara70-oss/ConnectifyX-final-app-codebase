import React, { useState, useMemo } from "react";
import {
  Download,
  UserPlus,
  Pencil,
  Share2,
  Phone,
  Mail,
  Zap,
  TrendingUp,
  Star,
  MapPin,
  Building2,
  SlidersHorizontal,
  X,
  CheckCircle2,
  FileText,
  Send,
  Search
} from "lucide-react";

export interface RecruiterOpening {
  id: string;
  title: string;
  badge: "HIRING" | "SHORTLISTING" | "CLOSED";
  positions: number;
  packageText: string;
  deadlineText: string;
}

export interface IntelligenceEvent {
  id: string;
  title: string;
  timeAgo: string;
  description: string;
  iconType: "share" | "email" | "meeting" | "feedback";
}

export interface CorporatePartner {
  id: string;
  companyName: string;
  logoLetter: string;
  logoBg: string;
  statusBadge: "🟢 Highly Engaged" | "🟣 Active Drive" | "⚪ Pending Sync";
  lastActivity: string;
  location: string;
  industry: string;
  hiringVelocity: string;
  hiringVelocityTrend: string;
  conversionRate: string;
  conversionBenchmark: string;
  studentRating: number;
  contactName: string;
  contactTitle: string;
  contactAvatar: string;
  contactEmail: string;
  contactPhone: string;
  nextBestActionText: string;
  openings: RecruiterOpening[];
  intelligenceFeed: IntelligenceEvent[];
  sharedTalentCount: number;
  driveHistoryCount: number;
}

const INITIAL_PARTNERS: CorporatePartner[] = [
  {
    id: "part-1",
    companyName: "TechVanguard Systems",
    logoLetter: "T",
    logoBg: "bg-white text-slate-800 border-slate-200",
    statusBadge: "🟢 Highly Engaged",
    lastActivity: "2H AGO",
    location: "Palo Alto, CA",
    industry: "Software & AI",
    hiringVelocity: "High",
    hiringVelocityTrend: "+12%",
    conversionRate: "22.4%",
    conversionBenchmark: "Avg 18%",
    studentRating: 4.8,
    contactName: "Sarah Jenkins",
    contactTitle: "Senior Talent Acquisition Lead",
    contactAvatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200",
    contactEmail: "sarah.jenkins@techvanguard.io",
    contactPhone: "+1 (650) 555-0192",
    nextBestActionText: "TechVanguard viewed the 'Gold Tier Batch' packet 14 times today.",
    openings: [
      {
        id: "op-1",
        title: "Associate Software Engineer",
        badge: "HIRING",
        positions: 12,
        packageText: "18 - 24 LPA",
        deadlineText: "Deadline: Oct 12"
      },
      {
        id: "op-2",
        title: "Data Science Intern",
        badge: "SHORTLISTING",
        positions: 5,
        packageText: "45k Stipend",
        deadlineText: "Deadline: Closed"
      },
      {
        id: "op-3",
        title: "DevOps & Cloud Engineer",
        badge: "HIRING",
        positions: 8,
        packageText: "16 - 20 LPA",
        deadlineText: "Deadline: Nov 01"
      }
    ],
    intelligenceFeed: [
      {
        id: "ev-1",
        title: "Profiles Shared",
        timeAgo: "2h ago",
        description: "Batch 2024 Top 50 packet shared with Sarah via secure link.",
        iconType: "share"
      },
      {
        id: "ev-2",
        title: "Email Interaction",
        timeAgo: "Yesterday",
        description: "Confirmed receipt of new JD for DevOps role.",
        iconType: "email"
      },
      {
        id: "ev-3",
        title: "Meeting Held",
        timeAgo: "3 days ago",
        description: "On-campus visit for facility audit completed.",
        iconType: "meeting"
      },
      {
        id: "ev-4",
        title: "Feedback Received",
        timeAgo: "5 days ago",
        description: "Tech interview feedback: 'Strong coding skills, need more soft skill focus.'",
        iconType: "feedback"
      }
    ],
    sharedTalentCount: 50,
    driveHistoryCount: 6
  },
  {
    id: "part-2",
    companyName: "Lumina Robotics",
    logoLetter: "L",
    logoBg: "bg-slate-100 text-purple-700 border-purple-200",
    statusBadge: "🟣 Active Drive",
    lastActivity: "4H AGO",
    location: "Austin, TX",
    industry: "Robotics & Automation",
    hiringVelocity: "Medium",
    hiringVelocityTrend: "+8%",
    conversionRate: "19.5%",
    conversionBenchmark: "Avg 18%",
    studentRating: 4.6,
    contactName: "Marcus Vance",
    contactTitle: "Head of Campus Relations",
    contactAvatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200",
    contactEmail: "marcus.v@luminarobotics.com",
    contactPhone: "+1 (512) 555-0144",
    nextBestActionText: "Lumina Robotics requested 10 additional interview slots for ECE batch.",
    openings: [
      {
        id: "op-4",
        title: "Embedded Systems Hardware Engineer",
        badge: "HIRING",
        positions: 8,
        packageText: "15 - 20 LPA",
        deadlineText: "Deadline: Oct 28"
      }
    ],
    intelligenceFeed: [
      {
        id: "ev-5",
        title: "Drive Scheduled",
        timeAgo: "1h ago",
        description: "On-campus physical interviews locked for Nov 10.",
        iconType: "meeting"
      }
    ],
    sharedTalentCount: 35,
    driveHistoryCount: 3
  },
  {
    id: "part-3",
    companyName: "Nexus Fintech",
    logoLetter: "N",
    logoBg: "bg-slate-100 text-blue-700 border-blue-200",
    statusBadge: "⚪ Pending Sync",
    lastActivity: "1D AGO",
    location: "New York, NY",
    industry: "Fintech & Banking",
    hiringVelocity: "Moderate",
    hiringVelocityTrend: "+5%",
    conversionRate: "17.8%",
    conversionBenchmark: "Avg 18%",
    studentRating: 4.5,
    contactName: "Elena Rostova",
    contactTitle: "University Recruiting Lead",
    contactAvatar: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200",
    contactEmail: "elena.r@nexusfintech.com",
    contactPhone: "+1 (212) 555-0881",
    nextBestActionText: "Nexus Fintech pending NDA sign-off for autumn drive.",
    openings: [
      {
        id: "op-5",
        title: "Quantitative Risk Analyst",
        badge: "SHORTLISTING",
        positions: 6,
        packageText: "16.5 LPA",
        deadlineText: "Deadline: Nov 05"
      }
    ],
    intelligenceFeed: [
      {
        id: "ev-6",
        title: "NDA Contract Dispatched",
        timeAgo: "2 days ago",
        description: "Contract sent to Elena via legal portal.",
        iconType: "email"
      }
    ],
    sharedTalentCount: 20,
    driveHistoryCount: 2
  }
];

export const RecruiterCoordinationView: React.FC = () => {
  // State
  const [partners, setPartners] = useState<CorporatePartner[]>(INITIAL_PARTNERS);
  const [selectedPartnerId, setSelectedPartnerId] = useState<string>(INITIAL_PARTNERS[0].id);

  // Inner workspace tab state: "jobs" | "talent" | "history" | "analytics"
  const [innerTab, setInnerTab] = useState<"jobs" | "talent" | "history" | "analytics">("jobs");

  // Search filter
  const [directorySearch, setDirectorySearch] = useState("");

  // Modal states
  const [isAddPartnerOpen, setIsAddPartnerOpen] = useState(false);
  const [isInitiateProposalOpen, setIsInitiateProposalOpen] = useState(false);
  const [isMessageRecruiterOpen, setIsMessageRecruiterOpen] = useState(false);

  // Form states
  const [newPartnerForm, setNewPartnerForm] = useState({
    companyName: "",
    industry: "Software & AI",
    location: "Palo Alto, CA",
    contactName: "",
    contactTitle: "Senior Talent Acquisition Lead",
    contactEmail: "",
    contactPhone: ""
  });

  const [proposalForm, setProposalForm] = useState({
    proposedRole: "Associate Software Engineer",
    packageLPA: "20.0 LPA",
    targetBatch: "2024 Graduating Batch",
    tentativeDates: "Nov 15 - Nov 18",
    messageNote: "We would love to invite TechVanguard Systems for an exclusive early-bird campus drive."
  });

  const [messageText, setMessageText] = useState("");

  // Toast Notification state
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => {
      setToastMessage(null);
    }, 4000);
  };

  // Currently Selected Partner Object
  const selectedPartner = useMemo(() => {
    return partners.find((p) => p.id === selectedPartnerId) || partners[0];
  }, [partners, selectedPartnerId]);

  // Filtered Partner Directory List
  const filteredPartners = useMemo(() => {
    return partners.filter((p) => {
      const q = directorySearch.toLowerCase().trim();
      return (
        !q ||
        p.companyName.toLowerCase().includes(q) ||
        p.industry.toLowerCase().includes(q) ||
        p.contactName.toLowerCase().includes(q)
      );
    });
  }, [partners, directorySearch]);

  // Handle Export CSV
  const handleExportCSV = () => {
    const headers = [
      "Company Name",
      "Industry",
      "Location",
      "Status",
      "Hiring Velocity",
      "Conversion Rate",
      "Student Rating",
      "Contact Person",
      "Contact Email"
    ];

    const csvRows = partners.map((p) => [
      `"${p.companyName}"`,
      `"${p.industry}"`,
      `"${p.location}"`,
      `"${p.statusBadge}"`,
      `"${p.hiringVelocity}"`,
      `"${p.conversionRate}"`,
      p.studentRating,
      `"${p.contactName}"`,
      `"${p.contactEmail}"`
    ]);

    const csvContent = [headers.join(","), ...csvRows.map((e) => e.join(","))].join("\n");
    const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.setAttribute("href", url);
    link.setAttribute("download", `Corporate_Partnerships_Report_${new Date().toISOString().slice(0, 10)}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

    showToast(`Successfully exported engagement metrics for ${partners.length} corporate partners to CSV.`);
  };

  // Add Partner Form Submit
  const handleAddPartnerSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newPartnerForm.companyName.trim() || !newPartnerForm.contactName.trim()) return;

    const firstLetter = newPartnerForm.companyName.charAt(0).toUpperCase() || "C";
    const newPartner: CorporatePartner = {
      id: `part-${Date.now()}`,
      companyName: newPartnerForm.companyName,
      logoLetter: firstLetter,
      logoBg: "bg-[#7C3AED] text-white border-purple-300",
      statusBadge: "🟢 Highly Engaged",
      lastActivity: "JUST NOW",
      location: newPartnerForm.location || "Palo Alto, CA",
      industry: newPartnerForm.industry || "Software & AI",
      hiringVelocity: "High",
      hiringVelocityTrend: "+15%",
      conversionRate: "24.0%",
      conversionBenchmark: "Avg 18%",
      studentRating: 4.9,
      contactName: newPartnerForm.contactName,
      contactTitle: newPartnerForm.contactTitle || "Talent Acquisition Manager",
      contactAvatar: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200",
      contactEmail: newPartnerForm.contactEmail || `contact@${newPartnerForm.companyName.toLowerCase().replace(/\s+/g, "")}.com`,
      contactPhone: newPartnerForm.contactPhone || "+1 (650) 555-0100",
      nextBestActionText: `${newPartnerForm.companyName} onboarded to placement portal.`,
      openings: [
        {
          id: `op-${Date.now()}`,
          title: "Graduate Software Engineer",
          badge: "HIRING",
          positions: 10,
          packageText: "20 - 25 LPA",
          deadlineText: "Deadline: Nov 20"
        }
      ],
      intelligenceFeed: [
        {
          id: `ev-${Date.now()}`,
          title: "Partner Onboarded",
          timeAgo: "Just now",
          description: "New corporate partnership established and verified by TPO Officer.",
          iconType: "meeting"
        }
      ],
      sharedTalentCount: 25,
      driveHistoryCount: 1
    };

    setPartners([newPartner, ...partners]);
    setSelectedPartnerId(newPartner.id);
    setIsAddPartnerOpen(false);
    showToast(`New corporate partner ${newPartner.companyName} onboarded successfully!`);

    // Reset Form
    setNewPartnerForm({
      companyName: "",
      industry: "Software & AI",
      location: "Palo Alto, CA",
      contactName: "",
      contactTitle: "Senior Talent Acquisition Lead",
      contactEmail: "",
      contactPhone: ""
    });
  };

  // Drive Proposal Submit
  const handleProposalSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setIsInitiateProposalOpen(false);
    showToast(`Drive proposal dispatched to ${selectedPartner.contactName} at ${selectedPartner.companyName}!`);
  };

  // Message Recruiter Submit
  const handleMessageSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setIsMessageRecruiterOpen(false);
    showToast(`Message sent to ${selectedPartner.contactName} (${selectedPartner.contactEmail}).`);
    setMessageText("");
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

      {/* 1. Top Header & Action Controls */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl md:text-3xl font-extrabold text-slate-900 tracking-tight">
            Recruiter Coordination
          </h1>
          <p className="text-xs md:text-sm text-slate-500 font-medium mt-1">
            Strategic partnership intelligence for 42 active corporate partners.
          </p>
        </div>

        <div className="flex items-center gap-3">
          {/* Export CSV CTA */}
          <button
            onClick={handleExportCSV}
            className="bg-white hover:bg-slate-50 text-slate-700 font-bold px-4 py-2.5 rounded-xl border border-slate-200 shadow-xs text-xs md:text-sm flex items-center gap-2 transition-all cursor-pointer hover:border-slate-300"
          >
            <Download className="w-4 h-4 text-slate-600" />
            <span>Export</span>
          </button>

          {/* Add Partner CTA */}
          <button
            onClick={() => setIsAddPartnerOpen(true)}
            className="bg-[#7C3AED] hover:bg-[#6B21A8] active:bg-purple-900 text-white font-bold px-4 py-2.5 rounded-xl shadow-md shadow-purple-500/20 text-xs md:text-sm flex items-center gap-2 transition-all cursor-pointer transform hover:-translate-y-0.5"
          >
            <UserPlus className="w-4 h-4 stroke-[2.5]" />
            <span>Add Partner</span>
          </button>
        </div>
      </div>

      {/* 3-COLUMN SPLIT WORKSPACE GRID */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-5 items-start">
        {/* COLUMN 1: DIRECTORY & FILTER COLUMN (LEFT PANE - 3 COLS) */}
        <div className="lg:col-span-3 bg-white rounded-2xl border border-slate-100 shadow-xs overflow-hidden flex flex-col">
          {/* Header */}
          <div className="p-4 border-b border-slate-100 flex items-center justify-between bg-slate-50/50">
            <span className="text-xs font-black text-slate-900 tracking-wider uppercase">
              DIRECTORY
            </span>
            <button
              onClick={() => showToast("Directory filter drawer opened.")}
              title="Filter Directory"
              className="text-slate-400 hover:text-slate-700 p-1"
            >
              <SlidersHorizontal className="w-4 h-4" />
            </button>
          </div>

          {/* Directory Search */}
          <div className="p-3 border-b border-slate-100">
            <div className="relative">
              <Search className="w-3.5 h-3.5 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
              <input
                type="text"
                value={directorySearch}
                onChange={(e) => setDirectorySearch(e.target.value)}
                placeholder="Filter partners..."
                className="w-full bg-slate-50 text-xs pl-8 pr-3 py-1.5 rounded-lg border border-slate-200 outline-none focus:ring-1 focus:ring-purple-500/30"
              />
            </div>
          </div>

          {/* Directory Partner Cards List */}
          <div className="divide-y divide-slate-100 overflow-y-auto max-h-[700px]">
            {filteredPartners.length > 0 ? (
              filteredPartners.map((partner) => {
                const isSelected = partner.id === selectedPartnerId;

                return (
                  <div
                    key={partner.id}
                    onClick={() => setSelectedPartnerId(partner.id)}
                    className={`p-4 cursor-pointer transition-all flex items-center gap-3.5 ${
                      isSelected
                        ? "bg-[#F3E8FF]/60 border-l-4 border-[#7C3AED] shadow-2xs"
                        : "hover:bg-slate-50"
                    }`}
                  >
                    {/* Logo Avatar Box */}
                    <div
                      className={`w-10 h-10 rounded-xl font-black text-sm flex items-center justify-center border shrink-0 shadow-2xs ${partner.logoBg}`}
                    >
                      {partner.logoLetter}
                    </div>

                    <div className="flex-1 min-w-0">
                      <h4 className="text-xs font-extrabold text-slate-900 truncate">
                        {partner.companyName}
                      </h4>

                      <div className="flex items-center gap-1.5 mt-0.5">
                        <span className="text-[10px] font-bold">{partner.statusBadge}</span>
                      </div>

                      <span className="block text-[9px] font-extrabold text-slate-400 tracking-wider uppercase mt-1">
                        LAST ACTIVITY: {partner.lastActivity}
                      </span>
                    </div>
                  </div>
                );
              })
            ) : (
              <div className="p-6 text-center text-xs text-slate-400 font-medium">
                No matching corporate partners found.
              </div>
            )}
          </div>
        </div>

        {/* COLUMN 2: SELECTED PARTNER WORKSPACE (CENTER PANE - 6 COLS) */}
        <div className="lg:col-span-6 space-y-5">
          {/* Partner Header Box */}
          <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-xs space-y-4">
            <div className="flex items-start justify-between gap-4">
              <div className="flex items-center gap-4">
                <div className="w-14 h-14 rounded-2xl bg-white border border-slate-200 shadow-xs flex items-center justify-center text-2xl font-black text-slate-800 shrink-0">
                  {selectedPartner.logoLetter}
                </div>
                <div>
                  <h2 className="text-xl font-extrabold text-slate-900 leading-tight">
                    {selectedPartner.companyName}
                  </h2>
                  <div className="flex items-center gap-3 text-xs font-semibold text-slate-500 mt-1">
                    <span className="flex items-center gap-1">
                      <MapPin className="w-3.5 h-3.5 text-slate-400" /> {selectedPartner.location}
                    </span>
                    <span>•</span>
                    <span className="flex items-center gap-1">
                      <Building2 className="w-3.5 h-3.5 text-slate-400" /> {selectedPartner.industry}
                    </span>
                  </div>
                </div>
              </div>

              {/* Quick Actions (Edit & Share) */}
              <div className="flex items-center gap-2">
                <button
                  onClick={() => showToast("Edit partner details modal opened.")}
                  title="Edit Partner Profile"
                  className="border border-slate-200 hover:bg-slate-50 text-slate-600 p-2 rounded-xl transition-colors cursor-pointer"
                >
                  <Pencil className="w-4 h-4" />
                </button>
                <button
                  onClick={() => showToast(`Share link generated for ${selectedPartner.companyName}.`)}
                  title="Share / Copy Link"
                  className="border border-slate-200 hover:bg-slate-50 text-slate-600 p-2 rounded-xl transition-colors cursor-pointer"
                >
                  <Share2 className="w-4 h-4" />
                </button>
              </div>
            </div>

            {/* KPI Metrics Summary Row */}
            <div className="grid grid-cols-3 gap-3 pt-2 border-t border-slate-100">
              {/* Hiring Velocity */}
              <div className="bg-slate-50/80 p-3 rounded-xl border border-slate-100">
                <span className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block">
                  HIRING VELOCITY
                </span>
                <div className="flex items-baseline gap-2 mt-1">
                  <span className="text-base font-black text-purple-700">
                    {selectedPartner.hiringVelocity}
                  </span>
                  <span className="text-[11px] font-extrabold text-emerald-600 flex items-center">
                    <TrendingUp className="w-3 h-3 mr-0.5" />
                    {selectedPartner.hiringVelocityTrend}
                  </span>
                </div>
              </div>

              {/* Conversion Rate */}
              <div className="bg-slate-50/80 p-3 rounded-xl border border-slate-100">
                <span className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block">
                  CONVERSION RATE
                </span>
                <div className="flex items-baseline gap-1.5 mt-1">
                  <span className="text-base font-black text-slate-900">
                    {selectedPartner.conversionRate}
                  </span>
                  <span className="text-[10px] font-bold text-slate-400">
                    {selectedPartner.conversionBenchmark}
                  </span>
                </div>
              </div>

              {/* Student Rating */}
              <div className="bg-slate-50/80 p-3 rounded-xl border border-slate-100">
                <span className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block">
                  STUDENT RATING
                </span>
                <div className="flex items-center gap-1.5 mt-1">
                  <span className="text-base font-black text-slate-900">
                    {selectedPartner.studentRating.toFixed(1)} / 5
                  </span>
                  <Star className="w-3.5 h-3.5 text-amber-400 fill-amber-400" />
                </div>
              </div>
            </div>
          </div>

          {/* Inner Portal Navigation Tabs */}
          <div className="bg-white rounded-2xl border border-slate-100 shadow-xs p-5 space-y-5">
            <div className="flex items-center gap-6 border-b border-slate-100">
              <button
                onClick={() => setInnerTab("jobs")}
                className={`pb-2.5 text-xs font-extrabold transition-all cursor-pointer relative ${
                  innerTab === "jobs" ? "text-[#7C3AED]" : "text-slate-500 hover:text-slate-800"
                }`}
              >
                <span>Active Jobs ({selectedPartner.openings.length})</span>
                {innerTab === "jobs" && (
                  <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-[#7C3AED] rounded-full" />
                )}
              </button>

              <button
                onClick={() => setInnerTab("talent")}
                className={`pb-2.5 text-xs font-extrabold transition-all cursor-pointer relative ${
                  innerTab === "talent" ? "text-[#7C3AED]" : "text-slate-500 hover:text-slate-800"
                }`}
              >
                <span>Shared Talent ({selectedPartner.sharedTalentCount})</span>
                {innerTab === "talent" && (
                  <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-[#7C3AED] rounded-full" />
                )}
              </button>

              <button
                onClick={() => setInnerTab("history")}
                className={`pb-2.5 text-xs font-extrabold transition-all cursor-pointer relative ${
                  innerTab === "history" ? "text-[#7C3AED]" : "text-slate-500 hover:text-slate-800"
                }`}
              >
                <span>Drive History ({selectedPartner.driveHistoryCount})</span>
                {innerTab === "history" && (
                  <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-[#7C3AED] rounded-full" />
                )}
              </button>

              <button
                onClick={() => setInnerTab("analytics")}
                className={`pb-2.5 text-xs font-extrabold transition-all cursor-pointer relative ${
                  innerTab === "analytics" ? "text-[#7C3AED]" : "text-slate-500 hover:text-slate-800"
                }`}
              >
                <span>Engagement Analytics</span>
                {innerTab === "analytics" && (
                  <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-[#7C3AED] rounded-full" />
                )}
              </button>
            </div>

            {/* Inner Content Display */}
            {innerTab === "jobs" ? (
              <div className="space-y-5">
                {/* Primary Contact Module */}
                <div className="space-y-2">
                  <div className="flex items-center justify-between">
                    <h3 className="text-xs font-extrabold text-slate-900 uppercase tracking-wider">
                      Primary Contact
                    </h3>
                    <button
                      onClick={() => showToast("Change primary contact dialog.")}
                      className="text-xs font-extrabold text-purple-700 hover:underline"
                    >
                      Change Contact
                    </button>
                  </div>

                  <div className="bg-slate-50 p-4 rounded-2xl border border-slate-100 flex items-center justify-between gap-4">
                    <div className="flex items-center gap-3">
                      <img
                        src={selectedPartner.contactAvatar}
                        alt={selectedPartner.contactName}
                        className="w-11 h-11 rounded-2xl object-cover border border-slate-200 shadow-2xs"
                      />
                      <div>
                        <h4 className="text-sm font-extrabold text-slate-900">
                          {selectedPartner.contactName}
                        </h4>
                        <p className="text-xs font-semibold text-purple-700">
                          {selectedPartner.contactTitle}
                        </p>
                      </div>
                    </div>

                    <div className="flex items-center gap-2">
                      <button
                        onClick={() => setIsMessageRecruiterOpen(true)}
                        className="bg-white hover:bg-slate-100 border border-slate-200 text-slate-800 text-xs font-bold px-3 py-2 rounded-xl flex items-center gap-1.5 transition-colors cursor-pointer shadow-2xs"
                      >
                        <Mail className="w-3.5 h-3.5 text-slate-600" />
                        <span>Message</span>
                      </button>
                      <button
                        onClick={() => showToast(`Dialing ${selectedPartner.contactPhone}...`)}
                        title="Call Contact"
                        className="bg-white hover:bg-slate-100 border border-slate-200 text-slate-600 p-2 rounded-xl transition-colors cursor-pointer shadow-2xs"
                      >
                        <Phone className="w-4 h-4" />
                      </button>
                    </div>
                  </div>
                </div>

                {/* Current Openings Section */}
                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <h3 className="text-xs font-extrabold text-slate-900 uppercase tracking-wider">
                      CURRENT OPENINGS
                    </h3>
                    <span className="bg-purple-100 text-purple-700 text-[10px] font-black uppercase px-2.5 py-1 rounded-full">
                      New Drive Proposed
                    </span>
                  </div>

                  <div className="space-y-3">
                    {selectedPartner.openings.map((op) => (
                      <div
                        key={op.id}
                        className="p-4 bg-white rounded-2xl border border-slate-200/80 shadow-2xs space-y-2 hover:border-purple-200 transition-all"
                      >
                        <div className="flex items-center justify-between">
                          <h4 className="text-sm font-extrabold text-slate-900">{op.title}</h4>
                          <span
                            className={`text-[10px] font-black uppercase px-2.5 py-0.5 rounded-md ${
                              op.badge === "HIRING"
                                ? "bg-emerald-100 text-emerald-700"
                                : op.badge === "SHORTLISTING"
                                ? "bg-purple-100 text-purple-700"
                                : "bg-slate-100 text-slate-600"
                            }`}
                          >
                            {op.badge}
                          </span>
                        </div>

                        <div className="flex flex-wrap items-center gap-4 text-xs font-semibold text-slate-500">
                          <span>👥 {op.positions} Positions</span>
                          <span>•</span>
                          <span>💼 {op.packageText}</span>
                          <span>•</span>
                          <span>📅 {op.deadlineText}</span>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            ) : (
              <div className="p-8 text-center text-xs text-slate-400 font-medium bg-slate-50 rounded-xl">
                Displaying {innerTab} data for {selectedPartner.companyName}.
              </div>
            )}
          </div>
        </div>

        {/* COLUMN 3: AI ACTION & INTELLIGENCE FEED (RIGHT PANE - 3 COLS) */}
        <div className="lg:col-span-3 space-y-5">
          {/* Top AI Next Best Action Card (Solid Purple Box) */}
          <div className="bg-[#7C3AED] text-white p-5 rounded-2xl shadow-md space-y-3 relative overflow-hidden">
            <div className="flex items-center gap-1.5 text-xs font-black tracking-wider uppercase text-purple-200">
              <Zap className="w-4 h-4 text-amber-300 fill-amber-300" />
              NEXT BEST ACTION
            </div>

            <p className="text-xs font-extrabold leading-relaxed text-white">
              &quot;{selectedPartner.nextBestActionText}&quot;
            </p>

            <button
              onClick={() => setIsInitiateProposalOpen(true)}
              className="bg-white hover:bg-slate-100 text-[#7C3AED] font-extrabold text-xs w-full py-2.5 rounded-xl transition-all shadow-xs cursor-pointer transform active:scale-95"
            >
              Initiate Drive Proposal
            </button>
          </div>

          {/* Intelligence Activity Feed */}
          <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-xs space-y-4">
            <div className="flex items-center justify-between">
              <span className="text-xs font-black text-slate-900 tracking-wider uppercase flex items-center gap-1.5">
                INTELLIGENCE FEED <span className="w-2 h-2 rounded-full bg-emerald-500" />
              </span>
            </div>

            <div className="space-y-4 text-xs">
              {selectedPartner.intelligenceFeed.map((ev) => (
                <div key={ev.id} className="flex items-start gap-3 relative group">
                  <div className="w-8 h-8 rounded-xl bg-purple-50 text-purple-600 flex items-center justify-center shrink-0 border border-purple-100">
                    <FileText className="w-4 h-4" />
                  </div>
                  <div>
                    <div className="flex items-center justify-between gap-2">
                      <h5 className="font-extrabold text-slate-900">{ev.title}</h5>
                      <span className="text-[10px] text-slate-400 font-medium">{ev.timeAgo}</span>
                    </div>
                    <p className="text-slate-500 text-[11px] font-medium leading-normal mt-0.5">
                      &quot;{ev.description}&quot;
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* MODAL 1: + Add Partner Modal */}
      {isAddPartnerOpen && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl space-y-5 animate-in zoom-in-95 duration-200">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-xl bg-purple-100 text-purple-700 flex items-center justify-center font-bold">
                  +
                </div>
                <h3 className="text-lg font-extrabold text-slate-900">Onboard Corporate Partner</h3>
              </div>
              <button
                onClick={() => setIsAddPartnerOpen(false)}
                className="text-slate-400 hover:text-slate-600 p-1"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleAddPartnerSubmit} className="space-y-4 text-xs font-medium">
              <div>
                <label className="font-bold text-slate-700 block mb-1">Company Name</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. TechVanguard Systems"
                  value={newPartnerForm.companyName}
                  onChange={(e) => setNewPartnerForm({ ...newPartnerForm, companyName: e.target.value })}
                  className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Industry / Sector</label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. Software & AI"
                    value={newPartnerForm.industry}
                    onChange={(e) => setNewPartnerForm({ ...newPartnerForm, industry: e.target.value })}
                    className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                  />
                </div>

                <div>
                  <label className="font-bold text-slate-700 block mb-1">Location</label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. Palo Alto, CA"
                    value={newPartnerForm.location}
                    onChange={(e) => setNewPartnerForm({ ...newPartnerForm, location: e.target.value })}
                    className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Primary Contact Name</label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. Sarah Jenkins"
                    value={newPartnerForm.contactName}
                    onChange={(e) => setNewPartnerForm({ ...newPartnerForm, contactName: e.target.value })}
                    className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                  />
                </div>

                <div>
                  <label className="font-bold text-slate-700 block mb-1">Contact Designation</label>
                  <input
                    type="text"
                    placeholder="Senior Talent Acquisition Lead"
                    value={newPartnerForm.contactTitle}
                    onChange={(e) => setNewPartnerForm({ ...newPartnerForm, contactTitle: e.target.value })}
                    className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Contact Email</label>
                  <input
                    type="email"
                    required
                    placeholder="sarah@company.com"
                    value={newPartnerForm.contactEmail}
                    onChange={(e) => setNewPartnerForm({ ...newPartnerForm, contactEmail: e.target.value })}
                    className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                  />
                </div>

                <div>
                  <label className="font-bold text-slate-700 block mb-1">Contact Phone</label>
                  <input
                    type="text"
                    placeholder="+1 (650) 555-0192"
                    value={newPartnerForm.contactPhone}
                    onChange={(e) => setNewPartnerForm({ ...newPartnerForm, contactPhone: e.target.value })}
                    className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                  />
                </div>
              </div>

              <div className="flex items-center justify-end gap-3 pt-4 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setIsAddPartnerOpen(false)}
                  className="px-4 py-2.5 text-slate-600 font-bold hover:bg-slate-100 rounded-xl"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="bg-[#7C3AED] hover:bg-[#6B21A8] text-white font-bold px-5 py-2.5 rounded-xl shadow-md shadow-purple-500/20"
                >
                  Save Partner
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* MODAL 2: Initiate Drive Proposal Modal */}
      {isInitiateProposalOpen && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <Zap className="w-5 h-5 text-purple-600" />
                <h3 className="text-base font-extrabold text-slate-900">
                  Initiate Drive Proposal ({selectedPartner.companyName})
                </h3>
              </div>
              <button
                onClick={() => setIsInitiateProposalOpen(false)}
                className="text-slate-400 hover:text-slate-600 p-1"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleProposalSubmit} className="space-y-4 text-xs font-medium">
              <div>
                <label className="font-bold text-slate-700 block mb-1">Proposed Target Role</label>
                <input
                  type="text"
                  required
                  value={proposalForm.proposedRole}
                  onChange={(e) => setProposalForm({ ...proposalForm, proposedRole: e.target.value })}
                  className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Proposed Package</label>
                  <input
                    type="text"
                    required
                    value={proposalForm.packageLPA}
                    onChange={(e) => setProposalForm({ ...proposalForm, packageLPA: e.target.value })}
                    className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                  />
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Tentative Dates</label>
                  <input
                    type="text"
                    required
                    value={proposalForm.tentativeDates}
                    onChange={(e) => setProposalForm({ ...proposalForm, tentativeDates: e.target.value })}
                    className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                  />
                </div>
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Proposal Invitation Note</label>
                <textarea
                  rows={3}
                  value={proposalForm.messageNote}
                  onChange={(e) => setProposalForm({ ...proposalForm, messageNote: e.target.value })}
                  className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                />
              </div>

              <div className="flex items-center justify-end gap-3 pt-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setIsInitiateProposalOpen(false)}
                  className="px-4 py-2 rounded-xl text-slate-600 font-bold hover:bg-slate-100"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="bg-[#7C3AED] hover:bg-[#6B21A8] text-white font-bold px-4 py-2 rounded-xl shadow-md"
                >
                  Send Proposal Invite
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* MODAL 3: Message Recruiter Modal */}
      {isMessageRecruiterOpen && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <Mail className="w-5 h-5 text-purple-600" />
                <h3 className="text-base font-extrabold text-slate-900">
                  Message: {selectedPartner.contactName}
                </h3>
              </div>
              <button
                onClick={() => setIsMessageRecruiterOpen(false)}
                className="text-slate-400 hover:text-slate-600 p-1"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleMessageSubmit} className="space-y-4 text-xs font-medium">
              <div>
                <label className="font-bold text-slate-700 block mb-1">Recruiter Email</label>
                <input
                  type="text"
                  disabled
                  value={selectedPartner.contactEmail}
                  className="w-full p-3 bg-slate-100 border border-slate-200 rounded-xl text-slate-500 cursor-not-allowed"
                />
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Message Content</label>
                <textarea
                  rows={4}
                  required
                  placeholder={`Hi ${selectedPartner.contactName},\nFollowing up on our upcoming recruitment schedule...`}
                  value={messageText}
                  onChange={(e) => setMessageText(e.target.value)}
                  className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                />
              </div>

              <div className="flex items-center justify-end gap-3 pt-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setIsMessageRecruiterOpen(false)}
                  className="px-4 py-2 rounded-xl text-slate-600 font-bold hover:bg-slate-100"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="bg-[#7C3AED] hover:bg-[#6B21A8] text-white font-bold px-4 py-2 rounded-xl shadow-md flex items-center gap-1.5"
                >
                  <Send className="w-3.5 h-3.5" />
                  <span>Send Message</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default RecruiterCoordinationView;
export const CompaniesView = RecruiterCoordinationView;
