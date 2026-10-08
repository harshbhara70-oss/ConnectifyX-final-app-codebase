import jwt from 'jsonwebtoken';
import User from '../models/User.js';
import mongoose from 'mongoose';

export const protect = async (req, res, next) => {
  let token;

  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer')
  ) {
    try {
      // Get token from header
      token = req.headers.authorization.split(' ')[1];

      // Verify token
      const secret = process.env.JWT_SECRET || 'fallback_jwt_secret_key_123456';
      const decoded = jwt.verify(token, secret);

      // If database is not connected, populate a fallback mock user
      if (mongoose.connection.readyState !== 1) {
        req.user = {
          id: decoded.id,
          fullName: 'Demo User',
          email: 'demo@c2c.com',
          phone: '+91 98765 43210',
          role: 'student',
          isVerified: true,
        };
        return next();
      }

      // Get user from the token, exclude password
      req.user = await User.findById(decoded.id).select('-password');
      
      if (!req.user) {
        return res.status(401).json({ success: false, message: 'Not authorized, user not found' });
      }

      return next();
    } catch (error) {
      console.error('JWT verification error:', error.message);
      return res.status(401).json({ success: false, message: 'Not authorized, token failed' });
    }
  }

  if (!token) {
    return res.status(401).json({ success: false, message: 'Not authorized, no token provided' });
  }
};
