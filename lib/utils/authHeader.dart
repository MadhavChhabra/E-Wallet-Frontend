import 'package:flutter_ewallet/utils/shared_user.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'RefreshToken.dart';

Future<Map<String, String>> authHeader() async {
  final token = await SharedUser.getToken();
  print('Auth Header Token stored = ');
  print(token);

  if (token != null) {
    if (JwtDecoder.isExpired(token)) {
      await RefreshTokenButton.getAccessToken();
      final updatedToken = await SharedUser.getToken();
      return {'Authorization': 'Bearer $updatedToken'};
    } else {
      return {'Authorization': 'Bearer $token'};
    }
  } else {
    return {};
  }
}
