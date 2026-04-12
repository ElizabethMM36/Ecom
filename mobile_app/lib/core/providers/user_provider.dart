import 'package:flutter/material.dart';
import 'dart:convert';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  String? _token;

  Map<String, dynamic>? get user => _user;
  String? get token => _token;

  // Manual decoding logic to avoid 'jwt_decode' package
  void initializeFromToken(String token) {
    _token = token;
    try {
      final parts = token.split('.');
      if (parts.length == 3) {
        // The middle part is the payload
        String payload = parts[1];

        // Normalize Base64 (add padding if necessary)
        while (payload.length % 4 != 0) {
          payload += '=';
        }

        final String decoded = utf8.decode(base64Url.decode(payload));
        final Map<String, dynamic> data = jsonDecode(decoded);

        // Set the user map with the ID extracted from the token
        _user = {
          'id': data['id'] ?? data['sub'] ?? 'unknown',
          'name': 'User', // Placeholder until profile fetch
        };
      }
    } catch (e) {
      debugPrint("Error decoding token: $e");
      _user = {'id': 'unknown'};
    }
    notifyListeners();
  }

  void setUser(Map<String, dynamic> user, String token) {
    _user = user;
    _token = token;
    notifyListeners();
  }

  void logout() {
    _user = null;
    _token = null;
    notifyListeners();
  }
}
