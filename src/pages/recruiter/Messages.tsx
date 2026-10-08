import { useState } from "react";
import RecruiterLayout from "../../components/recruiter/RecruiterLayout";
import { pushRecruiterNotification } from "../../utils/recruiterNotifications";
import {
  MessageSquare,
  Search,
  Send,
  User,
  Calendar,
  Mail,
  Phone,
  FileText,
  Plus,
  X,
  AlertTriangle,
  CheckCircle2
} from "lucide-react";
import { cn } from "../../lib/utils";
import { useNavigate } from "react-router-dom";

interface MessageItem {
  id: number;
  candidateName: string;
  role: string;
  lastMessage: string;
  time: string;
}

const Messages = () => {
  const navigate = useNavigate();
  const [conversations, setConversations] = useState<MessageItem[]>([]);
  const [selectedConv, setSelectedConv] = useState<MessageItem | null>(null);
  const [showModal, setShowModal] = useState(false);

  // New Conversation Form State
  const [candidateName, setCandidateName] = useState("");
  const [candidateNameError, setCandidateNameError] = useState("");
  const [roleTitle, setRoleTitle] = useState("");
  const [roleTitleError, setRoleTitleError] = useState("");
  const [firstMessage, setFirstMessage] = useState("");
  const [formError, setFormError] = useState("");

  // Candidate Name Input: Strictly NO NUMBERS
  const handleNameChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const val = e.target.value;
    if (/[0-9]/.test(val)) {
      setCandidateNameError("Numbers are not allowed in Candidate Name");
    } else {
      setCandidateNameError("");
    }
    setCandidateName(val.replace(/[0-9]/g, ""));
  };

  // Job Title Input: Strictly NO NUMBERS
  const handleRoleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const val = e.target.value;
    if (/[0-9]/.test(val)) {
      setRoleTitleError("Numbers are not allowed in Job Title / Role");
    } else {
      setRoleTitleError("");
    }
    setRoleTitle(val.replace(/[0-9]/g, ""));
  };

  const handleStartConversation = (e: React.FormEvent) => {
    e.preventDefault();
    if (!candidateName.trim() || !roleTitle.trim() || !firstMessage.trim()) {
      setFormError("Please fill out all required fields.");
      return;
    }
    setFormError("");
    const newConv: MessageItem = {
      id: Date.now(),
      candidateName: candidateName.trim(),
      role: roleTitle.trim(),
      lastMessage: firstMessage.trim(),
      time: "Just now"
    };
    setConversations([newConv, ...conversations]);
    setSelectedConv(newConv);
    
    pushRecruiterNotification(
      "New Conversation Started",
      `💬 Message sent to ${candidateName.trim()} for "${roleTitle.trim()}".`,
      "info"
    );

    setCandidateName("");
    setRoleTitle("");
    setFirstMessage("");
    setShowModal(false);
  };

  return (
    <RecruiterLayout
      title="Messages"
      subtitle="Communicate directly with candidates and coordinate interview schedules."
      sidebarHighlight="/recruiter/messages"
    >
      <div className="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden min-h-[580px] flex flex-col md:flex-row">
        {/* Left Sidebar — Conversations List */}
        <div className="w-full md:w-80 border-r border-slate-100 flex flex-col shrink-0 bg-slate-50/50">
          <div className="p-4 border-b border-slate-100 flex items-center justify-between">
            <h3 className="text-base font-bold text-slate-900">Messages</h3>
            <button 
              onClick={() => setShowModal(true)}
              className="p-1.5 bg-[#5e17eb] hover:bg-[#4b12bc] text-white rounded-lg transition-colors"
              title="New Message"
            >
              <Plus className="w-4 h-4" />
            </button>
          </div>

          <div className="p-3 border-b border-slate-100">
            <div className="flex items-center gap-2 px-3 py-2 bg-white border border-slate-200 rounded-xl text-xs text-slate-400">
              <Search className="w-4 h-4" />
              <input 
                type="text" 
                placeholder="Search messages..." 
                className="bg-transparent border-none outline-none w-full text-slate-700 placeholder-slate-400"
              />
            </div>
          </div>

          {/* Conversations List / Empty */}
          {conversations.length > 0 ? (
            <div className="flex-1 overflow-y-auto divide-y divide-slate-100">
              {conversations.map((c) => (
                <div 
                  key={c.id} 
                  onClick={() => setSelectedConv(c)}
                  className={cn(
                    "p-3.5 cursor-pointer hover:bg-slate-100/60 transition-colors flex items-start gap-3",
                    selectedConv?.id === c.id ? "bg-purple-50/70 border-l-4 border-l-[#5e17eb]" : ""
                  )}
                >
                  <div className="w-9 h-9 rounded-full bg-[#5e17eb] text-white font-bold text-xs flex items-center justify-center shrink-0">
                    {c.candidateName.split(" ").map(n => n[0]).join("")}
                  </div>
                  <div className="min-w-0 flex-1">
                    <div className="flex items-center justify-between">
                      <h4 className="text-xs font-bold text-slate-900 truncate">{c.candidateName}</h4>
                      <span className="text-[10px] text-slate-400">{c.time}</span>
                    </div>
                    <p className="text-[11px] text-slate-500 truncate">{c.role}</p>
                    <p className="text-[11px] text-slate-600 truncate mt-0.5">{c.lastMessage}</p>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="flex-1 overflow-y-auto p-4 text-center flex flex-col items-center justify-center">
              <div className="w-10 h-10 rounded-full bg-purple-50 flex items-center justify-center text-[#5e17eb] mb-2">
                <MessageSquare className="w-5 h-5" />
              </div>
              <p className="text-xs font-semibold text-slate-700">No messages yet</p>
              <p className="text-[11px] text-slate-400 mt-0.5">Start a new message to contact candidates.</p>
              <button 
                onClick={() => setShowModal(true)}
                className="mt-3 px-3 py-1.5 bg-[#5e17eb] text-white rounded-lg text-xs font-semibold hover:bg-[#4b12bc]"
              >
                + Start Message
              </button>
            </div>
          )}
        </div>

        {/* Center Panel — Active Chat or Empty State */}
        {selectedConv ? (
          <div className="flex-1 flex flex-col justify-between p-4 bg-white">
            <div className="border-b border-slate-100 pb-3 flex items-center justify-between">
              <div>
                <h3 className="font-bold text-slate-900 text-sm">{selectedConv.candidateName}</h3>
                <p className="text-xs text-slate-500">{selectedConv.role}</p>
              </div>
            </div>
            
            <div className="flex-1 py-4 space-y-3 overflow-y-auto">
              <div className="max-w-md bg-[#5e17eb] text-white p-3 rounded-2xl rounded-tr-none text-xs ml-auto shadow-sm">
                {selectedConv.lastMessage}
              </div>
            </div>

            <div className="pt-3 border-t border-slate-100 flex items-center gap-2">
              <input 
                type="text" 
                placeholder="Type your message..." 
                className="flex-1 px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs outline-none focus:ring-2 focus:ring-[#5e17eb]/20"
              />
              <button className="p-2.5 bg-[#5e17eb] text-white rounded-xl hover:bg-[#4b12bc]">
                <Send className="w-4 h-4" />
              </button>
            </div>
          </div>
        ) : (
          <div className="flex-1 flex flex-col items-center justify-center p-12 text-center bg-slate-50/30">
            <div className="w-16 h-16 rounded-2xl bg-purple-100/60 flex items-center justify-center text-[#5e17eb] mb-4 shadow-sm">
              <MessageSquare className="w-8 h-8" />
            </div>
            <h3 className="text-lg font-bold text-slate-900">Interview & Communications Center</h3>
            <p className="text-slate-500 text-sm mt-1 max-w-md leading-relaxed">
              Select a candidate or start a new conversation to communicate and schedule interview rounds.
            </p>
            <button
              onClick={() => setShowModal(true)}
              className="mt-6 px-5 py-2.5 bg-[#5e17eb] hover:bg-[#4b12bc] text-white text-sm font-semibold rounded-xl transition-all shadow-md"
            >
              + Start New Conversation
            </button>
          </div>
        )}
      </div>

      {/* New Conversation Modal */}
      {showModal && (
        <div className="fixed inset-0 z-50 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl p-6 border border-slate-200 shadow-xl max-w-md w-full space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <h3 className="text-base font-bold text-slate-900">Start New Candidate Message</h3>
              <button onClick={() => setShowModal(false)} className="text-slate-400 hover:text-slate-600">
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleStartConversation} className="space-y-4">
              {formError && (
                <div className="p-3 bg-rose-50 border border-rose-200 rounded-xl text-xs font-semibold text-rose-700 flex items-center gap-2">
                  <AlertTriangle className="w-4 h-4 shrink-0" /> {formError}
                </div>
              )}

              <div>
                <label className="block text-xs font-semibold text-slate-800 mb-1">
                  Candidate Name <span className="text-rose-500">*</span>
                </label>
                <input 
                  type="text" 
                  value={candidateName}
                  onChange={handleNameChange}
                  placeholder="e.g. Priya Sharma (Letters only)"
                  className="w-full px-3.5 py-2.5 rounded-xl border border-slate-300 focus:ring-2 focus:ring-[#5e17eb]/20 focus:outline-none text-sm font-medium"
                />
                {candidateNameError && (
                  <p className="mt-1 text-xs text-rose-600 font-semibold flex items-center gap-1">
                    <AlertTriangle className="w-3.5 h-3.5" /> {candidateNameError}
                  </p>
                )}
                <p className="mt-1 text-[11px] text-slate-400">Numbers (0-9) are strictly prohibited in Candidate Name.</p>
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-800 mb-1">
                  Job Title / Position <span className="text-rose-500">*</span>
                </label>
                <input 
                  type="text" 
                  value={roleTitle}
                  onChange={handleRoleChange}
                  placeholder="e.g. Software Engineer (Letters only)"
                  className="w-full px-3.5 py-2.5 rounded-xl border border-slate-300 focus:ring-2 focus:ring-[#5e17eb]/20 focus:outline-none text-sm font-medium"
                />
                {roleTitleError && (
                  <p className="mt-1 text-xs text-rose-600 font-semibold flex items-center gap-1">
                    <AlertTriangle className="w-3.5 h-3.5" /> {roleTitleError}
                  </p>
                )}
                <p className="mt-1 text-[11px] text-slate-400">Numbers (0-9) are strictly prohibited in Job Title field.</p>
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-800 mb-1">
                  Initial Message <span className="text-rose-500">*</span>
                </label>
                <textarea 
                  rows={3}
                  value={firstMessage}
                  onChange={(e) => setFirstMessage(e.target.value)}
                  placeholder="Write your message or interview invite..."
                  className="w-full px-3.5 py-2.5 rounded-xl border border-slate-300 focus:ring-2 focus:ring-[#5e17eb]/20 focus:outline-none text-sm resize-none"
                ></textarea>
              </div>

              <div className="flex items-center justify-end gap-2 pt-2 border-t border-slate-100">
                <button 
                  type="button" 
                  onClick={() => setShowModal(false)}
                  className="px-4 py-2 border border-slate-200 rounded-xl text-xs font-semibold text-slate-600 hover:bg-slate-50"
                >
                  Cancel
                </button>
                <button 
                  type="submit" 
                  className="px-4 py-2 bg-[#5e17eb] hover:bg-[#4b12bc] text-white rounded-xl text-xs font-semibold shadow-sm"
                >
                  Send Message
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </RecruiterLayout>
  );
};

export default Messages;
