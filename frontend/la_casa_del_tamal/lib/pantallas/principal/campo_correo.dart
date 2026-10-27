import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

/// Campo "Correo" de la pantalla de recuperar contraseña.
class CampoCorreo extends StatelessWidget {
  final TextEditingController controller;

  const CampoCorreo({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppEstilos.inputOscuro,
        hintText: 'Correo',
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: const Icon(
          Icons.mail_outline,
          color: Colors.white54,
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }
}