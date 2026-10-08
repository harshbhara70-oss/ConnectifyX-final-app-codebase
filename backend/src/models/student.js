import mongoose from "mongoose";
import bcrypt from "bcryptjs";

const educationSchema = new mongoose.Schema(
  {
    degree: { type: String, trim: true },
    institution: { type: String, trim: true },
    fieldOfStudy: { type: String, trim: true },
    startYear: { type: Number },
    endYear: { type: Number },
    grade: { type: String, trim: true },
  },
  { _id: true }
);

const skillDetailSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    proficiency: {
      type: Number,
      min: 0,
      max: 100,
      default: 0,
    },
    category: { type: String, trim: true },
    yearsOfExperience: { type: Number, min: 0, default: 0 },
  },
  { timestamps: true }
);

const progressHistorySchema = new mongoose.Schema(
  {
    progressPercentage: { type: Number, min: 0, max: 100, required: true },
    status: {
      type: String,
      enum: ["enrolled", "in-progress", "completed"],
      required: true,
    },
    note: { type: String, trim: true },
    updatedAt: { type: Date, default: Date.now },
  },
  { _id: false }
);

const learningProgressSchema = new mongoose.Schema(
  {
    moduleId: { type: String, required: true, trim: true },
    title: { type: String, required: true, trim: true },
    description: { type: String, trim: true },
    progressPercentage: { type: Number, min: 0, max: 100, default: 0 },
    status: {
      type: String,
      enum: ["enrolled", "in-progress", "completed"],
      default: "enrolled",
    },
    enrolledAt: { type: Date, default: Date.now },
    completedAt: { type: Date },
    history: [progressHistorySchema],
  },
  { timestamps: true }
);

const assignmentSubmissionSchema = new mongoose.Schema(
  {
    assignmentId: { type: String, required: true, trim: true },
    title: { type: String, trim: true },
    content: { type: String, trim: true },
    submissionUrl: { type: String, trim: true },
    answers: { type: mongoose.Schema.Types.Mixed },
    score: { type: Number, min: 0, max: 100 },
    status: {
      type: String,
      enum: ["submitted", "graded"],
      default: "submitted",
    },
    feedback: { type: String, trim: true },
    submittedAt: { type: Date, default: Date.now },
  },
  { timestamps: true }
);

const quizSubmissionSchema = new mongoose.Schema(
  {
    quizId: { type: String, required: true, trim: true },
    title: { type: String, trim: true },
    answers: { type: mongoose.Schema.Types.Mixed, required: true },
    score: { type: Number, min: 0, max: 100 },
    totalQuestions: { type: Number, min: 0 },
    correctAnswers: { type: Number, min: 0 },
    submittedAt: { type: Date, default: Date.now },
  },
  { timestamps: true }
);

const scoreHistorySchema = new mongoose.Schema(
  {
    score: { type: Number, min: 0, max: 100, required: true },
    eligibilityStatus: {
      type: String,
      enum: ["Eligible", "Not Eligible"],
      required: true,
    },
    breakdown: { type: mongoose.Schema.Types.Mixed },
    calculatedAt: { type: Date, default: Date.now },
  },
  { _id: false }
);

const studentSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    password: {
      type: String,
      select: false,
      minlength: 8,
    },
    phone: {
      type: String,
      trim: true,
    },
    college: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "College",
    },
    branch: {
      type: String,
      trim: true,
    },
    semester: {
      type: Number,
      min: 1,
      max: 12,
    },
    percentage: {
      type: Number,
      default: 0,
      min: 0,
      max: 100,
    },
    role: {
      type: String,
      default: "student",
    },
    skills: [
      {
        type: String,
        trim: true,
      },
    ],
    skillDetails: [skillDetailSchema],
    interests: [{ type: String, trim: true }],
    education: [educationSchema],
    resume: {
      type: String,
      trim: true,
    },
    resumeUrl: {
      type: String,
      trim: true,
    },
    bio: {
      type: String,
      trim: true,
    },
    location: {
      type: String,
      trim: true,
    },
    linkedIn: {
      type: String,
      trim: true,
    },
    github: {
      type: String,
      trim: true,
    },
    portfolio: {
      type: String,
      trim: true,
    },
    status: {
      type: String,
      enum: ["Active", "Inactive"],
      default: "Active",
    },
    learningProgress: [learningProgressSchema],
    assignmentSubmissions: [assignmentSubmissionSchema],
    quizSubmissions: [quizSubmissionSchema],
    scoreHistory: [scoreHistorySchema],
  },
  {
    timestamps: true,
  }
);

studentSchema.pre("save", async function () {
  if (!this.isModified("password") || !this.password) {
    return;
  }

  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
});

studentSchema.methods.comparePassword = async function (enteredPassword) {
  if (!this.password) {
    return false;
  }

  return bcrypt.compare(enteredPassword, this.password);
};

export default mongoose.model("Student", studentSchema);
