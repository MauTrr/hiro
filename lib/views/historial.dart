import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../pantalla_principal.dart';

import '../models/categoria.dart';
import '../models/transaccion.dart';
import '../services/categorias_services.dart';
import '../services/transacciones_services.dart';

class Historial extends StatefulWidget {
  const Historial({super.key});

  @override
  State<Historial> createState() => HistorialState();
}

class HistorialState extends State<Historial> {
  final TransaccionService _transaccionService = TransaccionService();
  final CategoriaService _categoriaService = CategoriaService();

  int _expandedIndex = -1;
  List<Transaccion> _transacciones = [];
  Map<int, Categoria> _categoriasMap = {};
  double _saldoTotal = 0.0;
  double _balanceMensual = 0.0;

  void initState() {
    super.initState();
    _cargarDatos();
  }

  void actualizarResumen() {
    _cargarDatos();
  }

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

  Widget _buildCardInfo(String title, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF48A6A7), width: 2.0),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> cargarTransacciones() async {
    // Aquí va tu lógica para obtener las transacciones
    final transacciones = await TransaccionService().obtenerTransaccion();
    final categorias = await _categoriaService.obtenerCategoria();
    final categoriasMap = {for (var c in categorias) c.id!: c};

    setState(() {
      _transacciones = transacciones;
      _categoriasMap = categoriasMap;
    });
  }

  Future<void> _eliminarTransaccion(Transaccion transaccion) async {
    await _transaccionService.eliminarTransaccion(transaccion.id!);
    await _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final transacciones = await _transaccionService.obtenerTransaccion();
    final categorias = await _categoriaService.obtenerCategoria();
    final categoriasMap = {for (var c in categorias) c.id!: c};
    final saldo = await _transaccionService.obtenerSaldoTotal();

    final now = DateTime.now();
    final balanceMap = await _transaccionService.balanceMensual(
      now.year,
      now.month,
    );
    final balance = balanceMap['balance'] ?? 0;

    setState(() {
      _transacciones = transacciones;
      _categoriasMap = categoriasMap;
      _saldoTotal = saldo;
      _balanceMensual = balance;
    });
  }

  Widget _buildTablaTransacciones() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF48A6A7), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de columnas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Expanded(
                  child: Text(
                    'Descripción',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 60), // espacio para los botones
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Lista de transacciones
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _transacciones.length,
            itemBuilder: (context, index) {
              final trans = _transacciones[index];
              final categoria = _categoriasMap[trans.categoriaId];

              return Container(
                decoration: BoxDecoration(
                  color:
                      _expandedIndex == index
                          ? const Color(0xFF48A6A7)
                          : Colors.transparent,
                ),
                child: ExpansionTile(
                  key: UniqueKey(),
                  initiallyExpanded: _expandedIndex == index,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _expandedIndex = expanded ? index : -1;
                    });
                  },
                  tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                  iconColor: Colors.black,
                  collapsedIconColor: Colors.black,
                  collapsedTextColor: Colors.black,
                  textColor: Color(0xFFF2EFE7),
                  subtitle: Text(
                    '${trans.tipo == 'Gasto' ? '-' : '+'}${_formatCurrency(trans.valor)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  leading: Icon(
                    IconData(
                      categoria?.tipoImagen ?? 0xe8cc,
                      fontFamily: 'MaterialSymbols',
                    ),
                    color: Colors.black87,
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(categoria?.nombre ?? 'Sin categoría'),
                      ),
                      SizedBox(
                        width: 70,
                        child: Center(
                          child: Text(
                            _formatearFecha(trans.fecha),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              trans.descripcion,
                              style: const TextStyle(color: Color(0xFFF2EFE7)),
                            ),
                          ),
                          // Botón editar
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFF2EFE7),
                            ),
                            child: IconButton(
                              onPressed: () {
                                final state =
                                    context
                                        .findAncestorStateOfType<
                                          PantallaPrincipalState
                                        >();
                                if (state != null) {
                                  state.editarTransaccionDesdeHistorial(trans);
                                }
                              },
                              icon: Text(
                                String.fromCharCode(0xe3c9),
                                style: TextStyle(
                                  fontFamily: 'MaterialSymbols',
                                  fontSize: 25,
                                  color: Color(0xFF48A6A7),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Botón eliminar
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFF2EFE7),
                            ),
                            child: IconButton(
                              onPressed: () => _eliminarTransaccion(trans),
                              icon: Text(
                                String.fromCharCode(0xe872),
                                style: TextStyle(
                                  fontFamily: 'MaterialSymbols',
                                  fontSize: 25,
                                  color: Color(0xFF48A6A7),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        bottom: 100,
      ), // por si hay barra de navegación
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saldo Disponible',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Balance mensual',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCardInfo('Saldo', _formatCurrency(_saldoTotal)),
                _buildCardInfo(
                  'Balance',
                  '${_balanceMensual >= 0 ? '+ ' : '- '}${_formatCurrency(_balanceMensual.abs())}',
                  color: _balanceMensual >= 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Historial',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildTablaTransacciones(),
          ),
        ],
      ),
    );
  }
}

class TarjetaTransaccion extends StatelessWidget {
  final Transaccion transaccion;
  final void Function(Transaccion) onEditar;

  const TarjetaTransaccion({
    super.key,
    required this.transaccion,
    required this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(transaccion.descripcion),
        subtitle: Text(transaccion.fecha),
        trailing: IconButton(
          icon: Icon(Icons.edit, color: Colors.teal),
          onPressed: () => onEditar(transaccion),
        ),
      ),
    );
  }
}
