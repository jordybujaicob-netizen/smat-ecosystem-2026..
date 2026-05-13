import 'dart:convert';
import 'dart:async'; // Necesario para el timeout
import 'package:http/http.dart' as http;
import '../models/estacion.dart';
import 'auth_service.dart';

class ApiService {
  final String baseUrl = "http://127.0.0.1:8000";

  // Obtener estaciones con Manejo de Errores (Punto 1 del PDF 7.1)
  Future<List<Estacion>> fetchEstaciones() async {
    try {
      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/estaciones/'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 5)); // Evita esperas infinitas

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((e) => Estacion.fromJson(e)).toList();
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      // Evita que la App se cierre si el servidor cae
      throw Exception('No se pudo conectar con SMAT. ¿Está el servidor activo?');
    }
  }

  // Crear Estación con robustez
  Future<bool> createEstacion(String nombre, String ubicacion) async {
    try {
      final token = await AuthService().getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/estaciones/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'nombre': nombre, 'ubicacion': ubicacion}),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Editar Estación con robustez
  Future<bool> editarEstacion(int id, String nombre, String ubicacion) async {
    try {
      final token = await AuthService().getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/estaciones/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'nombre': nombre, 'ubicacion': ubicacion}),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Eliminar Estación con robustez
  Future<bool> eliminarEstacion(int id) async {
    try {
      final token = await AuthService().getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/estaciones/$id'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}