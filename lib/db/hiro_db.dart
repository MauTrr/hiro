import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//Crear la base de datos
class HiroDb {
  static final HiroDb _instance =
      HiroDb._internal(); //Patron para evitar que se creen muchas conexiones
  static Database? _database;

  factory HiroDb() => _instance;

  HiroDb._internal();

  //Acceder a la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  //Iniciar la base de datos
  Future<Database> _initDatabase() async {
    final dbPath =
        await getDatabasesPath(); //Devuelve e directorio local donde se almacenan las DB en el dispositivo
    final path = join(dbPath, 'Hiro.db'); // Join para crear la ruta al Hiro.db

    //Crear las tablas
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE categorias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        tipo TEXT CHECK( tipo IN('Ingreso','Gasto')) NOT NULL,
        tipo_imagen TEXT
        )
        ''');

        await db.execute('''
          CREATE TABLE transacciones (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          valor REAL,
          descripcion TEXT,
          tipo TEXT CHECK(tipo IN ('Ingreso', 'Gasto')),
          fecha TEXT DEFAULT(datetime('now')),
          categoria_id INTEGER
          )
        ''');
      },
    );
  }
}
