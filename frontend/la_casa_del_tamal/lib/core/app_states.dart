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
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppEstilos.rojoVencido.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded, color: AppEstilos.rojoVencido, size: 34),
            ),
            const SizedBox(height: 14),
            Text(mensaje, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onReintentar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppEstilos.colorDorado,
                foregroundColor: Colors.black87,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reintentar', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado vacío reutilizable: ícono en un círculo + texto centrado.
class AppEmptyState extends StatelessWidget {
  final String mensaje;
  final IconData icono;
  const AppEmptyState({super.key, required this.mensaje, this.icono = Icons.inbox_outlined});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(icono, color: Colors.white38, size: 34),
            ),
            const SizedBox(height: 14),
            Text(mensaje, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 14, height: 1.4)),
          ],
        ),
      ),
    );
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