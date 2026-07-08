import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_ewallet/utils/shared_user.dart';
import 'package:flutter_ewallet/utils/shared_values.dart';
import 'package:http/http.dart' as http;

/// Exchanges the stored refresh token for a fresh access token.
///
/// The backend rotates refresh tokens, so the response carries a *new* refresh
/// token that must replace the old one. If the refresh fails (revoked/expired),
/// the local session is cleared.
class RefreshTokenButton extends StatelessWidget {
  const RefreshTokenButton({Key? key}) : super(key: key);

  static Future<bool> getAccessToken() async {
    try {
      final Uri uri = Uri.parse('${SharedValues.baseUrl}/auth/refresh-token');
      final String? refreshToken = await SharedUser().getRefreshToken();

      if (refreshToken == null) {
        await SharedUser.logout();
        return false;
      }

      final response = await http.post(
        uri,
        headers: <String, String>{
          'Authorization': 'Bearer $refreshToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final Map<String, dynamic> data =
            (body['data'] ?? body) as Map<String, dynamic>;

        final String? newAccess = data['token'];
        final String? newRefresh = data['refreshToken'];

        if (newAccess != null && newAccess.isNotEmpty) {
          await SharedUser().updateAccessToken(newAccess);
        }
        if (newRefresh != null && newRefresh.isNotEmpty) {
          await SharedUser().writeToStorage('refreshToken', newRefresh);
        }
        return newAccess != null && newAccess.isNotEmpty;
      }

      // Refresh token no longer valid — force a clean re-login.
      await SharedUser.logout();
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const ElevatedButton(
      onPressed: getAccessToken,
      child: Text('Get Access Token'),
    );
  }
}
