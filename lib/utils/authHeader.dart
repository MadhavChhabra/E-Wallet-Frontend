import 'package:flutter_ewallet/utils/shared_user.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'RefreshToken.dart';

/// Builds the `Authorization` header for authenticated requests. If the stored
/// access token is expired it is proactively refreshed. Never logs the token.
Future<Map<String, String>> authHeader() async {
  var token = await SharedUser.getToken();
  if (token == null) {
    return {};
  }

  bool expired;
  try {
    expired = JwtDecoder.isExpired(token);
  } catch (_) {
    expired = true; // Malformed token -> force refresh path.
  }

  if (expired) {
    await RefreshTokenButton.getAccessToken();
    token = await SharedUser.getToken();
    if (token == null) {
      return {};
    }
  }

  return {'Authorization': 'Bearer $token'};
}
