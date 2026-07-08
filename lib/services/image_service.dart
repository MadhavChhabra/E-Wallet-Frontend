import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:flutter_ewallet/services/http_service.dart';
import 'package:flutter_ewallet/utils/RefreshToken.dart';
import 'package:flutter_ewallet/utils/authHeader.dart';
import 'package:flutter_ewallet/utils/shared_values.dart';
import 'package:http/http.dart' as http;

/// Image upload + profile-picture management against the backend.
///
/// Uses [XFile] (from image_picker) and byte uploads so the same code path works
/// on web and mobile. Uploads go to the multipart endpoint `/api/v1/images`
/// (field `file`), which returns an opaque filename.
class ImageService {
  /// Uploads [file] and returns the stored filename, or null on failure.
  static Future<String?> uploadImage(XFile file) async {
    final uri = Uri.parse('${SharedValues.baseUrl}/images');
    final bytes = await file.readAsBytes();

    Future<http.StreamedResponse> send() async {
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(await authHeader());
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: file.name.isNotEmpty ? file.name : 'upload.jpg',
      ));
      return request.send();
    }

    var streamed = await send();
    if (streamed.statusCode == 401) {
      await RefreshTokenButton.getAccessToken();
      streamed = await send();
    }

    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = body['data'];
      if (data is Map && data['filename'] != null) {
        return data['filename'] as String;
      }
    }
    return null;
  }

  /// Associates an uploaded [filename] with the current user's profile.
  static Future<bool> setProfileImage(String filename) async {
    final res = await HttpService.putWithAuth(
        '/users/me/profile-image', {'filename': filename});
    return res['message'] == 'Success';
  }

  /// Convenience: upload then set as profile image in one call.
  static Future<bool> uploadAndSetProfileImage(XFile file) async {
    final filename = await uploadImage(file);
    if (filename == null) return false;
    return setProfileImage(filename);
  }

  /// Returns the current user's profile image absolute URL, or null if unset.
  static Future<String?> currentProfileImageUrl() async {
    final res = await HttpService.getWithAuth('/users/me');
    final data = res['data'];
    if (data is Map && data['profileImageUrl'] != null) {
      return '${SharedValues.apiHost}${data['profileImageUrl']}';
    }
    return null;
  }
}
