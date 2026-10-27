import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

/// Tarjeta cuadrada del home: ícono arriba, texto abajo.
class MenuTile extends StatelessWidget {
  final Widget icono;
  final String texto;
  final VoidCallback onTap;

  const MenuTile({super.key, required this.icono, required this.texto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppEstilos.inputOscuro,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26), side: const BorderSide(color: AppEstilos.bordeOscuro)),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              icono,
              Text(texto, style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'serif')),
            ],
          ),
        ),
      ),
    );
  }
}