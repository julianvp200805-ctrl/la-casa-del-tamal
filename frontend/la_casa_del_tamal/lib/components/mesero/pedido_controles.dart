import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/mesas.dart';

const Color _amarillo = Color(0xFFFFD60A);

/// 50000 -> "50.000"
String formatoPesos(num v) {
  final s = v.round().toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return b.toString();
}

class TituloMesero extends StatelessWidget {
  final String texto;
  final bool centrado;
  const TituloMesero({super.key, required this.texto, this.centrado = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            texto,
            textAlign: centrado ? TextAlign.center : TextAlign.left,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              height: 1.25,
              fontFamily: 'serif',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
}

/// Desayuno | Almuerzo | Comida rápida | Bebidas.
/// [colorActivo] tiñe la pestaña elegida: oliva en mesero, ámbar en cocina.
class CategoriaTabs extends StatelessWidget {
  static const etiquetas = ['Desayuno', 'Almuerzo', 'Comida\nrápida', 'Bebidas'];
  final int seleccionada;
  final ValueChanged<int> onChanged;
  final Color colorActivo;
  const CategoriaTabs({
    super.key,
    required this.seleccionada,
    required this.onChanged,
    this.colorActivo = AppEstilos.verdeBoton,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
        child: Row(
          children: [
            for (int i = 0; i < etiquetas.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    height: 44,
                    margin: EdgeInsets.only(right: i == etiquetas.length - 1 ? 0 : 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == seleccionada ? colorActivo : AppEstilos.platoMesero,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: i == seleccionada ? colorActivo : AppEstilos.bordeOscuro),
                      boxShadow: i == seleccionada
                          ? [BoxShadow(color: colorActivo.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 3))]
                          : [],
                    ),
                    child: Text(
                      etiquetas[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.2,
                        fontWeight: i == seleccionada ? FontWeight.bold : FontWeight.w500,
                        color: i == seleccionada ? Colors.black87 : Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}

/// Barra "Mesa 4 · 5 personas · Tamal, Chorizo · Valor total: $50.000"
class ResumenPedido extends StatelessWidget {
  final int? mesa;
  final String detalle;
  final double total;
  final int items;
  final int notas;

  const ResumenPedido({
    super.key,
    required this.mesa,
    required this.detalle,
    required this.total,
    this.items = 0,
    this.notas = 0,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppEstilos.platoMesero,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: items > 0 ? AppEstilos.meseroOliva : AppEstilos.bordeOscuro, width: items > 0 ? 1.3 : 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mesa == null ? 'Mesa sin asignar' : 'Mesa $mesa · ${cupoMesa(mesa!)} personas',
                      style: TextStyle(
                        color: mesa == null ? Colors.white38 : Colors.white,
                        fontSize: 13,
                        fontFamily: 'serif',
                        fontWeight: mesa == null ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detalle.isEmpty ? 'Aún no agregas platos' : detalle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: items == 0 ? Colors.white24 : Colors.white54, fontSize: 10),
                    ),
                    if (notas > 0) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.notes, size: 10, color: AppEstilos.meseroOliva),
                          const SizedBox(width: 4),
                          Text('Notas para cocina: $notas',
                              style: const TextStyle(color: AppEstilos.meseroOliva, fontSize: 10)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('\$${formatoPesos(total)}', style: const TextStyle(color: _amarillo, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'serif')),
                  Text('Artículos: $items', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
      );
}

/// Botón dorado "Hacer pedido", ancho completo para que sea fácil de tocar.
class BotonHacerPedido extends StatelessWidget {
  final int cantidad;
  final bool enviando;
  final VoidCallback onPressed;
  const BotonHacerPedido({super.key, required this.cantidad, required this.enviando, required this.onPressed});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: enviando ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppEstilos.botonMesero,
              disabledBackgroundColor: AppEstilos.botonMesero.withValues(alpha: 0.5),
              foregroundColor: Colors.black87,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: enviando
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black54))
                : Text(
                    cantidad > 0 ? 'Hacer pedido · $cantidad' : 'Hacer pedido',
                    style: const TextStyle(color: Colors.black87, fontSize: 16, fontFamily: 'serif', fontWeight: FontWeight.bold, height: 1),
                  ),
          ),
        ),
      );
}