import 'dart:convert';

import 'package:flutter_ewallet/utils/refresh_token.dart';
import 'package:flutter_ewallet/utils/auth_header.dart';
import 'package:flutter_ewallet/utils/api_config.dart';
import 'package:flutter_ewallet/utils/session_guard.dart';
import 'package:http/http.dart' as http;

/// Thin HTTP client for the E-Wallet API.
class HttpService {
  static String get baseUrl => ApiConfig.baseUrl;

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<Map<String, dynamic>> postWithoutAuth(
      String url, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$url'),
      headers: _jsonHeaders,
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  static Future<Map<String, dynamic>> getWithoutAuth(String url) async {
    final response =
        await http.get(Uri.parse('$baseUrl$url'), headers: _jsonHeaders);
    return _decode(response);
  }

  static Future<Map<String, dynamic>> getWithAuth(String url) {
    return _authed(
        (headers) => http.get(Uri.parse('$baseUrl$url'), headers: headers));
  }

  static Future<Map<String, dynamic>> postWithAuth(
    String url,
    Map<String, dynamic> body, {
    String? idempotencyKey,
  }) {
    return _authed((headers) {
      if (idempotencyKey != null) {
        headers = {...headers, 'Idempotency-Key': idempotencyKey};
      }
      return http.post(
        Uri.parse('$baseUrl$url'),
        headers: headers,
        body: jsonEncode(body),
      );
    });
  }

  static Future<Map<String, dynamic>> putWithAuth(
      String url, Map<String, dynamic> body) {
    return _authed((headers) => http.put(
          Uri.parse('$baseUrl$url'),
          headers: headers,
          body: jsonEncode(body),
        ));
  }

  static Future<Map<String, dynamic>> deleteWithAuth(String url) {
    return _authed(
        (headers) => http.delete(Uri.parse('$baseUrl$url'), headers: headers));
  }

  static Future<void> logout() async {
    try {
      await _authed((headers) =>
          http.post(Uri.parse('$baseUrl/auth/logout'), headers: headers));
    } catch (_) {}
  }

  static Future<Map<String, dynamic>> _authed(
      Future<http.Response> Function(Map<String, String> headers) send) async {
    var headers = {...await authHeader(), ..._jsonHeaders};
    var response = await send(headers);

    if (response.statusCode == 401) {
      final refreshed = await RefreshTokenButton.getAccessToken();
      if (!refreshed) {
        SessionGuard.redirectToSignIn(
          message: 'Session expired. Please sign in again.',
        );
        throw ApiException('Session expired. Please sign in again.');
      }
      headers = {...await authHeader(), ..._jsonHeaders};
      response = await send(headers);
      if (response.statusCode == 401) {
        SessionGuard.redirectToSignIn(
          message: 'Session expired. Please sign in again.',
        );
        throw ApiException('Session expired. Please sign in again.');
      }
    }

    return _decode(response);
  }

  static Map<String, dynamic> _decode(http.Response response) {
    if (response.body.isEmpty) {
      if (response.statusCode >= 400) {
        throw ApiException('Request failed (${response.statusCode})');
      }
      return {'status': response.statusCode};
    }

    final decoded = jsonDecode(response.body);
    final Map<String, dynamic> body = decoded is Map<String, dynamic>
        ? decoded
        : {'data': decoded};

    if (response.statusCode >= 400) {
      final message = body['message']?.toString();
      final errorCode = body['errorCode']?.toString();
      final validation = _firstValidationError(body['errors']);
      throw ApiException(
        validation ??
            message ??
            errorCode ??
            'Request failed (${response.statusCode})',
      );
    }

    return body;
  }

  static String? _firstValidationError(dynamic errors) {
    if (errors is! List || errors.isEmpty) return null;
    final first = errors.first;
    if (first is Map) {
      final field = first['field']?.toString();
      final message = first['message']?.toString();
      if (field != null && message != null) return '$field: $message';
      return message;
    }
    return null;
  }
}

class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
