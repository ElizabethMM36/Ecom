const express = require('express');
const router = express.Router();
const Order = require('../models/Order');
const crypto = require('crypto');
function validateWebhookSignature(body, signature, secret) {
    const expectedSignature = crypto.createHmac('sha256', secret)
        .update(JSON.stringify(body))
        .digest('hex');
    return signature === expectedSignature;
}

router.post('razorpay-webhook', async(req,res) => {
    const secret = process.env.RAZORPAY_WEBHOOK_SECRET;
     // Verify the webhook signature
     const isValid = validateWebhookSignature(req.body, req.headers['x-razorpay-signature'], secret);
     if (isValid) return res.status(400).send('Invalid signature');
     const {event , payload} = req.body;
     if(event === 'payment.captured'){
        const orderId = payload.payment.entity.order_id;
        const paymentId = payload.payment.entity.id;
    // put order in  EScrow
    const releaseINDays = 3;
    const releaseDate = new Date();
    releaseDate.setDate(releaseDate.getDate() + releaseINDays);
     }
     await Order.findOneAndUpdate({ razorpay_order_id: orderId }, {
        status: 'PAID_ESCROW',
        razorpay_payment_id: paymentId,
        escrow_release_date: releaseDate
     });
     res.json({ message: 'Webhook processed' });

})
module.exports = router;