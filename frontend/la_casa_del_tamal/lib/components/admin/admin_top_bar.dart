import 'package:flutter/material.dart';
import 'package:frontend/components/admin/generar_codigo_page.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/gerente/gerent_services.dart';

/// Ícono de perfil con menú dinámico. Se usa en el home (sin
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
    // CORRECCIÓN DEFINITIVA: Inyectamos el fondo oscuro modificando el popupMenuTheme local
    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: const PopupMenuThemeData(
          color: AppEstilos.inputOscuro, // Fuerza el fondo gris oscuro en el menú flotante
        ),
      ),
      child: PopupMenuButton<String>(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppEstilos.bordeOscuro, width: 1),
        ),
        onSelected: (v) {
          if (v == 'generar_codigo') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GenerarCodigoPage()),
            );
          } else if (v == 'cerrar_sesion') {
            _cerrarSesion(context);
          }
        },
        itemBuilder: (BuildContext context) => [
          const PopupMenuItem<String>(
            value: 'generar_codigo',
            child: Row(
              children: [
                Icon(Icons.vpn_key_outlined, color: AppEstilos.verdeBoton, size: 16),
                SizedBox(width: 10),
                Text(
                  'Generar código', 
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(color: Colors.white10),
          const PopupMenuItem<String>(
            value: 'cerrar_sesion',
            child: Row(
              children: [
                Icon(Icons.logout_outlined, color: AppEstilos.rojoVencido, size: 16),
                SizedBox(width: 10),
                Text(
                  'Cerrar sesión', 
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
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
