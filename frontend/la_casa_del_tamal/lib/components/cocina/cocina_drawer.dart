import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/gerente/gerent_services.dart';

/// Barra lateral de cocina: Cerrar sesión + Eliminar cuenta.
class CocinaDrawer extends StatelessWidget {
  const CocinaDrawer({super.key});

  Future<void> _cerrarSesion(BuildContext context) async {
    await UserService().cerrarSesion();
    if (!context.mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _eliminarCuenta(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('user_id') ?? '';
    if (!context.mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppEstilos.tablaInventario,
        title: const Text('Eliminar cuenta', style: TextStyle(color: Colors.white)),
        content: const Text('¿Seguro que quieres eliminar tu cuenta permanentemente? Esta acción no se puede deshacer.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar', style: TextStyle(color: Colors.white70))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: AppEstilos.rojoVencido, fontWeight: FontWeight.bold))),
        ],
      ),
    );
    if (ok != true) return;
    try {
      if (id.isNotEmpty) await UserService().eliminarTrabajador(id);
      await UserService().cerrarSesion();
      if (!context.mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red.shade700, duration: const Duration(seconds: 3)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppEstilos.fondoOscuro,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text('COCINA', style: TextStyle(color: AppEstilos.acentoCocina, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'serif')),
            const Divider(color: Colors.white24),
            const Spacer(),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.logout_outlined, color: AppEstilos.colorDorado),
              title: const Text('Cerrar sesión', style: TextStyle(color: AppEstilos.colorDorado)),
              onTap: () {
                Navigator.pop(context);
                _cerrarSesion(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: AppEstilos.rojoVencido),
              title: const Text('Eliminar cuenta', style: TextStyle(color: AppEstilos.rojoVencido)),
              onTap: () {
                Navigator.pop(context);
                _eliminarCuenta(context);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}