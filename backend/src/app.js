import express from "express";
import cors from "cors";
import errorHandler from "./middleware/errorHandler.js";
import notFound from "./middleware/notFoundMiddleware.js";
import adminRoutes from "./routes/adminRoutes.js";
import collegeRoutes from "./routes/collegeRoutes.js";
import studentRoutes from "./routes/studentRoutes.js";
import studentAuthRoutes from "./routes/studentAuthRoutes.js";
import aiRoutes from "./routes/aiRoutes.js";
import mentorRoutes from "./routes/mentorRoutes.js";
import recruiterRoutes from "./routes/recruiterRoutes.js";

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get("/", (req, res) => {
  res.json({
    success: true,
    message: "Campus2Corporate Backend API is running successfully",
  });
});

// Admin Routes
app.use("/api/admin", adminRoutes);
app.use("/api/v1/admin", adminRoutes);

// College Routes
app.use("/api/college", collegeRoutes);

// Student & Auth Routes
app.use("/api/auth", studentAuthRoutes);
app.use("/api/student", studentRoutes);
app.use("/api/students", studentRoutes);

// AI Services Routes
app.use("/api/ai", aiRoutes);

// Mentor Module Routes – Employability Matrix + Dashboard + Sessions + Feedback (real-time MongoDB, isMock=false)
app.use("/api/mentor", mentorRoutes);

// Recruiter Module Routes – Dashboard + Jobs + Pipeline (real-time MongoDB Atlas, isMock=false)
app.use("/api/recruiter", recruiterRoutes);

// 404 Handler
app.use(notFound);

// Global Error Handler
app.use(errorHandler);

export default app;