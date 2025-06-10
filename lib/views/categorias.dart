import 'package:flutter/material.dart';
import '../pantalla_principal.dart';

import '../models/categoria.dart';
import '../services/categorias_services.dart';

class CategoriaScreen extends StatefulWidget {
  const CategoriaScreen({super.key});

  @override
  State<CategoriaScreen> createState() => _CategoriaScreenState();
}

class _CategoriaScreenState extends State<CategoriaScreen> {
  final CategoriaService _categoriaService = CategoriaService();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _iconoController = TextEditingController();

  String _tipoSeleccionado = 'Ingreso';
  List<Categoria> _categorias = [];

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    final categorias = await _categoriaService.obtenerCategoria();
    setState(() {
      _categorias = categorias;
    });
  }

  Future<void> _insertarCategoria() async {
    if (_nombreController.text.trim().isEmpty ||
        _iconoController.text.trim().isEmpty)
      return;

    final nuevaCategoria = Categoria(
      nombre: _nombreController.text,
      tipo: _tipoSeleccionado,
      tipoImagen: int.tryParse(_iconoController.text) ?? 0xe8cc,
    );

    await _categoriaService.insertarCategoria(nuevaCategoria);
    _nombreController.clear();
    _iconoController.clear();
    _cargarCategorias();
  }

  Categoria? _categoriaEnEdicion;
  void _llenarFormularioParaEditar(Categoria categoria) {
    setState(() {
      _categoriaEnEdicion = categoria;
      _nombreController.text = categoria.nombre;
      _iconoController.text = categoria.tipoImagen.toString();
      _tipoSeleccionado = categoria.tipo;
    });
  }

  Future<void> _actualizarCategoria() async {
    if (_categoriaEnEdicion == null) return;

    final categoriaActualizada = Categoria(
      id: _categoriaEnEdicion!.id,
      nombre: _nombreController.text,
      tipo: _tipoSeleccionado,
      tipoImagen: int.tryParse(_iconoController.text) ?? 0xe8cc,
    );

    await _categoriaService.actualizarCategoria(categoriaActualizada);
    _nombreController.clear();
    _iconoController.clear();
    _categoriaEnEdicion = null;
    await _cargarCategorias();

    context
        .findAncestorStateOfType<PantallaPrincipalState>()
        ?.historialKey
        .currentState
        ?.cargarTransacciones();

    context
        .findAncestorStateOfType<PantallaPrincipalState>()
        ?.graficasKey
        .currentState
        ?.actualizarDatos();
  }

  Future<void> _eliminarCategoria(Categoria categoria) async {
    await _categoriaService.eliminarCategoria(categoria.id!);
    await _cargarCategorias();
  }

  final Map<String, int> iconosDisponibles = {
    'Otro': 0xe8cc,
    'Pago': 0xef63,
    'Transporte': 0xe530,
    'Alimento': 0xe56c,
    'Servicio': 0xec1a,
    'Viaje': 0xefd9,
    'Bar': 0xe540,
    'Salud': 0xe1d5,
    'Mascota': 0xe91d,
    'Juego': 0xea28,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gestión de Categorías',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFF006A71), width: 2.0),
                borderRadius: BorderRadius.circular(5),
              ),
              height: 150,
              child:
                  _categorias.isEmpty
                      ? const Center(child: Text('No hay categorías'))
                      : ListView.builder(
                        itemCount: _categorias.length,
                        itemBuilder: (context, index) {
                          final categoria = _categorias[index];
                          final iconData = IconData(
                            categoria.tipoImagen,
                            fontFamily: 'MaterialSymbols',
                          );

                          return ListTile(
                            leading: Icon(
                              iconData,
                              color:
                                  categoria.tipo == 'Ingreso'
                                      ? Color(0xFF48A6A7)
                                      : Color(0xFF006A71),
                            ),
                            title: Text(categoria.nombre),
                            subtitle: Text(categoria.tipo),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                //Boton Editar
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF48A6A7),
                                  ),
                                  child: IconButton(
                                    onPressed:
                                        () => _llenarFormularioParaEditar(
                                          categoria,
                                        ),
                                    icon: Text(
                                      String.fromCharCode(0xe3c9),
                                      style: TextStyle(
                                        fontFamily: 'MaterialSymbols',
                                        fontSize: 25,
                                        color: Color(0xFFF2EFE7),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                //Boton Eliminar
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF48A6A7),
                                  ),
                                  child: IconButton(
                                    onPressed:
                                        () => _eliminarCategoria(categoria),
                                    icon: Text(
                                      String.fromCharCode(0xe872),
                                      style: TextStyle(
                                        fontFamily: 'MaterialSymbols',
                                        fontSize: 25,
                                        color: Color(0xFFF2EFE7),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Agregar Categoría Nueva',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _tipoSeleccionado,
              onChanged: (value) {
                setState(() {
                  _tipoSeleccionado = value ?? 'Ingreso';
                });
              },
              decoration: InputDecoration(
                labelText: 'Tipo:',
                labelStyle: TextStyle(
                  color:
                      _tipoSeleccionado == 'Ingreso'
                          ? Color(0xFF48A6A7)
                          : Color(0xFF006A71),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        _tipoSeleccionado.isEmpty
                            ? Color(0xFF48A6A7)
                            : Color(0xFF006A71),
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF006a71), width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        _tipoSeleccionado.isEmpty
                            ? Color(0xFF48A6A7)
                            : Color(0xFF006A71),
                    width: 2.0,
                  ),
                ),
              ),
              items:
                  ['Ingreso', 'Gasto']
                      .map(
                        (tipo) =>
                            DropdownMenuItem(value: tipo, child: Text(tipo)),
                      )
                      .toList(),
              dropdownColor: Color(0xFFF2EFE7),
              isExpanded: false,
            ),

            const SizedBox(height: 20),
            TextField(
              controller: _nombreController,
              cursorColor:
                  _tipoSeleccionado == 'Ingreso'
                      ? Color(0xFF48A6A7)
                      : Color(0xFF006A71),
              decoration: InputDecoration(
                labelText: 'Nombre:',
                labelStyle: TextStyle(
                  color:
                      _tipoSeleccionado == 'Ingreso'
                          ? Color(0xFF48A6A7)
                          : Color(0xFF006A71),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        _tipoSeleccionado == 'Ingreso'
                            ? Color(0xFF48A6A7)
                            : Color(0xFF006A71),
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF006A71), width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        _tipoSeleccionado == 'Ingreso'
                            ? Color(0xFF48A6A7)
                            : Color(0xFF006A71),
                    width: 2.0,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.35,
              child: DropdownButtonFormField<String>(
                isDense: true,
                value:
                    _iconoController.text.isNotEmpty
                        ? _iconoController.text
                        : null,
                onChanged: (value) {
                  setState(() {
                    _iconoController.text = value ?? '';
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Ícono',
                  labelStyle: TextStyle(
                    color:
                        _tipoSeleccionado == 'Ingreso'
                            ? Color(0xFF48A6A7)
                            : Color(0xFF006A71),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color:
                          _tipoSeleccionado == 'Ingreso'
                              ? Color(0xFF48A6A7)
                              : Color(0xFF006A71),
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF006A71),
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color:
                          _tipoSeleccionado == 'Ingreso'
                              ? Color(0xFF48A6A7)
                              : Color(0xFF006A71),
                      width: 2.0,
                    ),
                  ),
                ),
                items:
                    iconosDisponibles.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.value.toString(),
                        child: Icon(
                          IconData(entry.value, fontFamily: 'MaterialSymbols'),
                          size: 32,
                          color:
                              _tipoSeleccionado == 'Ingreso'
                                  ? Color(0xFF48A6A7)
                                  : Color(0xFF006A71),
                        ),
                      );
                    }).toList(),
                menuMaxHeight: 80,
                dropdownColor: Color(0xFFF2EFE7),
                isExpanded: false,
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  if (_categoriaEnEdicion != null) {
                    _actualizarCategoria();
                  } else {
                    _insertarCategoria();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF48A6A7),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 75,
                    vertical: 10,
                  ),
                ),
                child: const Text(
                  'Guardar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xfff2efe7),
                    fontSize: 20,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
