import * as authService from '../services/auth.service.js';

/**
 * POST /api/v1/auth/register
 */
export const register = async (req, res) => {
  try {
    const { email, password, fullName, roleChoice, shopInfo } = req.body;

    const result = await authService.register(email, password, fullName, roleChoice, shopInfo);

    res.status(201).json({
      success: true,
      message: 'Registration successful',
      data: {
        user: result.user,
        accessToken: result.token,
      },
    });
  } catch (error) {
    const statusCode = error.message.includes('already registered')
      ? 400
      : error.message.includes('required')
      ? 400
      : error.message.includes('yêu cầu')
      ? 400
      : error.message.includes('must be at least')
      ? 400
      : 500;

    res.status(statusCode).json({
      success: false,
      message: error.message,
    });
  }
};

/**
 * POST /api/v1/auth/login
 */
export const login = async (req, res) => {

  try {
    const { email, password } = req.body;
     console.log('🔍 Gọi authService.login với:', { email, password });
    const result = await authService.login(email, password);

    res.status(200).json({
      success: true,
      message: 'Login successful',
      data: {
        user: result.user,
        accessToken: result.token,
      },
    });
  } catch (error) {
    console.log('❌ Login error:', error.message);
      console.log('❌ Error stack:', error.stack);
    res.status(401).json({
      success: false,
      message: error.message,
    });
  }
};

/**
 * POST /api/v1/auth/google
 */
export const googleLogin = async (req, res) => {
  try {
    const { idToken, roleChoice } = req.body;
    const result = await authService.googleLogin(idToken, roleChoice);
    
    res.status(200).json({
      success: true,
      message: 'Google login successful',
      data: {
        user: result.user,
        accessToken: result.token,
      },
    });
  } catch (error) {
    res.status(401).json({
      success: false,
      message: error.message,
    });
  }
};

/**
 * GET /api/v1/auth/me
 * Cần authenticate
 */
export const getCurrentUser = async (req, res) => {
  try {
    const userId = req.user.id;

    const user = await authService.getCurrentUser(userId);

    res.status(200).json({
      success: true,
      message: 'Get current user successful',
      data: user,
    });
  } catch (error) {
    res.status(404).json({
      success: false,
      message: error.message,
    });
  }
};

/**
 * POST /api/v1/auth/logout
 * Stateless JWT - không cần làm gì
 */
export const logout = async (req, res) => {
  try {
    await authService.logout();

    res.status(200).json({
      success: true,
      message: 'Logout successful',
      data: null,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

/**
 * POST /api/v1/auth/forgot-password
 * Yêu cầu reset password bằng email
 */
export const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;

    await authService.forgotPassword(email);

    res.status(200).json({
      success: true,
      message: 'If account exists, reset link has been sent to email',
      data: null,
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message,
    });
  }
};

/**
 * POST /api/v1/auth/reset-password
 * Reset password dùng token từ forgot-password
 * Cần authenticate (body chỉ có newPassword)
 */
export const resetPassword = async (req, res) => {
  try {
    const userId = req.user.id;
    const { newPassword } = req.body;

    await authService.resetPassword(userId, newPassword);

    res.status(200).json({
      success: true,
      message: 'Password reset successful',
      data: null,
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message,
    });
  }
};

/**
 * POST /api/v1/auth/change-password
 * Thay đổi password (khi user đã login)
 */
export const changePassword = async (req, res) => {
  try {
    const userId = req.user.id;
    const { oldPassword, newPassword } = req.body;

    await authService.changePassword(userId, oldPassword, newPassword);

    res.status(200).json({
      success: true,
      message: 'Password changed successful',
      data: null,
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message,
    });
  }
};

/**
 * PATCH /api/v1/auth/profile
 * Cập nhật thông tin profile (cần authenticate)
 */
export const updateProfile = async (req, res) => {
  try {
    const userId = req.user.id;
    const updateData = req.body;

    const user = await authService.updateProfile(userId, updateData);

    res.status(200).json({
      success: true,
      message: 'Profile updated successful',
      data: user,
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message,
    });
  }
};
