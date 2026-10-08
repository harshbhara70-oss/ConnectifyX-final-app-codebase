import React, { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { 
  Users, 
  Calendar, 
  Award, 
  Clock, 
  Search, 
  Sparkles, 
  Plus, 
  PlayCircle, 
  X, 
  ChevronDown, 
  CheckCircle, 
  ChevronRight,
  Bell,
  Send,
  Upload,
  FileText,
  BookOpen,
  Settings,
  Shield,
  Star,
  MessageSquare,
  Lock,
  TrendingUp
} from 'lucide-react';
import { DashboardLayout } from '../components/layout/DashboardLayout';

// ─── TS Interfaces ───────────────────────────────────────────────────────────
interface Milestone {
  name: string;
  status: 'done' | 'progress' | 'pending';
}

interface Student {
  id: string;
  name: string;
  college: string;
  branch: string;
  semester: string;
  gpa: string;
  role: string;
  company: string;
  progress: number;
  matchScore: number;
  resumeScore: number;
  aptitudeScore: number;
  techSkillRating: number;
  softSkillRating: number;
  communicationRating: number;
  avatar: string;
  avatarBg: string;
  email: string;
  phone: string;
  notes: string[];
  skills: string[];
  attendance: number;
  milestones: Milestone[];
  pipelineStage: 'Enrolled' | 'Skill Assessment' | 'Learning Path' | 'Mentorship' | 'Mock Interview' | 'Placement Ready' | 'Hired';
}

interface Session {
  id: string;
  studentName: string;
  type: string;
  time: string;
  date: string;
  day: 'Mon' | 'Tue' | 'Wed' | 'Thu' | 'Fri';
  meetingLink?: string;
}

interface Task {
  id: string;
  name: string;
  studentName: string;
  dueDate: string;
  status: 'Pending' | 'Reviewed' | 'In Progress';
}



interface Message {
  id: string;
  sender: 'mentor' | 'student';
  text: string;
  timestamp: string;
}

interface Resource {
  id: string;
  title: string;
  category: 'Interview Questions' | 'Coding Sheets' | 'PDFs' | 'Resume Templates' | 'Company Experiences' | 'Videos';
  uploadedAt: string;
  size: string;
}

interface Notification {
  id: string;
  text: string;
  time: string;
  read: boolean;
}

interface Announcement {
  id: string;
  title: string;
  content: string;
  date: string;
  category: 'Workshop' | 'Deadline' | 'Policy' | 'Notice';
}

interface ActivityItem {
  id: string;
  text: string;
  time: string;
  done: boolean;
}

// ─── Initial Mock Databases ──────────────────────────────────────────────────
const initialStudents: Student[] = [
  {
    id: '1',
    name: 'Rahul Sharma',
    college: 'Delhi Technological University',
    branch: 'Computer Science',
    semester: '8th Semester',
    gpa: '9.2',
    role: 'Frontend Developer (React)',
    company: 'Stripe',
    progress: 82,
    matchScore: 94,
    resumeScore: 92,
    aptitudeScore: 88,
    techSkillRating: 90,
    softSkillRating: 85,
    communicationRating: 88,
    avatar: 'RS',
    avatarBg: 'bg-blue-600',
    email: 'rahul.sharma@dtu.edu',
    phone: '+91 98765 43210',
    notes: [
      'Sarah Jenkins: Completed mock system architecture challenge with Stripe parameters.',
      'Exhibits solid grasp of custom caching hooks and responsive dashboard setups.',
      'Needs slight layout tuning under grid overlays.'
    ],
    skills: ['React', 'TypeScript', 'TailwindCSS', 'Redux'],
    attendance: 95,
    milestones: [
      { name: 'Resume Completed', status: 'done' },
      { name: 'LinkedIn Profile', status: 'done' },
      { name: 'Aptitude Training', status: 'done' },
      { name: 'HR Interview', status: 'progress' },
      { name: 'Placement', status: 'pending' }
    ],
    pipelineStage: 'Mock Interview'
  },
  {
    id: '2',
    name: 'Priya Singh',
    college: 'NIT Trichy',
    branch: 'Information Technology',
    semester: '8th Semester',
    gpa: '8.8',
    role: 'Full Stack Engineer',
    company: 'Atlassian',
    progress: 74,
    matchScore: 88,
    resumeScore: 94,
    aptitudeScore: 86,
    techSkillRating: 88,
    softSkillRating: 82,
    communicationRating: 84,
    avatar: 'PS',
    avatarBg: 'bg-emerald-600',
    email: 'priya.singh@nitt.edu',
    phone: '+91 98765 43211',
    notes: [
      'Priya is very responsive. Code structure for Postgres pools looks clean.',
      'Struggles during high-stress complexity evaluations.'
    ],
    skills: ['Node.js', 'PostgreSQL', 'Go', 'Docker'],
    attendance: 92,
    milestones: [
      { name: 'Resume Completed', status: 'done' },
      { name: 'LinkedIn Profile', status: 'done' },
      { name: 'Aptitude Training', status: 'progress' },
      { name: 'HR Interview', status: 'pending' },
      { name: 'Placement', status: 'pending' }
    ],
    pipelineStage: 'Mentorship'
  },
  {
    id: '3',
    name: 'Anjali Gupta',
    college: 'IIT Bombay',
    branch: 'Industrial Design',
    semester: '8th Semester',
    gpa: '9.4',
    role: 'UI/UX Designer',
    company: 'Notion',
    progress: 80,
    matchScore: 91,
    resumeScore: 89,
    aptitudeScore: 92,
    techSkillRating: 84,
    softSkillRating: 94,
    communicationRating: 95,
    avatar: 'AG',
    avatarBg: 'bg-indigo-600',
    email: 'anjali@iitb.ac.in',
    phone: '+91 98765 43212',
    notes: [
      'Strong Figma typography layers and client-facing skills.',
      'Reviewing tokenization maps to optimize Tailwind layout generation.'
    ],
    skills: ['Figma', 'UI Design', 'Design Systems', 'HTML/CSS'],
    attendance: 96,
    milestones: [
      { name: 'Resume Completed', status: 'done' },
      { name: 'LinkedIn Profile', status: 'done' },
      { name: 'Aptitude Training', status: 'done' },
      { name: 'HR Interview', status: 'progress' },
      { name: 'Placement', status: 'pending' }
    ],
    pipelineStage: 'Placement Ready'
  },
  {
    id: '4',
    name: 'Gaurav  Verma',
    college: 'BITS Pilani',
    branch: 'Computer Science',
    semester: '8th Semester',
    gpa: '8.5',
    role: 'Software Engineer (Backend)',
    company: 'Vercel',
    progress: 68,
    matchScore: 85,
    resumeScore: 92,
    aptitudeScore: 80,
    techSkillRating: 82,
    softSkillRating: 78,
    communicationRating: 80,
    avatar: 'AV',
    avatarBg: 'bg-violet-600',
    email: 'Gaurav .verma@bits.edu',
    phone: '+91 98765 43213',
    notes: [
      'Completed distributed key-value storage challenges.',
      'Needs training on container setups.'
    ],
    skills: ['Java', 'Spring Boot', 'System Design', 'Redis'],
    attendance: 90,
    milestones: [
      { name: 'Resume Completed', status: 'done' },
      { name: 'LinkedIn Profile', status: 'progress' },
      { name: 'Aptitude Training', status: 'pending' },
      { name: 'HR Interview', status: 'pending' },
      { name: 'Placement', status: 'pending' }
    ],
    pipelineStage: 'Learning Path'
  },
  {
    id: '5',
    name: 'Divya Nair',
    college: 'Delhi Technological University',
    branch: 'Computer Science',
    semester: '8th Semester',
    gpa: '9.0',
    role: 'Backend Engineer',
    company: 'Stripe',
    progress: 78,
    matchScore: 93,
    resumeScore: 88,
    aptitudeScore: 90,
    techSkillRating: 84,
    softSkillRating: 82,
    communicationRating: 86,
    avatar: 'DN',
    avatarBg: 'bg-pink-650 bg-pink-600',
    email: 'divya@dtu.edu',
    phone: '+91 98765 43214',
    notes: [
      'Very strong with asynchronous queue pipelines.',
      'Suggested Stripe payment integration framework overview.'
    ],
    skills: ['Python', 'Django', 'PostgreSQL', 'Celery'],
    attendance: 94,
    milestones: [
      { name: 'Resume Completed', status: 'done' },
      { name: 'LinkedIn Profile', status: 'done' },
      { name: 'Aptitude Training', status: 'progress' },
      { name: 'HR Interview', status: 'pending' },
      { name: 'Placement', status: 'pending' }
    ],
    pipelineStage: 'Skill Assessment'
  },
  {
    id: '6',
    name: 'Sandeep Singh',
    college: 'Delhi Technological University',
    branch: 'Electronics',
    semester: '8th Semester',
    gpa: '8.4',
    role: 'QA Automation Engineer',
    company: 'Stripe',
    progress: 72,
    matchScore: 86,
    resumeScore: 90,
    aptitudeScore: 84,
    techSkillRating: 80,
    softSkillRating: 86,
    communicationRating: 78,
    avatar: 'SS',
    avatarBg: 'bg-yellow-600',
    email: 'sandeep@dtu.edu',
    phone: '+91 98765 43219',
    notes: [
      'Structured unit test script implementation.',
      'Identified critical routing loopholes in mock dashboard deployment.'
    ],
    skills: ['Jest', 'Cypress', 'Playwright', 'TypeScript'],
    attendance: 93,
    milestones: [
      { name: 'Resume Completed', status: 'done' },
      { name: 'LinkedIn Profile', status: 'done' },
      { name: 'Aptitude Training', status: 'progress' },
      { name: 'HR Interview', status: 'pending' },
      { name: 'Placement', status: 'pending' }
    ],
    pipelineStage: 'Enrolled'
  },
  {
    id: '7',
    name: 'Yash Vardhan',
    college: 'IIT Delhi',
    branch: 'Computer Science',
    semester: '8th Semester',
    gpa: '9.6',
    role: 'Site Reliability Engineer',
    company: 'Atlassian',
    progress: 96,
    matchScore: 97,
    resumeScore: 95,
    aptitudeScore: 96,
    techSkillRating: 96,
    softSkillRating: 92,
    communicationRating: 94,
    avatar: 'YV',
    avatarBg: 'bg-red-650 bg-red-600',
    email: 'yash@iitd.ac.in',
    phone: '+91 98765 43221',
    notes: [
      'Exemplary score values in SRE scenarios.',
      'Ready for direct production environment roles.'
    ],
    skills: ['Kubernetes', 'Prometheus', 'Linux', 'Go'],
    attendance: 98,
    milestones: [
      { name: 'Resume Completed', status: 'done' },
      { name: 'LinkedIn Profile', status: 'done' },
      { name: 'Aptitude Training', status: 'done' },
      { name: 'HR Interview', status: 'done' },
      { name: 'Placement', status: 'done' }
    ],
    pipelineStage: 'Hired'
  }
];

const initialSessions: Session[] = [
  {
    id: 's1',
    studentName: 'Rahul Sharma',
    type: 'Resume Review',
    time: '10:00 AM - 11:00 AM',
    date: 'Today',
    day: 'Mon',
    meetingLink: 'https://teams.microsoft.com/mock-rahul'
  },
  {
    id: 's2',
    studentName: 'Priya Singh',
    type: 'Mock Interview',
    time: '2:00 PM - 3:00 PM',
    date: 'Today',
    day: 'Mon',
    meetingLink: 'https://teams.microsoft.com/mock-priya'
  },
  {
    id: 's3',
    studentName: 'Anjali Gupta',
    type: 'Career Guidance',
    time: '5:00 PM - 6:00 PM',
    date: 'Today',
    day: 'Mon',
    meetingLink: 'https://teams.microsoft.com/mock-anjali'
  }
];

const initialTasks: Task[] = [
  { id: 't1', name: 'Project Proposal Review', studentName: 'Anjali Gupta', dueDate: '2026-06-30', status: 'Reviewed' },
  { id: 't2', name: 'UI Design Refactoring review', studentName: 'Anjali Gupta', dueDate: '2026-07-02', status: 'In Progress' },
  { id: 't3', name: 'Frontend Cache checklist', studentName: 'Rahul Sharma', dueDate: '2026-06-29', status: 'Pending' },
  { id: 't4', name: 'Postgres Pool configuration audit', studentName: 'Priya Singh', dueDate: '2026-07-05', status: 'Pending' }
];



const initialResources: Resource[] = [
  { id: 'r1', title: 'Stripe Frontend Mock Rubric', category: 'PDFs', uploadedAt: '2026-06-20', size: '1.2 MB' },
  { id: 'r2', title: 'System Design Interview Cheatsheet', category: 'Prep Kits', uploadedAt: '2026-06-18', size: '3.4 MB' } as any, // Cast due to strict union matching
  { id: 'r3', title: 'Resume Review Template Grid', category: 'Resume Templates', uploadedAt: '2026-06-22', size: '420 KB' },
  { id: 'r4', title: 'Company Mock coding sheets', category: 'Coding Sheets', uploadedAt: '2026-06-25', size: '1.8 MB' },
  { id: 'r5', title: 'DSA Cosine Embeddings logic video', category: 'Videos', uploadedAt: '2026-06-24', size: '920 MB' }
];

const initialNotifications: Notification[] = [
  { id: 'n1', text: 'Rahul Sharma submitted Project Proposal', time: '10m ago', read: false },
  { id: 'n2', text: 'Stripe Assessment Rubric modified', time: '4h ago', read: true }
];

const initialAnnouncements: Announcement[] = [
  { id: 'a1', title: 'Atlassian Placement freeze deadline', content: 'Portfolio submissions must be completed before July 5th.', date: 'Today', category: 'Deadline' },
  { id: 'a2', title: 'Technical Rubrics Seminar', content: 'Explore dynamic cosine index algorithms on Tuesday.', date: '2 days ago', category: 'Workshop' }
];

const initialActivityTicker: ActivityItem[] = [
  { id: 'act1', text: 'Rahul Sharma completed Java Assessment', time: '10m ago', done: true },
  { id: 'act2', text: 'Priya Singh uploaded Resume for review', time: '1h ago', done: true },
  { id: 'act3', text: 'Anjali Gupta completed Aptitude Mock', time: '4h ago', done: false },
  { id: 'act4', text: 'Gaurav  Verma initiated Learning Roadmap', time: '1d ago', done: true }
];

export const MentorDashboard: React.FC = () => {
  const { currentUser, logout } = useAuth();

  const getInitials = (name: string) => {
    return name
      .split(' ')
      .map((n) => n[0])
      .join('')
      .toUpperCase()
      .slice(0, 2);
  };

  // Navigation states
  const [activeTab, setActiveTab] = useState<'overview' | 'mentees' | 'sessions' | 'skills' | 'activity' | 'resources' | 'roadmaps' | 'communication' | 'feedback' | 'profile' | 'settings'>('overview');

  // Global UI States
  const [showDropdown, setShowDropdown] = useState(false);
  const [showNotifications, setShowNotifications] = useState(false);
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  // Data Collections States
  const [students, setStudents] = useState<Student[]>(initialStudents);
  const [sessions, setSessions] = useState<Session[]>(initialSessions);
  const [tasks] = useState<Task[]>(initialTasks);
  const [resources, setResources] = useState<Resource[]>(initialResources);
  const [notifications, setNotifications] = useState<Notification[]>(initialNotifications);
  const [announcements] = useState<Announcement[]>(initialAnnouncements);
  const [activityTicker, setActivityTicker] = useState<ActivityItem[]>(initialActivityTicker);

  // Tab 2: Mentee management states
  const [searchQuery, setSearchQuery] = useState('');
  const [activeStudentId, setActiveStudentId] = useState<string>('1');
  const [newNoteText, setNewNoteText] = useState('');

  // Selected student computation
  const activeStudent = students.find(s => s.id === activeStudentId) || students[0];

  // Tab 3: Session scheduler states
  const [showScheduleModal, setShowScheduleModal] = useState(false);
  const [newSessionStudent, setNewSessionStudent] = useState('');
  const [newSessionType, setNewSessionType] = useState('Resume Review');
  const [newSessionTime, setNewSessionTime] = useState('10:00 AM - 11:00 AM');
  const [newSessionDate, setNewSessionDate] = useState('Today');
  const [newSessionDay, setNewSessionDay] = useState<'Mon' | 'Tue' | 'Wed' | 'Thu' | 'Fri'>('Mon');

  // Tab 8: Feedback form states
  const [feedbackStudent, setFeedbackStudent] = useState('Rahul Sharma');
  const [techRating, setTechRating] = useState(4);
  const [commRating, setCommRating] = useState(4);
  const [feedbackComments, setFeedbackComments] = useState('');

  // Tab 10: Resource states
  const [newResourceTitle, setNewResourceTitle] = useState('');
  const [newResourceCategory, setNewResourceCategory] = useState<'Interview Questions' | 'Coding Sheets' | 'PDFs' | 'Resume Templates' | 'Company Experiences' | 'Videos'>('PDFs');
  const [resourceFilter, setResourceFilter] = useState<string>('All');

  // Tab 11: Communication workspace states
  const [activeChatStudent, setActiveChatStudent] = useState<string>('Rahul Sharma');
  const [activeChatChannel, setActiveChatChannel] = useState<'direct' | 'group' | 'announcements' | 'boards'>('direct');
  const [activeGroupChannel, setActiveGroupChannel] = useState<string>('#stripe-frontend');
  const [typedMessage, setTypedMessage] = useState('');
  const [chatHistory, setChatHistory] = useState<Record<string, Message[]>>({
    'Rahul Sharma': [
      { id: '1', sender: 'student', text: 'Hey Sarah, is the mock rubric ready?', timestamp: '2:30 PM' },
      { id: '2', sender: 'mentor', text: 'Yes, just uploaded to your profile resources block.', timestamp: '2:35 PM' }
    ],
    'Priya Singh': [
      { id: '1', sender: 'student', text: 'Hi Sarah, completed the postgres schema modifications.', timestamp: 'Yesterday' }
    ],
    'Anjali Gupta': [
      { id: '1', sender: 'student', text: 'Sarah, I pushed the updated Figma link to the repo.', timestamp: '3 days ago' },
      { id: '2', sender: 'mentor', text: 'Excellent, I will review it tonight and log feedback.', timestamp: '3 days ago' }
    ],
    '#stripe-frontend': [
      { id: 'c1', sender: 'student', text: 'Is anyone working on the custom hooks cache lab?', timestamp: '10:15 AM' },
      { id: 'c2', sender: 'mentor', text: 'Rahul is currently reviewing cache parameters there.', timestamp: '10:20 AM' }
    ],
    '#atlassian-cohort': [
      { id: 'c1', sender: 'student', text: 'System design files are pinned in resources.', timestamp: 'Yesterday' }
    ]
  });
  const [isTyping, setIsTyping] = useState(false);

  // Tab 12: Settings states
  const [darkMode, setDarkMode] = useState(false);
  const [pushAlerts, setPushAlerts] = useState(true);
  const [privacyMode, setPrivacyMode] = useState(false);
  const [alertsLimit, setAlertsLimit] = useState('10');
  const [selectedLanguage, setSelectedLanguage] = useState('English');
  const [availabilitySwitch, setAvailabilitySwitch] = useState(true);
  const [showPasswordResetModal, setShowPasswordResetModal] = useState(false);

  // Helper trigger toast
  const triggerToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 3500);
  };

  // Add notes to current student
  const handleAddNote = () => {
    if (!newNoteText.trim()) return;
    setStudents(prev => prev.map(s => {
      if (s.id === activeStudentId) {
        return { ...s, notes: [newNoteText, ...s.notes] };
      }
      return s;
    }));
    setNewNoteText('');
    triggerToast('Note successfully logged.');
  };

  // Create new session
  const handleCreateSession = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newSessionStudent) {
      triggerToast('Please select a student.');
      return;
    }
    const newSession: Session = {
      id: `s_${Date.now()}`,
      studentName: newSessionStudent,
      type: newSessionType,
      time: newSessionTime,
      date: newSessionDate,
      day: newSessionDay,
      meetingLink: 'https://teams.microsoft.com/mock-link-added'
    };
    setSessions([newSession, ...sessions]);
    setShowScheduleModal(false);
    triggerToast(`Session scheduled with ${newSessionStudent}`);
  };

  // Submit Star Evaluation Feedback
  const handleSendFeedback = (e: React.FormEvent) => {
    e.preventDefault();
    const comment = feedbackComments.trim() || 'No comments.';
    const formattedEval = `Sarah Jenkins (Evaluation - Tech: ${techRating}/5, Comm: ${commRating}/5): ${comment}`;

    // Append to student's notes
    setStudents(prev => prev.map(s => {
      if (s.name === feedbackStudent) {
        return { ...s, notes: [formattedEval, ...s.notes] };
      }
      return s;
    }));

    triggerToast(`Evaluation feedback logged for ${feedbackStudent}`);
    setFeedbackComments('');
  };

  // Send Chat message
  const handleSendMessage = () => {
    if (!typedMessage.trim()) return;
    const targetKey = activeChatChannel === 'direct' ? activeChatStudent : activeGroupChannel;
    
    const newMsg: Message = {
      id: `m_${Date.now()}`,
      sender: 'mentor',
      text: typedMessage,
      timestamp: 'Just now'
    };

    setChatHistory(prev => ({
      ...prev,
      [targetKey]: [...(prev[targetKey] || []), newMsg]
    }));
    setTypedMessage('');

    // Simulate student typing response after 2 seconds
    setIsTyping(true);
    setTimeout(() => {
      setIsTyping(false);
      let replyText = 'Thanks Sarah! Checking resources right away.';
      if (activeChatChannel === 'direct') {
        if (activeChatStudent === 'Rahul Sharma') {
          replyText = 'Thanks Sarah, checking the frontend cache implementation now!';
        } else if (activeChatStudent === 'Priya Singh') {
          replyText = 'Understood, updating the Postgres index schema parameters.';
        } else if (activeChatStudent === 'Anjali Gupta') {
          replyText = 'Design tokens are ready, let me know when you review the Figma link!';
        }
      }
      const autoResponse: Message = {
        id: `m_${Date.now() + 1}`,
        sender: 'student',
        text: replyText,
        timestamp: 'Just now'
      };
      setChatHistory(prev => ({
        ...prev,
        [targetKey]: [...(prev[targetKey] || []), autoResponse]
      }));
    }, 2000);
  };

  // Add Resource Share
  const handleAddResource = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newResourceTitle.trim()) return;
    const newRes: Resource = {
      id: `r_${Date.now()}`,
      title: newResourceTitle,
      category: newResourceCategory,
      uploadedAt: new Date().toISOString().split('T')[0],
      size: '1.5 MB'
    };
    setResources([newRes, ...resources]);
    setNewResourceTitle('');
    triggerToast(`Resource shared: ${newRes.title}`);
  };

  // Toggle OKR Item
  const toggleProgressItem = (studentId: string, milestoneIndex: number) => {
    setStudents(prev => prev.map(s => {
      if (s.id === studentId) {
        const updatedMilestones = s.milestones.map((m, idx): Milestone => {
          if (idx === milestoneIndex) {
            const nextStatus: 'done' | 'progress' | 'pending' = m.status === 'done' ? 'pending' : m.status === 'pending' ? 'progress' : 'done';
            return { ...m, status: nextStatus };
          }
          return m;
        });

        // Calculate progress percentage
        const doneCount = updatedMilestones.filter(m => m.status === 'done').length;
        const progressCount = updatedMilestones.filter(m => m.status === 'progress').length;
        const calculatedProgress = Math.round((doneCount * 33) + (progressCount * 15) + 30);
        const finalProgress = calculatedProgress > 100 ? 100 : calculatedProgress;

        return {
          ...s,
          milestones: updatedMilestones,
          progress: finalProgress
        };
      }
      return s;
    }));
    triggerToast('Milestone status toggled.');
  };

  // Activity checkbox ticker toggle
  const toggleActivityTicker = (id: string) => {
    setActivityTicker(prev => prev.map(item => {
      if (item.id === id) {
        return { ...item, done: !item.done };
      }
      return item;
    }));
  };

  return (
    <DashboardLayout>
      <div className={`dashboard-shell min-h-screen font-sans antialiased flex flex-col md:flex-row transition-colors duration-300 ${
        darkMode ? 'bg-slate-950 text-slate-100' : 'bg-slate-50/50 text-slate-800'
      }`}>
        
        {/* Toast Notification */}
        {toastMessage && (
          <div className="fixed bottom-5 right-5 z-[99999] flex items-center gap-3 bg-slate-900 text-white px-5 py-3.5 rounded-xl shadow-2xl border border-slate-800 animate-slide-in">
            <Sparkles className="w-5 h-5 text-purple-400" />
            <span className="text-sm font-semibold">{toastMessage}</span>
            <button onClick={() => setToastMessage(null)} className="text-slate-400 hover:text-white ml-2">
              <X className="w-4 h-4" />
            </button>
          </div>
        )}

        {/* Sidebar Nav */}
        <aside className={`dashboard-sidebar w-full md:w-64 shrink-0 flex flex-col justify-between border-r transition-colors duration-300 ${
          darkMode ? 'bg-slate-900 border-slate-800 text-slate-400' : 'bg-slate-900 text-slate-400 border-slate-850'
        }`}>
          <div className="p-6">
            <div className="flex items-center gap-3 px-2 mb-8">
              <div className="w-8 h-8 rounded-lg bg-gradient-to-r from-purple-650 to-indigo-650 flex items-center justify-center text-xs font-black text-white shadow-md shadow-purple-500/20">C2C</div>
              <div>
                <span className="text-xs block text-slate-500 uppercase tracking-widest font-black leading-none">Ashoksoft</span>
                <span className="text-sm block text-white font-extrabold tracking-tight mt-1">C2C Mentorship</span>
              </div>
            </div>
            
            <nav className="space-y-1">
              {[
                { id: 'overview', label: 'Dashboard Overview', icon: BookOpen },
                { id: 'mentees', label: 'Student Analytics', icon: Users },
                { id: 'sessions', label: 'Session Timeline', icon: Calendar },
                { id: 'skills', label: 'Employability Matrix', icon: Award },
                { id: 'activity', label: 'Activity & Leaderboard', icon: TrendingUp },
                { id: 'resources', label: 'Shared Material Library', icon: Upload },
                { id: 'roadmaps', label: 'Career Roadmaps', icon: CheckCircle },
                { id: 'communication', label: 'Communication Hub', icon: MessageSquare },
                { id: 'feedback', label: 'Feedback Section', icon: Star },
                { id: 'profile', label: 'Mentor Profile', icon: Shield },
                { id: 'settings', label: 'System Settings', icon: Settings }
              ].map(tab => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id as any)}
                  className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-bold transition-all cursor-pointer ${
                    activeTab === tab.id
                      ? 'bg-gradient-to-r from-purple-650 to-indigo-650 text-white shadow-lg shadow-purple-600/10'
                      : 'hover:bg-slate-800 hover:text-white'
                  }`}
                >
                  <tab.icon className="w-4.5 h-4.5 shrink-0" />
                  <span>{tab.label}</span>
                </button>
              ))}
            </nav>
          </div>

          <div className="p-6 border-t border-slate-800 text-left">
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 rounded-full bg-gradient-to-r from-purple-600 to-indigo-650 flex items-center justify-center font-bold text-white text-xs">
                {getInitials(currentUser?.fullName || 'Sarah Jenkins')}
              </div>
              <div>
                <h4 className="text-xs font-bold text-white">{currentUser?.fullName || 'Sarah Jenkins'}</h4>
                <p className="text-[10px] text-slate-500 font-medium">Mentor ID: M-2026</p>
              </div>
            </div>
          </div>
        </aside>

        {/* Right Main Content */}
        <div className="flex-1 flex flex-col min-w-0">
          
          {/* Header Bar */}
          <header className={`h-20 border-b flex items-center justify-between px-6 shrink-0 relative z-35 transition-colors duration-300 ${
            darkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-100'
          }`}>
            <div className="flex items-center gap-3">
              <h2 className={`text-base font-bold tracking-tight capitalize ${
                darkMode ? 'text-white' : 'text-slate-900'
              }`}>
                {activeTab.replace('_', ' ')} sub-workspace
              </h2>
            </div>

            <div className="flex items-center gap-4">
              
              {/* Notification Center */}
              <div className="relative">
                <button 
                  onClick={() => {
                    setShowNotifications(!showNotifications);
                    setShowDropdown(false);
                  }}
                  className={`w-10 h-10 rounded-xl border flex items-center justify-center relative transition-all cursor-pointer ${
                    darkMode ? 'bg-slate-800 border-slate-700 text-slate-300 hover:bg-slate-700' : 'bg-slate-50 border-slate-200/60 text-slate-600 hover:bg-slate-100'
                  }`}
                >
                  <Bell className="w-5 h-5" />
                  {notifications.length > 0 && (
                    <span className="absolute top-2.5 right-2.5 w-2 h-2 rounded-full bg-purple-500 border border-white"></span>
                  )}
                </button>

                {showNotifications && (
                  <div className={`absolute right-0 mt-2 w-80 rounded-xl shadow-2xl border p-2 z-[9999] animate-fade-in text-left ${
                    darkMode ? 'bg-slate-900 border-slate-800 text-slate-300' : 'bg-white border-slate-100 text-slate-800'
                  }`}>
                    <div className="px-3 py-2 border-b flex items-center justify-between border-slate-100/10">
                      <span className={`text-xs font-extrabold uppercase tracking-wide ${darkMode ? 'text-white' : 'text-slate-900'}`}>Live Alerts</span>
                      <button 
                        onClick={() => {
                          setNotifications([]);
                          triggerToast('Alert checklist cleared.');
                        }}
                        className="text-[10px] font-bold text-purple-400 hover:text-purple-300"
                      >
                        Clear All
                      </button>
                    </div>
                    <div className="max-h-64 overflow-y-auto mt-1 space-y-1">
                      {notifications.length === 0 ? (
                        <p className="text-xs text-slate-500 py-6 text-center font-medium">No active alerts</p>
                      ) : (
                        notifications.map((notif) => (
                          <div key={notif.id} className={`p-2.5 rounded-lg flex justify-between gap-3 text-xs border border-transparent hover:border-slate-850/50 ${
                            darkMode ? 'hover:bg-slate-850' : 'hover:bg-slate-50'
                          }`}>
                            <div>
                              <p className={`font-semibold ${notif.read ? 'text-slate-500' : 'text-slate-300'}`}>{notif.text}</p>
                              <span className="text-[10px] text-slate-500 block mt-1">{notif.time}</span>
                            </div>
                          </div>
                        ))
                      )}
                    </div>
                  </div>
                )}
              </div>

              {/* Profile Menu Toggle */}
              <div className="relative">
                <button
                  onClick={() => {
                    setShowDropdown(!showDropdown);
                    setShowNotifications(false);
                  }}
                  className={`flex items-center gap-2 p-1 rounded-full border transition-all cursor-pointer ${
                    darkMode ? 'bg-slate-800 border-slate-700 hover:bg-slate-700' : 'bg-slate-50 border-slate-200/50 hover:bg-slate-100'
                  }`}
                >
                  <div className="w-8 h-8 rounded-full bg-gradient-to-r from-purple-650 to-indigo-650 flex items-center justify-center font-bold text-white text-xs">
                    {getInitials(currentUser?.fullName || 'Sarah Jenkins')}
                  </div>
                  <ChevronDown className="w-3.5 h-3.5 text-slate-400" />
                </button>

                {showDropdown && (
                  <div className={`absolute right-0 mt-2 w-56 rounded-xl shadow-2xl border py-1 z-[9999] animate-fade-in text-left ${
                    darkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-100'
                  }`}>
                    <div className="p-3 border-b border-slate-100/10">
                      <h4 className={`font-bold text-xs ${darkMode ? 'text-white' : 'text-slate-900'}`}>{currentUser?.fullName || 'Sarah Jenkins'}</h4>
                      <p className="text-[10px] text-slate-400 font-semibold">Principal SE • Stripe</p>
                    </div>
                    {['My profile info', 'Rubric settings'].map(item => (
                      <button 
                        key={item}
                        onClick={() => {
                          setShowDropdown(false);
                          if (item === 'My profile info') setActiveTab('profile');
                          else if (item === 'Rubric settings') setActiveTab('settings');
                        }}
                        className={`w-full text-left px-3.5 py-2 text-xs font-semibold hover:bg-slate-50/10 transition-colors ${
                          darkMode ? 'text-slate-300 hover:bg-slate-800' : 'text-slate-600 hover:bg-slate-50'
                        }`}
                      >
                        {item}
                      </button>
                    ))}
                    <button 
                      onClick={logout}
                      className="w-full text-left px-3.5 py-2 text-xs font-bold transition-colors border-t border-slate-100/10 mt-1 text-red-500 hover:bg-red-500/10 cursor-pointer"
                    >
                      Sign Out
                    </button>
                  </div>
                )}
              </div>

            </div>
          </header>

          {/* Main workspace */}
          <main className="dashboard-main flex-1 p-6 overflow-y-auto">

            {/* TAB 1: OVERVIEW */}
            {activeTab === 'overview' && (
              <div className="space-y-6 animate-fade-in text-left">
                
                {/* 1. Personalized Hero & Action Zone */}
                <div className={`rounded-3xl border p-6 md:p-8 shadow-sm flex flex-col md:flex-row justify-between items-start md:items-center gap-6 ${
                  darkMode ? 'bg-slate-900 border-slate-800 text-white' : 'bg-white border-slate-100 text-slate-900'
                }`}>
                  <div className="space-y-2">
                    <div className="flex items-center gap-2 text-purple-400 font-bold text-xs">
                      <Sparkles className="w-4.5 h-4.5" />
                      <span>{currentUser ? `${currentUser.fullName.split(' ')[0]}'s Workspace` : "Dr. Sarah's Workspace"}</span>
                    </div>
                    <h1 className={`text-lg md:text-xl font-extrabold tracking-tight`}>
                      {currentUser ? `Welcome Back, ${currentUser.fullName.split(' ')[0]}! Guide students, monitor their growth, and help shape the next generation of industry-ready professionals.` : "Welcome Back, Dr. Sarah! Guide students, monitor their growth, and help shape the next generation of industry-ready professionals."}
                    </h1>
                    <p className="text-xs text-slate-400 font-semibold">
                      {"Access live evaluations, project code check-ins, and student metrics from the Stripe candidate queue."}
                    </p>
                  </div>

                  <div className="flex flex-wrap gap-2.5 shrink-0 w-full md:w-auto">
                    <button
                      onClick={() => setShowScheduleModal(true)}
                      className="px-4 py-2 bg-[#5e17eb] hover:bg-[#4b12bc] text-white font-bold rounded-xl text-xs flex items-center gap-1.5 cursor-pointer shadow-md shadow-purple-500/20"
                    >
                      <Calendar className="w-4 h-4" />
                      <span>📅 Schedule Session</span>
                    </button>
                    <button
                      onClick={() => setActiveTab('mentees')}
                      className={`px-4 py-2 border rounded-xl font-bold text-xs flex items-center gap-1.5 cursor-pointer transition-colors ${
                        darkMode ? 'border-slate-800 hover:bg-slate-800 text-slate-300' : 'border-slate-200 hover:bg-slate-50 text-slate-700'
                      }`}
                    >
                      <Users className="w-4 h-4" />
                      <span>👥 View Students</span>
                    </button>
                    <button
                      onClick={() => setActiveTab('feedback')}
                      className={`px-4 py-2 border rounded-xl font-bold text-xs flex items-center gap-1.5 cursor-pointer transition-colors ${
                        darkMode ? 'border-slate-800 hover:bg-slate-800 text-slate-300' : 'border-slate-200 hover:bg-slate-50 text-slate-700'
                      }`}
                    >
                      <Star className="w-4 h-4" />
                      <span>✍ Add Feedback</span>
                    </button>
                  </div>
                </div>

                {/* 2. Mentor Performance Overview Counters */}
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                  {[
                    { label: 'Students Assigned', val: `${students.length} Total`, sub: 'Active cohorts', icon: Users, text: 'text-blue-600', bg: 'bg-blue-50 border-blue-100' },
                    { label: 'Sessions This Week', val: `${sessions.length} Slots`, sub: 'Scheduled mock trials', icon: Calendar, text: 'text-emerald-600', bg: 'bg-emerald-50 border-emerald-100' },
                    { label: 'Average Mentor Rating', val: '4.95 / 5.00', sub: 'Calculated this term', icon: Star, text: 'text-amber-600', bg: 'bg-amber-50 border-amber-100' },
                    { label: 'Placement-Ready Students', val: `${students.filter(s => s.progress >= 80).length} Candidates`, sub: 'Readiness Score >= 80%', icon: Award, text: 'text-purple-600', bg: 'bg-purple-50 border-purple-100' },
                    { label: 'Feedback Pending', val: `${tasks.filter(t => t.status === 'Pending').length} Reviews`, sub: 'Needs feedback checks', icon: Clock, text: 'text-pink-600', bg: 'bg-pink-50 border-pink-100' },
                    { label: 'Students Placed', val: `${students.filter(s => s.pipelineStage === 'Hired').length} Hired`, sub: 'Matched successfully', icon: Shield, text: 'text-cyan-600', bg: 'bg-cyan-50 border-cyan-100' }
                  ].map((stat, i) => (
                    <div key={i} className={`border rounded-2xl p-5 shadow-sm hover:shadow-md transition-all flex items-center justify-between ${
                      darkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-100'
                    }`}>
                      <div>
                        <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">{stat.label}</p>
                        <h3 className={`text-xl font-black mt-1 ${darkMode ? 'text-white' : 'text-slate-900'}`}>{stat.val}</h3>
                        <span className="text-[10px] text-slate-400 mt-1 block font-medium">{stat.sub}</span>
                      </div>
                      <div className={`w-11 h-11 rounded-xl flex items-center justify-center border ${stat.bg} ${stat.text}`}>
                        <stat.icon className="w-5.5 h-5.5" />
                      </div>
                    </div>
                  ))}
                </div>

                {/* 3. Interactive Student Pipeline Journey */}
                <div className={`rounded-2xl border p-6 shadow-sm space-y-6 ${
                  darkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-100'
                }`}>
                  <div>
                    <h3 className={`text-sm font-bold ${darkMode ? 'text-white' : 'text-slate-900'}`}>Interactive Student Pipeline Journey</h3>
                    <p className="text-xs text-slate-400 mt-0.5">Progressive layout tracking system mapping milestone states.</p>
                  </div>

                  <div className="overflow-x-auto pb-4">
                    <div className="flex items-center justify-between min-w-[800px] px-4 relative">
                      {/* Connecting lines vector background */}
                      <div className="absolute top-[28px] left-[6%] right-[6%] h-1 bg-slate-200/50 -z-10 rounded-full"></div>

                      {(['Enrolled', 'Skill Assessment', 'Learning Path', 'Mentorship', 'Mock Interview', 'Placement Ready', 'Hired'] as const).map((stage, sIdx) => {
                        const stageStudents = students.filter(s => s.pipelineStage === stage);
                        return (
                          <div key={sIdx} className="flex flex-col items-center space-y-3 relative z-10 w-28 text-center">
                            
                            {/* Circle Stage Bubble */}
                            <div className={`w-14 h-14 rounded-full border-4 flex flex-col items-center justify-center transition-all ${
                              stageStudents.length > 0 
                                ? 'bg-purple-600 border-white text-white shadow-lg shadow-purple-650/20' 
                                : darkMode ? 'bg-slate-900 border-slate-800 text-slate-500' : 'bg-slate-50 border-slate-200 text-slate-400'
                            }`}>
                              <span className="text-xs font-black">{stageStudents.length}</span>
                            </div>

                            <div className="space-y-1">
                              <p className={`text-[10px] font-black ${darkMode ? 'text-slate-300' : 'text-slate-800'}`}>{stage}</p>
                              
                              {/* Avatar metrics overlay */}
                              <div className="flex -space-x-1 justify-center">
                                {stageStudents.map((st) => (
                                  <div 
                                    key={st.id} 
                                    title={`${st.name} (${st.college})`}
                                    onClick={() => {
                                      setActiveStudentId(st.id);
                                      setActiveTab('mentees');
                                    }}
                                    className={`w-4 h-4 rounded-full border border-white flex items-center justify-center text-[6px] font-black text-white cursor-pointer ${st.avatarBg}`}
                                  >
                                    {st.avatar}
                                  </div>
                                ))}
                              </div>
                            </div>
                          </div>
                        );
                      })}
                    </div>
                  </div>
                </div>

                {/* Live Bulletins & AI Quick Insights Panel */}
                <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                  
                  {/* Announcements bulletin */}
                  <div className={`lg:col-span-2 rounded-2xl border p-6 shadow-sm ${
                    darkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-100'
                  }`}>
                    <h3 className={`text-sm font-bold mb-4 tracking-tight ${darkMode ? 'text-white' : 'text-slate-900'}`}>Announcements Bulletin Feed</h3>
                    <div className="space-y-3.5 max-h-[300px] overflow-y-auto pr-1">
                      {announcements.map((ann) => (
                        <div key={ann.id} className={`p-3 rounded-xl border text-xs ${
                          darkMode ? 'bg-slate-950 border-slate-850' : 'bg-slate-50 border-slate-100'
                        }`}>
                          <div className="flex justify-between items-center mb-1">
                            <span className={`font-extrabold ${darkMode ? 'text-white' : 'text-slate-800'}`}>{ann.title}</span>
                            <span className="text-[8px] font-bold text-purple-600 bg-purple-50 px-1.5 py-0.5 rounded border border-purple-100 shrink-0">{ann.category}</span>
                          </div>
                          <p className="text-slate-400 mt-1 font-semibold">{ann.content}</p>
                          <span className="text-[10px] text-slate-500 block mt-2 font-mono">{ann.date}</span>
                        </div>
                      ))}
                    </div>
                  </div>

                  {/* AI Quick Insights & Personal Goals Tracker */}
                  <div className={`rounded-2xl border p-6 shadow-sm flex flex-col justify-between ${
                    darkMode ? 'bg-slate-900 border-slate-800 text-slate-300' : 'bg-white border-slate-100 text-slate-800'
                  }`}>
                    <div className="space-y-5 text-xs text-left">
                      <h3 className={`text-sm font-bold tracking-tight ${darkMode ? 'text-white' : 'text-slate-900'}`}>AI Insights & Targets</h3>
                      
                      {/* Insights List (Module 15) */}
                      <div className="space-y-2">
                        {[
                          { text: '12 students are placement-ready', status: 'optimal' },
                          { text: 'Resume quality has improved by 18%', status: 'optimal' },
                          { text: '3 mock interviews pending review', status: 'warning' }
                        ].map((insight, idx) => (
                          <div key={idx} className={`p-2.5 rounded-lg border font-semibold flex items-center gap-2 ${
                            insight.status === 'optimal' 
                              ? 'bg-emerald-50/5 border-emerald-550/10 text-emerald-400' 
                              : 'bg-amber-50/5 border-amber-550/10 text-amber-400'
                          }`}>
                            <Sparkles className="w-3.5 h-3.5 shrink-0" />
                            <span>{insight.text}</span>
                          </div>
                        ))}
                      </div>

                      {/* Personal Goal Metric Tracker (Module 16) */}
                      <div className="space-y-3 pt-3 border-t border-slate-100/10 font-semibold text-slate-400">
                        <span className="text-[9px] uppercase tracking-wider font-bold block text-slate-500"> Sarah Jenkins Goals</span>
                        
                        {[
                          { label: 'Conduct Sessions', progress: 9, total: 10 },
                          { label: 'Resume Reviews', progress: 7, total: 10 },
                          { label: 'Mock Interviews', progress: 8, total: 10 }
                        ].map((goal, idx) => (
                          <div key={idx} className="space-y-1">
                            <div className="flex justify-between font-mono text-[10px]">
                              <span>{goal.label}</span>
                              <span>{goal.progress} / {goal.total}</span>
                            </div>
                            <div className={`w-full h-1.5 rounded-full overflow-hidden ${darkMode ? 'bg-slate-850' : 'bg-slate-150'}`}>
                              <div className="bg-purple-500 h-full" style={{ width: `${(goal.progress / goal.total) * 100}%` }}></div>
                            </div>
                          </div>
                        ))}
                      </div>

                    </div>
                  </div>

                </div>

              </div>
            )}

            {/* TAB 2: DETAILED STUDENT PROGRESS ANALYTICS */}
            {activeTab === 'mentees' && (
              <div className="space-y-6 animate-fade-in text-left">
                
                <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
                  
                  {/* Left Column: Student Roster selector */}
                  <div className={`lg:col-span-4 border p-5 rounded-2xl shadow-sm space-y-4 ${
                    darkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-100'
                  }`}>
                    <div>
                      <h3 className={`text-sm font-bold ${darkMode ? 'text-white' : 'text-slate-900'}`}>Assigned Student Roster</h3>
                      <p className="text-xs text-slate-400 mt-0.5">Select a student record to inspect metrics.</p>
                    </div>

                    <div className="relative">
                      <span className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <Search className="w-4 h-4 text-slate-400" />
                      </span>
                      <input
                        type="text"
                        placeholder="Search student..."
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        className={`w-full pl-9 pr-4 py-2 text-xs border rounded-xl focus:outline-none focus:ring-1 focus:ring-purple-500 ${
                          darkMode ? 'bg-slate-800 border-slate-700 text-white' : 'bg-slate-50 border-slate-200'
                        }`}
                      />
                    </div>

                    <div className="space-y-1.5 max-h-[360px] overflow-y-auto pr-1">
                      {students
                        .filter(s => s.name.toLowerCase().includes(searchQuery.toLowerCase()))
                        .map((st) => (
                          <div 
                            key={st.id} 
                            onClick={() => setActiveStudentId(st.id)}
                            className={`p-3 rounded-xl border flex items-center justify-between cursor-pointer transition-colors ${
                              activeStudentId === st.id 
                                ? 'bg-purple-600/10 border-purple-500 text-purple-400' 
                                : darkMode ? 'bg-slate-950 border-slate-850 text-slate-400 hover:bg-slate-800' : 'bg-slate-50 border-slate-100 text-slate-700 hover:bg-slate-100/50'
                            }`}
                          >
                            <div className="flex items-center gap-2.5">
                              <div className={`w-7.5 h-7.5 rounded-lg flex items-center justify-center text-white font-bold text-[10px] ${st.avatarBg}`}>
                                {st.avatar}
                              </div>
                              <div className="text-left font-bold">
                                <p className={activeStudentId === st.id ? 'text-purple-400' : darkMode ? 'text-slate-300' : 'text-slate-800'}>{st.name}</p>
                                <span className="text-[9px] text-slate-500 block font-semibold mt-0.5">{st.college}</span>
                              </div>
                            </div>
                            <ChevronRight className="w-4 h-4 text-slate-400" />
                          </div>
                        ))}
                    </div>
                  </div>

                  {/* Right Column: Deep Student Progress Analytics */}
                  <div className={`lg:col-span-8 border p-6 rounded-2xl shadow-sm text-xs text-slate-400 space-y-6 ${
                    darkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-100'
                  }`}>
                    
                    {/* Header profile info */}
                    <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                      <div className="flex items-center gap-3">
                        <div className={`w-14 h-14 rounded-2xl flex items-center justify-center text-white font-bold text-lg ${activeStudent.avatarBg}`}>
                          {activeStudent.avatar}
                        </div>
                        <div className="text-left">
                          <h3 className={`font-black text-sm ${darkMode ? 'text-white' : 'text-slate-900'}`}>{activeStudent.name}</h3>
                          <p className="font-semibold text-slate-500">{activeStudent.college} • {activeStudent.branch}</p>
                          <span className="text-[9px] text-purple-400 font-bold uppercase tracking-wider block mt-1">{activeStudent.semester}</span>
                        </div>
                      </div>

                      {/* circular progress tracking widget */}
                      <div className="flex items-center gap-3 bg-slate-50/5 p-3 rounded-2xl border border-slate-100/10">
                        <div className="relative w-12 h-12 shrink-0">
                          <svg className="w-full h-full" viewBox="0 0 36 36">
                            <circle cx="18" cy="18" r="15.915" fill="transparent" stroke={darkMode ? '#334155' : '#f1f5f9'} strokeWidth="3" />
                            <circle cx="18" cy="18" r="15.915" fill="transparent" stroke="#8b5cf6" strokeWidth="3" strokeDasharray={`${activeStudent.progress} 100`} strokeLinecap="round" />
                          </svg>
                          <div className={`absolute inset-0 flex items-center justify-center font-mono text-[9px] font-black ${darkMode ? 'text-white' : 'text-slate-800'}`}>
                            {activeStudent.progress}%
                          </div>
                        </div>
                        <div className="leading-tight text-left font-bold">
                          <p className={`text-[10px] ${darkMode ? 'text-slate-350' : 'text-slate-800'}`}>Readiness Score</p>
                          <span className="text-[8px] text-slate-500 font-medium block mt-0.5">Overall Placement Ready</span>
                        </div>
                      </div>
                    </div>

                    {/* Skill scores & parameters list */}
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-6 pt-5 border-t border-slate-100/10">
                      
                      <div className="space-y-3">
                        <h4 className={`font-bold uppercase tracking-wider text-[9px] ${darkMode ? 'text-slate-300' : 'text-slate-500'}`}>Employability metrics</h4>
                        <div className="space-y-2.5 font-bold font-mono">
                          <div className="flex justify-between items-center">
                            <span>Resume score:</span>
                            <span className="text-purple-400">{activeStudent.resumeScore} / 100</span>
                          </div>
                          <div className="flex justify-between items-center">
                            <span>Aptitude score:</span>
                            <span className="text-purple-400">{activeStudent.aptitudeScore} / 100</span>
                          </div>
                          <div className="flex justify-between items-center">
                            <span>Attendance rate:</span>
                            <span className="text-emerald-500">{activeStudent.attendance}%</span>
                          </div>
                        </div>
                      </div>

                      <div className="space-y-3">
                        <h4 className={`font-bold uppercase tracking-wider text-[9px] ${darkMode ? 'text-slate-300' : 'text-slate-500'}`}>Skills Assessment ratings</h4>
                        <div className="space-y-2.5 font-bold">
                          <div className="space-y-1">
                            <div className="flex justify-between text-[10px]">
                              <span>Technical Skill:</span>
                              <span>{activeStudent.techSkillRating}%</span>
                            </div>
                            <div className={`w-full h-1.5 rounded-full overflow-hidden ${darkMode ? 'bg-slate-800' : 'bg-slate-150'}`}>
                              <div className="bg-purple-500 h-full" style={{ width: `${activeStudent.techSkillRating}%` }}></div>
                            </div>
                          </div>
                          <div className="space-y-1">
                            <div className="flex justify-between text-[10px]">
                              <span>Communication & Soft skills:</span>
                              <span>{activeStudent.communicationRating}%</span>
                            </div>
                            <div className={`w-full h-1.5 rounded-full overflow-hidden ${darkMode ? 'bg-slate-800' : 'bg-slate-150'}`}>
                              <div className="bg-purple-500 h-full" style={{ width: `${activeStudent.communicationRating}%` }}></div>
                            </div>
                          </div>
                        </div>
                      </div>

                    </div>

                    {/* Private Notes Vault (Module 14) */}
                    <div className="space-y-3 pt-5 border-t border-slate-100/10">
                      <h4 className={`font-bold uppercase tracking-wider text-[9px] ${darkMode ? 'text-slate-300' : 'text-slate-500'}`}>Private Notes Vault</h4>
                      <div className="space-y-2 max-h-36 overflow-y-auto pr-1">
                        {activeStudent.notes.map((note, nIdx) => (
                          <div key={nIdx} className={`p-2.5 rounded-lg border font-semibold leading-relaxed text-left ${
                            darkMode ? 'bg-slate-950 border-slate-850 text-slate-300' : 'bg-slate-50 border-slate-100/70 text-slate-650'
                          }`}>
                            {note}
                          </div>
                        ))}
                      </div>

                      <div className="flex gap-2 mt-2">
                        <input
                          type="text"
                          value={newNoteText}
                          onChange={(e) => setNewNoteText(e.target.value)}
                          placeholder="Log custom notes details..."
                          className={`flex-1 px-3 py-1.5 border rounded-lg focus:outline-none focus:ring-1 focus:ring-purple-500 text-xs ${
                            darkMode ? 'bg-slate-950 border-slate-800 text-white' : 'bg-white border-slate-200'
                          }`}
                        />
                        <button
                          onClick={handleAddNote}
                          className="px-4.5 py-1.5 bg-slate-900 hover:bg-slate-800 text-white font-bold rounded-lg text-xs cursor-pointer"
                        >
                          Save Memo
                        </button>
                      </div>
                    </div>

                  </div>

                </div>

              </div>
            )}

            {/* TAB 3: SCHEDULED SESSION TIMELINE */}
            {activeTab === 'sessions' && (
              <div className="space-y-6 animate-fade-in text-left">
                
                <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start text-xs">
                  
                  {/* Sequential Session Tracker */}
                  <div className={`lg:col-span-7 border p-6 rounded-2xl shadow-sm space-y-5 ${
                    darkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-100'
                  }`}>
                    <div className="flex justify-between items-center">
                      <div>
                        <h2 className={`text-sm font-bold ${darkMode ? 'text-white' : 'text-slate-900'}`}>Scheduled Session Timeline</h2>
                        <p className="text-xs text-slate-400 mt-0.5">Sequential schedule layout for interview check-ins.</p>
                      </div>
                      <button
                        onClick={() => setShowScheduleModal(true)}
                        className="px-4 py-2 bg-slate-900 hover:bg-slate-850 text-white font-bold rounded-xl flex items-center gap-1.5 cursor-pointer"
                      >
                        <Plus className="w-4 h-4" />
                        <span>Schedule Slot</span>
                      </button>
                    </div>

                    <div className="space-y-3.5">
                      {sessions.map((session) => (
                        <div key={session.id} className={`p-4 rounded-xl border flex flex-col sm:flex-row justify-between gap-4 ${
                          darkMode ? 'bg-slate-950 border-slate-850' : 'bg-slate-50 border-slate-100'
                        }`}>
                          <div className="space-y-2">
                            <div className="flex items-center gap-2">
                              <span className="text-[10px] font-black text-purple-400 bg-purple-500/5 px-2 py-0.5 rounded border border-purple-500/10 shrink-0">
                                {session.time.split(' ')[0]}
                              </span>
                              <h4 className={`font-extrabold ${darkMode ? 'text-white' : 'text-slate-900'}`}>{session.type}</h4>
                            </div>
                            <p className="text-[10px] text-slate-500 font-semibold">Assigned: <span className="text-slate-400">{session.studentName}</span></p>
                          </div>

                          <div className="flex items-center gap-3 justify-between sm:justify-end pt-2 sm:pt-0 border-t sm:border-t-0 border-slate-100/10 font-bold shrink-0">
                            <span className="text-slate-500 flex items-center gap-1 font-mono">
                              <Clock className="w-3.5 h-3.5" /> {session.time}
                            </span>
                            {session.meetingLink && (
                              <a 
                                href={session.meetingLink}
                                target="_blank"
                                rel="noreferrer"
                                className="text-purple-400 hover:text-purple-300 flex items-center gap-0.5"
                              >
                                <PlayCircle className="w-4.5 h-4.5" />
                                <span>Join Room</span>
                              </a>
                            )}
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>

                  {/* Action Priority Queue (Caution panel) */}
                  <div className={`lg:col-span-5 border p-6 rounded-2xl shadow-sm space-y-4 ${
                    darkMode ? 'bg-slate-900 border-slate-800 text-slate-350' : 'bg-white border-slate-100 text-slate-700'
                  }`}>
                    <div>
                      <h3 className={`text-sm font-bold ${darkMode ? 'text-white' : 'text-slate-900'}`}>Action Priority Queue</h3>
                      <p className="text-xs text-slate-400 mt-0.5">Active operational warnings and task alerts.</p>
                    </div>

                    <div className="space-y-3 font-bold text-slate-400">
                      {[
                        { text: 'Resume Review Pending (5)', status: 'urgent' },
                        { text: 'Interview Feedback Pending (3)', status: 'urgent' },
                        { text: 'New Student Assigned (Sandeep Singh)', status: 'notice' },
                        { text: 'Session Tomorrow (Priya Singh)', status: 'notice' }
                      ].map((item, idx) => (
                        <div key={idx} className={`p-3.5 rounded-xl border flex items-center gap-3 ${
                          item.status === 'urgent' 
                            ? 'bg-rose-500/5 border-rose-500/20 text-rose-400' 
                            : 'bg-amber-500/5 border-amber-500/20 text-amber-400'
                        }`}>
                          <span className="text-sm shrink-0">⚠</span>
                          <span className="text-xs font-black">{item.text}</span>
                        </div>
                      ))}
                    </div>
                  </div>

                </div>

              </div>
            )}

            {/* TAB 4: SKILL GAP & EMPLOYABILITY MATRIX */}
            {activeTab === 'skills' && (
              <div className="space-y-6 animate-fade-in text-left text-xs">
                
                <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
                  
                  {/* Live Skill Bar Chart */}
                  <div className={`lg:col-span-7 border p-6 rounded-2xl shadow-sm space-y-5 ${
                    darkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-100'
                  }`}>
                    <div>
                      <h3 className={`text-sm font-bold ${darkMode ? 'text-white' : 'text-slate-900'}`}>Live Skill Gap Bar Chart</h3>
                      <p className="text-xs text-slate-400 mt-0.5">Comparative progress bar arrays modeling technical domains.</p>
                    </div>

                    <div className="space-y-3 font-semibold text-slate-400">
                      {[
                        { name: 'Java Programming', val: 90, color: 'bg-blue-500' },
                        { name: 'Data Structures & Algorithms (DSA)', val: 70, color: 'bg-purple-500' },
                        { name: 'SQL & Database Indexing', val: 80, color: 'bg-indigo-500' },
                        { name: 'Communication Vectors', val: 50, color: 'bg-pink-500' },
                        { name: 'ATS Resume Alignment', val: 72, color: 'bg-emerald-500' }
                      ].map((item, idx) => (
                        <div key={idx} className="space-y-1.5">
                          <div className="flex justify-between items-center font-mono font-bold text-[10px]">
                            <span>{item.name}</span>
                            <span>{item.val}% Mastery</span>
                          </div>
                          <div className={`w-full h-2 rounded-full overflow-hidden ${darkMode ? 'bg-slate-850' : 'bg-slate-150'}`}>
                            <div className={`h-full ${item.color}`} style={{ width: `${item.val}%` }}></div>
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>

                  {/* Employability Profile Ring Scorecard */}
                  <div className={`lg:col-span-5 border p-6 rounded-2xl shadow-sm space-y-6 ${
                    darkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-100'
                  }`}>
                    <h3 className={`text-sm font-bold ${darkMode ? 'text-white' : 'text-slate-900'}`}>Employability Profile Ring Scorecard</h3>
                    
                    <div className={`p-4 rounded-xl border flex flex-col items-center justify-center ${
                      darkMode ? 'bg-slate-950 border-slate-850' : 'bg-slate-50 border-slate-150'
                    }`}>
                      <div className="relative w-28 h-28 my-3">
                        <svg className="w-full h-full" viewBox="0 0 36 36">
                          <circle cx="18" cy="18" r="15.915" fill="transparent" stroke={darkMode ? '#334155' : '#f1f5f9'} strokeWidth="3.5" />
                          <circle cx="18" cy="18" r="15.915" fill="transparent" stroke="#8b5cf6" strokeWidth="3.5" strokeDasharray="86 100" strokeLinecap="round" />
                        </svg>
                        <div className="absolute inset-0 flex flex-col items-center justify-center text-center font-bold">
                          <span className={`text-sm font-black ${darkMode ? 'text-white' : 'text-slate-800'}`}>86</span>
                          <span className="text-[7px] text-slate-500 font-bold uppercase tracking-wider">Employability Index</span>
                        </div>
                      </div>

                      <div className="w-full space-y-2 mt-4 text-[10px] font-semibold text-slate-500">
                        {[
                          { label: 'Resume alignment', val: 92 },
                          { label: 'Technical vector accuracy', val: 84 },
                          { label: 'Communication metrics score', val: 78 },
                          { label: 'Mock Interview parameters', val: 89 },
                          { label: 'Attendance rate', val: 95 }
                        ].map((score, idx) => (
                          <div key={idx} className="flex justify-between items-center font-bold">
                            <span>{score.label}</span>
                            <span className={darkMode ? 'text-slate-350' : 'text-slate-700'}>{score.val} / 100</span>
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>

                </div>

              </div>
            )}

            {/* TAB 5: RECENT ACTIVITY & LEADERBOARD */}
            {activeTab === 'activity' && (
              <div className="space-y-6 animate-fade-in text-left text-xs">
                
                <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
                  
                  {/* Activity Ticker Feed */}
                  <div className={`lg:col-span-5 border p-6 rounded-2xl shadow-sm space-y-4 ${
                    darkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-100'
                  }`}>
                    <div>
                      <h3 className={`text-sm font-bold ${darkMode ? 'text-white' : 'text-slate-900'}`}>Recent Activity Ticker</h3>
                      <p className="text-xs text-slate-400 mt-0.5">Submission logs with checkbox status toggles.</p>
                    </div>

                    <div className="space-y-2.5">
                      {activityTicker.map((item) => (
                        <label 
                          key={item.id} 
                          className={`flex items-center gap-3 p-3 rounded-xl border cursor-pointer transition-all ${
                            item.done 
                              ? 'border-purple-500/10 bg-purple-500/5 text-purple-400' 
                              : darkMode ? 'border-slate-800 bg-slate-950 hover:border-slate-700 text-slate-400' : 'border-slate-150 bg-slate-50 hover:border-purple-200 text-slate-700'
                          }`}
                        >
                          <input
                            type="checkbox"
                            checked={item.done}
                            onChange={() => toggleActivityTicker(item.id)}
                            className="rounded text-purple-600 focus:ring-purple-500 w-4 h-4 border-slate-300"
                          />
                          <div className="leading-none text-left min-w-0">
                            <p className="font-extrabold text-xs truncate">{item.text}</p>
                            <span className="text-[9px] text-slate-500 font-medium block mt-1 font-mono">{item.time}</span>
                          </div>
                        </label>
                      ))}
                    </div>
                  </div>

                  {/* Leaderboard Matrix */}
                  <div className={`lg:col-span-7 border p-6 rounded-2xl shadow-sm space-y-4 ${
                    darkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-100'
                  }`}>
                    <div>
                      <h3 className={`text-sm font-bold ${darkMode ? 'text-white' : 'text-slate-900'}`}>High-Achiever Leaderboard Matrix</h3>
                      <p className="text-xs text-slate-400 mt-0.5">Ranks based on aggregate employability indices.</p>
                    </div>

                    <div className="overflow-x-auto border border-slate-100/10 rounded-xl">
                      <table className="w-full text-left text-xs">
                        <thead>
                          <tr className={`border-b uppercase tracking-widest font-black text-[9px] ${
                            darkMode ? 'bg-slate-850 border-slate-800 text-slate-400' : 'bg-slate-50 border-slate-100 text-slate-400'
                          }`}>
                            <th className="p-4">Rank</th>
                            <th className="p-4">Student</th>
                            <th className="p-4">Placement Fit</th>
                            <th className="p-4 text-right">Score</th>
                          </tr>
                        </thead>
                        <tbody className="font-semibold text-slate-400">
                          {[
                            { rank: '🥇 Rank 1', name: 'Rahul Sharma', fit: 'Stripe (React)', score: 96 },
                            { rank: '🥈 Rank 2', name: 'Priya Singh', fit: 'Atlassian (Full Stack)', score: 94 },
                            { rank: '🥉 Rank 3', name: 'Gaurav  Verma', fit: 'Vercel (Backend)', score: 92 }
                          ].map((item, idx) => (
                            <tr key={idx} className={`border-b transition-colors ${
                              darkMode ? 'border-slate-800/40 hover:bg-slate-850/50' : 'border-slate-100/40 hover:bg-slate-50/20'
                            }`}>
                              <td className={`p-4 font-black ${darkMode ? 'text-white' : 'text-slate-900'}`}>{item.rank}</td>
                              <td className="p-4 font-bold text-purple-400">{item.name}</td>
                              <td className="p-4">{item.fit}</td>
                              <td className="p-4 text-right font-mono font-black">{item.score}</td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  </div>

                </div>

              </div>
            )}

            {/* TAB 6: RESOURCE LIBRARY */}
            {activeTab === 'resources' && (
              <div className="space-y-6 animate-fade-in text-left text-xs">
                
                <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
                  
                  {/* Resource directory */}
                  <div className={`lg:col-span-8 border p-6 rounded-2xl shadow-sm space-y-5 ${
                    darkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-100'
                  }`}>
                    <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-2">
                      <div>
                        <h2 className={`text-sm font-bold ${darkMode ? 'text-white' : 'text-slate-900'}`}>Shared Material Library</h2>
                        <p className="text-xs text-slate-400 mt-0.5">Filter by category tags or upload documents.</p>
                      </div>

                      <div className="flex flex-wrap gap-1">
                        {['All', 'Interview Questions', 'Coding Sheets', 'PDFs', 'Resume Templates', 'Company Experiences', 'Videos'].map(cat => (
                          <button
                            key={cat}
                            onClick={() => setResourceFilter(cat)}
                            className={`px-2 py-0.5 rounded border text-[8.5px] font-black uppercase tracking-wider transition-all cursor-pointer ${
                              resourceFilter === cat 
                                ? 'bg-purple-650 text-white border-purple-700 bg-purple-600' 
                                : darkMode ? 'border-slate-800 bg-slate-950 text-slate-400 hover:text-white' : 'border-slate-200 bg-slate-50 text-slate-500 hover:text-slate-800'
                            }`}
                          >
                            {cat}
                          </button>
                        ))}
                      </div>
                    </div>

                    <div className="space-y-3 max-h-[360px] overflow-y-auto pr-1">
                      {resources
                        .filter(res => resourceFilter === 'All' || res.category === resourceFilter)
                        .map((res) => (
                          <div key={res.id} className={`p-4 rounded-xl border flex justify-between items-center ${
                            darkMode ? 'bg-slate-950 border-slate-850' : 'bg-slate-50 border-slate-100'
                          }`}>
                            <div className="flex gap-3 items-center">
                              <div className="w-9 h-9 rounded-lg bg-purple-500/10 border border-purple-500/15 flex items-center justify-center text-purple-400">
                                <FileText className="w-4.5 h-4.5" />
                              </div>
                              <div>
                                <h4 className={`font-extrabold ${darkMode ? 'text-white' : 'text-slate-800'}`}>{res.title}</h4>
                                <span className="text-[10px] text-slate-500 font-bold block uppercase tracking-wider mt-0.5">{res.category} • {res.size}</span>
                              </div>
                            </div>
                            <div className="text-right flex items-center gap-4">
                              <span className="text-[9px] text-slate-500 font-mono">{res.uploadedAt}</span>
                              <button 
                                onClick={() => triggerToast(`Downloading resource: ${res.title}`)}
                                className="text-[9px] font-black uppercase text-purple-400 hover:text-purple-300 cursor-pointer"
                              >
                                Download
                              </button>
                            </div>
                          </div>
                        ))}
                    </div>
                  </div>

                  {/* Share form */}
                  <div className={`lg:col-span-4 border p-6 rounded-2xl shadow-sm space-y-4 ${
                    darkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-100'
                  }`}>
                    <h3 className={`text-sm font-bold ${darkMode ? 'text-white' : 'text-slate-900'}`}>Upload Shared Resource</h3>
                    
                    <form onSubmit={handleAddResource} className="space-y-4 font-semibold text-slate-500">
                      <div>
                        <label className="block text-[10px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">Resource Title</label>
                        <input
                          type="text"
                          value={newResourceTitle}
                          onChange={(e) => setNewResourceTitle(e.target.value)}
                          placeholder="e.g. Stripe mock API documentation"
                          className={`w-full px-3.5 py-2.5 border rounded-xl focus:outline-none ${
                            darkMode ? 'bg-slate-950 border-slate-800 text-white' : 'bg-slate-50 border-slate-200 text-slate-800'
                          }`}
                          required
                        />
                      </div>

                      <div>
                        <label className="block text-[10px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">Category</label>
                        <select
                          value={newResourceCategory}
                          onChange={(e) => setNewResourceCategory(e.target.value as any)}
                          className={`w-full px-3.5 py-2.5 border rounded-xl focus:outline-none font-bold ${
                            darkMode ? 'bg-slate-950 border-slate-800 text-white' : 'bg-slate-50 border-slate-200 text-slate-700'
                          }`}
                        >
                          <option value="Interview Questions">Interview Questions</option>
                          <option value="Coding Sheets">Coding Sheets</option>
                          <option value="PDFs">PDFs</option>
                          <option value="Resume Templates">Resume Templates</option>
                          <option value="Company Experiences">Company Experiences</option>
                          <option value="Videos">Videos</option>
                        </select>
                      </div>

                      <button
                        type="submit"
                        className="w-full py-2.5 bg-slate-900 hover:bg-slate-850 text-white rounded-xl font-bold flex items-center justify-center gap-1.5 cursor-pointer text-xs"
                      >
                        <Upload className="w-4 h-4" />
                        <span>Upload File</span>
                      </button>
                    </form>
                  </div>

                </div>

              </div>
            )}

            {/* TAB 7: CAREER ROADMAP CHECKLISTS */}
            {activeTab === 'roadmaps' && (
              <div className="space-y-6 animate-fade-in text-left text-xs">
                
                <div className={`border p-6 rounded-2xl shadow-sm space-y-6 ${
                  darkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-100'
                }`}>
                  <div>
                    <h2 className={`text-sm font-bold ${darkMode ? 'text-white' : 'text-slate-900'}`}>Career Roadmap Checklists</h2>
                    <p className="text-xs text-slate-400 mt-0.5">Steppers checklist mapping student milestone statuses.</p>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    {students.slice(0, 4).map((student) => (
                      <div key={student.id} className={`p-4 rounded-xl border space-y-4 font-semibold ${
                        darkMode ? 'bg-slate-950 border-slate-850' : 'bg-slate-50 border-slate-100'
                      }`}>
                        <div className="flex items-center gap-2.5">
                          <div className={`w-8 h-8 rounded-lg flex items-center justify-center text-white font-bold shrink-0 ${student.avatarBg}`}>
                            {student.avatar}
                          </div>
                          <div>
                            <h3 className={`font-extrabold ${darkMode ? 'text-white' : 'text-slate-900'}`}>{student.name}</h3>
                            <p className="text-[9px] text-slate-500 font-medium">{student.college} • {student.role}</p>
                          </div>
                        </div>

                        {/* Roadmap Stepper Milestone checklist (Module 13) */}
                        <div className="space-y-2 pt-2 border-t border-slate-100/10">
                          {student.milestones.map((milestone, mIdx) => (
                            <label 
                              key={mIdx} 
                              className={`flex items-center gap-2.5 p-2 rounded-lg border cursor-pointer transition-all ${
                                milestone.status === 'done' 
                                  ? 'border-purple-500/30 bg-purple-500/5' 
                                  : darkMode ? 'border-slate-800 bg-slate-900/40 hover:border-slate-700' : 'border-slate-150 bg-white hover:border-purple-200'
                              }`}
                            >
                              <input
                                type="checkbox"
                                checked={milestone.status === 'done'}
                                onChange={() => toggleProgressItem(student.id, mIdx)}
                                className="rounded text-purple-600 focus:ring-purple-500 w-3.5 h-3.5 border-slate-300"
                              />
                              <div className="leading-none text-left">
                                <p className={`text-[9px] font-black ${darkMode ? 'text-slate-350' : 'text-slate-850'}`}>
                                  {milestone.status === 'done' ? '✔' : '⬜'} {milestone.name}
                                </p>
                                <span className={`text-[8px] font-bold uppercase tracking-wider block mt-0.5 ${
                                  milestone.status === 'done' ? 'text-emerald-500' : milestone.status === 'progress' ? 'text-amber-505 text-amber-500' : 'text-slate-500'
                                }`}>
                                  {milestone.status === 'done' ? 'Completed' : milestone.status === 'progress' ? 'In Progress' : 'Pending'}
                                </span>
                              </div>
                            </label>
                          ))}
                        </div>

                      </div>
                    ))}
                  </div>
                </div>

              </div>
            )}

            {/* TAB 8: INTEGRATED COMMUNICATION CENTER */}
            {activeTab === 'communication' && (
              <div className="space-y-6 animate-fade-in text-left text-xs">
                
                {/* Success stories banner (Module 18) */}
                <div className="bg-gradient-to-r from-purple-600 via-indigo-655 to-indigo-600 rounded-2xl p-5 shadow-lg shadow-purple-500/10 text-white flex items-center justify-between gap-4">
                  <div className="space-y-1">
                    <span className="text-[9px] font-black uppercase tracking-widest text-purple-200">Placement Success Banner</span>
                    <h3 className="text-sm font-extrabold flex items-center gap-1.5">
                      <span>🎉 Congratulations! Rahul Sharma placed at TCS (Package: ₹7 LPA) - Mentored by You</span>
                    </h3>
                  </div>
                  <button 
                    onClick={() => triggerToast('Logged victory ticker share.')}
                    className="px-3.5 py-1.5 bg-white text-purple-600 font-bold rounded-lg text-[10px] cursor-pointer"
                  >
                    Share
                  </button>
                </div>

                <div className={`border rounded-3xl overflow-hidden shadow-sm flex h-[460px] ${
                  darkMode ? 'bg-slate-900 border-slate-800 text-slate-400' : 'bg-white border-slate-100 text-slate-800'
                }`}>
                  
                  {/* Left Rail */}
                  <div className={`w-60 border-r flex flex-col justify-between shrink-0 p-4 ${
                    darkMode ? 'bg-slate-950 border-slate-850' : 'bg-slate-50 border-slate-100'
                  }`}>
                    <div className="space-y-6">
                      
                      {/* DM selection */}
                      <div className="space-y-2">
                        <span className="text-[9px] font-black text-slate-500 uppercase tracking-widest px-2.5 block">Direct Messages</span>
                        <nav className="space-y-0.5">
                          {students.slice(0, 3).map((st) => (
                            <button
                              key={st.id}
                              onClick={() => {
                                setActiveChatStudent(st.name);
                                setActiveChatChannel('direct');
                              }}
                              className={`w-full flex items-center gap-2 px-2 py-1.5 rounded-lg font-bold transition-all ${
                                activeChatChannel === 'direct' && activeChatStudent === st.name
                                  ? 'bg-purple-600/10 text-purple-400'
                                  : 'hover:bg-slate-800/10 text-slate-400'
                              }`}
                            >
                              <div className={`w-5.5 h-5.5 rounded-full flex items-center justify-center font-bold text-white text-[8px] ${st.avatarBg}`}>
                                {st.avatar}
                              </div>
                              <span className="truncate">{st.name}</span>
                            </button>
                          ))}
                        </nav>
                      </div>

                      {/* Workspaces */}
                      <div className="space-y-2">
                        <span className="text-[9px] font-black text-slate-500 uppercase tracking-widest px-2.5 block">Workspaces & Cohorts</span>
                        <nav className="space-y-0.5">
                          {['#stripe-frontend', '#atlassian-cohort'].map((channel) => (
                            <button
                              key={channel}
                              onClick={() => {
                                setActiveGroupChannel(channel);
                                setActiveChatChannel('group');
                              }}
                              className={`w-full flex items-center gap-2 px-2.5 py-1.5 rounded-lg font-bold text-left transition-all ${
                                activeChatChannel === 'group' && activeGroupChannel === channel
                                  ? 'bg-purple-600/10 text-purple-400'
                                  : 'hover:bg-slate-800/10 text-slate-400'
                              }`}
                            >
                              <span>#</span>
                              <span className="truncate">{channel.replace('#', '')}</span>
                            </button>
                          ))}
                        </nav>
                      </div>

                    </div>
                  </div>

                  {/* Right Rail Panel */}
                  <div className="flex-1 flex flex-col justify-between bg-transparent">
                    
                    {/* Chat Header */}
                    <div className="p-4 border-b border-slate-100/10 flex justify-between items-center">
                      <h3 className={`font-extrabold ${darkMode ? 'text-white' : 'text-slate-900'}`}>
                        {activeChatChannel === 'direct' ? activeChatStudent : activeGroupChannel}
                      </h3>
                      <span className="text-[9px] text-emerald-500 font-bold bg-emerald-500/5 px-2 py-0.5 rounded border border-emerald-500/15">Active Workspace</span>
                    </div>

                    {/* Messages history */}
                    <div className="flex-1 p-4 overflow-y-auto space-y-4 font-semibold">
                      {(chatHistory[activeChatChannel === 'direct' ? activeChatStudent : activeGroupChannel] || []).map((msg) => (
                        <div key={msg.id} className={`flex ${msg.sender === 'mentor' ? 'justify-end' : 'justify-start'}`}>
                          <div className={`p-3 rounded-2xl max-w-xs ${
                            msg.sender === 'mentor'
                              ? 'bg-purple-600 text-white rounded-tr-none'
                              : darkMode ? 'bg-slate-800 text-slate-200 border border-slate-750 rounded-tl-none' : 'bg-slate-50 text-slate-800 border border-slate-150 rounded-tl-none'
                          }`}>
                            <p>{msg.text}</p>
                            <span className={`text-[8px] block mt-1.5 text-right ${msg.sender === 'mentor' ? 'text-purple-200' : 'text-slate-500'}`}>
                              {msg.timestamp}
                            </span>
                          </div>
                        </div>
                      ))}
                      {isTyping && (
                        <div className="flex justify-start">
                          <div className={`p-3 rounded-2xl rounded-tl-none font-bold animate-pulse ${
                            darkMode ? 'bg-slate-800 text-slate-550 border border-slate-750' : 'bg-slate-50 text-slate-400 border border-slate-150'
                          }`}>
                            typing response...
                          </div>
                        </div>
                      )}
                    </div>

                    {/* Input message form */}
                    <div className="p-4 border-t border-slate-100/10 bg-transparent flex gap-2">
                      <input
                        type="text"
                        value={typedMessage}
                        onChange={(e) => setTypedMessage(e.target.value)}
                        placeholder="Write a message..."
                        className={`flex-1 px-4 py-2 border rounded-xl focus:outline-none focus:ring-1 focus:ring-purple-500 text-xs ${
                          darkMode ? 'bg-slate-950 border-slate-800 text-white' : 'bg-white border-slate-200'
                        }`}
                        onKeyDown={(e) => e.key === 'Enter' && handleSendMessage()}
                      />
                      <button
                        onClick={handleSendMessage}
                        className="w-10 h-10 bg-slate-900 hover:bg-slate-800 text-white rounded-xl flex items-center justify-center transition-all cursor-pointer shrink-0"
                      >
                        <Send className="w-4 h-4" />
                      </button>
                    </div>

                  </div>

                </div>

              </div>
            )}

            {/* TAB 9: FEEDBACK FORM EVALUATION */}
            {activeTab === 'feedback' && (
              <div className="space-y-6 animate-fade-in text-left text-xs">
                
                <div className={`border p-6 rounded-2xl shadow-sm max-w-xl ${
                  darkMode ? 'bg-slate-900 border-slate-800 text-slate-350' : 'bg-white border-slate-100 text-slate-700'
                }`}>
                  <h2 className={`text-sm font-bold mb-4 tracking-tight ${darkMode ? 'text-white' : 'text-slate-900'}`}>Candidate star evaluation feedback</h2>
                  
                  <form onSubmit={handleSendFeedback} className="space-y-4 font-semibold">
                    <div>
                      <label className="block text-[10px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">Assigned candidate</label>
                      <select
                        value={feedbackStudent}
                        onChange={(e) => setFeedbackStudent(e.target.value)}
                        className={`w-full px-3.5 py-2.5 border rounded-xl focus:outline-none font-bold ${
                          darkMode ? 'bg-slate-950 border-slate-800 text-white' : 'bg-slate-50 border-slate-200 text-slate-700'
                        }`}
                      >
                        {students.map(s => (
                          <option key={s.id} value={s.name}>{s.name} ({s.college})</option>
                        ))}
                      </select>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <label className="block text-[10px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">Technical Rating</label>
                        <div className="flex gap-1">
                          {[1, 2, 3, 4, 5].map((star) => (
                            <button
                              type="button"
                              key={star}
                              onClick={() => setTechRating(star)}
                              className={`p-1.5 rounded-lg border cursor-pointer transition-colors ${
                                techRating >= star 
                                  ? 'border-purple-300 bg-purple-500/10 text-purple-400' 
                                  : darkMode ? 'border-slate-850 bg-slate-900 text-slate-650' : 'border-slate-150 bg-white text-slate-400'
                              }`}
                            >
                              <Star className="w-4 h-4 fill-current" />
                            </button>
                          ))}
                        </div>
                      </div>

                      <div>
                        <label className="block text-[10px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">Communication Rating</label>
                        <div className="flex gap-1">
                          {[1, 2, 3, 4, 5].map((star) => (
                            <button
                              type="button"
                              key={star}
                              onClick={() => setCommRating(star)}
                              className={`p-1.5 rounded-lg border cursor-pointer transition-colors ${
                                commRating >= star 
                                  ? 'border-purple-300 bg-purple-500/10 text-purple-400' 
                                  : darkMode ? 'border-slate-850 bg-slate-900 text-slate-655' : 'border-slate-150 bg-white text-slate-400'
                              }`}
                            >
                              <Star className="w-4 h-4 fill-current" />
                            </button>
                          ))}
                        </div>
                      </div>
                    </div>

                    <div>
                      <label className="block text-[10px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">Assessment Commentary</label>
                      <textarea
                        value={feedbackComments}
                        onChange={(e) => setFeedbackComments(e.target.value)}
                        placeholder="Write structured evaluation notes here..."
                        rows={4}
                        className={`w-full px-3.5 py-2.5 border rounded-xl focus:outline-none focus:ring-1 focus:ring-purple-500 ${
                          darkMode ? 'bg-slate-950 border-slate-800 text-white' : 'bg-slate-50 border-slate-200 text-slate-800'
                        }`}
                        required
                      />
                    </div>

                    <div className="pt-2 flex justify-end">
                      <button
                        type="submit"
                        className="px-5 py-2.5 bg-[#5e17eb] hover:bg-[#4b12bc] text-white rounded-xl font-bold shadow-lg shadow-purple-500/20 cursor-pointer"
                      >
                        Submit Feedback
                      </button>
                    </div>
                  </form>
                </div>

              </div>
            )}

            {/* TAB 10: PROFILE */}
            {activeTab === 'profile' && (
              <div className="space-y-6 animate-fade-in text-left text-xs">
                
                <div className={`border p-6 rounded-2xl shadow-sm space-y-6 ${
                  darkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-100'
                }`}>
                  <div className="flex gap-4 items-center">
                    <div className="w-16 h-16 rounded-2xl bg-gradient-to-r from-purple-650 to-indigo-650 bg-purple-600 flex items-center justify-center font-bold text-white text-xl shadow-md">
                      {getInitials(currentUser?.fullName || 'Sarah Jenkins')}
                    </div>
                    <div>
                      <h2 className={`text-base font-extrabold ${darkMode ? 'text-white' : 'text-slate-900'}`}>{currentUser?.fullName || 'Sarah Jenkins'}</h2>
                      <p className="text-xs text-slate-500 font-semibold mt-0.5">Principal Software Engineer • Stripe Sourcing pipelines</p>
                      <p className="text-[9px] text-purple-400 font-bold uppercase tracking-wider mt-1.5">Department: Engineering Sourcing</p>
                    </div>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 border-t border-slate-105/10 pt-5 text-slate-500 font-semibold">
                    <div>
                      <span className="text-[9px] text-slate-400 block font-bold uppercase tracking-wider mb-0.5">Corporate Email</span>
                      <p className={darkMode ? 'text-slate-200' : 'text-slate-800'}>{currentUser?.email || 'sarah.jenkins@stripe.com'}</p>
                    </div>
                    <div>
                      <span className="text-[9px] text-slate-400 block font-bold uppercase tracking-wider mb-0.5">Office hours</span>
                      <p className={darkMode ? 'text-slate-200' : 'text-slate-800'}>Mon, Wed, Fri (4:00 - 6:00 PM)</p>
                    </div>
                    <div>
                      <span className="text-[9px] text-slate-400 block font-bold uppercase tracking-wider mb-0.5">Contact Number</span>
                      <p className={darkMode ? 'text-slate-200' : 'text-slate-800'}>{currentUser?.phone || '+1 (555) 019-2834'}</p>
                    </div>
                    <div>
                      <span className="text-[9px] text-slate-400 block font-bold uppercase tracking-wider mb-0.5">Expertise Tags</span>
                      <p className={darkMode ? 'text-slate-200' : 'text-slate-800'}>React, Cosine Vector Embeddings, System Design</p>
                    </div>
                  </div>

                  <div className="pt-5 border-t border-slate-105/10 flex justify-between items-center">
                    <div>
                      <h4 className={`font-extrabold ${darkMode ? 'text-slate-200' : 'text-slate-800'}`}>Availability Booking Ticker</h4>
                      <p className="text-[9px] text-slate-500 font-semibold mt-0.5">Allow assigned cohorts to schedule 1-on-1 mock reviews immediately.</p>
                    </div>
                    <button
                      onClick={() => {
                        setAvailabilitySwitch(!availabilitySwitch);
                        triggerToast(availabilitySwitch ? 'Booking calendar paused' : 'Booking calendar active');
                      }}
                      className={`w-12 h-6.5 rounded-full p-1 transition-colors flex items-center cursor-pointer ${
                        availabilitySwitch ? 'bg-purple-650 bg-purple-600 justify-end' : 'bg-slate-700 justify-start'
                      }`}
                    >
                      <span className="w-4.5 h-4.5 rounded-full bg-white shadow"></span>
                    </button>
                  </div>
                </div>

              </div>
            )}

            {/* TAB 11: SYSTEM SETTINGS */}
            {activeTab === 'settings' && (
              <div className="space-y-6 animate-fade-in text-left text-xs">
                
                <div className={`border p-6 rounded-2xl shadow-sm max-w-lg space-y-5 ${
                  darkMode ? 'bg-slate-900 border-slate-800 text-slate-350' : 'bg-white border-slate-100 text-slate-700'
                }`}>
                  <h3 className={`text-sm font-bold mb-4 ${darkMode ? 'text-white' : 'text-slate-900'}`}>System Preferences</h3>
                  
                  <div className="space-y-4 font-semibold">
                    <div className="flex justify-between items-center">
                      <div>
                        <span className={darkMode ? 'text-slate-200' : 'text-slate-800'}>Force System Dark Mode</span>
                        <span className="text-[9px] text-slate-500 block font-medium mt-0.5">Enforce high-contrast dark theme canvas.</span>
                      </div>
                      <button
                        onClick={() => {
                          setDarkMode(!darkMode);
                          triggerToast(darkMode ? 'Dark mode deactivated' : 'Dark mode active');
                        }}
                        className={`w-10 h-5.5 rounded-full p-0.5 transition-colors flex items-center cursor-pointer ${
                          darkMode ? 'bg-purple-650 bg-purple-600 justify-end' : 'bg-slate-700 justify-start'
                        }`}
                      >
                        <span className="w-4 h-4 rounded-full bg-white shadow"></span>
                      </button>
                    </div>

                    <div className="flex justify-between items-center pt-3 border-t border-slate-100/10">
                      <div>
                        <span className={darkMode ? 'text-slate-200' : 'text-slate-800'}>Message Push Alerts</span>
                        <span className="text-[9px] text-slate-500 block font-medium mt-0.5">Receive browser cues for assignment submissions.</span>
                      </div>
                      <button
                        onClick={() => {
                          setPushAlerts(!pushAlerts);
                          triggerToast(pushAlerts ? 'Alert notifications paused' : 'Alert notifications active');
                        }}
                        className={`w-10 h-5.5 rounded-full p-0.5 transition-colors flex items-center cursor-pointer ${
                          pushAlerts ? 'bg-purple-650 bg-purple-600 justify-end' : 'bg-slate-700 justify-start'
                        }`}
                      >
                        <span className="w-4 h-4 rounded-full bg-white shadow"></span>
                      </button>
                    </div>

                    <div className="flex justify-between items-center pt-3 border-t border-slate-100/10">
                      <div>
                        <span className={darkMode ? 'text-slate-200' : 'text-slate-800'}>Private Profile Mode</span>
                        <span className="text-[9px] text-slate-500 block font-medium mt-0.5">Hide email details from recruiter directories.</span>
                      </div>
                      <button
                        onClick={() => {
                          setPrivacyMode(!privacyMode);
                          triggerToast(privacyMode ? 'Privacy mode deactivated' : 'Privacy mode active');
                        }}
                        className={`w-10 h-5.5 rounded-full p-0.5 transition-colors flex items-center cursor-pointer ${
                          privacyMode ? 'bg-purple-650 bg-purple-600 justify-end' : 'bg-slate-700 justify-start'
                        }`}
                      >
                        <span className="w-4 h-4 rounded-full bg-white shadow"></span>
                      </button>
                    </div>

                    <div className="flex justify-between items-center pt-3 border-t border-slate-100/10">
                      <div>
                        <span className={darkMode ? 'text-slate-200' : 'text-slate-800'}>Alert Cache Limits</span>
                        <span className="text-[9px] text-slate-500 block font-medium mt-0.5">Limit logs display counts inside header dropdown.</span>
                      </div>
                      <select
                        value={alertsLimit}
                        onChange={(e) => {
                          setAlertsLimit(e.target.value);
                          triggerToast(`Limit set to ${e.target.value} alerts`);
                        }}
                        className={`px-2 py-1 border rounded-lg focus:outline-none font-bold text-[10px] ${
                          darkMode ? 'bg-slate-950 border-slate-800 text-white' : 'bg-slate-50 border-slate-200 text-slate-700'
                        }`}
                      >
                        <option value="5">5 Logs</option>
                        <option value="10">10 Logs</option>
                        <option value="25">25 Logs</option>
                      </select>
                    </div>

                    <div className="flex justify-between items-center pt-3 border-t border-slate-100/10">
                      <div>
                        <span className={darkMode ? 'text-slate-200' : 'text-slate-800'}>System Language</span>
                      </div>
                      <select
                        value={selectedLanguage}
                        onChange={(e) => {
                          setSelectedLanguage(e.target.value);
                          triggerToast(`Language configured to ${e.target.value}`);
                        }}
                        className={`px-2.5 py-1.5 border rounded-lg focus:outline-none font-bold text-[10px] ${
                          darkMode ? 'bg-slate-950 border-slate-800 text-white' : 'bg-slate-50 border-slate-200 text-slate-700'
                        }`}
                      >
                        <option value="English">English</option>
                        <option value="Spanish">Spanish</option>
                        <option value="French">French</option>
                      </select>
                    </div>

                    <div className="pt-4 border-t border-slate-100/10">
                      <button
                        onClick={() => setShowPasswordResetModal(true)}
                        className={`w-full py-2.5 border rounded-xl font-bold flex items-center justify-center gap-1.5 cursor-pointer text-xs ${
                          darkMode ? 'bg-slate-950 border-slate-850 text-slate-350 hover:bg-slate-800' : 'bg-slate-100 border-slate-200 hover:bg-slate-200 text-slate-700'
                        }`}
                      >
                        <Lock className="w-4 h-4 text-slate-400" />
                        <span>Request Password Reset</span>
                      </button>
                    </div>

                  </div>
                </div>

                {showPasswordResetModal && (
                  <div className="fixed inset-0 z-[999999] flex items-center justify-center bg-slate-950/70 backdrop-blur-sm p-4 animate-fade-in">
                    <div className={`w-full max-w-sm rounded-2xl shadow-2xl border p-5 text-xs text-left ${
                      darkMode ? 'bg-slate-900 border-slate-800 text-slate-300' : 'bg-white border-slate-105/10 bg-white text-slate-800 border-slate-150'
                    }`}>
                      <div className="flex justify-between items-center mb-4 border-b border-slate-100/10 pb-2">
                        <h4 className="font-extrabold text-sm flex items-center gap-2">
                          <Lock className="w-4.5 h-4.5 text-purple-400" />
                          <span>Password Reset Dispatch</span>
                        </h4>
                        <button onClick={() => setShowPasswordResetModal(false)} className="p-1 rounded-lg text-slate-400 hover:text-slate-250 cursor-pointer">
                          <X className="w-4 h-4" />
                        </button>
                      </div>
                      <p className="font-semibold leading-relaxed mb-4">
                        We will dispatch a secure validation reset link directly to your corporate inbox: <span className="font-bold text-purple-400">sarah.jenkins@stripe.com</span>. Please verify client authorization before dispatching.
                      </p>
                      <div className="flex gap-2.5 justify-end">
                        <button 
                          onClick={() => setShowPasswordResetModal(false)} 
                          className={`px-4 py-2 border rounded-xl font-bold cursor-pointer ${
                            darkMode ? 'border-slate-800 hover:bg-slate-800' : 'border-slate-200 hover:bg-slate-50'
                          }`}
                        >
                          Cancel
                        </button>
                        <button 
                          onClick={() => {
                            setShowPasswordResetModal(false);
                            triggerToast('Password reset link successfully dispatched.');
                          }} 
                          className="px-4.5 py-2 bg-purple-650 bg-purple-600 hover:bg-purple-700 text-white font-bold rounded-xl shadow-lg shadow-purple-500/20 cursor-pointer"
                        >
                          Dispatch Link
                        </button>
                      </div>
                    </div>
                  </div>
                )}

              </div>
            )}

          </main>

        </div>

        {/* Schedule Slot Modal */}
        {showScheduleModal && (
          <div className="fixed inset-0 z-[99999] flex items-center justify-center bg-slate-950/70 backdrop-blur-sm p-4 animate-fade-in text-xs font-semibold text-slate-400">
            <div className={`w-full max-w-md rounded-3xl shadow-2xl border overflow-hidden animate-scale-up text-left ${
              darkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-100'
            }`}>
              
              <div className={`flex justify-between items-center p-5 border-b ${
                darkMode ? 'bg-slate-850 border-slate-800' : 'bg-slate-50 border-slate-100'
              }`}>
                <h3 className={`font-extrabold text-sm flex items-center gap-2 ${darkMode ? 'text-white' : 'text-slate-900'}`}>
                  <Calendar className="w-5 h-5 text-purple-500" />
                  <span>Create Session Slot</span>
                </h3>
                <button 
                  onClick={() => setShowScheduleModal(false)}
                  className="p-1 rounded-lg text-slate-400 hover:text-slate-200 cursor-pointer"
                >
                  <X className="w-4.5 h-4.5" />
                </button>
              </div>

              <form onSubmit={handleCreateSession} className="p-5 space-y-4">
                <div>
                  <label className="block text-[9px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">Select Student</label>
                  <select
                    value={newSessionStudent}
                    onChange={(e) => setNewSessionStudent(e.target.value)}
                    className={`w-full px-3.5 py-2.5 border rounded-xl focus:outline-none focus:ring-1 focus:ring-purple-500 font-bold ${
                      darkMode ? 'bg-slate-950 border-slate-800 text-white' : 'bg-slate-50 border-slate-200 text-slate-750'
                    }`}
                    required
                  >
                    <option value="">-- Choose Student --</option>
                    {students.map(s => (
                      <option key={s.id} value={s.name}>{s.name} ({s.college})</option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-[9px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">Session Category</label>
                  <select
                    value={newSessionType}
                    onChange={(e) => setNewSessionType(e.target.value)}
                    className={`w-full px-3.5 py-2.5 border rounded-xl focus:outline-none focus:ring-1 focus:ring-purple-500 font-bold ${
                      darkMode ? 'bg-slate-950 border-slate-800 text-white' : 'bg-slate-50 border-slate-200 text-slate-700'
                    }`}
                  >
                    <option value="Resume Review">Resume Review</option>
                    <option value="Mock Interview">Mock Interview</option>
                    <option value="Career Guidance">Career Guidance</option>
                  </select>
                </div>

                <div className="grid grid-cols-3 gap-4">
                  <div className="col-span-2">
                    <label className="block text-[9px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">Meeting Time</label>
                    <input
                      type="text"
                      value={newSessionTime}
                      onChange={(e) => setNewSessionTime(e.target.value)}
                      placeholder="e.g. 10:00 AM - 11:00 AM"
                      className={`w-full px-3.5 py-2.5 border rounded-xl focus:outline-none ${
                        darkMode ? 'bg-slate-950 border-slate-800 text-white' : 'bg-slate-550 border-slate-200'
                      }`}
                      required
                    />
                  </div>

                  <div>
                    <label className="block text-[9px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">Weekday</label>
                    <select
                      value={newSessionDay}
                      onChange={(e) => setNewSessionDay(e.target.value as any)}
                      className={`w-full px-3.5 py-2.5 border rounded-xl focus:outline-none font-bold ${
                        darkMode ? 'bg-slate-950 border-slate-800 text-white' : 'bg-slate-550 border-slate-200 text-slate-700'
                      }`}
                    >
                      <option value="Mon">Mon</option>
                      <option value="Tue">Tue</option>
                      <option value="Wed">Wed</option>
                      <option value="Thu">Thu</option>
                      <option value="Fri">Fri</option>
                    </select>
                  </div>
                </div>

                <div>
                  <label className="block text-[9px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">Meeting Date</label>
                  <input
                    type="text"
                    value={newSessionDate}
                    onChange={(e) => setNewSessionDate(e.target.value)}
                    placeholder="e.g. Today, Tomorrow"
                    className={`w-full px-3.5 py-2.5 border rounded-xl focus:outline-none ${
                      darkMode ? 'bg-slate-950 border-slate-800 text-white' : 'bg-slate-550 border-slate-200'
                    }`}
                    required
                  />
                </div>

                <div className="pt-4 border-t border-slate-100/10 flex gap-3.5 justify-end">
                  <button
                    type="button"
                    onClick={() => setShowScheduleModal(false)}
                    className={`px-4.5 py-2 border rounded-xl font-bold cursor-pointer ${
                      darkMode ? 'border-slate-800 hover:bg-slate-800 text-slate-350' : 'border-slate-200 hover:bg-slate-50 text-slate-600'
                    }`}
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    className="px-5 py-2 bg-[#5e17eb] hover:bg-[#4b12bc] text-white rounded-xl font-bold shadow-lg shadow-purple-500/20 cursor-pointer"
                  >
                    Schedule Session
                  </button>
                </div>
              </form>

            </div>
          </div>
        )}

      </div>
    </DashboardLayout>
  );
};


