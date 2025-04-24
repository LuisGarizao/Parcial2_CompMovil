import 'package:flutter/material.dart';

void main() {
  runApp(const InventarioApp());
}

class InventarioApp extends StatelessWidget {
  const InventarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario Fácil',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Producto {
  final String referencia;
  final String nombre;
  final double precio;
  final String descripcion;

  Producto({
    required this.referencia,
    required this.nombre,
    required this.precio,
    required this.descripcion,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<String, Producto> productos = {};

  final _refController = TextEditingController();
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();
  final _descripcionController = TextEditingController();

  void agregarProducto() {
    final ref = _refController.text;
    final nombre = _nombreController.text;
    final precio = double.tryParse(_precioController.text) ?? 0.0;
    final descripcion = _descripcionController.text;

    if (ref.isNotEmpty && nombre.isNotEmpty && descripcion.isNotEmpty) {
      setState(() {
        productos[ref] = Producto(
          referencia: ref,
          nombre: nombre,
          precio: precio,
          descripcion: descripcion,
        );
        _refController.clear();
        _nombreController.clear();
        _precioController.clear();
        _descripcionController.clear();
      });
    }
  }

  void eliminarProducto(String ref) {
    setState(() {
      productos.remove(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalProductos = productos.length;
    final totalPrecio = productos.values.fold(0.0, (sum, p) => sum + p.precio);

    return Scaffold(
      appBar: AppBar(title: const Text('Inventario Fácil')),
      floatingActionButton: FloatingActionButton(
        onPressed: agregarProducto,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _refController,
              decoration: const InputDecoration(labelText: 'Referencia'),
            ),
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _precioController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Precio'),
            ),
            TextField(
              controller: _descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: 20),
            Text('Total productos: $totalProductos'),
            Text('Valor acumulado: \$${totalPrecio.toStringAsFixed(2)}'),
            const Divider(height: 32),
            Expanded(
              child: ListView(
                children: productos.values.map((producto) {
                  return Card(
                    child: ListTile(
                      title: Text(producto.nombre),
                      subtitle: Text(producto.descripcion),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => eliminarProducto(producto.referencia),
                      ),
                      leading: Text('\$${producto.precio.toStringAsFixed(2)}'),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
