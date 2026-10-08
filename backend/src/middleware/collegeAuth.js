import jwt from "jsonwebtoken";
import College from "../models/college.js";
import { errorResponse } from "../utils/apiResponse.js";

const collegeAuth = async (req, res, next) => {
    console.log(req.headers);
  console.log(req.headers.authorization);
  try {
    let token;

    // Check Authorization Header
    if (
      req.headers.authorization &&
      req.headers.authorization.startsWith("Bearer")
    ) {
      token = req.headers.authorization.split(" ")[1];
    }

    // No Token
    if (!token) {
      return errorResponse(res, "Access denied. No token provided.", 401);
    }

    // Verify JWT
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Find College
    const college = await College.findById(decoded.id).select("-password");

    if (!college) {
      return errorResponse(res, "College not found.", 404);
    }

    // Store logged-in college
    req.college = college;

    next();
  } catch (error) {
    return errorResponse(res, "Invalid or expired token.", 401);
  }
};

export default collegeAuth;