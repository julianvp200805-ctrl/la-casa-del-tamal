import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

/// Botón verde grande (Iniciar sesión, Enviar código, Verificar...).
/// Con [cargando] muestra el indicador y se deshabilita.
class BotonVerde extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  final bool cargando;
  final double alto;
  final double radio;
  final Color colorTexto;
  final Color? colorDeshabilitado;
  final double tamanoSpinner;

  const BotonVerde({
    super.key,
    required this.texto,
    required this.onPressed,
    this.cargando = false,
    this.alto = 56,
    this.radio = 30,
    this.colorTexto = Colors.black,
    this.colorDeshabilitado,
    this.tamanoSpinner = 24,
  });

  /// Versión más baja y menos redonda (pantalla de recuperar contraseña).
  const BotonVerde.compacto({
    super.key,
    required this.texto,
    required this.onPressed,
    this.cargando = false,
  })  : alto = 52,
        radio = 12,
        colorTexto = Colors.black87,
        colorDeshabilitado = null,
        tamanoSpinner = 20;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: alto,
      child: ElevatedButton(
        onPressed: cargando ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppEstilos.verdeBoton,
          disabledBackgroundColor: colorDeshabilitado,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radio),
          ),
        ),
        child: cargando
            ? SizedBox(
                width: tamanoSpinner,
                height: tamanoSpinner,
                child: CircularProgressIndicator(
                  strokeWidth: tamanoSpinner > 20 ? 2.5 : 2,
                  color: Colors.black,
                ),
              )
            : Text(
                texto,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorTexto,
                ),
              ),
      ),
    );
  }
}