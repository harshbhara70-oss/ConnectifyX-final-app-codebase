import express from "express";
import studentAuthMiddleware from "../middleware/studentAuthMiddleware.js";
import {
  getStudentProfile,
  loginStudent,
  logoutStudent,
  registerStudent,
} from "../controllers/studentController.js";

const router = express.Router();

router.post("/register", registerStudent);
router.post("/login", loginStudent);
router.post("/logout", studentAuthMiddleware, logoutStudent);
router.get("/me", studentAuthMiddleware, getStudentProfile);

export default router;
