import 'dotenv/config';
import app from './app.js';
import connectDB from './config/db.js';
import http from 'http';
import { initSocket } from './config/socket.js';

connectDB();

const server = http.createServer(app);

// Khởi tạo Socket.io
initSocket(server);

const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});