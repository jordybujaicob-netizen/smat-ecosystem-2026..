import 'package:flutter/material.dart';
import '../models/estacion.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  late Future<List<Estacion>> _futureEstaciones;

  @override
  void initState() {
    super.initState();
    _refreshEstaciones();
  }

  void _refreshEstaciones() {
    setState(() {
      _futureEstaciones = _apiService.fetchEstaciones();
    });
  }

  void _mostrarFormulario({Estacion? estacion}) {
    final nombreController =
        TextEditingController(text: estacion?.nombre ?? '');
    final ubicacionController =
        TextEditingController(text: estacion?.ubicacion ?? '');
    final valorController =
        TextEditingController(text: estacion?.valor.toString() ?? '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(estacion == null ? 'Nueva Estación' : 'Editar Estación'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: ubicacionController,
                decoration: const InputDecoration(labelText: 'Ubicación'),
              ),
              TextField(
                controller: valorController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Valor'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nuevaEstacion = Estacion(
                id: estacion?.id,
                nombre: nombreController.text,
                ubicacion: ubicacionController.text,
                valor: int.tryParse(valorController.text) ?? 0,
              );

              try {
                if (estacion == null) {
                  await _apiService.createEstacion(nuevaEstacion);
                } else {
                  await _apiService.editarEstacion(nuevaEstacion);
                }
                if (context.mounted) Navigator.pop(context);
                _refreshEstaciones();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estaciones SMAT',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent, // Eliminada la franja azul
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              await AuthService().logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Estacion>>(
        future: _futureEstaciones,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
                child: Text('Error al conectar con el servidor'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay estaciones registradas.'));
          }

          final estaciones = snapshot.data!;
          return ListView.builder(
            itemCount: estaciones.length,
            itemBuilder: (context, index) {
              final est = estaciones[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(est.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle:
                      Text('Ubicación: ${est.ubicacion} | Valor: ${est.valor}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _mostrarFormulario(estacion: est),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          if (est.id != null) {
                            try {
                              await _apiService.eliminarEstacion(est.id!);
                              _refreshEstaciones();
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Error al eliminar: $e')),
                                );
                              }
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
