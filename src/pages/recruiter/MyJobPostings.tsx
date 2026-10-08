import { useState, useEffect } from "react";
import { useSearchParams, useNavigate } from "react-router-dom";
import RecruiterLayout from "../../components/recruiter/RecruiterLayout";
import { pushRecruiterNotification } from "../../utils/recruiterNotifications";
import {
  Briefcase,
  Plus,
  Filter,
  Eye,
  FileCheck2,
  Users,
  CheckCircle2,
  PlusCircle,
  FolderOpen,
  MapPin,
  IndianRupee,
  Trash2,
  Edit,
  ExternalLink,
  X,
  Sparkles,
  ArrowLeft,
  Calendar,
  Building,
  Check
} from "lucide-react";
import { cn } from "../../lib/utils";

export interface JobPostingItem {
  id: number;
  title: string;
  description: string;
  jobType: string;
  isRemote: boolean;
  location: string;
  salaryMin: string;
  salaryMax: string;
  salaryCurrency: string;
  skills: string[];
  departments: any[];
  status: "ACTIVE" | "DRAFT";
  createdAt: string;
  applicantsCount: number;
  inReviewCount: number;
  hiredCount: number;
}

const MyJobPostings = () => {
  const navigate = useNavigate();
  const [searchParams, setSearchParams] = useSearchParams();
  const selectedJobIdParam = searchParams.get("jobId");

  const [activeTab, setActiveTab] = useState("ALL");
  const [postings, setPostings] = useState<JobPostingItem[]>([]);
  const [selectedJobModal, setSelectedJobModal] = useState<JobPostingItem | null>(null);

  useEffect(() => {
    try {
      const stored = localStorage.getItem("c2c_recruiter_jobs");
      if (stored) {
        setPostings(JSON.parse(stored));
      }
    } catch (e) {
      console.error("Error loading jobs", e);
    }
  }, []);

  const deletePosting = (id: number) => {
    const updated = postings.filter(p => p.id !== id);
    setPostings(updated);
    localStorage.setItem("c2c_recruiter_jobs", JSON.stringify(updated));
    if (selectedJobIdParam && String(id) === selectedJobIdParam) {
      setSearchParams({});
    }
  };

  const publishDraft = (id: number) => {
    const targetJob = postings.find(p => p.id === id);
    const updated = postings.map(p => p.id === id ? { ...p, status: "ACTIVE" as const } : p);
    setPostings(updated);
    localStorage.setItem("c2c_recruiter_jobs", JSON.stringify(updated));
    window.dispatchEvent(new Event("storage"));

    if (targetJob) {
      pushRecruiterNotification(
        "Draft Job Vacancy Published",
        `🎉 Job vacancy "${targetJob.title}" is now published and active for candidate applications.`,
        "success"
      );
    }
  };

  // Filter postings based on active tab AND optional selected jobId URL param
  const filteredPostings = postings.filter(p => {
    if (selectedJobIdParam) {
      return String(p.id) === selectedJobIdParam;
    }
    if (activeTab === "ACTIVE") return p.status === "ACTIVE";
    if (activeTab === "DRAFT") return p.status === "DRAFT";
    return true;
  });

  const selectedJobInfo = selectedJobIdParam ? postings.find(p => String(p.id) === selectedJobIdParam) : null;

  return (
    <RecruiterLayout
      title="My Job Postings"
      subtitle="Manage and analyze your active talent acquisitions."
      sidebarHighlight="/recruiter/my-postings"
    >
      <div className="space-y-6 pb-8">
        {/* Specific Job Filter Banner */}
        {selectedJobIdParam && selectedJobInfo && (
          <div className="p-4 bg-purple-50 border-2 border-purple-200 rounded-2xl flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 shadow-xs">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-purple-100 text-[#5e17eb] rounded-xl shrink-0">
                <Briefcase className="w-5 h-5" />
              </div>
              <div>
                <span className="text-[10px] font-extrabold uppercase tracking-wider text-purple-700 bg-purple-100 px-2 py-0.5 rounded-md">
                  SINGLE JOB VIEW
                </span>
                <h3 className="text-sm font-bold text-slate-900 mt-0.5">
                  Viewing Job Posting: <span className="text-[#5e17eb]">{selectedJobInfo.title}</span>
                </h3>
              </div>
            </div>
            <button
              onClick={() => setSearchParams({})}
              className="px-3.5 py-1.5 bg-white border border-purple-300 hover:bg-purple-100 text-[#5e17eb] text-xs font-bold rounded-xl transition-all shadow-xs flex items-center gap-1.5 shrink-0"
            >
              <ArrowLeft className="w-3.5 h-3.5" />
              Show All Job Postings
            </button>
          </div>
        )}

        {/* Page Header */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h2 className="text-xl font-bold text-slate-900">Job Postings & Performance</h2>
            <p className="text-slate-500 text-xs mt-0.5">Track views, applications, and hiring pipeline metrics for all open positions.</p>
          </div>
          <button
            onClick={() => navigate("/recruiter/post-job")}
            className="inline-flex items-center gap-2 px-4 py-2.5 bg-[#5e17eb] hover:bg-[#4b12bc] text-white text-sm font-semibold rounded-xl transition-all shadow-sm hover:shadow shrink-0"
          >
            <Plus className="w-4 h-4" />
            Post a New Job
          </button>
        </div>

        {/* Filter Tabs Row */}
        {!selectedJobIdParam && (
          <div className="flex flex-wrap items-center justify-between gap-4 border-b border-slate-200 pb-3">
            <div className="flex items-center gap-2">
              {[
                { id: "ALL", label: `All Postings (${postings.length})` },
                { id: "ACTIVE", label: `Active (${postings.filter(p => p.status === "ACTIVE").length})` },
                { id: "DRAFT", label: `Drafts (${postings.filter(p => p.status === "DRAFT").length})` },
              ].map((tab) => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={cn(
                    "px-4 py-2 rounded-xl text-xs font-bold transition-all",
                    activeTab === tab.id
                      ? "bg-[#5e17eb] text-white shadow-xs"
                      : "bg-slate-100 text-slate-600 hover:bg-slate-200"
                  )}
                >
                  {tab.label}
                </button>
              ))}
            </div>
          </div>
        )}

        {/* Postings List / Grid */}
        {filteredPostings.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {filteredPostings.map((job) => (
              <div key={job.id} className="bg-white rounded-2xl p-5 border border-slate-200 shadow-xs hover:shadow-md transition-all space-y-4 flex flex-col justify-between">
                <div className="space-y-3">
                  <div className="flex items-start justify-between gap-3">
                    <div>
                      <div className="flex items-center gap-2 mb-1">
                        <h3 className="text-base font-bold text-slate-900 leading-snug">{job.title}</h3>
                        <span className={cn(
                          "px-2.5 py-0.5 rounded-full text-[10px] font-extrabold uppercase border",
                          job.status === "ACTIVE" ? "bg-emerald-50 text-emerald-700 border-emerald-200" : "bg-amber-50 text-amber-700 border-amber-200"
                        )}>
                          {job.status}
                        </span>
                      </div>
                      <div className="flex items-center gap-3 text-xs text-slate-500 font-medium">
                        <span className="flex items-center gap-1"><MapPin className="w-3.5 h-3.5" /> {job.location || "Remote"}</span>
                        <span>• {job.jobType}</span>
                        {job.createdAt && <span>• Posted {job.createdAt}</span>}
                      </div>
                    </div>

                    <button
                      onClick={() => deletePosting(job.id)}
                      className="text-slate-400 hover:text-rose-600 transition-colors p-1"
                      title="Delete Posting"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>

                  {job.description && (
                    <p className="text-xs text-slate-600 line-clamp-2 leading-relaxed">
                      {job.description}
                    </p>
                  )}

                  {/* Skills tags */}
                  {job.skills && job.skills.length > 0 && (
                    <div className="flex flex-wrap gap-1.5 pt-1">
                      {job.skills.slice(0, 4).map((skill, idx) => (
                        <span key={idx} className="px-2 py-0.5 bg-slate-100 text-slate-700 text-[10px] font-bold rounded-md">
                          {skill}
                        </span>
                      ))}
                      {job.skills.length > 4 && (
                        <span className="px-2 py-0.5 bg-slate-50 text-slate-400 text-[10px] font-bold rounded-md">
                          +{job.skills.length - 4} more
                        </span>
                      )}
                    </div>
                  )}

                  {/* Compensation & Applicants count */}
                  <div className="pt-3 border-t border-slate-100 flex items-center justify-between text-xs">
                    <div className="font-bold text-slate-900 flex items-center gap-1">
                      <IndianRupee className="w-3.5 h-3.5 text-slate-500" />
                      {job.salaryMin ? `${job.salaryMin} - ${job.salaryMax} LPA` : "Not specified"}
                    </div>
                    <span className="px-2.5 py-1 bg-purple-50 text-[#5e17eb] rounded-lg font-bold text-[11px] flex items-center gap-1">
                      <Users className="w-3.5 h-3.5" /> {job.applicantsCount || 0} Applicants
                    </span>
                  </div>
                </div>

                {/* Card Actions */}
                <div className="flex items-center justify-between gap-2 pt-2 border-t border-slate-100">
                  <button
                    onClick={() => setSelectedJobModal(job)}
                    className="px-3.5 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 text-xs font-bold rounded-xl transition-all flex items-center gap-1.5"
                  >
                    <Eye className="w-3.5 h-3.5" />
                    View Details
                  </button>

                  {job.status === "DRAFT" ? (
                    <button
                      onClick={() => publishDraft(job.id)}
                      className="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold rounded-xl transition-all shadow-xs flex items-center gap-1.5"
                    >
                      <CheckCircle2 className="w-3.5 h-3.5" />
                      Publish Job
                    </button>
                  ) : (
                    <button
                      onClick={() => navigate("/recruiter/shortlisted-candidates")}
                      className="px-4 py-2 bg-[#5e17eb] hover:bg-[#4b12bc] text-white text-xs font-bold rounded-xl transition-all shadow-xs flex items-center gap-1.5"
                    >
                      View Pipeline →
                    </button>
                  )}
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="bg-white rounded-2xl p-12 border border-slate-200 text-center flex flex-col items-center justify-center space-y-3">
            <div className="w-12 h-12 rounded-2xl bg-purple-50 flex items-center justify-center text-[#5e17eb]">
              <FolderOpen className="w-6 h-6" />
            </div>
            <h3 className="text-base font-bold text-slate-900">
              {selectedJobIdParam ? "Selected job posting not found" : "No job postings found"}
            </h3>
            <p className="text-slate-500 text-xs max-w-sm">
              {selectedJobIdParam ? "This job posting may have been deleted or removed." : "You have not published any job vacancies yet."}
            </p>
            {selectedJobIdParam ? (
              <button
                onClick={() => setSearchParams({})}
                className="mt-2 px-4 py-2 bg-[#5e17eb] hover:bg-[#4b12bc] text-white text-xs font-bold rounded-xl shadow-xs"
              >
                View All Job Postings
              </button>
            ) : (
              <button
                onClick={() => navigate("/recruiter/post-job")}
                className="mt-2 px-4 py-2 bg-[#5e17eb] hover:bg-[#4b12bc] text-white text-xs font-bold rounded-xl shadow-xs"
              >
                + Create First Job Posting
              </button>
            )}
          </div>
        )}
      </div>

      {/* JOB DETAILS PREVIEW MODAL */}
      {selectedJobModal && (
        <div className="fixed inset-0 z-50 bg-slate-900/40 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl p-6 border border-slate-200 shadow-2xl max-w-2xl w-full space-y-5 animate-in fade-in zoom-in duration-150 max-h-[85vh] overflow-y-auto">
            <div className="flex items-start justify-between border-b border-slate-100 pb-4">
              <div>
                <span className={cn(
                  "px-2.5 py-0.5 rounded-full text-[10px] font-extrabold uppercase border mb-2 inline-block",
                  selectedJobModal.status === "ACTIVE" ? "bg-emerald-50 text-emerald-700 border-emerald-200" : "bg-amber-50 text-amber-700 border-amber-200"
                )}>
                  {selectedJobModal.status}
                </span>
                <h3 className="text-xl font-extrabold text-slate-900">{selectedJobModal.title}</h3>
                <div className="flex items-center gap-4 text-xs text-slate-500 font-medium mt-1">
                  <span className="flex items-center gap-1"><MapPin className="w-3.5 h-3.5" /> {selectedJobModal.location || "Remote"}</span>
                  <span>• {selectedJobModal.jobType}</span>
                  {selectedJobModal.createdAt && <span>• Posted {selectedJobModal.createdAt}</span>}
                </div>
              </div>
              <button onClick={() => setSelectedJobModal(null)} className="text-slate-400 hover:text-slate-600 p-1">
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Description */}
            <div className="space-y-2">
              <h4 className="text-xs font-bold text-slate-900 uppercase tracking-wider">Job Description</h4>
              <p className="text-xs text-slate-700 leading-relaxed whitespace-pre-line bg-slate-50 p-4 rounded-2xl border border-slate-100">
                {selectedJobModal.description || "No description provided."}
              </p>
            </div>

            {/* Compensation & Skills */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs">
              <div className="bg-purple-50 p-4 rounded-2xl border border-purple-100">
                <span className="text-[10px] font-bold text-purple-700 uppercase block mb-1">Salary Range</span>
                <span className="text-sm font-bold text-slate-900">
                  {selectedJobModal.salaryMin ? `${selectedJobModal.salaryMin} - ${selectedJobModal.salaryMax} LPA` : "Not specified"}
                </span>
              </div>
              <div className="bg-blue-50 p-4 rounded-2xl border border-blue-100">
                <span className="text-[10px] font-bold text-blue-700 uppercase block mb-1">Applications Summary</span>
                <span className="text-sm font-bold text-slate-900">
                  {selectedJobModal.applicantsCount || 0} Candidates Applied
                </span>
              </div>
            </div>

            {/* Skills */}
            {selectedJobModal.skills && selectedJobModal.skills.length > 0 && (
              <div className="space-y-2">
                <h4 className="text-xs font-bold text-slate-900 uppercase tracking-wider">Required Skills</h4>
                <div className="flex flex-wrap gap-1.5">
                  {selectedJobModal.skills.map((s, idx) => (
                    <span key={idx} className="px-3 py-1 bg-slate-100 text-slate-800 text-xs font-bold rounded-xl border border-slate-200">
                      {s}
                    </span>
                  ))}
                </div>
              </div>
            )}

            <div className="flex items-center justify-end gap-3 pt-3 border-t border-slate-100">
              <button
                onClick={() => setSelectedJobModal(null)}
                className="px-4 py-2 border border-slate-200 rounded-xl text-xs font-semibold text-slate-600 hover:bg-slate-50 transition-colors"
              >
                Close Preview
              </button>
              {selectedJobModal.status === "DRAFT" ? (
                <button
                  onClick={() => {
                    publishDraft(selectedJobModal.id);
                    setSelectedJobModal(null);
                  }}
                  className="px-5 py-2 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold rounded-xl transition-all shadow-md"
                >
                  Publish This Job
                </button>
              ) : (
                <button
                  onClick={() => {
                    setSelectedJobModal(null);
                    navigate("/recruiter/shortlisted-candidates");
                  }}
                  className="px-5 py-2 bg-[#5e17eb] hover:bg-[#4b12bc] text-white text-xs font-bold rounded-xl transition-all shadow-md"
                >
                  View Pipeline Applications →
                </button>
              )}
            </div>
          </div>
        </div>
      )}
    </RecruiterLayout>
  );
};

export default MyJobPostings;
