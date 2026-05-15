import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_config.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  
  // Storage keys
  static const _tokenKey = 'access_token';
  static const _isAdminKey = 'is_admin';

  /// Admin Login
  /// Sends request as JSON body to /admin/login
  Future<Map<String, dynamic>> adminLogin(String username, String password, {bool rememberMe = false}) async {
    try {
      print('Attempting Admin Login: $username');
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': username,
          'password': password,
          'remember_me': rememberMe,
        }),
      );

      print('Admin Login Response: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['access_token'];
        
        await _storage.write(key: _tokenKey, value: token);
        await _storage.write(key: _isAdminKey, value: 'true');
        
        return {'success': true, 'token': token};
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': 'Invalid email or password'};
      } else if (response.statusCode == 403) {
        final data = json.decode(response.body);
        return {'success': false, 'message': data['detail'] ?? 'Access denied'};
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      print('Admin Login Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// User Login
  /// When normal user logs in, set is_admin = false
  Future<Map<String, dynamic>> userLogin(String email, String password, {bool rememberMe = false}) async {
    try {
      print('Attempting User Login: $email');
      // User login expects Form Data (OAuth2PasswordRequestForm)
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/user/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': email,
          'password': password,
          'remember_me': rememberMe.toString(),
        },
      );

      print('User Login Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['access_token'];
        
        await _storage.write(key: _tokenKey, value: token);
        await _storage.write(key: _isAdminKey, value: 'false');
        
        return {'success': true, 'token': token};
      } else {
        final data = json.decode(response.body);
        return {'success': false, 'message': data['detail'] ?? 'Login failed'};
      }
    } catch (e) {
      print('User Login Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Forgot Password
  /// If admin: call /admin/forgot-password
  /// If user: call /user/forgot-password
  Future<Map<String, dynamic>> forgotPassword(String email, bool isAdmin) async {
    try {
      final endpoint = isAdmin ? '/admin/forgot-password' : '/user/forgot-password';
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}$endpoint?email=$email'),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Reset link sent to your email'};
      } else {
        final data = json.decode(response.body);
        return {'success': false, 'message': data['detail'] ?? 'Error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Token management
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<bool> isAdmin() async {
    final value = await _storage.read(key: _isAdminKey);
    return value == 'true';
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _isAdminKey);
  }

  /// Admin: Send notification to user
  Future<Map<String, dynamic>> sendNotification({
    required String userEmail,
    required String subject,
    required String message,
    String type = 'email',
  }) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/send-notification'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'user_email': userEmail,
          'subject': subject,
          'message': message,
          'notification_type': type,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Notification sent successfully'};
      } else {
        final data = json.decode(response.body);
        return {'success': false, 'message': data['detail'] ?? 'Failed to send notification'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  /// Admin: Create new admin
  Future<Map<String, dynamic>> createAdmin({
    required String name,
    required String email,
    required bool isSuperuser,
  }) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/create-admin'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'is_superuser': isSuperuser,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'message': data['message'] ?? 'Admin created successfully'};
      } else {
        final data = json.decode(response.body);
        return {'success': false, 'message': data['detail'] ?? 'Failed to create admin'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
