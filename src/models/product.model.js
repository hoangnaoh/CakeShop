import mongoose from 'mongoose';

const productSchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: { type: String, required: true },
  category: { type: mongoose.Schema.Types.ObjectId, ref: 'Category', required: true },
  
  price: { type: Number, required: true }, 
  
  images: [{
    url: String,
    public_id: String,
    isPrimary: { type: Boolean, default: false }
  }],
  
  stock: { type: Number, default: 0, min: 0 },
  status: { type: String, enum: ['Available', 'Out of Stock', 'Unavailable'], default: 'Available' },
  sizes: [{ type: String }],
  
  
  rating: {
    average: { type: Number, default: 0 },
    count: { type: Number, default: 0 }
  }
}, {
  timestamps: true
});

export default mongoose.model('Product', productSchema);
