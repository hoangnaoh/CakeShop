import Review from '../models/review.model.js';
import Order from '../models/order.model.js';
import Product from '../models/product.model.js';

export const createReview = async (req, res) => {
  try {
    const { orderId, productId, rating, comment, images } = req.body;
    
    // Check if order exists and is delivered
    const order = await Order.findById(orderId);
    if (!order) return res.status(404).json({ success: false, message: 'Đơn hàng không tồn tại' });
    if (order.status !== 'Delivered') {
      return res.status(400).json({ success: false, message: 'Chỉ có thể đánh giá khi đơn hàng đã giao' });
    }
    if (order.customer.toString() !== req.user._id.toString()) {
      return res.status(403).json({ success: false, message: 'Bạn không có quyền đánh giá đơn này' });
    }

    // Check if already reviewed
    const existingReview = await Review.findOne({ order: orderId, product: productId });
    if (existingReview) {
      return res.status(400).json({ success: false, message: 'Bạn đã đánh giá sản phẩm này rồi' });
    }

    const review = await Review.create({
      order: orderId,
      product: productId,
      user: req.user._id,
      rating,
      comment,
      images: images || []
    });

    res.status(201).json({ success: true, data: review });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getProductReviews = async (req, res) => {
  try {
    const { productId } = req.params;
    const reviews = await Review.find({ product: productId })
      .populate('user', 'fullName avatar')
      .sort('-createdAt');
    
    // Calculate average rating
    let avgRating = 0;
    if (reviews.length > 0) {
      const sum = reviews.reduce((acc, cur) => acc + cur.rating, 0);
      avgRating = sum / reviews.length;
    }

    res.json({ 
      success: true, 
      count: reviews.length, 
      avgRating: avgRating.toFixed(1),
      data: reviews 
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
