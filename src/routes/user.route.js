import express from 'express';
import * as userController from '../controllers/user.controller.js';
import { authenticate } from '../middlewares/auth.middleware.js';

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Users
 *   description: API Quản lý người dùng và hồ sơ
 */

/**
 * @swagger
 * /users/{id}:
 *   get:
 *     summary: Xem hồ sơ user khác (Bao gồm shop nếu là lender)
 *     tags: [Users]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Thông tin user
 */
router.get('/:id', userController.getUserById);

export default router;
