import 'package:flutter/material.dart';
import 'app_estilos.dart';

/// Estado de error reutilizable: ícono + mensaje + botón "Reintentar".
class AppErrorState extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintentar;

  const AppErrorState({super.key, required this.mensaje, required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 40),
            const SizedBox(height: 12),
            Text(mensaje, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onReintentar,
              style: ElevatedButton.styleFrom(backgroundColor: AppEstilos.colorDorado),
              child: const Text('Reintentar', style: TextStyle(color: Colors.black87)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado vacío reutilizable: solo un texto centrado.
class AppEmptyState extends StatelessWidget {
  final String mensaje;
  const AppEmptyState({super.key, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(mensaje, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)));
  }
}

/// Botón dorado con sombra, usado en los formularios de auth.
class GoldButton extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final bool cargando;

  const GoldButton({super.key, required this.texto, required this.onPressed, this.cargando = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), boxShadow: AppEstilos.sombraSuave),
      child: ElevatedButton(
        onPressed: cargando ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppEstilos.colorDorado,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: cargando
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(texto, style: const TextStyle(color: Colors.black87, fontFamily: 'serif', fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}