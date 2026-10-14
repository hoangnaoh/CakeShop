import express from 'express';
import * as paymentController from '../controllers/payment.controller.js';

const router = express.Router();

/**
 * @swagger
 * /payments/webhook/emvco:
 *   post:
 *     summary: Webhook nhận thông báo thanh toán từ hệ thống EMVCo tự build
 *     tags: [Payments]
 */
router.post('/webhook/emvco', paymentController.handleEMVCoWebhook);

export default router;
