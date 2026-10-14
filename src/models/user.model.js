import mongoose from 'mongoose';
import bcrypt from 'bcrypt';

const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true
  },
  password: {
    type: String,
    required: function() {
      // Password is not required if registered via Google
      return !this.googleId;
    }
  },
  googleId: {
    type: String,
    sparse: true,
    unique: true
  },
  fullName: {
    type: String,
    required: true
  },
  avatar: {
    type: String
  },
  phone: {
    type: String
  },
  roles: [{
    type: String,
    enum: ['customer', 'admin'],
    default: ['customer']
  }],
  isActive: {
    type: Boolean,
    default: true
  },
  points: {
    type: Number,
    default: 0
  },
  totalEarnedPoints: {
    type: Number,
    default: 0
  },
  rank: {
    type: String,
    enum: ['Bronze', 'Silver', 'Gold', 'VIP'],
    default: 'Bronze'
  }
}, {
  timestamps: true
});

// Mã hóa mật khẩu trước khi lưu
userSchema.pre('save', async function() {
  if (!this.isModified('password')) return;
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
});

// Hàm so sánh mật khẩu
userSchema.methods.comparePassword = async function(candidatePassword) {
  if (!this.password) return false;
  return await bcrypt.compare(candidatePassword, this.password);
};

export default mongoose.model('User', userSchema);
