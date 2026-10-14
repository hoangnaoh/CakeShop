import express from 'express';
import * as productController from '../controllers/product.controller.js';
import { authenticate } from '../middlewares/auth.middleware.js';
import { upload } from '../config/cloudinary.config.js';

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Products
 *   description: API Quản lý Sản phẩm / Tủ đồ
 */

/**
 * @swagger
 * /products:
 *   get:
 *     summary: Lấy danh sách sản phẩm
 *     tags: [Products]
 */
router.get('/', productController.getProducts);

/**
 * @swagger
 * /products/shop/me:
 *   get:
 *     summary: Xem danh sách đồ của tôi (Dành cho Lender)
 *     tags: [Products]
 */
router.get('/shop/me', authenticate, productController.getMyProducts);

/**
 * @swagger
 * /products/{id}:
 *   get:
 *     summary: Xem chi tiết 1 sản phẩm
 *     tags: [Products]
 */
router.get('/:id', productController.getProductById);

/**
 * @swagger
 * /products:
 *   post:
 *     summary: Đăng sản phẩm mới (Hỗ trợ upload ảnh)
 *     tags: [Products]
 */
router.post('/shop/me', authenticate, upload.array('images', 5), productController.createProduct);

/**
 * @swagger
 * /products/{id}:
 *   put:
 *     summary: Chỉnh sửa sản phẩm
 *     tags: [Products]
 */
router.put('/:id', authenticate, productController.updateProduct);

/**
 * @swagger
 * /products/{id}:
 *   delete:
 *     summary: Tạm ẩn/Xóa sản phẩm
 *     tags: [Products]
 */
router.delete('/:id', authenticate, productController.deleteProduct);

export default router;
