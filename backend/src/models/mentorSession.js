import mongoose from "mongoose";

const mentorSessionSchema = new mongoose.Schema(
  {
    studentName: {
      type: String,
      required: true,
      trim: true,
    },
    type: {
      type: String,
      required: true,
      trim: true,
      default: "Resume Review",
    },
    time: {
      type: String,
      trim: true,
      default: "10:00 AM - 11:00 AM",
    },
    date: {
      type: String,
      trim: true,
      default: "Today",
    },
    day: {
      type: String,
      enum: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
      default: "Mon",
    },
    meetingLink: {
      type: String,
      trim: true,
      default: "https://teams.microsoft.com/mock-link",
    },
  },
  {
    timestamps: true,
  }
);

export default mongoose.model("MentorSession", mentorSessionSchema);
