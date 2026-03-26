const express = require('express');
const router = express.Router();
const Product = require('../models/Product');
const authMiddleware = require('../middleware/authMiddleware');
const User = require('../models/User');
const locationUtils = require('../utils/locationUtils');
const { upload } = require('../config/cloudinary');
 
// ── NEW: import the AI analysis service ──────────────────────────────────────
const { analyzeListingRisk, healthCheck } = require('../services/aiAnalysisService');
 
// ─────────────────────────────────────────────────────────────────────────────
// POST /api/products
// Creates a new listing, runs AI risk analysis, saves everything atomically.
// Flutter sends: multipart/form-data with images + JSON fields in body.
// ─────────────────────────────────────────────────────────────────────────────
// CREATE: New Product with Location
router.post('/products', authMiddleware, upload.array('images', 5), async (req, res) => {
    const imageUrls = req.files ? req.files.map(file => file.path) : [];
    try {
        const { 
            title, 
            category, 
            price, 
            description, 
            serialNumber, 
            condition,
            // Location Fields
            latitude,
            longitude,
            address,
            city,
            aiImageVerified,// boolean — object detection matched the category
            aiObjectLabel,  // string  — e.g. "cell phone", "chair"
            aiBlurPassed,   // boolean — Laplacian variance passed threshold
            aiImageCategory, // string  — the category Flutter was checking for

        } = req.body;

        // Validate required fields
        if (!title || !category || !price || !description|| !condition) {
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
    // ── 3. Fetch seller info for AI analysis + snapshot ──────────────────────
    const seller = await User.findById(req.user.id).select('Name trustScore is Verified CreatedAt');
    if (!seller){
        return res.status(404).json({error:'Seller account not found'});
    }
 const daysActive = Math.floor((Date.now() - new Date(seller.createdAt).getTime())/(1000*60*60*24));
 
    // ── 4. AI Risk Analysis (Step 9) — async, non-blocking to UX ────────────
    //    analyzeListingRisk never throws; it returns a safe fallback if FastAPI is down
    const aiResult = await analyzeListingRisk({
        price,
      condition,
      sellerRating: seller.trustScore ?? 0,
      daysActive,

    })
    
    // ── 5. Admin alert if flagged as fraud ───────────────────────────────────
    if (aiResult.isFlagged) {
      console.warn(
        `[FRAUD FLAG] Listing "${title}" by seller ${req.user.id}` +
        ` — Risk: ${aiResult.riskLabel} | Cluster: ${aiResult.clusterId}`
      );
      // TODO: push notification to admin dashboard via socket.io / email
    }
 
    // ── 6. Build and save Product document ──────────────────────────────────
        const newProduct = new Product({
            sellerId: req.user.id,
            title,
            category,
            price,
            description,
            images: imageUrls,
            serialNumber: serialNumber || null,
            condition,
            // Store location in GeoJSON format for geographical queries
            itemLocation: {
                type: 'Point',
                coordinates: [longitude, latitude],
                address: finalAddress || 'Location provided',
                city: finalCity || 'Unknown'
            },

           status: aiResult.status || 'available',

          // ── AI Risk fields (from FastAPI) ──────────────────────────────────────
      riskCluster:   aiResult.riskCluster,
      riskLabel:     aiResult.riskLabel,
      riskAction:    aiResult.riskAction,
      aiRiskScore:   aiResult.aiRiskScore,
      isFlagged:     aiResult.isFlagged,
      aiAnalyzedAt:  aiResult.aiAnalyzedAt,
      aiRawResponse: aiResult.aiRawResponse,
 
      // ── Flutter camera verification fields (Steps 5 & 6) ──────────────────
      aiImageVerified: aiImageVerified === 'true' || aiImageVerified === true,
      aiObjectLabel:   aiObjectLabel   || null,
      aiBlurPassed:    aiBlurPassed    === 'true' || aiBlurPassed === true,
      aiImageCategory: aiImageCategory || category,
 
      // ── Seller snapshot (frozen for escrow safety) ────────────────────────
      sellerSnapshot: {
        name:       seller.name,
        trustScore: seller.trustScore,
        isVerified: seller.isVerified,
      },

        });

        const savedProduct = await newProduct.save();
        
        // Populate seller info
        await savedProduct.populate('sellerId', 'name trustScore location');

        // Return formatted response with readable location
        const response = savedProduct.toObject();
        response.itemLocation = locationUtils.formatLocationResponse(savedProduct.itemLocation);

         // ── 7. Response ───────────────────────────────────────────────────────────
    return res.status(201).json({
      success: true,
      product: response,
      message: aiResult.success
        ? `Product created. Risk assessment: ${aiResult.riskLabel}`
        : 'Product created. AI analysis pending.',
      // Only expose non-sensitive risk info to client
      listingStatus:    savedProduct.status,
      verificationNote: aiResult.isFlagged
        ? 'Your listing is under review. We will notify you shortly.'
        : null,
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
router.post('/listings/nearby', async (req, res) => {
    try {
        const { latitude, longitude, maxDistance = 50 } = req.body;

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
router.get('/admin/ai-status', authMiddleware, async (req, res) => {
  const status = await healthCheck();
  res.json({
    aiService: status.online ? 'online' : 'offline',
    details:   status.data   || null,
  });
});

module.exports = router;