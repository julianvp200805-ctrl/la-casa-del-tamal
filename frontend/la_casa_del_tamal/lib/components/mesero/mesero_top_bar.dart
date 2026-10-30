import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/gerente/gerent_services.dart';

class MeseroTitulo extends StatelessWidget {
  final double tamano;
  const MeseroTitulo({super.key, this.tamano = 20});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Mesero', style: TextStyle(color: AppEstilos.meseroOliva, fontSize: tamano, fontFamily: 'serif')),
          const SizedBox(width: 4),
          Icon(Icons.receipt_long, color: AppEstilos.meseroOliva, size: tamano * 0.6),
        ],
      );
}

class MeseroPerfil extends StatelessWidget {
  const MeseroPerfil({super.key});

  Future<void> _cerrarSesion(BuildContext context) async {
    await UserService().cerrarSesion();
    if (!context.mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
        color: AppEstilos.platoMesero,
        onSelected: (v) {
          if (v == 'cerrar_sesion') _cerrarSesion(context);
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'cerrar_sesion', child: Text('Cerrar sesión', style: TextStyle(color: Colors.white))),
        ],
        child: const Icon(Icons.account_circle_outlined, color: AppEstilos.meseroOliva, size: 38),
      );
}

/// Salir a la izquierda; perfil y "Mesero" debajo, a la derecha.
class MeseroTopBar extends StatelessWidget {
  const MeseroTopBar({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 24, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.logout, color: Colors.white70, size: 28),
              ),
            ),
            const Spacer(),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [MeseroPerfil(), SizedBox(height: 2), MeseroTitulo(tamano: 17)],
            ),
          ],
        ),
      );
}