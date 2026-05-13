import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "http://127.0.0.1:8000";
  static String? _token;

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['access_token'];
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getToken() async => _token;
}