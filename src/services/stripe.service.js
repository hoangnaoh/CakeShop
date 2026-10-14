import Stripe from 'stripe';

const getStripe = () => {
  if (!process.env.STRIPE_SECRET_KEY) throw new Error('Stripe chưa được cấu hình. Hãy thêm STRIPE_SECRET_KEY trong file .env.');
  return new Stripe(process.env.STRIPE_SECRET_KEY);
};

export const createStripeCheckoutSession = async (order, product) => {
  const stripe = getStripe();
  const clientUrl = process.env.CLIENT_URL || 'http://localhost:5173';
  const session = await stripe.checkout.sessions.create({
    mode: 'payment',
    payment_method_types: ['card'],
    success_url: `${clientUrl}/payment/result?provider=stripe&status=success&orderId=${order._id}`,
    cancel_url: `${clientUrl}/payment/result?provider=stripe&status=cancelled&orderId=${order._id}`,
    metadata: { orderId: order._id.toString() },
    line_items: [{
      quantity: 1,
      price_data: {
        currency: 'vnd',
        unit_amount: Math.round(order.pricing.totalAmount),
        product_data: {
          name: product?.name || 'Fashion Rental Order',
          description: `${order.pricing.rentalDays} ngày thuê`,
          images: product?.images?.[0]?.url ? [product.images[0].url] : undefined,
        },
      },
    }],
  });

  return { sessionId: session.id, checkoutUrl: session.url, status: session.payment_status || 'pending' };
};

export const retrieveStripeCheckoutSession = async (sessionId) => {
  const stripe = getStripe();
  return stripe.checkout.sessions.retrieve(sessionId);
};

export const constructStripeWebhookEvent = (rawBody, signature) => {
  const stripe = getStripe();
  if (!process.env.STRIPE_WEBHOOK_SECRET) throw new Error('Stripe webhook secret is not configured');
  return stripe.webhooks.constructEvent(rawBody, signature, process.env.STRIPE_WEBHOOK_SECRET);
};
