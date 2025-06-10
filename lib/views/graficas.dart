import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/transaccion.dart';
import '../services/categorias_services.dart';
import '../services/transacciones_services.dart';

class Graficas extends StatefulWidget {
  const Graficas({super.key});

  @override
  State<Graficas> createState() => GraficasState();
}

class GraficasState extends State<Graficas> {
  final TransaccionService _transaccionService = TransaccionService();
  final CategoriaService _categoriaService = CategoriaService();
  List<Transaccion> _transacciones = [];
  Map<String, String> _mapaCategorias = {};

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cargarDatos();
  }

  void actualizarDatos() {
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final transacciones = await _transaccionService.obtenerTransaccion();
    final categorias = await _categoriaService.obtenerCategoria();

    setState(() {
      _transacciones = transacciones;
      _mapaCategorias = {
        for (var cat in categorias) cat.id.toString(): cat.nombre,
      };
    });
  }

  Map<String, double> calcularBalanceMensual(List<Transaccion> transacciones) {
    Map<String, double> balancePorMes = {};

    for (var trans in transacciones) {
      final fecha = DateTime.parse(trans.fecha);
      final mes = '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}';

      balancePorMes[mes] =
          (balancePorMes[mes] ?? 0) +
          (trans.tipo == 'Ingreso' ? trans.valor : -trans.valor);
    }

    return Map.fromEntries(
      balancePorMes.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  Map<String, double> calcularGastosPorCategoria(
    List<Transaccion> transacciones,
  ) {
    Map<String, double> gastos = {};

    for (var trans in transacciones) {
      if (trans.tipo == 'Gasto') {
        String nombreCategoria =
            _mapaCategorias[trans.categoriaId.toString()] ??
            trans.categoriaId.toString();

        gastos[nombreCategoria] = (gastos[nombreCategoria] ?? 0) + trans.valor;
      }
    }

    return gastos;
  }

  Widget buildBalanceMensualGrafica(Map<String, double> data) {
    final meses = data.keys.toList();
    final valores = data.values.toList();

    final spots = List.generate(
      valores.length,
      (index) => FlSpot(index.toDouble(), valores[index]),
    );

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Color(0xFF48A6A7),
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Color(0xFF006A71).withOpacity(0.2),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < meses.length) {
                  final mesNombre = _abreviarMes(meses[index]);
                  return Text(mesNombre, style: TextStyle(fontSize: 10));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        gridData: FlGridData(show: true),
      ),
    );
  }

  Widget buildGastosPorCategoriasChart(Map<String, double> data) {
    final keys = data.keys.toList();
    return BarChart(
      BarChartData(
        barGroups:
            keys.asMap().entries.map((entry) {
              int index = entry.key;
              String categoria = entry.value;
              double valor = data[categoria]!;
              return BarChartGroupData(
                x: index,
                barRods: [BarChartRodData(toY: valor, color: Colors.redAccent)],
              );
            }).toList(),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < keys.length) {
                  return Text(keys[index], style: TextStyle(fontSize: 10));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true),
      ),
    );
  }

  String _abreviarMes(String key) {
    final partes = key.split('-');
    final mes = int.parse(partes[1]);
    const nombres = [
      'ENE',
      'FEB',
      'MAR',
      'ABR',
      'MAY',
      'JUN',
      'JUL',
      'AGO',
      'SEP',
      'OCT',
      'NOV',
      'DIC',
    ];
    return nombres[mes - 1];
  }

  @override
  Widget build(BuildContext context) {
    final balanceData = calcularBalanceMensual(_transacciones);
    final gastoData = calcularGastosPorCategoria(_transacciones);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child:
          _transacciones.isEmpty
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Graficas',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      margin: EdgeInsets.only(bottom: 16),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFF48A6A7),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Balance Mensual',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            height: 200,
                            child: buildBalanceMensualGrafica(balanceData),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFF48A6A7),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gastos por categoría',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            height: 200,
                            child: buildGastosPorCategoriasChart(gastoData),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
