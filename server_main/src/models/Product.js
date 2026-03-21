const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
    sellerId:  {type: mongoose.Schema.Types.ObjectId, ref:'User',required: true},
    title:{type: String , required: true},
    category: { type: String, required: true},
    price: { type: Number, required: true },
    description: { type: String, required: true },
    images: [String],
    createdAt: { type: Date, default: Date.now },
    serialNumber: {String},
  condition: { type: String, enum: ['New', 'Like New', 'Used', 'Fair'] },
  
  // AI Segment Fields
  aiRiskScore: { type: Number, default: 0 }, // 0 to 1 (calculated by FastAPI)
  isFlagged: { type: Boolean, default: false },
  clusterId: Number, // Assigned by K-Means
status: { type: String, enum: ['available', 'sold', 'hidden'], default: 'available' }
}, { timestamps: true });