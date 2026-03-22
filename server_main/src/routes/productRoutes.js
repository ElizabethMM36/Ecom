const express = require('express');
const router = express.Router();
const Product = require('../models/Product');
const authMiddleware = require('../middleware/authMiddleware');
const User = require('../models/User');
const locationUtils = require('../utils/locationUtils');

// CREATE: New Product with Location
router.post('/products', authMiddleware, async (req, res) => {
    try {
        const { 
            title, 
            category, 
            price, 
            description, 
            images, 
            serialNumber, 
            condition,
            // Location Fields
            latitude,
            longitude,
            address,
            city
        } = req.body;

        // Validate required fields
        if (!title || !category || !price || !description) {
            return res.status(400).json({ error: 'Missing required fields: title, category, price, description' });
        }

        // Validate and format location
        if (!latitude || !longitude) {
            return res.status(400).json({ error: 'Location coordinates (latitude, longitude) are required' });
        }

        locationUtils.validateCoordinates(longitude, latitude);

        // Reverse geocode to get full address if not provided
        let finalAddress = address;
        let finalCity = city;
        
        if (!address) {
            const geoData = await locationUtils.reverseGeocode(longitude, latitude);
            if (geoData) {
                finalAddress = geoData.address;
                finalCity = geoData.city;
            }
        }

        const newProduct = new Product({
            sellerId: req.user.id,
            title,
            category,
            price,
            description,
            images,
            serialNumber,
            condition,
            // Store location in GeoJSON format for geographical queries
            itemLocation: {
                type: 'Point',
                coordinates: [longitude, latitude],
                address: finalAddress || 'Location provided',
                city: finalCity || 'Unknown'
            }
        });

        const savedProduct = await newProduct.save();
        
        // Populate seller info
        await savedProduct.populate('sellerId', 'name trustScore location');

        // Return formatted response with readable location
        const response = savedProduct.toObject();
        response.itemLocation = locationUtils.formatLocationResponse(savedProduct.itemLocation);

        /* FUTURE STEP: 
           axios.post('FASTAPI_URL/analyze', { price, category, sellerId })
           .then(res => update Product with aiRiskScore)
        */
        res.status(201).json({ 
            success: true, 
            product: response,
            message: 'Product created successfully with location'
        });

    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

// GET: All Available Listings
router.get('/listings', async (req, res) => {
    try {
        // Only show products that aren't flagged as high-risk fraud
        const listings = await Product.find({ 
            status: 'available', 
            isFlagged: false 
        }).populate('sellerId', 'name trustScore location');
        
        // Format locations in response
        const formattedListings = listings.map(listing => {
            const obj = listing.toObject();
            obj.itemLocation = locationUtils.formatLocationResponse(listing.itemLocation);
            return obj;
        });

        res.json({ success: true, count: formattedListings.length, listings: formattedListings });

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET: Nearby Products (Location-based Search)
router.get('/listings/nearby', async (req, res) => {
    try {
        const { latitude, longitude, maxDistance = 50 } = req.query;

        if (!latitude || !longitude) {
            return res.status(400).json({ error: 'latitude and longitude query parameters are required' });
        }

        const nearbyProducts = await locationUtils.getNearbyProducts(
            Product,
            parseFloat(longitude),
            parseFloat(latitude),
            parseFloat(maxDistance)
        );

        // Format locations in response
        const formattedProducts = nearbyProducts.map(product => {
            const obj = product.toObject();
            obj.itemLocation = locationUtils.formatLocationResponse(product.itemLocation);
            return obj;
        });

        res.json({ 
            success: true, 
            count: formattedProducts.length,
            radiusKm: maxDistance,
            products: formattedProducts 
        });

    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

// GET: Products by City
router.get('/listings/city/:city', async (req, res) => {
    try {
        const { city } = req.params;

        const listings = await Product.find({
            'itemLocation.city': new RegExp(city, 'i'),
            status: 'available',
            isFlagged: false
        }).populate('sellerId', 'name trustScore location');

        // Format locations in response
        const formattedListings = listings.map(listing => {
            const obj = listing.toObject();
            obj.itemLocation = locationUtils.formatLocationResponse(listing.itemLocation);
            return obj;
        });

        res.json({ 
            success: true, 
            city: city, 
            count: formattedListings.length, 
            listings: formattedListings 
        });

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// PATCH: Remove a Product (Soft Delete)
router.patch('/products/:id/remove', authMiddleware, async (req, res) => {
    try {
        const product = await Product.findById(req.params.id);
        
        if (!product) {
            return res.status(404).json({ error: 'Product not found' });
        }

        if (product.sellerId.toString() !== req.user.id) {
            return res.status(401).json({ error: 'Unauthorized' });
        }

        product.status = 'hidden';
        await product.save();

        res.json({ success: true, message: 'Product removed from marketplace' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// PATCH: Update Product Location
router.patch('/products/:id/location', authMiddleware, async (req, res) => {
    try {
        const { latitude, longitude, address, city } = req.body;
        const product = await Product.findById(req.params.id);

        if (!product) {
            return res.status(404).json({ error: 'Product not found' });
        }

        if (product.sellerId.toString() !== req.user.id) {
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

        product.itemLocation = {
            type: 'Point',
            coordinates: [longitude, latitude],
            address: finalAddress || 'Location updated',
            city: finalCity || 'Unknown'
        };

        await product.save();
        
        const response = product.toObject();
        response.itemLocation = locationUtils.formatLocationResponse(product.itemLocation);

        res.json({ success: true, product: response, message: 'Product location updated' });

    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

module.exports = router;