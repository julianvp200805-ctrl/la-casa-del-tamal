import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/pantallas/principal/pantalla_principal.dart';


class PantallaSplash extends StatefulWidget {
  const PantallaSplash({super.key});

  @override
  State<PantallaSplash> createState() => _PantallaSplashState();
}

class _PantallaSplashState extends State<PantallaSplash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/image/logo.png',
                width: 220,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.restaurant, size: 100, color: AppEstilos.verdeBoton);
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Sabor y tradición',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.white70),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: 160,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    minHeight: 4,
                    backgroundColor: AppEstilos.inputOscuro,
                    valueColor: AlwaysStoppedAnimation(AppEstilos.verdeBoton),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}