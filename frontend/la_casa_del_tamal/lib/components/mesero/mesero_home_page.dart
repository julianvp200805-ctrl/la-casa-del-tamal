import 'package:flutter/material.dart';
import 'package:frontend/components/mesero/estados_pedido_page.dart';
import 'package:frontend/components/mesero/mesero_top_bar.dart';
import 'package:frontend/components/mesero/tomar_pedido_page.dart';
import 'package:frontend/core/colores.dart';

/// Inicio del mesero: tomar un pedido o revisar cómo va cada uno en cocina.
class MeseroHomePage extends StatelessWidget {
  static const String routeName = '/mesero';
  static const double _anchoDiseno = 289; // ancho del marco en el diseño
  final String logoAssetPath;

  const MeseroHomePage({
    super.key,
    this.logoAssetPath = 'assets/image/logo.png',
  });

  void _ir(BuildContext context, Widget pagina) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => pagina));
  }

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.of(context).size.width;
    final s = (ancho / _anchoDiseno).clamp(1.0, 1.6).toDouble();

    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(30 * s, 30 * s, 30 * s, 24 * s),
          child: Column(
            children: [
              const Row(
                children: [
                  MeseroTitulo(tamano: 34),
                  Spacer(),
                  MeseroPerfil(),
                ],
              ),
              SizedBox(height: 60 * s),
              _BotonMesero(
                escala: s,
                texto: 'Tomar pedido',
                imagenPath: 'assets/image/tomar_pedido.png',
                alturaIcono: 48,
                iconoRespaldo: Icons.edit_note,
                colorRespaldo: const Color(0xFFFECEA7),
                onTap: () => _ir(context, const TomarPedidoPage()),
              ),
              SizedBox(height: 16 * s),
              _BotonMesero(
                escala: s,
                texto: 'Estados de los pedidos',
                imagenPath: 'assets/image/estados_pedido.png',
                alturaIcono: 54,
                iconoRespaldo: Icons.soup_kitchen,
                colorRespaldo: const Color(0xFFE8714A),
                onTap: () => _ir(context, const EstadosPedidosPage()),
              ),
              const Spacer(),
              Image.asset(
                logoAssetPath,
                height: 75 * s,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.house,
                  size: 60 * s,
                  color: AppEstilos.meseroOliva,
                ),
              ),
              SizedBox(height: 40 * s),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botón del inicio: icono arriba a la izquierda y texto debajo.
/// Medidas del diseño: 229 x 107, esquinas redondeadas, 16 de separación.
class _BotonMesero extends StatelessWidget {
  final double escala;
  final String texto;
  final String imagenPath;
  final double alturaIcono;
  final IconData iconoRespaldo;
  final Color colorRespaldo;
  final VoidCallback onTap;

  const _BotonMesero({
    required this.escala,
    required this.texto,
    required this.imagenPath,
    required this.alturaIcono,
    required this.iconoRespaldo,
    required this.colorRespaldo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = escala;
    final borde = BorderRadius.circular(24 * s);
    return Material(
      color: const Color(0xFF1C2A24),
      borderRadius: borde,
      child: InkWell(
        borderRadius: borde,
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 107 * s,
          padding: EdgeInsets.fromLTRB(26 * s, 14 * s, 16 * s, 12 * s),
          decoration: BoxDecoration(
            borderRadius: borde,
            border: Border.all(color: const Color(0xFF2E3D36), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                imagenPath,
                height: alturaIcono * s,
                errorBuilder: (_, __, ___) => Icon(
                  iconoRespaldo,
                  size: alturaIcono * s,
                  color: colorRespaldo,
                ),
              ),
              Text(
                texto,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15 * s,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}