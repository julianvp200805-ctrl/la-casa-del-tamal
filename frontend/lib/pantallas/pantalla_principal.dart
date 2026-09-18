import 'package:flutter/material.dart';
import 'package:frontend/components/inicio_sesion.dart';
import 'package:frontend/pantallas/menu.dart';
// NOTA: se elimino la clase LaCasaDelTamalApp que devolvia un MaterialApp.
// El unico MaterialApp de la app vive ahora en main.dart. Tener dos causa
// dos Navigator anidados y hace que SnackBars y "volver atras" fallen.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),
              Image.asset(
                'assets/image/logo.png',
                width: 200,
                height: 300,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 150,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white70),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'LOGO',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  );
                },
              ),
              const Spacer(flex: 3),
              const _MenuButton(),
              const Spacer(flex: 10),
              const Text(
                'El sabor de casa en\ncada tamal.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const InicioSesion()),
                  );
                },
                child: const Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  // CORREGIDO: antes recibia un "onTap" obligatorio que nunca se usaba
  // (se le pasaba un callback vacio y el boton navegaba por su cuenta).
  const _MenuButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MenuPage()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        side: const BorderSide(color: Colors.white, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
      ),
      child: const Text(
        'MENU',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}