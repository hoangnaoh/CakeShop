import express from 'express';
import * as aiController from '../controllers/ai.controller.js';
import { authenticate } from '../middlewares/auth.middleware.js';

const router = express.Router();

router.post('/chat', authenticate, aiController.askAiAssistant);

export default router;
