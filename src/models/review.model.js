import mongoose from 'mongoose';

const reviewSchema = new mongoose.Schema({
  order: { type: mongoose.Schema.Types.ObjectId, ref: 'Order', required: true },
  product: { type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true },
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  
  rating: { type: Number, required: true, min: 1, max: 5 },
  comment: { type: String, required: true },
  images: [{ type: String }] // URLs of uploaded images
}, {
  timestamps: true
});

export default mongoose.model('Review', reviewSchema);
