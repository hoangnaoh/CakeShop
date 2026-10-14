import mongoose from 'mongoose';

const orderItemSchema = new mongoose.Schema({
  product: { type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true },
  quantity: { type: Number, required: true },
  price: { type: Number, required: true },
  size: { type: String }
});

const orderSchema = new mongoose.Schema({
  customer: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  
  items: [orderItemSchema],
  
  status: { 
    type: String, 
    enum: [
      'Pending', 'Confirmed', 'Shipping', 'Delivered', 'Canceled'
    ], 
    default: 'Pending' 
  },
  
  totalAmount: { type: Number, required: true },
  
  paymentMethod: {
    type: String,
    enum: ['COD', 'EMVCo'],
    required: true
  },
  
  paymentStatus: {
    type: String,
    enum: ['Unpaid', 'Paid'],
    default: 'Unpaid'
  },
  
  shippingAddress: {
    fullName: String,
    phone: String,
    address: String
  },
  
  shippingFee: { type: Number, default: 0 },
  
  note: String,
  
  qrCodeUrl: { type: String },

  // --- Khuyến mãi & Tích điểm ---
  voucherCode: { type: String },
  discountAmount: { type: Number, default: 0 },
  pointsUsed: { type: Number, default: 0 }, // Số điểm đã sử dụng (1 điểm = 1đ)
  pointsEarned: { type: Number, default: 0 } // Số điểm nhận được từ đơn hàng này
}, {
  timestamps: true
});

export default mongoose.model('Order', orderSchema);
