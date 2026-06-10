import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/estacion.dart';
import 'auth_service.dart';

class ApiService {
  final String baseUrl = "http://localhost:8000";
  final AuthService _authService = AuthService();

  Future<List<Estacion>> fetchEstaciones() async {
    final response = await http.get(Uri.parse('$baseUrl/estaciones/'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Estacion.fromJson(item)).toList();
    }
    throw Exception("Error al cargar");
  }

  Future<void> createEstacion(Estacion est) async {
    String? token = await _authService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/estaciones/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "nombre": est.nombre,
        "ubicacion": est.ubicacion,
        "valor": est.valor
      }),
    );
    if (response.statusCode != 201) {
      throw Exception("Error al crear estación: ${response.body}");
    }
  }

  Future<void> editarEstacion(Estacion est) async {
    String? token = await _authService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/estaciones/${est.id}'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode(est.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception("Error del servidor: ${response.body}");
    }
  }

  Future<void> eliminarEstacion(int id) async {
    String? token = await _authService.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/estaciones/$id'),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode != 200) {
      throw Exception("Error al eliminar");
    }
  }
}
