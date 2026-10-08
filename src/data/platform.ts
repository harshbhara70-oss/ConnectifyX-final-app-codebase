import {
  LayoutDashboard,
  UserCircle2,
  Briefcase,
  FileText,
  BarChart3,
  Settings,
  GraduationCap,
  Building2,
  Users,
  CalendarRange,
  MessageSquareMore,
  ShieldCheck,
  Sparkles,
  BadgeCheck,
  TrendingUp,
  BellRing,
  Landmark,
  DatabaseZap,
  ClipboardCheck,
  ScrollText,
} from 'lucide-react';
import type { LucideIcon } from 'lucide-react';

export type PlatformRole = 'student' | 'recruiter' | 'college' | 'mentor' | 'admin';

export interface SidebarNavItem {
  title: string;
  icon: LucideIcon;
  active?: boolean;
  badge?: string | number;
  href?: string;
}

export const roleNavigation: Record<PlatformRole, SidebarNavItem[]> = {
  student: [
    { title: 'Dashboard', icon: LayoutDashboard, active: true },
    { title: 'Profile', icon: UserCircle2 },
    { title: 'Resume', icon: FileText },
    { title: 'Skills', icon: BadgeCheck },
    { title: 'Assessments', icon: ClipboardCheck },
    { title: 'Jobs', icon: Briefcase },
    { title: 'Applications', icon: ScrollText },
    { title: 'Settings', icon: Settings },
  ],
  recruiter: [
    { title: 'Dashboard', icon: LayoutDashboard, active: true },
    { title: 'Candidates', icon: Users },
    { title: 'Job Posts', icon: Briefcase },
    { title: 'Applications', icon: ScrollText },
    { title: 'Interviews', icon: CalendarRange },
    { title: 'Analytics', icon: BarChart3 },
    { title: 'Settings', icon: Settings },
  ],
  college: [
    { title: 'Dashboard', icon: LayoutDashboard, active: true },
    { title: 'Students', icon: GraduationCap },
    { title: 'Departments', icon: Building2 },
    { title: 'Placements', icon: Briefcase },
    { title: 'Analytics', icon: BarChart3 },
    { title: 'Reports', icon: ScrollText },
    { title: 'Settings', icon: Settings },
  ],
  mentor: [
    { title: 'Dashboard', icon: LayoutDashboard, active: true },
    { title: 'Students', icon: GraduationCap },
    { title: 'Sessions', icon: CalendarRange },
    { title: 'Feedback', icon: MessageSquareMore },
    { title: 'Progress', icon: TrendingUp },
    { title: 'Settings', icon: Settings },
  ],
  admin: [
    { title: 'Dashboard', icon: LayoutDashboard, active: true },
    { title: 'Students', icon: GraduationCap },
    { title: 'Recruiters', icon: Users },
    { title: 'Mentors', icon: ShieldCheck },
    { title: 'Colleges', icon: Landmark },
    { title: 'Jobs', icon: Briefcase },
    { title: 'Applications', icon: ScrollText },
    { title: 'Reports', icon: BarChart3 },
    { title: 'Analytics', icon: TrendingUp },
    { title: 'User Management', icon: DatabaseZap },
    { title: 'Permissions', icon: ShieldCheck },
    { title: 'Settings', icon: Settings },
  ],
};

export const platformHighlights = [
  {
    title: 'AI Placement Match',
    description: 'Resume, skills, and recruiter demand aligned in one place.',
    icon: Sparkles,
  },
  {
    title: 'Live Activity Feed',
    description: 'Students, recruiters, mentors, and admins stay connected.',
    icon: BellRing,
  },
  {
    title: 'Enterprise Analytics',
    description: 'Track readiness, conversions, placement outcomes, and health.',
    icon: BarChart3,
  },
];
