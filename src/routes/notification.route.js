import express from 'express';
import * as notificationController from '../controllers/notification.controller.js';
import { authenticate } from '../middlewares/auth.middleware.js';

const router = express.Router();

router.use(authenticate);

router.get('/', notificationController.getMyNotifications);
router.patch('/:id/read', notificationController.markAsRead);

export default router;
