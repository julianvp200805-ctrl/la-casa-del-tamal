import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/gerente/gerent_services.dart';

/// Ícono de perfil con menú "Cerrar sesión". Se usa en el home (sin
/// etiqueta) y en la barra superior de las demás pantallas (con "ADMIN").
class AdminPerfil extends StatelessWidget {
  final bool mostrarEtiqueta;
  const AdminPerfil({super.key, this.mostrarEtiqueta = true});

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.account_circle_outlined, color: AppEstilos.verdeBoton, size: 34),
          if (mostrarEtiqueta)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text('ADMIN', style: TextStyle(color: AppEstilos.verdeBoton, fontSize: 12, fontFamily: 'serif', letterSpacing: 0.5)),
            ),
        ],
      ),
    );
  }
}

/// Barra superior: flecha de volver a la izquierda, perfil + ADMIN a la derecha.
class AdminTopBar extends StatelessWidget {
  const AdminTopBar({super.key});

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
          const AdminPerfil(),
        ],
      ),
    );
  }
}