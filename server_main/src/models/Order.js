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
    // ── NEW: Payment & Escrow Details ──────────────────────────────────────
    paymentDetails: {
        method: { type: String, enum: ['CARD', 'WALLET', 'UPI', 'CASH', 'UNKNOWN'], default: 'UNKNOWN' },
        transactionId: { type: String, default: null },
        status: { 
            type: String, 
            enum: ['PENDING', 'HELD_IN_ESCROW', 'RELEASED_TO_SELLER', 'REFUNDED_TO_BUYER', 'FAILED'], 
            default: 'PENDING' 
        },
        paidAt: { type: Date }
    },

    escrowDetails: {
        status: { type: String, enum: ['PENDING', 'HELD', 'RELEASED', 'REFUNDED', 'DISPUTED'], default: 'PENDING' },
        releaseDate: { type: Date }, // Expected date funds unlock
        releasedAt: { type: Date }   // Actual date funds were transferred
    },

    // ── NEW: Dispute Management ────────────────────────────────────────────
    disputeDetails: {
        isDisputed: { type: Boolean, default: false },
        reason: { type: String, default: null }, // Why the buyer denied payment/delivery
        raisedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }, // Usually the buyer
        raisedAt: { type: Date },
        
        // Admin Resolution Fields
        adminResolution: { type: String, default: null }, // Notes from the admin
        resolvedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }, // Admin ID who fixed it
        resolvedAt: { type: Date }
    },
    
    // Tracking
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date, default: Date.now }
}, { timestamps: true });
// ── Indexes for fast Admin querying ────────────────────────────────────────
orderSchema.index({ status: 1 });
orderSchema.index({ 'escrowDetails.status': 1 });
orderSchema.index({ 'disputeDetails.isDisputed': 1 }); // Quickly find all disputed orders
module.exports = mongoose.model('Order', orderSchema);