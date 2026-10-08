import express from "express";
import {
  registerCollege,
  loginCollege,
  getCollegeProfile,
  getCollegeDashboard,
  createStudent,
  getAllStudents,
  getStudentById,
  updateStudent,
  deleteStudent,
   createApplication,
  getAllApplications,
  getApplicationById,
  updateApplication,
  deleteApplication,
   createProject,
  getAllProjects,
  getProjectById,
  updateProject,
  deleteProject,
   getEligibleStudents
} from "../controllers/collegeController.js";

import collegeAuth from "../middleware/collegeAuth.js";

const router = express.Router();

// Public Routes
router.post("/register", registerCollege);
router.post("/login", loginCollege);

// Protected Routes
router.get("/profile", collegeAuth, getCollegeProfile);
router.get("/dashboard", collegeAuth, getCollegeDashboard);

// Student Management
router.post("/students", collegeAuth, createStudent);
router.get("/students", collegeAuth, getAllStudents);
router.get("/students/eligible", collegeAuth, getEligibleStudents);
router.get("/students/:id", collegeAuth, getStudentById);
router.put("/students/:id", collegeAuth, updateStudent);
router.delete("/students/:id", collegeAuth, deleteStudent);

// Application Management
router.post("/applications", collegeAuth, createApplication);
router.get("/applications", collegeAuth, getAllApplications);
router.get("/applications/:id", collegeAuth, getApplicationById);
router.put("/applications/:id", collegeAuth, updateApplication);
router.delete("/applications/:id", collegeAuth, deleteApplication);

// Project Management
router.post("/projects", collegeAuth, createProject);
router.get("/projects", collegeAuth, getAllProjects);
router.get("/projects/:id", collegeAuth, getProjectById);
router.put("/projects/:id", collegeAuth, updateProject);
router.delete("/projects/:id", collegeAuth, deleteProject);

export default router;