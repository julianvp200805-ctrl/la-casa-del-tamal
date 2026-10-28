import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cocina_comida_page.dart';
import 'cocina_pedidos_page.dart';

class CocinaHomePage extends StatefulWidget {
  const CocinaHomePage({super.key});

  @override
  State<CocinaHomePage> createState() => _CocinaHomePageState();
}

class _CocinaHomePageState extends State<CocinaHomePage> {
  String _nombreUsuario = 'Cocina';

  @override
  void initState() {
    super.initState();
    _cargarNombre();
  }

  Future<void> _cargarNombre() async {
    final prefs = await SharedPreferences.getInstance();
    final nombre = prefs.getString('user_name');
    if (nombre != null && nombre.isNotEmpty && mounted) {
      setState(() => _nombreUsuario = nombre);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ENFOQUE NUEVO: ListTile resuelve la separación y alineación de forma limpia sin usar Row ni mainAxisAlignment
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Cocina ($_nombreUsuario)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'serif',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: CircleAvatar(
                  backgroundColor: AppEstilos.inputOscuro,
                  child: const Icon(Icons.person, color: AppEstilos.verdeBoton),
                ),
              ),
              const Spacer(),
              _buildBotonMenu(
                context,
                icon: Icons.assignment_outlined,
                titulo: 'Bandeja Pedidos',
                destino: const CocinaPedidosPage(),
              ),
              const SizedBox(height: 20),
              _buildBotonMenu(
                context,
                icon: Icons.outdoor_grill_outlined,
                titulo: 'Comida',
                destino: const CocinaComidaPage(),
              ),
              const Spacer(),
              Center(
                child: Image.asset(
                  'assets/image/logo.png',
                  width: 160,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotonMenu(
    BuildContext context, {
    required IconData icon,
    required String titulo,
    required Widget destino,
  }) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => destino)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppEstilos.inputOscuro,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppEstilos.bordeOscuro),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppEstilos.verdeBoton, size: 32),
            const SizedBox(width: 16),
            Text(
              titulo,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
