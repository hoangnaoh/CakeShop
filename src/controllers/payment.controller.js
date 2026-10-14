import Order from '../models/order.model.js';
import Notification from '../models/notification.model.js';
import User from '../models/user.model.js';

export const handleEMVCoWebhook = async (req, res) => {
  try {
    let transactions = [];
    if (req.body && req.body.data && Array.isArray(req.body.data)) {
      // Casso format
      transactions = req.body.data;
    } else {
      // Direct emulator format
      transactions = [req.body];
    }

    for (const tx of transactions) {
      const { amount, description, transactionId, tid } = tx;
      const txId = transactionId || tid;

      if (!description || !amount) continue;

      // Parse order code from description, e.g. "CAKE1234567890"
      const orderCodeMatch = description.match(/CAKE\d{13}/i);
      if (!orderCodeMatch) continue;

      const orderCode = orderCodeMatch[0].toUpperCase();

      // Find order by qrCodeUrl containing the orderCode
      const order = await Order.findOne({ qrCodeUrl: { $regex: orderCode } });

      if (order && order.paymentStatus === 'Unpaid') {
        if (amount >= order.totalAmount) {
          order.paymentStatus = 'Paid';
          order.status = 'Confirmed';
          await order.save();

          await Notification.create({
            user: order.customer,
            title: 'Payment Received',
            message: `We have received your payment of ${amount} VND. Your order is now confirmed.`,
            type: 'ORDER_CONFIRMED',
            orderId: order._id
          });

          // Create Notification for admin
          try {
            const admins = await User.find({ roles: 'admin' });
            const orderIdStr = order._id.toString();
            const shortId = orderIdStr.substring(orderIdStr.length - 6).toUpperCase();
            for (const admin of admins) {
              await Notification.create({
                user: admin._id,
                title: 'Đơn hàng đã thanh toán',
                message: `Đơn hàng #${shortId} đã thanh toán thành công số tiền ${amount} VND.`,
                type: 'ORDER_CONFIRMED',
                orderId: order._id
              });
            }
          } catch (e) {
            console.error('Failed to create admin notification:', e);
          }

          // Notify Admin
          try {
            const { emitToUser } = await import('../config/socket.js');
            emitToUser('admin', 'payment_received', {
              orderId: order._id,
              amount,
              transactionId: txId
            });
          } catch (e) {
            console.error('Socket notification error:', e);
          }
        }
      }
    }

    res.status(200).json({ success: true });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
