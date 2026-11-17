import 'package:flutter/material.dart';
import 'package:frontend/components/cocina/cocina_shell.dart';
import 'package:frontend/components/cocina/cocina_top_bar.dart';
import 'package:frontend/components/mesero/pedido_controles.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/menu/menu_services.dart';

class ProductoDetallePage extends StatelessWidget {
  final MenuItem plato;
  final List<String> ingredientes;

  /// Abierto desde la bandeja de cocina: lleva la barra inferior ámbar y el
  /// perfil de cocina arriba, como la maqueta 32.
  final bool deCocina;

  const ProductoDetallePage({
    super.key,
    required this.plato,
    required this.ingredientes,
    this.deCocina = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      bottomNavigationBar: deCocina
          ? BarraNavegacion(
              indiceActivo: 1,
              colorActivo: AppEstilos.acentoCocina,
              pestanas: pestanasCocina,
              onTap: (i) {
                pestanaCocinaActiva.value = i;
                Navigator.pop(context);
              },
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 24, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  if (deCocina) const CocinaPerfil(),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen grande del plato con degradado abajo que se funde
                    // con el fondo de la pantalla.
                    SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            color: const Color(0xFF2E4A3C),
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.zero,
                                child: plato.imagenUrl != null && plato.imagenUrl!.isNotEmpty
                                    ? Image.network(plato.imagenUrl!, width: double.infinity, height: 300, fit: BoxFit.cover, errorBuilder: (_, _, _) => _fallback())
                                    : _fallback(),
                              ),
                            ),
                          ),
                          // Degradado inferior que se funde con el fondo oscuro.
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.transparent,
                                    AppEstilos.fondoOscuro.withValues(alpha: 0.6),
                                    AppEstilos.fondoOscuro,
                                  ],
                                  stops: const [0.0, 0.5, 0.8, 1.0],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 24,
                            right: 24,
                            bottom: 16,
                            child: Text(
                              plato.nombre,
                              style: const TextStyle(color: Colors.white, fontSize: 26, fontFamily: 'serif', fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black54, blurRadius: 8)]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_etiquetaCategoria(plato.categoria),
                                        style: const TextStyle(color: AppEstilos.verdeBoton, fontSize: 13, fontStyle: FontStyle.italic)),
                                    const SizedBox(height: 6),
                                    Text(plato.nombre, style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'serif')),
                                  ],
                                ),
                              ),
                              // En la carta pública el precio manda; en la vista
                              // de cocina queda el dato de cocción de la maqueta.
                              if (deCocina)
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('Cocción', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                    SizedBox(height: 4),
                                    Text('—', style: TextStyle(color: AppEstilos.acentoCocina, fontSize: 18, fontFamily: 'serif')),
                                  ],
                                )
                              else
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('Precio', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                    const SizedBox(height: 4),
                                    Text('\$${formatoPesos(plato.precio)}',
                                        style: const TextStyle(color: AppEstilos.verdeBoton, fontSize: 20, fontFamily: 'serif', height: 1.1)),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text('Ingredientes principales', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 10,
                            children: ingredientes.map((ing) => _buildChip(ing)).toList(),
                          ),
                          const SizedBox(height: 28),
                          const Text('Descripción', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 12),
                          Text(
                            plato.descripcion ?? 'Sin descripción disponible.',
                            style: const TextStyle(color: Colors.white60, fontSize: 14, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _etiquetaCategoria(String? cat) {
    final c = (cat ?? '').trim();
    if (c.isEmpty) return 'General';
    final n = c.toLowerCase().replaceAll('á', 'a');
    if (n.contains('rapida')) return 'Comida rápida';
    return c[0].toUpperCase() + c.substring(1);
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
      height: 300,
      color: AppEstilos.bordeOscuro,
      child: const Icon(Icons.fastfood, size: 80, color: Colors.white24),
    );
  }
}
