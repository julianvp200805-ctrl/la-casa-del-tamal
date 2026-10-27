import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/gerente/gerent_services.dart';

/// Texto "Mesero" con su ícono de libreta (como en el diseño).
class MeseroTitulo extends StatelessWidget {
  final double tamano;
  const MeseroTitulo({super.key, this.tamano = 20});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Mesero', style: TextStyle(color: AppEstilos.meseroOliva, fontSize: tamano, fontFamily: 'serif')),
        const SizedBox(width: 4),
        Icon(Icons.receipt_long, color: AppEstilos.meseroOliva, size: tamano * 0.6),
      ],
    );
  }
}

/// Ícono de perfil con el menú "Cerrar sesión".
class MeseroPerfil extends StatelessWidget {
  const MeseroPerfil({super.key});

  Future<void> _cerrarSesion(BuildContext context) async {
    await UserService().cerrarSesion();
    if (!context.mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (v) {
        if (v == 'cerrar_sesion') _cerrarSesion(context);
      },
      itemBuilder: (_) => const [PopupMenuItem(value: 'cerrar_sesion', child: Text('Cerrar sesión'))],
      child: const Icon(Icons.account_circle_outlined, color: AppEstilos.meseroOliva, size: 38),
    );
  }
}

/// Barra superior de las pantallas del mesero: volver a la izquierda,
/// perfil y "Mesero" a la derecha.
class MeseroTopBar extends StatelessWidget {
  const MeseroTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.subdirectory_arrow_left, color: Colors.white),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const Spacer(),
          const Column(children: [MeseroPerfil(), SizedBox(height: 2), MeseroTitulo(tamano: 17)]),
        ],
      ),
    );
  }
}