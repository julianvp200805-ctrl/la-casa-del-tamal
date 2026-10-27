import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

/// Campo oscuro del login con ícono a la izquierda. Si es contraseña lleva
/// el ojito para mostrarla y el borde verde del diseño.
class CampoLogin extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icono;
  final bool esPassword;

  const CampoLogin({super.key, required this.controller, required this.hint, required this.icono, this.esPassword = false});

  @override
  State<CampoLogin> createState() => _CampoLoginState();
}

class _CampoLoginState extends State<CampoLogin> {
  bool _oculto = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppEstilos.inputOscuro,
        borderRadius: BorderRadius.circular(12),
        border: widget.esPassword ? Border.all(color: AppEstilos.verdeBoton, width: 1.2) : null,
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.esPassword && _oculto,
        keyboardType: widget.esPassword ? TextInputType.text : TextInputType.emailAddress,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(widget.icono, color: Colors.white54, size: 20),
          suffixIcon: widget.esPassword
              ? IconButton(
                  icon: Icon(_oculto ? Icons.visibility_off : Icons.visibility, color: Colors.white54, size: 20),
                  onPressed: () => setState(() => _oculto = !_oculto),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}