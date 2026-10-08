import Admin from '../models/Admin.js';

export const seedAdmin = async () => {
  try {
    const adminEmail = process.env.ADMIN_EMAIL;
    const adminPassword = process.env.ADMIN_PASSWORD;

    if (!adminEmail || !adminPassword) {
      console.warn('⚠️ ADMIN_EMAIL or ADMIN_PASSWORD missing from .env. Skipping admin seed.');
      return;
    }

    const existingAdmin = await Admin.findOne({ email: adminEmail.toLowerCase() });

    if (!existingAdmin) {
      const newAdmin = new Admin({
        email: adminEmail,
        password: adminPassword,
        role: 'ADMIN',
      });

      await newAdmin.save();
      console.log(`✅ Initial Admin Account Seeded Successfully: ${adminEmail}`);
    } else {
      existingAdmin.password = adminPassword;
      existingAdmin.role = 'ADMIN';
      await existingAdmin.save();
      console.log(`ℹ️ Admin Account Seeded & Synced with .env: ${adminEmail}`);
    }
  } catch (error) {
    console.error('❌ Error during Admin auto-seeding:', error.message);
  }
};

export default seedAdmin;
