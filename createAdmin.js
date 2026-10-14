import mongoose from 'mongoose';
import dotenv from 'dotenv';
import User from './src/models/user.model.js';

dotenv.config();

const MONGO_URI = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/BuildLab_DB';

const createAdmin = async () => {
  try {
    await mongoose.connect(MONGO_URI);
    console.log('MongoDB Connected...');

    const email = 'admin@gmail.com';
    const existingAdmin = await User.findOne({ email });

    if (existingAdmin) {
      console.log('Admin account already exists!');
      process.exit(0);
    }

    // Mongoose schema has pre('save') hook to hash password
    const admin = new User({
      email,
      password: '123456', // Password is plain text, will be hashed
      fullName: 'Chủ Shop CakeShop',
      roles: ['admin'], 
      isActive: true,
    });

    await admin.save();
    console.log('=================================');
    console.log('✅ Admin Account Created Successfully!');
    console.log('Email: admin@gmail.com');
    console.log('Password: password123');
    console.log('=================================');

    process.exit(0);
  } catch (error) {
    console.error('Error creating admin:', error);
    process.exit(1);
  }
};

createAdmin();
