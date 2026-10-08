import mongoose from "mongoose";

const mentorSettingsSchema = new mongoose.Schema(
  {
    darkMode: {
      type: Boolean,
      default: false,
    },
    pushAlerts: {
      type: Boolean,
      default: true,
    },
    privacyMode: {
      type: Boolean,
      default: false,
    },
    alertsLimit: {
      type: String,
      default: "10",
    },
    systemLanguage: {
      type: String,
      default: "English",
    },
    emailDigest: {
      type: String,
      default: "Daily Digest",
    },
    soundEffects: {
      type: Boolean,
      default: true,
    },
    defaultSessionDuration: {
      type: String,
      default: "45 min",
    },
    twoFactorAuth: {
      type: Boolean,
      default: true,
    },
    autoLockTimeout: {
      type: String,
      default: "30 min",
    },
  },
  {
    timestamps: true,
  }
);

const MentorSettings =
  mongoose.models.MentorSettings ||
  mongoose.model("MentorSettings", mentorSettingsSchema);

export default MentorSettings;
