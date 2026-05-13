import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/estacion.dart';

class ApiService {
  final String baseUrl = "http://127.0.0.1:8000";

  Future<List<Estacion>> fetchEstaciones() async {
    final response = await http.get(Uri.parse('$baseUrl/estaciones/'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Estacion.fromJson(item)).toList();
    }
    throw Exception("Error");
  }

  Future<void> eliminarEstacion(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/estaciones/$id'));
    if (response.statusCode != 200) throw Exception("Error al eliminar");
  }

  Future<void> editarEstacion(Estacion est) async {
    final response = await http.put(
      Uri.parse('$baseUrl/estaciones/${est.id}'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(est.toJson()),
    );
    if (response.statusCode != 200) throw Exception("Error al editar");
  }

  Future<void> createEstacion(Estacion est) async {
    await http.post(
      Uri.parse('$baseUrl/estaciones/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(est.toJson()),
    );
  }
}