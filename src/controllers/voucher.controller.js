import Voucher from '../models/voucher.model.js';

export const createVoucher = async (req, res) => {
  try {
    const voucher = await Voucher.create(req.body);
    res.status(201).json({ success: true, data: voucher });
  } catch (error) {
    if (error.code === 11000) {
      return res.status(400).json({ success: false, message: 'Mã voucher đã tồn tại' });
    }
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getVouchers = async (req, res) => {
  try {
    const vouchers = await Voucher.find().sort({ createdAt: -1 });
    res.json({ success: true, data: vouchers });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const validateVoucher = async (req, res) => {
  try {
    const { code, orderValue } = req.body;
    
    if (!code) return res.status(400).json({ success: false, message: 'Mã voucher là bắt buộc' });
    
    const voucher = await Voucher.findOne({ code: code.toUpperCase(), isActive: true });
    
    if (!voucher) {
      return res.status(404).json({ success: false, message: 'Mã voucher không hợp lệ hoặc đã hết hạn' });
    }

    const now = new Date();
    if (now < voucher.startDate || now > voucher.endDate) {
      return res.status(400).json({ success: false, message: 'Mã voucher không nằm trong thời gian sử dụng' });
    }

    if (voucher.usageLimit > 0 && voucher.usedCount >= voucher.usageLimit) {
      return res.status(400).json({ success: false, message: 'Mã voucher đã hết lượt sử dụng' });
    }

    if (orderValue && orderValue < voucher.minOrderValue) {
      return res.status(400).json({ success: false, message: `Đơn hàng tối thiểu phải từ ${voucher.minOrderValue}đ để áp dụng mã này` });
    }

    // Calculate preview discount if orderValue is provided
    let discountAmount = 0;
    if (orderValue) {
      if (voucher.discountType === 'percentage') {
        discountAmount = orderValue * (voucher.discountValue / 100);
        if (voucher.maxDiscount && discountAmount > voucher.maxDiscount) {
          discountAmount = voucher.maxDiscount;
        }
      } else {
        discountAmount = voucher.discountValue;
      }
    }

    res.json({ success: true, data: { voucher, discountPreview: discountAmount } });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
