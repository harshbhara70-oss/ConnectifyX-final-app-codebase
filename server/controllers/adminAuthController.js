import jwt from 'jsonwebtoken';
import Admin from '../models/Admin.js';

/**
 * @desc    Admin Login Endpoint
 * @route   POST /api/v1/admin/login
 * @access  Public
 */
export const adminLogin = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        error: 'Please provide both administrative email and password.',
        message: 'Please provide both administrative email and password.',
      });
    }

    const inputEmail = email.toLowerCase().trim();
    const envAdminEmail = (process.env.ADMIN_EMAIL || '').toLowerCase().trim();
    const envAdminPassword = process.env.ADMIN_PASSWORD;

    let isValid = false;
    let adminRecord = null;

    // Check directly against process.env first if configured
    if (envAdminEmail && envAdminPassword && inputEmail === envAdminEmail && password === envAdminPassword) {
      isValid = true;
    }

    // Secondary validation against MongoDB Admin model if env match didn't run or DB is active
    if (!isValid) {
      try {
        adminRecord = await Admin.findOne({ email: inputEmail });
        if (adminRecord) {
          const isMatch = await adminRecord.comparePassword(password);
          if (isMatch) {
            isValid = true;
          }
        }
      } catch (dbErr) {
        console.warn('MongoDB Admin lookup fallback failed:', dbErr.message);
      }
    }

    if (!isValid) {
      return res.status(401).json({
        success: false,
        error: 'Invalid administrative credentials.',
        message: 'Invalid administrative credentials.',
      });
    }

    // Record last login if DB record exists
    if (adminRecord) {
      try {
        adminRecord.lastLogin = new Date();
        await adminRecord.save();
      } catch (saveErr) {
        console.warn('Failed to update admin lastLogin:', saveErr.message);
      }
    }

    const jwtSecret = process.env.JWT_ADMIN_SECRET || process.env.JWT_SECRET || 'connectifyx_jwt_secret_key';

    const token = jwt.sign(
      {
        email: envAdminEmail,
        role: 'ADMIN',
      },
      jwtSecret,
      { expiresIn: '24h' }
    );

    return res.status(200).json({
      success: true,
      message: 'Admin authentication successful.',
      token,
      user: {
        email: envAdminEmail,
        role: 'ADMIN',
      },
      admin: {
        email: envAdminEmail,
        role: 'ADMIN',
      },
    });
  } catch (error) {
    console.error('Admin Login Error:', error.message);
    return res.status(500).json({
      success: false,
      error: 'Internal server error during admin authentication.',
      message: 'Internal server error during admin authentication.',
    });
  }
};

/**
 * @desc    Get Active Admin Profile
 * @route   GET /api/v1/admin/me
 * @access  Private (Admin)
 */
export const getAdminProfile = async (req, res) => {
  try {
    return res.status(200).json({
      success: true,
      admin: req.admin || { role: 'ADMIN', email: process.env.ADMIN_EMAIL || 'admin@campus.com' },
    });
  } catch (error) {
    console.error('Get Admin Profile Error:', error.message);
    return res.status(500).json({
      success: false,
      error: 'Internal server error fetching admin profile.',
      message: 'Internal server error fetching admin profile.',
    });
  }
};

export default { adminLogin, getAdminProfile };
