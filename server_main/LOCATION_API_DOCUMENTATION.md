# Location-Based E-Commerce API Documentation

## Overview
This backend supports easy location entry and management for buying and selling items. Users can enter locations when registering, updating profile, creating products, or placing orders.

---

## USER LOCATION MANAGEMENT

### 1. Register with Location
**Endpoint:** `POST /register`

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "securePassword123",
  "age": "28",
  "phone": "+91-9876543210",
  "latitude": 28.6139,
  "longitude": 77.2090,
  "address": "Delhi, India",
  "city": "Delhi"
}
```

**Note:** Location fields are optional. If `latitude`/`longitude` are provided, `address` and `city` will be auto-populated via reverse geocoding.

**Response:**
```json
{
  "success": true,
  "message": "User registered successfully",
  "user": {
    "_id": "userId123",
    "name": "John Doe",
    "email": "john@example.com",
    "location": {
      "coordinates": {
        "latitude": 28.6139,
        "longitude": 77.2090
      },
      "address": "Delhi, India",
      "city": "Delhi"
    }
  }
}
```

---

### 2. Update User Location
**Endpoint:** `PUT /location/:userId`

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "latitude": 28.6139,
  "longitude": 77.2090,
  "address": "Connaught Place, Delhi",
  "city": "Delhi"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Location updated successfully",
  "user": {
    "location": {
      "coordinates": {
        "latitude": 28.6139,
        "longitude": 77.2090
      },
      "address": "Connaught Place, Delhi",
      "city": "Delhi"
    }
  }
}
```

---

### 3. Geocode Address to Coordinates
**Endpoint:** `POST /geocode`

**Purpose:** Convert a street address to latitude/longitude

**Request Body:**
```json
{
  "address": "Times Square, New York, USA"
}
```

**Response:**
```json
{
  "success": true,
  "location": {
    "latitude": 40.758,
    "longitude": -73.9855,
    "address": "Times Square, New York, USA"
  }
}
```

---

### 4. Reverse Geocode Coordinates to Address
**Endpoint:** `POST /reverse-geocode`

**Purpose:** Convert latitude/longitude to a readable address

**Request Body:**
```json
{
  "latitude": 28.6139,
  "longitude": 77.2090
}
```

**Response:**
```json
{
  "success": true,
  "location": {
    "latitude": 28.6139,
    "longitude": 77.2090,
    "address": "Connaught Place, Delhi, India",
    "city": "Delhi",
    "country": "India",
    "postalCode": "110001"
  }
}
```

---

### 5. Get User Profile
**Endpoint:** `GET /profile/:userId`

**Response includes:**
- User details with location
- All active product listings with their locations
- User statistics (listings count, trust score, member since)

**Response:**
```json
{
  "success": true,
  "user": {
    "_id": "userId123",
    "name": "John Doe",
    "trustScore": 0.85,
    "location": {
      "coordinates": {
        "latitude": 28.6139,
        "longitude": 77.2090
      },
      "address": "Delhi, India",
      "city": "Delhi"
    }
  },
  "statistics": {
    "totalListings": 5,
    "trustScore": 0.85,
    "isVerified": true,
    "memberSince": "2024-01-15T10:30:00Z"
  },
  "listings": [...]
}
```

---

### 6. Find Nearby Sellers
**Endpoint:** `GET /sellers/nearby?latitude=28.6139&longitude=77.2090&maxDistance=50`

**Query Parameters:**
- `latitude` (required): Buyer's latitude
- `longitude` (required): Buyer's longitude
- `maxDistance` (optional, default: 50): Search radius in kilometers

**Response:**
```json
{
  "success": true,
  "radiusKm": 50,
  "count": 3,
  "sellers": [
    {
      "_id": "sellerId123",
      "name": "Local Seller",
      "email": "seller@example.com",
      "trustScore": 0.92,
      "location": {
        "coordinates": {
          "latitude": 28.6200,
          "longitude": 77.2100
        },
        "address": "Nearby Location",
        "city": "Delhi"
      }
    }
  ]
}
```

---

## PRODUCT LOCATION MANAGEMENT

### 7. Create Product with Location
**Endpoint:** `POST /products`

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "title": "iPhone 13 Pro",
  "category": "Electronics",
  "price": 79999,
  "description": "Excellent condition, 256GB, Space Gray",
  "images": ["url1", "url2"],
  "serialNumber": "SN123456",
  "condition": "Like New",
  "latitude": 28.6139,
  "longitude": 77.2090,
  "address": "Sector 12, Delhi",
  "city": "Delhi"
}
```

**Note:** If address is not provided, it will be auto-populated using reverse geocoding.

**Response:**
```json
{
  "success": true,
  "message": "Product created successfully with location",
  "product": {
    "_id": "productId123",
    "title": "iPhone 13 Pro",
    "price": 79999,
    "itemLocation": {
      "coordinates": {
        "latitude": 28.6139,
        "longitude": 77.2090
      },
      "address": "Sector 12, Delhi",
      "city": "Delhi"
    },
    "sellerId": {
      "name": "John Doe",
      "trustScore": 0.85
    }
  }
}
```

---

### 8. Get All Available Listings
**Endpoint:** `GET /listings`

**Response:**
```json
{
  "success": true,
  "count": 125,
  "listings": [
    {
      "_id": "productId123",
      "title": "iPhone 13 Pro",
      "price": 79999,
      "category": "Electronics",
      "itemLocation": {
        "coordinates": {
          "latitude": 28.6139,
          "longitude": 77.2090
        },
        "address": "Sector 12, Delhi",
        "city": "Delhi"
      },
      "sellerId": {
        "name": "John Doe",
        "trustScore": 0.85
      }
    }
  ]
}
```

---

### 9. Find Nearby Products (Location-Based Search)
**Endpoint:** `GET /listings/nearby?latitude=28.6139&longitude=77.2090&maxDistance=50`

**Query Parameters:**
- `latitude` (required): User's latitude
- `longitude` (required): User's longitude
- `maxDistance` (optional, default: 50): Search radius in kilometers

**Response:**
```json
{
  "success": true,
  "radiusKm": 50,
  "count": 18,
  "products": [
    {
      "_id": "productId123",
      "title": "iPhone 13 Pro",
      "price": 79999,
      "itemLocation": {
        "coordinates": {
          "latitude": 28.6139,
          "longitude": 77.2090
        },
        "address": "Sector 12, Delhi",
        "city": "Delhi"
      }
    }
  ]
}
```

---

### 10. Find Products by City
**Endpoint:** `GET /listings/city/:city`

Example: `GET /listings/city/Delhi`

**Response:**
```json
{
  "success": true,
  "city": "Delhi",
  "count": 45,
  "listings": [...]
}
```

---

### 11. Update Product Location
**Endpoint:** `PATCH /products/:productId/location`

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "latitude": 28.6200,
  "longitude": 77.2100,
  "address": "New Location, Delhi",
  "city": "Delhi"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Product location updated",
  "product": {
    "itemLocation": {
      "coordinates": {
        "latitude": 28.6200,
        "longitude": 77.2100
      },
      "address": "New Location, Delhi",
      "city": "Delhi"
    }
  }
}
```

---

## ORDER & DELIVERY LOCATION MANAGEMENT

### 12. Create Order with Delivery Location
**Endpoint:** `POST /orders/create`

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "productId": "productId123",
  "deliveryLatitude": 28.5900,
  "deliveryLongitude": 77.1950,
  "deliveryAddress": "Dwarka, Delhi",
  "deliveryCity": "Delhi",
  "postalCode": "110075"
}
```

**Response:**
```json
{
  "success": true,
  "order": {
    "orderId": "ORD_1705000000000_abc123",
    "amount": 79999,
    "deliveryLocation": {
      "coordinates": {
        "latitude": 28.5900,
        "longitude": 77.1950
      },
      "address": "Dwarka, Delhi",
      "city": "Delhi",
      "postalCode": "110075"
    },
    "sellerLocation": {
      "coordinates": {
        "latitude": 28.6139,
        "longitude": 77.2090
      },
      "address": "Sector 12, Delhi",
      "city": "Delhi"
    },
    "distanceKm": 8.5,
    "estimatedDelivery": {
      "estimatedDays": 1,
      "estimatedDate": "2024-01-20T14:30:00Z",
      "estimatedHours": 9
    },
    "productDetails": {
      "title": "iPhone 13 Pro",
      "price": 79999,
      "sellerName": "John Doe"
    },
    "status": "PENDING"
  }
}
```

---

### 13. Get Order Details
**Endpoint:** `GET /orders/:orderId`

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "order": {
    "orderId": "ORD_1705000000000_abc123",
    "status": "PENDING",
    "deliveryLocation": {
      "coordinates": {
        "latitude": 28.5900,
        "longitude": 77.1950
      },
      "address": "Dwarka, Delhi",
      "city": "Delhi"
    },
    "sellerLocation": {
      "coordinates": {
        "latitude": 28.6139,
        "longitude": 77.2090
      },
      "address": "Sector 12, Delhi",
      "city": "Delhi"
    },
    "buyerId": {...},
    "sellerId": {...},
    "productId": {...}
  }
}
```

---

### 14. Update Delivery Location (Before Payment)
**Endpoint:** `PATCH /orders/:orderId/delivery-location`

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "deliveryLatitude": 28.6000,
  "deliveryLongitude": 77.2000,
  "deliveryAddress": "Different Location, Delhi",
  "deliveryCity": "Delhi",
  "postalCode": "110001"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Delivery location updated",
  "order": {...}
}
```

---

### 15. Get User Orders
**Endpoint:** `GET /orders/user/all`

**Headers:**
```
Authorization: Bearer <token>
```

**Returns:** All orders where user is buyer or seller, with location information.

---

### 16. Release Escrow Funds
**Endpoint:** `POST /orders/:orderId/release`

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "message": "Funds released to seller",
  "order": {
    "status": "RELEASED",
    "escrow_release_date": "2024-01-21T10:30:00Z"
  }
}
```

---

### 17. Dispute Order
**Endpoint:** `POST /orders/:orderId/dispute`

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "reason": "Non-delivery",
  "description": "Product was not delivered within promised timeframe"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Order disputed. Admin will review within 24-48 hours",
  "order": {
    "status": "DISPUTED"
  }
}
```

---

## LOCATION UTILITIES

### Distance Calculation
The system automatically calculates distances between locations using the Haversine formula (great-circle distance).

### Delivery Time Estimation
Based on distance:
- Estimated speed: 30 km/hour
- Processing time: +1 hour
- Example: 8.5 km distance = 1.28 hours (rounded to 1 day delivery)

### Geolocation Quality
The system uses OpenStreetMap's Nominatim API for:
- Forward geocoding (address → coordinates)
- Reverse geocoding (coordinates → address)
- Free service, no API key required

---

## ERROR RESPONSES

### Invalid Coordinates
```json
{
  "error": "Latitude must be between -90 and 90"
}
```

### Missing Location
```json
{
  "error": "Delivery location (deliveryLatitude, deliveryLongitude) is required"
}
```

### Unauthorized
```json
{
  "error": "Unauthorized"
}
```

### Not Found
```json
{
  "error": "Order not found"
}
```

---

## FLOW EXAMPLES

### Flow 1: Register → Create Product → Sell
1. **Register** with location → User profile established
2. **Create Product** with location → Seller's inventory visible
3. **Update Location** if selling from different place
4. **Search Nearby** → Buyers find your products

### Flow 2: Search → Order → Delivery
1. **Get Nearby Products** based on buyer's location
2. **Create Order** with delivery address
3. **Update Delivery Location** if needed (before payment)
4. **Release Funds** after confirmed delivery

### Flow 3: Address Lookup
1. **Geocode Address** to get coordinates (for form inputs)
2. **Reverse Geocode** to auto-fill address (when coordinates provided)
3. Store in database automatically

---

## MOBILE APP INTEGRATION

### Flutter Client Setup
```dart
// Get user location
final position = await Geolocator.getCurrentPosition();

// Create product with location
final response = await http.post(
  Uri.parse('$API_URL/products'),
  headers: {'Authorization': 'Bearer $token'},
  body: jsonEncode({
    'title': 'iPhone',
    'price': 79999,
    'latitude': position.latitude,
    'longitude': position.longitude,
    // ... other fields
  }),
);

// Search nearby products
final nearbyResponse = await http.get(
  Uri.parse('$API_URL/listings/nearby?latitude=${position.latitude}&longitude=${position.longitude}&maxDistance=50'),
);

// Create order with delivery location
final orderResponse = await http.post(
  Uri.parse('$API_URL/orders/create'),
  headers: {'Authorization': 'Bearer $token'},
  body: jsonEncode({
    'productId': productId,
    'deliveryLatitude': position.latitude,
    'deliveryLongitude': position.longitude,
    // ... other fields
  }),
);
```

---

## PERMISSIONS & SECURITY

- Location data is accessible to users and admins only
- Only product owners can update product location
- Only order participants (buyer/seller) can view order locations
- Location data is stored with GeoJSON indexes for fast queries
- All location endpoints validate coordinates and format

---

## DATABASE INDEXES

The system automatically creates 2dsphere indexes on:
- `Product.itemLocation.coordinates`
- `User.location.coordinates`
- `Order.deliveryLocation.coordinates`

This enables efficient geospatial queries for finding nearby items/sellers.
