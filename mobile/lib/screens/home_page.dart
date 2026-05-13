import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/estacion.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SMAT - Estaciones"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh), 
            onPressed: () => setState(() {})
          )
        ],
      ),
      body: FutureBuilder<List<Estacion>>(
        future: _apiService.fetchEstaciones(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final est = snapshot.data![index];
              final Color colorValor = est.valor > 50 ? Colors.red : Colors.green;

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
                  await _apiService.eliminarEstacion(est.id!);
                },
                child: ListTile(
                  leading: const Icon(Icons.satellite_alt),
                  title: Text(est.nombre),
                  subtitle: Text(est.ubicacion),
                  trailing: Text(
                    "${est.valor}", 
                    style: TextStyle(color: colorValor, fontWeight: FontWeight.bold, fontSize: 18)
                  ),
                  onTap: () {
                    // PASAMOS LA ESTACIÓN PARA EDITAR
                    Navigator.pushNamed(context, '/add', arguments: est).then((_) => setState(() {}));
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add').then((_) => setState(() {})),
        child: const Icon(Icons.add),
      ),
    );
  }
}