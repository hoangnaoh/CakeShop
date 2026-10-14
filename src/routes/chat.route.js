import express from 'express';
import * as chatController from '../controllers/chat.controller.js';
import { authenticate, authorize } from '../middlewares/auth.middleware.js';

const router = express.Router();
const requireAdmin = authorize('admin');

router.get('/me', authenticate, chatController.getMyConversation);
router.get('/', authenticate, requireAdmin, chatController.getConversations);
router.get('/:conversationId/messages', authenticate, chatController.getMessages);
router.post('/:conversationId/messages', authenticate, chatController.sendMessage);

export default router;
