import express from 'express';
import * as authController from '../controllers/auth.controller.js';
import { authenticate } from '../middlewares/auth.middleware.js';

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Auth
 *   description: API Quản lý xác thực và tài khoản
 */

/**
 * @swagger
 * /auth/register:
 *   post:
 *     summary: Đăng ký tài khoản mới
 *     tags: [Auth]
 *     security: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *               - fullName
 *             properties:
 *               email:
 *                 type: string
 *                 example: user@example.com
 *               password:
 *                 type: string
 *                 example: password123
 *               fullName:
 *                 type: string
 *                 example: Nguyen Van A
 *     responses:
 *       201:
 *         description: Đăng ký thành công
 */
router.post('/register', authController.register);

/**
 * @swagger
 * /auth/login:
 *   post:
 *     summary: Đăng nhập bằng Email/Password
 *     tags: [Auth]
 *     security: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *                 example: user@example.com
 *               password:
 *                 type: string
 *                 example: password123
 *     responses:
 *       200:
 *         description: Đăng nhập thành công, trả về Access Token
 */
router.post('/login', authController.login);

/**
 * @swagger
 * /auth/google:
 *   post:
 *     summary: Đăng nhập bằng Google
 *     tags: [Auth]
 *     security: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - idToken
 *             properties:
 *               idToken:
 *                 type: string
 *               roleChoice:
 *                 type: string
 *                 enum: [renter, lender]
 *     responses:
 *       200:
 *         description: Đăng nhập Google thành công
 */
router.post('/google', authController.googleLogin);

/**
 * @swagger
 * /auth/me:
 *   get:
 *     summary: Lấy thông tin tài khoản đang đăng nhập
 *     tags: [Auth]
 *     responses:
 *       200:
 *         description: Thông tin user
 */
router.get('/me', authenticate, authController.getCurrentUser);

/**
 * @swagger
 * /auth/logout:
 *   post:
 *     summary: Đăng xuất
 *     tags: [Auth]
 *     responses:
 *       200:
 *         description: Đăng xuất thành công
 */
router.post('/logout', authenticate, authController.logout);

/**
 * @swagger
 * /auth/forgot-password:
 *   post:
 *     summary: Quên mật khẩu
 *     tags: [Auth]
 *     security: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               email:
 *                 type: string
 *     responses:
 *       200:
 *         description: Đã gửi email reset
 */
router.post('/forgot-password', authController.forgotPassword);

/**
 * @swagger
 * /auth/reset-password:
 *   post:
 *     summary: Đặt lại mật khẩu (Dùng token từ email)
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               newPassword:
 *                 type: string
 *     responses:
 *       200:
 *         description: Thành công
 */
router.post('/reset-password', authenticate, authController.resetPassword);

/**
 * @swagger
 * /auth/change-password:
 *   post:
 *     summary: Đổi mật khẩu
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               oldPassword:
 *                 type: string
 *               newPassword:
 *                 type: string
 *     responses:
 *       200:
 *         description: Đổi mật khẩu thành công
 */
router.post('/change-password', authenticate, authController.changePassword);

/**
 * @swagger
 * /auth/profile:
 *   patch:
 *     summary: Cập nhật thông tin cá nhân cơ bản
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               fullName:
 *                 type: string
 *               phone:
 *                 type: string
 *     responses:
 *       200:
 *         description: Cập nhật thành công
 */
router.patch('/profile', authenticate, authController.updateProfile);

export default router;
