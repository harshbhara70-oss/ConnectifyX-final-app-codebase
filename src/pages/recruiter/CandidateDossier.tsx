import { useState } from "react";
import RecruiterLayout from "../../components/recruiter/RecruiterLayout";
import { cn } from "../../lib/utils";
import { 
  Star, MapPin, GraduationCap, Download, Share, Calendar, CheckCircle2, 
  Briefcase, Code2, Users, BrainCircuit, Activity, ChevronRight, Award, UserCheck, Search, ArrowLeft
} from "lucide-react";
import { useParams, useNavigate } from "react-router-dom";

const CandidateDossier = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [showFullTimeline, setShowFullTimeline] = useState(false);

  // If no candidate ID provided, show candidate search empty state
  if (!id) {
    return (
      <RecruiterLayout title="Candidate Intelligence Dossier" subtitle="Comprehensive view of candidate profile and analytics" sidebarHighlight="/recruiter/applications">
        <div className="bg-white rounded-2xl p-16 border border-slate-100 shadow-sm text-center flex flex-col items-center justify-center max-w-2xl mx-auto my-12">
          <div className="w-16 h-16 rounded-2xl bg-purple-50 flex items-center justify-center text-[#5e17eb] mb-4">
            <UserCheck className="w-8 h-8" />
          </div>
          <h3 className="text-xl font-bold text-slate-900">Select a Candidate</h3>
          <p className="text-slate-500 text-sm mt-1 leading-relaxed">
            Choose a candidate from your Applications list or Hiring Pipeline to view their AI-verified intelligence dossier, academic credentials, and soft skills fingerprint.
          </p>
          <button
            onClick={() => navigate("/recruiter/applications")}
            className="mt-6 inline-flex items-center gap-2 px-5 py-2.5 bg-[#5e17eb] hover:bg-[#4b12bc] text-white text-sm font-semibold rounded-xl transition-all shadow-md"
          >
            <ArrowLeft className="w-4 h-4" /> Go to Applications List
          </button>
        </div>
      </RecruiterLayout>
    );
  }

  return (
    <RecruiterLayout title="Candidate Intelligence Dossier" subtitle="Comprehensive view of candidate profile and analytics" sidebarHighlight="/recruiter/applications">
      <div className="space-y-6 max-w-6xl mx-auto pb-12">
        
        {/* Header Section */}
        <div className="bg-white rounded-2xl p-6 shadow-sm border border-[var(--c2c-border)] flex flex-col md:flex-row gap-6 items-start md:items-center">
          <div className="w-24 h-24 rounded-full bg-gradient-to-br from-[var(--c2c-primary)] to-[var(--c2c-accent)] flex items-center justify-center text-white text-3xl font-bold shrink-0 shadow-md">
            AV
          </div>
          <div className="flex-1 space-y-2">
            <div className="flex items-center gap-3">
              <h1 className="text-2xl font-bold text-[var(--c2c-text)]">Arjun Varma</h1>
              <span className="px-2 py-1 bg-[var(--c2c-success)]/10 text-[var(--c2c-success)] text-xs font-semibold rounded-full flex items-center gap-1 border border-[var(--c2c-success)]/20">
                <Award className="w-3 h-3" /> Top 2%
              </span>
            </div>
            <p className="text-lg font-medium text-[var(--c2c-text)]">Full Stack Developer</p>
            <div className="flex flex-wrap items-center gap-4 text-sm text-[var(--c2c-muted)]">
              <span className="flex items-center gap-1"><GraduationCap className="w-4 h-4" /> Stanford University</span>
              <span className="flex items-center gap-1"><MapPin className="w-4 h-4" /> San Francisco, CA</span>
              <span className="flex items-center gap-1 text-amber-500 font-medium bg-amber-50 px-2 py-0.5 rounded-md">
                <Star className="w-4 h-4 fill-amber-500" /> 4.8/5 (124 ratings)
              </span>
            </div>
          </div>
          <div className="flex flex-wrap gap-3 mt-4 md:mt-0">
            <button className="px-4 py-2 bg-[var(--c2c-primary)] hover:bg-[var(--c2c-accent)] text-white text-sm font-medium rounded-xl transition-colors shadow-sm">
              Schedule Interview
            </button>
            <button className="px-4 py-2 bg-[var(--c2c-success)] hover:bg-emerald-700 text-white text-sm font-medium rounded-xl transition-colors shadow-sm">
              Shortlist Candidate
            </button>
            <button className="p-2 border border-[var(--c2c-border-strong)] text-[var(--c2c-muted)] hover:text-[var(--c2c-primary)] rounded-xl transition-colors bg-white">
              <Download className="w-5 h-5" />
            </button>
            <button className="p-2 border border-[var(--c2c-border-strong)] text-[var(--c2c-muted)] hover:text-[var(--c2c-primary)] rounded-xl transition-colors bg-white">
              <Share className="w-5 h-5" />
            </button>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Main Content Column */}
          <div className="lg:col-span-2 space-y-6">
            
            {/* Academic Excellence */}
            <div className="bg-white rounded-2xl p-6 shadow-sm border border-[var(--c2c-border)]">
              <h2 className="text-lg font-bold text-[var(--c2c-text)] mb-4 flex items-center gap-2">
                <GraduationCap className="w-5 h-5 text-[var(--c2c-primary)]" /> Academic Excellence
              </h2>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="p-4 bg-slate-50 rounded-xl">
                  <p className="text-xs text-[var(--c2c-muted)] font-medium">University & Degree</p>
                  <p className="text-base font-bold text-[var(--c2c-text)] mt-1">Stanford University</p>
                  <p className="text-sm text-[var(--c2c-muted)]">M.S. Computer Science (2022 - 2024)</p>
                </div>
                <div className="p-4 bg-slate-50 rounded-xl">
                  <p className="text-xs text-[var(--c2c-muted)] font-medium">GPA & Rank</p>
                  <p className="text-base font-bold text-[var(--c2c-text)] mt-1">3.95 / 4.0</p>
                  <p className="text-sm text-[var(--c2c-success)] font-semibold">Top 1% Class Standing</p>
                </div>
              </div>
            </div>

            {/* Verified Experience */}
            <div className="bg-white rounded-2xl p-6 shadow-sm border border-[var(--c2c-border)]">
              <div className="flex items-center justify-between mb-4">
                <h2 className="text-lg font-bold text-[var(--c2c-text)] flex items-center gap-2">
                  <Briefcase className="w-5 h-5 text-[var(--c2c-primary)]" /> Verified Experience
                </h2>
                <button 
                  onClick={() => setShowFullTimeline(!showFullTimeline)}
                  className="text-xs font-semibold text-[var(--c2c-primary)] hover:underline"
                >
                  {showFullTimeline ? "Show Highlights" : "Full Timeline"}
                </button>
              </div>

              <div className="space-y-4">
                <div className="p-4 border border-[var(--c2c-border)] rounded-xl relative pl-6 border-l-4 border-l-[var(--c2c-primary)]">
                  <div className="flex items-center justify-between">
                    <h3 className="font-bold text-[var(--c2c-text)]">SWE Intern @ GeeksBrain</h3>
                    <span className="text-xs font-medium text-[var(--c2c-muted)]">Jun 2023 - Sep 2023</span>
                  </div>
                  <p className="text-xs text-[var(--c2c-success)] font-semibold mt-1 flex items-center gap-1">
                    <CheckCircle2 className="w-3.5 h-3.5" /> Verified Work Experience
                  </p>
                  <p className="text-sm text-[var(--c2c-muted)] mt-2">
                    Engineered distributed backend microservices handling 50k+ daily API requests with 99.9% uptime.
                  </p>
                </div>
              </div>
            </div>

          </div>

          {/* Right Sidebar Column */}
          <div className="space-y-6">
            {/* Cognitive Assessment */}
            <div className="bg-white rounded-2xl p-6 shadow-sm border border-[var(--c2c-border)] text-center">
              <div className="w-16 h-16 rounded-full bg-purple-50 text-[var(--c2c-primary)] font-extrabold text-xl flex items-center justify-center mx-auto mb-3 border border-[var(--c2c-border)]">
                98th
              </div>
              <h3 className="font-bold text-[var(--c2c-text)]">Cognitive Assessment</h3>
              <p className="text-xs text-[var(--c2c-muted)] mt-1">98th Percentile in Problem Solving & Algorithmic Thinking</p>
            </div>

            {/* Core Stack Proficiency */}
            <div className="bg-white rounded-2xl p-6 shadow-sm border border-[var(--c2c-border)] space-y-4">
              <h3 className="font-bold text-[var(--c2c-text)]">Core Stack Proficiency</h3>
              
              <div className="space-y-3 text-sm">
                <div>
                  <div className="flex justify-between text-xs font-medium mb-1">
                    <span>React.js & Next.js</span>
                    <span className="text-[var(--c2c-primary)] font-bold">95%</span>
                  </div>
                  <div className="w-full h-2 bg-slate-100 rounded-full overflow-hidden">
                    <div className="h-full bg-[var(--c2c-primary)] rounded-full" style={{ width: "95%" }}></div>
                  </div>
                </div>

                <div>
                  <div className="flex justify-between text-xs font-medium mb-1">
                    <span>PostgreSQL & Node.js</span>
                    <span className="text-[var(--c2c-primary)] font-bold">90%</span>
                  </div>
                  <div className="w-full h-2 bg-slate-100 rounded-full overflow-hidden">
                    <div className="h-full bg-[var(--c2c-primary)] rounded-full" style={{ width: "90%" }}></div>
                  </div>
                </div>

                <div>
                  <div className="flex justify-between text-xs font-medium mb-1">
                    <span>AWS Cloud & Docker</span>
                    <span className="text-[var(--c2c-primary)] font-bold">85%</span>
                  </div>
                  <div className="w-full h-2 bg-slate-100 rounded-full overflow-hidden">
                    <div className="h-full bg-[var(--c2c-primary)] rounded-full" style={{ width: "85%" }}></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

      </div>
    </RecruiterLayout>
  );
};

export default CandidateDossier;
