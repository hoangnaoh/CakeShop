import crypto from 'crypto';
import axios from 'axios';
import moment from 'moment';
import dotenv from 'dotenv';
dotenv.config();

export const createZaloPayUrl = async (order, item) => {
  const config = {
    app_id: process.env.ZALOPAY_APP_ID || '2554',
    key1: process.env.ZALOPAY_KEY1 || 'sdngKKJmqEMzvh5QQcdD2A9XBSKUNaYn',
    key2: process.env.ZALOPAY_KEY2 || 'trMrHtvjo6myautxDUiAcYsVtaeQ8nhf',
    endpoint: process.env.ZALOPAY_ENDPOINT || 'https://sb-openapi.zalopay.vn/v2/create'
  };

  const app_trans_id = `${moment().format('YYMMDD')}_${Date.now()}`;
  
  const orderData = {
    app_id: config.app_id,
    app_trans_id, 
    app_user: 'user123',
    app_time: Date.now(), // miliseconds
    item: JSON.stringify([{ itemid: item._id, itemname: item.name, itemprice: order.pricing.totalAmount, itemquantity: 1 }]),
    embed_data: JSON.stringify({ redirecturl: `${process.env.CLIENT_URL}/payment/result` }),
    amount: order.pricing.totalAmount,
    description: `Thanh toan don hang #${app_trans_id}`,
    bank_code: 'zalopayapp',
  };

  const data = config.app_id + "|" + orderData.app_trans_id + "|" + orderData.app_user + "|" + orderData.amount + "|" + orderData.app_time + "|" + orderData.embed_data + "|" + orderData.item;
  orderData.mac = crypto.createHmac('sha256', config.key1).update(data).digest('hex');

  try {
    const res = await axios.post(config.endpoint, null, { params: orderData });
    // Store app_trans_id
    order.paymentSessionId = app_trans_id;
    await order.save();
    
    return res.data.order_url;
  } catch (error) {
    console.error('Error creating ZaloPay link:', error);
    throw new Error('Could not create ZaloPay payment link');
  }
};

export const verifyZaloPayWebhook = (webhookData) => {
  const config = { key2: process.env.ZALOPAY_KEY2 || 'trMrHtvjo6myautxDUiAcYsVtaeQ8nhf' };
  try {
    const reqMac = webhookData.mac;
    const dataStr = webhookData.data;

    const mac = crypto.createHmac('sha256', config.key2).update(dataStr).digest('hex');

    if (reqMac !== mac) {
      return { isSuccess: false };
    }
    const dataJson = JSON.parse(dataStr);
    return { isSuccess: true, data: dataJson };
  } catch (error) {
    return { isSuccess: false };
  }
};
