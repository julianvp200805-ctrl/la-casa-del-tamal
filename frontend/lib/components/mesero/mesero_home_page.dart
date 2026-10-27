import 'package:flutter/material.dart';
import 'package:frontend/components/mesero/estados_pedido_page.dart';
import 'package:frontend/components/mesero/mesero_top_bar.dart';
import 'package:frontend/components/mesero/tomar_pedido_page.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/pantallas/menu/menu_tile.dart';

/// Inicio del mesero: tomar un pedido o revisar cómo va cada uno en cocina.
class MeseroHomePage extends StatelessWidget {
  static const String routeName = '/mesero';
  final String logoAssetPath;

  const MeseroHomePage({super.key, this.logoAssetPath = 'assets/image/logo.png'});

  void _ir(BuildContext context, Widget pagina) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => pagina));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
          child: Column(
            children: [
              const Row(children: [MeseroTitulo(tamano: 34), Spacer(), MeseroPerfil()]),
              const SizedBox(height: 56),
              SizedBox(
                height: 110,
                child: MenuTile(
                  icono: const Icon(Icons.edit_note, color: Color(0xFFFECEA7), size: 38),
                  texto: 'Tomar pedido',
                  onTap: () => _ir(context, const TomarPedidoPage()),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 110,
                child: MenuTile(
                  icono: const Icon(Icons.soup_kitchen, color: Color(0xFFE8714A), size: 38),
                  texto: 'Estados de los pedidos',
                  onTap: () => _ir(context, const EstadosPedidosPage()),
                ),
              ),
              const Spacer(),
              Image.asset(
                logoAssetPath,
                height: 100,
                errorBuilder: (_, __, ___) => const Icon(Icons.house, size: 60, color: AppEstilos.meseroOliva),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}