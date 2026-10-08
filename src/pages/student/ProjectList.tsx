import { useMemo, useState } from "react";
import { useAuth } from "../../context/AuthContext";
import StudentLayout from "../../components/student/StudentLayout";
import type { StudentSidebarIconName } from "../../components/student/StudentSidebar";

type IconName =
  | "dashboard" | "user-check" | "briefcase" | "clipboard" | "building"
  | "bell" | "award" | "settings" | "resume" | "map" | "plus" | "search"
  | "sparkles" | "check" | "alert" | "target" | "chart" | "clock" | "edit"
  | "trash" | "arrow-right" | "close" | "layers" | "megaphone";

const Icon = ({ name, className = "h-4 w-4" }: { name: IconName; className?: string }) => {
  const paths: Record<IconName, React.ReactNode> = {
    dashboard: <><rect x="3" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="3" width="7" height="7" rx="1.5"/><rect x="3" y="14" width="7" height="7" rx="1.5"/><rect x="14" y="14" width="7" height="7" rx="1.5"/></>,
    "user-check": <><circle cx="9" cy="8" r="4"/><path d="M3 21v-2a5 5 0 0 1 5-5h2"/><path d="m15 16 2 2 4-5"/></>,
    briefcase: <><rect x="3" y="7" width="18" height="13" rx="2"/><path d="M8 7V5a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2M3 12h18"/></>,
    clipboard: <><rect x="5" y="4" width="14" height="17" rx="2"/><path d="M9 4V2h6v2M9 10h6M9 14h6M9 18h4"/></>,
    building: <><path d="M5 21V5a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v16M3 21h18"/><path d="M9 7h1M14 7h1M9 11h1M14 11h1M9 15h1M14 15h1"/></>,
    bell: <><path d="M18 9a6 6 0 0 0-12 0c0 7-3 7-3 7h18s-3 0-3-7"/><path d="M10 20a2 2 0 0 0 4 0"/></>,
    award: <><circle cx="12" cy="8" r="5"/><path d="m9 12.5-1 8 4-2 4 2-1-8"/></>,
    settings: <><circle cx="12" cy="12" r="3"/><path d="M19 12a7 7 0 0 0-.1-1.2l2-1.5-2-3.5-2.4 1a7.5 7.5 0 0 0-2-1.2L14.2 3H9.8L9.5 5.6a7.5 7.5 0 0 0-2 1.2l-2.4-1-2 3.5 2 1.5A7 7 0 0 0 5 12c0 .4 0 .8.1 1.2l-2 1.5 2 3.5 2.4-1a7.5 7.5 0 0 0 2 1.2l.3 2.6h4.4l.3-2.6a7.5 7.5 0 0 0 2-1.2l2.4 1 2-3.5-2-1.5c.1-.4.1-.8.1-1.2Z"/></>,
    resume: <><path d="M6 3h9l5 5v13H6a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2Z"/><path d="M14 3v5h5M8 13h8M8 17h6"/></>,
    map: <><path d="m4 6 6-3 4 3 6-3v15l-6 3-4-3-6 3V6Z"/><path d="M10 3v15M14 6v15"/></>,
    plus: <path d="M12 5v14M5 12h14"/>,
    search: <><circle cx="11" cy="11" r="7"/><path d="m16 16 4 4"/></>,
    sparkles: <><path d="M12 3 10.5 8.5 5 10l5.5 1.5L12 17l1.5-5.5L19 10l-5.5-1.5L12 3Z"/><path d="M5 17v4M3 19h4M19 3v3M17.5 4.5h3"/></>,
    check: <path d="m5 12 4 4L19 6"/>,
    alert: <><path d="M12 4 3.5 19h17L12 4Z"/><path d="M12 9v4M12 16h.01"/></>,
    target: <><circle cx="12" cy="12" r="8"/><circle cx="12" cy="12" r="4"/><path d="M12 2v3M12 19v3M2 12h3M19 12h3"/></>,
    chart: <><path d="M4 19V5M4 19h16M8 16v-5M12 16V8M16 16v-7"/></>,
    clock: <><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></>,
    edit: <><path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L8 18l-4 1 1-4Z"/></>,
    trash: <><path d="M4 7h16M10 11v6M14 11v6M9 7V4h6v3M6 7l1 14h10l1-14"/></>,
    "arrow-right": <><path d="M5 12h14"/><path d="m13 6 6 6-6 6"/></>,
    close: <><path d="M18 6 6 18M6 6l12 12"/></>,
    layers: <><path d="m12 3 9 5-9 5-9-5 9-5Z"/><path d="m3 12 9 5 9-5M3 16l9 5 9-5"/></>,
    megaphone: <><path d="m3 11 16-5v12L3 13v-2Z"/><path d="M19 9v6"/><path d="M7 14.5 8.5 20H12l-1.5-5"/></>,
  };

  return <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className={className} aria-hidden="true">{paths[name]}</svg>;
};

type Project = {
  id: string;
  title: string;
  description: string;
  techStack: string[];
  category: string;
  status: "Completed" | "In Progress";
};

type Job = {
  id: string;
  company: string;
  role: string;
  requiredSkills: string[];
  description: string;
};

const projects: Project[] = [
  { id: "p1", title: "AI Fraud Detection System", description: "Machine learning system for detecting fraudulent transactions with an analytics dashboard.", techStack: ["Python", "Machine Learning", "SQL", "Power BI"], category: "AI / ML", status: "Completed" },
  { id: "p2", title: "Verbalystic", description: "Real-time AI speech analysis application for speech and transcript analysis.", techStack: ["React", "Next.js", "FastAPI", "Python", "AI"], category: "AI / Full Stack", status: "Completed" },
  { id: "p3", title: "RegLens AI", description: "AI compliance assistant that retrieves regulatory clauses and generates compliance analysis.", techStack: ["FastAPI", "Groq", "Python", "Qdrant"], category: "AI / ML", status: "In Progress" },
];

const jobs: Job[] = [
  { id: "j1", company: "TechNova", role: "AI / ML Engineer", requiredSkills: ["Python", "Machine Learning", "SQL", "FastAPI", "React", "LLM"], description: "Build and deploy machine learning systems, AI APIs and data-driven products." },
  { id: "j2", company: "DataSphere", role: "Data Analyst", requiredSkills: ["Python", "SQL", "Power BI", "Excel", "Statistics"], description: "Analyze business data, create dashboards and communicate actionable insights." },
  { id: "j3", company: "CloudWorks", role: "Full Stack Developer", requiredSkills: ["React", "TypeScript", "Node.js", "SQL", "REST APIs"], description: "Build responsive web applications and scalable backend services." },
];


const sidebarItems: Array<{
  label: string;
  icon: StudentSidebarIconName;
  route: string;
  badge?: number;
}> = [
  {
    label: "Dashboard",
    icon: "dashboard",
    route: "/student-dashboard",
  },
  {
    label: "My Profile",
    icon: "user-check",
    route: "/student/profile",
  },
  {
    label: "My Projects",
    icon: "briefcase",
    route: "/student/projects",
  },
  {
    label: "Applications",
    icon: "clipboard",
    route: "/student/applications",
    badge: 2,
  },
  {
    label: "Placement Prep",
    icon: "building",
    route: "/student/placementprep",
  },
  {
    label: "Notifications",
    icon: "bell",
    route: "/student/notifications",
    badge: 3,
  },
  {
    label: "Certificates",
    icon: "award",
    route: "/student/certificates",
  },
  {
    label: "Settings",
    icon: "settings",
    route: "/student/settings",
  },
  {
    label: "AI Resume",
    icon: "resume",
    route: "/student/ai-resume",
  },
  {
    label: "Career Roadmap",
    icon: "map",
    route: "/student/roadmap",
  },
  {
    label: "Career Updates",
    icon: "megaphone",
    route: "/student/broadcast",
  },
];

const analyze = (project: Project, job: Job) => {
  const normalized = project.techStack.map((s) => s.toLowerCase());
  const matched = job.requiredSkills.filter((s) => normalized.includes(s.toLowerCase()));
  const missing = job.requiredSkills.filter((s) => !normalized.includes(s.toLowerCase()));
  return { matched, missing, score: Math.round((matched.length / job.requiredSkills.length) * 100) };
};

const StudentProjects = () => {
  const { currentUser } = useAuth();
  const fullName = currentUser?.fullName || currentUser?.name || "Student";
  const [selectedProjectId, setSelectedProjectId] = useState(projects[0].id);
  const [selectedJobId, setSelectedJobId] = useState(jobs[0].id);
  const [query, setQuery] = useState("");
  const [showCreate, setShowCreate] = useState(false);
  const [toast, setToast] = useState("");

  const selectedProject = projects.find((p) => p.id === selectedProjectId) || projects[0];
  const selectedJob = jobs.find((j) => j.id === selectedJobId) || jobs[0];
  const analysis = useMemo(() => analyze(selectedProject, selectedJob), [selectedProject, selectedJob]);

  const filteredProjects = projects.filter((p) =>
    `${p.title} ${p.category} ${p.techStack.join(" ")}`.toLowerCase().includes(query.toLowerCase()),
  );

  const notify = (message: string) => {
    setToast(message);
    window.setTimeout(() => setToast(""), 2500);
  };

  return (
    <StudentLayout
      sidebarItems={sidebarItems}
      sidebarHighlight="My Projects"
      userSummary={{ fullName, role: "Student", status: "Placement track active" }}
      stats={{ label: "My projects", value: String(projects.length), subtitle: "Portfolio projects", accent: "AI analysis" }}
    >
      <main className="min-w-0 space-y-6">

        <section className="relative overflow-hidden rounded-3xl border border-[#e8e0ed] bg-white p-6 shadow-sm sm:p-8">
          <div className="absolute -right-20 -top-20 h-52 w-52 rounded-full bg-[#5400D6]/10 blur-3xl" />
          <div className="relative flex flex-col gap-6 lg:flex-row lg:items-end lg:justify-between">
            <div className="max-w-2xl">
              <span className="inline-flex items-center gap-2 rounded-full bg-[#5400D6]/10 px-3 py-1.5 text-xs font-bold text-[#5400D6]">
                <Icon name="sparkles" className="h-3.5 w-3.5" />
                AI-powered project analysis
              </span>
              <h1 className="mt-4 text-3xl font-black tracking-tight text-slate-900 sm:text-4xl">My Projects</h1>
              <p className="mt-3 text-sm leading-6 text-slate-500 sm:text-base">
                Showcase the projects you have built and see how compatible your skills are with a target job.
              </p>
            </div>
            <button type="button" onClick={() => setShowCreate(true)} className="inline-flex items-center justify-center gap-2 rounded-xl bg-[#5400D6] px-5 py-3 text-sm font-bold text-white hover:bg-[#4500ad]">
              <Icon name="plus" className="h-4 w-4" />
              Add Project
            </button>
          </div>
        </section>

        <section className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
          {[
            ["My Projects", projects.length, "briefcase"],
            ["Completed", projects.filter((p) => p.status === "Completed").length, "check"],
            ["In Progress", projects.filter((p) => p.status === "In Progress").length, "clock"],
            ["Current Match", `${analysis.score}%`, "target"],
          ].map(([label, value, icon]) => (
            <article key={String(label)} className="rounded-2xl border border-[#e8e0ed] bg-white p-5 shadow-sm">
              <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-[#5400D6]/10 text-[#5400D6]">
                <Icon name={icon as IconName} className="h-5 w-5" />
              </div>
              <p className="mt-4 text-xs font-bold uppercase tracking-wider text-slate-400">{label}</p>
              <p className="mt-1 text-3xl font-black text-slate-900">{value}</p>
            </article>
          ))}
        </section>

        <section className="grid gap-5 xl:grid-cols-[minmax(0,0.95fr)_minmax(420px,1.05fr)]">

          <div className="min-w-0 rounded-2xl border border-[#e8e0ed] bg-white shadow-sm">
            <div className="border-b border-slate-100 p-5 sm:p-6">
              <h2 className="text-lg font-black text-slate-900">Projects I have built</h2>
              <p className="mt-1 text-xs text-slate-500">Select a project to view its job compatibility analysis.</p>
              <div className="relative mt-4">
                <Icon name="search" className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
                <input value={query} onChange={(e) => setQuery(e.target.value)} placeholder="Search your projects..." className="h-10 w-full rounded-xl border border-slate-200 bg-slate-50 pl-9 pr-3 text-xs outline-none focus:border-[#5400D6]/30" />
              </div>
            </div>

            <div className="space-y-3 p-4 sm:p-5">
              {filteredProjects.map((project) => {
                const active = project.id === selectedProject.id;
                return (
                  <button key={project.id} type="button" onClick={() => setSelectedProjectId(project.id)} className={`w-full rounded-2xl border p-4 text-left transition ${active ? "border-[#5400D6]/30 bg-[#5400D6]/5" : "border-slate-200 hover:border-[#5400D6]/20 hover:bg-slate-50"}`}>
                    <div className="flex items-start gap-3">
                      <div className={`flex h-11 w-11 flex-shrink-0 items-center justify-center rounded-xl ${active ? "bg-[#5400D6] text-white" : "bg-[#5400D6]/10 text-[#5400D6]"}`}>
                        <Icon name="layers" className="h-5 w-5" />
                      </div>
                      <div className="min-w-0 flex-1">
                        <div className="flex flex-wrap items-center gap-2">
                          <h3 className="text-sm font-black text-slate-900">{project.title}</h3>
                          <span className={`rounded-full px-2 py-0.5 text-[9px] font-bold ${project.status === "Completed" ? "bg-emerald-50 text-emerald-700" : "bg-amber-50 text-amber-700"}`}>{project.status}</span>
                        </div>
                        <p className="mt-1 line-clamp-2 text-xs leading-5 text-slate-500">{project.description}</p>
                        <div className="mt-3 flex flex-wrap gap-1.5">
                          {project.techStack.map((skill) => <span key={skill} className="rounded-full bg-slate-100 px-2 py-1 text-[9px] font-semibold text-slate-600">{skill}</span>)}
                        </div>
                      </div>
                      <Icon name="arrow-right" className={`mt-1 h-4 w-4 ${active ? "text-[#5400D6]" : "text-slate-300"}`} />
                    </div>
                  </button>
                );
              })}
            </div>
          </div>

          <div className="min-w-0 rounded-2xl border border-[#e8e0ed] bg-white shadow-sm">
            <div className="border-b border-slate-100 p-5 sm:p-6">
              <div className="flex items-start gap-3">
                <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-[#5400D6] text-white">
                  <Icon name="sparkles" className="h-5 w-5" />
                </div>
                <div>
                  <h2 className="text-lg font-black text-slate-900">AI Job Compatibility</h2>
                  <p className="mt-1 text-xs leading-5 text-slate-500">AI compares your selected project's technologies with the target job requirements.</p>
                </div>
              </div>

              <div className="mt-5">
                <label className="mb-2 block text-xs font-bold text-slate-500">Analyze this project for</label>
                <select value={selectedJobId} onChange={(e) => setSelectedJobId(e.target.value)} className="w-full rounded-xl border border-slate-200 bg-white px-3 py-3 text-sm font-semibold text-slate-700 outline-none focus:border-[#5400D6]/30">
                  {jobs.map((job) => <option key={job.id} value={job.id}>{job.company} — {job.role}</option>)}
                </select>
              </div>
            </div>

            <div className="space-y-5 p-5 sm:p-6">
              <div className="rounded-2xl bg-[#5400D6]/5 p-5">
                <div className="flex items-center justify-between gap-4">
                  <div>
                    <p className="text-xs font-bold uppercase tracking-wider text-slate-400">Compatibility score</p>
                    <p className="mt-1 text-4xl font-black text-[#5400D6]">{analysis.score}%</p>
                    <p className="mt-1 text-xs font-bold text-slate-600">
                      {analysis.score >= 80 ? "Strong match" : analysis.score >= 60 ? "Good match" : "Needs improvement"}
                    </p>
                  </div>
                  <div className="flex h-20 w-20 items-center justify-center rounded-full border-8 border-[#5400D6]/10">
                    <Icon name="target" className="h-7 w-7 text-[#5400D6]" />
                  </div>
                </div>
              </div>

              <div className="rounded-2xl border border-slate-200 p-4">
                <p className="text-sm font-black text-slate-900">{selectedJob.role}</p>
                <p className="mt-1 text-xs font-bold text-[#5400D6]">{selectedJob.company}</p>
                <p className="mt-2 text-xs leading-5 text-slate-500">{selectedJob.description}</p>
              </div>

              <div>
                <div className="flex items-center justify-between">
                  <h3 className="text-sm font-black text-slate-900">Matched skills</h3>
                  <span className="text-xs font-bold text-emerald-600">{analysis.matched.length} matched</span>
                </div>
                <div className="mt-3 flex flex-wrap gap-2">
                  {analysis.matched.map((skill) => (
                    <span key={skill} className="inline-flex items-center gap-1.5 rounded-full bg-emerald-50 px-2.5 py-1.5 text-[10px] font-bold text-emerald-700">
                      <Icon name="check" className="h-3 w-3" />{skill}
                    </span>
                  ))}
                </div>
              </div>

              <div>
                <div className="flex items-center justify-between">
                  <h3 className="text-sm font-black text-slate-900">Skills to improve</h3>
                  <span className="text-xs font-bold text-amber-600">{analysis.missing.length} missing</span>
                </div>
                <div className="mt-3 flex flex-wrap gap-2">
                  {analysis.missing.map((skill) => (
                    <span key={skill} className="inline-flex items-center gap-1.5 rounded-full bg-amber-50 px-2.5 py-1.5 text-[10px] font-bold text-amber-700">
                      <Icon name="alert" className="h-3 w-3" />{skill}
                    </span>
                  ))}
                </div>
              </div>

              <div className="rounded-xl border border-[#5400D6]/15 bg-[#5400D6]/5 p-4">
                <div className="flex gap-3">
                  <Icon name="sparkles" className="mt-0.5 h-4 w-4 flex-shrink-0 text-[#5400D6]" />
                  <div>
                    <p className="text-xs font-black text-slate-900">AI recommendation</p>
                    <p className="mt-1 text-xs leading-5 text-slate-600">
                      {analysis.score >= 80
                        ? "This project strongly supports the target role. Highlight these technologies in your resume and interview."
                        : analysis.score >= 60
                          ? "This project is a good foundation. Strengthen the missing skills and add measurable project outcomes."
                          : "This project has limited alignment. Build or extend a project using the missing technologies before targeting this role."}
                    </p>
                  </div>
                </div>
              </div>

              <button type="button" onClick={() => notify(`AI analysis generated for ${selectedProject.title}.`)} className="flex w-full items-center justify-center gap-2 rounded-xl bg-[#5400D6] py-3 text-sm font-bold text-white hover:bg-[#4500ad]">
                <Icon name="sparkles" className="h-4 w-4" />
                Run AI Analysis
              </button>
            </div>
          </div>
        </section>

        <section className="rounded-2xl border border-[#e8e0ed] bg-white p-5 shadow-sm sm:p-6">
          <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <h2 className="text-lg font-black text-slate-900">Selected Project</h2>
              <p className="mt-1 text-xs text-slate-500">Keep your project details updated so the AI analysis remains useful.</p>
            </div>
            <div className="flex gap-2">
              <button type="button" onClick={() => notify("Project editor opened.")} className="inline-flex items-center gap-2 rounded-lg border border-slate-200 px-3 py-2 text-xs font-bold text-slate-600 hover:bg-slate-50">
                <Icon name="edit" className="h-3.5 w-3.5" />Edit Project
              </button>
              <button type="button" onClick={() => notify("Project deletion can be connected to your backend.")} className="inline-flex items-center gap-2 rounded-lg border border-rose-100 px-3 py-2 text-xs font-bold text-rose-600 hover:bg-rose-50">
                <Icon name="trash" className="h-3.5 w-3.5" />Remove
              </button>
            </div>
          </div>
        </section>

        {showCreate && <CreateProjectModal onClose={() => setShowCreate(false)} onCreate={() => { setShowCreate(false); notify("Project added. Connect this form to your project API."); }} />}

        {toast && <div className="fixed bottom-6 right-6 z-[70] flex items-center gap-2 rounded-xl bg-slate-900 px-4 py-3 text-sm font-semibold text-white shadow-xl"><Icon name="check" className="h-4 w-4 text-emerald-400"/>{toast}</div>}
      </main>
    </StudentLayout>
  );
};

const CreateProjectModal = ({ onClose, onCreate }: { onClose: () => void; onCreate: () => void }) => (
  <div className="fixed inset-0 z-[60] flex items-center justify-center bg-slate-900/50 p-4 backdrop-blur-sm" onClick={onClose}>
    <div className="w-full max-w-lg rounded-2xl bg-white shadow-2xl" onClick={(e) => e.stopPropagation()}>
      <div className="flex items-start justify-between border-b border-slate-100 p-5">
        <div>
          <h2 className="text-lg font-black text-slate-900">Create Project</h2>
          <p className="mt-1 text-xs text-slate-500">Add a project to your student portfolio.</p>
        </div>
        <button type="button" onClick={onClose} className="rounded-lg p-2 text-slate-400 hover:bg-slate-50"><Icon name="close" className="h-4 w-4"/></button>
      </div>
      <div className="space-y-4 p-5">
        <input placeholder="Project name" className="w-full rounded-xl border border-slate-200 px-3 py-3 text-sm outline-none focus:border-[#5400D6]/30"/>
        <textarea placeholder="What did you build? What problem does it solve?" rows={4} className="w-full resize-none rounded-xl border border-slate-200 px-3 py-3 text-sm outline-none focus:border-[#5400D6]/30"/>
        <input placeholder="Technologies: Python, React, SQL..." className="w-full rounded-xl border border-slate-200 px-3 py-3 text-sm outline-none focus:border-[#5400D6]/30"/>
        <button type="button" onClick={onCreate} className="flex w-full items-center justify-center gap-2 rounded-xl bg-[#5400D6] py-3 text-sm font-bold text-white hover:bg-[#4500ad]"><Icon name="plus" className="h-4 w-4"/>Create Project</button>
      </div>
    </div>
  </div>
);

export default StudentProjects;