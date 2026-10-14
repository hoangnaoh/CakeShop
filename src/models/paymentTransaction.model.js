import mongoose from 'mongoose';

const paymentTransactionSchema = new mongoose.Schema({
  rentalOrder: { type: mongoose.Schema.Types.ObjectId, ref: 'Order', required: true },
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  
  amount: { type: Number, required: true },
  currency: { type: String, default: 'VND' },
  
  type: {
    type: String,
    enum: ['Payment', 'DepositRefund', 'PayoutLender', 'DamagePenalty'],
    required: true
  },
  
  paymentMethod: { type: String, enum: ['VNPAY', 'MoMo', 'Stripe', 'BankTransfer'], required: true },
  
  status: { type: String, enum: ['Pending', 'Success', 'Failed', 'Refunded'], default: 'Pending' },
  
  transactionId: { type: String },
  
  note: String
}, {
  timestamps: true
});

export default mongoose.model('PaymentTransaction', paymentTransactionSchema);
