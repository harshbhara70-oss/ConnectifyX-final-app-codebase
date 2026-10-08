import mongoose from "mongoose";

const mentorActivitySchema = new mongoose.Schema(
  {
    text: {
      type: String,
      required: true,
      trim: true,
    },
    time: {
      type: String,
      trim: true,
      default: "Just now",
    },
    done: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

mentorActivitySchema.index({ createdAt: -1 });

export default mongoose.model("MentorActivity", mentorActivitySchema);
