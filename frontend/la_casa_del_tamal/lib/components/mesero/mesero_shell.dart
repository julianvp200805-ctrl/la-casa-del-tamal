import 'package:flutter/material.dart';
import 'package:frontend/components/mesero/estados_pedido_page.dart';
import 'package:frontend/components/mesero/tomar_pedido_page.dart';
import 'package:frontend/core/colores.dart';

/// Las 2 pestañas del mesero de la maqueta: la barra sustituye el antiguo
/// menú de botones (Tomar pedido, Estados de los pedidos).
const List<PestanaNav> pestanasMesero = [
  PestanaNav(texto: 'Tomar pedido', icono: Icons.edit_note, pagina: TomarPedidoPage()),
  PestanaNav(texto: 'Pedidos', icono: Icons.checklist_rounded, pagina: EstadosPedidosPage()),
];

final ValueNotifier<int> pestanaMeseroActiva = ValueNotifier<int>(0);

class MeseroShell extends StatelessWidget {
  static const String routeName = '/mesero';

  const MeseroShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ShellConBarra(
      controlador: pestanaMeseroActiva,
      colorActivo: AppEstilos.meseroOliva,
      pestanas: pestanasMesero,
    );
  }
}
