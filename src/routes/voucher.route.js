import express from 'express';
import * as voucherController from '../controllers/voucher.controller.js';
import { authenticate, authorize } from '../middlewares/auth.middleware.js';

const router = express.Router();

/**
 * @swagger
 * /vouchers/validate:
 *   post:
 *     summary: Kiểm tra mã giảm giá
 *     tags: [Vouchers]
 */
router.post('/validate', authenticate, voucherController.validateVoucher);

/**
 * @swagger
 * /vouchers:
 *   get:
 *     summary: Lấy danh sách voucher (Admin)
 *     tags: [Vouchers]
 */
router.get('/', authenticate, authorize('admin'), voucherController.getVouchers);

/**
 * @swagger
 * /vouchers:
 *   post:
 *     summary: Tạo mã giảm giá mới (Admin)
 *     tags: [Vouchers]
 */
router.post('/', authenticate, authorize('admin'), voucherController.createVoucher);

export default router;
