import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/categoria.dart';
import '../models/transaccion.dart';
import '../services/categorias_services.dart';
import '../services/transacciones_services.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  //Variables de estado
  final TransaccionService _transaccionService = TransaccionService();
  final CategoriaService _categoriaService = CategoriaService();
  double _saldoTotal = 0.0;
  double _balanceMensual = 0.0;
  List<Transaccion> _transacciones = [];
  List<FlSpot> _puntosBalance = [];
  Map<int, Categoria> _categoriasMap = {};

  //Funciones para el formato de fecha
  String _formatearFecha(String fechaString) {
    try {
      final fecha = DateTime.parse(fechaString);
      return DateFormat('dd-MM-yy').format(fecha);
    } catch (e) {
      return fechaString; // En caso de error, regresa el string original
    }
  }

  String _formatCurrency(double value) {
    return '\$${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}';
  }

  // Ciclo de inicialización
  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void recargar() {
    _cargarDatos();
  }

  //Metodo para calcular el balance mensual
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

  //Metodo para cargar los datos de manera asincronica
  Future<void> _cargarDatos() async {
    final transacciones = await _transaccionService.obtenerTransaccion();
    final categorias = await _categoriaService.obtenerCategoria();
    final categoriasMap = {for (var cat in categorias) cat.id: cat};
    final saldo = await _transaccionService.obtenerSaldoTotal();
    final now = DateTime.now();

    final balanceMensual = await _transaccionService.balanceMensual(
      now.year,
      now.month,
    );

    setState(() {
      _transacciones = transacciones;
      _saldoTotal = saldo;
      _balanceMensual = balanceMensual['balance'] ?? 0;
      _puntosBalance = generarPuntosGraficoBalance(transacciones);
      _categoriasMap = Map.fromEntries(
        categoriasMap.entries
            .where((entry) => entry.key != null)
            .map((entry) => MapEntry(entry.key!, entry.value)),
      );
    });
  }

  //Funcion que permite crear los puntos del balance mensual por mes
  List<FlSpot> generarPuntosGraficoBalance(List<Transaccion> transacciones) {
    final balanceMensual = calcularBalanceMensual(transacciones);
    final meses = List.generate(12, (index) {
      final now = DateTime.now();
      final mes = DateTime(now.year, index + 1);
      final clave = '${mes.year}-${mes.month.toString().padLeft(2, '0')}';
      final valor = balanceMensual[clave] ?? 0.0;
      return FlSpot(index.toDouble(), valor);
    });

    return meses;
  }

  // Widget que crea el grafico del balance mensual
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

  // Widget que crea la tabla del ultimo movimiento registrado
  Widget _buildUltimoMovimiento() {
    final trans =
        _transacciones
            .map((t) => MapEntry(t, DateTime.tryParse(t.fecha)))
            .where((entry) => entry.value != null)
            .toList()
          ..sort((a, b) => b.value!.compareTo(a.value!));

    final ultimaTrans = trans.isNotEmpty ? trans.first.key : null;

    if (ultimaTrans == null) {
      return const Text('No hay transacciones registradas aún');
    }

    final categoria = _categoriasMap[ultimaTrans.categoriaId];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF48A6A7), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Expanded(
                  child: Text(
                    'Descripción',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold)),
                // espacio para los botones
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                IconData(
                  categoria?.tipoImagen ?? 0xe8cc,
                  fontFamily: 'MaterialSymbols',
                ),
                color: Colors.black87,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(categoria?.nombre ?? 'Sin categoría'),
                    Text(
                      '${ultimaTrans.tipo == 'Gasto' ? '-' : '+'}${_formatCurrency(ultimaTrans.valor)}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatearFecha(ultimaTrans.fecha),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  //Funcion auxiliar que abrevia los meses en la grafica
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

  //Creacion del body
  @override
  Widget build(BuildContext context) {
    final balanceData = calcularBalanceMensual(_transacciones);
    final ultimaTransaccion =
        _transacciones.isNotEmpty ? _transacciones.last : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          // Creacion de la tarjeta de saldo disponible
          children: [
            Text(
              'Saldo Disponible',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              child: Card(
                color: Color(0xFFF2EFE7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Color(0xFF48A6A7), width: 2),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$${_saldoTotal.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${_balanceMensual >= 0 ? '+ ' : '- '}\$${_balanceMensual.abs().toStringAsFixed(0)} Balance',
                        style: TextStyle(
                          color:
                              _balanceMensual >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Creacion de la grafica
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
                border: Border.all(color: Color(0xFF48A6A7), width: 2.0),
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
            const SizedBox(height: 10),

            //Creacion de ultimo movimiento
            Text(
              'Ultimo movimiento',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildUltimoMovimiento(),
          ],
        ),
      ),
    );
  }
}
