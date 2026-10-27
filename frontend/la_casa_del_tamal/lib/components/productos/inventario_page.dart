import 'package:flutter/material.dart';
import 'package:frontend/components/admin/admin_top_bar.dart';
import 'package:frontend/components/chat/chat_fab.dart';
import 'package:frontend/components/productos/productos_page.dart';
import 'package:frontend/components/productos/productos_vencidos_page.dart';
import 'package:frontend/components/ventas/venta_titulo_row.dart';
import 'package:frontend/core/colores.dart';

/// Inventario: entrada a "Productos vencidos" y "Productos".
class InventarioPage extends StatelessWidget {
  static const String routeName = '/inventario';
  final String logoAssetPath;

  const InventarioPage({super.key, this.logoAssetPath = 'assets/image/logo.png'});

  void _ir(BuildContext context, Widget pagina) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => pagina));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      floatingActionButton: const ChatFab(),
      body: SafeArea(
        child: Column(
          children: [
            const AdminTopBar(),
            const VentaTituloRow(titulo: 'Inventario'),
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _construirBotonMenu(
                      context,
                      texto: 'Productos vencidos',
                      icono: Icons.restaurant_menu_outlined, // Icono similar a cubiertos con alerta
                      colorIcono: const Color(0xFF64B5F6),
                      onTap: () => _ir(context, const ProductosVencidosPage()),
                    ),
                    const SizedBox(height: 20),
                    _construirBotonMenu(
                      context,
                      texto: 'Productos',
                      icono: Icons.bakery_dining_outlined, // Icono representativo para comida/productos
                      colorIcono: const Color(0xFFFFB74D),
                      onTap: () => _ir(context, const ProductosPage()),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Image.asset(
                logoAssetPath,
                height: 90,
                errorBuilder: (_, __, ___) => const Icon(Icons.house, size: 60, color: AppEstilos.verdeBoton),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye un botón de menú grande, estético y centrado
  Widget _construirBotonMenu(
    BuildContext context, {
    required String texto,
    required IconData icono,
    required Color colorIcono,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 120, // Altura cómoda para visualización premium
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppEstilos.inputOscuro, // Fondo gris oscuro unificado de la app
        borderRadius: BorderRadius.circular(20), // Bordes curvos idénticos a los del mockup
        border: Border.all(color: Colors.white.withValues(alpha: 0.04), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                // Contenedor del icono con un ligero brillo de fondo
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorIcono.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icono, color: colorIcono, size: 38), // Icono más grande y visible
                ),
                const SizedBox(width: 20),
                // Texto del botón integrado de forma limpia
                Expanded(
                  child: Text(
                    texto,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withValues(alpha: 0.3),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}