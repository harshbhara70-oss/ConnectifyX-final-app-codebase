import React, { useState } from "react";
import {
  UserPlus,
  Calendar,
  Send,
  FileText,
  AlertTriangle,
  ArrowRight,
  Briefcase,
  Users,
  CheckCircle2,
  Sparkles,
  MessageSquare,
  X,
  ChevronRight,
  ShieldAlert,
  Clock
} from "lucide-react";
import type { ViewType } from "../CollegeSidebar";

interface ExecutiveOverviewProps {
  onNavigateView?: (view: ViewType) => void;
  onOpenNewDriveModal?: () => void;
  onExportReport?: () => void;
  searchQuery?: string;
}

interface ActivityItem {
  id: string;
  name: string;
  detail: string;
  action: string;
  badgeText: string;
  badgeStyle: string;
  avatarBg: string;
}

interface ScheduleItem {
  id: string;
  month: string;
  day: string;
  title: string;
  subtitle: string;
  tag: string;
}

export const ExecutiveOverview: React.FC<ExecutiveOverviewProps> = ({
  onNavigateView,
  onOpenNewDriveModal,
  onExportReport,
  searchQuery = ""
}) => {
  // Toast notification state
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  // Modal controls
  const [isInviteModalOpen, setIsInviteModalOpen] = useState(false);
  const [isScheduleModalOpen, setIsScheduleModalOpen] = useState(false);
  const [isBroadcastModalOpen, setIsBroadcastModalOpen] = useState(false);
  const [isReportsModalOpen, setIsReportsModalOpen] = useState(false);
  const [isPendingReviewOpen, setIsPendingReviewOpen] = useState(false);
  const [isAssistantOpen, setIsAssistantOpen] = useState(false);

  // Form states for modals
  const [inviteEmails, setInviteEmails] = useState("");
  const [broadcastSubject, setBroadcastSubject] = useState("");
  const [broadcastMessage, setBroadcastMessage] = useState("");
  const [assistantInput, setAssistantInput] = useState("");
  const [chatMessages, setChatMessages] = useState<Array<{ sender: "user" | "ai"; text: string }>>([
    {
      sender: "ai",
      text: "Hello Dr. Sarah Jenkins! I am your AI Placement Assistant. How can I help you optimize placement cycles today?"
    }
  ]);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 3500);
  };

  // Mock student activities dataset
  const ACTIVITIES: ActivityItem[] = [
    {
      id: "act-1",
      name: "Rahul Verma",
      detail: "(CS 2025)",
      action: "applied for Microsoft SDE Intern",
      badgeText: "APPLIED",
      badgeStyle: "bg-slate-100 text-slate-700 border-slate-200",
      avatarBg: "bg-blue-600 text-white"
    },
    {
      id: "act-2",
      name: "Priya Singh",
      detail: "(EC 2025)",
      action: "completed Python Assessment",
      badgeText: "88/100",
      badgeStyle: "bg-purple-100 text-[#7C3AED] border-purple-200 font-extrabold",
      avatarBg: "bg-purple-600 text-white"
    },
    {
      id: "act-3",
      name: "Arun Kumar",
      detail: "(ME 2025)",
      action: "updated his Resume Profile",
      badgeText: "UPDATED",
      badgeStyle: "bg-slate-100 text-slate-600 border-slate-200",
      avatarBg: "bg-amber-600 text-white"
    },
    {
      id: "act-4",
      name: "Ananya Deshpande",
      detail: "(IT 2025)",
      action: "was shortlisted for Deloitte USI",
      badgeText: "SHORTLISTED",
      badgeStyle: "bg-[#F3E8FF] text-[#7C3AED] border-purple-200 font-extrabold",
      avatarBg: "bg-emerald-600 text-white"
    }
  ];

  // Mock upcoming schedule dataset
  const SCHEDULE_EVENTS: ScheduleItem[] = [
    {
      id: "sch-1",
      month: "OCT",
      day: "12",
      title: "NVIDIA Orientation",
      subtitle: "Pre-Placement Talk & Technical Overview",
      tag: "Orientation"
    },
    {
      id: "sch-2",
      month: "OCT",
      day: "14",
      title: "Amazon Online Assessment",
      subtitle: "Coding & Aptitude Test (Main Lab)",
      tag: "Assessment"
    },
    {
      id: "sch-3",
      month: "OCT",
      day: "18",
      title: "Deloitte Final Interviews",
      subtitle: "HR & Tech Rounds (Auditorium)",
      tag: "Interviews"
    },
    {
      id: "sch-4",
      month: "OCT",
      day: "21",
      title: "HDFC Group Discussion",
      subtitle: "Managerial Trainee Batch Selection",
      tag: "Group Discussion"
    }
  ];

  // Handlers for action modals
  const handleInviteSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setIsInviteModalOpen(false);
    showToast(`Invites successfully sent to: ${inviteEmails || "Selected Batch"}`);
    setInviteEmails("");
  };

  const handleBroadcastSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setIsBroadcastModalOpen(false);
    showToast(`Broadcast "${broadcastSubject}" sent to 1,420 eligible students.`);
    setBroadcastSubject("");
    setBroadcastMessage("");
  };

  const handleApprovePending = () => {
    setIsPendingReviewOpen(false);
    showToast("Google Placement eligibility criteria approved! 120 students verified.");
  };

  const handleSendMessage = (e: React.FormEvent) => {
    e.preventDefault();
    if (!assistantInput.trim()) return;

    const userText = assistantInput;
    setChatMessages((prev) => [...prev, { sender: "user", text: userText }]);
    setAssistantInput("");

    setTimeout(() => {
      setChatMessages((prev) => [
        ...prev,
        {
          sender: "ai",
          text: `Regarding "${userText}": I analyzed current batch analytics. 84% of CS candidates are ready for interviews, and 4 upcoming drives are scheduled this week.`
        }
      ]);
    }, 600);
  };

  // Filter activities based on global search query if present
  const filteredActivities = ACTIVITIES.filter(
    (item) =>
      !searchQuery ||
      item.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.action.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.detail.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="space-y-6 pb-12">
      {/* Toast Banner */}
      {toastMessage && (
        <div className="fixed bottom-6 left-6 z-50 bg-slate-900 text-white text-xs font-bold px-4 py-3 rounded-2xl shadow-2xl flex items-center gap-2 border border-slate-800 animate-bounce">
          <CheckCircle2 className="w-4 h-4 text-emerald-400" />
          <span>{toastMessage}</span>
        </div>
      )}

      {/* A. Top Welcome Hero Banner (Solid Purple Card) */}
      <div className="bg-gradient-to-r from-[#6B21A8] via-[#7C3AED] to-[#6B21A8] rounded-2xl p-6 md:p-8 text-white shadow-lg shadow-purple-900/10 flex flex-col md:flex-row md:items-center justify-between gap-6 relative overflow-hidden">
        <div className="relative z-10 max-w-2xl space-y-2">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-white/10 backdrop-blur-md border border-white/20 text-xs font-bold text-purple-100">
            <Sparkles className="w-3.5 h-3.5 text-amber-300" />
            <span>Campus Placement Season Active</span>
          </div>
          <h1 className="text-2xl md:text-3xl lg:text-4xl font-extrabold tracking-tight text-white leading-tight">
            {"Welcome back, MIT Academy of Engineering"}
          </h1>
          <p className="text-xs md:text-sm text-purple-100/90 font-medium">
            {"Academic Year 2024-25. You have 1,420 students eligible for upcoming placement cycles."}
          </p>
        </div>

        {/* Embedded Stat Badges (Right Alignment) */}
        <div className="relative z-10 flex flex-row md:flex-col lg:flex-row items-center gap-3 shrink-0">
          {/* Active Students Badge */}
          <div className="bg-white/15 backdrop-blur-md border border-white/20 rounded-2xl p-4 min-w-[140px] text-center shadow-inner">
            <span className="text-[10px] font-extrabold uppercase tracking-wider text-purple-200 block">
              {"Active Students"}
            </span>
            <div className="text-2xl md:text-3xl font-extrabold text-white mt-0.5 tracking-tight">
              {"3,842"}
            </div>
          </div>

          {/* Placement Rate Badge */}
          <div className="bg-white/15 backdrop-blur-md border border-white/20 rounded-2xl p-4 min-w-[140px] text-center shadow-inner">
            <span className="text-[10px] font-extrabold uppercase tracking-wider text-purple-200 block">
              {"Placement Rate"}
            </span>
            <div className="text-2xl md:text-3xl font-extrabold text-white mt-0.5 tracking-tight">
              {"82.4%"}
            </div>
          </div>
        </div>

        {/* Decorative background glow */}
        <div className="absolute -right-12 -top-12 w-64 h-64 rounded-full bg-purple-400/20 blur-3xl pointer-events-none" />
      </div>

      {/* B. Quick Action Grid & Alert Notification Card */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        {/* Left: 4 Circular Action Tiles (~60% width) */}
        <div className="lg:col-span-7 bg-white p-6 rounded-2xl border border-slate-100 shadow-sm flex flex-col justify-between">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-sm font-extrabold text-slate-900 uppercase tracking-wider">
              {"Quick Actions"}
            </h2>
            <span className="text-[11px] font-bold text-purple-700 bg-purple-50 px-2.5 py-0.5 rounded-full">
              {"Frequent Tasks"}
            </span>
          </div>

          <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
            {/* Tile 1: Invite Students */}
            <button
              onClick={() => setIsInviteModalOpen(true)}
              className="flex flex-col items-center justify-center p-4 rounded-2xl bg-purple-50/60 hover:bg-[#F3E8FF] border border-purple-100 text-slate-800 transition-all cursor-pointer group hover:-translate-y-1"
            >
              <div className="w-12 h-12 rounded-full bg-[#7C3AED] text-white flex items-center justify-center shadow-md shadow-purple-500/20 group-hover:scale-110 transition-transform mb-2">
                <UserPlus className="w-5 h-5" />
              </div>
              <span className="text-xs font-bold text-slate-800 group-hover:text-[#7C3AED] text-center">
                {"Invite Students"}
              </span>
            </button>

            {/* Tile 2: Schedule Drive */}
            <button
              onClick={() => {
                if (onOpenNewDriveModal) onOpenNewDriveModal();
                else setIsScheduleModalOpen(true);
              }}
              className="flex flex-col items-center justify-center p-4 rounded-2xl bg-purple-50/60 hover:bg-[#F3E8FF] border border-purple-100 text-slate-800 transition-all cursor-pointer group hover:-translate-y-1"
            >
              <div className="w-12 h-12 rounded-full bg-[#7C3AED] text-white flex items-center justify-center shadow-md shadow-purple-500/20 group-hover:scale-110 transition-transform mb-2">
                <Calendar className="w-5 h-5" />
              </div>
              <span className="text-xs font-bold text-slate-800 group-hover:text-[#7C3AED] text-center">
                {"Schedule Drive"}
              </span>
            </button>

            {/* Tile 3: Send Broadcast */}
            <button
              onClick={() => setIsBroadcastModalOpen(true)}
              className="flex flex-col items-center justify-center p-4 rounded-2xl bg-purple-50/60 hover:bg-[#F3E8FF] border border-purple-100 text-slate-800 transition-all cursor-pointer group hover:-translate-y-1"
            >
              <div className="w-12 h-12 rounded-full bg-[#7C3AED] text-white flex items-center justify-center shadow-md shadow-purple-500/20 group-hover:scale-110 transition-transform mb-2">
                <Send className="w-5 h-5" />
              </div>
              <span className="text-xs font-bold text-slate-800 group-hover:text-[#7C3AED] text-center">
                {"Send Broadcast"}
              </span>
            </button>

            {/* Tile 4: View Reports */}
            <button
              onClick={() => {
                if (onExportReport) onExportReport();
                else setIsReportsModalOpen(true);
              }}
              className="flex flex-col items-center justify-center p-4 rounded-2xl bg-purple-50/60 hover:bg-[#F3E8FF] border border-purple-100 text-slate-800 transition-all cursor-pointer group hover:-translate-y-1"
            >
              <div className="w-12 h-12 rounded-full bg-[#7C3AED] text-white flex items-center justify-center shadow-md shadow-purple-500/20 group-hover:scale-110 transition-transform mb-2">
                <FileText className="w-5 h-5" />
              </div>
              <span className="text-xs font-bold text-slate-800 group-hover:text-[#7C3AED] text-center">
                {"View Reports"}
              </span>
            </button>
          </div>
        </div>

        {/* Right: Pending Actions Warning Banner (~40% width) */}
        <div className="lg:col-span-5 bg-rose-50/90 border border-rose-200 p-6 rounded-2xl shadow-sm flex flex-col justify-between">
          <div>
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2 text-rose-700">
                <AlertTriangle className="w-5 h-5 fill-rose-100" />
                <h3 className="text-xs font-extrabold tracking-wider uppercase">
                  {"⚠️ PENDING ACTIONS"}
                </h3>
              </div>
              <span className="text-[10px] font-extrabold bg-rose-200/80 text-rose-800 px-2 py-0.5 rounded-full uppercase">
                {"Urgent"}
              </span>
            </div>

            <p className="text-xs text-rose-900 font-semibold leading-relaxed mt-1">
              {"Google Placement eligibility criteria needs approval. 120 students awaiting verification."}
            </p>
          </div>

          <div className="mt-4 pt-3 border-t border-rose-200/60 flex justify-end">
            <button
              onClick={() => setIsPendingReviewOpen(true)}
              className="inline-flex items-center gap-1.5 text-xs font-extrabold text-rose-700 hover:text-rose-900 transition-colors cursor-pointer group"
            >
              <span>{"Review Now"}</span>
              <ArrowRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
            </button>
          </div>
        </div>
      </div>

      {/* C. Key Metric Cards Row (4 symmetrical KPI tracking tiles) */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        {/* Tile 1: Total Students */}
        <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm hover:border-purple-200 transition-all group">
          <div className="flex items-center justify-between">
            <span className="text-[11px] font-extrabold uppercase tracking-wider text-slate-400 group-hover:text-[#7C3AED] transition-colors">
              {"Total Students"}
            </span>
            <div className="w-9 h-9 rounded-xl bg-purple-50 flex items-center justify-center text-[#7C3AED]">
              <Users className="w-4 h-4" />
            </div>
          </div>
          <div className="text-3xl font-extrabold text-slate-900 tracking-tight mt-2">
            {"4,128"}
          </div>
          <div className="mt-3 space-y-1.5">
            <div className="flex items-center justify-between text-xs font-bold">
              <span className="text-purple-700">+4%^</span>
              <span className="text-[10px] text-slate-400 font-medium">Growth vs last session</span>
            </div>
            <div className="w-full h-1.5 bg-purple-100 rounded-full overflow-hidden">
              <div className="bg-[#7C3AED] h-full w-[78%]" />
            </div>
          </div>
        </div>

        {/* Tile 2: Active Drives */}
        <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm hover:border-purple-200 transition-all group">
          <div className="flex items-center justify-between">
            <span className="text-[11px] font-extrabold uppercase tracking-wider text-slate-400 group-hover:text-[#7C3AED] transition-colors">
              {"Active Drives"}
            </span>
            <div className="w-9 h-9 rounded-xl bg-purple-50 flex items-center justify-center text-[#7C3AED]">
              <Briefcase className="w-4 h-4" />
            </div>
          </div>
          <div className="text-3xl font-extrabold text-slate-900 tracking-tight mt-2">
            {"12"}
          </div>
          <div className="mt-3 flex items-center justify-between">
            <span className="text-[10px] font-extrabold bg-purple-100 text-[#7C3AED] px-2.5 py-1 rounded-md">
              {"4 this week"}
            </span>
            <span className="text-[10px] text-slate-400 font-medium">Ongoing recruitment</span>
          </div>
        </div>

        {/* Tile 3: Upcoming Interviews */}
        <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm hover:border-purple-200 transition-all group">
          <div className="flex items-center justify-between">
            <span className="text-[11px] font-extrabold uppercase tracking-wider text-slate-400 group-hover:text-[#7C3AED] transition-colors">
              {"Upcoming Interviews"}
            </span>
            <div className="w-9 h-9 rounded-xl bg-purple-50 flex items-center justify-center text-[#7C3AED]">
              <Clock className="w-4 h-4" />
            </div>
          </div>
          <div className="text-3xl font-extrabold text-slate-900 tracking-tight mt-2">
            {"45"}
          </div>
          <div className="mt-3 flex items-center justify-between">
            <span className="text-[10px] font-extrabold bg-amber-50 text-amber-700 px-2 py-0.5 rounded-md border border-amber-100">
              {"Next 48h"}
            </span>
            {/* Overlapping student avatar circles */}
            <div className="flex -space-x-2 overflow-hidden">
              <div className="w-6 h-6 rounded-full bg-blue-600 border-2 border-white text-white text-[9px] font-bold flex items-center justify-center">
                RV
              </div>
              <div className="w-6 h-6 rounded-full bg-purple-600 border-2 border-white text-white text-[9px] font-bold flex items-center justify-center">
                PS
              </div>
              <div className="w-6 h-6 rounded-full bg-emerald-600 border-2 border-white text-white text-[9px] font-bold flex items-center justify-center">
                AK
              </div>
              <div className="w-6 h-6 rounded-full bg-amber-600 border-2 border-white text-white text-[9px] font-bold flex items-center justify-center">
                +42
              </div>
            </div>
          </div>
        </div>

        {/* Tile 4: Broadcasts Sent */}
        <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm hover:border-purple-200 transition-all group">
          <div className="flex items-center justify-between">
            <span className="text-[11px] font-extrabold uppercase tracking-wider text-slate-400 group-hover:text-[#7C3AED] transition-colors">
              {"Broadcasts Sent"}
            </span>
            <div className="w-9 h-9 rounded-xl bg-purple-50 flex items-center justify-center text-[#7C3AED]">
              <Send className="w-4 h-4" />
            </div>
          </div>
          <div className="text-3xl font-extrabold text-slate-900 tracking-tight mt-2">
            {"28"}
          </div>
          <div className="mt-3 space-y-1.5">
            <div className="flex items-center justify-between text-xs font-bold">
              <span className="text-emerald-600">100% Delivery Success</span>
            </div>
            <div className="w-full h-1.5 bg-emerald-100 rounded-full overflow-hidden">
              <div className="bg-emerald-500 h-full w-full" />
            </div>
          </div>
        </div>
      </div>

      {/* D. Bottom Row: Activity Feed & Upcoming Calendar */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        {/* Left Container — Recent Student Activity Feed (~60% width) */}
        <div className="lg:col-span-7 bg-white p-6 rounded-2xl border border-slate-100 shadow-sm flex flex-col justify-between">
          <div>
            <div className="flex items-center justify-between mb-5">
              <h2 className="text-base font-extrabold text-slate-900">
                {"Recent Student Activity"}
              </h2>
              <button
                onClick={() => onNavigateView && onNavigateView("students")}
                className="text-xs font-extrabold text-[#7C3AED] hover:text-[#6B21A8] transition-colors cursor-pointer"
              >
                {"View All ➔"}
              </button>
            </div>

            <div className="divide-y divide-slate-100">
              {filteredActivities.map((act) => (
                <div
                  key={act.id}
                  className="py-3.5 flex items-center justify-between gap-3 hover:bg-purple-50/30 px-2 rounded-xl transition-colors"
                >
                  <div className="flex items-center gap-3">
                    <div
                      className={`w-9 h-9 rounded-full ${act.avatarBg} font-extrabold text-xs flex items-center justify-center shrink-0 shadow-xs`}
                    >
                      {act.name
                        .split(" ")
                        .map((n) => n[0])
                        .join("")}
                    </div>
                    <div>
                      <div className="text-xs font-extrabold text-slate-900">
                        {act.name}{" "}
                        <span className="text-slate-400 font-normal">{act.detail}</span>
                      </div>
                      <div className="text-xs text-slate-600 font-medium">
                        {act.action}
                      </div>
                    </div>
                  </div>

                  <span
                    className={`text-[10px] font-extrabold px-2.5 py-1 rounded-md border shrink-0 ${act.badgeStyle}`}
                  >
                    {act.badgeText}
                  </span>
                </div>
              ))}
            </div>
          </div>

          <div className="pt-4 mt-2 border-t border-slate-100 flex items-center justify-between text-[11px] text-slate-400 font-medium">
            <span>{"Real-time candidate telemetry feed"}</span>
            <span className="text-purple-600 font-bold">{"Updated 2 mins ago"}</span>
          </div>
        </div>

        {/* Right Container — Upcoming Schedule & AI Recommendation (~40% width) */}
        <div className="lg:col-span-5 space-y-4">
          {/* Upcoming Schedule Card */}
          <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm space-y-4">
            <div className="flex items-center justify-between">
              <h2 className="text-base font-extrabold text-slate-900">
                {"Upcoming Schedule"}
              </h2>
              <span className="text-[10px] font-extrabold bg-purple-100 text-[#7C3AED] px-2 py-0.5 rounded-full">
                {"October 2024"}
              </span>
            </div>

            <div className="space-y-3">
              {SCHEDULE_EVENTS.map((event) => (
                <div
                  key={event.id}
                  className="flex items-center gap-3 p-2.5 rounded-xl hover:bg-slate-50 border border-transparent hover:border-slate-100 transition-all"
                >
                  <div className="w-12 h-12 rounded-xl bg-purple-50 border border-purple-100 text-center flex flex-col justify-center shrink-0">
                    <span className="text-[9px] font-black text-[#7C3AED] uppercase leading-none">
                      {event.month}
                    </span>
                    <span className="text-base font-black text-slate-900 leading-none mt-0.5">
                      {event.day}
                    </span>
                  </div>

                  <div className="flex-1 min-w-0">
                    <div className="text-xs font-extrabold text-slate-900 truncate">
                      {event.title}
                    </div>
                    <div className="text-[11px] text-slate-500 font-medium truncate">
                      {event.subtitle}
                    </div>
                  </div>

                  <ChevronRight className="w-4 h-4 text-slate-300 shrink-0" />
                </div>
              ))}
            </div>
          </div>

          {/* AI Recommendation Banner (Bottom Light Grey Card) */}
          <div className="bg-slate-100/90 border border-slate-200/80 p-4 rounded-2xl flex items-start gap-3 shadow-xs">
            <div className="w-8 h-8 rounded-xl bg-[#7C3AED] text-white flex items-center justify-center shrink-0 shadow-xs mt-0.5">
              <Sparkles className="w-4 h-4" />
            </div>
            <div>
              <span className="text-[10px] font-extrabold uppercase tracking-wider text-[#7C3AED] block">
                {"AI Insight Recommendation"}
              </span>
              <p className="text-xs text-slate-800 font-bold leading-snug mt-0.5">
                {"Resume quality has improved by 15% across all departments this month."}
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Floating Assistant Floating Action Button (FAB) */}
      <div className="fixed bottom-6 right-6 z-40">
        <button
          onClick={() => setIsAssistantOpen(!isAssistantOpen)}
          className="bg-[#7C3AED] hover:bg-[#6B21A8] text-white w-14 h-14 rounded-full shadow-2xl flex items-center justify-center cursor-pointer transition-all transform hover:scale-110 ring-4 ring-purple-200"
          title="AI Assistant Chat"
        >
          <MessageSquare className="w-6 h-6" />
        </button>
      </div>

      {/* MODAL 1: Invite Students */}
      {isInviteModalOpen && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl space-y-4 animate-scale-up">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <UserPlus className="w-5 h-5 text-[#7C3AED]" />
                <h3 className="text-lg font-extrabold text-slate-900">
                  {"Invite Students to Placement Portal"}
                </h3>
              </div>
              <button
                onClick={() => setIsInviteModalOpen(false)}
                className="text-slate-400 hover:text-slate-600 p-1"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleInviteSubmit} className="space-y-4 text-xs">
              <div>
                <label className="font-bold text-slate-700 block mb-1">
                  {"Student Email Addresses (comma separated)"}
                </label>
                <textarea
                  rows={3}
                  value={inviteEmails}
                  onChange={(e) => setInviteEmails(e.target.value)}
                  placeholder="rahul.v@mit.edu, priya.s@mit.edu, batch2025@mit.edu"
                  className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-purple-500/30"
                />
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">
                  {"Select Department / Batch"}
                </label>
                <select className="w-full p-2.5 bg-slate-50 border border-slate-200 rounded-xl outline-none">
                  <option>{"Computer Science (2025)"}</option>
                  <option>{"Electronics & Telecom (2025)"}</option>
                  <option>{"Mechanical Engineering (2025)"}</option>
                  <option>{"All Eligible Batches"}</option>
                </select>
              </div>

              <div className="pt-3 border-t border-slate-100 flex justify-end gap-3">
                <button
                  type="button"
                  onClick={() => setIsInviteModalOpen(false)}
                  className="px-4 py-2.5 text-slate-600 font-semibold"
                >
                  {"Cancel"}
                </button>
                <button
                  type="submit"
                  className="px-5 py-2.5 bg-[#7C3AED] hover:bg-[#6B21A8] text-white font-bold rounded-xl shadow-md"
                >
                  {"Send Invitations"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* MODAL 2: Send Broadcast */}
      {isBroadcastModalOpen && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <Send className="w-5 h-5 text-[#7C3AED]" />
                <h3 className="text-lg font-extrabold text-slate-900">
                  {"Broadcast Announcement"}
                </h3>
              </div>
              <button
                onClick={() => setIsBroadcastModalOpen(false)}
                className="text-slate-400 hover:text-slate-600 p-1"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleBroadcastSubmit} className="space-y-3 text-xs">
              <div>
                <label className="font-bold text-slate-700 block mb-1">
                  {"Subject Line"}
                </label>
                <input
                  type="text"
                  required
                  value={broadcastSubject}
                  onChange={(e) => setBroadcastSubject(e.target.value)}
                  placeholder="e.g. Mandatory Resume Verification Drive"
                  className="w-full p-2.5 bg-slate-50 border border-slate-200 rounded-xl outline-none"
                />
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">
                  {"Announcement Content"}
                </label>
                <textarea
                  rows={4}
                  required
                  value={broadcastMessage}
                  onChange={(e) => setBroadcastMessage(e.target.value)}
                  placeholder="Write your broadcast message to all eligible students..."
                  className="w-full p-2.5 bg-slate-50 border border-slate-200 rounded-xl outline-none"
                />
              </div>

              <div className="pt-3 border-t border-slate-100 flex justify-end gap-3">
                <button
                  type="button"
                  onClick={() => setIsBroadcastModalOpen(false)}
                  className="px-4 py-2.5 text-slate-600 font-semibold"
                >
                  {"Cancel"}
                </button>
                <button
                  type="submit"
                  className="px-5 py-2.5 bg-[#7C3AED] hover:bg-[#6B21A8] text-white font-bold rounded-xl shadow-md"
                >
                  {"Dispatch Broadcast"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* MODAL 3: Pending Review Drawer */}
      {isPendingReviewOpen && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <ShieldAlert className="w-5 h-5 text-rose-600" />
                <h3 className="text-lg font-extrabold text-slate-900">
                  {"Pending Criteria Approval"}
                </h3>
              </div>
              <button
                onClick={() => setIsPendingReviewOpen(false)}
                className="text-slate-400 hover:text-slate-600 p-1"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="bg-rose-50 p-4 rounded-xl border border-rose-200 space-y-2 text-xs">
              <div className="font-extrabold text-rose-900">
                {"Google Placement Eligibility Requirement"}
              </div>
              <p className="text-rose-800 leading-relaxed font-medium">
                {"Google APAC requires minimum 7.5 CGPA and zero active backlogs for 120 applicants. Please confirm college endorsement."}
              </p>
            </div>

            <div className="pt-3 border-t border-slate-100 flex justify-end gap-3 text-xs">
              <button
                type="button"
                onClick={() => setIsPendingReviewOpen(false)}
                className="px-4 py-2.5 text-slate-600 font-semibold"
              >
                {"Dismiss"}
              </button>
              <button
                type="button"
                onClick={handleApprovePending}
                className="px-5 py-2.5 bg-rose-600 hover:bg-rose-700 text-white font-bold rounded-xl shadow-md"
              >
                {"Approve & Verify 120 Students"}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* MODAL 4: Floating Assistant Drawer */}
      {isAssistantOpen && (
        <div className="fixed bottom-24 right-6 z-50 w-80 sm:w-96 bg-white rounded-2xl shadow-2xl border border-slate-200 flex flex-col h-[420px] overflow-hidden animate-scale-up">
          <div className="bg-gradient-to-r from-[#6B21A8] to-[#7C3AED] p-4 text-white flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Sparkles className="w-4 h-4 text-amber-300" />
              <h3 className="text-sm font-extrabold">{"AI Placement Assistant"}</h3>
            </div>
            <button
              onClick={() => setIsAssistantOpen(false)}
              className="text-purple-200 hover:text-white"
            >
              <X className="w-4 h-4" />
            </button>
          </div>

          <div className="flex-1 p-4 overflow-y-auto space-y-3 bg-slate-50 text-xs">
            {chatMessages.map((msg, idx) => (
              <div
                key={idx}
                className={`flex ${msg.sender === "user" ? "justify-end" : "justify-start"}`}
              >
                <div
                  className={`p-3 rounded-2xl max-w-[85%] font-medium ${
                    msg.sender === "user"
                      ? "bg-[#7C3AED] text-white rounded-br-none"
                      : "bg-white text-slate-800 border border-slate-200 rounded-bl-none shadow-xs"
                  }`}
                >
                  {msg.text}
                </div>
              </div>
            ))}
          </div>

          <form onSubmit={handleSendMessage} className="p-3 bg-white border-t border-slate-100 flex gap-2">
            <input
              type="text"
              value={assistantInput}
              onChange={(e) => setAssistantInput(e.target.value)}
              placeholder="Ask placement AI..."
              className="flex-1 text-xs p-2.5 bg-slate-50 border border-slate-200 rounded-xl outline-none focus:ring-2 focus:ring-purple-500/30"
            />
            <button
              type="submit"
              className="px-3.5 bg-[#7C3AED] hover:bg-[#6B21A8] text-white rounded-xl font-bold flex items-center justify-center"
            >
              <Send className="w-3.5 h-3.5" />
            </button>
          </form>
        </div>
      )}
      {/* MODAL 5: Schedule Drive Quick Modal */}
      {isScheduleModalOpen && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <Calendar className="w-5 h-5 text-[#7C3AED]" />
                <h3 className="text-lg font-extrabold text-slate-900">{"Schedule Placement Drive"}</h3>
              </div>
              <button onClick={() => setIsScheduleModalOpen(false)} className="text-slate-400 hover:text-slate-600 p-1">
                <X className="w-5 h-5" />
              </button>
            </div>
            <p className="text-xs text-slate-600 font-medium">{"Quickly initiate a recruitment drive for upcoming campus visits."}</p>
            <div className="space-y-3 text-xs">
              <input type="text" placeholder="Company Name (e.g. NVIDIA / Microsoft)" className="w-full p-2.5 bg-slate-50 border border-slate-200 rounded-xl outline-none" />
              <input type="text" placeholder="Job Title / Role" className="w-full p-2.5 bg-slate-50 border border-slate-200 rounded-xl outline-none" />
              <input type="date" className="w-full p-2.5 bg-slate-50 border border-slate-200 rounded-xl outline-none" />
            </div>
            <div className="pt-3 border-t border-slate-100 flex justify-end gap-3 text-xs">
              <button onClick={() => setIsScheduleModalOpen(false)} className="px-4 py-2.5 text-slate-600 font-semibold">{"Cancel"}</button>
              <button onClick={() => { setIsScheduleModalOpen(false); showToast("Drive scheduled successfully!"); }} className="px-5 py-2.5 bg-[#7C3AED] text-white font-bold rounded-xl shadow-md">{"Schedule Drive"}</button>
            </div>
          </div>
        </div>
      )}

      {/* MODAL 6: View Intelligence Reports Modal */}
      {isReportsModalOpen && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <FileText className="w-5 h-5 text-[#7C3AED]" />
                <h3 className="text-lg font-extrabold text-slate-900">{"Placement Intelligence Reports"}</h3>
              </div>
              <button onClick={() => setIsReportsModalOpen(false)} className="text-slate-400 hover:text-slate-600 p-1">
                <X className="w-5 h-5" />
              </button>
            </div>
            <p className="text-xs text-slate-600 font-medium">{"Download executive reports & analytical summaries for academic year 2024-25."}</p>
            <div className="flex gap-3">
              <button onClick={() => { setIsReportsModalOpen(false); showToast("Downloaded Executive PDF Report!"); }} className="flex-1 py-3 bg-[#7C3AED] hover:bg-[#6B21A8] text-white font-bold rounded-xl text-xs shadow-md">{"Download PDF"}</button>
              <button onClick={() => { setIsReportsModalOpen(false); showToast("Exported Raw CSV Dataset!"); }} className="flex-1 py-3 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-xl text-xs shadow-md">{"Export CSV"}</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default ExecutiveOverview;
