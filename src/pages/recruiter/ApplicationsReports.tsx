import { useState, useEffect } from "react";
import RecruiterLayout from "../../components/recruiter/RecruiterLayout";
import { pushRecruiterNotification } from "../../utils/recruiterNotifications";
import {
  FileBarChart2,
  Download,
  Filter,
  Search,
  PlusCircle,
  Users,
  Inbox,
  CheckCircle2,
  UserCheck,
  Briefcase,
  ChevronRight
} from "lucide-react";
import { cn } from "../../lib/utils";
import { useNavigate } from "react-router-dom";

export interface CandidateAppItem {
  id: number;
  jobId?: number | string;
  jobTitle?: string;
  name: string;
  role: string;
  stage: string;
  score: string;
  appliedDate?: string;
  source?: string;
}

const defaultCandidatesData: CandidateAppItem[] = [
  { id: 101, jobId: "1", jobTitle: "Full Stack Developer", name: "Rohan Verma", role: "Full Stack Developer", stage: "shortlisted", score: "94", appliedDate: "Today", source: "Referral" },
  { id: 102, jobId: "2", jobTitle: "AI / ML Engineer", name: "Ananya Sharma", role: "AI / ML Engineer", stage: "eligible", score: "91", appliedDate: "Yesterday", source: "External / Outside" },
  { id: 103, jobId: "1", jobTitle: "Full Stack Developer", name: "Siddharth Rao", role: "Full Stack Developer", stage: "shortlisted", score: "96", appliedDate: "2 days ago", source: "Referral" },
  { id: 104, jobId: "1", jobTitle: "Full Stack Developer", name: "Priya Sundaram", role: "Full Stack Developer", stage: "interview", score: "98", appliedDate: "3 days ago", source: "Direct Application" },
  { id: 105, jobId: "2", jobTitle: "AI / ML Engineer", name: "Kabir Mehta", role: "AI / ML Engineer", stage: "offer", score: "99", appliedDate: "4 days ago", source: "External / Outside" }
];

const ApplicationsReports = () => {
  const navigate = useNavigate();
  const [selectedFilter, setSelectedFilter] = useState("ALL");
  const [candidates, setCandidates] = useState<CandidateAppItem[]>([]);

  const loadCandidatesData = () => {
    try {
      const storedCandStr = localStorage.getItem("c2c_recruiter_candidates");
      if (storedCandStr) {
        const parsed = JSON.parse(storedCandStr);
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
    loadCandidatesData();
    window.addEventListener("storage", loadCandidatesData);
    return () => window.removeEventListener("storage", loadCandidatesData);
  }, []);

  const handleShortlistCandidate = (candidateId: number) => {
    const updated = candidates.map(c => c.id === candidateId ? { ...c, stage: "shortlisted" } : c);
    setCandidates(updated);
    try {
      localStorage.setItem("c2c_recruiter_candidates", JSON.stringify(updated));
      window.dispatchEvent(new Event("storage"));
    } catch (e) {
      console.error(e);
    }

    const target = candidates.find(c => c.id === candidateId);
    if (target) {
      pushRecruiterNotification(
        "Candidate Shortlisted",
        `⭐ ${target.name} has been shortlisted for "${target.jobTitle || target.role}".`,
        "info"
      );
    }
  };

  const filteredCandidates = candidates.filter((c) => {
    if (selectedFilter === "ALL") return true;
    if (selectedFilter === "ELIGIBLE") return c.stage === "eligible";
    if (selectedFilter === "SHORTLISTED") return c.stage === "shortlisted";
    if (selectedFilter === "CONTACTED") return c.stage === "contacted";
    if (selectedFilter === "INTERVIEW") return c.stage === "interview";
    if (selectedFilter === "OFFER") return c.stage === "offer";
    return true;
  });

  return (
    <RecruiterLayout
      title="Applications & Reports"
      subtitle="View, filter, and analyze candidate application intelligence."
      sidebarHighlight="/recruiter/applications"
    >
      <div className="space-y-6 pb-8">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h2 className="text-xl font-bold text-slate-900">Applications & Candidate Reports</h2>
            <p className="text-slate-500 text-xs mt-0.5">Filtering candidate responses across all active and past job postings.</p>
          </div>
          <div className="flex items-center gap-2">
            <button 
              onClick={() => navigate("/recruiter/shortlisted-candidates")}
              className="inline-flex items-center gap-1.5 px-3.5 py-2 text-xs font-bold text-[#5e17eb] bg-purple-50 hover:bg-purple-100 border border-purple-200 rounded-xl transition-all shadow-xs"
            >
              <UserCheck className="w-3.5 h-3.5" /> View Shortlisted Candidates Pipeline →
            </button>
          </div>
        </div>

        {/* Filter Pills Row */}
        <div className="flex flex-wrap items-center gap-2">
          {[
            { id: "ALL", label: `All Applications (${candidates.length})` },
            { id: "ELIGIBLE", label: `Eligible / Applied (${candidates.filter(c => c.stage === "eligible").length})` },
            { id: "SHORTLISTED", label: `Shortlisted (${candidates.filter(c => c.stage === "shortlisted").length})` },
            { id: "CONTACTED", label: `Contacted (${candidates.filter(c => c.stage === "contacted").length})` },
            { id: "INTERVIEW", label: `Interview (${candidates.filter(c => c.stage === "interview").length})` },
            { id: "OFFER", label: `Offer Extended (${candidates.filter(c => c.stage === "offer").length})` }
          ].map((filter) => (
            <button
              key={filter.id}
              onClick={() => setSelectedFilter(filter.id)}
              className={cn(
                "px-3 py-1.5 text-xs font-bold rounded-xl transition-all",
                selectedFilter === filter.id
                  ? "bg-[#5e17eb] text-white shadow-xs"
                  : "bg-white text-slate-600 border border-slate-200 hover:bg-slate-50"
              )}
            >
              {filter.label}
            </button>
          ))}
        </div>

        {/* Applications Data Table */}
        <div className="bg-white rounded-2xl border border-slate-200 shadow-xs overflow-hidden">
          {filteredCandidates.length > 0 ? (
            <div className="overflow-x-auto">
              <table className="w-full text-left text-sm">
                <thead className="bg-slate-50 text-slate-500 font-bold text-xs uppercase tracking-wider border-b border-slate-200">
                  <tr>
                    <th className="px-5 py-3.5">Candidate Name</th>
                    <th className="px-5 py-3.5">Applied Job Vacancy</th>
                    <th className="px-5 py-3.5">Pipeline Stage</th>
                    <th className="px-5 py-3.5">Skill Match</th>
                    <th className="px-5 py-3.5">Applied Date</th>
                    <th className="px-5 py-3.5 text-right">Shortlist Action</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {filteredCandidates.map((app) => (
                    <tr key={app.id} className="hover:bg-slate-50/50 transition-colors">
                      <td className="px-5 py-4 font-bold text-slate-900">
                        {app.name}
                        {app.source && (
                          <span className="block text-[10px] font-semibold text-slate-400 mt-0.5">
                            {app.source}
                          </span>
                        )}
                      </td>
                      <td className="px-5 py-4 text-xs font-semibold text-slate-700">
                        <span className="px-2.5 py-1 bg-purple-50 text-[#5e17eb] rounded-lg font-bold">
                          {app.jobTitle || app.role}
                        </span>
                      </td>
                      <td className="px-5 py-4">
                        <span className={cn(
                          "px-2.5 py-1 rounded-full text-[11px] font-extrabold uppercase border",
                          app.stage === "shortlisted" && "bg-indigo-50 text-indigo-700 border-indigo-200",
                          app.stage === "contacted" && "bg-blue-50 text-blue-700 border-blue-200",
                          app.stage === "eligible" && "bg-purple-50 text-purple-700 border-purple-200",
                          app.stage === "interview" && "bg-amber-50 text-amber-700 border-amber-200",
                          app.stage === "offer" && "bg-emerald-50 text-emerald-700 border-emerald-200"
                        )}>
                          {app.stage === "eligible" ? "ELIGIBLE" : app.stage}
                        </span>
                      </td>
                      <td className="px-5 py-4 text-xs font-extrabold text-slate-900">{app.score}% Match</td>
                      <td className="px-5 py-4 text-xs text-slate-500 font-medium">{app.appliedDate || "Recently"}</td>
                      <td className="px-5 py-4 text-right">
                        {app.stage === "eligible" ? (
                          <button
                            onClick={() => handleShortlistCandidate(app.id)}
                            className="px-3 py-1.5 bg-[#5e17eb] hover:bg-[#4b12bc] text-white text-xs font-bold rounded-xl transition-all shadow-xs"
                          >
                            ⭐ Shortlist Candidate
                          </button>
                        ) : app.stage === "shortlisted" ? (
                          <span className="text-xs font-bold text-emerald-600 inline-flex items-center gap-1">
                            <CheckCircle2 className="w-4 h-4 text-emerald-500" /> Shortlisted
                          </span>
                        ) : (
                          <span className="text-xs font-bold text-blue-600 inline-flex items-center gap-1">
                            <CheckCircle2 className="w-4 h-4 text-blue-500" /> In Hiring Pipeline
                          </span>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          ) : (
            <div className="p-16 text-center flex flex-col items-center justify-center">
              <div className="w-14 h-14 rounded-2xl bg-purple-50 flex items-center justify-center text-[#5e17eb] mb-4">
                <Inbox className="w-7 h-7" />
              </div>
              <h3 className="text-lg font-bold text-slate-900">No Applications Found</h3>
              <p className="text-slate-500 text-sm mt-1 max-w-md leading-relaxed">
                No candidate applications match your current filters.
              </p>
            </div>
          )}
        </div>
      </div>
    </RecruiterLayout>
  );
};

export default ApplicationsReports;
