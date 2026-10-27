import 'package:flutter/material.dart';
import 'package:frontend/components/productos/producto.dart';
import 'package:frontend/services/productos/producto_service.dart';

/// Diálogo para crear un tipo de producto nuevo (nombre + días de vencimiento).
/// Devuelve el tipo creado o null si se cancela.
Future<TipoProducto?> pedirNuevoTipo(BuildContext context, ProductoService service) {
  final nombre = TextEditingController();
  final dias = TextEditingController();
  String? error;
  bool guardando = false;

  return showDialog<TipoProducto>(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (ctx, setLocal) => AlertDialog(
        title: const Text('Nuevo tipo de producto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nombre, decoration: const InputDecoration(hintText: 'Nombre (ej: carne)')),
            TextField(controller: dias, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Días hasta vencer')),
            if (error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(error!, style: const TextStyle(color: Colors.red, fontSize: 12))),
          ],
        ),
        actions: [
          TextButton(onPressed: guardando ? null : () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: guardando
                ? null
                : () async {
                    final d = int.tryParse(dias.text.trim());
                    if (nombre.text.trim().isEmpty || d == null || d <= 0) {
                      setLocal(() => error = 'Escribe un nombre y los días (mayor a 0)');
                      return;
                    }
                    setLocal(() { guardando = true; error = null; });
                    try {
                      final tipo = await service.crearTipo(nombre: nombre.text.trim(), dias: d);
                      if (ctx.mounted) Navigator.pop(ctx, tipo);
                    } catch (e) {
                      setLocal(() { guardando = false; error = e.toString(); });
                    }
                  },
            child: Text(guardando ? 'Guardando...' : 'Crear'),
          ),
        ],
      ),
    ),
  );
}