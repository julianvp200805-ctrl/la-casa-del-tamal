import 'package:flutter/material.dart';

/// Título de pantalla (blanco, serif). Por defecto a la izquierda; con
/// `centrado: true` va al centro (pantalla "Mes").
class VentaTituloRow extends StatelessWidget {
  final String titulo;
  final bool centrado;
  const VentaTituloRow({super.key, required this.titulo, this.centrado = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 18, 24, 14),
      child: Align(
        alignment: centrado ? Alignment.center : Alignment.centerLeft,
        child: Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 22, fontFamily: 'serif')),
      ),
    );
  }
}