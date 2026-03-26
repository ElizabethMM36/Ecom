const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
    sellerId:  {type: mongoose.Schema.Types.ObjectId, ref:'User',required: true},
    title:{type: String , required: true},
    category: { type: String, required: true},
    price: { type: Number, required: true },
    description: { type: String, required: true },
    images: [String],
    createdAt: { type: Date, default: Date.now },
    serialNumber: {type: String, default: null},
  condition: { type: String, enum: ['New', 'Like New', 'Used', 'Fair'] },
  itemLocation: {
    type: { type: String, default: 'Point' },
    coordinates: { type: [Number], index: '2dsphere' },
    address:     { type: String, default: 'Location provided' },
      city:        { type: String, default: 'Unknown' },
  },
     status: {
      type: String,
      enum: ['available', 'pending', 'hidden', 'under_review'],
      default: 'available',
    },
  // AI Segment Fields
  aiRiskScore: { type: Number, default: null, min: 0, max: 1, }, // 0 to 1 (calculated by FastAPI)
  isFlagged: { type: Boolean, default: false },
  riskCluster: {
    type:Number,
    enum: [0,1,2],
    default: null,
  },
  riskLabel: {type: String, enum:['Safe','Potential Scalper', 'Fraud Anomaly', 'Unanalyzed'],default:'Inanalyzed' },
riskAction: { type: String, enum:['allow','review','flag'], default:'allow'},
aiAnalyzedAt: {type: Date , default: null},
    // Raw FastAPI response stored for admin review / debugging
    aiRawResponse: { type: mongoose.Schema.Types.Mixed, default: null },
     
    // ── Camera / image quality flags (from Flutter Step 5 & 6) ──────────────
    // Flutter sends these after TFLite detection + blur check
    aiImageVerified: {type:Boolean , default: false},
    aiObjectLabel : {type: String, default: null},
    aiBlurPassed: {type:Boolean , default: false},
aiImageCategory:   { type: String,  default: null },   // expected category
 
    // ── Seller trust snapshot (frozen at order creation) ─────────────────────
    // These are copied from the User document so mid-transaction changes don't matter
    sellerSnapshot: {
      name:       { type: String, default: null },
      trustScore: { type: Number, default: null },
      isVerified: { type: Boolean, default: false },
    },
  },
  {
    timestamps: true, // adds createdAt + updatedAt automatically
  },
);
// ── Indexes ───────────────────────────────────────────────────────────────────
productSchema.index({ 'itemLocation': '2dsphere' });
productSchema.index({ status: 1, isFlagged: 1 });
productSchema.index({ sellerId: 1 });
productSchema.index({ riskCluster: 1 });
productSchema.index({ category: 1, status: 1 });

module.exports = mongoose.model('Product', productSchema);