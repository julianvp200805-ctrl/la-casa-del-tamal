import 'package:flutter/material.dart';
import 'package:frontend/components/admin/admin_top_bar.dart';
import 'package:frontend/components/ventas/venta_mes.dart';
import 'package:frontend/components/ventas/venta_semanal.dart';
import 'package:frontend/components/ventas/venta_titulo_row.dart';
import 'package:frontend/components/ventas/ventas_diarias.dart';
import 'package:frontend/core/colores.dart';

/// Pestaña "Ventas" del admin: la botonera Diario / Semana / Mes cambia el
/// contenido en la misma pantalla, como en las maquetas.
class VentasPage extends StatefulWidget {
  static const String routeName = '/ventas';

  const VentasPage({super.key});

  @override
  State<VentasPage> createState() => _VentasPageState();
}

class _VentasPageState extends State<VentasPage> {
  static const List<String> _titulos = ['Ventas diarias', 'Semana', 'Mes'];
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
            VentaTituloRow(titulo: _titulos[_vista], centrado: _vista == 2),
            BotoneraSegmentada(
              opciones: const ['Diario', 'Semana', 'Mes'],
              indiceActivo: _vista,
              onTap: (i) => setState(() => _vista = i),
            ),
            const SizedBox(height: 16),
            // IndexedStack: cada vista conserva su fecha/mes elegido y su
            // consulta ya hecha al cambiar de botonera.
            Expanded(
              child: IndexedStack(
                index: _vista,
                children: const [
                  VentasDiariasVista(),
                  VentasSemanaVista(),
                  VentasMesVista(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
