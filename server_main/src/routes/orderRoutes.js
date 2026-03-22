const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Order = require('../models/Order');
const Product = require('../models/Product');
const authMiddleware = require('../middleware/authMiddleware');
const locationUtils = require('../utils/locationUtils');

// CREATE: New Order with Delivery Location
router.post('/orders/create', authMiddleware, async (req, res) => {
    try {
        const { 
            productId,
            // Delivery Location - where buyer wants it delivered
            deliveryLatitude,
            deliveryLongitude,
            deliveryAddress,
            deliveryCity,
            postalCode
        } = req.body;

        // Validate required fields
        if (!productId) {
            return res.status(400).json({ error: 'productId is required' });
        }

        if (!deliveryLatitude || !deliveryLongitude) {
            return res.status(400).json({ error: 'Delivery location (deliveryLatitude, deliveryLongitude) is required' });
        }

        // Validate coordinates
        locationUtils.validateCoordinates(deliveryLongitude, deliveryLatitude);

        // Get product details
        const product = await Product.findById(productId).populate('sellerId', 'name location');
        if (!product) {
            return res.status(404).json({ error: 'Product not found' });
        }

        // Prevent buying own product
        if (product.sellerId._id.toString() === req.user.id) {
            return res.status(400).json({ error: 'Cannot buy your own product' });
        }

        // Get buyer's user info
        const buyer = await User.findById(req.user.id);

        // Reverse geocode delivery location if address not provided
        let finalDeliveryAddress = deliveryAddress;
        let finalDeliveryCity = deliveryCity;

        if (!deliveryAddress) {
            const geoData = await locationUtils.reverseGeocode(deliveryLongitude, deliveryLatitude);
            if (geoData) {
                finalDeliveryAddress = geoData.address;
                finalDeliveryCity = geoData.city;
            }
        }

        // Calculate distance between seller and buyer for logistics
        const distanceKm = locationUtils.calculateDistance(
            product.itemLocation.coordinates,
            [deliveryLongitude, deliveryLatitude]
        );

        const deliveryEstimate = locationUtils.estimateDeliveryTime(distanceKm);

        // Create Order in database
        const orderId = `ORD_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
        const newOrder = new Order({
            orderId: orderId,
            productId: productId,
            amount: product.price,
            buyerId: req.user.id,
            sellerId: product.sellerId._id,
            
            // Delivery Location
            deliveryLocation: {
                type: 'Point',
                coordinates: [deliveryLongitude, deliveryLatitude],
                address: finalDeliveryAddress || 'Delivery location provided',
                city: finalDeliveryCity || 'Unknown',
                postalCode: postalCode || null
            },
            
            // Seller's location at time of order
            sellerLocation: {
                type: 'Point',
                coordinates: product.itemLocation.coordinates,
                address: product.itemLocation.address,
                city: product.itemLocation.city
            },
            
            status: 'PENDING'
        });

        const savedOrder = await newOrder.save();

        res.status(201).json({
            success: true,
            order: {
                orderId: savedOrder.orderId,
                amount: product.price,
                deliveryLocation: locationUtils.formatLocationResponse(savedOrder.deliveryLocation),
                distanceKm: Math.round(distanceKm * 10) / 10,
                estimatedDelivery: deliveryEstimate,
                productDetails: {
                    title: product.title,
                    price: product.price,
                    sellerName: product.sellerId.name
                },
                status: savedOrder.status
            }
        });

    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

// GET: Order Details with Location Info
router.get('/orders/:id', authMiddleware, async (req, res) => {
    try {
        const order = await Order.findById(req.params.id)
            .populate('productId', 'title category price images')
            .populate('buyerId', 'name email phone')
            .populate('sellerId', 'name email phone location');

        if (!order) {
            return res.status(404).json({ error: 'Order not found' });
        }

        // Check authorization
        if (order.buyerId._id.toString() !== req.user.id && 
            order.sellerId._id.toString() !== req.user.id &&
            req.user.role !== 'admin') {
            return res.status(401).json({ error: 'Unauthorized' });
        }

        const response = order.toObject();
        response.deliveryLocation = locationUtils.formatLocationResponse(order.deliveryLocation);
        response.sellerLocation = locationUtils.formatLocationResponse(order.sellerLocation);

        res.json({ success: true, order: response });

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET: Orders for User (Buyer or Seller)
router.get('/orders/user/all', authMiddleware, async (req, res) => {
    try {
        const orders = await Order.find({
            $or: [
                { buyerId: req.user.id },
                { sellerId: req.user.id }
            ]
        })
            .populate('productId', 'title category price images')
            .populate('buyerId', 'name email')
            .populate('sellerId', 'name email')
            .sort({ createdAt: -1 });

        const formattedOrders = orders.map(order => {
            const obj = order.toObject();
            obj.deliveryLocation = locationUtils.formatLocationResponse(order.deliveryLocation);
            obj.sellerLocation = locationUtils.formatLocationResponse(order.sellerLocation);
            return obj;
        });

        res.json({ success: true, count: formattedOrders.length, orders: formattedOrders });

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// PATCH: Update Delivery Location (before payment)
router.patch('/orders/:id/delivery-location', authMiddleware, async (req, res) => {
    try {
        const { 
            deliveryLatitude, 
            deliveryLongitude, 
            deliveryAddress, 
            deliveryCity,
            postalCode 
        } = req.body;

        const order = await Order.findById(req.params.id);

        if (!order) {
            return res.status(404).json({ error: 'Order not found' });
        }

        // Only buyer can update delivery location before payment
        if (order.buyerId.toString() !== req.user.id) {
            return res.status(401).json({ error: 'Unauthorized' });
        }

        if (order.status !== 'PENDING') {
            return res.status(400).json({ error: 'Cannot update location after payment' });
        }

        if (!deliveryLatitude || !deliveryLongitude) {
            return res.status(400).json({ error: 'deliveryLatitude and deliveryLongitude are required' });
        }

        locationUtils.validateCoordinates(deliveryLongitude, deliveryLatitude);

        // Reverse geocode if address not provided
        let finalAddress = deliveryAddress;
        let finalCity = deliveryCity;

        if (!deliveryAddress) {
            const geoData = await locationUtils.reverseGeocode(deliveryLongitude, deliveryLatitude);
            if (geoData) {
                finalAddress = geoData.address;
                finalCity = geoData.city;
            }
        }

        order.deliveryLocation = {
            type: 'Point',
            coordinates: [deliveryLongitude, deliveryLatitude],
            address: finalAddress || 'Updated location',
            city: finalCity || 'Unknown',
            postalCode: postalCode || null
        };

        await order.save();

        const response = order.toObject();
        response.deliveryLocation = locationUtils.formatLocationResponse(order.deliveryLocation);

        res.json({ 
            success: true, 
            message: 'Delivery location updated',
            order: response 
        });

    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

// POST: Release Funds from Escrow (after delivery confirmation)
router.post('/orders/:id/release', authMiddleware, async (req, res) => {
    try {
        const order = await Order.findById(req.params.id);

        if (!order) {
            return res.status(404).json({ error: 'Order not found' });
        }

        // Only buyer can confirm order or Admin
        if (order.buyerId.toString() !== req.user.id && req.user.role !== 'admin') {
            return res.status(401).json({ error: 'Unauthorized' });
        }

        if (order.status !== 'PENDING') {
            return res.status(400).json({ error: 'Order is not in pending status' });
        }

        // Update order status to confirmed (ready for delivery)
        order.status = 'CONFIRMED';
        order.escrow_release_date = new Date();
        await order.save();

        res.json({ 
            success: true,
            message: 'Order confirmed and ready for delivery',
            order: order 
        });

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// POST: Dispute Order (buyer claims non-delivery or issues)
router.post('/orders/:id/dispute', authMiddleware, async (req, res) => {
    try {
        const { reason, description } = req.body;
        const order = await Order.findById(req.params.id);

        if (!order) {
            return res.status(404).json({ error: 'Order not found' });
        }

        if (order.buyerId.toString() !== req.user.id) {
            return res.status(401).json({ error: 'Only buyer can dispute an order' });
        }

        if (['RELEASED', 'REFUNDED', 'DISPUTED'].includes(order.status)) {
            return res.status(400).json({ error: 'Order cannot be disputed in current status' });
        }

        order.status = 'DISPUTED';
        await order.save();

        // TODO: Create a dispute ticket in the system
        // TODO: Notify seller and admin

        res.json({ 
            success: true,
            message: 'Order disputed. Admin will review within 24-48 hours',
            order: order 
        });

    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

module.exports = router;