const express = require('express');
const router = express.Router();
const User = require('../models/User');

const orderSchema = new mongoose.Schema({
    orderId: { type: String, required: true, unique: true },
    price:{type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true },

    status: {
        type: String,
        enum : ['PENDING', 'PAID_ESCROW', 'RELEASED', 'DISPUTED', 'REFUNDED'],
        default: 'PENDING'
    },
    razorpay_order_id: String,
    razorpay_payment_id: String,
    escrow_release_date: Date,
    buyerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    sellerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    productId: { type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true },
    createdAt: { type: Date, default: Date.now }

})
module.exports = mongoose.model('Order', orderSchema);