import PayOSPackage from '@payos/node';
import dotenv from 'dotenv';
dotenv.config();

const PayOS = PayOSPackage.PayOS || PayOSPackage;

const payos = new PayOS(
  process.env.PAYOS_CLIENT_ID,
  process.env.PAYOS_API_KEY,
  process.env.PAYOS_CHECKSUM_KEY
);

export const createPayOSCheckoutUrl = async (order, item) => {
  const orderCode = Number(String(Date.now()).slice(-6)); 
  
  const body = {
    orderCode,
    amount: order.pricing.totalAmount,
    description: `Thanh toan don ${orderCode}`,
    items: [
      {
        name: item.name,
        quantity: 1,
        price: order.pricing.totalAmount,
      },
    ],
    returnUrl: `${process.env.CLIENT_URL}/payment/result`,
    cancelUrl: `${process.env.CLIENT_URL}/payment/result?cancel=true`,
  };

  try {
    const paymentLinkRes = await payos.createPaymentLink(body);
    // Store orderCode into the rentalOrder so we can verify it later in the webhook
    order.paymentSessionId = orderCode.toString();
    await order.save();
    return paymentLinkRes.checkoutUrl;
  } catch (error) {
    console.error('Error creating PayOS payment link:', error);
    throw new Error('Could not create PayOS payment link');
  }
};

export const verifyPayOSWebhook = (webhookData) => {
  return payos.verifyPaymentWebhookData(webhookData);
};
