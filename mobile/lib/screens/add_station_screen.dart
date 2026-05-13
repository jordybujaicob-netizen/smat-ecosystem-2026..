import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddEstacionScreen extends StatefulWidget {
  const AddEstacionScreen({super.key});

  @override
  State<AddEstacionScreen> createState() => _AddEstacionScreenState();
}

class _AddEstacionScreenState extends State<AddEstacionScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _cargando = false;

  void _guardar() async {
    if (_nombreController.text.trim().isEmpty || _ubicacionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    setState(() => _cargando = true);

    try {
      bool success = await _apiService.createEstacion(
        _nombreController.text.trim(),
        _ubicacionController.text.trim(),
      );

      if (success) {
        if (mounted) Navigator.pop(context, true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error al guardar")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error de conexión")),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
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
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: "Nombre de la Estación"),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _ubicacionController,
              decoration: const InputDecoration(labelText: "Ubicación"),
            ),
            const SizedBox(height: 25),
            _cargando 
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _guardar,
                  child: const Text("Guardar Estación"),
                ),
          ],
        ),
      ),
    );
  }
}