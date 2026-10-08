import { useState, useEffect } from "react";
import RecruiterLayout from "../../components/recruiter/RecruiterLayout";
import { pushRecruiterNotification } from "../../utils/recruiterNotifications";
import {
  Users,
  Plus,
  Inbox,
  X,
  AlertTriangle,
  CheckCircle2,
  Trash2,
  ArrowRight,
  RotateCcw,
  UserPlus
} from "lucide-react";
import { cn } from "../../lib/utils";

export interface CandidateCard {
  id: number;
  name: string;
  role: string;
  stage: string;
  score: string;
  source?: string;
}

const initialColumns = [
  { id: "shortlisted", title: "Shortlisted", color: "border-purple-500" },
  { id: "contacted", title: "Contacted", color: "border-blue-500" },
  { id: "interview", title: "Interview Scheduled", color: "border-amber-500" },
  { id: "offer", title: "Offer Extended", color: "border-emerald-500" }
];

const defaultCandidatesData: CandidateCard[] = [
  { id: 101, name: "Rohan Verma", role: "Full Stack Developer", stage: "shortlisted", score: "94", source: "Referral" },
  { id: 102, name: "Ananya Sharma", role: "AI / ML Engineer", stage: "eligible", score: "91", source: "External / Outside" },
  { id: 103, name: "Siddharth Rao", role: "Full Stack Developer", stage: "shortlisted", score: "96", source: "Referral" },
  { id: 104, name: "Priya Sundaram", role: "Full Stack Developer", stage: "interview", score: "98", source: "Direct Application" },
  { id: 105, name: "Kabir Mehta", role: "AI / ML Engineer", stage: "offer", score: "99", source: "External / Outside" }
];

const PipelineManagement = () => {
  const [candidates, setCandidates] = useState<CandidateCard[]>([]);
  const [showModal, setShowModal] = useState(false);
  const [selectedStage, setSelectedStage] = useState("shortlisted");

  // Load candidate applications from localStorage
  const loadCandidates = () => {
    try {
      const stored = localStorage.getItem("c2c_recruiter_candidates");
      if (stored) {
        const parsed = JSON.parse(stored);
        if (Array.isArray(parsed) && parsed.length > 0) {
          setCandidates(parsed);
          return;
        }
      }
      setCandidates(defaultCandidatesData);
      localStorage.setItem("c2c_recruiter_candidates", JSON.stringify(defaultCandidatesData));
    } catch (e) {
      console.error(e);
      setCandidates(defaultCandidatesData);
    }
  };

  useEffect(() => {
    loadCandidates();
    window.addEventListener("storage", loadCandidates);
    return () => window.removeEventListener("storage", loadCandidates);
  }, []);

  const saveCandidatesState = (newCandidates: CandidateCard[]) => {
    setCandidates(newCandidates);
    try {
      localStorage.setItem("c2c_recruiter_candidates", JSON.stringify(newCandidates));
      window.dispatchEvent(new Event("storage"));
    } catch (e) {
      console.error(e);
    }
  };

  // Move Forward to Next Stage
  const advanceCandidate = (candidate: CandidateCard) => {
    let nextStage = candidate.stage;
    let notifTitle = "";
    let notifMsg = "";

    if (candidate.stage === "shortlisted") {
      nextStage = "contacted";
      notifTitle = "Candidate Contacted";
      notifMsg = `📞 ${candidate.name} moved to Contacted stage for "${candidate.role}".`;
    } else if (candidate.stage === "contacted") {
      nextStage = "interview";
      notifTitle = "Interview Scheduled";
      notifMsg = `📅 Interview scheduled for ${candidate.name} (${candidate.role}).`;
    } else if (candidate.stage === "interview") {
      nextStage = "offer";
      notifTitle = "Job Offer Extended";
      notifMsg = `🎉 Job offer extended to ${candidate.name} for "${candidate.role}"!`;
    }

    if (nextStage !== candidate.stage) {
      const updated = candidates.map(c => c.id === candidate.id ? { ...c, stage: nextStage } : c);
      saveCandidatesState(updated);
      
      pushRecruiterNotification(
        notifTitle,
        notifMsg,
        "info"
      );
    }
  };

  // Rollback to Previous Stage
  const rollbackCandidate = (candidate: CandidateCard) => {
    let prevStage = candidate.stage;
    let notifMsg = "";

    if (candidate.stage === "offer") {
      prevStage = "interview";
      notifMsg = `↩️ ${candidate.name} rolled back to Interview Scheduled for "${candidate.role}".`;
    } else if (candidate.stage === "interview") {
      prevStage = "contacted";
      notifMsg = `↩️ ${candidate.name} rolled back to Contacted for "${candidate.role}".`;
    } else if (candidate.stage === "contacted") {
      prevStage = "shortlisted";
      notifMsg = `↩️ ${candidate.name} rolled back to Shortlisted for "${candidate.role}".`;
    }

    if (prevStage !== candidate.stage) {
      const updated = candidates.map(c => c.id === candidate.id ? { ...c, stage: prevStage } : c);
      saveCandidatesState(updated);
      
      pushRecruiterNotification(
        "Candidate Stage Rolled Back",
        notifMsg,
        "warning"
      );
    }
  };

  // Add Candidate Form State
  const [name, setName] = useState("");
  const [nameError, setNameError] = useState("");
  const [role, setRole] = useState("");
  const [roleError, setRoleError] = useState("");
  const [source, setSource] = useState("Referral");
  const [score, setScore] = useState("90");
  const [formError, setFormError] = useState("");

  // Candidate Name Input: Strictly NO NUMBERS
  const handleNameChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const val = e.target.value;
    if (/[0-9]/.test(val)) {
      setNameError("Numbers are not allowed in Candidate Name");
    } else {
      setNameError("");
    }
    setName(val.replace(/[0-9]/g, ""));
  };

  // Job Title Input: Strictly NO NUMBERS
  const handleRoleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const val = e.target.value;
    if (/[0-9]/.test(val)) {
      setRoleError("Numbers are not allowed in Job Title / Role");
    } else {
      setRoleError("");
    }
    setRole(val.replace(/[0-9]/g, ""));
  };

  const handleAddCandidate = (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim() || !role.trim()) {
      setFormError("Please fill out all required fields.");
      return;
    }
    setFormError("");
    const newCandidate: CandidateCard = {
      id: Date.now(),
      name: name.trim(),
      role: role.trim(),
      stage: selectedStage,
      score: score.trim() || "90",
      source: source
    };

    const updated = [...candidates, newCandidate];
    saveCandidatesState(updated);
    
    pushRecruiterNotification(
      "Candidate Added",
      `⭐ ${name.trim()} (${source}) added to candidate pipeline for "${role.trim()}".`,
      "info"
    );

    setName("");
    setRole("");
    setShowModal(false);
  };

  const removeCandidate = (id: number) => {
    const updated = candidates.filter(c => c.id !== id);
    saveCandidatesState(updated);
  };

  return (
    <RecruiterLayout
      title="Shortlisted Candidates"
      subtitle="Track and manage candidates across recruitment stages."
      sidebarHighlight="/recruiter/shortlisted-candidates"
    >
      <div className="space-y-6 pb-8">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h2 className="text-xl font-bold text-slate-900">Shortlisted Candidates</h2>
            <p className="text-slate-500 text-xs mt-0.5">Manage and advance candidates through hiring stages with Move Forward & Rollback.</p>
          </div>

          <div className="flex items-center gap-2">
            <button 
              onClick={() => {
                setSelectedStage("shortlisted");
                setShowModal(true);
              }}
              className="inline-flex items-center gap-2 px-4 py-2.5 bg-[#5e17eb] hover:bg-[#4b12bc] text-white text-xs font-semibold rounded-xl transition-all shadow-sm shrink-0"
              title="Add candidate from referral or external outside application"
            >
              <UserPlus className="w-4 h-4" />
              Add Candidate (Referral / External)
            </button>
          </div>
        </div>

        {/* Kanban Board Columns */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {initialColumns.map((col) => {
            const stageCandidates = candidates.filter(
              c => c.stage && c.stage.toLowerCase() === col.id.toLowerCase()
            );

            return (
              <div key={col.id} className="bg-slate-100/70 rounded-2xl p-4 border border-slate-200/60 flex flex-col min-h-[460px]">
                {/* Column Header */}
                <div className={cn("flex items-center justify-between pb-3 mb-3 border-b-2", col.color)}>
                  <h3 className="text-sm font-bold text-slate-800">{col.title}</h3>
                  <span className="px-2 py-0.5 text-xs font-bold bg-white text-slate-700 rounded-full border border-slate-200">
                    {stageCandidates.length}
                  </span>
                </div>

                {/* Candidate List / Empty Drop Zone */}
                {stageCandidates.length > 0 ? (
                  <div className="flex-1 space-y-3">
                    {stageCandidates.map((c) => (
                      <div key={c.id} className="bg-white rounded-xl p-3.5 border border-slate-200 shadow-xs hover:shadow transition-all space-y-2.5">
                        <div className="flex items-start justify-between">
                          <div>
                            <h4 className="text-sm font-bold text-slate-900">{c.name}</h4>
                            <p className="text-xs text-slate-500 font-medium">{c.role}</p>
                            {c.source && (
                              <span className="inline-block mt-1 px-2 py-0.5 bg-purple-50 text-[#5e17eb] text-[10px] font-extrabold rounded-md border border-purple-200">
                                Source: {c.source}
                              </span>
                            )}
                          </div>
                          <button onClick={() => removeCandidate(c.id)} className="text-slate-400 hover:text-rose-600 transition-colors p-1">
                            <Trash2 className="w-3.5 h-3.5" />
                          </button>
                        </div>

                        <div className="flex items-center justify-between pt-2 border-t border-slate-100 text-xs">
                          <span className="px-2 py-0.5 bg-emerald-50 text-emerald-700 rounded-full font-bold text-[10px]">
                            {c.score}% Match
                          </span>
                        </div>

                        {/* Move Forward & Rollback Action Buttons */}
                        <div className="space-y-1.5 pt-1">
                          {c.stage !== "offer" && (
                            <button
                              onClick={() => advanceCandidate(c)}
                              className="w-full py-1.5 px-2 bg-[#5e17eb] hover:bg-[#4b12bc] text-white rounded-lg text-[11px] font-bold transition-all flex items-center justify-center gap-1 shadow-xs"
                            >
                              Move Forward →
                            </button>
                          )}

                          {c.stage === "offer" && (
                            <div className="py-1 px-2 bg-emerald-50 text-emerald-800 rounded-lg text-[10px] font-extrabold flex items-center justify-center gap-1 border border-emerald-200">
                              <CheckCircle2 className="w-3.5 h-3.5 text-emerald-600" />
                              Offer Issued
                            </div>
                          )}

                          {c.stage !== "shortlisted" && (
                            <button
                              onClick={() => rollbackCandidate(c)}
                              className="w-full py-1 px-2 bg-slate-100 hover:bg-rose-50 text-slate-600 hover:text-rose-700 rounded-lg text-[10px] font-semibold transition-all flex items-center justify-center gap-1 border border-slate-200 hover:border-rose-200"
                              title="Roll back candidate stage"
                            >
                              <RotateCcw className="w-3 h-3 text-rose-500" />
                              Rollback
                            </button>
                          )}
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="flex-1 flex flex-col items-center justify-center p-6 border-2 border-dashed border-slate-200 rounded-xl text-center">
                    <div className="w-10 h-10 rounded-full bg-white flex items-center justify-center text-slate-400 mb-2 shadow-xs">
                      <Inbox className="w-5 h-5" />
                    </div>
                    <p className="text-xs font-semibold text-slate-600">No candidates in {col.title}</p>
                    <p className="text-[11px] text-slate-400 mt-0.5">Click below to add a candidate to this stage.</p>
                  </div>
                )}

                {/* Add Candidate Button */}
                <button 
                  onClick={() => {
                    setSelectedStage(col.id);
                    setShowModal(true);
                  }}
                  className="mt-3 w-full py-2 border border-slate-200 bg-white hover:bg-slate-50 text-slate-700 rounded-xl text-xs font-semibold flex items-center justify-center gap-1.5 transition-colors shadow-xs"
                >
                  <Plus className="w-3.5 h-3.5" />
                  Add to {col.title}
                </button>
              </div>
            );
          })}
        </div>
      </div>

      {/* Add Candidate Modal */}
      {showModal && (
        <div className="fixed inset-0 z-50 bg-slate-900/40 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl p-6 border border-slate-200 shadow-xl max-w-md w-full space-y-4 animate-in fade-in zoom-in duration-150">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <h3 className="text-base font-bold text-slate-900">Add Candidate (Referral / External)</h3>
              <button onClick={() => setShowModal(false)} className="text-slate-400 hover:text-slate-600">
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleAddCandidate} className="space-y-4">
              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">
                  Candidate Name <span className="text-rose-500">*</span>
                </label>
                <input
                  type="text"
                  value={name}
                  onChange={handleNameChange}
                  placeholder="FullName (Letters only)"
                  className="w-full px-3.5 py-2 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-[#5e17eb]/20 text-xs font-medium text-slate-800"
                />
                {nameError && (
                  <p className="mt-1 text-[11px] text-rose-600 font-semibold flex items-center gap-1">
                    <AlertTriangle className="w-3.5 h-3.5" /> {nameError}
                  </p>
                )}
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">
                  Job Role / Vacancy Title <span className="text-rose-500">*</span>
                </label>
                <input
                  type="text"
                  value={role}
                  onChange={handleRoleChange}
                  placeholder="e.g. Software Engineer (Letters only)"
                  className="w-full px-3.5 py-2 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-[#5e17eb]/20 text-xs font-medium text-slate-800"
                />
                {roleError && (
                  <p className="mt-1 text-[11px] text-rose-600 font-semibold flex items-center gap-1">
                    <AlertTriangle className="w-3.5 h-3.5" /> {roleError}
                  </p>
                )}
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">
                  Candidate Source <span className="text-rose-500">*</span>
                </label>
                <select
                  value={source}
                  onChange={(e) => setSource(e.target.value)}
                  className="w-full px-3.5 py-2 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-[#5e17eb]/20 text-xs font-medium text-slate-800 bg-white"
                >
                  <option value="Referral">Referral (Employee / Campus Referral)</option>
                  <option value="External / Outside">External / Outside Application</option>
                  <option value="Direct Application">Direct Campus Portal Application</option>
                </select>
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">
                  Target Stage <span className="text-rose-500">*</span>
                </label>
                <select
                  value={selectedStage}
                  onChange={(e) => setSelectedStage(e.target.value)}
                  className="w-full px-3.5 py-2 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-[#5e17eb]/20 text-xs font-medium text-slate-800 bg-white"
                >
                  {initialColumns.map((col) => (
                    <option key={col.id} value={col.id}>{col.title}</option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">
                  Skill Match Score (%)
                </label>
                <input
                  type="text"
                  value={score}
                  onChange={(e) => setScore(e.target.value)}
                  placeholder="90"
                  className="w-full px-3.5 py-2 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-[#5e17eb]/20 text-xs font-medium text-slate-800"
                />
              </div>

              {formError && (
                <p className="text-xs text-rose-600 font-semibold flex items-center gap-1">
                  <AlertTriangle className="w-3.5 h-3.5" /> {formError}
                </p>
              )}

              <div className="flex items-center justify-end gap-3 pt-2">
                <button
                  type="button"
                  onClick={() => setShowModal(false)}
                  className="px-4 py-2 border border-slate-200 rounded-xl text-xs font-semibold text-slate-600 hover:bg-slate-50 transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-5 py-2 bg-[#5e17eb] hover:bg-[#4b12bc] text-white text-xs font-bold rounded-xl transition-all shadow-md"
                >
                  Add Candidate
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </RecruiterLayout>
  );
};

export default PipelineManagement;
