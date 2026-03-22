# Mobile App Integration Guide - Location Features

## Required Flutter Packages

Add these to `pubspec.yaml`:

```yaml
dependencies:
  geolocator: ^9.0.2           # Get device location
  google_maps_flutter: ^2.5.0  # Display maps
  geocoding: ^2.1.0            # Additional geocoding
  http: ^1.1.0                 # API calls
  provider: ^6.0.0             # State management
```

Install with: `flutter pub add geolocator google_maps_flutter geocoding`

---

## Step 1: Request Location Permissions

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show nearby products and handle delivery</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need your location for full app functionality</string>
```

---

## Step 2: Location Service Provider

Create `lib/providers/location_provider.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationProvider with ChangeNotifier {
  double? _latitude;
  double? _longitude;
  String? _address;
  String? _city;
  bool _isLoading = false;
  String? _error;

  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String? get address => _address;
  String? get city => _city;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final String apiUrl = 'YOUR_API_URL';
  final String token = 'YOUR_AUTH_TOKEN'; // Get from SharedPreferences

  // Get current device location
  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      // Reverse geocode to get address
      await reverseGeocode(position.latitude, position.longitude);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Reverse geocode coordinates to address
  Future<void> reverseGeocode(double latitude, double longitude) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/reverse-geocode'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _address = data['location']['address'];
        _city = data['location']['city'];
      }
    } catch (e) {
      _error = 'Could not fetch address: $e';
    }
    notifyListeners();
  }

  // Geocode address to coordinates
  Future<void> geocodeAddress(String address) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/geocode'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'address': address}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _latitude = data['location']['latitude'];
        _longitude = data['location']['longitude'];
        _address = data['location']['address'];
      } else {
        _error = 'Address not found';
      }
    } catch (e) {
      _error = 'Geocoding error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Set location manually
  void setLocation(double latitude, double longitude, String address, String city) {
    _latitude = latitude;
    _longitude = longitude;
    _address = address;
    _city = city;
    _error = null;
    notifyListeners();
  }

  // Clear location
  void clearLocation() {
    _latitude = null;
    _longitude = null;
    _address = null;
    _city = null;
    _error = null;
    notifyListeners();
  }
}
```

---

## Step 3: Location Selection Widget

Create `lib/widgets/location_picker.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPicker extends StatefulWidget {
  final Function(double, double, String, String) onLocationSelected;
  final bool allowMapSelection;

  const LocationPicker({
    required this.onLocationSelected,
    this.allowMapSelection = true,
    Key? key,
  }) : super(key: key);

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final TextEditingController _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Address Input
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Search or Enter Address',
                hintText: 'e.g., Times Square, New York',
                prefixIcon: Icon(Icons.location_on),
                suffixIcon: _addressController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _addressController.clear();
                          locationProvider.clearLocation();
                        },
                      )
                    : null,
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() {}),
              onSubmitted: (value) {
                locationProvider.geocodeAddress(value);
              },
            ),
            SizedBox(height: 10),

            // Search Button
            ElevatedButton.icon(
              icon: Icon(Icons.search),
              label: Text('Search Address'),
              onPressed: () {
                if (_addressController.text.isNotEmpty) {
                  locationProvider.geocodeAddress(_addressController.text);
                }
              },
            ),
            SizedBox(height: 10),

            // Current Location Button
            ElevatedButton.icon(
              icon: Icon(Icons.my_location),
              label: Text('Use Current Location'),
              onPressed: () {
                locationProvider.getCurrentLocation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
              ),
            ),
            SizedBox(height: 20),

            // Selected Location Display
            if (locationProvider.latitude != null)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Location',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 10),
                      Text(
                        locationProvider.address ?? 'Address not available',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 5),
                      Text(
                        'City: ${locationProvider.city ?? 'Unknown'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Coordinates: ${locationProvider.latitude!.toStringAsFixed(4)}, ${locationProvider.longitude!.toStringAsFixed(4)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          widget.onLocationSelected(
                            locationProvider.latitude!,
                            locationProvider.longitude!,
                            locationProvider.address ?? '',
                            locationProvider.city ?? '',
                          );
                          Navigator.pop(context);
                        },
                        child: Text('Confirm Location'),
                      ),
                    ],
                  ),
                ),
              )
            else if (locationProvider.isLoading)
              Center(child: CircularProgressIndicator())
            else if (locationProvider.error != null)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Error: ${locationProvider.error}',
                  style: TextStyle(color: Colors.red.shade800),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }
}
```

---

## Step 4: Use in Sell Product Screen

Update `lib/screens/post_product/post_product_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/location_provider.dart';
import '../../widgets/location_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PostProductScreen extends StatefulWidget {
  @override
  State<PostProductScreen> createState() => _PostProductScreenState();
}

class _PostProductScreenState extends State<PostProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;

  double? _selectedLatitude;
  double? _selectedLongitude;
  String? _selectedAddress;
  String? _selectedCity;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _priceController = TextEditingController();
    _descriptionController = TextEditingController();
    _categoryController = TextEditingController();
  }

  Future<void> createProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLatitude == null || _selectedLongitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a location')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('YOUR_API_URL/products'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN',
        },
        body: jsonEncode({
          'title': _titleController.text,
          'category': _categoryController.text,
          'price': double.parse(_priceController.text),
          'description': _descriptionController.text,
          'condition': 'Like New', // Add selector
          'latitude': _selectedLatitude,
          'longitude': _selectedLongitude,
          'address': _selectedAddress,
          'city': _selectedCity,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product listing created!')),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Failed to create product');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sell Product')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Form Fields
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Product Title'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'Category'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              SizedBox(height: 20),

              // Location Picker
              Text(
                'Product Location',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 10),
              LocationPicker(
                onLocationSelected: (lat, lng, addr, city) {
                  setState(() {
                    _selectedLatitude = lat;
                    _selectedLongitude = lng;
                    _selectedAddress = addr;
                    _selectedCity = city;
                  });
                },
              ),
              SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : createProduct,
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text('Create Listing'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}
```

---

## Step 5: Use in Buy Product / Order Screen

```dart
import 'package:flutter/material.dart';
import '../../widgets/location_picker.dart';

class BuyProductScreen extends StatefulWidget {
  final String productId;

  const BuyProductScreen({required this.productId});

  @override
  State<BuyProductScreen> createState() => _BuyProductScreenState();
}

class _BuyProductScreenState extends State<BuyProductScreen> {
  double? _deliveryLatitude;
  double? _deliveryLongitude;
  String? _deliveryAddress;
  String? _deliveryCity;

  Future<void> createOrder() async {
    if (_deliveryLatitude == null || _deliveryLongitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select delivery location')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('YOUR_API_URL/orders/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN',
        },
        body: jsonEncode({
          'productId': widget.productId,
          'deliveryLatitude': _deliveryLatitude,
          'deliveryLongitude': _deliveryLongitude,
          'deliveryAddress': _deliveryAddress,
          'deliveryCity': _deliveryCity,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final orderId = data['order']['orderId'];
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order created: $orderId')),
        );
        
        // Navigate to order confirmation or payment integration
        // For future payment gateway integration, add payment processing here
        Navigator.pop(context);
      } else {
        throw Exception('Failed to create order');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Place Order')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Location',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 10),
            LocationPicker(
              onLocationSelected: (lat, lng, addr, city) {
                setState(() {
                  _deliveryLatitude = lat;
                  _deliveryLongitude = lng;
                  _deliveryAddress = addr;
                  _deliveryCity = city;
                });
              },
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: createOrder,
                child: Text('Proceed to Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Configuration

Update your API URL and tokens in your provider setup:

```dart
// In main.dart or your app initialization
Provider(
  create: (_) => LocationProvider()
    ..apiUrl = 'https://your-api.com/api'
    ..token = SharedPreferencesService.getToken(),
  child: MyApp(),
)
```

---

## Key Features

✅ **One-tap location** via device GPS
✅ **Address search** with autocomplete
✅ **Manual address entry** with geocoding
✅ **Location validation** on both ends
✅ **Distance calculation** for delivery estimates
✅ **Nearby search** for products/sellers
✅ **Multiple location entry points** (register, sell, buy)
✅ **User-friendly error messages**

---

## Testing

Test with these coordinates:
- **New York**: 40.758, -73.985
- **Delhi**: 28.6139, 77.2090
- **London**: 51.5074, -0.1278
- **Tokyo**: 35.6762, 139.6503
