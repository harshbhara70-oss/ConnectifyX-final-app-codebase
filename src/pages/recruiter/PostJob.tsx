import { useState } from "react";
import RecruiterLayout from "../../components/recruiter/RecruiterLayout";
import { pushRecruiterNotification } from "../../utils/recruiterNotifications";
import {
  ChevronRight,
  Bold,
  Italic,
  Underline,
  Link as LinkIcon,
  List,
  ListOrdered,
  MapPin,
  Calendar,
  Briefcase,
  Plus,
  X,
  ToggleLeft,
  ToggleRight,
  IndianRupee,
  AlertTriangle,
  CheckCircle2
} from "lucide-react";
import { cn } from "../../lib/utils";
import { useNavigate } from "react-router-dom";

const PostJob = () => {
  const navigate = useNavigate();

  // Form State
  const [jobTitle, setJobTitle] = useState("");
  const [jobTitleError, setJobTitleError] = useState("");
  const [jobDescription, setJobDescription] = useState("");
  const [jobType, setJobType] = useState("Full-time Permanent");
  const [isRemote, setIsRemote] = useState(false);
  const [location, setLocation] = useState("");
  const [salaryMin, setSalaryMin] = useState("");
  const [salaryMax, setSalaryMax] = useState("");
  const [salaryCurrency, setSalaryCurrency] = useState("LPA");
  const [publishImmediately, setPublishImmediately] = useState(true);
  const [eligibilityToggle, setEligibilityToggle] = useState("PERCENTAGES");
  const [skills, setSkills] = useState<string[]>([]);
  const [newSkill, setNewSkill] = useState("");
  
  const [departments, setDepartments] = useState<any[]>([]);

  // Submit and Validation state
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [isSubmitted, setIsSubmitted] = useState(false);

  // Job Title Change Handler: Strict NO NUMBERS rule
  const handleJobTitleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const rawValue = e.target.value;
    // Check if user tried typing numbers
    if (/[0-9]/.test(rawValue)) {
      setJobTitleError("Numbers are not allowed in Job Title");
    } else {
      setJobTitleError("");
    }
    // Disallow and strip any numeric digits automatically
    const cleanedValue = rawValue.replace(/[0-9]/g, "");
    setJobTitle(cleanedValue);
  };

  const addSkill = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === "Enter" && newSkill.trim() !== "") {
      e.preventDefault();
      setSkills([...skills, newSkill.trim()]);
      setNewSkill("");
    }
  };

  const removeSkill = (indexToRemove: number) => {
    setSkills(skills.filter((_, index) => index !== indexToRemove));
  };

  const addRow = () => {
    setDepartments([
      ...departments,
      { id: Date.now(), institution: "", department: "", requirement: "" }
    ]);
  };

  const validateForm = () => {
    const newErrors: Record<string, string> = {};
    if (!jobTitle.trim()) {
      newErrors.jobTitle = "Job Title is required";
    }
    if (!jobDescription.trim()) {
      newErrors.jobDescription = "Job Description is required";
    }
    if (!isRemote && !location.trim()) {
      newErrors.location = "Office Location is required for non-remote roles";
    }
    if (!salaryMin) {
      newErrors.salaryMin = "Minimum salary is required";
    }
    if (!salaryMax) {
      newErrors.salaryMax = "Maximum salary is required";
    }
    if (skills.length === 0) {
      newErrors.skills = "At least one required skill must be added";
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handlePublish = (asDraft = false) => {
    if (!asDraft && !validateForm()) {
      return;
    }

    const newJob = {
      id: Date.now(),
      title: jobTitle.trim(),
      description: jobDescription.trim(),
      jobType,
      isRemote,
      location: isRemote ? "Remote" : location.trim(),
      salaryMin,
      salaryMax,
      salaryCurrency,
      skills,
      departments,
      status: asDraft ? "DRAFT" : "ACTIVE",
      createdAt: new Date().toLocaleDateString("en-US", { month: "short", day: "2-digit", year: "numeric" }),
      applicantsCount: 0,
      inReviewCount: 0,
      hiredCount: 0
    };

    try {
      const existing = JSON.parse(localStorage.getItem("c2c_recruiter_jobs") || "[]");
      localStorage.setItem("c2c_recruiter_jobs", JSON.stringify([newJob, ...existing]));
      
      pushRecruiterNotification(
        asDraft ? "Job Draft Saved" : "New Job Vacancy Published",
        asDraft 
          ? `Draft created for "${jobTitle.trim()}".` 
          : `🎉 New job "${jobTitle.trim()}" published for candidate applications.`,
        "info"
      );
    } catch (e) {
      console.error("Error saving job to localStorage", e);
    }

    setIsSubmitted(true);
    setTimeout(() => {
      navigate("/recruiter/my-postings");
    }, 1200);
  };

  return (
    <RecruiterLayout 
      title="Post a New Job" 
      subtitle="Define the role, requirements, and reach top talent instantly."
      sidebarHighlight="/recruiter/post-job"
    >
      <div className="max-w-6xl mx-auto pb-12">
        {/* Header Section */}
        <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-6 gap-4">
          <div className="flex items-center text-sm font-medium text-[var(--c2c-muted)]">
            <span onClick={() => navigate("/recruiter/my-postings")} className="hover:text-[var(--c2c-primary)] cursor-pointer">Postings</span>
            <ChevronRight className="w-4 h-4 mx-2" />
            <span className="text-[var(--c2c-text)] font-semibold">Create New Job</span>
          </div>
          <div className="flex items-center gap-3">
            <button 
              onClick={() => handlePublish(true)}
              className="px-4 py-2.5 rounded-xl font-semibold text-[var(--c2c-primary)] bg-white border border-[var(--c2c-border-strong)] hover:bg-slate-50 transition-colors text-sm shadow-sm"
            >
              Save as Draft
            </button>
            <button 
              onClick={() => handlePublish(false)}
              className="px-5 py-2.5 rounded-xl font-semibold text-white bg-[var(--c2c-primary)] hover:bg-[var(--c2c-primary-dark)] transition-colors text-sm shadow-md hover:shadow-lg"
            >
              Publish Job
            </button>
          </div>
        </div>

        {isSubmitted && (
          <div className="mb-6 p-4 bg-emerald-50 border border-emerald-200 rounded-2xl flex items-center gap-3 text-emerald-800 text-sm font-semibold">
            <CheckCircle2 className="w-5 h-5 text-emerald-600 shrink-0" />
            Job posting submitted successfully! Redirecting to postings dashboard...
          </div>
        )}

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Left Column — Role Information */}
          <div className="lg:col-span-2 space-y-8">
            <div className="bg-white rounded-2xl border border-[var(--c2c-border)] p-6 shadow-sm">
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-xl font-bold text-[var(--c2c-text)]">Role Information</h2>
                <span className="text-xs text-[var(--c2c-muted)]"><span className="text-rose-500 font-bold">*</span> Mandatory fields</span>
              </div>
              
              <div className="space-y-6">
                {/* Job Title Field with Strict NO NUMBERS Rule */}
                <div>
                  <label className="block text-sm font-semibold text-[var(--c2c-text)] mb-2">
                    Job Title <span className="text-rose-500">*</span>
                  </label>
                  <input 
                    type="text" 
                    value={jobTitle}
                    onChange={handleJobTitleChange}
                    placeholder="e.g. Senior Full Stack Engineer (Letters only)" 
                    className={cn(
                      "w-full px-4 py-3 rounded-xl border focus:outline-none focus:ring-2 transition-all font-medium",
                      jobTitleError || errors.jobTitle
                        ? "border-rose-400 focus:ring-rose-500/20 bg-rose-50/20"
                        : "border-[var(--c2c-border-strong)] focus:ring-[var(--c2c-primary)]/20 focus:border-[var(--c2c-primary)]"
                    )}
                  />
                  {jobTitleError && (
                    <p className="mt-1.5 text-xs text-rose-600 font-semibold flex items-center gap-1">
                      <AlertTriangle className="w-3.5 h-3.5" /> {jobTitleError}
                    </p>
                  )}
                  {errors.jobTitle && !jobTitleError && (
                    <p className="mt-1.5 text-xs text-rose-600 font-semibold">{errors.jobTitle}</p>
                  )}
                  <p className="mt-1 text-[11px] text-[var(--c2c-muted)]">Numbers (0-9) are strictly prohibited in Job Title field.</p>
                </div>

                {/* Job Description Field */}
                <div>
                  <label className="block text-sm font-semibold text-[var(--c2c-text)] mb-2">
                    Job Description <span className="text-rose-500">*</span>
                  </label>
                  <div className={cn(
                    "border rounded-xl overflow-hidden focus-within:ring-2 transition-all",
                    errors.jobDescription
                      ? "border-rose-400 focus-within:ring-rose-500/20"
                      : "border-[var(--c2c-border-strong)] focus-within:ring-[var(--c2c-primary)]/20"
                  )}>
                    <div className="bg-slate-50 border-b border-slate-200 px-3 py-2 flex items-center gap-2">
                      <button type="button" className="p-1.5 hover:bg-slate-200 rounded text-[var(--c2c-muted)]"><Bold className="w-4 h-4" /></button>
                      <button type="button" className="p-1.5 hover:bg-slate-200 rounded text-[var(--c2c-muted)]"><Italic className="w-4 h-4" /></button>
                      <button type="button" className="p-1.5 hover:bg-slate-200 rounded text-[var(--c2c-muted)]"><Underline className="w-4 h-4" /></button>
                      <div className="w-px h-5 bg-slate-300 mx-1"></div>
                      <button type="button" className="p-1.5 hover:bg-slate-200 rounded text-[var(--c2c-muted)]"><LinkIcon className="w-4 h-4" /></button>
                      <button type="button" className="p-1.5 hover:bg-slate-200 rounded text-[var(--c2c-muted)]"><List className="w-4 h-4" /></button>
                      <button type="button" className="p-1.5 hover:bg-slate-200 rounded text-[var(--c2c-muted)]"><ListOrdered className="w-4 h-4" /></button>
                    </div>
                    <textarea 
                      value={jobDescription}
                      onChange={(e) => setJobDescription(e.target.value)}
                      placeholder="Describe the responsibilities, daily tasks, key requirements, and team dynamics..."
                      className="w-full px-4 py-3 min-h-[160px] focus:outline-none resize-y text-slate-800 text-sm leading-relaxed"
                    ></textarea>
                  </div>
                  {errors.jobDescription && (
                    <p className="mt-1.5 text-xs text-rose-600 font-semibold">{errors.jobDescription}</p>
                  )}
                </div>

                {/* Job Type & Location */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <div className="flex justify-between items-center mb-2">
                      <label className="block text-sm font-semibold text-[var(--c2c-text)]">
                        Job Type <span className="text-rose-500">*</span>
                      </label>
                      <div className="flex items-center gap-2 cursor-pointer select-none" onClick={() => setIsRemote(!isRemote)}>
                        <span className="text-xs text-[var(--c2c-muted)] font-semibold">Remote</span>
                        {isRemote ? 
                          <ToggleRight className="w-6 h-6 text-[var(--c2c-primary)]" /> : 
                          <ToggleLeft className="w-6 h-6 text-[var(--c2c-muted)]" />
                        }
                      </div>
                    </div>
                    <select 
                      value={jobType}
                      onChange={(e) => setJobType(e.target.value)}
                      className="w-full px-4 py-3 rounded-xl border border-[var(--c2c-border-strong)] focus:outline-none focus:ring-2 focus:ring-[var(--c2c-primary)]/20 bg-white font-medium text-slate-800 text-sm"
                    >
                      <option>Full-time Permanent</option>
                      <option>Part-time</option>
                      <option>Contract</option>
                      <option>Internship</option>
                    </select>
                  </div>

                  <div>
                    <label className="block text-sm font-semibold text-[var(--c2c-text)] mb-2">
                      Office Location {!isRemote && <span className="text-rose-500">*</span>}
                    </label>
                    <div className="relative">
                      <MapPin className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[var(--c2c-muted)]" />
                      <input 
                        type="text" 
                        value={location}
                        onChange={(e) => setLocation(e.target.value.replace(/[0-9]/g, ""))}
                        placeholder={isRemote ? "Remote Position" : "City, Country (e.g. Bangalore, India)"} 
                        className={cn(
                          "w-full pl-10 pr-4 py-3 rounded-xl border focus:outline-none focus:ring-2 transition-all font-medium text-sm",
                          errors.location
                            ? "border-rose-400 focus:ring-rose-500/20"
                            : "border-[var(--c2c-border-strong)] focus:ring-[var(--c2c-primary)]/20"
                        )}
                        disabled={isRemote}
                      />
                    </div>
                    {errors.location && (
                      <p className="mt-1.5 text-xs text-rose-600 font-semibold">{errors.location}</p>
                    )}
                  </div>
                </div>

                {/* Salary Range */}
                <div>
                  <label className="block text-sm font-semibold text-[var(--c2c-text)] mb-2">
                    Salary Range (Annual) <span className="text-rose-500">*</span>
                  </label>
                  <div className="flex items-center gap-3">
                    <div className="relative flex-1">
                      <IndianRupee className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[var(--c2c-muted)]" />
                      <input 
                        type="number" 
                        value={salaryMin}
                        onChange={(e) => setSalaryMin(e.target.value)}
                        placeholder="Min" 
                        className="w-full pl-9 pr-3 py-3 rounded-xl border border-[var(--c2c-border-strong)] focus:outline-none focus:ring-2 focus:ring-[var(--c2c-primary)]/20 text-sm font-medium"
                      />
                    </div>
                    <span className="text-[var(--c2c-muted)] font-bold text-xs">TO</span>
                    <div className="relative flex-1">
                      <IndianRupee className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[var(--c2c-muted)]" />
                      <input 
                        type="number" 
                        value={salaryMax}
                        onChange={(e) => setSalaryMax(e.target.value)}
                        placeholder="Max" 
                        className="w-full pl-9 pr-3 py-3 rounded-xl border border-[var(--c2c-border-strong)] focus:outline-none focus:ring-2 focus:ring-[var(--c2c-primary)]/20 text-sm font-medium"
                      />
                    </div>
                    <select 
                      value={salaryCurrency}
                      onChange={(e) => setSalaryCurrency(e.target.value)}
                      className="px-4 py-3 rounded-xl border border-[var(--c2c-border-strong)] focus:outline-none focus:ring-2 focus:ring-[var(--c2c-primary)]/20 bg-white font-semibold text-sm"
                    >
                      <option>LPA</option>
                      <option>INR</option>
                    </select>
                  </div>
                  {(errors.salaryMin || errors.salaryMax) && (
                    <p className="mt-1.5 text-xs text-rose-600 font-semibold">Please specify both minimum and maximum salary range.</p>
                  )}
                </div>
              </div>
            </div>

            {/* Required Skills Section */}
            <div className="bg-white rounded-2xl border border-[var(--c2c-border)] p-6 shadow-sm">
              <div className="flex items-center justify-between mb-4">
                <h2 className="text-xl font-bold text-[var(--c2c-text)]">
                  Required Skills <span className="text-rose-500">*</span>
                </h2>
                <span className="text-xs text-[var(--c2c-muted)]">Press Enter to add skills</span>
              </div>
              
              <div className="flex flex-wrap gap-2 mb-4">
                {skills.map((skill, idx) => (
                  <span key={idx} className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-[var(--c2c-primary)]/10 text-[var(--c2c-primary)] font-semibold text-xs border border-[var(--c2c-primary)]/20">
                    {skill}
                    <button type="button" onClick={() => removeSkill(idx)} className="hover:text-[var(--c2c-accent)] transition-colors"><X className="w-3.5 h-3.5" /></button>
                  </span>
                ))}
              </div>
              <div className="relative flex items-center">
                <input 
                  type="text" 
                  value={newSkill}
                  onChange={(e) => setNewSkill(e.target.value)}
                  onKeyDown={addSkill}
                  placeholder="Type a skill (e.g. TypeScript, Docker) and press Enter..." 
                  className="w-full pl-4 pr-24 py-3 rounded-xl border border-[var(--c2c-border-strong)] focus:outline-none focus:ring-2 focus:ring-[var(--c2c-primary)]/20 text-sm"
                />
                <button 
                  type="button"
                  onClick={() => {
                    if (newSkill.trim()) {
                      setSkills([...skills, newSkill.trim()]);
                      setNewSkill("");
                    }
                  }}
                  className="absolute right-2 flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-bold text-white bg-[var(--c2c-primary)] hover:bg-[var(--c2c-primary-dark)] transition-colors shadow-sm"
                >
                  <Plus className="w-3.5 h-3.5" /> Add
                </button>
              </div>
              {errors.skills && (
                <p className="mt-1.5 text-xs text-rose-600 font-semibold">{errors.skills}</p>
              )}
            </div>

            {/* Eligibility & Departments */}
            <div className="bg-white rounded-2xl border border-[var(--c2c-border)] p-6 shadow-sm">
              <div className="flex justify-between items-center mb-6">
                <h2 className="text-xl font-bold text-[var(--c2c-text)]">Eligibility Criteria</h2>
                <button 
                  type="button"
                  onClick={addRow}
                  className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-semibold text-[var(--c2c-primary)] bg-[var(--c2c-primary)]/10 hover:bg-[var(--c2c-primary)]/20 transition-colors"
                >
                  <Plus className="w-3.5 h-3.5" /> Add Rule
                </button>
              </div>

              <div className="space-y-4">
                {departments.length > 0 ? (
                  departments.map((dep, index) => (
                    <div key={dep.id} className="grid grid-cols-1 md:grid-cols-3 gap-3 p-3 bg-slate-50 rounded-xl border border-slate-200">
                      <div>
                        <label className="block text-[11px] font-semibold text-[var(--c2c-muted)] uppercase mb-1">Institution Tier</label>
                        <input 
                          type="text"
                          defaultValue={dep.institution}
                          placeholder="e.g. Tier 1 / IIT / NIT"
                          className="w-full px-3 py-2 text-xs font-medium rounded-lg border border-slate-300 bg-white"
                        />
                      </div>
                      <div>
                        <label className="block text-[11px] font-semibold text-[var(--c2c-muted)] uppercase mb-1">Department</label>
                        <input 
                          type="text"
                          defaultValue={dep.department}
                          placeholder="e.g. Computer Science"
                          className="w-full px-3 py-2 text-xs font-medium rounded-lg border border-slate-300 bg-white"
                        />
                      </div>
                      <div>
                        <label className="block text-[11px] font-semibold text-[var(--c2c-muted)] uppercase mb-1">Min Score / GPA</label>
                        <input 
                          type="text"
                          defaultValue={dep.requirement}
                          placeholder="e.g. 60% or 7.0 CGPA"
                          className="w-full px-3 py-2 text-xs font-medium rounded-lg border border-slate-300 bg-white"
                        />
                      </div>
                    </div>
                  ))
                ) : (
                  <div className="p-6 border-2 border-dashed border-slate-200 rounded-xl text-center">
                    <p className="text-xs text-slate-500 font-medium mb-2">No eligibility criteria rules added yet.</p>
                    <button 
                      type="button"
                      onClick={addRow}
                      className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-semibold text-[#5e17eb] bg-purple-50 hover:bg-purple-100 transition-colors border border-purple-200"
                    >
                      <Plus className="w-3.5 h-3.5" /> Add First Rule
                    </button>
                  </div>
                )}
              </div>
            </div>

          </div>

          {/* Right Column — Instant Preview */}
          <div className="lg:col-span-1 space-y-6">
            <div className="bg-white rounded-2xl border border-[var(--c2c-border)] p-6 shadow-sm sticky top-24">
              <h3 className="text-base font-bold text-[var(--c2c-text)] mb-4 flex items-center justify-between">
                Instant Card Preview
                <span className="px-2 py-0.5 rounded-full text-[10px] font-extrabold bg-purple-50 text-[var(--c2c-primary)] border border-purple-100">
                  LIVE PREVIEW
                </span>
              </h3>

              <div className="p-4 rounded-xl border border-slate-200 bg-gradient-to-br from-slate-50 to-white shadow-sm space-y-3">
                <div className="flex items-center gap-2">
                  <div className="w-8 h-8 rounded-lg bg-[var(--c2c-primary)] text-white font-bold flex items-center justify-center text-xs">
                    C2C
                  </div>
                  <div>
                    <h4 className="font-bold text-slate-900 text-sm truncate">
                      {jobTitle || "Job Title Preview"}
                    </h4>
                    <p className="text-[11px] text-slate-500 font-medium">{jobType} • {isRemote ? "Remote" : (location || "Location")}</p>
                  </div>
                </div>

                <div className="text-xs text-slate-600 line-clamp-3">
                  {jobDescription || "Job description excerpt will appear here as you type..."}
                </div>

                <div className="flex flex-wrap gap-1 pt-1">
                  {skills.slice(0, 4).map((s, i) => (
                    <span key={i} className="px-2 py-0.5 rounded-md bg-purple-50 text-[#5e17eb] text-[10px] font-semibold">
                      {s}
                    </span>
                  ))}
                </div>

                <div className="pt-3 border-t border-slate-100 flex items-center justify-between text-xs font-semibold text-slate-700">
                  <span>Salary</span>
                  <span className="text-[var(--c2c-primary)]">
                    {salaryMin && salaryMax ? `₹${salaryMin} - ₹${salaryMax} ${salaryCurrency}` : "₹ Salary Range"}
                  </span>
                </div>
              </div>

              <div className="mt-4 pt-4 border-t border-slate-100 text-xs text-[var(--c2c-muted)]">
                Candidates will see this preview card in their job search feed.
              </div>
            </div>
          </div>
        </div>
      </div>
    </RecruiterLayout>
  );
};

export default PostJob;
