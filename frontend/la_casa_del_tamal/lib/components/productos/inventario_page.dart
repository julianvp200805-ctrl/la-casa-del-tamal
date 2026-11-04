import 'package:flutter/material.dart';
import 'package:frontend/components/admin/admin_top_bar.dart';
import 'package:frontend/components/productos/productos_page.dart';
import 'package:frontend/components/productos/productos_vencidos_page.dart';
import 'package:frontend/components/ventas/venta_titulo_row.dart';
import 'package:frontend/core/colores.dart';

/// Pestaña "Inventario" del admin: la botonera Productos / Vencidos cambia el
/// contenido en la misma pantalla.
class InventarioPage extends StatefulWidget {
  static const String routeName = '/inventario';

  const InventarioPage({super.key});

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  static const List<String> _titulos = ['Productos', 'Productos vencidos'];
  int _vista = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AdminTopBar(),
            VentaTituloRow(titulo: _titulos[_vista]),
            BotoneraSegmentada(
              opciones: const ['Productos', 'Vencidos'],
              indiceActivo: _vista,
              onTap: (i) => setState(() => _vista = i),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: IndexedStack(
                index: _vista,
                children: const [
                  ProductosVista(),
                  VencidosVista(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
