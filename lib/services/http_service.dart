import 'dart:convert';

import 'package:flutter_ewallet/utils/RefreshToken.dart';
import 'package:flutter_ewallet/utils/authHeader.dart';
import 'package:flutter_ewallet/utils/shared_values.dart';
import 'package:http/http.dart' as http;

/// Thin HTTP client for the E-Wallet API.
///
/// Responsibilities:
///  * attaches the bearer access token on authenticated calls,
///  * transparently refreshes the token once on a 401 and retries the request,
///  * decodes JSON responses into a `Map`.
///
/// It intentionally does not log tokens or response bodies.
class HttpService {
  static const String baseUrl = SharedValues.baseUrl;

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // --- Unauthenticated -------------------------------------------------------

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
    final response = await http.get(Uri.parse('$baseUrl$url'), headers: _jsonHeaders);
    return _decode(response);
  }

  // --- Authenticated ---------------------------------------------------------

  static Future<Map<String, dynamic>> getWithAuth(String url) {
    return _authed((headers) => http.get(Uri.parse('$baseUrl$url'), headers: headers));
  }

  static Future<Map<String, dynamic>> postWithAuth(
      String url, Map<String, dynamic> body) {
    return _authed((headers) =>
        http.post(Uri.parse('$baseUrl$url'), headers: headers, body: jsonEncode(body)));
  }

  static Future<Map<String, dynamic>> putWithAuth(
      String url, Map<String, dynamic> body) {
    return _authed((headers) =>
        http.put(Uri.parse('$baseUrl$url'), headers: headers, body: jsonEncode(body)));
  }

  static Future<Map<String, dynamic>> deleteWithAuth(String url) {
    return _authed((headers) => http.delete(Uri.parse('$baseUrl$url'), headers: headers));
  }

  /// Revokes the session on the server. Safe to call even if it fails.
  static Future<void> logout() async {
    try {
      await _authed((headers) =>
          http.post(Uri.parse('$baseUrl/auth/logout'), headers: headers));
    } catch (_) {
      // Logout is best-effort; local credentials are cleared regardless.
    }
  }

  // --- Internals -------------------------------------------------------------

  /// Runs [send] with an auth header. On a 401, refreshes the access token once
  /// and retries before giving up.
  static Future<Map<String, dynamic>> _authed(
      Future<http.Response> Function(Map<String, String> headers) send) async {
    var headers = {...await authHeader(), ..._jsonHeaders};
    var response = await send(headers);

    if (response.statusCode == 401) {
      await RefreshTokenButton.getAccessToken();
      headers = {...await authHeader(), ..._jsonHeaders};
      response = await send(headers);
    }

    return _decode(response);
  }

  static Map<String, dynamic> _decode(http.Response response) {
    if (response.body.isEmpty) {
      return {'status': response.statusCode};
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return {'data': decoded};
  }
}
