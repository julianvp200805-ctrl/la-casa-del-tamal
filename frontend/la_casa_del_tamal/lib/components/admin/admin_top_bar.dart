import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

/// Ícono de perfil con menú dinámico. Se usa en el home (sin
/// etiqueta) y en la barra superior de las demás pantallas (con "ADMIN").
class AdminPerfil extends StatelessWidget {
  final bool mostrarEtiqueta;
  const AdminPerfil({super.key, this.mostrarEtiqueta = true});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Scaffold.of(context).openEndDrawer(),
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
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const Spacer(),
          const AdminPerfil(),
        ],
      ),
    );
  }
}
