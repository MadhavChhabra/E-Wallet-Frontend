import 'dart:convert';
import 'package:flutter_ewallet/utils/shared_user.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_ewallet/utils/authHeader.dart';
import 'package:flutter_ewallet/utils/shared_values.dart';

class HttpService {
  static const String baseUrl = SharedValues.baseUrl;

  static Future<Map<String, dynamic>> postWithoutAuth(
      String url, Map<String, dynamic> body) async {
    final response =
        await http.post(Uri.parse('$baseUrl$url'), body: jsonEncode(body));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getWithoutAuth(String url) async {
    final response = await http.get(Uri.parse('$baseUrl$url'));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getWithAuth(String url) async {
    final headers = await authHeader();
    headers['Content-Type'] = 'application/json';

    final response = await http.get(
      Uri.parse('$baseUrl$url'),
      headers: headers,
    );

    RegExp regex = RegExp(r'"token":"(.*?)"');
    RegExpMatch? match = regex.firstMatch(response.headers.toString());
    if (match != null && match.groupCount > 0) {
      final token = match.group(1)!;
      await SharedUser().updateAccessToken(token);
    }

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> postWithAuth(
      String url, Map<String, dynamic> body) async {
    final headers = await authHeader();
    headers['Content-Type'] = 'application/json';

    final response = await http.post(Uri.parse('$baseUrl$url'),
        headers: headers, body: jsonEncode(body));

    RegExp regex = RegExp(r'"token":"(.*?)"');
    RegExpMatch? match = regex.firstMatch(response.headers.toString());
    if (match != null && match.groupCount > 0) {
      final token = match.group(1)!;
      await SharedUser().updateAccessToken(token);
    }

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> putWithAuth(
      String url, Map<String, dynamic> body) async {
    final headers = await authHeader();
    headers['Content-Type'] = 'application/json';

    final response = await http.put(Uri.parse('$baseUrl$url'),
        headers: headers, body: jsonEncode(body));

    // Check if authorization header contains a token
    RegExp regex = RegExp(r'"token":"(.*?)"');
    RegExpMatch? match = regex.firstMatch(response.headers.toString());
    if (match != null && match.groupCount > 0) {
      final token = match.group(1)!;
      await SharedUser().updateAccessToken(token);
    }

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteWithAuth(String url) async {
    final headers = await authHeader();
    headers['Content-Type'] = 'application/json';

    final response =
        await http.delete(Uri.parse('$baseUrl$url'), headers: headers);

    // Check if authorization header contains a token
    RegExp regex = RegExp(r'"token":"(.*?)"');
    RegExpMatch? match = regex.firstMatch(response.headers.toString());
    if (match != null && match.groupCount > 0) {
      final token = match.group(1)!;
      await SharedUser().updateAccessToken(token);
    }

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> logout(String userId) async {
    try {
      final headers = await authHeader();
      headers['Content-Type'] = 'application/json';
      final response = await http.get(
        Uri.parse('$baseUrl/auth/logout/$userId'),
        headers: headers
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to logout: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during logout: $e');
      throw Exception('Failed to logout: $e');
    }
  }
}
