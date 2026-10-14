import mongoose from 'mongoose';

const transactionSchema = new mongoose.Schema({
  wallet: { type: mongoose.Schema.Types.ObjectId, ref: 'Wallet', required: true },
  type: { 
    type: String, 
    enum: ['deposit', 'withdrawal', 'payment', 'refund', 'fee'], 
    required: true 
  },
  amount: { type: Number, required: true },
  balanceAfter: { type: Number },
  referenceId: { type: mongoose.Schema.Types.ObjectId }, // could be rental_order_id or withdrawal_request_id
  orderCode: { type: String }, // Used for string-based references like EMVCo QR codes
  description: { type: String },
  status: { 
    type: String, 
    enum: ['pending', 'completed', 'failed'], 
    default: 'pending' 
  },
  completedAt: { type: Date }
}, {
  timestamps: true
});

export default mongoose.model('Transaction', transactionSchema);
