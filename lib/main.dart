import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
// import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario Fácil',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<String, Map<String, dynamic>> productos = {};
  final Set<String> referenciasUsadas = {};

  void agregarProducto(String ref, String nombre, double precio, String descripcion) {
    setState(() {
      productos[ref] = {
        'nombre': nombre,
        'precio': precio,
        'descripcion': descripcion,
      };
      referenciasUsadas.add(ref);
    });
  }

  void eliminarProducto(String ref) {
    setState(() {
      productos.remove(ref);
      referenciasUsadas.remove(ref);
    });
  }

  void mostrarFormularioAgregarProducto() {
    final refController = TextEditingController();
    final nombreController = TextEditingController();
    final precioController = TextEditingController();
    final descripcionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar producto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: refController,
                decoration: const InputDecoration(labelText: 'Referencia'),
              ),
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: precioController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio'),
              ),
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
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
            onPressed: () {
              final ref = refController.text;
              final nombre = nombreController.text;
              final precio = double.tryParse(precioController.text) ?? 0.0;
              final descripcion = descripcionController.text;

              if (ref.isNotEmpty && nombre.isNotEmpty) {
                if (referenciasUsadas.contains(ref)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Referencia ya utilizada. Usa otra.')),
                  );
                } else {
                  agregarProducto(ref, nombre, precio, descripcion);
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalProductos = productos.length;
    final totalAcumulado = productos.values.fold<double>(
        0.0, (suma, item) => suma + (item['precio'] as double));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario Fácil'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Chip(
                  label: Text('$totalProductos producto(s)'),
                  backgroundColor: Colors.green.shade200,
                ),
                Chip(
                  label: Text('\$Total: ${totalAcumulado.toStringAsFixed(2)}'),
                  backgroundColor: Colors.blue.shade200,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: productos.entries.map((entry) {
                final ref = entry.key;
                final data = entry.value;
                return Card(
                  child: ListTile(
                    title: Text(data['nombre']),
                    subtitle: Text(data['descripcion']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => eliminarProducto(ref),
                    ),
                    leading: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ref: $ref'),
                        Text('\$${data['precio']}'),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: mostrarFormularioAgregarProducto,
        child: const Icon(Icons.add),
      ),
    );
  }
}
