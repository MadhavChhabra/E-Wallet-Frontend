import 'dart:convert';

import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:flutter_ewallet/services/http_service.dart';
import 'package:flutter_ewallet/utils/refresh_token.dart';
import 'package:flutter_ewallet/utils/auth_header.dart';
import 'package:flutter_ewallet/utils/api_config.dart';
import 'package:http/http.dart' as http;

/// Image upload + profile-picture management against the backend.
class ImageService {
  static Future<String?> uploadImage(XFile file) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/images');
    final bytes = await file.readAsBytes();
    final filename = _safeFilename(file.name);

    Future<http.StreamedResponse> send() async {
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(await authHeader());
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
        contentType: _mediaTypeFor(filename),
      ));
      return request.send();
    }

    var streamed = await send();
    if (streamed.statusCode == 401) {
      await RefreshTokenButton.getAccessToken();
      streamed = await send();
    }

    final response = await http.Response.fromStream(streamed);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);
      final data = body['data'];
      if (data is Map && data['filename'] != null) {
        return data['filename'] as String;
      }
    }
    return null;
  }

  static Future<bool> setProfileImage(String filename) async {
    final res = await HttpService.putWithAuth(
        '/users/me/profile-image', {'filename': filename});
    return res['message'] == 'Success';
  }

  static Future<bool> uploadAndSetProfileImage(XFile file) async {
    final filename = await uploadImage(file);
    if (filename == null) return false;
    return setProfileImage(filename);
  }

  static Future<String?> currentProfileImageUrl() async {
    final res = await HttpService.getWithAuth('/users/me');
    final data = res['data'];
    if (data is Map && data['profileImageUrl'] != null) {
      return '${ApiConfig.apiHost}${data['profileImageUrl']}';
    }
    return null;
  }

  static String _safeFilename(String name) {
    if (name.isEmpty) return 'upload.jpg';
    if (name.contains('.')) return name;
    return '$name.jpg';
  }

  static MediaType _mediaTypeFor(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('image', 'jpeg');
    }
  }
}
