import express from "express";
import {
  getEmployabilityMatrix,
  recordMenteeEvaluation,
  toggleActivityTicker,
  getActivityLeaderboard,
  getMentorActivities,
  createMentorActivity,
  deleteMentorActivity,
  getMentorLeaderboard,
  getMentorResources,
  createMentorResource,
  deleteMentorResource,
  downloadMentorResource,
  getMentorDashboard,
  getMentorStudents,
  createMentorStudentNote,
  getMentorSessions,
  createMentorSession,
  deleteMentorSession,
  submitMentorFeedback,
  addStudentNote,
  updateStudentMilestones,
  getMentorProfile,
  updateMentorProfile,
  toggleMentorAvailability,
  getMentorSettings,
  updateMentorSettings,
  requestPasswordReset,
} from "../controllers/mentorController.js";

const router = express.Router();

// Shared Material Library / Study Materials – Real-time MongoDB Atlas endpoints
router.get("/resources", getMentorResources);
router.post("/resources", createMentorResource);
router.delete("/resources/:id", deleteMentorResource);
router.post("/resources/:id/download", downloadMentorResource);

// Activity & Leaderboard – Core screen endpoints (real-time MongoDB Atlas, isMock: false)
router.get("/activity-leaderboard", getActivityLeaderboard);
router.get("/activity", getMentorActivities);
router.post("/activity", createMentorActivity);
router.patch("/activity/:id/toggle", toggleActivityTicker);
router.delete("/activity/:id", deleteMentorActivity);
router.get("/leaderboard", getMentorLeaderboard);
router.post("/leaderboard/evaluate", recordMenteeEvaluation);

// Employability Matrix – core for matrix screen
router.get("/employability-matrix", getEmployabilityMatrix);
router.post("/employability/evaluate", recordMenteeEvaluation);
router.patch("/employability/activity/:id/toggle", toggleActivityTicker);

// Dashboard & Students (realtime from MongoDB – 0 entries if empty, no mock fallback)
router.get("/dashboard", getMentorDashboard);
router.get("/students", getMentorStudents);
router.post("/students", createMentorStudentNote);
router.post("/students/:id/notes", addStudentNote);
router.put("/students/:id/milestones", updateStudentMilestones);

// Sessions
router.get("/sessions", getMentorSessions);
router.post("/sessions", createMentorSession);
router.delete("/sessions/:id", deleteMentorSession);

// Feedback
router.post("/feedback", submitMentorFeedback);

// Mentor Profile – Real-time MongoDB Atlas endpoints
router.get("/profile", getMentorProfile);
router.put("/profile", updateMentorProfile);
router.patch("/profile/availability", toggleMentorAvailability);

// System Settings – Real-time MongoDB Atlas endpoints
router.get("/settings", getMentorSettings);
router.put("/settings", updateMentorSettings);
router.post("/settings/password-reset", requestPasswordReset);

// Health check for mentor module
router.get("/health", (req, res) => {
  res.json({ success: true, message: "Mentor routes operational" });
});

export default router;
