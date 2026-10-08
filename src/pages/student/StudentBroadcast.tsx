import React, { useMemo, useState } from "react";
import StudentLayout from "../../components/student/StudentLayout";
import type { StudentSidebarIconName } from "../../components/student/StudentSidebar";

type IconName = "search" | "bell" | "broadcast" | "briefcase" | "calendar" | "location" | "money" | "users" | "share" | "bookmark" | "check" | "building" | "graduation" | "megaphone" | "clock" | "dashboard" | "user-check" | "clipboard" | "award" | "settings" | "resume" | "map";

const Icon = ({ name, className = "h-4 w-4" }: { name: IconName; className?: string }) => {
  const paths: Record<IconName, React.ReactNode> = {
    dashboard: <><rect x="3" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="3" width="7" height="7" rx="1.5"/><rect x="3" y="14" width="7" height="7" rx="1.5"/><rect x="14" y="14" width="7" height="7" rx="1.5"/></>,
    "user-check": <><circle cx="9" cy="8" r="4"/><path d="M3 21v-2a5 5 0 0 1 5-5h2"/><path d="m15 16 2 2 4-5"/></>,
    clipboard: <><rect x="5" y="4" width="14" height="17" rx="2"/><path d="M9 4V2h6v2M9 10h6M9 14h6M9 18h4"/></>,
    award: <><circle cx="12" cy="8" r="5"/><path d="m9 12.5-1 8 4-2 4 2-1-8"/></>,
    settings: <><circle cx="12" cy="12" r="3"/><path d="M19 12a7 7 0 0 0-.1-1.2l2-1.5-2-3.5-2.4 1a7.5 7.5 0 0 0-2-1.2L14.2 3H9.8L9.5 5.6a7.5 7.5 0 0 0-2 1.2l-2.4-1-2 3.5 2 1.5A7 7 0 0 0 5 12c0 .4 0 .8.1 1.2l-2 1.5 2 3.5 2.4-1a7.5 7.5 0 0 0 2 1.2l.3 2.6h4.4l.3-2.6a7.5 7.5 0 0 0 2-1.2l2.4 1 2-3.5-2-1.5c.1-.4.1-.8.1-1.2Z"/></>,
    resume: <><path d="M6 3h9l5 5v13H6a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2Z"/><path d="M14 3v5h5M8 13h8M8 17h6"/></>,
    map: <><path d="m4 6 6-3 4 3 6-3v15l-6 3-4-3-6 3V6Z"/><path d="M10 3v15M14 6v15"/></>,
    search: <><circle cx="11" cy="11" r="7" /><path d="m16 16 4 4" /></>,
    bell: <><path d="M18 9a6 6 0 0 0-12 0c0 7-3 7-3 7h18s-3 0-3-7" /><path d="M10 20a2 2 0 0 0 4 0" /></>,
    broadcast: <><circle cx="12" cy="12" r="2" /><path d="M8.5 8.5a5 5 0 0 0 0 7M15.5 8.5a5 5 0 0 1 0 7" /><path d="M5.5 5.5a9 9 0 0 0 0 13M18.5 5.5a9 9 0 0 1 0 13" /></>,
    briefcase: <><rect x="3" y="7" width="18" height="13" rx="2" /><path d="M8 7V5a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2M3 12h18" /></>,
    calendar: <><rect x="3" y="4" width="18" height="17" rx="2" /><path d="M16 2v4M8 2v4M3 9h18" /></>,
    location: <><path d="M20 10c0 5-8 11-8 11S4 15 4 10a8 8 0 1 1 16 0Z" /><circle cx="12" cy="10" r="2.5" /></>,
    money: <><rect x="3" y="6" width="18" height="12" rx="2" /><circle cx="12" cy="12" r="3" /><path d="M7 9h.01M17 15h.01" /></>,
    users: <><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" /><circle cx="9" cy="7" r="4" /><path d="M22 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75" /></>,
    share: <><circle cx="18" cy="5" r="3" /><circle cx="6" cy="12" r="3" /><circle cx="18" cy="19" r="3" /><path d="m8.6 13.5 6.8 4M15.4 6.5l-6.8 4" /></>,
    bookmark: <path d="M6 4a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v18l-6-3-6 3V4Z" />,
    check: <path d="m5 12 4 4L19 6" />,
    building: <><path d="M5 21V5a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v16M3 21h18" /><path d="M9 7h1M14 7h1M9 11h1M14 11h1" /></>,
    graduation: <><path d="m3 9 9-5 9 5-9 5-9-5Z" /><path d="M7 11v5c2.5 2 7.5 2 10 0v-5M21 9v6" /></>,
    megaphone: <><path d="m3 11 15-6v14L3 13v-2Z" /><path d="M18 9a4 4 0 0 1 0 6M7 14l2 6" /></>,
    clock: <><circle cx="12" cy="12" r="9" /><path d="M12 7v5l3 2" /></>,
  };

  return <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className={className} aria-hidden="true">{paths[name]}</svg>;
};

type Broadcast = {
  id: number;
  type: "Placement" | "Academic" | "Student Union" | "Event";
  title: string;
  preview: string;
  sender: string;
  time: string;
  unread?: boolean;
  company?: string;
  role?: string;
  deadline?: string;
  location?: string;
  ctc?: string;
  description: string;
  eligibility: string[];
  applied?: number;
  viewed?: number;
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


const broadcasts: Broadcast[] = [
  {
    id: 1,
    type: "Placement",
    title: "Google Recruitment 2025: Software Engineer (University Grad)",
    preview: "Eligible students can apply for the Google University Graduate Software Engineer opportunity.",
    sender: "Placement Cell",
    time: "2h ago",
    unread: true,
    company: "Google",
    role: "Software Engineer (University Grad)",
    deadline: "Oct 25, 2024",
    location: "Bangalore / Hyderabad",
    ctc: "Competitive CTC",
    description: "As a Software Engineer at Google, you'll work on the next generation of applications that will change the way billions of people interact with information and each other. The team is looking for talented graduates who are passionate about building large-scale systems and solving complex problems.",
    eligibility: ["7.5 CGPA and above", "B.Tech CSE / IT / ECE", "Final Year students", "No active backlogs"],
    applied: 82,
    viewed: 450,
  },
  {
    id: 2,
    type: "Academic",
    title: "Mid-Semester Timetable Released",
    preview: "Check the updated schedule for CSE and IT departments. Exams begin next month.",
    sender: "Academic Department",
    time: "5h ago",
    unread: true,
    description: "The updated mid-semester examination timetable has been released for CSE and IT departments. Please review your subjects and examination dates.",
    eligibility: [],
  },
  {
    id: 3,
    type: "Student Union",
    title: "TechFest 2024: Volunteer Registrations",
    preview: "Join the organizing committee for the upcoming technical festival.",
    sender: "Student Union",
    time: "Yesterday",
    description: "Students interested in volunteering for the upcoming technical festival can register through the student activities portal.",
    eligibility: [],
  },
  {
    id: 4,
    type: "Placement",
    title: "Mock Interview Sessions - Round 2",
    preview: "Mandatory mock interviews for final-year students. Slots opening this week.",
    sender: "Placement Cell",
    time: "Yesterday",
    description: "Round 2 of mock interview sessions is now available for final-year students preparing for campus recruitment.",
    eligibility: ["Final Year students"],
    viewed: 126,
  },
  {
    id: 5,
    type: "Placement",
    title: "Microsoft Software Engineering Internship",
    preview: "Microsoft has opened applications for software engineering internship roles.",
    sender: "Placement Cell",
    time: "2 days ago",
    company: "Microsoft",
    role: "Software Engineering Intern",
    deadline: "Nov 04, 2024",
    location: "Hyderabad",
    ctc: "₹28 LPA",
    description: "Microsoft is inviting applications for software engineering internship opportunities. Selected students will work with engineering teams on real-world products.",
    eligibility: ["7.5 CGPA and above", "B.Tech CSE / IT", "Pre-final or Final Year"],
    applied: 198,
    viewed: 622,
  },
];

const typeStyles = {
  Placement: { badge: "bg-purple-100 text-purple-700", icon: "briefcase" as IconName, iconBg: "bg-purple-100 text-purple-700" },
  Academic: { badge: "bg-violet-100 text-violet-700", icon: "graduation" as IconName, iconBg: "bg-violet-100 text-violet-700" },
  "Student Union": { badge: "bg-slate-100 text-slate-600", icon: "megaphone" as IconName, iconBg: "bg-slate-100 text-slate-600" },
  Event: { badge: "bg-purple-100 text-purple-700", icon: "calendar" as IconName, iconBg: "bg-purple-100 text-purple-700" },
};

const StudentBroadcast: React.FC = () => {
  const [selectedId, setSelectedId] = useState(1);
  const [filter, setFilter] = useState<"All" | "Placements" | "Events">("All");
  const [search, setSearch] = useState("");
  const [saved, setSaved] = useState<number[]>([]);
  const [applied, setApplied] = useState<number[]>([]);

  const filteredBroadcasts = useMemo(() => {
    return broadcasts.filter((item) => {
      const matchesFilter = filter === "All" || (filter === "Placements" && item.type === "Placement") || (filter === "Events" && (item.type === "Event" || item.type === "Student Union"));
      const query = search.trim().toLowerCase();
      const matchesSearch = !query || item.title.toLowerCase().includes(query) || item.preview.toLowerCase().includes(query) || item.sender.toLowerCase().includes(query);
      return matchesFilter && matchesSearch;
    });
  }, [filter, search]);

  const selected = broadcasts.find((item) => item.id === selectedId) ?? broadcasts[0];

  const handleSave = () => {
    setSaved((current) => current.includes(selected.id) ? current.filter((id) => id !== selected.id) : [...current, selected.id]);
  };

  const handleApply = () => {
    setApplied((current) => current.includes(selected.id) ? current : [...current, selected.id]);
  };

  return (
    <StudentLayout
      sidebarItems={sidebarItems}
      sidebarHighlight="Career Updates"
      userSummary={{
        fullName: "Zaira Hussain",
        role: "B.Tech CSE",
        status: "Placement track active",
      }}
      stats={{
        label: "New broadcasts",
        value: "12",
        subtitle: "Updates from your college",
        accent: "New",
      }}
    >
      <div className="min-h-full bg-[#FCF9F8]">
        <div className="mx-auto w-full max-w-[1440px] px-4 py-5 sm:px-6 lg:px-8">

          <header className="mb-6">
            <div className="flex flex-col gap-4 rounded-3xl border border-[#E8E0F0] bg-white p-5 shadow-sm sm:p-7 lg:flex-row lg:items-center lg:justify-between">
              <div>
                <div className="mb-3 inline-flex items-center gap-2 rounded-full bg-[#F4EFFF] px-3 py-1.5 text-[10px] font-bold text-[#5400D6]">
                  <Icon name="broadcast" className="h-3.5 w-3.5" />
                  Career Updates
                </div>
                <h1 className="text-2xl font-black tracking-tight text-slate-900 sm:text-3xl">
                  College Broadcasts
                </h1>
                <p className="mt-2 max-w-2xl text-xs leading-5 text-slate-500 sm:text-sm">
                  Stay informed about placement opportunities, academic announcements,
                  events, and important messages shared by your college.
                </p>
              </div>

              <div className="flex items-center gap-3 rounded-2xl border border-[#E4D8F4] bg-[#FCF9FF] px-4 py-3">
                <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-[#5400D6] text-white">
                  <Icon name="bell" className="h-4 w-4" />
                </div>
                <div>
                  <p className="text-lg font-black text-slate-900">12</p>
                  <p className="text-[10px] font-semibold text-slate-500">New updates</p>
                </div>
              </div>
            </div>
          </header>

          <div className="grid gap-5 xl:grid-cols-[340px_minmax(0,1fr)]">

            <aside className="min-w-0">
              <div className="overflow-hidden rounded-2xl border border-[#E8E0F0] bg-white shadow-sm">

                <div className="border-b border-[#EEE8F4] p-4 sm:p-5">
                  <div className="flex items-center justify-between gap-3">
                    <div>
                      <h2 className="text-sm font-black text-slate-900">Updates</h2>
                      <p className="mt-1 text-[10px] text-slate-400">
                        Recent messages
                      </p>
                    </div>

                    <span className="rounded-full bg-[#F4EFFF] px-2.5 py-1 text-[9px] font-bold text-[#5400D6]">
                      12 new
                    </span>
                  </div>

                  <div className="mt-4 flex flex-wrap gap-2">
                    {(["All", "Placements", "Events"] as const).map((item) => (
                      <button
                        key={item}
                        type="button"
                        onClick={() => setFilter(item)}
                        className={`rounded-lg px-3 py-2 text-[9px] font-bold transition ${
                          filter === item
                            ? "bg-[#5400D6] text-white shadow-sm"
                            : "border border-[#E5DDEE] bg-white text-slate-500 hover:border-[#BFA4E8] hover:bg-[#F4EFFF] hover:text-[#5400D6]"
                        }`}
                      >
                        {item}
                      </button>
                    ))}
                  </div>

                  <div className="relative mt-4">
                    <Icon
                      name="search"
                      className="absolute left-3 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-slate-400"
                    />
                    <input
                      value={search}
                      onChange={(e) => setSearch(e.target.value)}
                      placeholder="Search updates..."
                      className="h-10 w-full rounded-xl border border-[#E5DDEE] bg-[#FCF9F8] pl-9 pr-3 text-[10px] text-slate-700 outline-none transition placeholder:text-slate-400 focus:border-[#9D73DE] focus:bg-white focus:ring-4 focus:ring-[#F4EFFF]"
                    />
                  </div>
                </div>

                <div className="max-h-[620px] overflow-y-auto p-3">
                  <div className="space-y-2">
                    {filteredBroadcasts.map((item) => {
                      const styles = typeStyles[item.type];
                      const active = selected.id === item.id;

                      return (
                        <button
                          key={item.id}
                          type="button"
                          onClick={() => setSelectedId(item.id)}
                          className={`w-full rounded-2xl border p-3.5 text-left transition ${
                            active
                              ? "border-[#CBB3EA] bg-[#F9F5FF] shadow-sm"
                              : "border-transparent bg-white hover:border-[#E8DDF4] hover:bg-[#FCF9FF]"
                          }`}
                        >
                          <div className="flex items-start gap-3">
                            <span
                              className={`flex h-9 w-9 flex-shrink-0 items-center justify-center rounded-xl ${styles.iconBg}`}
                            >
                              <Icon name={styles.icon} className="h-4 w-4" />
                            </span>

                            <div className="min-w-0 flex-1">
                              <div className="flex items-center justify-between gap-2">
                                <span
                                  className={`rounded-md px-1.5 py-1 text-[7px] font-black uppercase tracking-wide ${styles.badge}`}
                                >
                                  {item.type === "Placement"
                                    ? "Placement"
                                    : item.type}
                                </span>

                                <span className="flex-shrink-0 text-[8px] text-slate-400">
                                  {item.time}
                                </span>
                              </div>

                              <h3
                                className={`mt-2 line-clamp-2 text-[11px] font-bold leading-4 ${
                                  item.unread
                                    ? "text-slate-900"
                                    : "text-slate-700"
                                }`}
                              >
                                {item.title}
                              </h3>

                              <p className="mt-1 line-clamp-2 text-[9px] leading-4 text-slate-500">
                                {item.preview}
                              </p>

                              {item.unread && (
                                <div className="mt-2 flex items-center gap-1.5 text-[8px] font-bold text-[#5400D6]">
                                  <span className="h-1.5 w-1.5 rounded-full bg-[#5400D6]" />
                                  New update
                                </div>
                              )}
                            </div>
                          </div>
                        </button>
                      );
                    })}

                    {filteredBroadcasts.length === 0 && (
                      <div className="rounded-2xl border border-dashed border-[#DCCFEA] bg-[#FCF9FF] px-4 py-12 text-center">
                        <Icon
                          name="broadcast"
                          className="mx-auto h-6 w-6 text-[#BDA4DB]"
                        />
                        <p className="mt-3 text-[10px] font-bold text-slate-600">
                          No updates found
                        </p>
                        <p className="mt-1 text-[9px] text-slate-400">
                          Try another search or category.
                        </p>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            </aside>

            <main className="min-w-0">
              <article className="overflow-hidden rounded-3xl border border-[#E8E0F0] bg-white shadow-sm">

                <div className="border-b border-[#EEE8F4] p-5 sm:p-7 lg:p-8">
                  <div className="flex flex-col gap-5">
                    <div className="flex items-start justify-between gap-4">
                      <div className="min-w-0">
                        <div className="flex flex-wrap items-center gap-2">
                          <span className="rounded-full bg-[#5400D6] px-3 py-1.5 text-[8px] font-black uppercase tracking-wider text-white">
                            {selected.type === "Placement"
                              ? "Placement Opportunity"
                              : selected.type}
                          </span>

                          <span className="text-[9px] text-slate-400">
                            Posted by {selected.sender} · {selected.time}
                          </span>
                        </div>

                        <h2 className="mt-4 max-w-4xl text-2xl font-black leading-tight tracking-tight text-slate-900 sm:text-3xl lg:text-4xl">
                          {selected.title}
                        </h2>
                      </div>

                      <div className="flex flex-shrink-0 items-center gap-1.5">
                        <button
                          type="button"
                          onClick={handleSave}
                          className={`flex h-9 w-9 items-center justify-center rounded-xl transition ${
                            saved.includes(selected.id)
                              ? "bg-[#F4EFFF] text-[#5400D6]"
                              : "border border-[#E5DDEE] text-slate-400 hover:bg-[#F9F5FF] hover:text-[#5400D6]"
                          }`}
                          aria-label="Save broadcast"
                        >
                          <Icon name="bookmark" className="h-4 w-4" />
                        </button>

                        <button
                          type="button"
                          className="flex h-9 w-9 items-center justify-center rounded-xl border border-[#E5DDEE] text-slate-400 transition hover:bg-[#F9F5FF] hover:text-[#5400D6]"
                          aria-label="Share broadcast"
                        >
                          <Icon name="share" className="h-4 w-4" />
                        </button>
                      </div>
                    </div>

                    {selected.company && (
                      <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
                        {[
                          {
                            icon: "calendar" as IconName,
                            label: "Deadline",
                            value: selected.deadline,
                          },
                          {
                            icon: "location" as IconName,
                            label: "Location",
                            value: selected.location,
                          },
                          {
                            icon: "money" as IconName,
                            label: "Compensation",
                            value: selected.ctc,
                          },
                          {
                            icon: "briefcase" as IconName,
                            label: "Role",
                            value: selected.role,
                          },
                        ].map((item) => (
                          <div
                            key={item.label}
                            className="rounded-2xl border border-[#EEE8F4] bg-[#FCF9F8] p-3.5"
                          >
                            <div className="flex items-start gap-3">
                              <span className="flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-lg bg-[#F4EFFF] text-[#5400D6]">
                                <Icon name={item.icon} className="h-3.5 w-3.5" />
                              </span>
                              <div className="min-w-0">
                                <p className="text-[8px] font-bold uppercase tracking-wide text-slate-400">
                                  {item.label}
                                </p>
                                <p className="mt-1 line-clamp-2 text-[10px] font-bold leading-4 text-slate-700">
                                  {item.value}
                                </p>
                              </div>
                            </div>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                </div>

                <div className="grid lg:grid-cols-[minmax(0,1fr)_280px]">
                  <div className="p-5 sm:p-7 lg:p-8">
                    <section>
                      <div className="flex items-center gap-2">
                        <span className="h-5 w-1 rounded-full bg-[#5400D6]" />
                        <h3 className="text-[10px] font-black uppercase tracking-wider text-slate-500">
                          Message
                        </h3>
                      </div>

                      <p className="mt-4 max-w-3xl text-sm leading-7 text-slate-600">
                        {selected.description}
                      </p>
                    </section>

                    {selected.company && (
                      <section className="mt-8">
                        <div className="flex items-center gap-2">
                          <span className="h-5 w-1 rounded-full bg-[#5400D6]" />
                          <h3 className="text-[10px] font-black uppercase tracking-wider text-slate-500">
                            Opportunity
                          </h3>
                        </div>

                        <div className="mt-4 rounded-2xl border border-[#E4D8F4] bg-[#FCF9FF] p-5">
                          <div className="flex items-center gap-4">
                            <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-white text-base font-black text-[#5400D6] shadow-sm ring-1 ring-[#E4D8F4]">
                              {selected.company.charAt(0)}
                            </div>

                            <div>
                              <p className="text-base font-black text-slate-900">
                                {selected.company}
                              </p>
                              <p className="mt-1 text-[10px] text-slate-500">
                                {selected.role}
                              </p>
                            </div>
                          </div>
                        </div>
                      </section>
                    )}
                  </div>

                  {selected.eligibility.length > 0 && (
                    <aside className="border-t border-[#EEE8F4] bg-[#FCF9FF] p-5 sm:p-7 lg:border-l lg:border-t-0">
                      <div className="flex items-center gap-2">
                        <span className="flex h-7 w-7 items-center justify-center rounded-lg bg-[#F4EFFF] text-[#5400D6]">
                          <Icon name="check" className="h-3.5 w-3.5" />
                        </span>
                        <h3 className="text-[10px] font-black uppercase tracking-wider text-slate-600">
                          Eligibility
                        </h3>
                      </div>

                      <div className="mt-5 space-y-3">
                        {selected.eligibility.map((item) => (
                          <div key={item} className="flex items-start gap-2.5">
                            <span className="mt-0.5 flex h-4 w-4 flex-shrink-0 items-center justify-center rounded-full bg-[#EDE3FA] text-[#5400D6]">
                              <Icon name="check" className="h-2.5 w-2.5" />
                            </span>
                            <span className="text-[10px] leading-5 text-slate-600">
                              {item}
                            </span>
                          </div>
                        ))}
                      </div>
                    </aside>
                  )}
                </div>

                <footer className="flex flex-col gap-4 border-t border-[#EEE8F4] px-5 py-5 sm:px-7 lg:flex-row lg:items-center lg:justify-between lg:px-8">
                  <div className="flex flex-wrap items-center gap-4 text-[9px] text-slate-400">
                    {selected.viewed !== undefined && (
                      <span className="flex items-center gap-1.5">
                        <Icon name="users" className="h-3.5 w-3.5" />
                        {selected.viewed} viewed
                      </span>
                    )}

                    {selected.applied !== undefined && (
                      <span className="flex items-center gap-1.5">
                        <Icon name="users" className="h-3.5 w-3.5" />
                        {selected.applied} applied
                      </span>
                    )}
                  </div>

                  {selected.company && (
                    <div className="flex w-full gap-2 sm:w-auto">
                      <button
                        type="button"
                        onClick={handleSave}
                        className={`flex-1 rounded-xl border px-5 py-2.5 text-[9px] font-bold transition sm:flex-none ${
                          saved.includes(selected.id)
                            ? "border-[#D7C2F2] bg-[#F4EFFF] text-[#5400D6]"
                            : "border-[#CBB3EA] bg-white text-[#5400D6] hover:bg-[#F9F5FF]"
                        }`}
                      >
                        {saved.includes(selected.id) ? "Saved" : "Save for Later"}
                      </button>

                      <button
                        type="button"
                        onClick={handleApply}
                        className="flex-1 rounded-xl bg-[#5400D6] px-6 py-2.5 text-[9px] font-bold text-white shadow-sm transition hover:bg-[#4300AA] sm:flex-none"
                      >
                        {applied.includes(selected.id)
                          ? "Application Started"
                          : "Apply Now"}
                      </button>
                    </div>
                  )}
                </footer>
              </article>

              <div className="mt-4 flex flex-col gap-2 rounded-2xl border border-[#E8E0F0] bg-white px-4 py-4 text-[9px] text-slate-400 sm:flex-row sm:items-center sm:justify-between">
                <span className="flex items-center gap-1.5">
                  <Icon name="clock" className="h-3.5 w-3.5" />
                  College updates are refreshed throughout the day.
                </span>
                <span className="font-bold text-[#5400D6]">
                  Stay updated on new opportunities
                </span>
              </div>
            </main>
          </div>
        </div>
      </div>
    </StudentLayout>
  );
};

export default StudentBroadcast;