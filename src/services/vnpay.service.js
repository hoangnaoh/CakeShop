import crypto from 'crypto';
import moment from 'moment';
import dotenv from 'dotenv';
dotenv.config();

export const createVNPayUrl = async (order, item, req) => {
  let ipAddr = req.headers['x-forwarded-for'] || 
               req.connection.remoteAddress || 
               req.socket.remoteAddress || 
               req.connection.socket.remoteAddress;

  if (!ipAddr || ipAddr === '::1') ipAddr = '127.0.0.1';

  const tmnCode = process.env.VNPAY_TMN_CODE;
  const secretKey = process.env.VNPAY_SECRET_KEY;
  let vnpUrl = process.env.VNPAY_URL || 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html';
  const returnUrl = `${process.env.CLIENT_URL}/payment/result`;

  const date = new Date();
  const createDate = moment(date).format('YYYYMMDDHHmmss');
  
  const expireDate = moment(date).add(15, 'minutes').format('YYYYMMDDHHmmss');

  const orderId = order._id.toString();
  const amount = order.pricing.totalAmount;
  const bankCode = ''; // Optional
  
  const currCode = 'VND';
  let vnp_Params = {};
  vnp_Params['vnp_Version'] = '2.1.0';
  vnp_Params['vnp_Command'] = 'pay';
  vnp_Params['vnp_TmnCode'] = tmnCode;
  // VNPay amount is multiplied by 100
  vnp_Params['vnp_Amount'] = amount * 100;
  if (bankCode) {
    vnp_Params['vnp_BankCode'] = bankCode;
  }
  vnp_Params['vnp_CreateDate'] = createDate;
  vnp_Params['vnp_CurrCode'] = currCode;
  vnp_Params['vnp_IpAddr'] = ipAddr;
  vnp_Params['vnp_Locale'] = 'vn';
  vnp_Params['vnp_OrderInfo'] = `Thanh toan don hang ${orderId}`;
  vnp_Params['vnp_OrderType'] = 'other';
  vnp_Params['vnp_ReturnUrl'] = returnUrl;
  vnp_Params['vnp_TxnRef'] = orderId; // Transaction Ref is OrderID
  vnp_Params['vnp_ExpireDate'] = expireDate;

  vnp_Params = sortObject(vnp_Params);

  const signData = new URLSearchParams(vnp_Params).toString();
  const hmac = crypto.createHmac('sha512', secretKey);
  const signed = hmac.update(new Buffer.from(signData, 'utf-8')).digest('hex'); 
  vnp_Params['vnp_SecureHash'] = signed;

  vnpUrl += '?' + new URLSearchParams(vnp_Params).toString();

  // Store transaction ref
  order.paymentSessionId = orderId;
  await order.save();

  return vnpUrl;
};

export const verifyVNPayIPN = (query) => {
  const secureHash = query.vnp_SecureHash;
  const secretKey = process.env.VNPAY_SECRET_KEY;

  delete query.vnp_SecureHash;
  delete query.vnp_SecureHashType;

  const sortedQuery = sortObject(query);
  const signData = new URLSearchParams(sortedQuery).toString();
  const hmac = crypto.createHmac('sha512', secretKey);
  const signed = hmac.update(new Buffer.from(signData, 'utf-8')).digest('hex');     
  
  if (secureHash === signed) {
    return { isSuccess: true, data: query };
  }
  return { isSuccess: false };
};

function sortObject(obj) {
  let sorted = {};
  let str = [];
  let key;
  for (key in obj) {
    if (obj.hasOwnProperty(key)) {
      str.push(encodeURIComponent(key));
    }
  }
  str.sort();
  for (key = 0; key < str.length; key++) {
    sorted[str[key]] = encodeURIComponent(obj[str[key]]).replace(/%20/g, '+');
  }
  return sorted;
}
