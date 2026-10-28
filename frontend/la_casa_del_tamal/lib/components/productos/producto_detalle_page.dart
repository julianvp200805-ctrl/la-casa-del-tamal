import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/menu/menu_services.dart';

class ProductoDetallePage extends StatelessWidget {
  final MenuItem plato;
  final List<String> ingredientes;

  const ProductoDetallePage({
    super.key,
    required this.plato,
    required this.ingredientes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(plato.nombre, style: const TextStyle(color: Colors.white, fontFamily: 'serif')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: plato.imagenUrl != null && plato.imagenUrl!.isNotEmpty
                    ? Image.network(
                        plato.imagenUrl!,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallback(),
                      )
                    : _fallback(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (plato.categoria ?? 'General').toUpperCase(),
                  style: const TextStyle(color: AppEstilos.verdeBoton, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Cocción', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('3 - 4 H', style: TextStyle(color: AppEstilos.colorDorado, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(plato.nombre, style: const TextStyle(color: Colors.white, fontSize: 24, fontFamily: 'serif', fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const Text('ingredientes principales', style: TextStyle(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: ingredientes.map((ing) => _buildChip(ing)).toList(),
            ),
            const SizedBox(height: 28),
            const Text('Descripción', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              plato.descripcion ?? 'Sin descripción disponible.',
              style: const TextStyle(color: Colors.white60, fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppEstilos.inputOscuro,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppEstilos.bordeOscuro),
      ),
      child: Text(
        texto,
        style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'serif'),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      width: double.infinity,
      height: 220,
      color: AppEstilos.bordeOscuro,
      child: const Icon(Icons.fastfood, size: 60, color: Colors.white24),
    );
  }
}
