import College from "../models/college.js";
import Student from "../models/student.js";
import Project from "../models/project.js";
import Application from "../models/application.js";

import generateToken from "../utils/generateToken.js";
import { successResponse, errorResponse } from "../utils/apiResponse.js";

// ================= Register College =================

export const registerCollege = async (req, res) => {
  try {
    const {
      name,
      email,
      phone,
      password,
      address,
      website,
      university,
    } = req.body;

    if (
      !name ||
      !email ||
      !phone ||
      !password ||
      !address ||
      !website ||
      !university
    ) {
      return errorResponse(res, "All fields are required", 400);
    }

    const existingCollege = await College.findOne({ email });

    if (existingCollege) {
      return errorResponse(res, "College already exists", 400);
    }

    const college = await College.create({
      name,
      email,
      phone,
      password,
      address,
      website,
      university,
    });

    return successResponse(
      res,
      "College registered successfully",
      {
        id: college._id,
        name: college.name,
        email: college.email,
      },
      201
    );
  } catch (error) {
     console.error(error);  
    return errorResponse(res, error.message, 500);
  }
};

// ================= Login College =================

export const loginCollege = async (req, res) => {
  try {
    const { email, password } = req.body;
    

    if (!email || !password) {
      return errorResponse(res, "Email and Password are required", 400);
    }

    const college = await College.findOne({ email });

    if (!college) {
      return errorResponse(res, "Invalid email or password", 401);
    }

    const isMatch = await college.comparePassword(password);

    if (!isMatch) {
      return errorResponse(res, "Invalid email or password", 401);
    }

    const token = generateToken(college._id);

    return successResponse(
      res,
      "Login successful",
      {
        token,
        college: {
          id: college._id,
          name: college.name,
          email: college.email,
        },
      },
      200
    );
  } catch (error) {
    return errorResponse(res, error.message, 500);
  }
};

// ================= Get Profile =================

export const getCollegeProfile = async (req, res) => {
  try {
    return successResponse(
      res,
      "College profile fetched successfully",
      req.college,
      200
    );
  } catch (error) {
    return errorResponse(res, error.message, 500);
  }
};

// ================= Dashboard =================

export const getCollegeDashboard = async (req, res) => {
  try {
    const totalStudents = await Student.countDocuments({
      college: req.college._id,
    });

    const activeStudents = await Student.countDocuments({
      college: req.college._id,
      status: "Active",
    });

    const totalProjects = await Project.countDocuments();

    const totalApplications = await Application.countDocuments();

    return successResponse(
      res,
      "Dashboard fetched successfully",
      {
        totalStudents,
        activeStudents,
        totalProjects,
        totalApplications,
      },
      200
    );
  } catch (error) {
    return errorResponse(res, error.message, 500);
  }
};

// ================= Create Student =================
export const createStudent = async (req, res) => {
  try {
    const student = await Student.create({
      ...req.body,
      college: req.college._id, // Logged-in college
    });

    return successResponse(
      res,
      "Student created successfully",
      student,
      201
    );
  } catch (error) {
    return errorResponse(res, error.message, 500);
  }
};

// ================= Get All Students =================
export const getAllStudents = async (req, res) => {
  try {
    const students = await Student.find({
      college: req.college._id,
    });

    return successResponse(
      res,
      "Students fetched successfully",
      students,
      200
    );
  } catch (error) {
    return errorResponse(res, error.message, 500);
  }
};

// ================= Get Student By ID =================
export const getStudentById = async (req, res) => {
  try {
    const student = await Student.findOne({
      _id: req.params.id,
      college: req.college._id,
    });

    if (!student) {
      return errorResponse(res, "Student not found", 404);
    }

    return successResponse(
      res,
      "Student fetched successfully",
      student,
      200
    );
  } catch (error) {
    return errorResponse(res, error.message, 500);
  }
};

// ================= Update Student =================
export const updateStudent = async (req, res) => {
  try {
    const student = await Student.findOneAndUpdate(
      {
        _id: req.params.id,
        college: req.college._id,
      },
      req.body,
      {
        new: true,
        runValidators: true,
      }
    );

    if (!student) {
      return errorResponse(res, "Student not found", 404);
    }

    return successResponse(
      res,
      "Student updated successfully",
      student,
      200
    );
  } catch (error) {
    return errorResponse(res, error.message, 500);
  }
};

// ================= Delete Student =================
export const deleteStudent = async (req, res) => {
  try {
    const student = await Student.findOneAndDelete({
      _id: req.params.id,
      college: req.college._id,
    });

    if (!student) {
      return errorResponse(res, "Student not found", 404);
    }

    return successResponse(
      res,
      "Student deleted successfully",
      null,
      200
    );
  } catch (error) {
    return errorResponse(res, error.message, 500);
  }
};

// ====================== APPLICATION MANAGEMENT ======================

// Create Application
export const createApplication = async (req, res) => {
  try {
    const application = await Application.create(req.body);

    return successResponse(
      res,
      "Application created successfully",
      application,
      201
    );
  } catch (error) {
    return errorResponse(res, error.message, 500);
  }
};

// Get All Applications
export const getAllApplications = async (req, res) => {
  try {
    const applications = await Application.find()
      .populate({
        path: "student",
        match: { college: req.college._id },
      })
      .populate("project");

    const filteredApplications = applications.filter(
      (app) => app.student !== null
    );

    return successResponse(
      res,
      "Applications fetched successfully",
      filteredApplications,
      200
    );
  } catch (error) {
    return errorResponse(res, error.message, 500);
  }
};

// Get Application By ID
export const getApplicationById = async (req, res) => {
  try {
    const application = await Application.findById(req.params.id)
      .populate({
        path: "student",
        match: { college: req.college._id },
      })
      .populate("project");

    if (!application || !application.student) {
      return errorResponse(res, "Application not found", 404);
    }

    return successResponse(
      res,
      "Application fetched successfully",
      application,
      200
    );
  } catch (error) {
    return errorResponse(res, error.message, 500);
  }
};

// Update Application
export const updateApplication = async (req, res) => {
  try {
    const application = await Application.findByIdAndUpdate(
      req.params.id,
      req.body,
      {
        new: true,
        runValidators: true,
      }
    );

    if (!application) {
      return errorResponse(res, "Application not found", 404);
    }

    return successResponse(
      res,
      "Application updated successfully",
      application,
      200
    );
  } catch (error) {
    return errorResponse(res, error.message, 500);
  }
};

// Delete Application
export const deleteApplication = async (req, res) => {
  try {
    const application = await Application.findByIdAndDelete(req.params.id);

    if (!application) {
      return errorResponse(res, "Application not found", 404);
    }

    return successResponse(
      res,
      "Application deleted successfully",
      null,
      200
    );
  } catch (error) {
    return errorResponse(res, error.message, 500);
  }
};  

// ====================== PROJECT MANAGEMENT ======================

// Create Project
export const createProject = async (req, res) => {
  try {
    const project = await Project.create(req.body);

    return successResponse(
      res,
      "Project created successfully",
      project,
      201
    );
  } catch (error) {
    return errorResponse(res, error.message, 500);
  }
};

// Get All Projects
export const getAllProjects = async (req, res) => {
  try {
    const projects = await Project.find()
      .populate("company")
      .populate("recruiter");

    return successResponse(
      res,
      "Projects fetched successfully",
      projects,
      200
    );
  } catch (error) {
    return errorResponse(res, error.message, 500);
  }
};

// Get Project By ID
export const getProjectById = async (req, res) => {
  try {
    const project = await Project.findById(req.params.id)
      .populate("company")
      .populate("recruiter");

    if (!project) {
      return errorResponse(res, "Project not found", 404);
    }

    return successResponse(
      res,
      "Project fetched successfully",
      project,
      200
    );
  } catch (error) {
    return errorResponse(res, error.message, 500);
  }
};

// Update Project
export const updateProject = async (req, res) => {
  try {
    const project = await Project.findByIdAndUpdate(
      req.params.id,
      req.body,
      {
        new: true,
        runValidators: true,
      }
    );

    if (!project) {
      return errorResponse(res, "Project not found", 404);
    }

    return successResponse(
      res,
      "Project updated successfully",
      project,
      200
    );
  } catch (error) {
    return errorResponse(res, error.message, 500);
  }
};

// Delete Project
export const deleteProject = async (req, res) => {
  try {
    const project = await Project.findByIdAndDelete(req.params.id);

    if (!project) {
      return errorResponse(res, "Project not found", 404);
    }

    return successResponse(
      res,
      "Project deleted successfully",
      null,
      200
    );
  } catch (error) {
    return errorResponse(res, error.message, 500);
  }
};

// Get Eligible Students (70% and above)
export const getEligibleStudents = async (req, res) => {
  try {
    const students = await Student.find({
      percentage:  80 ,
      status: "Active",
    }).select("-password");

    return successResponse(
      res,
      "Eligible students fetched successfully",
      students,
      200
    );
  } catch (error) {
    return errorResponse(res, error.message, 500);
  }
};