import * as aiService from "../services/aiServices.js";

const parseAiJson = (result) => {
  if (typeof result !== "string") return result;
  const cleaned = result.replace(/```json|```/g, "").trim();
  return JSON.parse(cleaned);
};

const sendSuccess = (res, message, data) => {
  return res.status(200).json({
    success: true,
    message,
    data,
  });
};

const sendError = (res, error) => {
  console.error(error);

  return res.status(500).json({
    success: false,
    message: error.message || "Internal Server Error",
  });
};

// ===============================
// AI Study Planner
// ===============================

export const studyPlan = async (req, res) => {
  try {
    const { studentContext } = req.body;

    if (!studentContext) {
      return res.status(400).json({
        success: false,
        message: "Student context is required.",
      });
    }

    const result = await aiService.generateStudyPlan(studentContext);

    sendSuccess(res, "Study plan generated successfully.", parseAiJson(result));
  } catch (error) {
    sendError(res, error);
  }
};

// ===============================
// Placement Analysis
// ===============================

export const placementAnalysis = async (req, res) => {
  try {
    const { studentContext } = req.body;

    if (!studentContext) {
      return res.status(400).json({
        success: false,
        message: "Student context is required.",
      });
    }

    const result = await aiService.analyzePlacement(studentContext);

    sendSuccess(
      res,
      "Placement analysis completed.",
      parseAiJson(result)
    );
  } catch (error) {
    sendError(res, error);
  }
};

// ===============================
// ATS Resume Score
// ===============================

export const atsScore = async (req, res) => {
  try {
    const { resumeText } = req.body;

    if (!resumeText) {
      return res.status(400).json({
        success: false,
        message: "Resume text is required.",
      });
    }

    const result = await aiService.analyzeResume(resumeText);

    sendSuccess(res, "Resume analyzed successfully.", parseAiJson(result));
  } catch (error) {
    sendError(res, error);
  }
};

// ===============================
// Skill Gap Analysis
// ===============================

export const skillGap = async (req, res) => {
  try {
    const { studentContext, role } = req.body;

    if (!studentContext || !role) {
      return res.status(400).json({
        success: false,
        message: "Student context and role are required.",
      });
    }

    const result = await aiService.analyzeSkillGap(
      studentContext,
      role
    );

    sendSuccess(
      res,
      "Skill gap analysis completed.",
      parseAiJson(result)
    );
  } catch (error) {
    sendError(res, error);
  }
};

// ===============================
// AI Career Coach
// ===============================

export const careerCoach = async (req, res) => {
  try {
    const { question, studentContext } = req.body;

    if (!question) {
      return res.status(400).json({
        success: false,
        message: "Question is required.",
      });
    }

    const result = await aiService.careerCoach(
      question,
      studentContext || ""
    );
    const parsed = parseAiJson(result);

    sendSuccess(res, "Response generated successfully.", {
      answer: parsed.answer || String(result),
    });
  } catch (error) {
    sendError(res, error);
  }
};

export const resumeSummary = async (req, res) => {
  try {
    const result = await aiService.generateResumeSummary(req.body.resume || req.body);
    sendSuccess(res, "Resume summary generated successfully.", parseAiJson(result));
  } catch (error) {
    sendError(res, error);
  }
};

export const resumeExperience = async (req, res) => {
  try {
    const result = await aiService.enhanceResumeExperience(req.body.experience || req.body);
    sendSuccess(res, "Experience bullets enhanced successfully.", parseAiJson(result));
  } catch (error) {
    sendError(res, error);
  }
};

export const resumeNote = async (req, res) => {
  try {
    const result = await aiService.classifyResumeNote(
      req.body.note || req.body
    );

    sendSuccess(
      res,
      "Resume note classified successfully.",
      parseAiJson(result)
    );
  } catch (error) {
    sendError(res, error);
  }
};

export const hiringInterview = async (req, res) => {
  try {
    const result = await aiService.generateHiringInterview(req.body);
    sendSuccess(res, "Interview generated successfully.", parseAiJson(result));
  } catch (error) {
    sendError(res, error);
  }
};

export const hiringQuestions = async (req, res) => {
  try {
    const result = await aiService.generateHiringQuestions(req.body);
    sendSuccess(res, "Questions generated successfully.", parseAiJson(result));
  } catch (error) {
    sendError(res, error);
  }
};

export const hiringEvaluate = async (req, res) => {
  try {
    const result = await aiService.evaluateHiringAnswer(req.body);
    sendSuccess(res, "Answer evaluated successfully.", parseAiJson(result));
  } catch (error) {
    sendError(res, error);
  }
};

export const hiringFeedback = async (req, res) => {
  try {
    const result = await aiService.generateHiringFeedback(req.body);
    sendSuccess(res, "Feedback generated successfully.", parseAiJson(result));
  } catch (error) {
    sendError(res, error);
  }
};
