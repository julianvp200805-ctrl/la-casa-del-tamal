import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/gerente/gerent_services.dart';

/// Barra lateral del mesero: Cerrar sesión + Eliminar cuenta.
class MeseroDrawer extends StatelessWidget {
  const MeseroDrawer({super.key});

  Future<void> _cerrarSesion(BuildContext context) async {
    await UserService().cerrarSesion();
    if (!context.mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _eliminarCuenta(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('user_id') ?? '';
    if (!context.mounted) return;
    final controlador = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) {
          bool habilitado = false;
          return AlertDialog(
            backgroundColor: AppEstilos.tablaInventario,
            title: const Text('Eliminar cuenta', style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('¿Seguro que quieres eliminar tu cuenta permanentemente? Esta acción no se puede deshacer.', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                const Text('Escribe ELIMINAR para confirmar:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: controlador,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'ELIMINAR',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: AppEstilos.fondoOscuro,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                  onChanged: (v) => setSt(() => habilitado = v.trim().toUpperCase() == 'ELIMINAR'),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar', style: TextStyle(color: Colors.white70))),
              TextButton(
                onPressed: habilitado ? () => Navigator.pop(ctx, true) : null,
                child: Text('Eliminar', style: TextStyle(color: habilitado ? AppEstilos.rojoVencido : Colors.white24, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
    controlador.dispose();
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
            const Text('MESERO', style: TextStyle(color: AppEstilos.meseroOliva, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'serif')),
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