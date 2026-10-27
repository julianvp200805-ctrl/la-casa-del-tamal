import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

/// Campo de texto redondeado con sombra, igual al de login/recuperar.
class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool esPassword;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.esPassword = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _ocultar = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppEstilos.colorInput,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppEstilos.sombraSuave,
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.esPassword ? _ocultar : false,
        keyboardType: widget.esPassword
            ? TextInputType.text
            : TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Colors.black45),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          suffixIcon: widget.esPassword
              ? IconButton(
                  icon: Icon(
                    _ocultar ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black45,
                  ),
                  onPressed: () => setState(() => _ocultar = !_ocultar),
                )
              : null,
        ),
      ),
    );
  }
}