import 'package:flutter/material.dart';
import 'package:frontend/components/admin/admin_menu.dart';
import 'package:frontend/components/chat/chat_fab.dart';
import 'package:frontend/components/productos/inventario_page.dart';
import 'package:frontend/components/ventas/ventas_page.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/pedido/pedido_proceso_page.dart';

/// Las 4 pestañas del admin, con su pantalla. Compartidas por las pantallas
/// hijas (Codigo de acceso) que muestran la barra sin pestana activa.
const List<PestanaNav> pestanasAdmin = [
  PestanaNav(texto: 'Ventas', icono: Icons.bar_chart_rounded, pagina: VentasPage()),
  PestanaNav(texto: 'Pedidos', icono: Icons.point_of_sale, pagina: PedidosProcesoPage()),
  PestanaNav(texto: 'Inventario', icono: Icons.device_hub_rounded, pagina: InventarioPage()),
  PestanaNav(texto: 'Menú', icono: Icons.restaurant_rounded, pagina: AdminMenuPage()),
];

/// Pestaña visible del shell; las pantallas hijas la escriben al volver.
final ValueNotifier<int> pestanaAdminActiva = ValueNotifier<int>(0);

/// Pantalla del admin: las pestañas de la barra sustituyen el antiguo menú
/// de botones (Ventas, Pedidos, Inventario, Menú).
class AdminShell extends StatelessWidget {
  static const String routeName = '/admin';

  const AdminShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ShellConBarra(
      controlador: pestanaAdminActiva,
      botonFlotante: const ChatFab(),
      pestanas: pestanasAdmin,
    );
  }
}
