import mongoose from "mongoose";
import Student from "../models/student.js";
import generateToken from "../utils/generateToken.js";
import { successResponse, errorResponse } from "../utils/apiResponse.js";

const emailRegex = /^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,})+$/;

const normalizeEmail = (email) => String(email || "").trim().toLowerCase();

const toNumber = (value) => {
  if (value === undefined || value === null || value === "") {
    return undefined;
  }

  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : undefined;
};

const clampPercentage = (value) => {
  const parsed = toNumber(value);
  if (parsed === undefined) {
    return undefined;
  }

  return Math.min(100, Math.max(0, parsed));
};

const isValidObjectId = (value) => mongoose.Types.ObjectId.isValid(value);

const isAllowedRole = (role) =>
  !role || ["student", "recruiter", "mentor", "user"].includes(String(role).toLowerCase());

const publicStudent = (student) => ({
  id: student._id,
  name: student.name,
  fullName: student.name,
  email: student.email,
  phone: student.phone,
  role: student.role || "student",
  college: student.college,
  branch: student.branch,
  semester: student.semester,
  skills: student.skills || [],
  skillDetails: student.skillDetails || [],
  interests: student.interests || [],
  education: student.education || [],
  resume: student.resume,
  resumeUrl: student.resumeUrl || student.resume,
  bio: student.bio,
  location: student.location,
  linkedIn: student.linkedIn,
  github: student.github,
  portfolio: student.portfolio,
  status: student.status,
  createdAt: student.createdAt,
  updatedAt: student.updatedAt,
});

const authPayload = (student, message, statusCode, res) => {
  const token = generateToken(student);
  const profile = publicStudent(student);

  return res.status(statusCode).json({
    success: true,
    message,
    token,
    student: profile,
    user: profile,
    data: {
      token,
      student: profile,
    },
  });
};

const getAuthenticatedStudent = async (req, res) => {
  const studentId = req.user?.id || req.student?._id;

  if (!studentId) {
    errorResponse(res, "Authentication required", 401);
    return null;
  }

  const student = await Student.findById(studentId).select("+password");

  if (!student) {
    errorResponse(res, "Student account not found", 404);
    return null;
  }

  return student;
};

const syncSkillNames = (student) => {
  const skillNames = new Set();

  for (const skill of student.skills || []) {
    if (skill) {
      skillNames.add(String(skill).trim());
    }
  }

  for (const skill of student.skillDetails || []) {
    if (skill.name) {
      skillNames.add(skill.name.trim());
    }
  }

  student.skills = [...skillNames].filter(Boolean);
};

const findSkill = (student, skillIdOrName) => {
  const needle = String(skillIdOrName || "").trim().toLowerCase();

  return student.skillDetails.find(
    (skill) =>
      skill._id?.toString() === skillIdOrName ||
      skill.name.toLowerCase() === needle
  );
};

const buildSkillList = (student) => {
  const mapped = new Map();

  for (const skill of student.skillDetails || []) {
    mapped.set(skill.name.toLowerCase(), skill);
  }

  for (const skillName of student.skills || []) {
    const key = String(skillName).toLowerCase();
    if (!mapped.has(key)) {
      mapped.set(key, {
        id: key,
        _id: key,
        name: skillName,
        proficiency: 0,
        category: "",
        yearsOfExperience: 0,
      });
    }
  }

  return [...mapped.values()];
};

const average = (values) => {
  const numericValues = values.filter((value) => Number.isFinite(value));
  if (!numericValues.length) {
    return 0;
  }

  return numericValues.reduce((sum, value) => sum + value, 0) / numericValues.length;
};

const calculateScoreBreakdown = (student) => {
  const skillValues = (student.skillDetails || []).map((skill) =>
    clampPercentage(skill.proficiency)
  );
  const fallbackSkillScore = Math.min((student.skills || []).length * 10, 100);
  const skillsScore = skillValues.length ? average(skillValues) : fallbackSkillScore;

  const learningScore = average(
    (student.learningProgress || []).map((module) =>
      clampPercentage(module.progressPercentage)
    )
  );
  const assignmentScore = average(
    (student.assignmentSubmissions || []).map((submission) =>
      clampPercentage(submission.score)
    )
  );
  const quizScore = average(
    (student.quizSubmissions || []).map((submission) =>
      clampPercentage(submission.score)
    )
  );

  const weights = {
    skills: 0.4,
    learningProgress: 0.25,
    assignments: 0.2,
    quizzes: 0.15,
  };

  const total =
    skillsScore * weights.skills +
    learningScore * weights.learningProgress +
    assignmentScore * weights.assignments +
    quizScore * weights.quizzes;

  const skillScore = Math.round(total);

  return {
    skillScore,
    eligibilityStatus: skillScore >= 70 ? "Eligible" : "Not Eligible",
    breakdown: {
      skills: {
        score: Math.round(skillsScore),
        weight: weights.skills,
        count: skillValues.length || (student.skills || []).length,
      },
      learningProgress: {
        score: Math.round(learningScore),
        weight: weights.learningProgress,
        count: (student.learningProgress || []).length,
      },
      assignments: {
        score: Math.round(assignmentScore),
        weight: weights.assignments,
        count: (student.assignmentSubmissions || []).length,
      },
      quizzes: {
        score: Math.round(quizScore),
        weight: weights.quizzes,
        count: (student.quizSubmissions || []).length,
      },
    },
  };
};

export const registerStudent = async (req, res) => {
  try {
    const {
      name,
      fullName,
      email,
      phone,
      password,
      role,
      college,
      branch,
      semester,
    } = req.body;

    const displayName = String(name || fullName || "").trim();
    const normalizedEmail = normalizeEmail(email);

    if (!isAllowedRole(role)) {
      return errorResponse(res, "Invalid role specified", 400);
    }

    if (!displayName || !normalizedEmail || !password) {
      return errorResponse(res, "Name, email, and password are required", 400);
    }

    if (!emailRegex.test(normalizedEmail)) {
      return errorResponse(res, "Please provide a valid email address", 400);
    }

    if (String(password).length < 8) {
      return errorResponse(res, "Password must be at least 8 characters long", 400);
    }

    if (college && !isValidObjectId(college)) {
      return errorResponse(res, "Invalid college id", 400);
    }

    const existingStudent = await Student.findOne({ email: normalizedEmail });
    if (existingStudent) {
      return errorResponse(res, "An account with this email already exists", 409);
    }

    const assignedRole = role ? String(role).toLowerCase() : "student";

    const student = await Student.create({
      name: displayName,
      email: normalizedEmail,
      phone,
      password,
      role: assignedRole,
      percentage: toNumber(req.body.percentage) ?? 0,
      college: college || undefined,
      branch,
      semester: toNumber(semester),
    });

    return authPayload(student, "Account registered successfully", 201, res);
  } catch (error) {
    if (error.code === 11000) {
      return errorResponse(res, "An account with this email already exists", 409);
    }

    return errorResponse(res, error.message || "Registration failed", 500);
  }
};

export const loginStudent = async (req, res) => {
  try {
    const { email, password } = req.body;
    const normalizedEmail = normalizeEmail(email);

    if (!normalizedEmail || !password) {
      return errorResponse(res, "Email and password are required", 400);
    }

    const student = await Student.findOne({ email: normalizedEmail }).select("+password");

    if (!student || !(await student.comparePassword(password))) {
      return errorResponse(res, "Invalid email or password", 401);
    }

    if (student.status !== "Active") {
      return errorResponse(res, "Account is inactive", 403);
    }

    return authPayload(student, "Login successful", 200, res);
  } catch (error) {
    return errorResponse(res, error.message || "Login failed", 500);
  }
};

export const logoutStudent = (req, res) =>
  successResponse(res, "Logged out successfully", { token: null });

export const getStudentProfile = async (req, res) => {
  try {
    return successResponse(res, "Student profile fetched successfully", {
      student: publicStudent(req.student),
    });
  } catch (error) {
    return errorResponse(res, error.message || "Failed to fetch student profile", 500);
  }
};

export const updateStudentProfile = async (req, res) => {
  try {
    const student = await getAuthenticatedStudent(req, res);
    if (!student) {
      return null;
    }

    const allowedFields = [
      "name",
      "fullName",
      "phone",
      "college",
      "branch",
      "semester",
      "resume",
      "resumeUrl",
      "bio",
      "location",
      "linkedIn",
      "github",
      "portfolio",
    ];

    for (const field of allowedFields) {
      if (req.body[field] !== undefined) {
        if (field === "fullName") {
          student.name = String(req.body[field]).trim();
        } else if (field === "semester") {
          student.semester = toNumber(req.body[field]);
        } else if (field === "college") {
          if (req.body[field] && !isValidObjectId(req.body[field])) {
            return errorResponse(res, "Invalid college id", 400);
          }
          student.college = req.body[field] || undefined;
        } else {
          student[field] = req.body[field];
        }
      }
    }

    if (Array.isArray(req.body.interests)) {
      student.interests = req.body.interests.map((interest) => String(interest).trim()).filter(Boolean);
    }

    if (Array.isArray(req.body.education)) {
      student.education = req.body.education;
    }

    if (Array.isArray(req.body.skills)) {
      student.skills = req.body.skills.map((skill) => String(skill).trim()).filter(Boolean);
    }

    if (student.resumeUrl && !student.resume) {
      student.resume = student.resumeUrl;
    }

    if (student.resume && !student.resumeUrl) {
      student.resumeUrl = student.resume;
    }

    syncSkillNames(student);
    await student.save();

    return successResponse(res, "Student profile updated successfully", {
      student: publicStudent(student),
    });
  } catch (error) {
    return errorResponse(res, error.message || "Failed to update student profile", 500);
  }
};

export const getStudentSkills = async (req, res) => {
  try {
    return successResponse(res, "Student skills fetched successfully", {
      skills: buildSkillList(req.student),
    });
  } catch (error) {
    return errorResponse(res, error.message || "Failed to fetch student skills", 500);
  }
};

export const addStudentSkill = async (req, res) => {
  try {
    const student = await getAuthenticatedStudent(req, res);
    if (!student) {
      return null;
    }

    const name = String(req.body.name || req.body.skill || "").trim();
    const proficiency = clampPercentage(req.body.proficiency) ?? 0;

    if (!name) {
      return errorResponse(res, "Skill name is required", 400);
    }

    const stringSkillExists = (student.skills || []).some(
      (skill) => String(skill).toLowerCase() === name.toLowerCase()
    );

    if (findSkill(student, name) || stringSkillExists) {
      return errorResponse(res, "Skill already exists", 409);
    }

    student.skillDetails.push({
      name,
      proficiency,
      category: req.body.category,
      yearsOfExperience: toNumber(req.body.yearsOfExperience) || 0,
    });
    syncSkillNames(student);
    await student.save();

    return successResponse(res, "Skill added successfully", {
      skill: student.skillDetails[student.skillDetails.length - 1],
      skills: buildSkillList(student),
    }, 201);
  } catch (error) {
    return errorResponse(res, error.message || "Failed to add skill", 500);
  }
};

export const updateStudentSkill = async (req, res) => {
  try {
    const student = await getAuthenticatedStudent(req, res);
    if (!student) {
      return null;
    }

    const skill = findSkill(student, req.params.skillId || req.body.skillId || req.body.name);
    let skillToUpdate = skill;

    if (!skillToUpdate) {
      const existingSkillName = (student.skills || []).find(
        (name) =>
          String(name).toLowerCase() ===
          String(req.params.skillId || req.body.skillId || req.body.name).toLowerCase()
      );

      if (!existingSkillName) {
        return errorResponse(res, "Skill not found", 404);
      }

      student.skillDetails.push({
        name: existingSkillName,
        proficiency: 0,
      });
      skillToUpdate = student.skillDetails[student.skillDetails.length - 1];
    }

    if (req.body.name !== undefined) {
      const nextName = String(req.body.name).trim();
      const duplicate = student.skillDetails.find(
        (item) =>
          item._id.toString() !== skillToUpdate._id.toString() &&
          item.name.toLowerCase() === nextName.toLowerCase()
      );

      if (duplicate) {
        return errorResponse(res, "Another skill with this name already exists", 409);
      }

      skillToUpdate.name = nextName;
    }

    if (req.body.proficiency !== undefined) {
      skillToUpdate.proficiency = clampPercentage(req.body.proficiency);
    }

    if (req.body.category !== undefined) {
      skillToUpdate.category = req.body.category;
    }

    if (req.body.yearsOfExperience !== undefined) {
      skillToUpdate.yearsOfExperience = toNumber(req.body.yearsOfExperience) || 0;
    }

    syncSkillNames(student);
    await student.save();

    return successResponse(res, "Skill updated successfully", {
      skill: skillToUpdate,
      skills: buildSkillList(student),
    });
  } catch (error) {
    return errorResponse(res, error.message || "Failed to update skill", 500);
  }
};

export const deleteStudentSkill = async (req, res) => {
  try {
    const student = await getAuthenticatedStudent(req, res);
    if (!student) {
      return null;
    }

    const skill = findSkill(student, req.params.skillId || req.body.skillId || req.body.name);
    const skillName = skill?.name || req.params.skillId || req.body.name;
    const hadStringSkill = (student.skills || []).some(
      (name) => String(name).toLowerCase() === String(skillName).toLowerCase()
    );

    if (skill) {
      student.skillDetails.pull(skill._id);
    }

    student.skills = (student.skills || []).filter(
      (name) => String(name).toLowerCase() !== String(skillName).toLowerCase()
    );

    if (!skill && !hadStringSkill) {
      return errorResponse(res, "Skill not found", 404);
    }

    syncSkillNames(student);
    await student.save();

    return successResponse(res, "Skill deleted successfully", {
      skills: buildSkillList(student),
    });
  } catch (error) {
    return errorResponse(res, error.message || "Failed to delete skill", 500);
  }
};

export const getLearningModules = (req, res) =>
  successResponse(res, "Learning modules fetched successfully", {
    modules: req.student.learningProgress || [],
  });

export const updateLearningProgress = async (req, res) => {
  try {
    const student = await getAuthenticatedStudent(req, res);
    if (!student) {
      return null;
    }

    const moduleId = String(req.params.moduleId || req.body.moduleId || "").trim();
    const title = String(req.body.title || req.body.moduleTitle || moduleId).trim();
    const progressPercentage = clampPercentage(req.body.progressPercentage);

    if (!moduleId) {
      return errorResponse(res, "Module id is required", 400);
    }

    if (progressPercentage === undefined) {
      return errorResponse(res, "Progress percentage is required", 400);
    }

    let module = student.learningProgress.find((item) => item.moduleId === moduleId);
    const status = progressPercentage >= 100 ? "completed" : progressPercentage > 0 ? "in-progress" : "enrolled";

    if (!module) {
      student.learningProgress.push({
        moduleId,
        title,
        description: req.body.description,
        progressPercentage,
        status,
        completedAt: status === "completed" ? new Date() : undefined,
        history: [{ progressPercentage, status, note: req.body.note }],
      });
      module = student.learningProgress[student.learningProgress.length - 1];
    } else {
      module.title = title || module.title;
      if (req.body.description !== undefined) {
        module.description = req.body.description;
      }
      module.progressPercentage = progressPercentage;
      module.status = status;
      module.completedAt = status === "completed" ? new Date() : undefined;
      module.history.push({ progressPercentage, status, note: req.body.note });
    }

    await student.save();

    return successResponse(res, "Learning progress updated successfully", {
      module,
      modules: student.learningProgress,
    });
  } catch (error) {
    return errorResponse(res, error.message || "Failed to update learning progress", 500);
  }
};

export const markModuleComplete = async (req, res) => {
  req.body = req.body || {};
  req.body.progressPercentage = 100;
  return updateLearningProgress(req, res);
};

export const getLearningProgressHistory = (req, res) => {
  const moduleId = req.params.moduleId || req.query.moduleId;
  const modules = moduleId
    ? (req.student.learningProgress || []).filter((module) => module.moduleId === moduleId)
    : req.student.learningProgress || [];

  return successResponse(res, "Learning progress history fetched successfully", {
    history: modules.flatMap((module) =>
      (module.history || []).map((entry) => {
        const historyEntry = entry.toObject?.() || entry;

        return {
          moduleId: module.moduleId,
          title: module.title,
          ...historyEntry,
        };
      })
    ),
  });
};

export const getAssignments = (req, res) =>
  successResponse(res, "Assignments fetched successfully", {
    assignments: req.student.assignmentSubmissions || [],
  });

export const submitAssignment = async (req, res) => {
  try {
    const student = await getAuthenticatedStudent(req, res);
    if (!student) {
      return null;
    }

    const assignmentId = String(req.params.assignmentId || req.body.assignmentId || "").trim();
    if (!assignmentId) {
      return errorResponse(res, "Assignment id is required", 400);
    }

    const duplicate = student.assignmentSubmissions.find(
      (submission) => submission.assignmentId === assignmentId
    );

    if (duplicate && !req.body.allowResubmit) {
      return errorResponse(res, "Assignment already submitted", 409);
    }

    const score = clampPercentage(req.body.score);

    const payload = {
      assignmentId,
      title: req.body.title,
      content: req.body.content,
      submissionUrl: req.body.submissionUrl,
      answers: req.body.answers,
      score,
      status: score === undefined ? "submitted" : "graded",
      feedback: req.body.feedback,
      submittedAt: new Date(),
    };

    let submission = duplicate;
    if (duplicate) {
      Object.assign(duplicate, payload);
    } else {
      student.assignmentSubmissions.push(payload);
      submission = student.assignmentSubmissions[student.assignmentSubmissions.length - 1];
    }

    await student.save();

    return successResponse(res, "Assignment submitted successfully", {
      submission,
    }, duplicate ? 200 : 201);
  } catch (error) {
    return errorResponse(res, error.message || "Failed to submit assignment", 500);
  }
};

export const getQuizzes = (req, res) =>
  successResponse(res, "Quizzes fetched successfully", {
    quizzes: req.student.quizSubmissions || [],
  });

export const submitQuiz = async (req, res) => {
  try {
    const student = await getAuthenticatedStudent(req, res);
    if (!student) {
      return null;
    }

    const quizId = String(req.params.quizId || req.body.quizId || "").trim();
    if (!quizId) {
      return errorResponse(res, "Quiz id is required", 400);
    }

    if (req.body.answers === undefined) {
      return errorResponse(res, "Quiz answers are required", 400);
    }

    const duplicate = student.quizSubmissions.find((submission) => submission.quizId === quizId);
    if (duplicate && !req.body.allowResubmit) {
      return errorResponse(res, "Quiz already submitted", 409);
    }

    const totalQuestions = toNumber(req.body.totalQuestions);
    const correctAnswers = toNumber(req.body.correctAnswers);
    const calculatedScore =
      totalQuestions && correctAnswers !== undefined
        ? (correctAnswers / totalQuestions) * 100
        : undefined;
    const score = clampPercentage(req.body.score ?? calculatedScore);

    const payload = {
      quizId,
      title: req.body.title,
      answers: req.body.answers,
      score,
      totalQuestions,
      correctAnswers,
      submittedAt: new Date(),
    };

    let submission = duplicate;
    if (duplicate) {
      Object.assign(duplicate, payload);
    } else {
      student.quizSubmissions.push(payload);
      submission = student.quizSubmissions[student.quizSubmissions.length - 1];
    }

    await student.save();

    return successResponse(res, "Quiz submitted successfully", {
      submission,
    }, duplicate ? 200 : 201);
  } catch (error) {
    return errorResponse(res, error.message || "Failed to submit quiz", 500);
  }
};

export const getSkillScore = async (req, res) => {
  try {
    const result = calculateScoreBreakdown(req.student);

    return successResponse(res, "Skill score calculated successfully", result);
  } catch (error) {
    return errorResponse(res, error.message || "Failed to calculate skill score", 500);
  }
};

export const calculateAndStoreSkillScore = async (req, res) => {
  try {
    const student = await getAuthenticatedStudent(req, res);
    if (!student) {
      return null;
    }

    const result = calculateScoreBreakdown(student);

    student.scoreHistory.push({
      score: result.skillScore,
      eligibilityStatus: result.eligibilityStatus,
      breakdown: result.breakdown,
    });

    await student.save();

    return successResponse(res, "Skill score calculated and stored successfully", result);
  } catch (error) {
    return errorResponse(res, error.message || "Failed to store skill score", 500);
  }
};
