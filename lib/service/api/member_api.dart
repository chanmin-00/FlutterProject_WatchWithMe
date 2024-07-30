import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MemberApiService {
  static final String _baseUrl = dotenv.env['BASE_URL']!;

  static Future<String> fetchUserEmail(String userId, String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/member/get/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': '*/*',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json =
          jsonDecode(utf8.decode(response.bodyBytes));
      if (json['isSuccess'] == true) {
        final Map<String, dynamic> data = json['data'];
        final email = data['email'];
        return email;
      } else {
        throw Exception('Failed to fetch user email');
      }
    } else {
      throw Exception('Failed to load user email');
    }
  }

  static Future<Map<String, dynamic>> registerMember({
    required String email,
    required String password,
    required String confirmPassword,
    required String name,
    required String mobile,
    required bool agree,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/member'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': '*/*',
      },
      body: jsonEncode(<String, dynamic>{
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'name': name,
        'mobile': mobile,
        'agree': agree,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      return responseBody;
    } else {
      throw Exception('Failed to register member: ${response.reasonPhrase}');
    }
  }

  static Future<Map<String, dynamic>> loginMember({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/member/login'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': '*/*',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      return responseBody;
    } else {
      throw Exception('Failed to login member: ${response.reasonPhrase}');
    }
  }
}
