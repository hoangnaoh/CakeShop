import helloRoute from './hello.route.js';
import userRoute from './user.route.js';
import authRoute from './auth.route.js';
import productRoute from './product.route.js';
import orderRoute from './order.route.js';
import paymentRoute from './payment.route.js';
import notificationRoute from './notification.route.js';
import aiRoute from './ai.route.js';
import chatRoute from './chat.route.js';
import settingRoute from './setting.route.js';
import uploadRoute from './upload.route.js';
import voucherRoute from './voucher.route.js';
import reviewRoute from './review.route.js';

const routes = (app) => {
  // API v1 routes
  app.use('/api/v1/auth', authRoute);
  app.use('/api/v1/users', userRoute);
  
  // Real Routes
  app.use('/api/v1/products', productRoute);
  app.use('/api/v1/orders', orderRoute);
  app.use('/api/v1/notifications', notificationRoute);
  app.use('/api/v1/vouchers', voucherRoute);
  app.use('/api/v1/reviews', reviewRoute);

  app.use('/api/v1/payments', paymentRoute);
  app.use('/api/v1/ai', aiRoute);
  app.use('/api/v1/chats', chatRoute);
  app.use('/api/v1/settings', settingRoute);
  app.use('/api/v1/upload', uploadRoute);

  // Legacy routes (keep for backward compatibility)
  app.use('/api/hello', helloRoute);
};

export default routes;
