import Order from '../models/order.model.js';
import Product from '../models/product.model.js';
import Notification from '../models/notification.model.js';
import PlatformSetting from '../models/platformSetting.model.js';
import Voucher from '../models/voucher.model.js';
import User from '../models/user.model.js';
import { generateVietQR } from '../utils/emvco.util.js';
import axios from 'axios';

let lastCassoGlobalSyncTime = 0;

const checkOrderPaymentWithCasso = async (order) => {
  if (!order || !order.qrCodeUrl) return false;

  const orderCodeMatch = order.qrCodeUrl.match(/CAKE\d{13}/i);
  if (!orderCodeMatch) return false;

  const orderCode = orderCodeMatch[0].toUpperCase();
  const totalAmount = order.totalAmount;

  const apiKey = process.env.CASSO_API_KEY;
  if (!apiKey) {
    console.warn('[Casso Sync] CASSO_API_KEY is not defined in .env');
    return false;
  }

  try {
    const setting = await PlatformSetting.findOne({ key: 'ADMIN_BANK_ACCOUNT' });
    const accountNumber = (setting && setting.value && setting.value.accountNumber)
      ? setting.value.accountNumber
      : '113366668888';

    // 1. Force Sync with bank via Casso (Rate limited to once per 2 minutes globally to prevent 429)
    const now = Date.now();
    if (now - lastCassoGlobalSyncTime >= 120000) {
      lastCassoGlobalSyncTime = now;
      console.log(`[Casso Sync] Triggering sync for account ${accountNumber} (Order: ${order._id})...`);
      
      // Request sync in background (no await)
      axios.post(
        'https://oauth.casso.vn/v2/sync',
        { bank_acc_id: accountNumber },
        {
          headers: {
            'Authorization': `Apikey ${apiKey}`,
            'Content-Type': 'application/json',
          },
          timeout: 5000,
        }
      ).catch(e => console.error('[Casso Sync] Sync trigger error:', e.message));
    }

    // 2. Fetch the latest transactions from Casso
    console.log(`[Casso Fetch] Fetching recent transactions to match order ${orderCode}...`);
    const response = await axios.get('https://oauth.casso.vn/v2/transactions', {
      headers: {
        'Authorization': `Apikey ${apiKey}`,
        'Content-Type': 'application/json'
      },
      params: {
        sort: 'DESC',
        pageSize: 20
      },
      timeout: 5000
    });

    if (response.data && response.data.error === 0) {
      const records = response.data.data.records || [];
      for (const record of records) {
        const description = String(record.description).toUpperCase();
        const amount = Math.abs(Number(record.amount));

        if (description.includes(orderCode)) {
          if (amount >= totalAmount) {
            console.log(`[Casso Match Success] Found matching transaction for order ${orderCode}! Amount: ${amount}`);
            
            // Mark order as paid
            order.paymentStatus = 'Paid';
            order.status = 'Confirmed';
            await order.save();

            // Create Notification
            await Notification.create({
              user: order.customer._id || order.customer,
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

            // Notify Admin via WebSocket
            try {
              const { emitToUser } = await import('../config/socket.js');
              emitToUser('admin', 'payment_received', {
                orderId: order._id,
                amount,
                transactionId: record.transactionId || record.id
              });
            } catch (e) {
              console.error('Socket notification error:', e);
            }

            return true;
          }
        }
      }
    }
  } catch (error) {
    console.error('[Casso Fetch] Error checking transactions:', error.response?.data || error.message);
  }
  return false;
};

export const createOrder = async (req, res) => {
  try {
    const { items, shippingAddress, paymentMethod, note, voucherCode, usePoints, shippingFee = 0 } = req.body;
    
    if (!items || items.length === 0) {
      return res.status(400).json({ success: false, message: 'Cart is empty' });
    }

    const user = await User.findById(req.user._id);
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });

    let subtotalAmount = 0;
    const orderItems = [];

    for (const item of items) {
      const product = await Product.findById(item.productId);
      if (!product) {
        return res.status(404).json({ success: false, message: `Product not found: ${item.productId}` });
      }
      if (product.status !== 'Available' || product.stock < item.quantity) {
        return res.status(400).json({ success: false, message: `Product ${product.name} is out of stock or unavailable` });
      }

      const itemTotal = product.price * item.quantity;
      subtotalAmount += itemTotal;
      orderItems.push({
        product: product._id,
        quantity: item.quantity,
        price: product.price,
        size: item.size
      });

      product.stock -= item.quantity;
      if (product.stock === 0) product.status = 'Out of Stock';
      await product.save();
    }

    let discountAmount = 0;
    let appliedVoucher = null;

    // Process Voucher
    if (voucherCode) {
      const voucher = await Voucher.findOne({ code: voucherCode.toUpperCase(), isActive: true });
      const now = new Date();
      if (voucher && now >= voucher.startDate && now <= voucher.endDate) {
        if (voucher.usageLimit === 0 || voucher.usedCount < voucher.usageLimit) {
          if (subtotalAmount >= voucher.minOrderValue) {
            if (voucher.discountType === 'percentage') {
              discountAmount = subtotalAmount * (voucher.discountValue / 100);
              if (voucher.maxDiscount && discountAmount > voucher.maxDiscount) discountAmount = voucher.maxDiscount;
            } else {
              discountAmount = voucher.discountValue;
            }
            appliedVoucher = voucher;
          }
        }
      }
    }

    let totalAfterDiscount = subtotalAmount - discountAmount;
    if (totalAfterDiscount < 0) totalAfterDiscount = 0;

    // Process Points (1 point = 1 VND)
    let pointsUsed = 0;
    if (usePoints && usePoints > 0) {
      if (user.points < usePoints) {
        return res.status(400).json({ success: false, message: 'Not enough points' });
      }
      pointsUsed = usePoints;
      if (pointsUsed > totalAfterDiscount) {
        pointsUsed = totalAfterDiscount;
      }
      totalAfterDiscount -= pointsUsed;
      
      // Deduct points
      user.points -= pointsUsed;
      await user.save();
    }

    const feeNum = Number(shippingFee) || 0;
    const totalAmount = totalAfterDiscount + feeNum;
    
    // Determine cashback percentage based on Rank
    let cashbackPercent = 0.05; // Bronze
    if (user.rank === 'Silver') cashbackPercent = 0.07;
    else if (user.rank === 'Gold') cashbackPercent = 0.10;
    else if (user.rank === 'VIP') cashbackPercent = 0.15;

    const pointsEarned = Math.floor(totalAmount * cashbackPercent);

    if (appliedVoucher) {
      appliedVoucher.usedCount += 1;
      await appliedVoucher.save();
    }

    let qrCodeUrl = null;
    let paymentStatus = 'Unpaid';
    
    if (paymentMethod === 'EMVCo') {
      const setting = await PlatformSetting.findOne({ key: 'ADMIN_BANK_ACCOUNT' });
      const orderCode = `CAKE${Date.now()}`;
      
      if (setting && setting.value) {
        qrCodeUrl = generateVietQR({
          bin: setting.value.bin,
          accountNumber: setting.value.accountNumber,
          accountName: setting.value.accountName,
          amount: totalAmount,
          orderCode
        });
      } else {
        // Fallback mock if settings not configured
        qrCodeUrl = generateVietQR({
          bin: '970415',
          accountNumber: '113366668888',
          accountName: 'CAKESHOP',
          amount: totalAmount,
          orderCode
        });
      }
    }

    const order = await Order.create({
      customer: req.user._id,
      items: orderItems,
      totalAmount,
      shippingFee: feeNum,
      shippingAddress,
      paymentMethod,
      paymentStatus,
      note,
      qrCodeUrl,
      voucherCode: appliedVoucher ? appliedVoucher.code : null,
      discountAmount,
      pointsUsed,
      pointsEarned
    });

    // Create Notification
    await Notification.create({
      user: req.user._id,
      title: 'Order Placed Successfully',
      message: `Your order for ${totalAmount} VND has been placed.`,
      type: 'ORDER_CONFIRMATION',
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
          title: 'Đơn hàng mới',
          message: `Khách hàng đã đặt đơn hàng mới #${shortId} trị giá ${totalAmount} VND.`,
          type: 'NEW_ORDER',
          orderId: order._id
        });
      }
    } catch (e) {
      console.error('Failed to create admin notification:', e);
    }

    // Notify Admin (optional socket logic can be kept simple)
    const { emitToUser } = await import('../config/socket.js');
    emitToUser('admin', 'new_order', {
      orderId: order._id,
      totalAmount
    });

    res.status(201).json({ success: true, data: order });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getMyOrders = async (req, res) => {
  try {
    const orders = await Order.find({ customer: req.user._id })
      .populate('items.product', 'name images price')
      .sort('-createdAt');
    res.json({ success: true, count: orders.length, data: orders });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getShopOrders = async (req, res) => {
  try {
    if (!req.user.roles.includes('admin')) {
      return res.status(403).json({ success: false, message: 'Only admins can view all orders' });
    }
    
    const orders = await Order.find()
      .populate('items.product', 'name images')
      .populate('customer', 'fullName phone')
      .sort('-createdAt');

    res.json({ success: true, count: orders.length, data: orders });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getOrderById = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id)
      .populate('items.product', 'name images price')
      .populate('customer', 'fullName phone email avatar');

    if (!order) return res.status(404).json({ success: false, message: 'Order not found' });

    // Trigger Casso Sync and check transactions if order is EMVCo and Unpaid
    if (order.paymentMethod === 'EMVCo' && order.paymentStatus === 'Unpaid') {
      await checkOrderPaymentWithCasso(order);
    }

    res.json({ success: true, data: order });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const updateOrderStatus = async (req, res) => {
  try {
    const { status, paymentStatus } = req.body;
    const order = await Order.findById(req.params.id);
    
    if (!order) return res.status(404).json({ success: false, message: 'Order not found' });

    if (!req.user.roles.includes('admin')) {
       return res.status(403).json({ success: false, message: 'Not authorized to update this order' });
    }

    if (status) order.status = status;
    
    // Automatically set paymentStatus to Paid if Delivered
    if (status === 'Delivered') {
      order.paymentStatus = 'Paid';
    } else if (paymentStatus) {
      order.paymentStatus = paymentStatus;
    }
    
    await order.save();

    // Reward points if order is delivered
    if (status === 'Delivered' && order.pointsEarned > 0) {
      const customer = await User.findById(order.customer);
      if (customer) {
        customer.points += order.pointsEarned;
        customer.totalEarnedPoints += order.pointsEarned;

        // Rank upgrade logic
        if (customer.totalEarnedPoints >= 2000000) customer.rank = 'VIP';
        else if (customer.totalEarnedPoints >= 500000) customer.rank = 'Gold';
        else if (customer.totalEarnedPoints >= 100000) customer.rank = 'Silver';

        await customer.save();
      }
    }

    // Create Notification
    let notificationType = 'SYSTEM';
    let message = `Your order status has been updated to ${status}.`;
    if (status === 'Confirmed') notificationType = 'ORDER_CONFIRMED';
    else if (status === 'Shipping') notificationType = 'ORDER_SHIPPING';
    else if (status === 'Delivered') {
      notificationType = 'ORDER_DELIVERED';
      if (order.pointsEarned > 0) message += ` You earned ${order.pointsEarned} CakeCoins!`;
    }

    await Notification.create({
      user: order.customer,
      title: `Order ${status}`,
      message,
      type: notificationType,
      orderId: order._id
    });

    // Notify customer in real-time
    const { emitToUser } = await import('../config/socket.js');
    emitToUser(order.customer.toString(), 'order_status_updated', {
      orderId: order._id,
      status,
      message
    });

    res.json({ success: true, data: order });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const cancelOrder = async (req, res) => {
  try {
    const { reason } = req.body;
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ success: false, message: 'Order not found' });
    if (order.customer.toString() !== req.user._id.toString() && !req.user.roles.includes('admin')) {
      return res.status(403).json({ success: false, message: 'Not authorized to cancel this order' });
    }
    
    order.note = `Cancelled. Reason: ${reason || ''}`;
    order.status = 'Canceled';
    await order.save();
    
    res.json({ success: true, message: 'Order cancelled successfully', data: order });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// Removed unneeded functions
export const extendOrder = async (req, res) => { res.status(400).json({ success: false }); };
export const confirmOrder = async (req, res) => { res.status(400).json({ success: false }); };
export const checkInOrder = async (req, res) => { res.status(400).json({ success: false }); };
export const checkOutOrder = async (req, res) => { res.status(400).json({ success: false }); };
export const getShopRevenue = async (req, res) => {
  try {
    if (!req.user.roles.includes('admin')) {
      return res.status(403).json({ success: false, message: 'Only admins can view revenue' });
    }

    const orders = await Order.find({
      $or: [{ status: 'Delivered' }, { paymentStatus: 'Paid' }]
    }).populate('items.product');

    let totalRevenue = 0;
    const productRevenue = {};

    orders.forEach(order => {
      totalRevenue += order.totalAmount;
      order.items.forEach(item => {
        if (item.product) {
          const productId = item.product._id.toString();
          if (!productRevenue[productId]) {
            productRevenue[productId] = {
              name: item.product.name,
              totalSold: 0,
              revenue: 0
            };
          }
          productRevenue[productId].totalSold += item.quantity;
          productRevenue[productId].revenue += (item.price * item.quantity);
        }
      });
    });

    const topProducts = Object.values(productRevenue).sort((a, b) => b.revenue - a.revenue);

    res.json({
      success: true,
      data: {
        totalRevenue,
        totalOrders: orders.length,
        topProducts
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
