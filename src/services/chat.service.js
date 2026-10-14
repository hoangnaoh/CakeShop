import { Conversation, Message } from '../models/chat.model.js';

export const getOrCreateConversation = async (customerId) => {
  let conversation = await Conversation.findOne({ customer: customerId, status: 'open' }).populate('customer', 'fullName email roles');
  if (!conversation) conversation = await Conversation.create({ customer: customerId });
  return Conversation.findById(conversation._id).populate('customer', 'fullName email roles').lean();
};

export const listConversations = async () => Conversation.find({}).populate('customer', 'fullName email roles').sort({ lastMessageAt: -1, createdAt: -1 }).lean();

export const listMessages = async (conversationId, user) => {
  const conversation = await Conversation.findById(conversationId);
  if (!conversation) throw new Error('Conversation not found');
  
  const isAdmin = user.roles && user.roles.includes('admin');
  if (!isAdmin && conversation.customer.toString() !== user.id) throw new Error('Permission denied');
  
  return Message.find({ conversation: conversationId }).populate('sender', 'fullName email roles').sort({ createdAt: 1 }).lean();
};

export const sendMessage = async (conversationId, sender, text) => {
  if (!text?.trim()) throw new Error('Message text is required');
  const conversation = await Conversation.findById(conversationId);
  if (!conversation) throw new Error('Conversation not found');
  
  const isAdmin = sender.roles && sender.roles.includes('admin');
  if (!isAdmin && conversation.customer.toString() !== sender.id) throw new Error('Permission denied');
  
  const message = await Message.create({ 
    conversation: conversationId, 
    sender: sender.id, 
    senderRole: isAdmin ? 'admin' : 'customer', 
    text: text.trim() 
  });
  
  conversation.lastMessage = message.text;
  conversation.lastMessageAt = message.createdAt;
  await conversation.save();
  return Message.findById(message._id).populate('sender', 'fullName email roles').lean();
};
