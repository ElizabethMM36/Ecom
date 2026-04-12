const cloudinary = require('cloudinary').v2;
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const multer = require('multer');
dotenv = require('dotenv');
dotenv.config();


// Configure Cloudinary with your credentials
cloudinary.config({
  cloud_name: process.env.cloud_name,
  api_key: process.env.api_key,
  api_secret: process.env.api_secret
});

// Set up the storage engine
const productStorage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: {
    folder: 'techhub_products', // The folder name in your Cloudinary account
    allowed_formats: ['jpg', 'png', 'jpeg', 'webp'],
    transformation: [{ width: 800, height: 800, crop: 'limit' }] // Auto-resize
  },
});
// Storage for User Profile Pictures
const profileStorage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: {
    folder: 'techhub_profiles', // Separate folder
    allowed_formats: ['jpg', 'png', 'jpeg'],
    transformation: [{ width: 400, height: 400, crop: 'thumb', gravity: 'face' }] // Auto-crop to face!
  },
});

const uploadProduct = multer({ storage: productStorage });
const uploadProfile = multer({ storage: profileStorage });


module.exports = { cloudinary, upload: uploadProduct, // Default export for products
    uploadProfile };