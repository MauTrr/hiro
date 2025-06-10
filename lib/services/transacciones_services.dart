import 'package:sqflite/sqflite.dart';
import '../models/transaccion.dart';
import '../db/hiro_db.dart';

class TransaccionService {
  final HiroDb _hiroDb = HiroDb();

  // Insertar una transaccion
  Future<void> insertarTransaccion(Transaccion transaccion) async {
    final db = await _hiroDb.database;
    await db.insert(
      'transacciones',
      transaccion.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //Obtener las transacciones
  Future<List<Transaccion>> obtenerTransaccion() async {
    final db = await _hiroDb.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transacciones',
      orderBy: 'fecha DESC',
    );

    return maps.map((map) => Transaccion.fromMap(map)).toList();
  }

  //Actualizar una transaccion
  Future<void> actualizarTransaccion(Transaccion transaccion) async {
    final db = await _hiroDb.database;
    await db.update(
      'transacciones',
      transaccion.toMap(),
      where: 'id = ?',
      whereArgs: [transaccion.id],
    );
  }

  //Eliminar una transaccion
  Future<void> eliminarTransaccion(int id) async {
    final db = await HiroDb().database;
    await db.delete('transacciones', where: 'id = ?', whereArgs: [id]);
  }

  //Obtener el saldo total
  Future<double> obtenerSaldoTotal() async {
    final db = await _hiroDb.database;
    final ingresos = await db.rawQuery(
      "SELECT SUM(valor) as total FROM transacciones WHERE tipo = 'Ingreso'",
    );
    final gastos = await db.rawQuery(
      "SELECT SUM(valor) as total FROM transacciones WHERE tipo = 'Gasto'",
    );
    double totalIngresos =
        ingresos.first['total'] != null
            ? ingresos.first['total'] as double
            : 0.0;
    double totalGastos =
        gastos.first['total'] != null ? gastos.first['total'] as double : 0.0;

    return totalIngresos - totalGastos;
  }

  //Hacer el balance mensual
  Future<Map<String, double>> balanceMensual(int year, int month) async {
    final db = await _hiroDb.database;

    //Crear formato Año-Mes
    final fechaInicio = DateTime(year, month, 1).toIso8601String();
    final fechaFin = DateTime(year, month + 1, 1).toIso8601String();

    final ingresos = await db.rawQuery(
      "SELECT SUM(valor) as total FROM transacciones WHERE tipo = 'Ingreso' AND fecha BETWEEN ? AND ?",
      [fechaInicio, fechaFin],
    );
    final gastos = await db.rawQuery(
      "SELECT SUM(valor) as total FROM transacciones WHERE tipo = 'Gasto' AND fecha BETWEEN ? AND ?",
      [fechaInicio, fechaFin],
    );

    double totalIngresos =
        ingresos.first['total'] != null
            ? ingresos.first['total'] as double
            : 0.0;
    double totalGastos =
        gastos.first['total'] != null ? gastos.first['total'] as double : 0.0;
    double balance = totalIngresos - totalGastos;

    return {
      'ingresos': totalIngresos,
      'gastos': totalGastos,
      'balance': balance,
    };
  }
}
