import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'productos.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE productos(
            ref TEXT PRIMARY KEY,
            nombre TEXT,
            precio REAL,
            descripcion TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insertarProducto(Map<String, dynamic> producto) async {
    final db = await database;
    await db.insert('productos', producto,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> eliminarProducto(String ref) async {
    final db = await database;
    await db.delete('productos', where: 'ref = ?', whereArgs: [ref]);
  }

  static Future<List<Map<String, dynamic>>> obtenerProductos() async {
    final db = await database;
    return await db.query('productos');
  }
}
