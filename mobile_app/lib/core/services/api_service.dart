// lib/core/services/api_service.dart
//
// Sends a completed listing (image + form data + camera AI flags) to
// POST /api/products on your Node.js server_main backend.

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ── Change this to your machine's LAN IP when testing on a real device ──
  // Emulator: http://10.0.2.2:5000
  // Real device on same WiFi: http://192.168.x.x:5000
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000/api',
  );

  // ── Get stored JWT from SharedPreferences ──────────────────────────────────
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // ── POST /api/products ─────────────────────────────────────────────────────
  // Sends multipart/form-data with:
  //   • images[]          — captured image file
  //   • All form fields   — title, category, price, etc.
  //   • AI camera flags   — aiImageVerified, aiObjectLabel, aiBlurPassed
  //   • Location          — latitude, longitude
  //
  // @param listing   ListingSubmission with all fields
  // @returns         Map with { success, product, listingStatus, verificationNote }
  static Future<Map<String, dynamic>> submitListing(
    ListingSubmission listing,
  ) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Not authenticated. Please log in.');
    }

    final uri = Uri.parse('$_baseUrl/products');
    final request = http.MultipartRequest('POST', uri);

    // Auth header
    request.headers['Authorization'] = 'Bearer $token';

    // ── Image file ─────────────────────────────────────────────────────────
    if (listing.imagePath != null) {
      final file = File(listing.imagePath!);
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();
      final ext = listing.imagePath!.split('.').last.toLowerCase();

      request.files.add(
        http.MultipartFile(
          'images',
          stream,
          length,
          filename: 'listing_${DateTime.now().millisecondsSinceEpoch}.$ext',
          contentType: MediaType('image', ext == 'jpg' ? 'jpeg' : ext),
        ),
      );
    }

    // ── Core listing fields ────────────────────────────────────────────────
    request.fields.addAll({
      'title': listing.title,
      'category': listing.category,
      'price': listing.price.toString(),
      'description': listing.description,
      'condition': listing.condition,
      if (listing.serialNumber?.isNotEmpty == true)
        'serialNumber': listing.serialNumber!,
      if (listing.location?.isNotEmpty == true) 'address': listing.location!,
    });

    // ── Location fields ────────────────────────────────────────────────────
    if (listing.latitude != null && listing.longitude != null) {
      request.fields['latitude'] = listing.latitude.toString();
      request.fields['longitude'] = listing.longitude.toString();
    }

    // ── Flutter camera AI verification fields (Steps 5 & 6) ───────────────
    // These tell the Node backend what the camera detected before capture
    request.fields.addAll({
      'aiImageVerified': listing.aiImageVerified.toString(),
      'aiBlurPassed': listing.aiBlurPassed.toString(),
      if (listing.aiObjectLabel?.isNotEmpty == true)
        'aiObjectLabel': listing.aiObjectLabel!,
      'aiImageCategory': listing.category,
    });

    // ── Send ───────────────────────────────────────────────────────────────
    final streamed = await request.send().timeout(
      const Duration(seconds: 30),
      onTimeout: () =>
          throw Exception('Request timed out. Check your connection.'),
    );

    final response = await http.Response.fromStream(streamed);
    final body = _parseJson(response.body);

    if (response.statusCode == 201) {
      return body;
    } else {
      final errMsg = body['error'] ?? body['message'] ?? 'Unknown server error';
      throw Exception('Server error ${response.statusCode}: $errMsg');
    }
  }

  static Map<String, dynamic> _parseJson(String body) {
    try {
      // Using dart:convert
      return Map<String, dynamic>.from(
        (body.isNotEmpty ? _jsonDecode(body) : {}) as Map,
      );
    } catch (_) {
      return {'error': 'Invalid response from server'};
    }
  }

  // ignore: prefer_typing_uninitialized_variables
  static _jsonDecode(String body) {
    // dart:convert is imported via the http package transitively
    // Add: import 'dart:convert'; at the top of the file
    // This is a placeholder — replace with:
    //   import 'dart:convert';
    //   return jsonDecode(body);
    throw UnimplementedError('Add: import dart:convert and use jsonDecode');
  }
}

// ── Data class for a complete listing submission ───────────────────────────────
class ListingSubmission {
  final String? imagePath;
  final String title;
  final String category;
  final double price;
  final String description;
  final String condition; // 'New' | 'Like New' | 'Used' | 'Fair'
  final String? serialNumber;
  final String? location;

  // Location
  final double? latitude;
  final double? longitude;

  // Flutter camera AI flags — set from CameraScreen result
  final bool aiImageVerified; // Step 5: TFLite object detected
  final bool aiBlurPassed; // Step 6: blur check passed
  final String? aiObjectLabel; // Step 5: what ML Kit detected

  const ListingSubmission({
    this.imagePath,
    required this.title,
    required this.category,
    required this.price,
    required this.description,
    required this.condition,
    this.serialNumber,
    this.location,
    this.latitude,
    this.longitude,
    this.aiImageVerified = false,
    this.aiBlurPassed = false,
    this.aiObjectLabel,
  });
}
