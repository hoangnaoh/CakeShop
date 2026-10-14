import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-in-env';
const TOKEN_EXPIRY = '7d';

/**
 * Tạo JWT access token
 * Payload: {id, role}
 */
export const generateToken = (userId, role) => {
  const payload = {
    id: userId,
    role: role,
  };
  return jwt.sign(payload, JWT_SECRET, { expiresIn: TOKEN_EXPIRY });
};

/**
 * Verify JWT token
 * Return: payload or null
 */
export const verifyToken = (token) => {
  try {
    return jwt.verify(token, JWT_SECRET);
  } catch (error) {
    return null;
  }
};

/**
 * Decode token (không verify expiry)
 */
export const decodeToken = (token) => {
  try {
    return jwt.decode(token);
  } catch (error) {
    return null;
  }
};
