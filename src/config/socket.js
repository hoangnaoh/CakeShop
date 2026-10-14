import { Server } from 'socket.io';
import { verifyToken } from '../utils/jwt.js';

let io;
// Lưu trữ các userId đang kết nối và socket id tương ứng
// Dạng: { "userId": ["socketId1", "socketId2"] }
const connectedUsers = new Map();

export const initSocket = (server) => {
  io = new Server(server, {
    cors: {
      origin: '*', // Trong thực tế nên để đúng domain của Frontend
      methods: ['GET', 'POST']
    }
  });

  // Middleware xác thực kết nối Socket
  io.use((socket, next) => {
    try {
      const token = socket.handshake.auth.token || socket.handshake.headers['authorization'];
      if (!token) {
        return next(new Error('Authentication error: Missing token'));
      }
      
      const actualToken = token.startsWith('Bearer ') ? token.slice(7) : token;
      const decoded = verifyToken(actualToken);
      
      if (!decoded || (!decoded.id && !decoded._id)) {
        return next(new Error('Authentication error: Invalid token'));
      }
      
      // Lưu userId vào socket
      socket.userId = decoded.id || decoded._id;
      next();
    } catch (err) {
      next(new Error('Authentication error'));
    }
  });

  io.on('connection', (socket) => {
    console.log(`[Socket] User connected: ${socket.userId} (Socket: ${socket.id})`);
    
    // Thêm vào danh sách users đang online
    const userSockets = connectedUsers.get(socket.userId) || [];
    userSockets.push(socket.id);
    connectedUsers.set(socket.userId, userSockets);

    socket.on('disconnect', () => {
      console.log(`[Socket] User disconnected: ${socket.userId} (Socket: ${socket.id})`);
      const sockets = connectedUsers.get(socket.userId) || [];
      const index = sockets.indexOf(socket.id);
      if (index !== -1) {
        sockets.splice(index, 1);
        if (sockets.length === 0) {
          connectedUsers.delete(socket.userId);
        } else {
          connectedUsers.set(socket.userId, sockets);
        }
      }
    });
  });

  return io;
};

// Hàm hỗ trợ để lấy đối tượng io
export const getIO = () => {
  if (!io) {
    throw new Error('Socket.io is not initialized!');
  }
  return io;
};

// Hàm hỗ trợ để bắn sự kiện tới 1 user cụ thể
export const emitToUser = (userId, eventName, data) => {
  if (!io) {
    console.log('[Socket Debug] io is undefined');
    return false;
  }
  const userIdStr = userId.toString();
  const sockets = connectedUsers.get(userIdStr);
  console.log(`[Socket Debug] emitToUser: ${userIdStr}. Sockets found:`, sockets);
  
  if (sockets && sockets.length > 0) {
    sockets.forEach(socketId => {
      io.to(socketId).emit(eventName, data);
      console.log(`[Socket Debug] Emitted ${eventName} to socket ${socketId}`);
    });
    return true; // Sent successfully
  }
  return false; // User is offline
};

// Hàm hỗ trợ để check debug
export const getConnectedUsersDebug = () => {
  return Object.fromEntries(connectedUsers);
};
