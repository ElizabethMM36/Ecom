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

  // Nominatim Base URL
  final String apiUrl = 'https://nominatim.openstreetmap.org';

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

  // Corrected Reverse Geocode (Coordinates -> Address)
  Future<void> reverseGeocode(double lat, double lon) async {
    try {
      // Nominatim uses GET with lat/lon params
      final response = await http.get(
        Uri.parse(
          '$apiUrl/reverse?lat=$lat&lon=$lon&format=json&addressdetails=1',
        ),
        headers: {
          'User-Agent':
              'SecondShop_App_Project', // Required by Nominatim policy
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _address = data['display_name'];

        // Extract city/town/village safely
        var addr = data['address'];
        _city =
            addr['city'] ??
            addr['town'] ??
            addr['village'] ??
            addr['suburb'] ??
            'Unknown';
      }
    } catch (e) {
      _error = 'Could not fetch address: $e';
    }
    notifyListeners();
  }

  // Corrected Geocode (Address -> Coordinates)
  Future<void> geocodeAddress(String query) async {
    if (query.isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Nominatim uses GET with 'q' param
      final response = await http.get(
        Uri.parse(
          '$apiUrl/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=1',
        ),
        headers: {'User-Agent': 'SecondShop_App_Project'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          _latitude = double.parse(data[0]['lat']);
          _longitude = double.parse(data[0]['lon']);
          _address = data[0]['display_name'];

          var addr = data[0]['address'];
          _city = addr['city'] ?? addr['town'] ?? addr['village'] ?? 'Unknown';
        } else {
          _error = 'Location not found. Try being more specific.';
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Geocoding error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void setLocation(double lat, double lon, String addr, String cty) {
    _latitude = lat;
    _longitude = lon;
    _address = addr;
    _city = cty;
    _error = null;
    notifyListeners();
  }

  void clearLocation() {
    _latitude = null;
    _longitude = null;
    _address = null;
    _city = null;
    _error = null;
    notifyListeners();
  }
}
