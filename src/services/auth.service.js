import bcrypt from 'bcrypt';
import { OAuth2Client } from 'google-auth-library';
import User from '../models/user.model.js';
import { generateToken } from '../utils/jwt.js';

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);
const SALT_ROUNDS = 10;

export const register = async (email, password, fullName, roleChoice, shopInfo) => {
  if (!email || !password || !fullName) {
    throw new Error('Email, password, and fullName are required');
  }

  const existingUser = await User.findOne({ email: email.toLowerCase() });
  if (existingUser) {
    throw new Error('Email already registered');
  }

  const userRole = (roleChoice === 'admin') ? 'admin' : 'customer';

  const user = new User({
    email: email.toLowerCase(),
    password: password,
    fullName: fullName,
    roles: [userRole], 
  });

  await user.save();

  const token = generateToken(user._id.toString(), userRole);

  return {
    user: {
      id: user._id,
      email: user.email,
      fullName: user.fullName,
      roles: user.roles,
    },
    token,
  };
};

export const login = async (email, password) => {
  if (!email || !password) {
    throw new Error('Email and password are required');
  }

  const user = await User.findOne({ email: email.toLowerCase() });
  if (!user) {
    throw new Error('Invalid email or password');
  }

   const isPasswordValid = await bcrypt.compare(password, user.password);

  if (!isPasswordValid) {
    throw new Error('Invalid email or password');
  }

  const token = generateToken(user._id.toString(), user.roles[0] || 'customer');

  return {
    user: {
      id: user._id,
      email: user.email,
      fullName: user.fullName,
      roles: user.roles,
      points: user.points,
      rank: user.rank
    },
    token,
  };
};

export const googleLogin = async (idToken, roleChoice) => {
  const ticket = await client.verifyIdToken({
    idToken,
    audience: process.env.GOOGLE_CLIENT_ID
  });
  
  const { sub: googleId, email, name, picture } = ticket.getPayload();

  let user = await User.findOne({ email });

  if (user) {
    if (!user.googleId) {
      user.googleId = googleId;
      user.avatar = user.avatar || picture;
      await user.save();
    }
  } else {
    const userRoles = roleChoice ? [roleChoice] : ['customer'];
    user = await User.create({
      fullName: name,
      email,
      googleId,
      avatar: picture,
      roles: userRoles
    });
  }

  const token = generateToken(user._id.toString(), user.roles[0] || 'customer');

  return {
    user: {
      id: user._id,
      email: user.email,
      fullName: user.fullName,
      avatar: user.avatar,
      roles: user.roles,
      points: user.points,
      rank: user.rank
    },
    token
  };
};

export const getCurrentUser = async (userId) => {
  const user = await User.findById(userId).select('-password');
  if (!user) {
    throw new Error('User not found');
  }

  return user._doc;
};

export const logout = async () => {
  return { message: 'Logout successful' };
};

export const forgotPassword = async (email) => {
  throw new Error('Not implemented yet');
};

export const resetPassword = async (userId, newPassword) => {
  throw new Error('Not implemented yet');
};

export const changePassword = async (userId, oldPassword, newPassword) => {
  if (!userId || !oldPassword || !newPassword) {
    throw new Error('User ID, old password, and new password are required');
  }

  if (newPassword.length < 6) {
    throw new Error('Password must be at least 6 characters');
  }

  const user = await User.findById(userId);
  if (!user) {
    throw new Error('User not found');
  }
  
  if (user.googleId && !user.password) {
    throw new Error('Google users cannot change password');
  }

  const isOldPasswordValid = await user.comparePassword(oldPassword);
  if (!isOldPasswordValid) {
    throw new Error('Current password is incorrect');
  }

  user.password = newPassword;
  await user.save();

  return { message: 'Password changed successful' };
};

export const updateProfile = async (userId, updateData) => {
  const user = await User.findById(userId);
  if (!user) throw new Error('User not found');

  const allowedFields = ['fullName', 'phone', 'avatar'];
  for (const key of Object.keys(updateData)) {
    if (allowedFields.includes(key)) {
      user[key] = updateData[key];
    }
  }
  await user.save();
  return user;
};

