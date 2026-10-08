import User from '../models/User.js';
import generateToken from '../utils/generateToken.js';
import mongoose from 'mongoose';

// Check if database is connected
const isDbConnected = () => mongoose.connection.readyState === 1;

// @desc    Register a new user
// @route   POST /api/auth/register
// @access  Public
export const registerUser = async (req, res) => {
  try {
    const { fullName, email, phone, password, role } = req.body;

    // 1. Validate required fields
    if (!fullName || !email || !phone || !password || !role) {
      return res.status(400).json({
        success: false,
        message: 'Please provide all required fields: fullName, email, phone, password, role',
      });
    }

    // 2. Validate email format
    const emailRegex = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({
        success: false,
        message: 'Please enter a valid email address',
      });
    }

    // 3. Validate phone number
    if (phone.length < 10) {
      return res.status(400).json({
        success: false,
        message: 'Please enter a valid phone number (minimum 10 digits)',
      });
    }

    // 4. Validate password length
    if (password.length < 8) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 8 characters long',
      });
    }

    // 5. Validate role enum
    const validRoles = ['student', 'mentor', 'college', 'recruiter'];
    if (!validRoles.includes(role.toLowerCase())) {
      return res.status(400).json({
        success: false,
        message: `Invalid role. Allowed roles are: ${validRoles.join(', ')}`,
      });
    }

    // 6. DB Connection Check & Fallback
    if (!isDbConnected()) {
      console.warn('MongoDB is disconnected. Falling back to local Mock Auth Session.');
      const mockId = new mongoose.Types.ObjectId().toString();
      const token = generateToken(mockId);
      return res.status(201).json({
        success: true,
        message: 'Account created successfully (Mock Mode - Database Unreachable)',
        token,
        user: {
          id: mockId,
          fullName,
          email: email.toLowerCase(),
          phone,
          role: role.toLowerCase(),
          isVerified: false,
        },
      });
    }

    // 7. Check duplicate email or phone (regardless of role)
    const emailExists = await User.findOne({ email });
    if (emailExists) {
      return res.status(400).json({
        success: false,
        message: 'An account with this email address already exists',
      });
    }

    const phoneExists = await User.findOne({ phone });
    if (phoneExists) {
      return res.status(400).json({
        success: false,
        message: 'An account with this phone number already exists',
      });
    }

    // 8. Create user (password will be hashed in pre-save hook)
    const user = await User.create({
      fullName,
      email,
      phone,
      password,
      role: role.toLowerCase(),
    });

    // 9. Generate JWT
    const token = generateToken(user._id);

    return res.status(201).json({
      success: true,
      message: 'Account created successfully',
      token,
      user: {
        id: user._id,
        fullName: user.fullName,
        email: user.email,
        phone: user.phone,
        role: user.role,
        isVerified: user.isVerified,
      },
    });
  } catch (error) {
    console.error('Registration error:', error);
    return res.status(500).json({
      success: false,
      message: 'Registration failed due to a server error',
      error: error.message,
    });
  }
};

// @desc    Authenticate user & get token
// @route   POST /api/auth/login
// @access  Public
export const loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;

    // 1. Validate inputs
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide both email and password',
      });
    }

    // 2. DB Connection Check & Fallback
    if (!isDbConnected()) {
      console.warn('MongoDB is disconnected. Falling back to local Mock Auth Session.');
      const mockId = new mongoose.Types.ObjectId().toString();
      const token = generateToken(mockId);
      
      // Guess role from email prefix, default to student
      let role = 'student';
      if (email.toLowerCase().includes('mentor')) role = 'mentor';
      else if (email.toLowerCase().includes('college')) role = 'college';
      else if (email.toLowerCase().includes('recruiter')) role = 'recruiter';

      return res.status(200).json({
        success: true,
        message: 'Logged in successfully (Mock Mode - Database Unreachable)',
        token,
        user: {
          id: mockId,
          fullName: 'Demo User',
          email: email.toLowerCase(),
          phone: '+91 98765 43210',
          role,
          isVerified: true,
        },
      });
    }

    // 3. Check if user exists
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
    }

    // 4. Compare passwords
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
    }

    // 5. Generate JWT
    const token = generateToken(user._id);

    return res.status(200).json({
      success: true,
      message: 'Logged in successfully',
      token,
      user: {
        id: user._id,
        fullName: user.fullName,
        email: user.email,
        phone: user.phone,
        role: user.role,
        isVerified: user.isVerified,
      },
    });
  } catch (error) {
    console.error('Login error:', error);
    return res.status(500).json({
      success: false,
      message: 'Login failed due to a server error',
      error: error.message,
    });
  }
};

// @desc    Get user profile
// @route   GET /api/auth/me
// @access  Private
export const getMe = async (req, res) => {
  try {
    // If db is not connected but we have a valid mock token, return mock profile data
    if (!isDbConnected() && req.user === undefined) {
      return res.status(200).json({
        success: true,
        user: {
          id: 'mock_id',
          fullName: 'Demo User',
          email: 'demo@c2c.com',
          phone: '+91 98765 43210',
          role: 'student',
          isVerified: true,
        },
      });
    }

    // req.user was set by authMiddleware
    return res.status(200).json({
      success: true,
      user: req.user,
    });
  } catch (error) {
    console.error('Get profile error:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve profile data',
      error: error.message,
    });
  }
};
