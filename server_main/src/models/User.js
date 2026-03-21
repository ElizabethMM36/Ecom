const mongoose = require('mongoose');
const userSchema = new mongoose.Schema({
    name: {type: String , required: true},
    email: {type: String , unique: true, required: true},
    password: {type: String, required: true},
    age:{ type: String , required: true},
    phone:{ type : String , required: true},
    role: { type: String, enum: ['user', 'admin'], default: 'user' },
    location: {
    type: { type: String, default: 'Point' },
    coordinates: { type: [Number], index: '2dsphere' }, // [Longitude, Latitude]
    address: String // Human-readable city/area name
  },
  trustScore: { type: Number, default: 0.5 }, // Updated by FastAPI later
  isVerified: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now }

})
module.exports = mongoose.model('User', userSchema);