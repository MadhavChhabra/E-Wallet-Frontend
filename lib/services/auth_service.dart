import 'package:flutter_ewallet/utils/shared_values.dart';

class AuthService {
  
  static const String baseUrl = SharedValues.baseUrl;
  // static UserModel? _cachedUser; 


  // static Future<UserModel> register(Map<String, dynamic> userData) async {
  //   try {
  //     final res = await http.post(
  //       Uri.parse('$baseUrl/auth/signup'),
  //       body: jsonEncode(userData),
  //       headers: await authHeader(),
  //     );

  //     if (res.statusCode == 200) {
  //       final data = jsonDecode(res.body)['data'];
  //       return UserModel.formJson(data);
  //     } else {
  //       throw Exception(
  //           'Failed to register: ${jsonDecode(res.body)['message']}');
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to register: $e');
  //   }
  // }

  // static Future<Map<String, dynamic>> login(
  //     Map<String, dynamic> credentials) async {
  //   try {
  //     final res = await http.post(
  //       Uri.parse('$baseUrl/auth/login'),
  //       body: jsonEncode(credentials),
  //       headers: await authHeader(),
  //     );

  //     if (res.statusCode == 200) {
  //       final data = jsonDecode(res.body);
  //       return data;
  //     } else {
  //       throw Exception('Failed to login: ${jsonDecode(res.body)['message']}');
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to login: $e');
  //   }
  // }


}
