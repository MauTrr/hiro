import 'package:flutter/material.dart';
import 'pantalla_principal.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio>
        //Animacion de la imagen del logo
        with
        SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animationScale;
  late Animation<double> _animationOpacity;

  //Inicializacion de Animacion
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animationScale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _animationOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  // Liberación de la animacion
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  //Diseño del Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF006A71), Color(0xFF48A6A7)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 100),

            //Crear el logo animado
            ScaleTransition(
              scale: _animationScale,
              child: FadeTransition(
                opacity: _animationOpacity,
                child: Image.asset(
                  'assets/images/LogoVertical.png',
                  width: 450,
                ),
              ),
            ),

            const SizedBox(height: 30),

            //Texto
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: const Text(
                '¿Listo para gestionar tus finanzas con Hiro?¡Empecemos!',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Color(0xFFF2EFE7),
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            //Creacion del Boton continuar
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF2EFE7),
                padding: const EdgeInsets.symmetric(
                  horizontal: 75,
                  vertical: 15,
                ),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaPrincipal(),
                  ),
                );
              },
              child: const Text(
                'Continuar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xff006A71),
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
