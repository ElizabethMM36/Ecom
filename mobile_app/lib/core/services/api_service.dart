// lib/core/services/api_service.dart

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ApiService {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required int age,
    double? latitude,
    double? longitude,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/users/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': name,
            'email': email,
            'password': password,
            'phone': phone,
            'age': age,
            if (latitude != null) 'latitude': latitude,
            if (longitude != null) 'longitude': longitude,
          }),
        )
        .timeout(const Duration(seconds: 15));

    final data = _parseJson(response.body);

    if (response.statusCode == 201 && data['success'] == true) {
      return data;
    } else {
      throw Exception(data['error'] ?? 'Registration failed');
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    // Added a timeout and error handling for network connectivity
    final response = await http
        .post(
          Uri.parse('$_baseUrl/users/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () =>
              throw Exception('Connection timed out. Is the server running?'),
        );

    final data = _parseJson(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', data['token']);
      return data;
    } else {
      throw Exception(data['error'] ?? 'Login failed');
    }
  }

  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/users/profile/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['error'] ?? 'Failed to load profile');
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<Map<String, dynamic>> submitListing(
    ListingSubmission listing,
  ) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Not authenticated. Please log in.');
    }

    final uri = Uri.parse('$_baseUrl/products');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

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

    request.fields.addAll({
      'title': listing.title,
      'category': listing.category,
      'price': listing.price.toString(),
      'description': listing.description,
      'condition': listing.condition,
      if (listing.serialNumber?.isNotEmpty == true)
        'serialNumber': listing.serialNumber!,
      if (listing.location?.isNotEmpty == true) 'address': listing.location!,
      'aiImageVerified': listing.aiImageVerified.toString(),
      'aiBlurPassed': listing.aiBlurPassed.toString(),
      if (listing.aiObjectLabel?.isNotEmpty == true)
        'aiObjectLabel': listing.aiObjectLabel!,
      'aiImageCategory': listing.category,
    });

    if (listing.latitude != null && listing.longitude != null) {
      request.fields['latitude'] = listing.latitude.toString();
      request.fields['longitude'] = listing.longitude.toString();
    }

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

  // Cleaned up the JSON parsing to use the imported dart:convert directly

  static Map<String, dynamic> _parseJson(String body) {
    print("SERVER RESPONSE BODY: $body"); // <--- Add this line
    try {
      if (body.isEmpty) return {};
      return Map<String, dynamic>.from(jsonDecode(body) as Map);
    } catch (e) {
      return {'error': 'Invalid response: $e'};
    }
  }
}

class ListingSubmission {
  final String? imagePath;
  final String title;
  final String category;
  final double price;
  final String description;
  final String condition;
  final String? serialNumber;
  final String? location;
  final double? latitude;
  final double? longitude;
  final bool aiImageVerified;
  final bool aiBlurPassed;
  final String? aiObjectLabel;

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
