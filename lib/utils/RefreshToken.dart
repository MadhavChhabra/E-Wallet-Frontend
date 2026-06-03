import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ewallet/utils/shared_user.dart';
import 'package:flutter_ewallet/utils/shared_values.dart';
import 'package:http/http.dart' as http;

class RefreshTokenButton extends StatelessWidget {
  const RefreshTokenButton({Key? key}) : super(key: key);

  static Future<void> getAccessToken() async {
    try {
      print("DOING IT");
      final Uri uri = Uri.parse('${SharedValues.baseUrl}/auth/refresh-token');
      final String? refreshToken = await SharedUser()
          .getRefreshToken(); // Provide your refresh token here

      if (refreshToken != null) {
        print("Refresh Token is not null");
        final response = await http.post(
          uri,
          headers: <String, String>{
            HttpHeaders.authorizationHeader:
                'Bearer $refreshToken', // Send JWT token in Authorization header
            HttpHeaders.contentTypeHeader:
                'application/json', // Specify content type as JSON
          },
        );

        if (response.statusCode == 200) {
          // Successful response, handle the data here
          final Map<String, dynamic> data = jsonDecode(response.body);
           await SharedUser().updateAccessToken(data["token"]);

          print('Access token received: ${response.body}');
          // SharedUser().updateAccessToken(value)
        } else {
          // Handle error responses
          print('Failed to get access token: ${response.statusCode}');
        }
      } else {
        print("refresh token is null");
      }
    } catch (e) {
      // Handle network errors or other exceptions
      print('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: getAccessToken,
      child: const Text('Get Access Token'),
    );
  }
}

// Usage:
// Place this button in your widget tree where you want it to appear
// For example, inside the build method of a StatelessWidget or StatefulWidget
