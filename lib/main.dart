import 'package:flutter/material.dart';
import 'db_helper.dart';

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
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        brightness: Brightness.light,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        ),
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

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    final datos = await DBHelper.obtenerProductos();
    setState(() {
      for (var prod in datos) {
        productos[prod['ref']] = {
          'nombre': prod['nombre'],
          'precio': prod['precio'],
          'descripcion': prod['descripcion'],
        };
        referenciasUsadas.add(prod['ref']);
      }
    });
  }

  Future<void> agregarProducto(String ref, String nombre, double precio, String descripcion) async {
    final nuevoProducto = {
      'ref': ref,
      'nombre': nombre,
      'precio': precio,
      'descripcion': descripcion,
    };
    await DBHelper.insertarProducto(nuevoProducto);
    setState(() {
      productos[ref] = nuevoProducto;
      referenciasUsadas.add(ref);
    });
  }

  Future<void> eliminarProducto(String ref) async {
    await DBHelper.eliminarProducto(ref);
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
              const SizedBox(height: 10),
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: precioController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio'),
              ),
              const SizedBox(height: 10),
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
            onPressed: () async {
              final ref = refController.text;
              final nombre = nombreController.text;
              final precio = double.tryParse(precioController.text) ?? 0.0;
              final descripcion = descripcionController.text;

              if (ref.isNotEmpty && nombre.isNotEmpty) {
                if (referenciasUsadas.contains(ref)) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Referencia duplicada'),
                      content: const Text('La referencia ya ha sido utilizada. Usa otra diferente.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  await agregarProducto(ref, nombre, precio, descripcion);
                  if (context.mounted) Navigator.pop(context);
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
        title: const Text('Gestión De Inventario'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
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
                    title: Text(
                      data['nombre'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(data['descripcion']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => eliminarProducto(ref),
                    ),
                    leading: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: mostrarFormularioAgregarProducto,
        label: const Text('Agregar'),
        icon: const Icon(Icons.add_box_rounded),
      ),
    );
  }
}
