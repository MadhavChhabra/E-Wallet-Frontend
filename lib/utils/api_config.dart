import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_ewallet/utils/shared_values.dart';
import 'package:http/http.dart' as http;

/// Resolves the backend host at runtime (web) or from compile-time defines.
class ApiConfig {
  static String? _runtimeApiHost;

  static String get apiHost {
    final runtime = _runtimeApiHost;
    if (runtime != null && runtime.isNotEmpty) {
      return runtime;
    }
    return SharedValues.apiHost;
  }

  static String get baseUrl => '$apiHost/api/v1';

  static bool get isMisconfigured =>
      apiHost.contains('example.com') || apiHost.startsWith('http://10.0.2.2');

  /// Loads `web/api-config.json` on Flutter Web (respects GitHub Pages base href).
  static Future<void> init() async {
    if (!kIsWeb) return;

    try {
      final configUri = Uri.base.resolve('api-config.json');
      final response = await http.get(configUri);
      if (response.statusCode != 200) return;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) return;

      final raw = decoded['apiBaseUrl']?.toString().trim();
      if (raw == null || raw.isEmpty) return;

      _runtimeApiHost = raw.replaceAll(RegExp(r'/+$'), '');
    } catch (_) {
      // Fall back to compile-time API_BASE_URL.
    }
  }
}
