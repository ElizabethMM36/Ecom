/**
 * Location Utility Functions
 * Handles geolocation queries, distance calculations, and location validation
 */

const axios = require('axios');

// Validate location coordinates
const validateCoordinates = (longitude, latitude) => {
    if (typeof longitude !== 'number' || typeof latitude !== 'number') {
        throw new Error('Coordinates must be numbers');
    }
    if (latitude < -90 || latitude > 90) {
        throw new Error('Latitude must be between -90 and 90');
    }
    if (longitude < -180 || longitude > 180) {
        throw new Error('Longitude must be between -180 and 180');
    }
    return true;
};

// Convert coordinates to GeoJSON format used by MongoDB
const getGeoJSONPoint = (longitude, latitude) => {
    validateCoordinates(longitude, latitude);
    return {
        type: 'Point',
        coordinates: [longitude, latitude]
    };
};

// Calculate distance between two points (Haversine formula - returns km)
const calculateDistance = (coord1, coord2) => {
    const [lon1, lat1] = coord1;
    const [lon2, lat2] = coord2;
    
    const R = 6371; // Earth's radius in km
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    
    const a = 
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
    
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
};

// Reverse geocode coordinates to get address (using free API like nominatim)
const reverseGeocode = async (longitude, latitude) => {
    try {
        validateCoordinates(longitude, latitude);
        
        // Using OpenStreetMap's Nominatim API (free, no key required)
        const response = await axios.get('https://nominatim.openstreetmap.org/reverse', {
            params: {
                format: 'json',
                lat: latitude,
                lon: longitude,
            },
            headers: {
                'User-Agent': 'TechHubMarketplace_Elizabeth_v1 (elizabethmathew10d@gmail.com)',
            },

            timeout: 5000
        });

        if (response.data && response.data.address) {
            const addr = response.data.address;
            return {
                address: response.data.display_name,
                city: addr.city || addr.town || addr.village || 'Unknown',
                country: addr.country || 'Unknown',
                postalCode: addr.postcode || null
            };
        }
        return null;
    } catch (error) {
        console.error('Reverse geocoding error:', error.message);
        return null;
    }
};

// Geocode address to get coordinates
const geocodeAddress = async (address) => {
    try {
        if (!address || address.trim() === '') {
            throw new Error('Address cannot be empty');
        }

        // Using OpenStreetMap's Nominatim API
        const response = await axios.get('https://nominatim.openstreetmap.org/search', {
            params: {
                format: 'json',
                q: address,
                limit: 1
            },
            headers: {
                'User-Agent': 'TechHubMarketplace_Elizabeth_v1 (elizabethmathew10d@gmail.com)'
            },
            timeout: 5000
        });

        if (response.data && response.data.length > 0) {
            const result = response.data[0];
            return {
                longitude: parseFloat(result.lon),
                latitude: parseFloat(result.lat),
                address: result.display_name
            };
        }
        throw new Error('Address not found');
    } catch (error) {
        console.error('Geocoding error:', error.message);
        throw error;
    }
};

// Find products near a location
const getNearbyProducts = async (ProductModel, longitude, latitude, maxDistance = 50) => {
    try {
        validateCoordinates(longitude, latitude);
        
        const products = await ProductModel.find({
            'itemLocation.coordinates': {
                $near: {
                    $geometry: {
                        type: 'Point',
                        coordinates: [longitude, latitude]
                    },
                    $maxDistance: maxDistance * 1000 // Convert km to meters
                }
            },
            status: 'available',
            isFlagged: false
        }).populate('sellerId', 'name trustScore location');

        return products;
    } catch (error) {
        console.error('Nearby products search error:', error.message);
        throw error;
    }
};

// Find sellers near a location
const getNearBySellers = async (UserModel, longitude, latitude, maxDistance = 50) => {
    try {
        validateCoordinates(longitude, latitude);
        
        const sellers = await UserModel.find({
            'location.coordinates': {
                $near: {
                    $geometry: {
                        type: 'Point',
                        coordinates: [longitude, latitude]
                    },
                    $maxDistance: maxDistance * 1000 // Convert km to meters
                }
            },
            role: 'user',
            isVerified: true
        }).select('name email phone trustScore location');

        return sellers;
    } catch (error) {
        console.error('Nearby sellers search error:', error.message);
        throw error;
    }
};

// Calculate estimated delivery time based on distance (simplified)
const estimateDeliveryTime = (distanceKm) => {
    // Assuming average delivery speed of 30 km/hour with base processing time
    const hours = Math.ceil(distanceKm / 30) + 1; // +1 for processing/packing
    const date = new Date();
    date.setHours(date.getHours() + hours);
    return {
        estimatedDays: Math.ceil(hours / 24),
        estimatedDate: date,
        estimatedHours: hours
    };
};

// Format location for response
const formatLocationResponse = (location) => {
    if (!location) return null;
    
    return {
        coordinates: {
            latitude: location.coordinates[1],
            longitude: location.coordinates[0]
        },
        address: location.address || 'Address not available',
        city: location.city || null,
        postalCode: location.postalCode || null
    };
};

module.exports = {
    validateCoordinates,
    getGeoJSONPoint,
    calculateDistance,
    reverseGeocode,
    geocodeAddress,
    getNearbyProducts,
    getNearBySellers,
    estimateDeliveryTime,
    formatLocationResponse
};
