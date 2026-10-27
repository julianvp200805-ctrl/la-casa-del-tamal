import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

/// Campo de texto oscuro con ojo para mostrar/ocultar (contraseñas).
class CampoOscuro extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool esPassword;
  final ValueChanged<String>? onChanged;

  const CampoOscuro({super.key, required this.controller, required this.hint, this.esPassword = true, this.onChanged});

  @override
  State<CampoOscuro> createState() => _CampoOscuroState();
}

class _CampoOscuroState extends State<CampoOscuro> {
  bool _oculto = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppEstilos.inputOscuro,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppEstilos.bordeOscuro),
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.esPassword && _oculto,
        onChanged: widget.onChanged,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(color: Colors.white54, fontSize: 12),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          suffixIcon: widget.esPassword
              ? IconButton(
                  icon: Icon(_oculto ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white70, size: 18),
                  onPressed: () => setState(() => _oculto = !_oculto),
                )
              : null,
        ),
      ),
    );
  }
}