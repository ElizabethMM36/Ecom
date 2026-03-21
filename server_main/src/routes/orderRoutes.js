const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Order = require('../models/Order');
const Product = require('../models/Product');
const authMiddleware = require('../middleware/authMiddleware');
const razorpay = require('razorpay');
router.post('/orders/create', authMiddleware, async(res,req) => {
try{
    const {productId} = req.body;
    const product = await Product.findById(productId);
    const options = {
        amount: product.price * 100, // Amount in paise
        currency: "INR",
        receipt: `receipt_${Date.now()}`
    };
    const razorpayOrder = await razorpay.orders.create(options);
    const newOrder = new Order({
        buyerId : req.user.id,
        sellerId : product.sellerId,
        amount: product.price,
        paymentId: razorpayOrder.id,
        status: 'PENDING',
        
    });
    const savedOrder = await newOrder.save();
    res.json({ orderId: razorpayOrder.id, amount: options.amount });
    

}catch(error){
    res.status(500).json({ error: error.message }); 
}})
router.post('/orders/:id/release', authMiddleware, async(res,req) => {
    try{
        const order = await Order.findById(req.params.id);
        // Only buyer can release the funds early or Admin
        if ( order.buyerId.toString() !== req.user.id && req.user.role !== 'admin'){
            return res.status(401).json("Unauthorized");

        }
        if ( order.status !== 'PAID_ESCROW'){
            return res.status(400).json("Order not in escrow");
        }
        // Here we would call Razorpay's API to release the funds to the seller
        order.status = 'RELEASED';
        await order.save();
        res.json({ message: "Funds released to seller" });
    }catch(error){
        res.status(500).json({ error: error.message }); 
    }   
})
module.exports = router;