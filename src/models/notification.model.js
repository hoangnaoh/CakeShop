import mongoose from 'mongoose';

const notificationSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  title: { type: String, required: true },
  message: { type: String, required: true },
  type: { 
    type: String, 
    enum: ['ORDER_CONFIRMATION', 'ORDER_CONFIRMED', 'ORDER_SHIPPING', 'ORDER_DELIVERED', 'NEW_ORDER', 'SYSTEM'], 
    required: true 
  },
  orderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Order' },
  isRead: { type: Boolean, default: false }
}, {
  timestamps: true
});

export default mongoose.model('Notification', notificationSchema);
