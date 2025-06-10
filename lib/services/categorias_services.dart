import 'package:sqflite/sqflite.dart';
import '../models/categoria.dart';
import '../db/hiro_db.dart';

class CategoriaService {
  final HiroDb _hiroDb = HiroDb();

  //Insertar una categoria
  Future<void> insertarCategoria(Categoria categoria) async {
    final db = await _hiroDb.database;
    await db.insert(
      'categorias',
      categoria.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //Obtener categorias
  Future<List<Categoria>> obtenerCategoria() async {
    final db = await _hiroDb.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categorias',
      orderBy: 'id DESC',
    );

    return maps.map((map) => Categoria.fromMap(map)).toList();
  }

  //Actualizar una categoria
  Future<void> actualizarCategoria(Categoria categoria) async {
    final db = await _hiroDb.database;
    await db.update(
      'categorias',
      categoria.toMap(),
      where: 'id = ?',
      whereArgs: [categoria.id],
    );
  }

  //Eliminar una categoria
  Future<void> eliminarCategoria(int id) async {
    final db = await HiroDb().database;
    await db.delete('categorias', where: 'id = ?', whereArgs: [id]);
  }
}
