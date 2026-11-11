import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/colores.dart';

/// Campo de texto de los formularios: fondo sutil, borde claro y borde
/// verde al enfocarlo. Si es contraseña trae el ojito para mostrarla.
/// El teclado, los formateadores y la capitalización se ajustan por campo.
class CampoInicio extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icono;
  final bool esPassword;
  final String? Function(String?)? validator;
  final TextInputType teclado;
  final List<TextInputFormatter>? formateadores;
  final TextCapitalization capitalizacion;
  final int? maxLength;

  const CampoInicio({
    super.key,
    required this.controller,
    required this.hint,
    required this.icono,
    this.esPassword = false,
    this.validator,
    this.teclado = TextInputType.text,
    this.formateadores,
    this.capitalizacion = TextCapitalization.none,
    this.maxLength,
  });

  @override
  State<CampoInicio> createState() => _CampoInicioState();
}

class _CampoInicioState extends State<CampoInicio> {
  bool _oculto = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.esPassword ? TextInputType.text : widget.teclado,
      inputFormatters: widget.formateadores,
      textCapitalization: widget.capitalizacion,
      maxLength: widget.maxLength,
      obscureText: widget.esPassword && _oculto,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: const TextStyle(color: Colors.white54, fontSize: 15),
        counterText: '',
        prefixIcon: Icon(widget.icono, color: AppEstilos.verdeBoton),
        suffixIcon: widget.esPassword
            ? IconButton(
                icon: Icon(
                  _oculto
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white54,
                ),
                onPressed: () => setState(() => _oculto = !_oculto),
              )
            : null,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.07),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppEstilos.verdeBoton, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}