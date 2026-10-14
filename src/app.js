import express from 'express';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import routes from './routes/index.js';
import logger from './middlewares/logger.js';
import swaggerUi from 'swagger-ui-express';
import { swaggerSpec } from './config/swagger.js';

const app = express();

const defaultClientUrl = process.env.CLIENT_URL || 'http://localhost:5173';

// ── CORS ──────────────────────────────────────────────────────────────────────
app.use(cors({
  origin: true, // Cho phép tất cả origins (Flutter mobile, web, Postman, Render...)
  credentials: true, // Cho phép gửi cookie (refresh token httpOnly)
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// ── MIDDLEWARE ────────────────────────────────────────────────────────────────
app.use(express.json());
app.use(cookieParser());
logger(app);

// ── HEALTH CHECK (dùng cho Render / UptimeRobot) ──────────────────────────────
app.get('/health', (req, res) => res.status(200).json({ status: 'ok', timestamp: new Date() }));

// ── SWAGGER API DOCS ────────────────────────────────────────────────────────────
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// ── ROUTES ────────────────────────────────────────────────────────────────────
routes(app);

export default app;