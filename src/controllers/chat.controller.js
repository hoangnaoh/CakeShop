import * as chatService from '../services/chat.service.js';

export const getMyConversation = async (req, res) => {
  try {
    const conversation = await chatService.getOrCreateConversation(req.user.id);
    res.status(200).json({ success: true, data: conversation });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

export const getConversations = async (req, res) => {
  try {
    const conversations = await chatService.listConversations();
    res.status(200).json({ success: true, data: conversations });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getMessages = async (req, res) => {
  try {
    const messages = await chatService.listMessages(req.params.conversationId, req.user);
    res.status(200).json({ success: true, data: messages });
  } catch (error) {
    res.status(error.message.includes('Permission') ? 403 : 400).json({ success: false, message: error.message });
  }
};

export const sendMessage = async (req, res) => {
  try {
    const message = await chatService.sendMessage(req.params.conversationId, req.user, req.body.text);
    res.status(201).json({ success: true, data: message });
  } catch (error) {
    res.status(error.message.includes('Permission') ? 403 : 400).json({ success: false, message: error.message });
  }
};
