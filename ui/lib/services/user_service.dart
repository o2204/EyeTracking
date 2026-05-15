import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_config.dart';

class UserService {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await _storage.read(key: 'access_token');

    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/user/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        // Token might be expired
        if (response.statusCode == 401) {
          await _storage.delete(key: 'access_token');
        }
        return null;
      }
    } catch (e) {
      print('Error fetching current user: $e');
      return null;
    }
  }

  Future<bool> updateUser({String? name, String? email, String? password}) async {
    final token = await _storage.read(key: 'access_token');

    if (token == null) return false;

    try {
      final Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (password != null && password.isNotEmpty) body['password'] = password;

      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/user/update'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }
}
