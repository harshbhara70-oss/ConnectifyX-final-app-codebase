import express from "express";
import {
    registerAdmin,
    loginAdmin,
    getAdminProfile,
    getDashboardAnalytics,
    getAllStudents,
    getStudentById,
    updateStudent,
    deleteStudent,
    createCollege,
    getAllColleges,
    getCollegeById,
    updateCollege,
    deleteCollege,
    createRecruiter,
    getAllRecruiters,
    getRecruiterById,
    updateRecruiter,
    deleteRecruiter,
    createProject,
    getAllProjects,
    getProjectById,
    updateProject,
    approveProject,
    rejectProject,
    deleteProject

} from "../controllers/adminController.js";

import adminAuth from "../middleware/adminAuth.js";

const router = express.Router();

router.post("/register", registerAdmin);

// Public Route
router.post("/login", loginAdmin);

// Protected Route
router.get("/profile", adminAuth, getAdminProfile);

router.get("/dashboard", adminAuth, getDashboardAnalytics);

router.post("/colleges", adminAuth, createCollege);

router.get("/students", adminAuth, getAllStudents);
router.get("/students/:id", adminAuth, getStudentById);
router.put("/students/:id", adminAuth, updateStudent);
router.delete("/students/:id", adminAuth, deleteStudent);
router.get("/colleges", adminAuth, getAllColleges);
router.get("/colleges/:id", adminAuth, getCollegeById);
router.put("/colleges/:id", adminAuth, updateCollege);
router.delete("/colleges/:id", adminAuth, deleteCollege);
router.post("/recruiters", adminAuth, createRecruiter);
router.get("/recruiters", adminAuth, getAllRecruiters);
router.get("/recruiters/:id", adminAuth, getRecruiterById);
router.put("/recruiters/:id", adminAuth, updateRecruiter);
router.delete("/recruiters/:id", adminAuth, deleteRecruiter);


// Project Management APIs
router.post("/projects", adminAuth, createProject);
router.get("/projects", adminAuth, getAllProjects);
router.get("/projects/:id", adminAuth, getProjectById);
router.put("/projects/:id", adminAuth, updateProject);
router.put("/projects/:id/approve", adminAuth, approveProject);
router.put("/projects/:id/reject", adminAuth, rejectProject);
router.delete("/projects/:id", adminAuth, deleteProject);

export default router;