import mongoose from "mongoose";

const mentorEvaluationSchema = new mongoose.Schema(
  {
    studentName: {
      type: String,
      required: true,
      trim: true,
    },
    score: {
      type: Number,
      required: true,
      min: 0,
      max: 100,
    },
    notes: {
      type: String,
      trim: true,
      default: "",
    },
    // Denormalized snapshot for leaderboard display – filled at creation time
    college: {
      type: String,
      trim: true,
      default: "Campus Candidate",
    },
    branch: {
      type: String,
      trim: true,
      default: "CSE",
    },
    skills: {
      type: [String],
      default: ["Java", "DSA", "React", "Problem Solving"],
    },
    gapAreas: {
      type: String,
      trim: true,
      default: "System Architecture Tuning",
    },
    fit: {
      type: String,
      trim: true,
      default: "Tech Fit",
    },
    avatarBg: {
      type: String,
      trim: true,
      default: "#6366F1",
    },
    // Optional mentor identifier if multi-mentor support needed
    mentorId: {
      type: String,
      trim: true,
      default: "M-2026",
    },
  },
  {
    timestamps: true,
  }
);

mentorEvaluationSchema.index({ studentName: 1, createdAt: -1 });
mentorEvaluationSchema.index({ score: -1 });

export default mongoose.model("MentorEvaluation", mentorEvaluationSchema);
