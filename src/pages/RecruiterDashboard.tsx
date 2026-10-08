import React from 'react';
import { Link } from 'react-router-dom';
import { DashboardLayout } from '../components/layout/DashboardLayout';
import { roleNavigation } from '../data/platform';
import {
  ArrowLeft,
  BarChart3,
  Bell,
  Briefcase,
  Building2,
  CalendarDays,
  Clock,
  FileText,
  Filter,
  GraduationCap,
  LayoutDashboard,
  Settings,
  Sparkles,
  Star,
  Users,
} from 'lucide-react';
import { useAuth } from '../context/AuthContext';

const stats = [
  { label: 'Matched Candidates', value: '2,410', change: '+18%', icon: Users },
  { label: 'Active Drives', value: '12', change: '+3', icon: Briefcase },
  { label: 'Interviews Today', value: '28', change: '6 pending', icon: CalendarDays },
  { label: 'Avg Match Score', value: '91%', change: '+4.2%', icon: Star },
];

const candidates = [
  { name: 'Rahul Sharma', role: 'Frontend Engineer', college: 'DTU', score: '94%', stage: 'Technical Round' },
  { name: 'Priya Singh', role: 'Full Stack Engineer', college: 'NIT Trichy', score: '88%', stage: 'Assessment' },
  { name: 'Anjali Gupta', role: 'Product Designer', college: 'IIT Bombay', score: '91%', stage: 'Portfolio Review' },
  { name: 'Gaurav  Verma', role: 'Backend Engineer', college: 'BITS Pilani', score: '85%', stage: 'Shortlisted' },
];

export const RecruiterDashboard: React.FC = () => {
  const { logout } = useAuth();

  const menuItems = roleNavigation.recruiter.map((item) => ({
    title: item.title,
    icon: item.title === 'Dashboard' ? LayoutDashboard : item.title === 'Candidates' ? Users : item.title === 'Job Posts' ? Briefcase : item.title === 'Applications' ? FileText : item.title === 'Interviews' ? CalendarDays : item.title === 'Analytics' ? BarChart3 : Settings,
    active: item.active,
    onClick: item.title === 'Settings' ? logout : undefined,
  }));

  return (
    <DashboardLayout
      portalLabel="Recruiter Portal"
      title="Recruiter Dashboard"
      subtitle="Manage verified talent pipelines and interview activity"
      actions={
        <Link to="/" className="inline-flex h-10 items-center gap-2 rounded-xl border border-slate-200 bg-white px-3.5 text-sm font-semibold text-slate-700 shadow-sm hover:bg-slate-50">
          <ArrowLeft className="h-4 w-4" />
          Home
        </Link>
      }
      profile={
        <button type="button" className="dashboard-icon-button" aria-label="Notifications">
          <Bell className="h-4 w-4" />
        </button>
      }
      footer={
        <div className="rounded-2xl border border-white/10 bg-white/5 p-4">
          <p className="text-xs font-semibold text-slate-400">Hiring Pipeline</p>
          <p className="mt-2 text-2xl font-bold text-white">76%</p>
          <div className="mt-3 h-2 overflow-hidden rounded-full bg-white/10">
            <div className="h-full w-3/4 rounded-full bg-gradient-to-r from-blue-400 to-emerald-400" />
          </div>
          <p className="mt-3 text-xs text-slate-400">Stripe India cohort</p>
        </div>
      }
      sidebarItems={menuItems.map((item) => ({
        title: item.title,
        icon: ({ className }) => <item.icon className={className} />,
        active: item.active,
        onClick: item.onClick,
      }))}
      className="bg-slate-50"
    >
      <div className="mx-auto max-w-7xl">

        <section className="dashboard-hero relative overflow-hidden rounded-[24px] px-6 py-6 text-white">
          <div className="relative z-10 flex flex-col gap-6 lg:flex-row lg:items-end lg:justify-between">
            <div>
              <span className="inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/5 px-3 py-1 text-xs font-semibold text-blue-100">
                <Sparkles className="h-3.5 w-3.5" />
                AI-ranked candidate intelligence
              </span>
              <h2 className="mt-4 text-3xl font-bold tracking-tight">Stripe Frontend Drive</h2>
              <p className="mt-2 max-w-2xl text-sm leading-6 text-slate-300">
                Review high-fit candidates, schedule interviews, and keep the hiring team aligned from one workspace.
              </p>
            </div>
            <div className="grid grid-cols-3 gap-3 text-center">
              {['2,410 verified', '184 ready', '28 today'].map((item) => (
                <div key={item} className="rounded-2xl border border-white/10 bg-white/5 px-4 py-3">
                  <p className="text-sm font-bold">{item}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        <section className="mt-6 grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
          {stats.map((item) => {
            const Icon = item.icon;

            return (
              <article key={item.label} className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
                <div className="flex items-start justify-between">
                  <div>
                    <p className="text-sm font-medium text-slate-500">{item.label}</p>
                    <p className="mt-2 text-3xl font-bold tracking-tight text-slate-950">{item.value}</p>
                  </div>
                  <div className="grid h-11 w-11 place-items-center rounded-xl bg-blue-50 text-blue-600">
                    <Icon className="h-5 w-5" />
                  </div>
                </div>
                <p className="mt-4 text-xs font-semibold text-emerald-700">{item.change}</p>
              </article>
            );
          })}
        </section>

        <section className="mt-6 grid gap-6 xl:grid-cols-[1.4fr_0.6fr]">
          <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
            <div className="flex flex-col gap-3 border-b border-slate-100 pb-4 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <h2 className="text-lg font-semibold text-slate-950">Candidate Pipeline</h2>
                <p className="mt-1 text-sm text-slate-500">Sorted by verified match score and readiness.</p>
              </div>
              <div className="flex gap-2">
                <button className="inline-flex h-10 items-center gap-2 rounded-xl border border-slate-200 bg-white px-3 text-sm font-semibold text-slate-700 hover:bg-slate-50">
                  <Filter className="h-4 w-4" />
                  Filters
                </button>
                <button className="inline-flex h-10 items-center gap-2 rounded-xl bg-slate-950 px-3.5 text-sm font-semibold text-white hover:bg-slate-800">
                  Export
                </button>
              </div>
            </div>

            <div className="overflow-x-auto">
              <table className="mt-2 min-w-[680px]">
                <thead>
                  <tr className="border-b border-slate-100">
                    <th className="py-3 text-left">Candidate</th>
                    <th className="py-3 text-left">College</th>
                    <th className="py-3 text-left">Match</th>
                    <th className="py-3 text-left">Stage</th>
                    <th className="py-3 text-right">Action</th>
                  </tr>
                </thead>
                <tbody>
                  {candidates.map((candidate) => (
                    <tr key={candidate.name} className="border-b border-slate-100 last:border-0">
                      <td className="py-4">
                        <div className="flex items-center gap-3">
                          <div className="grid h-10 w-10 place-items-center rounded-xl bg-slate-100 text-sm font-bold text-slate-700">
                            {candidate.name.split(' ').map((part) => part[0]).join('')}
                          </div>
                          <div>
                            <p className="font-semibold text-slate-900">{candidate.name}</p>
                            <p className="text-xs text-slate-500">{candidate.role}</p>
                          </div>
                        </div>
                      </td>
                      <td className="py-4 text-sm text-slate-600">{candidate.college}</td>
                      <td className="py-4">
                        <span className="rounded-full bg-emerald-50 px-2.5 py-1 text-xs font-bold text-emerald-700 ring-1 ring-emerald-100">
                          {candidate.score}
                        </span>
                      </td>
                      <td className="py-4 text-sm text-slate-600">{candidate.stage}</td>
                      <td className="py-4 text-right">
                        <button className="rounded-xl border border-slate-200 px-3 py-2 text-xs font-semibold text-slate-700 hover:bg-blue-50 hover:text-blue-700">
                          Review
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>

          <div className="space-y-6">
            <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
              <h2 className="text-lg font-semibold text-slate-950">Interview Queue</h2>
              <div className="mt-4 space-y-3">
                {['10:00 AM - Rahul Sharma', '12:30 PM - Anjali Gupta', '03:00 PM - Priya Singh'].map((slot) => (
                  <div key={slot} className="flex items-center gap-3 rounded-xl border border-slate-100 bg-slate-50 p-3">
                    <Clock className="h-4 w-4 text-blue-600" />
                    <p className="text-sm font-semibold text-slate-700">{slot}</p>
                  </div>
                ))}
              </div>
            </section>

            <section className="rounded-2xl border border-dashed border-slate-300 bg-white p-5 text-center shadow-sm">
              <div className="mx-auto grid h-12 w-12 place-items-center rounded-2xl bg-slate-100 text-slate-500">
                <Building2 className="h-5 w-5" />
              </div>
              <h2 className="mt-4 text-base font-semibold text-slate-950">No inactive drives</h2>
              <p className="mt-2 text-sm leading-6 text-slate-500">
                All open recruiter drives have active candidates and recent updates.
              </p>
            </section>

            <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
              <div className="flex items-center gap-3">
                <div className="grid h-10 w-10 place-items-center rounded-xl bg-blue-50 text-blue-600">
                  <GraduationCap className="h-5 w-5" />
                </div>
                <div>
                  <p className="text-sm font-semibold text-slate-950">Talent pool health</p>
                  <p className="text-xs text-slate-500">184 candidates ready for recruiter review</p>
                </div>
              </div>
              <div className="mt-4 h-2 overflow-hidden rounded-full bg-slate-100">
                <div className="h-full w-[84%] rounded-full bg-gradient-to-r from-blue-500 to-emerald-500" />
              </div>
            </section>
          </div>
        </section>
      </div>
    </DashboardLayout>
  );
};
