const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Product = require('../models/Product');
const Order = require('../models/Order');
const authMiddleware = require('../middleware/authMiddleware');
const locationUtils = require('../utils/locationUtils');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { upload } = require('../config/cloudinary');
// PATCH: Update Profile Picture
router.patch('/profile/image', authMiddleware, upload.single('profilePicture'), async (req, res) => {
    try {
        if (!req.file) return res.status(400).json({ error: "No image uploaded" });

        const user = await User.findByIdAndUpdate(
            req.user.id,
            { profilePicture: req.file.path }, // Cloudinary URL
            { new: true }
        ).select('-password');

        res.json({ success: true, profilePicture: user.profilePicture });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// POST: Register new user with optional location
router.post('/register', async (req, res) => {
    try {
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(req.body.password, salt);
        const { 
            name, 
            email, 
            password,
            age, 
            phone,
            // Optional location fields
            latitude,
            longitude,
            address,
            city
        } = req.body;

        // Validate required fields
        if (!name || !email || !password || !age || !phone) {
            return res.status(400).json({ error: 'Missing required fields' });
        }

        // Check if user already exists
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ error: 'Email already registered' });
        }

        let userLocation = null;

        // If location provided, validate and set it
        if (latitude && longitude) {
            locationUtils.validateCoordinates(longitude, latitude);
            
            let finalAddress = address;
            let finalCity = city;

            if (!address) {
                const geoData = await locationUtils.reverseGeocode(longitude, latitude);
                if (geoData) {
                    finalAddress = geoData.address;
                    finalCity = geoData.city;
                }
            }

            userLocation = {
                type: 'Point',
                coordinates: [longitude, latitude],
                address: finalAddress || 'Location provided',
                address: finalCity || 'Unknown'
            };
        }

        const newUser = new User({ 
            name, 
            email, 
            password: hashedPassword, 
            age, 
            phone,
            location: userLocation
        });

        const savedUser = await newUser.save();
        
        const response = savedUser.toObject();
        delete response.password;
        if (response.location) {
            response.location = locationUtils.formatLocationResponse(response.location);
        }

        res.status(201).json({ 
            success: true, 
            message: 'User registered successfully',
            user: response 
        });

    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});
// GET: Verify if the token is still valid
router.get('/verify-token', authMiddleware, (req, res) => {
    // If authMiddleware passes, req.user is populated
    res.json({ 
        success: true, 
        isLoggedIn: true, 
        user: req.user 
    });
});
// POST: Login
router.post('/login',  async (req, res) => {
    try {
        const { email, password } = req.body;

        const user = await User.findOne({email});
        if (!user) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        
        if (!user) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }
        const token = jwt.sign({ id: user._id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '7d' });
        res.json({ 
            success: true, 
            token, // Send this to Flutter
            user: { id: user._id, name: user.name, email: user.email }
        });

        const response = user.toObject();
        if (response.location) {
            response.location = locationUtils.formatLocationResponse(response.location);
        }

        

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET: User Profile with Listings and Location
router.get('/profile/:userId',authMiddleware, async (req, res) => {
    try {
        const user = await User.findById(req.params.userId).select('-password');

        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        // Get user's product listings
        const userListings = await Product.find({ 
            sellerId: req.params.userId,
            status: 'available'
        });

        const formattedListings = userListings.map(listing => {
            const obj = listing.toObject();
            obj.itemLocation = locationUtils.formatLocationResponse(listing.itemLocation);
            return obj;
        });

        const response = user.toObject();
        if (response.location) {
            response.location = locationUtils.formatLocationResponse(response.location);
        }

        res.json({
            success: true,
            user: response,
            statistics: {
                totalListings: userListings.length,
                trustScore: user.trustScore,
                isVerified: user.isVerified,
                memberSince: user.createdAt
            },
            listings: formattedListings
        });

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// PUT: Update User Location (set or update business location)
router.put('/location/:userId', authMiddleware, async (req, res) => {
    try {
        const { latitude, longitude, address, city } = req.body;

        // Check authorization
        if (req.params.userId !== req.user.id) {
            return res.status(401).json({ error: 'Unauthorized' });
        }

        if (!latitude || !longitude) {
            return res.status(400).json({ error: 'latitude and longitude are required' });
        }

        locationUtils.validateCoordinates(longitude, latitude);

        // Reverse geocode if address not provided
        let finalAddress = address;
        let finalCity = city;

        if (!address) {
            const geoData = await locationUtils.reverseGeocode(longitude, latitude);
            if (geoData) {
                finalAddress = geoData.address;
                finalCity = geoData.city;
            }
        }

        const updatedUser = await User.findByIdAndUpdate(
            req.params.userId,
            {
                location: {
                    type: 'Point',
                    coordinates: [longitude, latitude],
                    address: finalAddress || 'Location updated',
                    address: finalCity || 'Unknown'
                }
            },
            { new: true }
        ).select('-password');

        const response = updatedUser.toObject();
        if (response.location) {
            response.location = locationUtils.formatLocationResponse(response.location);
        }

        res.json({ 
            success: true, 
            message: 'Location updated successfully',
            user: response 
        });

    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

//  Geocode Address to Coordinates
router.post('/geocode', async (req, res) => {
    try {
        const { address } = req.body;

        if (!address) {
            return res.status(400).json({ error: 'address is required' });
        }

        const geoData = await locationUtils.geocodeAddress(address);

        res.json({
            success: true,
            location: {
                latitude: geoData.latitude,
                longitude: geoData.longitude,
                address: geoData.address
            }
        });

    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

//  Reverse Geocode Coordinates to Address
router.post('/reverse-geocode', async (req, res) => {
    try {
        const { latitude, longitude } = req.body;

        if (!latitude || !longitude) {
            return res.status(400).json({ error: 'latitude and longitude are required' });
        }

        locationUtils.validateCoordinates(longitude, latitude);

        const geoData = await locationUtils.reverseGeocode(longitude, latitude);

        if (!geoData) {
            return res.status(404).json({ error: 'Address not found for these coordinates' });
        }

        res.json({
            success: true,
            location: {
                latitude: latitude,
                longitude: longitude,
                ...geoData
            }
        });

    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

// GET: Find Sellers Near User Location
router.get('/sellers/nearby', async (req, res) => {
    try {
        const { latitude, longitude, maxDistance = 50 } = req.query;

        if (!latitude || !longitude) {
            return res.status(400).json({ error: 'latitude and longitude query parameters are required' });
        }

        const nearbySellers = await locationUtils.getNearBySellers(
            User,
            parseFloat(longitude),
            parseFloat(latitude),
            parseFloat(maxDistance)
        );

        const formattedSellers = nearbySellers.map(seller => {
            const obj = seller.toObject();
            delete obj.password;
            if (obj.location) {
                obj.location = locationUtils.formatLocationResponse(obj.location);
            }
            return obj;
        });

        res.json({
            success: true,
            radiusKm: maxDistance,
            count: formattedSellers.length,
            sellers: formattedSellers
        });

    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

// DELETE: Remove User Account (Admin/Self Only)
router.delete('/users/:userId', authMiddleware, async (req, res) => {
    try {
        // Check authorization - user can delete own account or admin can delete any
        if (req.params.userId !== req.user.id && req.user.role !== 'admin') {
            return res.status(401).json({ error: 'Unauthorized' });
        }

        // Check for active escrowed transactions
        const activeOrders = await Order.find({
            sellerId: req.params.userId,
            status: 'PAID_ESCROW'
        });

        if (activeOrders.length > 0) {
            return res.status(400).json({ 
                error: 'Cannot delete user with active escrowed transactions',
                activeOrders: activeOrders.length
            });
        }

        const deletedUser = await User.findByIdAndDelete(req.params.userId);

        res.json({ 
            success: true,
            message: 'User account deleted successfully',
            user: deletedUser.name
        });

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;

