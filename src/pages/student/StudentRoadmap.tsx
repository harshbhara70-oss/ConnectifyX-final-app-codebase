import React, { useMemo, useState } from "react";
import StudentLayout from "../../components/student/StudentLayout";
import type { StudentSidebarIconName } from "../../components/student/StudentSidebar";

type IconName =
  | "dashboard"
  | "map"
  | "briefcase"
  | "building"
  | "file"
  | "broadcast"
  | "settings"
  | "search"
  | "bell"
  | "user"
  | "chevron-right"
  | "chevron-down"
  | "play"
  | "bookmark"
  | "book"
  | "code"
  | "lock"
  | "check"
  | "clock"
  | "edit"
  | "send"
  | "target"
  | "trophy";

const Icon = ({
  name,
  className = "h-5 w-5",
}: {
  name: IconName;
  className?: string;
}) => {
  const paths: Record<IconName, React.ReactNode> = {
    dashboard: (
      <>
        <rect x="3" y="3" width="7" height="7" rx="1.5" />
        <rect x="14" y="3" width="7" height="7" rx="1.5" />
        <rect x="3" y="14" width="7" height="7" rx="1.5" />
        <rect x="14" y="14" width="7" height="7" rx="1.5" />
      </>
    ),
    map: (
      <>
        <path d="m4 6 6-3 4 3 6-3v15l-6 3-4-3-6 3V6Z" />
        <path d="M10 3v15M14 6v15" />
      </>
    ),
    briefcase: (
      <>
        <path d="M9 7V5a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2v2" />
        <rect x="4" y="7" width="16" height="13" rx="2" />
        <path d="M4 12h16" />
      </>
    ),
    building: (
      <>
        <path d="M5 21V5a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v16" />
        <path d="M3 21h18" />
        <path d="M9 7h1M14 7h1M9 11h1M14 11h1" />
      </>
    ),
    file: (
      <>
        <path d="M14 3H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9Z" />
        <path d="M14 3v6h6M8 13h8M8 17h5" />
      </>
    ),
    broadcast: (
      <>
        <circle cx="12" cy="12" r="2" />
        <path d="M7.8 7.8a6 6 0 0 0 0 8.4M16.2 7.8a6 6 0 0 1 0 8.4" />
        <path d="M4.9 4.9a10 10 0 0 0 0 14.2M19.1 4.9a10 10 0 0 1 0 14.2" />
      </>
    ),
    settings: (
      <>
        <circle cx="12" cy="12" r="3" />
        <path d="M19 12a7.5 7.5 0 0 0-.1-1.2l2-1.5-2-3.5-2.4 1a7.5 7.5 0 0 0-2-1.2L14.2 3h-4.4l-.3 2.6a7.5 7.5 0 0 0-2 1.2l-2.4-1-2 3.5 2 1.5A7.5 7.5 0 0 0 5 12c0 .4 0 .8.1 1.2l-2 1.5 2 3.5 2.4-1a7.5 7.5 0 0 0 2 1.2l.3 2.6h4.4l.3-2.6a7.5 7.5 0 0 0 2-1.2l2.4 1 2-3.5-2-1.5c.1-.4.1-.8.1-1.2Z" />
      </>
    ),
    search: (
      <>
        <circle cx="11" cy="11" r="7" />
        <path d="m16 16 4 4" />
      </>
    ),
    bell: (
      <>
        <path d="M18 9a6 6 0 0 0-12 0c0 7-3 7-3 7h18s-3 0-3-7" />
        <path d="M10 20a2 2 0 0 0 4 0" />
      </>
    ),
    user: (
      <>
        <circle cx="12" cy="8" r="4" />
        <path d="M4 21a8 8 0 0 1 16 0" />
      </>
    ),
    "chevron-right": <path d="m9 18 6-6-6-6" />,
    "chevron-down": <path d="m6 9 6 6 6-6" />,
    play: <path d="m9 6 10 6-10 6V6Z" />,
    bookmark: (
      <path d="M6 4a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v18l-6-3-6 3V4Z" />
    ),
    book: (
      <>
        <path d="M4 5a2 2 0 0 1 2-2h9v16H6a2 2 0 0 0-2 2V5Z" />
        <path d="M15 3h3a2 2 0 0 1 2 2v14a2 2 0 0 0-2-2h-3" />
      </>
    ),
    code: (
      <>
        <path d="m8 9-4 3 4 3M16 9l4 3-4 3M14 6l-4 12" />
      </>
    ),
    lock: (
      <>
        <rect x="4" y="10" width="16" height="11" rx="2" />
        <path d="M8 10V7a4 4 0 0 1 8 0v3" />
      </>
    ),
    check: <path d="m5 12 4 4L19 6" />,
    clock: (
      <>
        <circle cx="12" cy="12" r="9" />
        <path d="M12 7v5l3 2" />
      </>
    ),
    edit: (
      <>
        <path d="m4 20 4-.9L18.5 8.6a2.1 2.1 0 0 0-3-3L5 16l-1 4Z" />
        <path d="m13.5 7.5 3 3" />
      </>
    ),
    send: (
      <>
        <path d="m22 2-11 11" />
        <path d="m22 2-7 20-4-9-9-4 20-7Z" />
      </>
    ),
    target: (
      <>
        <circle cx="12" cy="12" r="8" />
        <circle cx="12" cy="12" r="4" />
        <circle cx="12" cy="12" r="1" />
      </>
    ),
    trophy: (
      <>
        <path d="M8 21h8M12 17v4M7 4h10v5a5 5 0 0 1-10 0V4Z" />
        <path d="M7 6H4v2a4 4 0 0 0 4 4M17 6h3v2a4 4 0 0 1-4 4" />
      </>
    ),
  };

  return (
    <svg
      className={className}
      fill="none"
      stroke="currentColor"
      strokeWidth="1.8"
      strokeLinecap="round"
      strokeLinejoin="round"
      viewBox="0 0 24 24"
      aria-hidden="true"
    >
      {paths[name]}
    </svg>
  );
};

type Lesson = {
  title: string;
  description: string;
  icon: IconName;
  locked?: boolean;
  complete?: boolean;
};

type Module = {
  title: string;
  items: Lesson[];
};

type RoadmapSection = {
  id: string;
  number: string;
  title: string;
  description: string;
  kind: "video" | "practice";
};


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
const modules: Module[] = [
  {
    title: "PHASE 1 · FOUNDATIONS",
    items: [
      {
        title: "HTML5 Semantics",
        description: "Semantic structure and accessible HTML.",
        icon: "code",
        complete: true,
      },
      {
        title: "CSS3 Modern Layouts",
        description: "Modern responsive CSS layouts.",
        icon: "code",
        complete: true,
      },
      {
        title: "Responsive Design",
        description: "Build interfaces that adapt to every screen.",
        icon: "lock",
      },
    ],
  },
  {
    title: "PHASE 2 · JAVASCRIPT",
    items: [
      {
        title: "DOM Manipulation",
        description: "Interact with the browser document.",
        icon: "lock",
      },
      {
        title: "Async JS & Fetch API",
        description: "Work with asynchronous JavaScript.",
        icon: "lock",
      },
    ],
  },
  {
    title: "PHASE 3 · FRAMEWORKS",
    items: [
      {
        title: "React Fundamentals",
        description: "Build component-driven applications.",
        icon: "lock",
      },
    ],
  },
];

const sections: RoadmapSection[] = [
  {
    id: "css",
    number: "01",
    title: "Advanced CSS Grid & Flexbox",
    description: "Master high-end UI patterns and responsive structures.",
    kind: "video",
  },
  {
    id: "dom",
    number: "02",
    title: "DOM Algorithms & Logic",
    description: "Solve complex interaction problems and efficient rendering.",
    kind: "practice",
  },
];

const videoLessons = [
  {
    title: "CSS Grid Crash Course",
    subtitle: "Kevin Powell · 45 min",
  },
  {
    title: "Modern UI Layouts",
    subtitle: "Web Dev Simplified · 22 min",
  },
];

const problems = [
  {
    problem: "Virtual DOM Reconciliation Mock",
    difficulty: "Hard",
    status: "Not Started",
    action: "Solve",
  },
  {
    problem: "Event Delegation Patterns",
    difficulty: "Medium",
    status: "Attempted",
    action: "Retry",
  },
  {
    problem: "Custom Hook for Fetching",
    difficulty: "Easy",
    status: "Solved",
    action: "View Solution",
  },
];

const RoadmapSectionCard = ({
  section,
  active,
  onSelect,
}: {
  section: RoadmapSection;
  active: boolean;
  onSelect: () => void;
}) => {
  const isVideo = section.kind === "video";

  return (
    <article
      className={`rounded-2xl border bg-white transition-all ${
        active
          ? "border-purple-200 shadow-[0_12px_35px_rgba(126,34,206,0.10)]"
          : "border-slate-200 shadow-sm hover:border-purple-100 hover:shadow-md"
      }`}
    >
      <div className="p-5 sm:p-6">
        <div className="flex items-start gap-4">
          <div
            className={`flex h-11 w-11 shrink-0 items-center justify-center rounded-xl text-sm font-black ${
              active
                ? "bg-purple-700 text-white"
                : "bg-purple-50 text-purple-700"
            }`}
          >
            {section.number}
          </div>

          <div className="min-w-0 flex-1">
            <div className="flex flex-wrap items-center gap-2">
              <span className="rounded-full bg-purple-50 px-2.5 py-1 text-[10px] font-bold uppercase tracking-wide text-purple-700">
                {isVideo ? "Learn" : "Practice"}
              </span>
              {active && (
                <span className="rounded-full bg-emerald-50 px-2.5 py-1 text-[10px] font-bold text-emerald-600">
                  Current
                </span>
              )}
            </div>

            <h2 className="mt-2 text-lg font-extrabold tracking-tight text-slate-900 sm:text-xl">
              {section.title}
            </h2>
            <p className="mt-1 text-sm leading-6 text-slate-500">
              {section.description}
            </p>
          </div>

          <button
            type="button"
            onClick={onSelect}
            className="rounded-lg p-2 text-slate-400 transition hover:bg-purple-50 hover:text-purple-700"
            aria-label={`Bookmark ${section.title}`}
          >
            <Icon name="bookmark" className="h-5 w-5" />
          </button>
        </div>

        {isVideo ? (
          <div className="mt-6">
            <div className="flex gap-6 border-b border-slate-100">
              <button
                type="button"
                className="flex items-center gap-2 border-b-2 border-purple-700 pb-3 text-xs font-bold text-purple-700"
              >
                <Icon name="play" className="h-4 w-4" />
                Videos
              </button>
              <button
                type="button"
                className="flex items-center gap-2 pb-3 text-xs font-semibold text-slate-400 hover:text-slate-700"
              >
                <Icon name="file" className="h-4 w-4" />
                Documentation
              </button>
              <button
                type="button"
                className="hidden items-center gap-2 pb-3 text-xs font-semibold text-slate-400 hover:text-slate-700 sm:flex"
              >
                <Icon name="book" className="h-4 w-4" />
                Articles
              </button>
            </div>

            <div className="mt-4 grid gap-3 sm:grid-cols-2">
              {videoLessons.map((video) => (
                <button
                  key={video.title}
                  type="button"
                  onClick={onSelect}
                  className="group flex items-center gap-3 rounded-xl border border-slate-200 bg-slate-50 p-3 text-left transition hover:border-purple-200 hover:bg-purple-50"
                >
                  <span className="flex h-11 w-11 shrink-0 items-center justify-center rounded-lg bg-slate-800 text-white">
                    <Icon name="play" className="h-5 w-5" />
                  </span>
                  <span className="min-w-0">
                    <span className="block truncate text-sm font-bold text-slate-800 group-hover:text-purple-700">
                      {video.title}
                    </span>
                    <span className="mt-1 block text-xs text-slate-400">
                      {video.subtitle}
                    </span>
                  </span>
                </button>
              ))}
            </div>
          </div>
        ) : (
          <div className="mt-6 overflow-x-auto">
            <div className="min-w-[620px]">
              <div className="grid grid-cols-[2.2fr_0.8fr_1fr_auto] border-b border-slate-100 px-2 pb-3 text-[11px] font-bold uppercase tracking-wide text-slate-400">
                <span>Problem</span>
                <span>Difficulty</span>
                <span>Status</span>
                <span>Action</span>
              </div>

              <div className="divide-y divide-slate-100">
                {problems.map((problem) => (
                  <div
                    key={problem.problem}
                    className="grid grid-cols-[2.2fr_0.8fr_1fr_auto] items-center gap-3 px-2 py-4 text-sm text-slate-600"
                  >
                    <span className="font-medium text-slate-700">
                      {problem.problem}
                    </span>

                    <span
                      className={
                        problem.difficulty === "Hard"
                          ? "font-bold text-rose-500"
                          : problem.difficulty === "Medium"
                            ? "font-bold text-amber-500"
                            : "font-bold text-emerald-500"
                      }
                    >
                      {problem.difficulty}
                    </span>

                    <span className="text-slate-500">{problem.status}</span>

                    <button
                      type="button"
                      onClick={onSelect}
                      className="rounded-lg bg-purple-50 px-3 py-1.5 text-xs font-bold text-purple-700 transition hover:bg-purple-100"
                    >
                      {problem.action}
                    </button>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}
      </div>
    </article>
  );
};

const StudentRoadmap: React.FC = () => {
  const [selectedSection, setSelectedSection] = useState("css");
  const [journal, setJournal] = useState("");
  const [sidebarOpen, setSidebarOpen] = useState(true);

  const completedLessons = useMemo(
    () =>
      modules.reduce(
        (total, module) =>
          total + module.items.filter((item) => item.complete).length,
        0
      ),
    []
  );

  const totalLessons = useMemo(
    () => modules.reduce((total, module) => total + module.items.length, 0),
    []
  );

  const progress = Math.round((completedLessons / totalLessons) * 100);

  return (
    <StudentLayout
      sidebarItems={sidebarItems}
      sidebarHighlight="Explore Roadmaps"
      userSummary={{
        fullName: "Alex Chen",
        role: "Career-Ready Student",
        status: `${progress}% roadmap complete`,
      }}
      stats={{
        label: "Roadmap progress",
        value: `${progress}%`,
        subtitle: "Web Development Mastery",
        accent: "Learning",
      }}
    >
      <div className="min-h-full bg-[#faf9f8]">
        <div className="mx-auto max-w-[1500px] px-4 py-5 sm:px-6 lg:px-8 lg:py-7">
          {/* Top bar */}
          <div className="mb-6 flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
            <div>
              
              <h1 className="mt-2 text-2xl font-black tracking-tight text-slate-900 sm:text-3xl">
                Your Learning Roadmap
              </h1>
              <p className="mt-1 text-sm text-slate-500">
                Follow the path, complete each milestone, and build job-ready skills.
              </p>
            </div>

            <div className="flex items-center gap-3">
              <div className="relative hidden w-64 md:block">
                <Icon
                  name="search"
                  className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400"
                />
                <input
                  type="text"
                  placeholder="Search roadmap..."
                  className="h-10 w-full rounded-xl border border-slate-200 bg-white pl-9 pr-4 text-sm text-slate-700 outline-none transition placeholder:text-slate-400 focus:border-purple-300 focus:ring-4 focus:ring-purple-50"
                />
              </div>

              <button
                type="button"
                className="relative rounded-xl border border-slate-200 bg-white p-2.5 text-slate-500 transition hover:border-purple-200 hover:text-purple-700"
                aria-label="Notifications"
              >
                <Icon name="bell" className="h-5 w-5" />
                <span className="absolute right-2 top-2 h-1.5 w-1.5 rounded-full bg-rose-500" />
              </button>

              <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-purple-100 text-xs font-black text-purple-700">
                AC
              </div>
            </div>
          </div>

          {/* Hero */}
          <section className="overflow-hidden rounded-3xl border border-purple-100 bg-white shadow-[0_12px_40px_rgba(15,23,42,0.06)]">
            <div className="relative p-6 sm:p-8 lg:p-10">
              <div className="absolute right-0 top-0 h-48 w-48 rounded-full bg-purple-100/60 blur-3xl" />

              <div className="relative grid gap-8 lg:grid-cols-[1fr_360px] lg:items-center">
                <div>
                  <div className="flex flex-wrap items-center gap-2">
                    <span className="rounded-full bg-purple-100 px-3 py-1.5 text-[11px] font-black uppercase tracking-wide text-purple-700">
                      Advanced
                    </span>
                    <span className="flex items-center gap-1.5 text-xs font-semibold text-slate-500">
                      <Icon name="clock" className="h-4 w-4" />
                      12 weeks
                    </span>
                  </div>

                  <h2 className="mt-4 max-w-2xl text-3xl font-black tracking-tight text-slate-900 sm:text-4xl lg:text-5xl">
                    Web Development
                    <span className="block text-purple-700">Mastery</span>
                  </h2>

                  <p className="mt-4 max-w-2xl text-sm leading-7 text-slate-500 sm:text-base">
                    A structured path from modern HTML and CSS to JavaScript,
                    React, and production-ready frontend development.
                  </p>

                  <div className="mt-7 flex flex-wrap gap-3">
                    <button
                      type="button"
                      onClick={() => setSelectedSection("css")}
                      className="flex items-center gap-2 rounded-xl bg-purple-700 px-5 py-3 text-sm font-bold text-white shadow-[0_8px_20px_rgba(126,34,206,0.20)] transition hover:bg-purple-800"
                    >
                      <Icon name="play" className="h-4 w-4" />
                      Continue learning
                    </button>

                    <button
                      type="button"
                      onClick={() => setSidebarOpen((value) => !value)}
                      className="rounded-xl border border-slate-200 bg-white px-5 py-3 text-sm font-bold text-slate-600 transition hover:border-purple-200 hover:text-purple-700"
                    >
                      {sidebarOpen ? "Hide curriculum" : "View curriculum"}
                    </button>
                  </div>
                </div>

                <div className="rounded-2xl border border-slate-200 bg-slate-50 p-5">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-xs font-bold uppercase tracking-wide text-slate-400">
                        Overall progress
                      </p>
                      <p className="mt-1 text-3xl font-black text-slate-900">
                        {progress}%
                      </p>
                    </div>
                    <div className="flex h-12 w-12 items-center justify-center rounded-full bg-purple-100 text-purple-700">
                      <Icon name="target" className="h-6 w-6" />
                    </div>
                  </div>

                  <div className="mt-5 h-2.5 overflow-hidden rounded-full bg-slate-200">
                    <div
                      className="h-full rounded-full bg-purple-700 transition-all duration-500"
                      style={{ width: `${progress}%` }}
                    />
                  </div>

                  <div className="mt-3 flex justify-between text-xs font-medium text-slate-500">
                    <span>{completedLessons} completed</span>
                    <span>{totalLessons - completedLessons} remaining</span>
                  </div>
                </div>
              </div>
            </div>
          </section>

          {/* Main content */}
          <div className="mt-6 grid gap-6 lg:grid-cols-[280px_minmax(0,1fr)]">
            {sidebarOpen && (
              <aside className="h-fit rounded-2xl border border-slate-200 bg-white p-5 shadow-sm lg:sticky lg:top-5">
                <div className="flex items-center justify-between">
                  <div>
                    <h3 className="text-sm font-black text-slate-900">
                      Curriculum
                    </h3>
                    <p className="mt-1 text-xs text-slate-400">
                      {completedLessons} of {totalLessons} lessons complete
                    </p>
                  </div>
                  <Icon name="map" className="h-5 w-5 text-purple-700" />
                </div>

                <div className="mt-4 h-1.5 overflow-hidden rounded-full bg-slate-100">
                  <div
                    className="h-full rounded-full bg-purple-700"
                    style={{ width: `${progress}%` }}
                  />
                </div>

                <div className="mt-6 space-y-6">
                  {modules.map((module) => (
                    <div key={module.title}>
                      <p className="mb-3 text-[10px] font-black tracking-wider text-slate-400">
                        {module.title}
                      </p>

                      <div className="space-y-1">
                        {module.items.map((item) => (
                          <button
                            key={item.title}
                            type="button"
                            className={`flex w-full items-start gap-3 rounded-xl p-2.5 text-left transition ${
                              item.complete
                                ? "bg-purple-50 text-purple-700"
                                : "text-slate-500 hover:bg-slate-50 hover:text-slate-800"
                            }`}
                          >
                            <span
                              className={`mt-0.5 flex h-7 w-7 shrink-0 items-center justify-center rounded-lg ${
                                item.complete
                                  ? "bg-purple-100 text-purple-700"
                                  : "bg-slate-100 text-slate-400"
                              }`}
                            >
                              <Icon
                                name={item.complete ? "check" : item.icon}
                                className="h-3.5 w-3.5"
                              />
                            </span>

                            <span className="min-w-0">
                              <span className="block text-xs font-bold">
                                {item.title}
                              </span>
                              <span className="mt-0.5 block text-[11px] leading-4 text-slate-400">
                                {item.complete ? "Completed" : "Locked"}
                              </span>
                            </span>
                          </button>
                        ))}
                      </div>
                    </div>
                  ))}
                </div>

                <div className="mt-6 rounded-xl bg-purple-50 p-4">
                  <div className="flex items-center gap-2 text-purple-700">
                    <Icon name="trophy" className="h-4 w-4" />
                    <span className="text-xs font-black">Keep going</span>
                  </div>
                  <p className="mt-1.5 text-[11px] leading-5 text-slate-500">
                    Complete the next lesson to keep your learning streak moving.
                  </p>
                </div>
              </aside>
            )}

            <main className="min-w-0">
              <div className="mb-5 flex items-end justify-between">
                <div>
                  <p className="text-xs font-bold uppercase tracking-wider text-purple-700">
                    Current path
                  </p>
                  <h2 className="mt-1 text-xl font-black text-slate-900 sm:text-2xl">
                    Continue your roadmap
                  </h2>
                </div>
                <span className="hidden text-xs font-medium text-slate-400 sm:block">
                  2 learning sections
                </span>
              </div>

              <div className="space-y-5">
                {sections.map((section) => (
                  <RoadmapSectionCard
                    key={section.id}
                    section={section}
                    active={selectedSection === section.id}
                    onSelect={() => setSelectedSection(section.id)}
                  />
                ))}
              </div>

              <section className="mt-6 rounded-2xl border border-purple-100 bg-purple-50/70 p-5 sm:p-6">
                <div className="flex items-center gap-3">
                  <span className="flex h-9 w-9 items-center justify-center rounded-lg bg-white text-purple-700 shadow-sm">
                    <Icon name="edit" className="h-4 w-4" />
                  </span>
                  <div>
                    <h2 className="text-sm font-black text-slate-900">
                      My Learning Journal
                    </h2>
                    <p className="mt-0.5 text-xs text-slate-500">
                      Save notes, questions, and useful snippets as you learn.
                    </p>
                  </div>
                </div>

                <textarea
                  value={journal}
                  onChange={(e) => setJournal(e.target.value)}
                  placeholder="Write your key takeaways, code snippets, or questions..."
                  className="mt-4 h-32 w-full resize-none rounded-xl border border-slate-200 bg-white p-4 text-sm leading-6 text-slate-700 outline-none placeholder:text-slate-300 focus:border-purple-300 focus:ring-4 focus:ring-purple-50"
                />

                <div className="mt-3 flex justify-end">
                  <button
                    type="button"
                    onClick={() => setJournal(journal.trim())}
                    className="flex items-center gap-2 rounded-lg bg-purple-700 px-4 py-2.5 text-xs font-bold text-white transition hover:bg-purple-800"
                  >
                    <Icon name="send" className="h-3.5 w-3.5" />
                    Save notes
                  </button>
                </div>
              </section>

              <div className="mt-5 flex flex-wrap items-center justify-between gap-3 rounded-xl border border-slate-200 bg-white px-4 py-3 text-xs">
                <span className="text-slate-400">
                  Current section:{" "}
                  <span className="font-bold text-purple-700">
                    {selectedSection === "css"
                      ? "Advanced CSS Grid & Flexbox"
                      : "DOM Algorithms & Logic"}
                  </span>
                </span>

                <span className="flex items-center gap-1.5 font-semibold text-emerald-600">
                  <Icon name="check" className="h-3.5 w-3.5" />
                  Progress saved automatically
                </span>
              </div>
            </main>
          </div>
        </div>
      </div>
    </StudentLayout>
  );
};

export default StudentRoadmap;