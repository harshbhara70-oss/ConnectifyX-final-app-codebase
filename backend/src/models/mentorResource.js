import mongoose from "mongoose";

const mentorResourceSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: true,
      trim: true,
    },
    category: {
      type: String,
      required: true,
      enum: [
        "Interview Questions",
        "Coding Sheets",
        "PDFs",
        "Resume Templates",
        "Company Experiences",
        "Videos",
      ],
      default: "PDFs",
    },
    uploadedAt: {
      type: String,
      trim: true,
      default: () => new Date().toISOString().split("T")[0],
    },
    size: {
      type: String,
      trim: true,
      default: "1.5 MB",
    },
    fileUrl: {
      type: String,
      trim: true,
      default: "",
    },
    description: {
      type: String,
      trim: true,
      default: "",
    },
    downloadCount: {
      type: Number,
      default: 0,
    },
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

mentorResourceSchema.index({ category: 1, createdAt: -1 });
mentorResourceSchema.index({ createdAt: -1 });

export default mongoose.model("MentorResource", mentorResourceSchema);
