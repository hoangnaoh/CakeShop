import mongoose from 'mongoose';

const conversationSchema = new mongoose.Schema({
  customer: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  subject: { type: String, default: 'BuildLab support', trim: true },
  lastMessage: { type: String, default: '' },
  lastMessageAt: Date,
  status: { type: String, enum: ['open', 'closed'], default: 'open' }
}, { timestamps: true });

const messageSchema = new mongoose.Schema({
  conversation: { type: mongoose.Schema.Types.ObjectId, ref: 'Conversation', required: true },
  sender: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  senderRole: { type: String, enum: ['customer', 'admin'], required: true },
  text: { type: String, required: true, trim: true },
  readAt: Date
}, { timestamps: true });

export const Conversation = mongoose.model('Conversation', conversationSchema);
export const Message = mongoose.model('Message', messageSchema);
