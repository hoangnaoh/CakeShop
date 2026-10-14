import express from 'express';
import * as orderController from '../controllers/order.controller.js';
import { authenticate } from '../middlewares/auth.middleware.js';

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Orders
 *   description: API Quản lý Đơn Thuê Đồ
 */

/**
 * @swagger
 * /orders:
 *   post:
 *     summary: Tạo đơn thuê đồ mới
 *     tags: [Orders]
 */
router.post('/', authenticate, orderController.createOrder);

/**
 * @swagger
 * /orders/me:
 *   get:
 *     summary: Lấy danh sách đơn thuê của tôi (vai trò Khách thuê)
 *     tags: [Orders]
 */
router.get('/me', authenticate, orderController.getMyOrders);

/**
 * @swagger
 * /orders/shop/me:
 *   get:
 *     summary: Lấy danh sách đơn thuê của shop tôi (vai trò Chủ đồ)
 *     tags: [Orders]
 */
router.get('/shop/me', authenticate, orderController.getShopOrders);
router.get('/shop/revenue', authenticate, orderController.getShopRevenue);

/**
 * @swagger
 * /orders/{id}:
 *   get:
 *     summary: Xem chi tiết 1 đơn thuê
 *     tags: [Orders]
 */
router.get('/:id', authenticate, orderController.getOrderById);

/**
 * @swagger
 * /orders/{id}/status:
 *   patch:
 *     summary: Cập nhật trạng thái đơn thuê (bởi Chủ đồ hoặc Admin)
 *     tags: [Orders]
 */
router.patch('/:id/status', authenticate, orderController.updateOrderStatus);
router.post('/:id/cancel', authenticate, orderController.cancelOrder);
router.post('/:id/extend', authenticate, orderController.extendOrder);
router.patch('/:id/confirm', authenticate, orderController.confirmOrder);
router.post('/:id/check-in', authenticate, orderController.checkInOrder);
router.post('/:id/check-out', authenticate, orderController.checkOutOrder);

export default router;
