import mongoose from "mongoose";

const recruiterSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, "Recruiter name is required"],
      trim: true,
      minlength: [3, "Name must be at least 3 characters"],
      maxlength: [50, "Name cannot exceed 50 characters"],
    },

    email: {
      type: String,
      required: [true, "Email is required"],
      unique: true,
      lowercase: true,
      trim: true,
      match: [
        /^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,})+$/,
        "Please enter a valid email address",
      ],
    },

    phone: {
      type: String,
      required: [true, "Phone number is required"],
      match: [/^[6-9]\d{9}$/, "Please enter a valid 10-digit phone number"],
    },

    designation: {
      type: String,
      required: [true, "Designation is required"],
      trim: true,
    },

    company: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Company",
      required: [true, "Company is required"],
    },

    linkedin: {
      type: String,
      trim: true,
      default: "",
    },

    status: {
      type: String,
      enum: {
        values: ["Active", "Inactive"],
        message: "Status must be Active or Inactive",
      },
      default: "Active",
    },
  },
  {
    timestamps: true,
  }
);

export default mongoose.model("Recruiter", recruiterSchema);