import 'package:flutter/material.dart';
import 'package:frontend/components/cocina/cocina_comida_page.dart';
import 'package:frontend/components/cocina/cocina_pedidos_page.dart';
import 'package:frontend/core/colores.dart';

/// Las 2 pestañas de cocina: la barra sustituye el antiguo menú de botones
/// (Bandeja Pedidos, Comida).
const List<PestanaNav> pestanasCocina = [
  PestanaNav(texto: 'Bandeja', icono: Icons.assignment_rounded, pagina: CocinaPedidosPage()),
  PestanaNav(texto: 'Comida', icono: Icons.ramen_dining_rounded, pagina: CocinaComidaPage()),
];

final ValueNotifier<int> pestanaCocinaActiva = ValueNotifier<int>(0);

class CocinaShell extends StatelessWidget {
  static const String routeName = '/cocina';

  const CocinaShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ShellConBarra(
      controlador: pestanaCocinaActiva,
      colorActivo: AppEstilos.acentoCocina,
      pestanas: pestanasCocina,
    );
  }
}
