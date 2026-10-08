import express from "express";
import {
  getRecruiterDashboard,
  getRecruiterJobs,
  getRecruiterApplications,
  createRecruiterJob,
  deleteRecruiterJob,
  updateJobStatus,
  createCandidate,
  deleteCandidate,
  updateCandidateStage,
  getRecruiterMessages,
  createRecruiterMessage,
  sendRecruiterReply,
  getRecruiterSettings,
  updateRecruiterSettings,
  requestProfileEdit,
} from "../controllers/recruiterController.js";

const router = express.Router();

// Recruiter Dashboard & Applications – Real-time MongoDB Atlas endpoints (isMock: false)
router.get("/dashboard", getRecruiterDashboard);
router.get("/jobs", getRecruiterJobs);
router.get("/applications", getRecruiterApplications);
router.post("/jobs", createRecruiterJob);
router.delete("/jobs/:id", deleteRecruiterJob);
router.patch("/jobs/:id/status", updateJobStatus);
router.post("/candidates", createCandidate);
router.delete("/candidates/:id", deleteCandidate);
router.patch("/applications/:id/stage", updateCandidateStage);

// Recruiter Messages & Real-time candidate communications
router.get("/messages", getRecruiterMessages);
router.post("/messages", createRecruiterMessage);
router.post("/messages/:id/reply", sendRecruiterReply);

// Recruiter Settings & Verification Profile
router.get("/settings", getRecruiterSettings);
router.post("/settings", updateRecruiterSettings);
router.post("/settings/request-edit", requestProfileEdit);

// Health check
router.get("/health", (req, res) => {
  res.json({ success: true, message: "Recruiter routes operational" });
});

export default router;

