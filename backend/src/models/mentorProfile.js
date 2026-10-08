import mongoose from "mongoose";

const mentorProfileSchema = new mongoose.Schema(
  {
    fullName: {
      type: String,
      required: true,
      trim: true,
      default: "Dr. Sarah Jenkins",
    },
    avatar: {
      type: String,
      trim: true,
      default: "SJ",
    },
    avatarBg: {
      type: String,
      trim: true,
      default: "#6366F1",
    },
    roleTitle: {
      type: String,
      trim: true,
      default: "Principal Software Engineer",
    },
    company: {
      type: String,
      trim: true,
      default: "Stripe Sourcing Pipelines",
    },
    department: {
      type: String,
      trim: true,
      default: "Engineering Sourcing",
    },
    email: {
      type: String,
      trim: true,
      default: "sarah.jenkins@stripe.com",
    },
    officeHours: {
      type: String,
      trim: true,
      default: "Mon, Wed, Fri (4:00 - 6:00 PM)",
    },
    phone: {
      type: String,
      trim: true,
      default: "+1 (555) 019-2834",
    },
    expertiseTags: {
      type: [String],
      default: [
        "React",
        "Cosine Vector Embeddings",
        "System Design",
        "PostgreSQL",
        "Cloud Architecture",
      ],
    },
    bio: {
      type: String,
      trim: true,
      default:
        "Lead Architect specializing in high-throughput distributed systems, ML pipelines, and technical mentorship.",
    },
    availabilitySwitch: {
      type: Boolean,
      default: true,
    },
    location: {
      type: String,
      trim: true,
      default: "San Francisco, CA / Hybrid",
    },
    linkedInUrl: {
      type: String,
      trim: true,
      default: "https://linkedin.com/in/sarah-jenkins-lead",
    },
    githubUrl: {
      type: String,
      trim: true,
      default: "https://github.com/sarah-jenkins-c2c",
    },
  },
  {
    timestamps: true,
  }
);

const MentorProfile =
  mongoose.models.MentorProfile ||
  mongoose.model("MentorProfile", mentorProfileSchema);

export default MentorProfile;
