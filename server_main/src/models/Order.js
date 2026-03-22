const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
    orderId: { type: String, required: true, unique: true },
    productId: { type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true },
    amount: { type: Number, required: true }, // Price of the product
    
    status: {
        type: String,
        enum : ['PENDING', 'CONFIRMED', 'SHIPPED', 'DELIVERED', 'CANCELLED', 'DISPUTED', 'REFUNDED'],
        default: 'PENDING'
    },
    
    // Payment Info - Order tracking without external payment gateway
    
    // User Info
    buyerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    sellerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    
    // Delivery Location
    deliveryLocation: {
        type: { type: String, default: 'Point' },
        coordinates: { type: [Number], index: '2dsphere' }, // [longitude, latitude]
        address: String,
        city: String,
        postalCode: String
    },
    
    // Seller's Business Location (captured at order time for reference)
    sellerLocation: {
        type: { type: String, default: 'Point' },
        coordinates: { type: [Number] },
        address: String,
        city: String
    },
    
    // Escrow Management
    escrow_release_date: Date,
    
    // Tracking
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date, default: Date.now }
}, { timestamps: true });

module.exports = mongoose.model('Order', orderSchema);