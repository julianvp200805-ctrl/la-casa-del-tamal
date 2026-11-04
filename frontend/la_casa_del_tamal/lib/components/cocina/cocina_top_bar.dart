import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/gerente/gerent_services.dart';

/// "Cocina" en ámbar con su glyph, como en las maquetas 30-32.
class CocinaTitulo extends StatelessWidget {
  final double tamano;
  const CocinaTitulo({super.key, this.tamano = 17});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Cocina', style: TextStyle(color: AppEstilos.acentoCocina, fontSize: tamano, fontFamily: 'serif')),
          const SizedBox(width: 3),
          Icon(Icons.undo, color: AppEstilos.acentoCocina, size: 14),
        ],
      );
}

class CocinaPerfil extends StatelessWidget {
  const CocinaPerfil({super.key});

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
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_circle_outlined, color: AppEstilos.acentoCocina, size: 34),
            SizedBox(height: 2),
            CocinaTitulo(),
          ],
        ),
      );
}

/// Flecha de volver a la izquierda; perfil y "Cocina" a la derecha.
class CocinaTopBar extends StatelessWidget {
  const CocinaTopBar({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 24, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.subdirectory_arrow_left, color: Colors.white),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            const Spacer(),
            const CocinaPerfil(),
          ],
        ),
      );
}

/// Título serif de las pantallas de cocina ("Bandeja Pedidos", "Comida").
class TituloCocina extends StatelessWidget {
  final String texto;
  const TituloCocina({super.key, required this.texto});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(texto, style: const TextStyle(color: Colors.white70, fontSize: 24, fontFamily: 'serif')),
        ),
      );
}
