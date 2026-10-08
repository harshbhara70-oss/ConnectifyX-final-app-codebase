import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';
import dns from 'dns';
import connectDB from './config/db.js';
import authRoutes from './routes/authRoutes.js';
import adminAuthRoutes from './routes/adminAuthRoutes.js';
import { seedAdmin } from './utils/seedAdmin.js';

// Prioritize IPv4 DNS lookups to avoid ECONNREFUSED on MongoDB Atlas SRV links
dns.setDefaultResultOrder('ipv4first');

// Resolve __dirname in ES module scope
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load env variables from root folder
dotenv.config({ path: path.join(__dirname, '../.env') });

// Connect to MongoDB Atlas and auto-seed initial admin
connectDB().then(() => {
  seedAdmin();
});

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/v1/admin', adminAuthRoutes);
app.use('/api/admin', adminAuthRoutes);

// Root route for sanity check
app.get('/', (req, res) => {
  res.json({ message: 'Campus2Corporate Auth & Admin Backend API is running successfully' });
});

// Centralized error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: 'An unexpected internal server error occurred',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined,
  });
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
