import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../pantalla_principal.dart';

import '../models/categoria.dart';
import '../models/transaccion.dart';
import '../services/categorias_services.dart';
import '../services/transacciones_services.dart';

class TransaccionScreen extends StatefulWidget {
  const TransaccionScreen({Key? key}) : super(key: key);

  @override
  State<TransaccionScreen> createState() => TransaccionScreenState();
}

class TransaccionScreenState extends State<TransaccionScreen> {
  //Variables
  final TransaccionService _transaccionService = TransaccionService();
  final CategoriaService _categoriaService = CategoriaService();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  DateTime _fechaSeleccionada = DateTime.now();
  String _tipoSeleccionado = 'Ingreso';
  Categoria? _categoriaSeleccionada;
  List<Categoria> _categorias = [];
  Transaccion? _transaccionActual;

  //Ciclo de vida
  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  // Funcion para cargar los datos para editar una transaccion
  void cargarTransaccionParaEditar(Transaccion transaccion) async {
    if (_categorias.isEmpty) {
      await _cargarCategorias();
    }

    setState(() {
      _transaccionActual = transaccion;
      _descripcionController.text = transaccion.descripcion;
      _valorController.text = transaccion.valor.toString();
      _fechaSeleccionada = DateTime.parse(transaccion.fecha);
      _tipoSeleccionado = transaccion.tipo;
      _categoriaSeleccionada = _categorias.firstWhere(
        (cat) => cat.id == transaccion.categoriaId,
        orElse: () => _categorias.first,
      );
    });
  }

  //Funcion para actualizar una transaccion
  Future<void> _actualizarTransaccion(Transaccion transaccionOriginal) async {
    final nuevaTransaccion = Transaccion(
      id: transaccionOriginal.id,
      valor: double.tryParse(_valorController.text) ?? 0,
      descripcion: _descripcionController.text,
      fecha: _fechaSeleccionada.toIso8601String(),
      tipo: _tipoSeleccionado,
      categoriaId: _categoriaSeleccionada?.id ?? 0,
    );

    await _transaccionService.actualizarTransaccion(nuevaTransaccion);

    // Limpiar estado de edición después de guardar
    setState(() {
      _transaccionActual = null;
      _valorController.clear();
      _descripcionController.clear();
      _fechaSeleccionada = DateTime.now();
      _tipoSeleccionado = 'Ingreso';
      _categoriaSeleccionada = null;
    });

    context.findAncestorStateOfType<PantallaPrincipalState>()?.cambiarPantalla(
      2,
    );

    context
        .findAncestorStateOfType<PantallaPrincipalState>()
        ?.graficasKey
        .currentState
        ?.actualizarDatos();

    context
        .findAncestorStateOfType<PantallaPrincipalState>()
        ?.recargarDatosGlobales();
  }

  //Funcion para cargar categorias
  Future<void> _cargarCategorias() async {
    final categorias = await _categoriaService.obtenerCategoria();
    setState(() {
      _categorias = categorias;
    });
  }

  //Funcion para insertar una transaccion
  Future<void> _insertarTransaccion() async {
    if (_valorController.text.trim().isEmpty || _categoriaSeleccionada == null)
      return;

    final transaccion = Transaccion(
      tipo: _tipoSeleccionado,
      valor: double.tryParse(_valorController.text) ?? 0,
      descripcion: _descripcionController.text,
      fecha: _fechaSeleccionada.toIso8601String(),
      categoriaId: _categoriaSeleccionada!.id!,
    );

    await _transaccionService.insertarTransaccion(transaccion);
    _limpiarFormulario();

    context
        .findAncestorStateOfType<PantallaPrincipalState>()
        ?.historialKey
        .currentState
        ?.cargarTransacciones();

    context.findAncestorStateOfType<PantallaPrincipalState>()?.cambiarPantalla(
      2,
    );

    context
        .findAncestorStateOfType<PantallaPrincipalState>()
        ?.graficasKey
        .currentState
        ?.actualizarDatos();

    context
        .findAncestorStateOfType<PantallaPrincipalState>()
        ?.recargarDatosGlobales();

    _limpiarFormulario();
  }

  //Metodo para limpiar el formulario despues de agregar o editar una transaccion
  void _limpiarFormulario() {
    _valorController.clear();
    _descripcionController.clear();
    _fechaSeleccionada = DateTime.now();
    _categoriaSeleccionada = null;
    setState(() {});
  }

  // Funcion para consultar el servicio de categorias y actualiza el estado
  Future<void> recargarCategorias() async {
    final nuevasCategorias = await _categoriaService.obtenerCategoria();
    setState(() {
      _categorias = nuevasCategorias;
    });
  }

  // Funcion auxiliar que retorna la decoracion para inputs personalizados
  InputDecoration _buildDecoration(String label, Color color) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: color),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 2.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 2.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 2.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorTema =
        _tipoSeleccionado == 'Ingreso' ? Color(0xFF48A6A7) : Color(0xFF006A71);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _transaccionActual == null
                ? 'Registrar Transacción'
                : 'Editar Transacción',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          //Formulario tipo
          DropdownButtonFormField<String>(
            value: _tipoSeleccionado,
            onChanged: (value) {
              setState(() {
                _tipoSeleccionado = value!;
                _categoriaSeleccionada = null;
              });
            },
            decoration: _buildDecoration('Tipo', colorTema),
            items:
                ['Ingreso', 'Gasto'].map((tipo) {
                  return DropdownMenuItem(value: tipo, child: Text(tipo));
                }).toList(),
            dropdownColor: Color(0xFFF2EFE7),
          ),

          const SizedBox(height: 20),

          //Formulario Categoria
          DropdownButtonFormField<Categoria>(
            value: _categoriaSeleccionada,
            onChanged: (value) {
              setState(() {
                _categoriaSeleccionada = value;
              });
            },
            decoration: _buildDecoration('Categoria', colorTema),
            items:
                _categorias
                    .where((c) => c.tipo == _tipoSeleccionado)
                    .map(
                      (cat) => DropdownMenuItem(
                        value: cat,
                        child: Row(
                          children: [
                            Icon(
                              IconData(
                                cat.tipoImagen,
                                fontFamily: 'MaterialSymbols',
                              ),
                              color: colorTema,
                            ),
                            const SizedBox(width: 10),
                            Text(cat.nombre),
                          ],
                        ),
                      ),
                    )
                    .toList(),
            dropdownColor: Color(0xFFF2EFE7),
          ),

          const SizedBox(height: 20),

          //Formulario Valor
          TextField(
            controller: _valorController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            cursorColor: colorTema,
            decoration: _buildDecoration('Valor', colorTema),
          ),

          const SizedBox(height: 20),

          //Formulario Descripcion
          TextField(
            controller: _descripcionController,
            cursorColor: colorTema,
            decoration: _buildDecoration('Descripción', colorTema),
          ),

          const SizedBox(height: 20),
          //Fecha
          InkWell(
            onTap: () async {
              final nuevaFecha = await showDatePicker(
                context: context,
                initialDate: _fechaSeleccionada,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                builder: (BuildContext context, Widget? child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Color(0xFF006A71),
                        onPrimary: Color(0xFFF2EFE7),
                        onSurface: Color(0xFF006A71),
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: Color(0xFF48A6A7),
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (nuevaFecha != null) {
                setState(() {
                  _fechaSeleccionada = nuevaFecha;
                });
              }
            },
            child: InputDecorator(
              decoration: _buildDecoration('Fecha', colorTema),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('yyyy-MM-dd').format(_fechaSeleccionada)),
                  Icon(Icons.calendar_today, color: colorTema),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          //Botón
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed:
                  _transaccionActual == null
                      ? _insertarTransaccion
                      : () => _actualizarTransaccion(_transaccionActual!),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorTema,
                padding: const EdgeInsets.symmetric(
                  horizontal: 75,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'Guardar',
                style: TextStyle(
                  color: Color(0xFFF2EFE7),
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
