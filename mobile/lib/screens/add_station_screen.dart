import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/estacion.dart';

class AddStationScreen extends StatefulWidget {
  @override
  _AddStationScreenState createState() => _AddStationScreenState();
}

class _AddStationScreenState extends State<AddStationScreen> {
  final _nombreController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  void _guardar() async {
    if (_nombreController.text.isEmpty || _ubicacionController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final nueva = Estacion(
        nombre: _nombreController.text,
        ubicacion: _ubicacionController.text,
        valor: 0,
      );
      await _apiService.createEstacion(nueva);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al guardar")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nueva Estación")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: _nombreController, decoration: const InputDecoration(labelText: "Nombre")),
            TextField(controller: _ubicacionController, decoration: const InputDecoration(labelText: "Ubicación")),
            const SizedBox(height: 20),
            _isLoading ? const CircularProgressIndicator() : ElevatedButton(onPressed: _guardar, child: const Text("Guardar")),
          ],
        ),
      ),
    );
  }
}