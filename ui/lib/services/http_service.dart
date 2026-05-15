import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// Centralised HTTP service.
/// - Includes Authorization header when a token is provided.
/// - Returns the raw response body on non-2xx instead of masking errors.
/// - Enforces a 15-second timeout to prevent the app hanging indefinitely.
class HttpService {
  static const Duration _timeout = Duration(seconds: 15);

  /// GET request. Throws [HttpException] on non-2xx.
  Future<Map<String, dynamic>> get(
    String endpoint, {
    String? token,
  }) async {
    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}$endpoint'),
          headers: _buildHeaders(token: token),
        )
        .timeout(_timeout);

    return _handleResponse(response);
  }

  /// POST request. Throws [HttpException] on non-2xx.
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}$endpoint'),
          headers: _buildHeaders(token: token),
          body: json.encode(data),
        )
        .timeout(_timeout);

    return _handleResponse(response);
  }

  Map<String, String> _buildHeaders({String? token}) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    // Surface the server error message so the UI can show it
    String message = 'Request failed (${response.statusCode})';
    try {
      final body = json.decode(response.body) as Map<String, dynamic>;
      message = body['detail']?.toString() ?? message;
    } catch (_) {}
    throw HttpException(message, response.statusCode);
  }
}

class HttpException implements Exception {
  final String message;
  final int statusCode;
  const HttpException(this.message, this.statusCode);
  @override
  String toString() => 'HttpException($statusCode): $message';
}
