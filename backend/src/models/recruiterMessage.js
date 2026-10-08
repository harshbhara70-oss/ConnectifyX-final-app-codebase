import mongoose from "mongoose";

const chatMessageSchema = new mongoose.Schema({
  sender: {
    type: String,
    enum: ["recruiter", "candidate"],
    default: "recruiter",
  },
  text: {
    type: String,
    required: true,
  },
  timestamp: {
    type: Date,
    default: Date.now,
  },
});

const recruiterMessageSchema = new mongoose.Schema(
  {
    recruiter: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Recruiter",
    },
    candidateName: {
      type: String,
      required: true,
      trim: true,
    },
    role: {
      type: String,
      required: true,
      trim: true,
    },
    lastMessage: {
      type: String,
      required: true,
    },
    messages: [chatMessageSchema],
  },
  { timestamps: true }
);

const RecruiterMessage = mongoose.model("RecruiterMessage", recruiterMessageSchema);
export default RecruiterMessage;
