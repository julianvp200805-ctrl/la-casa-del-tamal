import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

/// Hoja inferior oscura de los formularios (Agregar producto / Editar plato):
/// esquinas muy redondeadas y sube cuando aparece el teclado.
class HojaFormulario extends StatelessWidget {
  final String titulo;
  final Widget child;

  const HojaFormulario({super.key, required this.titulo, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
        decoration: const BoxDecoration(
          color: AppEstilos.hojaOscura, 
          borderRadius: BorderRadius.vertical(top: Radius.circular(48)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'serif')),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Caja oscura (opcionalmente tocable) para selectores dentro de la hoja.
class CajaHoja extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const CajaHoja({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppEstilos.inputOscuro,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            width: double.infinity, 
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14), 
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Campo de texto oscuro de la hoja (nombre, precio, lote...).
class CampoHoja extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? teclado;
  final int lineas;

  const CampoHoja({super.key, required this.controller, required this.hint, this.teclado, this.lineas = 1});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: teclado,
        maxLines: lineas,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70, fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          filled: true,
          fillColor: AppEstilos.inputOscuro,
          
          // Borde cuando el campo NO está seleccionado
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          
          // Borde corregido cuando el campo está SIENDO EDITADO
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppEstilos.verdeAccion, width: 1.5),
          ),
        ),
      ),
    );
  }
}
