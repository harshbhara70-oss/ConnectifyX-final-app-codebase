import mongoose from "mongoose";

const companySchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },
    industry: {
      type: String,
      trim: true,
    },
    website: {
      type: String,
      trim: true,
    },
    location: {
      type: String,
      trim: true,
    },
    email: {
      type: String,
      unique: true,
      lowercase: true,
      trim: true,
    },
    phone: {
      type: String,
      match: [/^[0-9]{10}$/, "Invalid phone number"],
    },
    recruiters: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Recruiter",
      },
    ],
  },
  {
    timestamps: true,
  }
);

export default mongoose.model("Company", companySchema);