import express from 'express';
import * as settingController from '../controllers/setting.controller.js';
import { authenticate, authorize } from '../middlewares/auth.middleware.js';

const router = express.Router();

/**
 * @swagger
 * /settings/bank:
 *   get:
 *     summary: Lấy cấu hình tài khoản ngân hàng của Admin (Public)
 *     tags: [Settings]
 */
router.get('/bank', settingController.getAdminBankInfo);

/**
 * @swagger
 * /settings/admin/bank:
 *   put:
 *     summary: Admin cấu hình tài khoản ngân hàng
 *     tags: [Settings, Admin]
 */
router.put('/admin/bank', authenticate, authorize('admin'), settingController.updateAdminBankInfo);

router.get('/platform/config', settingController.getPlatformConfig);
router.patch('/platform/config', authenticate, authorize('admin'), settingController.updatePlatformConfig);

router.get('/shop-address', settingController.getShopAddress);
router.put('/admin/shop-address', authenticate, authorize('admin', 'shop'), settingController.updateShopAddress);

export default router;
