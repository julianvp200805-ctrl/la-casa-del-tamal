import 'package:flutter/material.dart';
import 'package:frontend/components/admin/admin_menu.dart';
import 'package:frontend/components/admin/admin_top_bar.dart';
import 'package:frontend/components/chat/chat_fab.dart';
import 'package:frontend/components/productos/inventario_page.dart';
import 'package:frontend/components/ventas/venta_total_card.dart';
import 'package:frontend/components/ventas/ventas_page.dart';
import 'package:frontend/pantallas/menu/menu_tile.dart';
import 'package:frontend/services/pedido/pedido_proceso_page.dart';
import 'package:frontend/services/pedido/pedido_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/core/colores.dart';


/// Página principal del admin - Casa del Tamal
class AdminHomePage extends StatefulWidget {
  static const String routeName = '/admin-home';
  final String logoAssetPath;

  const AdminHomePage({super.key, this.logoAssetPath = 'assets/image/logo.png'});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final PedidoService _pedidoService = PedidoService();
  String _nombreUsuario = 'admin';
  late Future<ReporteVentas> _hoy = _pedidoService.obtenerReporteVentas('diaria');

  @override
  void initState() {
    super.initState();
    _cargarNombreUsuario();
  }

  Future<void> _cargarNombreUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final nombre = prefs.getString('user_name');
    if (nombre != null && nombre.isNotEmpty && mounted) {
      setState(() => _nombreUsuario = nombre);
    }
  }

  // Al volver de otra pantalla se refresca el total de hoy.
  Future<void> _abrir(Widget pagina) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => pagina));
    if (mounted) setState(() => _hoy = _pedidoService.obtenerReporteVentas('diaria'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      floatingActionButton: const ChatFab(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 80),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 22),
                    child: Text('Hola, $_nombreUsuario', style: const TextStyle(color: Colors.white70, fontSize: 20, fontFamily: 'serif')),
                  ),
                  const Spacer(),
                  const AdminPerfil(mostrarEtiqueta: false),
                ],
              ),
              const SizedBox(height: 18),
              _TotalHoy(futuro: _hoy, onReintentar: () => setState(() => _hoy = _pedidoService.obtenerReporteVentas('diaria'))),
              const SizedBox(height: 18),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.0,
                children: [
                  MenuTile(icono: _icono(Icons.show_chart, AppEstilos.verdeBoton, fondo: const Color(0xFFE0E0E0)), texto: 'Ventas', onTap: () => _abrir(const VentasPage())),
                  MenuTile(icono: _icono(Icons.restaurant, Colors.black87, fondo: const Color(0xFFE0E0E0)), texto: 'Pedidos en\nproceso', onTap: () => _abrir(const PedidosProcesoPage())),
                  MenuTile(icono: _icono(Icons.inventory_2, const Color(0xFFD08A4E)), texto: 'Inventario', onTap: () => _abrir(const InventarioPage())),
                  MenuTile(icono: _icono(Icons.edit, const Color(0xFFF0842C)), texto: 'Modificar menu', onTap: () => _abrir(const AdminMenuPage())),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _icono(IconData icono, Color color, {Color? fondo}) {
    final ic = Icon(icono, color: color, size: 26);
    if (fondo == null) return ic;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(8)),
      child: ic,
    );
  }
}

/// Tarjeta verde "ventas de hoy" con el total real del backend.
class _TotalHoy extends StatelessWidget {
  final Future<ReporteVentas> futuro;
  final VoidCallback onReintentar;
  const _TotalHoy({required this.futuro, required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ReporteVentas>(
      future: futuro,
      builder: (context, snap) {
        if (snap.hasError) {
          return GestureDetector(
            onTap: onReintentar,
            child: const VentaTotalCard(etiqueta: 'No se pudo cargar · toca para reintentar'),
          );
        }
        final listo = snap.connectionState == ConnectionState.done;
        return VentaTotalCard(etiqueta: 'ventas de hoy', total: listo ? snap.data!.totalVentas : null);
      },
    );
  }
}