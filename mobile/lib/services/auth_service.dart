import 'dart:convert';
import 'package:http/http.dart' as http;
// Permite guardar datos directamente en el LocalStorage de Chrome
import 'dart:html' as html;

class AuthService {
  final String baseUrl = "http://localhost:8000";

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/token'),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "username": username,
          "password": password,
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];

        html.window.localStorage['smat_token'] = token;

        print("================ TOKEN IOT GUARDADO ================");
        print(token);
        print("====================================================");

        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    html.window.localStorage.remove('smat_token');
  }

  Future<String?> getToken() async {
    return html.window.localStorage['smat_token'];
  }
}
