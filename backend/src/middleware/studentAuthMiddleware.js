import authMiddleware from "./authMiddleware.js";
import Student from "../models/student.js";

const studentAuthMiddleware = [
  authMiddleware,
  async (req, res, next) => {
    try {
      if (req.user?.role && req.user.role !== "student") {
        return res.status(403).json({
          success: false,
          message: "Access denied",
        });
      }

      const student = await Student.findById(req.user.id).select("-password");

      if (!student) {
        return res.status(401).json({
          success: false,
          message: "Student account not found",
        });
      }

      req.user = {
        id: student._id.toString(),
        role: "student",
      };
      req.student = student;

      return next();
    } catch (error) {
      return res.status(401).json({
        success: false,
        message: "Invalid student session",
      });
    }
  },
];

export default studentAuthMiddleware;
