import 'package:flutter/material.dart';
import 'package:frontend/components/mesero/estados_pedido_page.dart';
import 'package:frontend/components/mesero/mesero_top_bar.dart';
import 'package:frontend/components/mesero/tomar_pedido_page.dart';
import 'package:frontend/core/colores.dart';

class MeseroHomePage extends StatelessWidget {
  static const String routeName = '/mesero';
  static const double _anchoDiseno = 289;
  final String logoAssetPath;

  const MeseroHomePage({super.key, this.logoAssetPath = 'assets/image/logo.png'});

  void _ir(BuildContext context, Widget pagina) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => pagina));

  @override
  Widget build(BuildContext context) {
    final s = (MediaQuery.of(context).size.width / _anchoDiseno).clamp(1.0, 1.6).toDouble();
    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(30 * s, 30 * s, 30 * s, 24 * s),
          child: Column(
            children: [
              const Row(children: [MeseroTitulo(tamano: 34), Spacer(), MeseroPerfil()]),
              SizedBox(height: 60 * s),
              _Boton(
                s: s,
                texto: 'Tomar pedido',
                imagen: 'assets/image/tomar_pedido.png',
                alto: 48,
                respaldo: Icons.edit_note,
                color: const Color(0xFFFECEA7),
                onTap: () => _ir(context, const TomarPedidoPage()),
              ),
              SizedBox(height: 16 * s),
              _Boton(
                s: s,
                texto: 'Estados de los pedidos',
                imagen: 'assets/image/estados_pedido.png',
                alto: 54,
                respaldo: Icons.soup_kitchen,
                color: const Color(0xFFE8714A),
                onTap: () => _ir(context, const EstadosPedidosPage()),
              ),
              const Spacer(),
              Image.asset(
                logoAssetPath,
                height: 75 * s,
                errorBuilder: (_, __, ___) => Icon(Icons.house, size: 60 * s, color: AppEstilos.meseroOliva),
              ),
              SizedBox(height: 40 * s),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta 229 x 107, radio 24, icono arriba-izquierda y texto debajo.
class _Boton extends StatelessWidget {
  final double s, alto;
  final String texto, imagen;
  final IconData respaldo;
  final Color color;
  final VoidCallback onTap;

  const _Boton({
    required this.s,
    required this.texto,
    required this.imagen,
    required this.alto,
    required this.respaldo,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borde = BorderRadius.circular(24 * s);
    return Material(
      color: AppEstilos.tablaInventario,
      borderRadius: borde,
      child: InkWell(
        borderRadius: borde,
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 107 * s,
          padding: EdgeInsets.fromLTRB(26 * s, 14 * s, 16 * s, 12 * s),
          decoration: BoxDecoration(borderRadius: borde, border: Border.all(color: AppEstilos.bordeOscuro)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(imagen,
                  height: alto * s, errorBuilder: (_, __, ___) => Icon(respaldo, size: alto * s, color: color)),
              Text(texto, style: TextStyle(color: Colors.white, fontSize: 15 * s, fontFamily: 'serif')),
            ],
          ),
        ),
      ),
    );
  }
}