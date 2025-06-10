import 'package:flutter/material.dart';
import 'views/principal.dart';
import 'views/agregar.dart';
import 'views/historial.dart';
import 'views/categorias.dart';
import 'views/graficas.dart';
import 'models/transaccion.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => PantallaPrincipalState();
}

class PantallaPrincipalState extends State<PantallaPrincipal> {
  // Estado de la pantalla principal
  int _selectedIndex = 0;
  // Claves globales para controlar las otras pantallas
  final GlobalKey<DashboardState> dashboardKey = GlobalKey<DashboardState>();
  final GlobalKey<TransaccionScreenState> transaccionScreenKey =
      GlobalKey<TransaccionScreenState>();
  final GlobalKey<GraficasState> graficasKey = GlobalKey<GraficasState>();

  final GlobalKey<HistorialState> historialKey = GlobalKey<HistorialState>();

  //Lista de todas las pantallas
  late final List<Widget> screens = [
    Dashboard(key: dashboardKey),
    TransaccionScreen(key: transaccionScreenKey),
    Historial(key: historialKey),
    CategoriaScreen(),
    Graficas(key: graficasKey),
  ];

  //Funcion para editar una transaccion desde el historial
  void editarTransaccionDesdeHistorial(Transaccion transaccion) {
    setState(() {
      _selectedIndex = 1; // Muestra TransaccionScreen
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      transaccionScreenKey.currentState?.cargarTransaccionParaEditar(
        transaccion,
      );
    });
  }

  // Funcion para cambiar de  pantalla (cambia la vista actual y recarga los datos)
  void cambiarPantalla(int index) {
    setState(() {
      _selectedIndex = index;

      if (index == 2) {
        historialKey.currentState?.cargarTransacciones();
        historialKey.currentState?.actualizarResumen();
      } else if (index == 4) {
        graficasKey.currentState?.actualizarDatos();
        dashboardKey.currentState?.recargar();
      }
    });
  }

  // Funcion que permite recargar toda la informacion despues de que se inserta o se inserta o edita una transaccion
  void recargarDatosGlobales() {
    historialKey.currentState?.cargarTransacciones();
    historialKey.currentState?.actualizarResumen();
    dashboardKey.currentState?.recargar();
    graficasKey.currentState
        ?.actualizarDatos(); // si quieres que también se recargue el gráfico
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Creacion de la barra superior de la aplicacion
      appBar: AppBar(
        backgroundColor: const Color(0xFF48A6A7),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 3.5),
              child: Image.asset(
                'assets/images/LogoLateral.png',
                height: 85,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
      //Contenido de las pantallas, muestra solo una vista de una pantalla, pero mantiene las otras en la memoria
      body: IndexedStack(index: _selectedIndex, children: screens),
      backgroundColor: Color(0xFFF2EFE7),

      //Creacion de la barra de navegacion inferior
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (value) {
          setState(() {
            _selectedIndex = value;

            if (value == 1) {
              transaccionScreenKey.currentState?.recargarCategorias();
            }
          });
        },
        backgroundColor: Color(0xFF48A6A7),
        selectedItemColor: Colors.white,
        unselectedItemColor: Color(0xFFF2EFE7),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            // Utilizar la fuente de MaterialIcons con unicode para mostrar iconos personalizados
            icon: Text(
              String.fromCharCode(0xe88a),
              style: TextStyle(
                fontFamily: 'MaterialSymbols',
                fontSize: 25,
                color: Color(0xFFF2EFE7),
                fontVariations: [FontVariation('FILL', 1)],
              ),
            ),
            activeIcon: Text(
              String.fromCharCode(0xe88a),
              style: TextStyle(
                fontFamily: 'MaterialSymbols',
                fontSize: 25,
                color: Color(0xFFFFFFFF),
                fontVariations: [FontVariation('FILL', 1)],
              ),
            ),
            label: 'Inicio',
            backgroundColor: Color(0xFF48A6A7),
          ),
          BottomNavigationBarItem(
            icon: Text(
              String.fromCharCode(0xe147),
              style: TextStyle(
                fontFamily: 'MaterialSymbols',
                fontSize: 25,
                color: Color(0xFFF2EFE7),
                fontVariations: [FontVariation('FILL', 1)],
              ),
            ),
            label: 'Inicio',
            backgroundColor: Color(0xFF48A6A7),
          ),
          BottomNavigationBarItem(
            icon: Text(
              String.fromCharCode(0xe0ee),
              style: TextStyle(
                fontFamily: 'MaterialSymbols',
                fontSize: 25,
                color: Color(0xFFF2EFE7),
                fontVariations: [FontVariation('FILL', 1)],
              ),
            ),
            label: 'Inicio',
            backgroundColor: Color(0xFF48A6A7),
          ),
          BottomNavigationBarItem(
            icon: Text(
              String.fromCharCode(0xe866),
              style: TextStyle(
                fontFamily: 'MaterialSymbols',
                fontSize: 25,
                color: Color(0xFFF2EFE7),
                fontVariations: [FontVariation('FILL', 1)],
              ),
            ),
            label: 'Inicio',
            backgroundColor: Color(0xFF48A6A7),
          ),
          BottomNavigationBarItem(
            icon: Text(
              String.fromCharCode(0xf190),
              style: TextStyle(
                fontFamily: 'MaterialSymbols',
                fontSize: 25,
                color: Color(0xFFF2EFE7),
                fontVariations: [FontVariation('FILL', 1)],
              ),
            ),
            label: 'Agregar',
            backgroundColor: Color(0xFF48A6A7),
          ),
        ],
      ),
    );
  }
}
