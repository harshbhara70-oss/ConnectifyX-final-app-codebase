import axios, { AxiosError } from "axios";

const API_BASE_URL =
  import.meta.env.VITE_API_URL || "http://localhost:5000/api";

const TOKEN_KEY = "c2c_student_token";

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
  },
  timeout: 15000,
});

// =======================
// Request Interceptor
// =======================
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem(TOKEN_KEY);

    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }

    return config;
  },
  (error) => Promise.reject(error)
);

// =======================
// Response Interceptor
// =======================
api.interceptors.response.use(
  (response) => response,
  (error: AxiosError<any>) => {
    if (error.response?.status === 401) {
      localStorage.removeItem(TOKEN_KEY);
      localStorage.removeItem("c2c_student_user");
    }

    return Promise.reject(error);
  }
);

// =======================
// Types
// =======================

export interface StudentProfile {
  id: string;
  name: string;
  fullName?: string;
  email: string;
  phone?: string;
  role: string;

  college?: string;
  branch?: string;
  semester?: number;

  skills?: any[];
  skillDetails?: any[];
  interests?: any[];
  education?: any[];

  resume?: string;
  resumeUrl?: string;

  bio?: string;
  location?: string;
  linkedIn?: string;
  github?: string;
  portfolio?: string;

  status?: string;

  createdAt?: string;
  updatedAt?: string;
}

export interface ApiState<T> {
  data: T | null;
  loading: boolean;
  error: string;
}

export const unwrapData = <T>(
  response: { data: any },
  key?: string
): T => {
  const payload = response.data?.data ?? response.data;
  return key ? payload[key] : payload;
};

// =======================
// Authentication
// =======================

const auth = {
  register: (data: any) => api.post("/auth/register", data),

  login: (data: any) => api.post("/auth/login", data),

  logout: () => api.post("/auth/logout"),

  me: () => api.get("/auth/me"),
};

// =======================
// Profile
// =======================

const profile = {
  get: () => api.get("/student/profile"),

  update: (data: any) =>
    api.put("/student/profile", data),

  uploadImage: (data: any) =>
    api.put("/student/profile", data),
};

// =======================
// Dashboard
// =======================

const dashboard = {
  get: () => api.get("/student/dashboard"),
};

// =======================
// Skills
// =======================

const skills = {
  get: () => api.get("/student/skills"),

  add: (data: any) =>
    api.post("/student/skills", data),

  update: (id: string, data: any) =>
    api.put(`/student/skills/${id}`, data),

  delete: (id: string) =>
    api.delete(`/student/skills/${id}`),
};

// =======================
// Projects
// =======================

const projects = {
  get: (params?: Record<string, any>) => api.get("/student/projects", { params }),

  apply: (projectId: string, data: any = {}) =>
    api.post(`/student/projects/${projectId}/apply`, data),

  applications: () =>
    api.get("/student/applications"),

  applicationDetails: (applicationId: string) =>
    api.get(`/student/applications/${applicationId}`),

  withdrawApplication: (applicationId: string) =>
    api.delete(`/student/applications/${applicationId}`),
};

// =======================
// Notifications
// =======================

const notifications = {
  get: () => api.get("/student/notifications"),

  markRead: (id: string) =>
    api.patch(`/student/notifications/${id}/read`),

  markAllRead: () =>
    api.patch("/student/notifications/all/read"),

  delete: (id: string) =>
    api.delete(`/student/notifications/${id}`),
};

// =======================
// Certificates
// =======================

const certificates = {
  get: () =>
    api.get("/student/certificates"),

  upload: (data: any) =>
    api.post("/student/certificates", data),

  update: (id: string, data: any) =>
    api.put(`/student/certificates/${id}`, data),

  delete: (id: string) =>
    api.delete(`/student/certificates/${id}`),
};

// =======================
// Settings
// =======================

const settings = {
  get: () =>
    api.get("/student/settings"),

  update: (data: any) =>
    api.put("/student/settings", data),
};

// =======================
// Resume Builder
// =======================

const resume = {
  get: () =>
    api.get("/student/resume-builder"),

  save: (data: any) =>
    api.put("/student/resume-builder", data),
};

// =======================
// Hiring
// =======================

const hiring = {
  get: () =>
    api.get("/student/hiring/drives"),

  start: (projectId: string, data: any = {}) =>
    api.post(
      `/student/hiring/drives/${projectId}/start`,
      data
    ),
};

// =======================
// AI
// =======================

const ai = {
  generateStudyPlan: (studentContext: string) =>
    api.post("/ai/study-plan", {
      studentContext,
    }),

  placementAnalysis: (studentContext: string) =>
    api.post("/ai/placement-analysis", {
      studentContext,
    }),

  atsScore: (resumeText: string) =>
    api.post("/ai/ats-score", {
      resumeText,
    }),

  skillGap: (studentContext: string, role: string) =>
    api.post("/ai/skill-gap", {
      studentContext,
      role,
    }),

  careerCoach: (question: string, studentContext: string) =>
    api.post("/ai/career-coach", {
      question,
      studentContext,
    }),

  resumeSummary: (data: any) =>
    api.post("/ai/resume/summary", data),

  resumeExperience: (data: any) =>
    api.post("/ai/resume/experience", data),
  resumeNote: (data: any) =>
    api.post("/ai/resume/note", data),

  hiringInterview: (data: any) =>
    api.post("/ai/hiring/interview", data),

  hiringQuestions: (data: any) =>
    api.post("/ai/hiring/questions", data),

  hiringEvaluate: (data: any) =>
    api.post("/ai/hiring/evaluate", data),

  hiringFeedback: (data: any) =>
    api.post("/ai/hiring/feedback", data),
};

// =======================
// Export Combined API
// =======================

export const studentApi = {
  ...auth,

  getProfile: profile.get,
  updateProfile: profile.update,
  uploadProfileImage: profile.uploadImage,

  getDashboard: dashboard.get,

  getSkills: skills.get,
  addSkill: skills.add,
  updateSkill: skills.update,
  deleteSkill: skills.delete,

  getProjects: projects.get,
  applyToProject: projects.apply,
  getApplications: projects.applications,
  getApplicationDetails: projects.applicationDetails,
  withdrawApplication: projects.withdrawApplication,

  getNotifications: notifications.get,
  markNotificationRead: notifications.markRead,
  markAllNotificationsRead: notifications.markAllRead,
  deleteNotification: notifications.delete,

  getCertificates: certificates.get,
  uploadCertificate: certificates.upload,
  updateCertificate: certificates.update,
  deleteCertificate: certificates.delete,

  getSettings: settings.get,
  updateSettings: settings.update,

  getResumeBuilder: resume.get,
  saveResumeBuilder: resume.save,

  getHiringDrives: hiring.get,
  startHiringDrive: hiring.start,
  generateStudyPlan: ai.generateStudyPlan,
  placementAnalysis: ai.placementAnalysis,
  atsScore: ai.atsScore,
  skillGap: ai.skillGap,
  careerCoach: ai.careerCoach,
  generateResumeSummary: ai.resumeSummary,
  enhanceResumeExperience: ai.resumeExperience,
  classifyResumeNote: ai.resumeNote,
  generateHiringInterview: ai.hiringInterview,
  generateHiringQuestions: ai.hiringQuestions,
  evaluateHiringAnswer: ai.hiringEvaluate,
  generateHiringFeedback: ai.hiringFeedback,
};


// =======================
// Error Helper
// =======================

export const getApiErrorMessage = (error: unknown): string => {
  if (axios.isAxiosError(error)) {
    return (
      error.response?.data?.message ||
      error.response?.data?.error ||
      error.message ||
      "Something went wrong"
    );
  }

  return "Something went wrong";
};

export default api;
