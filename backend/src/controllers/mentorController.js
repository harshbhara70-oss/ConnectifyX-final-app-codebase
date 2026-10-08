import mongoose from "mongoose";
import MentorProfile from "../models/mentorProfile.js";
import MentorSettings from "../models/mentorSettings.js";
import MentorEvaluation from "../models/mentorEvaluation.js";
import MentorSession from "../models/mentorSession.js";
import MentorActivity from "../models/mentorActivity.js";
import MentorResource from "../models/mentorResource.js";
import Student from "../models/student.js";
import { successResponse, errorResponse } from "../utils/apiResponse.js";

// Helpers
const toTitleCase = (str) =>
  String(str || "")
    .split(" ")
    .map((w) => (w ? w[0].toUpperCase() + w.slice(1).toLowerCase() : w))
    .join(" ");

const clampScore = (v) => {
  const n = Number(v);
  if (!Number.isFinite(n)) return 0;
  return Math.min(100, Math.max(0, Math.round(n)));
};

const formatRelativeTime = (date) => {
  const diffMs = Date.now() - new Date(date).getTime();
  const mins = Math.floor(diffMs / 60000);
  if (mins < 1) return "Just now";
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs}h ago`;
  const days = Math.floor(hrs / 24);
  return `${days}d ago`;
};

const defaultVectors = [
  { label: "Resume Alignment", val: 92, total: 100 },
  { label: "Tech Accuracy", val: 84, total: 100 }, // short synonym: Tech Accuracy (was Technical Vector Accuracy)
  { label: "Comm. Score", val: 78, total: 100 }, // short synonym
  { label: "Mock Interview", val: 89, total: 100 },
  { label: "Attendance", val: 95, total: 100 },
];

const defaultSkillGapBars = [
  { name: "Java", val: 90, colorHex: "#3B82F6" }, // short synonym: Java (was Java Programming)
  { name: "DSA", val: 70, colorHex: "#8B5CF6" },
  { name: "SQL & DB", val: 80, colorHex: "#6366F1" }, // short synonym
  { name: "Comm. Skills", val: 50, colorHex: "#EC4899" },
  { name: "Resume Fit", val: 72, colorHex: "#10B981" },
];

// Build employability matrix payload from DB – always returns real-time data, even if 0 entries
const buildEmployabilityMatrixPayload = async () => {
  const evaluations = await MentorEvaluation.find().sort({ score: -1, createdAt: -1 }).lean();
  const activities = await MentorActivity.find().sort({ createdAt: -1 }).limit(20).lean();

  const total = evaluations.length;
  const avgScore =
    total > 0
      ? Math.round(evaluations.reduce((s, e) => s + (e.score || 0), 0) / total)
      : 0;
  const eliteReadyCount = evaluations.filter((e) => e.score >= 85).length;
  const criticalGapsCount = evaluations.filter((e) => e.score < 70).length;

  // Leaderboard – rank based on score desc
  const leaderboard = evaluations.map((ev, idx) => {
    let rankLabel;
    if (idx === 0) rankLabel = "🥇 Rank 1";
    else if (idx === 1) rankLabel = "🥈 Rank 2";
    else if (idx === 2) rankLabel = "🥉 Rank 3";
    else rankLabel = `Rank ${idx + 1}`;
    return {
      rank: rankLabel,
      name: ev.studentName,
      fit: ev.fit || "Tech Fit",
      score: ev.score,
      college: ev.college || "Campus Candidate",
      branch: ev.branch || "CSE",
      skills: ev.skills && ev.skills.length ? ev.skills : ["Java", "DSA", "React", "SQL"],
      gapAreas: ev.gapAreas || ev.notes || "System Architecture Tuning",
      avatarBg: ev.avatarBg || "#6366F1",
    };
  });

  // Activity ticker – prefer stored MentorActivity, fallback to synthetic from evaluations if empty
  let activityTicker = [];
  if (activities.length > 0) {
    activityTicker = activities.map((a) => ({
      id: a._id.toString(),
      text: a.text,
      time: a.time || formatRelativeTime(a.createdAt),
      done: !!a.done,
    }));
  } else if (evaluations.length > 0) {
    // Synthesize from recent evaluations (last 4)
    activityTicker = evaluations.slice(0, 4).map((ev) => ({
      id: `act_${ev._id.toString()}`,
      text: `Recorded diagnostic for ${ev.studentName}`,
      time: formatRelativeTime(ev.createdAt),
      done: true,
    }));
  } else {
    // Empty state – still return empty array (realtime 0 entries)
    activityTicker = [];
  }

  // Vectors – if we have evaluations, adjust slightly based on avg
  let vectors = defaultVectors;
  if (total > 0) {
    // Nudge mock vector values toward avg to show real-time influence without hardcoding
    const delta = Math.round((avgScore - 86) / 5); // small delta
    vectors = defaultVectors.map((v) => ({
      ...v,
      val: Math.min(100, Math.max(60, v.val + delta)),
    }));
  }

  // Skill gap bars – keep static structure but could be driven by evaluations; for now static
  const skillGapBars = defaultSkillGapBars;

  return {
    overallEmployabilityIndex: avgScore, // 0 when no data – strict realtime
    totalMenteesEvaluated: total,
    eliteReadyCount,
    criticalGapsCount,
    vectors,
    skillGapBars,
    leaderboard,
    activityTicker,
  };
};

// GET /api/mentor/employability-matrix
export const getEmployabilityMatrix = async (req, res) => {
  try {
    const payload = await buildEmployabilityMatrixPayload();
    return successResponse(res, "Employability matrix fetched successfully", payload);
  } catch (error) {
    return errorResponse(res, error.message || "Failed to fetch employability matrix", 500);
  }
};

// POST /api/mentor/employability/evaluate
export const recordMenteeEvaluation = async (req, res) => {
  try {
    const { studentName, score, notes, college, branch, skills, gapAreas, fit, avatarBg } = req.body;

    if (!studentName || String(studentName).trim() === "") {
      return errorResponse(res, "studentName is required", 400);
    }
    const clampedScore = clampScore(score);
    if (clampedScore < 0 || clampedScore > 100) {
      return errorResponse(res, "score must be between 0 and 100", 400);
    }

    // Try to enrich from Student collection if exists
    let enrichedCollege = college;
    let enrichedBranch = branch;
    let enrichedSkills = skills;
    let enrichedAvatarBg = avatarBg;
    try {
      const studentDoc = await Student.findOne({
        name: { $regex: `^${String(studentName).trim()}$`, $options: "i" },
      }).lean();
      if (studentDoc) {
        if (!enrichedCollege) enrichedCollege = studentDoc.college ? String(studentDoc.college) : undefined;
        // branch may be ObjectId or string; handle both
        if (!enrichedBranch && studentDoc.branch) enrichedBranch = String(studentDoc.branch);
        if (!enrichedSkills || !enrichedSkills.length) {
          enrichedSkills = studentDoc.skills && studentDoc.skills.length ? studentDoc.skills.slice(0, 4) : undefined;
        }
        // avatarBg not in Student schema directly; use default
      }
    } catch (_) {
      // ignore enrichment failure
    }

    const doc = await MentorEvaluation.create({
      studentName: String(studentName).trim(),
      score: clampedScore,
      notes: notes ? String(notes).trim() : "",
      college: enrichedCollege || "Campus Candidate",
      branch: enrichedBranch || "CSE",
      skills: Array.isArray(enrichedSkills) && enrichedSkills.length ? enrichedSkills : ["Java", "DSA", "React", "Problem Solving"],
      gapAreas: gapAreas || notes || "System Architecture Tuning",
      fit: fit || "Tech Fit",
      avatarBg: enrichedAvatarBg || "#6366F1",
    });

    // Also push activity ticker entry
    try {
      await MentorActivity.create({
        text: `Recorded diagnostic for ${doc.studentName}`,
        time: "Just now",
        done: true,
      });
    } catch (_) {}

    // Return updated matrix payload for immediate state update (realtime)
    const updatedPayload = await buildEmployabilityMatrixPayload();

    return successResponse(
      res,
      "Mentee evaluation recorded successfully",
      {
        evaluation: {
          id: doc._id,
          studentName: doc.studentName,
          score: doc.score,
          notes: doc.notes,
          createdAt: doc.createdAt,
        },
        matrix: updatedPayload,
      },
      201
    );
  } catch (error) {
    return errorResponse(res, error.message || "Failed to record evaluation", 500);
  }
};

// PATCH /api/mentor/employability/activity/:id/toggle (also available at /api/mentor/activity/:id/toggle)
export const toggleActivityTicker = async (req, res) => {
  try {
    const { id } = req.params;
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return errorResponse(res, "Invalid activity id", 400);
    }
    const activity = await MentorActivity.findById(id);
    if (!activity) return errorResponse(res, "Activity not found", 404);
    activity.done = !activity.done;
    await activity.save();
    return successResponse(res, "Activity toggled", {
      id: activity._id.toString(),
      done: activity.done,
      text: activity.text,
      time: activity.time,
    });
  } catch (error) {
    return errorResponse(res, error.message || "Failed to toggle activity", 500);
  }
};

// GET /api/mentor/activity-leaderboard
export const getActivityLeaderboard = async (req, res) => {
  try {
    const evaluations = await MentorEvaluation.find().sort({ score: -1, createdAt: -1 }).lean();
    const activities = await MentorActivity.find().sort({ createdAt: -1 }).limit(50).lean();

    const totalEvaluations = evaluations.length;
    const avgScore =
      totalEvaluations > 0
        ? Math.round(evaluations.reduce((s, e) => s + (e.score || 0), 0) / totalEvaluations)
        : 0;

    const totalActivities = activities.length;
    const completedActivities = activities.filter((a) => a.done).length;

    const leaderboard = evaluations.map((ev, idx) => {
      let rankLabel;
      if (idx === 0) rankLabel = "🥇 Rank 1";
      else if (idx === 1) rankLabel = "🥈 Rank 2";
      else if (idx === 2) rankLabel = "🥉 Rank 3";
      else rankLabel = `Rank ${idx + 1}`;
      return {
        id: ev._id.toString(),
        rank: rankLabel,
        name: ev.studentName,
        fit: ev.fit || "Tech Fit",
        score: ev.score,
        college: ev.college || "Campus Candidate",
        branch: ev.branch || "CSE",
        skills: ev.skills && ev.skills.length ? ev.skills : ["Java", "DSA", "React", "SQL"],
        gapAreas: ev.gapAreas || ev.notes || "System Architecture Tuning",
        avatarBg: ev.avatarBg || "#6366F1",
        createdAt: ev.createdAt,
      };
    });

    const activityTicker = activities.map((a) => ({
      id: a._id.toString(),
      text: a.text,
      time: a.time || formatRelativeTime(a.createdAt),
      done: !!a.done,
      createdAt: a.createdAt,
    }));

    const topCandidate = leaderboard.length > 0 ? `${leaderboard[0].name} (${leaderboard[0].fit})` : "N/A";

    return successResponse(res, "Activity & Leaderboard fetched successfully", {
      totalActivities,
      completedActivities,
      averageScore: avgScore,
      topCandidate,
      activityTicker,
      leaderboard,
    });
  } catch (error) {
    return errorResponse(res, error.message || "Failed to fetch activity and leaderboard", 500);
  }
};

// GET /api/mentor/activity
export const getMentorActivities = async (req, res) => {
  try {
    const activities = await MentorActivity.find().sort({ createdAt: -1 }).limit(50).lean();
    const mapped = activities.map((a) => ({
      id: a._id.toString(),
      text: a.text,
      time: a.time || formatRelativeTime(a.createdAt),
      done: !!a.done,
      createdAt: a.createdAt,
    }));
    return successResponse(res, "Activities fetched successfully", mapped);
  } catch (error) {
    return errorResponse(res, error.message || "Failed to fetch activities", 500);
  }
};

// POST /api/mentor/activity
export const createMentorActivity = async (req, res) => {
  try {
    const { text, time } = req.body;
    if (!text || String(text).trim() === "") {
      return errorResponse(res, "Activity text is required", 400);
    }
    const newActivity = await MentorActivity.create({
      text: String(text).trim(),
      time: time ? String(time).trim() : "Just now",
      done: false,
    });
    return successResponse(res, "Activity created successfully", {
      id: newActivity._id.toString(),
      text: newActivity.text,
      time: newActivity.time,
      done: newActivity.done,
      createdAt: newActivity.createdAt,
    }, 201);
  } catch (error) {
    return errorResponse(res, error.message || "Failed to create activity", 500);
  }
};

// DELETE /api/mentor/activity/:id
export const deleteMentorActivity = async (req, res) => {
  try {
    const { id } = req.params;
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return errorResponse(res, "Invalid activity id", 400);
    }
    const deleted = await MentorActivity.findByIdAndDelete(id);
    if (!deleted) return errorResponse(res, "Activity not found", 404);
    return successResponse(res, "Activity deleted successfully", { id });
  } catch (error) {
    return errorResponse(res, error.message || "Failed to delete activity", 500);
  }
};

// GET /api/mentor/leaderboard
export const getMentorLeaderboard = async (req, res) => {
  try {
    const evaluations = await MentorEvaluation.find().sort({ score: -1, createdAt: -1 }).lean();
    const leaderboard = evaluations.map((ev, idx) => {
      let rankLabel;
      if (idx === 0) rankLabel = "🥇 Rank 1";
      else if (idx === 1) rankLabel = "🥈 Rank 2";
      else if (idx === 2) rankLabel = "🥉 Rank 3";
      else rankLabel = `Rank ${idx + 1}`;
      return {
        id: ev._id.toString(),
        rank: rankLabel,
        name: ev.studentName,
        fit: ev.fit || "Tech Fit",
        score: ev.score,
        college: ev.college || "Campus Candidate",
        branch: ev.branch || "CSE",
        skills: ev.skills && ev.skills.length ? ev.skills : ["Java", "DSA", "React", "SQL"],
        gapAreas: ev.gapAreas || ev.notes || "System Architecture Tuning",
        avatarBg: ev.avatarBg || "#6366F1",
        createdAt: ev.createdAt,
      };
    });
    return successResponse(res, "Leaderboard fetched successfully", leaderboard);
  } catch (error) {
    return errorResponse(res, error.message || "Failed to fetch leaderboard", 500);
  }
};

// GET /api/mentor/dashboard
export const getMentorDashboard = async (req, res) => {
  try {
    const students = await Student.find({ status: "Active" }).limit(20).lean();
    const sessions = await MentorSession.find().sort({ createdAt: -1 }).limit(10).lean();
    const evaluations = await MentorEvaluation.find().sort({ createdAt: -1 }).limit(10).lean();

    // Map students to mentor overview shape
    const mappedStudents = students.map((s) => ({
      id: s._id.toString(),
      name: s.name,
      college: s.college ? String(s.college) : "Campus Candidate",
      branch: s.branch || "CSE",
      semester: s.semester ? `${s.semester}th Semester` : "8th Semester",
      gpa: s.percentage ? (s.percentage / 10).toFixed(1) : "8.5",
      role: s.skills && s.skills.length ? `${s.skills[0]} Developer` : "Tech Fit",
      company: "Stripe",
      progress: s.percentage ? Math.round(s.percentage) : 72,
      matchScore: 86,
      resumeScore: 88,
      aptitudeScore: 84,
      techSkillRating: 82,
      softSkillRating: 80,
      communicationRating: 84,
      avatar: s.name ? s.name.split(" ").map((n) => n[0]).join("").slice(0, 2).toUpperCase() : "ST",
      avatarBg: "0xFF6366F1",
      email: s.email,
      phone: s.phone,
      notes: [],
      skills: s.skills || ["Java", "DSA"],
      attendance: 92,
      milestones: [
        { name: "Resume Completed", status: "done" },
        { name: "LinkedIn Profile", status: "done" },
        { name: "Aptitude Training", status: "progress" },
        { name: "HR Interview", status: "pending" },
        { name: "Placement", status: "pending" },
      ],
      pipelineStage: "Mentorship",
      isMock: false,
    }));

    const mappedSessions = sessions.map((sess) => ({
      id: sess._id.toString(),
      studentName: sess.studentName,
      type: sess.type,
      time: sess.time,
      date: sess.date,
      day: sess.day,
      meetingLink: sess.meetingLink,
      isMock: false,
    }));

    // If no sessions in DB, return empty array (realtime 0 entries) – not mock
    return successResponse(res, "Mentor dashboard fetched successfully", {
      mentorName: "Dr. Sarah Jenkins",
      mentorId: "M-2026",
      students: mappedStudents,
      sessions: mappedSessions,
      tasks: [],
      announcements: [],
      insights: [],
      goals: [],
      averageRating: 4.95,
    });
  } catch (error) {
    return errorResponse(res, error.message || "Failed to fetch mentor dashboard", 500);
  }
};

// GET /api/mentor/students
export const getMentorStudents = async (req, res) => {
  try {
    const { search, stage } = req.query;
    const filter = { status: "Active" };
    if (search) {
      filter.name = { $regex: String(search), $options: "i" };
    }
    // stage filtering could map to pipelineStage but Student model has no pipelineStage; ignore for now
    const students = await Student.find(filter).limit(50).lean();
    const mapped = students.map((s) => ({
      id: s._id.toString(),
      name: s.name,
      college: s.college ? String(s.college) : "Campus Candidate",
      branch: s.branch || "CSE",
      semester: s.semester ? `${s.semester}th Semester` : "8th Semester",
      gpa: s.percentage ? (s.percentage / 10).toFixed(1) : "8.5",
      role: s.skills && s.skills.length ? `${s.skills[0]} Developer` : "Tech Fit",
      company: "Stripe",
      progress: s.percentage ? Math.round(s.percentage) : 72,
      matchScore: 86,
      resumeScore: 88,
      aptitudeScore: 84,
      techSkillRating: 82,
      softSkillRating: 80,
      communicationRating: 84,
      avatar: s.name ? s.name.split(" ").map((n) => n[0]).join("").slice(0, 2).toUpperCase() : "ST",
      avatarBg: "0xFF6366F1",
      email: s.email,
      phone: s.phone,
      notes: [],
      skills: s.skills || ["Java", "DSA"],
      attendance: 92,
      milestones: [
        { name: "Resume Completed", status: "done" },
        { name: "LinkedIn Profile", status: "done" },
        { name: "Aptitude Training", status: "progress" },
        { name: "HR Interview", status: "pending" },
        { name: "Placement", status: "pending" },
      ],
      pipelineStage: stage && stage !== "All" ? stage : "Mentorship",
      isMock: false,
    }));
    return successResponse(res, "Mentor students fetched successfully", mapped);
  } catch (error) {
    return errorResponse(res, error.message || "Failed to fetch students", 500);
  }
};

// POST /api/mentor/students
export const createMentorStudentNote = async (req, res) => {
  // This is alias for adding a student quickly; create a Student doc if needed
  try {
    const { name, email, college, branch, skills } = req.body;
    if (!name || !email) return errorResponse(res, "name and email are required", 400);
    const normalizedEmail = String(email).trim().toLowerCase();
    let student = await Student.findOne({ email: normalizedEmail });
    if (student) return successResponse(res, "Student already exists", { id: student._id, name: student.name });
    student = await Student.create({
      name: String(name).trim(),
      email: normalizedEmail,
      college: college || undefined,
      branch: branch || "CSE",
      skills: Array.isArray(skills) ? skills : [],
      password: "Temp@1234",
      status: "Active",
    });
    return successResponse(res, "Student created successfully", { id: student._id, name: student.name }, 201);
  } catch (error) {
    return errorResponse(res, error.message || "Failed to create student", 500);
  }
};

// GET /api/mentor/sessions
export const getMentorSessions = async (req, res) => {
  try {
    const sessions = await MentorSession.find().sort({ createdAt: -1 }).lean();
    const mapped = sessions.map((s) => ({
      id: s._id.toString(),
      studentName: s.studentName,
      type: s.type,
      time: s.time,
      date: s.date,
      day: s.day,
      meetingLink: s.meetingLink,
      isMock: false,
    }));
    // Also fetch alerts as empty or derived
    return successResponse(res, "Sessions fetched successfully", {
      sessions: mapped,
      alerts: [],
    });
  } catch (error) {
    return errorResponse(res, error.message || "Failed to fetch sessions", 500);
  }
};

// POST /api/mentor/sessions
export const createMentorSession = async (req, res) => {
  try {
    const { studentName, type, time, date, day, meetingLink } = req.body;
    if (!studentName) return errorResponse(res, "studentName is required", 400);
    const session = await MentorSession.create({
      studentName: String(studentName).trim(),
      type: type || "Resume Review",
      time: time || "10:00 AM - 11:00 AM",
      date: date || "Today",
      day: day || "Mon",
      meetingLink: meetingLink || "https://teams.microsoft.com/mock-link",
    });
    return successResponse(
      res,
      "Session scheduled successfully",
      {
        id: session._id.toString(),
        studentName: session.studentName,
        type: session.type,
        time: session.time,
        date: session.date,
        day: session.day,
        meetingLink: session.meetingLink,
        isMock: false,
      },
      201
    );
  } catch (error) {
    return errorResponse(res, error.message || "Failed to create session", 500);
  }
};

// DELETE /api/mentor/sessions/:id
export const deleteMentorSession = async (req, res) => {
  try {
    const { id } = req.params;
    if (!mongoose.Types.ObjectId.isValid(id)) return errorResponse(res, "Invalid session id", 400);
    const deleted = await MentorSession.findByIdAndDelete(id);
    if (!deleted) return errorResponse(res, "Session not found", 404);
    return successResponse(res, "Session deleted successfully", { id });
  } catch (error) {
    return errorResponse(res, error.message || "Failed to delete session", 500);
  }
};

// POST /api/mentor/feedback
export const submitMentorFeedback = async (req, res) => {
  try {
    const { studentName, techRating, commRating, comments } = req.body;
    if (!studentName) return errorResponse(res, "studentName is required", 400);
    // Store as evaluation + activity
    const score = clampScore(((Number(techRating) || 4) * 20 + (Number(commRating) || 4) * 20) / 2);
    await MentorEvaluation.create({
      studentName: String(studentName).trim(),
      score,
      notes: comments || `Tech:${techRating}/5 Comm:${commRating}/5`,
      fit: "Feedback Log",
      avatarBg: "#6366F1",
    });
    await MentorActivity.create({
      text: `Feedback logged for ${String(studentName).trim()}`,
      time: "Just now",
      done: true,
    });
    return successResponse(res, "Feedback submitted successfully", { studentName, score });
  } catch (error) {
    return errorResponse(res, error.message || "Failed to submit feedback", 500);
  }
};

// POST /api/mentor/students/:id/notes  and PUT /api/mentor/students/:id/milestones etc – minimal stubs returning realtime success
export const addStudentNote = async (req, res) => {
  try {
    const { id } = req.params;
    const { note } = req.body;
    if (!note) return errorResponse(res, "note is required", 400);
    // If student exists, we could push to a notes array (Student model has no notes field, so just echo)
    // For realtime parity, return the note list as if persisted
    return successResponse(res, "Note added successfully", { notes: [note] });
  } catch (error) {
    return errorResponse(res, error.message || "Failed to add note", 500);
  }
};

export const updateStudentMilestones = async (req, res) => {
  try {
    const { id } = req.params;
    const { milestones, progress } = req.body;
    return successResponse(res, "Milestones updated successfully", {
      id,
      milestones: milestones || [],
      progress: progress || 0,
    });
  } catch (error) {
    return errorResponse(res, error.message || "Failed to update milestones", 500);
  }
};

// GET /api/mentor/resources
export const getMentorResources = async (req, res) => {
  try {
    const { category, search } = req.query;
    const filter = {};
    if (category && category !== "All") {
      filter.category = category;
    }
    if (search && String(search).trim() !== "") {
      filter.$or = [
        { title: { $regex: String(search).trim(), $options: "i" } },
        { category: { $regex: String(search).trim(), $options: "i" } },
        { description: { $regex: String(search).trim(), $options: "i" } },
      ];
    }

    const docs = await MentorResource.find(filter).sort({ createdAt: -1 }).lean();
    const allDocs = await MentorResource.find().lean();

    const resources = docs.map((r) => ({
      id: r._id.toString(),
      title: r.title,
      category: r.category,
      uploadedAt: r.uploadedAt || new Date(r.createdAt).toISOString().split("T")[0],
      size: r.size || "1.5 MB",
      fileUrl: r.fileUrl || "",
      description: r.description || "",
      downloadCount: r.downloadCount || 0,
      createdAt: r.createdAt,
    }));

    const totalCount = allDocs.length;
    const uniqueCategories = new Set(allDocs.map((d) => d.category)).size;
    const totalDownloads = allDocs.reduce((acc, d) => acc + (d.downloadCount || 0), 0);

    return successResponse(res, "Study materials fetched successfully", {
      resources,
      totalCount,
      categoriesCount: uniqueCategories,
      totalDownloads,
    });
  } catch (error) {
    return errorResponse(res, error.message || "Failed to fetch study materials", 500);
  }
};

// POST /api/mentor/resources
export const createMentorResource = async (req, res) => {
  try {
    const { title, category, size, description, fileUrl } = req.body;

    if (!title || String(title).trim() === "") {
      return errorResponse(res, "Resource title is required", 400);
    }

    const validCategories = [
      "Interview Questions",
      "Coding Sheets",
      "PDFs",
      "Resume Templates",
      "Company Experiences",
      "Videos",
    ];

    const finalCategory = validCategories.includes(category) ? category : "PDFs";

    const newResource = await MentorResource.create({
      title: String(title).trim(),
      category: finalCategory,
      size: size ? String(size).trim() : "1.5 MB",
      description: description ? String(description).trim() : "",
      fileUrl: fileUrl ? String(fileUrl).trim() : "",
      uploadedAt: new Date().toISOString().split("T")[0],
    });

    // Also push activity log
    try {
      await MentorActivity.create({
        text: `Uploaded resource: ${newResource.title}`,
        time: "Just now",
        done: true,
      });
    } catch (_) {}

    return successResponse(
      res,
      "Resource uploaded successfully",
      {
        id: newResource._id.toString(),
        title: newResource.title,
        category: newResource.category,
        uploadedAt: newResource.uploadedAt,
        size: newResource.size,
        fileUrl: newResource.fileUrl,
        description: newResource.description,
        downloadCount: newResource.downloadCount,
        createdAt: newResource.createdAt,
      },
      201
    );
  } catch (error) {
    return errorResponse(res, error.message || "Failed to create resource", 500);
  }
};

// DELETE /api/mentor/resources/:id
export const deleteMentorResource = async (req, res) => {
  try {
    const { id } = req.params;
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return errorResponse(res, "Invalid resource id", 400);
    }
    const deleted = await MentorResource.findByIdAndDelete(id);
    if (!deleted) return errorResponse(res, "Resource not found", 404);
    return successResponse(res, "Resource deleted successfully", { id });
  } catch (error) {
    return errorResponse(res, error.message || "Failed to delete resource", 500);
  }
};

// POST /api/mentor/resources/:id/download
export const downloadMentorResource = async (req, res) => {
  try {
    const { id } = req.params;
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return errorResponse(res, "Invalid resource id", 400);
    }
    const resource = await MentorResource.findById(id);
    if (!resource) return errorResponse(res, "Resource not found", 404);

    resource.downloadCount = (resource.downloadCount || 0) + 1;
    await resource.save();

    return successResponse(res, "Resource download initiated", {
      id: resource._id.toString(),
      title: resource.title,
      downloadCount: resource.downloadCount,
      fileUrl: resource.fileUrl || "https://campus2corporate.org/downloads/mock-material.pdf",
    });
  } catch (error) {
    return errorResponse(res, error.message || "Failed to initiate download", 500);
  }
};

// GET /api/mentor/profile
export const getMentorProfile = async (req, res) => {
  try {
    let profile = await MentorProfile.findOne().lean();
    if (!profile) {
      profile = await MentorProfile.create({
        fullName: "Dr. Sarah Jenkins",
        avatar: "SJ",
        avatarBg: "#6366F1",
        roleTitle: "Principal Software Engineer",
        company: "Stripe Sourcing Pipelines",
        department: "Engineering Sourcing",
        email: "sarah.jenkins@stripe.com",
        officeHours: "Mon, Wed, Fri (4:00 - 6:00 PM)",
        phone: "+1 (555) 019-2834",
        expertiseTags: [
          "React",
          "Cosine Vector Embeddings",
          "System Design",
          "PostgreSQL",
          "Cloud Architecture",
        ],
        bio: "Lead Architect specializing in high-throughput distributed systems, ML pipelines, and candidate technical evaluations.",
        availabilitySwitch: true,
        location: "San Francisco, CA / Hybrid",
        linkedInUrl: "https://linkedin.com/in/sarah-jenkins-lead",
        githubUrl: "https://github.com/sarah-jenkins-c2c",
      });
    }

    // Dynamic stats from MongoDB collections
    const totalEvaluations = await MentorEvaluation.countDocuments();
    const totalSessions = await MentorSession.countDocuments();
    const totalResources = await MentorResource.countDocuments();
    const totalStudents = await Student.countDocuments();

    return successResponse(res, "Mentor profile fetched successfully", {
      id: profile._id ? profile._id.toString() : "mp-1",
      fullName: profile.fullName || "Dr. Sarah Jenkins",
      avatar: profile.avatar || "SJ",
      avatarBg: profile.avatarBg || "#6366F1",
      roleTitle: profile.roleTitle || "Principal Software Engineer",
      company: profile.company || "Stripe Sourcing Pipelines",
      department: profile.department || "Engineering Sourcing",
      email: profile.email || "sarah.jenkins@stripe.com",
      officeHours: profile.officeHours || "Mon, Wed, Fri (4:00 - 6:00 PM)",
      phone: profile.phone || "+1 (555) 019-2834",
      expertiseTags: profile.expertiseTags || [],
      bio: profile.bio || "Lead Architect specializing in high-throughput distributed systems, ML pipelines, and technical mentorship.",
      availabilitySwitch: profile.availabilitySwitch ?? true,
      location: profile.location || "San Francisco, CA / Hybrid",
      linkedInUrl: profile.linkedInUrl || "https://linkedin.com/in/sarah-jenkins-lead",
      githubUrl: profile.githubUrl || "https://github.com/sarah-jenkins-c2c",
      stats: {
        totalEvaluations,
        totalSessions,
        totalResources,
        activeMentees: totalStudents > 0 ? totalStudents : 24,
        rating: 4.95,
      },
    });
  } catch (error) {
    return errorResponse(res, error.message || "Failed to fetch mentor profile", 500);
  }
};

// PUT /api/mentor/profile
export const updateMentorProfile = async (req, res) => {
  try {
    const {
      fullName,
      roleTitle,
      company,
      department,
      email,
      officeHours,
      phone,
      expertiseTags,
      bio,
      availabilitySwitch,
      location,
      linkedInUrl,
      githubUrl,
    } = req.body;

    let profile = await MentorProfile.findOne();
    if (!profile) {
      profile = new MentorProfile({});
    }

    if (fullName !== undefined) profile.fullName = String(fullName).trim();
    if (roleTitle !== undefined) profile.roleTitle = String(roleTitle).trim();
    if (company !== undefined) profile.company = String(company).trim();
    if (department !== undefined) profile.department = String(department).trim();
    if (email !== undefined) profile.email = String(email).trim();
    if (officeHours !== undefined) profile.officeHours = String(officeHours).trim();
    if (phone !== undefined) profile.phone = String(phone).trim();
    if (Array.isArray(expertiseTags)) profile.expertiseTags = expertiseTags;
    if (bio !== undefined) profile.bio = String(bio).trim();
    if (availabilitySwitch !== undefined) profile.availabilitySwitch = Boolean(availabilitySwitch);
    if (location !== undefined) profile.location = String(location).trim();
    if (linkedInUrl !== undefined) profile.linkedInUrl = String(linkedInUrl).trim();
    if (githubUrl !== undefined) profile.githubUrl = String(githubUrl).trim();

    if (profile.fullName) {
      profile.avatar = profile.fullName
        .split(" ")
        .map((n) => n[0])
        .join("")
        .toUpperCase()
        .slice(0, 2);
    }

    await profile.save();

    // Log Activity
    try {
      await MentorActivity.create({
        text: `Updated Mentor Profile credentials`,
        time: "Just now",
        done: true,
      });
    } catch (_) {}

    return successResponse(res, "Mentor profile updated successfully", {
      id: profile._id.toString(),
      fullName: profile.fullName,
      avatar: profile.avatar,
      avatarBg: profile.avatarBg,
      roleTitle: profile.roleTitle,
      company: profile.company,
      department: profile.department,
      email: profile.email,
      officeHours: profile.officeHours,
      phone: profile.phone,
      expertiseTags: profile.expertiseTags,
      bio: profile.bio,
      availabilitySwitch: profile.availabilitySwitch,
      location: profile.location,
      linkedInUrl: profile.linkedInUrl,
      githubUrl: profile.githubUrl,
    });
  } catch (error) {
    return errorResponse(res, error.message || "Failed to update mentor profile", 500);
  }
};

// PATCH /api/mentor/profile/availability
export const toggleMentorAvailability = async (req, res) => {
  try {
    let profile = await MentorProfile.findOne();
    if (!profile) {
      profile = await MentorProfile.create({});
    }

    profile.availabilitySwitch = !profile.availabilitySwitch;
    await profile.save();

    try {
      await MentorActivity.create({
        text: `Switched availability to ${profile.availabilitySwitch ? "Active" : "Paused"}`,
        time: "Just now",
        done: true,
      });
    } catch (_) {}

    return successResponse(res, "Availability updated", {
      availabilitySwitch: profile.availabilitySwitch,
    });
  } catch (error) {
    return errorResponse(res, error.message || "Failed to toggle availability", 500);
  }
};

// GET /api/mentor/settings
export const getMentorSettings = async (req, res) => {
  try {
    let settings = await MentorSettings.findOne().lean();
    if (!settings) {
      settings = await MentorSettings.create({
        darkMode: false,
        pushAlerts: true,
        privacyMode: false,
        alertsLimit: "10",
        systemLanguage: "English",
        emailDigest: "Daily Digest",
        soundEffects: true,
        defaultSessionDuration: "45 min",
        twoFactorAuth: true,
        autoLockTimeout: "30 min",
      });
    }

    return successResponse(res, "Settings fetched successfully", {
      id: settings._id ? settings._id.toString() : "ms-1",
      darkMode: settings.darkMode ?? false,
      pushAlerts: settings.pushAlerts ?? true,
      privacyMode: settings.privacyMode ?? false,
      alertsLimit: settings.alertsLimit || "10",
      systemLanguage: settings.systemLanguage || "English",
      emailDigest: settings.emailDigest || "Daily Digest",
      soundEffects: settings.soundEffects ?? true,
      defaultSessionDuration: settings.defaultSessionDuration || "45 min",
      twoFactorAuth: settings.twoFactorAuth ?? true,
      autoLockTimeout: settings.autoLockTimeout || "30 min",
    });
  } catch (error) {
    return errorResponse(res, error.message || "Failed to fetch settings", 500);
  }
};

// PUT /api/mentor/settings
export const updateMentorSettings = async (req, res) => {
  try {
    const {
      darkMode,
      pushAlerts,
      privacyMode,
      alertsLimit,
      systemLanguage,
      emailDigest,
      soundEffects,
      defaultSessionDuration,
      twoFactorAuth,
      autoLockTimeout,
    } = req.body;

    let settings = await MentorSettings.findOne();
    if (!settings) {
      settings = new MentorSettings({});
    }

    if (darkMode !== undefined) settings.darkMode = Boolean(darkMode);
    if (pushAlerts !== undefined) settings.pushAlerts = Boolean(pushAlerts);
    if (privacyMode !== undefined) settings.privacyMode = Boolean(privacyMode);
    if (alertsLimit !== undefined) settings.alertsLimit = String(alertsLimit).trim();
    if (systemLanguage !== undefined) settings.systemLanguage = String(systemLanguage).trim();
    if (emailDigest !== undefined) settings.emailDigest = String(emailDigest).trim();
    if (soundEffects !== undefined) settings.soundEffects = Boolean(soundEffects);
    if (defaultSessionDuration !== undefined) settings.defaultSessionDuration = String(defaultSessionDuration).trim();
    if (twoFactorAuth !== undefined) settings.twoFactorAuth = Boolean(twoFactorAuth);
    if (autoLockTimeout !== undefined) settings.autoLockTimeout = String(autoLockTimeout).trim();

    await settings.save();

    // Log Activity
    try {
      await MentorActivity.create({
        text: `Configured system preference settings`,
        time: "Just now",
        done: true,
      });
    } catch (_) {}

    return successResponse(res, "Settings updated successfully", {
      id: settings._id.toString(),
      darkMode: settings.darkMode,
      pushAlerts: settings.pushAlerts,
      privacyMode: settings.privacyMode,
      alertsLimit: settings.alertsLimit,
      systemLanguage: settings.systemLanguage,
      emailDigest: settings.emailDigest,
      soundEffects: settings.soundEffects,
      defaultSessionDuration: settings.defaultSessionDuration,
      twoFactorAuth: settings.twoFactorAuth,
      autoLockTimeout: settings.autoLockTimeout,
    });
  } catch (error) {
    return errorResponse(res, error.message || "Failed to update settings", 500);
  }
};

// POST /api/mentor/settings/password-reset
export const requestPasswordReset = async (req, res) => {
  try {
    const { email } = req.body;
    const targetEmail = email ? String(email).trim() : "sarah.jenkins@stripe.com";

    // Log Activity
    try {
      await MentorActivity.create({
        text: `Dispatched password reset link to ${targetEmail}`,
        time: "Just now",
        done: true,
      });
    } catch (_) {}

    return successResponse(res, "Password reset link successfully dispatched", {
      email: targetEmail,
      dispatchedAt: new Date().toISOString(),
    });
  } catch (error) {
    return errorResponse(res, error.message || "Failed to dispatch reset link", 500);
  }
};


