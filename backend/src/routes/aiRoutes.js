import express from "express";
import * as aiController from "../controllers/aiController.js";
import studentAuthMiddleware from "../middleware/studentAuthMiddleware.js";

const router = express.Router();

router.use(studentAuthMiddleware);

router.post("/study-plan", aiController.studyPlan);
router.post("/placement-analysis", aiController.placementAnalysis);
router.post("/ats-score", aiController.atsScore);
router.post("/skill-gap", aiController.skillGap);
router.post("/career-coach", aiController.careerCoach);
router.post("/resume/summary", aiController.resumeSummary);
router.post("/resume/experience", aiController.resumeExperience);
router.post("/resume/note", aiController.resumeNote);
router.post("/hiring/interview", aiController.hiringInterview);
router.post("/hiring/questions", aiController.hiringQuestions);
router.post("/hiring/evaluate", aiController.hiringEvaluate);
router.post("/hiring/feedback", aiController.hiringFeedback);

export default router;
