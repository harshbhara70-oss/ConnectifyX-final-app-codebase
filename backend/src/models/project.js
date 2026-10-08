import mongoose from "mongoose";

const projectSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, "Project title is required"],
      trim: true,
      minlength: [3, "Title must be at least 3 characters"],
      maxlength: [100, "Title cannot exceed 100 characters"],
    },

    description: {
      type: String,
      required: [true, "Project description is required"],
      trim: true,
      minlength: [20, "Description must be at least 20 characters"],
      maxlength: [2000, "Description cannot exceed 2000 characters"],
    },

    recruiter: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Recruiter",
      required: [true, "Recruiter is required"],
    },

    company: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Company",
      required: [true, "Company is required"],
    },

    requiredSkills: {
      type: [String],
      required: [true, "At least one skill is required"],
      validate: {
        validator: (skills) => skills.length > 0,
        message: "Please provide at least one required skill",
      },
    },

    duration: {
      type: String,
      required: [true, "Project duration is required"],
      trim: true,
    },

    stipend: {
      type: Number,
      required: [true, "Stipend is required"],
      min: [0, "Stipend cannot be negative"],
    },

    location: {
      type: String,
      required: [true, "Location is required"],
      trim: true,
    },

    mode: {
      type: String,
      enum: {
        values: ["Remote", "Hybrid", "On-site"],
        message: "Mode must be Remote, Hybrid or On-site",
      },
      default: "On-site",
    },

    openings: {
      type: Number,
      required: [true, "Number of openings is required"],
      min: [1, "There must be at least one opening"],
    },

    applicationDeadline: {
      type: Date,
      required: [true, "Application deadline is required"],
    },

    status: {
      type: String,
      enum: {
        values: ["Open", "Closed"],
        message: "Status must be Open or Closed",
      },
      default: "Open",
    },
  },
  {
    timestamps: true,
  }
);

export default mongoose.model("Project", projectSchema);