import mongoose from 'mongoose';

const categorySchema = new mongoose.Schema({
  name: { type: String, required: true },
  slug: { type: String, required: true, unique: true },
  description: String,
  parent: { type: mongoose.Schema.Types.ObjectId, ref: 'Category', default: null },
  image: String
}, { timestamps: true });

export default mongoose.model('Category', categorySchema);
