import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/pantallas/principal/pantalla_cargas.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // CORREGIDO: antes habia un MaterialApp aqui con
    // "home: Scaffold(body: LaCasaDelTamalApp())", y LaCasaDelTamalApp
    // devolvia OTRO MaterialApp adentro. Eso anida dos apps (dos Navigator,
    // dos temas) y rompe cosas como los SnackBar y el boton de volver.
    // Ahora solo hay UN MaterialApp y la pantalla inicial es HomeScreen.
    return MaterialApp(
      title: 'La Casa del Tamal',
      debugShowCheckedModeBanner: false,
      theme: _tema,
      home: const PantallaSplash(),
    );
  }

  // Tema global: los botones, inputs y tarjetas salen ya estilizados en
  // toda la app sin tener que configurarlos pantalla por pantalla.
  ThemeData get _tema {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppEstilos.headerInicio,
        primary: AppEstilos.headerInicio,
        secondary: AppEstilos.colorDorado,
      ),
      scaffoldBackgroundColor: AppEstilos.fondoClaro,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppEstilos.headerInicio,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppEstilos.botonVerde,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppEstilos.radioBoton),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppEstilos.botonVerde, width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}