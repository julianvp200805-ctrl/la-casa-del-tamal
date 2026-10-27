import 'package:flutter/material.dart';
import 'package:frontend/components/admin/admin_top_bar.dart';
import 'package:frontend/components/chat/chat_fab.dart';
import 'package:frontend/components/ventas/venta_mes.dart';
import 'package:frontend/components/ventas/venta_semanal.dart';
import 'package:frontend/components/ventas/venta_titulo_row.dart';
import 'package:frontend/components/ventas/ventas_diarias.dart';
import 'package:frontend/core/colores.dart';

/// Pantalla "Ventas" del admin: Diarias / De la semana / Mensuales.
class VentasPage extends StatelessWidget {
  static const String routeName = '/ventas';
  final String logoAssetPath;

  const VentasPage({super.key, this.logoAssetPath = 'assets/image/logo.png'});

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
            const VentaTituloRow(titulo: 'Ventas'),
            const SizedBox(height: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _Fila(
                      icono: Icons.calendar_today_rounded, 
                      color: const Color(0xFF2D8CFF), 
                      texto: 'Diarias', 
                      onTap: () => _ir(context, const VentasDiariasPage()),
                    ),
                    const SizedBox(height: 4),
                    _Fila(
                      icono: Icons.bar_chart_rounded, 
                      color: const Color(0xFFFFB74D), 
                      texto: 'De la semana', 
                      onTap: () => _ir(context, const VentasSemanaPage()),
                    ),
                    const SizedBox(height: 4),
                    _Fila(
                      icono: Icons.calendar_month_rounded, 
                      color: Colors.white, 
                      texto: 'Mensuales', 
                      onTap: () => _ir(context, const VentasMesPage()),
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
}

class _Fila extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String texto;
  final VoidCallback onTap;

  const _Fila({required this.icono, required this.color, required this.texto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppEstilos.inputOscuro,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.04), width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icono, color: color, size: 30),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Text(
                      texto, 
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 16, 
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded, 
                    color: Colors.white.withValues(alpha: 0.25), 
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}