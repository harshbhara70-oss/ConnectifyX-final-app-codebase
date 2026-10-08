import express from 'express';
import { adminLogin, getAdminProfile } from '../controllers/adminAuthController.js';
import { adminAuth } from '../middleware/adminAuth.js';

const router = express.Router();

// Public Admin Login Route
router.post('/login', adminLogin);

// Protected Admin Profile Route
router.get('/me', adminAuth, getAdminProfile);

export default router;
