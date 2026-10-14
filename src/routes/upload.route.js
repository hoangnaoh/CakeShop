
import express from 'express';
import { upload } from '../config/cloudinary.config.js';
import * as uploadController from '../controllers/upload.controller.js';

const router = express.Router();

router.post('/image', upload.single('image'), uploadController.uploadImage);

export default router;

