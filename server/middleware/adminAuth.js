import jwt from 'jsonwebtoken';
import Admin from '../models/Admin.js';

export const adminAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        error: 'Access Denied: Missing or malformed authentication token.',
        message: 'Access Denied: Missing or malformed authentication token.',
      });
    }

    const token = authHeader.split(' ')[1];
    const jwtSecret = process.env.JWT_ADMIN_SECRET || 'your_super_secret_admin_jwt_key_2026';

    const decoded = jwt.verify(token, jwtSecret);

    if (!decoded || (decoded.role !== 'ADMIN' && decoded.role !== 'SUPER_ADMIN')) {
      return res.status(403).json({
        success: false,
        error: 'Forbidden: Insufficient administrative privileges.',
        message: 'Forbidden: Insufficient administrative privileges.',
      });
    }

    let admin = null;
    if (decoded.id) {
      try {
        admin = await Admin.findById(decoded.id).select('-password');
      } catch (dbErr) {
        console.warn('DB lookup in adminAuth skipped:', dbErr.message);
      }
    }

    req.admin = admin || {
      email: decoded.email || process.env.ADMIN_EMAIL || 'admin@campus.com',
      role: decoded.role || 'ADMIN',
    };

    next();
  } catch (error) {
    console.error('Admin Auth Middleware Error:', error.message);
    return res.status(401).json({
      success: false,
      error: 'Access Denied: Invalid or expired administrative token.',
      message: 'Access Denied: Invalid or expired administrative token.',
    });
  }
};

export default adminAuth;
