import { useState, useEffect } from "react";
import RecruiterLayout from "../../components/recruiter/RecruiterLayout";
import {
  Briefcase,
  Users,
  UserCheck,
  Calendar,
  BarChart3,
  ChevronRight,
  MapPin,
  DollarSign,
  PlusCircle,
  Inbox,
  UserPlus
} from "lucide-react";
import { cn } from "../../lib/utils";
import { useNavigate } from "react-router-dom";

const RecruiterDashboard = () => {
  const navigate = useNavigate();
  const [jobFilter, setJobFilter] = useState("ALL");
  const [allJobs, setAllJobs] = useState<any[]>([]);
  const [candidates, setCandidates] = useState<any[]>([]);

  const loadDashboardData = () => {
    try {
      const storedJobs = localStorage.getItem("c2c_recruiter_jobs");
      if (storedJobs) {
        setAllJobs(JSON.parse(storedJobs));
      }
      const storedCandidates = localStorage.getItem("c2c_recruiter_candidates");
      if (storedCandidates) {
        setCandidates(JSON.parse(storedCandidates));
      }
    } catch (e) {
      console.error("Error reading dashboard data", e);
    }
  };

  useEffect(() => {
    loadDashboardData();
    window.addEventListener("storage", loadDashboardData);
    return () => window.removeEventListener("storage", loadDashboardData);
  }, []);

  const activeJobs = allJobs.filter(j => j.status === "ACTIVE");
  const totalAppsCount = candidates.length;
  const shortlistedCount = candidates.filter(c => c.stage === "shortlisted").length;
  const interviewCount = candidates.filter(c => c.stage === "interview").length;

  const stats = [
    { label: "Active Jobs", value: activeJobs.length.toString(), trend: `${activeJobs.length > 0 ? '+1' : '0'}`, trendUp: true, icon: Briefcase, color: "text-[#5e17eb]", bg: "bg-[#e9ddff]/50" },
    { label: "Total Applications", value: totalAppsCount.toString(), trend: `${totalAppsCount > 0 ? '+' + totalAppsCount : '0'}`, trendUp: true, icon: BarChart3, color: "text-blue-600", bg: "bg-blue-50" },
    { label: "Shortlisted", value: shortlistedCount.toString(), trend: `${shortlistedCount > 0 ? '+' + shortlistedCount : '0'}`, trendUp: true, icon: UserCheck, color: "text-emerald-600", bg: "bg-emerald-50" },
    { label: "Interviews", value: interviewCount.toString(), trend: `${interviewCount > 0 ? '+' + interviewCount : '0'}`, trendUp: true, icon: Calendar, color: "text-amber-600", bg: "bg-amber-50" }
  ];

  const [verificationStatus, setVerificationStatus] = useState("UNFILLED");

  useEffect(() => {
    try {
      const status = localStorage.getItem("c2c_verification_status") || "UNFILLED";
      setVerificationStatus(status);
    } catch (e) {
      console.error(e);
    }
  }, []);

  return (
    <RecruiterLayout 
      title="Dashboard" 
      subtitle="Overview of your recruitment activities." 
      sidebarHighlight="/recruiter/dashboard"
    >
      <div className="space-y-6 pb-8">
        
        {/* Welcome Banner */}
        <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-100 flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
          <div>
            <h2 className="text-2xl font-semibold text-slate-900 flex items-center gap-2">
              Welcome back 👋
              <span className="relative flex h-3 w-3 ml-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                <span className="relative inline-flex rounded-full h-3 w-3 bg-emerald-500"></span>
              </span>
            </h2>
            <p className="text-slate-500 mt-1 max-w-2xl text-sm leading-relaxed">
              Your recruitment workspace is set up. You currently have <strong className="text-slate-900">{activeJobs.length} active job postings</strong>.
            </p>
          </div>
          <button 
            onClick={() => navigate("/recruiter/post-job")}
            className="inline-flex items-center gap-2 px-4 py-2.5 bg-[#5e17eb] hover:bg-[#4b12bc] text-white text-sm font-semibold rounded-xl transition-all shadow-md hover:shadow-lg shrink-0"
          >
            <PlusCircle className="w-4 h-4" />
            Post a New Job
          </button>
        </div>

        {/* Stats Row */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {stats.map((stat, i) => (
            <div key={i} className="bg-white rounded-2xl p-5 border border-slate-100 shadow-sm hover:shadow-md transition-shadow group">
              <div className="flex justify-between items-start">
                <div className={cn("p-3 rounded-xl", stat.bg)}>
                  <stat.icon className={cn("w-5 h-5", stat.color)} />
                </div>
                <div className="flex items-center text-xs font-medium px-2 py-1 rounded-md text-slate-500 bg-slate-50">
                  {stat.trend}
                </div>
              </div>
              <div className="mt-4">
                <h4 className="text-slate-500 text-sm font-medium">{stat.label}</h4>
                <p className="text-2xl font-semibold text-slate-900 mt-1">{stat.value}</p>
              </div>
            </div>
          ))}
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Main Content Area */}
          <div className="lg:col-span-2 space-y-6">
            
            {/* Active Jobs */}
            <div className="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
              <div className="p-5 border-b border-slate-100 flex items-center justify-between">
                <h3 className="text-base font-semibold text-slate-900">Your Active Jobs</h3>
                <button onClick={() => navigate("/recruiter/my-postings")} className="text-sm font-medium text-[#5e17eb] hover:text-[#7c3aed] transition-colors flex items-center gap-1">
                  Manage Jobs <ChevronRight className="w-4 h-4" />
                </button>
              </div>

              {activeJobs.length > 0 ? (
                <div className="divide-y divide-slate-100">
                  {activeJobs.map((job) => (
                    <div key={job.id} className="p-5 hover:bg-slate-50/50 transition-colors">
                      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                        <div>
                          <div className="flex items-center gap-2 mb-1">
                            <h4 className="text-base font-bold text-slate-900">{job.title}</h4>
                            <span className="px-2.5 py-0.5 rounded-full text-[10px] font-extrabold uppercase bg-emerald-50 text-emerald-700 border border-emerald-200">
                              {job.status}
                            </span>
                          </div>
                          <div className="flex items-center gap-4 text-xs text-slate-500 mt-1">
                            <span className="flex items-center gap-1"><MapPin className="w-3.5 h-3.5" /> {job.location}</span>
                            <span>• {job.jobType}</span>
                          </div>
                        </div>
                        <button 
                          onClick={() => navigate(`/recruiter/my-postings?jobId=${job.id}`)}
                          className="px-3.5 py-2 text-xs font-semibold text-[#5e17eb] bg-purple-50 hover:bg-purple-100 rounded-xl transition-colors shrink-0"
                        >
                          View Posting
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="p-12 text-center flex flex-col items-center justify-center">
                  <div className="w-12 h-12 rounded-2xl bg-purple-50 flex items-center justify-center text-[#5e17eb] mb-3">
                    <Briefcase className="w-6 h-6" />
                  </div>
                  <h4 className="text-base font-semibold text-slate-800">No active job postings</h4>
                  <p className="text-slate-500 text-sm mt-1 max-w-sm">You have not published any job postings yet. Create your first listing to start accepting candidates.</p>
                  <button 
                    onClick={() => navigate("/recruiter/post-job")}
                    className="mt-4 px-4 py-2 bg-[#5e17eb] hover:bg-[#4b12bc] text-white text-sm font-semibold rounded-xl transition-all shadow-sm"
                  >
                    + Post a New Job
                  </button>
                </div>
              )}
            </div>

            {/* Recent Applications Table */}
            <div className="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
               <div className="p-5 border-b border-slate-100 flex items-center justify-between">
                <h3 className="text-base font-semibold text-slate-900">Recent Applications</h3>
                <button onClick={() => navigate("/recruiter/applications")} className="text-sm font-medium text-[#5e17eb] hover:text-[#7c3aed]">
                  View All
                </button>
              </div>
              
              <div className="p-12 text-center flex flex-col items-center justify-center">
                <div className="w-12 h-12 rounded-2xl bg-blue-50 flex items-center justify-center text-blue-600 mb-3">
                  <Inbox className="w-6 h-6" />
                </div>
                <h4 className="text-base font-semibold text-slate-800">No applications received yet</h4>
                <p className="text-slate-500 text-sm mt-1 max-w-sm">When candidates apply for your open roles, their applications and AI match scores will appear here.</p>
              </div>
            </div>
            
          </div>

          {/* Right Sidebar Area */}
          <div className="lg:col-span-1 space-y-6">
            
            {/* Top Candidates */}
            <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-5">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-base font-semibold text-slate-900">Top Candidate Matches</h3>
              </div>
              
              <div className="p-8 text-center flex flex-col items-center justify-center">
                <div className="w-10 h-10 rounded-xl bg-emerald-50 flex items-center justify-center text-emerald-600 mb-2">
                  <UserPlus className="w-5 h-5" />
                </div>
                <h4 className="text-sm font-semibold text-slate-800">No top matches yet</h4>
                <p className="text-slate-500 text-xs mt-1">Matched candidate dossiers will appear here as soon as applications arrive.</p>
              </div>
            </div>

            {/* Quick Actions Card */}
            <div className="bg-gradient-to-br from-slate-900 to-slate-800 rounded-2xl p-5 text-white shadow-md">
              <h4 className="text-base font-bold">Getting Started</h4>
              <p className="text-xs text-slate-300 mt-1 leading-relaxed">
                {verificationStatus === "VERIFIED"
                  ? "Your corporate profile is verified by Admin. You can post job vacancies and manage talent pipelines."
                  : "Set up your company profile and create job postings to unlock AI-verified talent pipelines."}
              </p>
              <div className="mt-4 space-y-2">
                {verificationStatus === "VERIFIED" ? (
                  <button 
                    onClick={() => navigate("/recruiter/settings?tab=company")}
                    className="w-full py-2 px-3 bg-emerald-500/20 text-emerald-300 border border-emerald-400/30 rounded-xl text-xs font-semibold flex items-center justify-between transition-colors"
                  >
                    <span className="flex items-center gap-1.5">✓ Company Profile Verified</span>
                    <ChevronRight className="w-3.5 h-3.5" />
                  </button>
                ) : verificationStatus === "PENDING" ? (
                  <button 
                    onClick={() => navigate("/recruiter/settings?tab=company")}
                    className="w-full py-2 px-3 bg-amber-500/20 text-amber-300 border border-amber-400/30 rounded-xl text-xs font-semibold flex items-center justify-between transition-colors"
                  >
                    <span>⏳ Profile Pending Admin Review</span>
                    <ChevronRight className="w-3.5 h-3.5" />
                  </button>
                ) : (
                  <button 
                    onClick={() => navigate("/recruiter/settings?tab=company")}
                    className="w-full py-2 px-3 bg-white/10 hover:bg-white/20 text-white rounded-xl text-xs font-semibold flex items-center justify-between transition-colors"
                  >
                    <span>Complete Company Profile</span>
                    <ChevronRight className="w-3.5 h-3.5" />
                  </button>
                )}

                <button 
                  onClick={() => navigate("/recruiter/post-job")}
                  className="w-full py-2 px-3 bg-[#5e17eb] hover:bg-[#4b12bc] text-white rounded-xl text-xs font-semibold flex items-center justify-between transition-colors"
                >
                  Create Job Posting <ChevronRight className="w-3.5 h-3.5" />
                </button>
              </div>
            </div>

          </div>
        </div>
      </div>
    </RecruiterLayout>
  );
};

export default RecruiterDashboard;
