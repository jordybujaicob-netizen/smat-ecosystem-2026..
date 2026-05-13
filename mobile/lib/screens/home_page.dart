import 'package:flutter/material.dart';
import 'dart:math'; 
import '../services/api_service.dart';
import '../models/estacion.dart';
import '../services/auth_service.dart';
import 'add_station_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Estacion>> futureEstaciones;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      // Capturamos el futuro con el nuevo manejo de errores
      futureEstaciones = apiService.fetchEstaciones();
    });
  }

  void _mostrarDialogoEdicion(Estacion estacion) {
    final nombreCtrl = TextEditingController(text: estacion.nombre);
    final ubicacionCtrl = TextEditingController(text: estacion.ubicacion);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar Estación"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: "Nombre")),
            TextField(controller: ubicacionCtrl, decoration: const InputDecoration(labelText: "Ubicación")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              bool ok = await apiService.editarEstacion(estacion.id, nombreCtrl.text, ubicacionCtrl.text);
              if (ok && mounted) {
                Navigator.pop(context);
                _refresh();
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMAT - Monitoreo Móvil'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () async {
            await AuthService().logout();
            Navigator.pushReplacementNamed(context, '/login');
          }),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Estacion>>(
          future: futureEstaciones,
          builder: (context, snapshot) {
            // INDICADOR VISUAL (Reto Puesta a Punto - Página 3 del PDF)
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } 
            // MANEJO DE RESILIENCIA (Página 3 del PDF: Mensaje si el servidor está apagado)
            else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, size: 50, color: Colors.grey),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('${snapshot.error}', textAlign: TextAlign.center),
                    ),
                    ElevatedButton(onPressed: _refresh, child: const Text("Reintentar")),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No hay estaciones registradas'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final est = snapshot.data![index];
                  int valorLectura = Random().nextInt(100); 
                  Color colorAlerta = valorLectura < 50 ? Colors.green : Colors.red;

                  return Dismissible(
                    key: Key(est.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) async {
                      await apiService.eliminarEstacion(est.id);
                      _refresh();
                    },
                    child: ListTile(
                      leading: Icon(Icons.satellite_alt, color: colorAlerta),
                      title: Text(est.nombre),
                      subtitle: Text("${est.ubicacion} (Valor: $valorLectura)"),
                      onTap: () => _mostrarDialogoEdicion(est),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => AddEstacionScreen())
          );
          if (result == true) _refresh();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}