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
            style: const TextStyle(color: Colors.white70, fontSize: 24, height: 1.25, fontFamily: 'serif'),
          ),
        ),
      );
}

/// desayuno | almuerzo | comida rápida | bebidas
class CategoriaTabs extends StatelessWidget {
  static const etiquetas = ['desayuno', 'almuerzo', 'comida\nrápida', 'bebidas'];
  final int seleccionada;
  final ValueChanged<int> onChanged;
  const CategoriaTabs({super.key, required this.seleccionada, required this.onChanged});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
        child: Row(
          children: [
            for (int i = 0; i < etiquetas.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(i),
                  child: Container(
                    height: 44,
                    margin: EdgeInsets.only(right: i == etiquetas.length - 1 ? 0 : 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == seleccionada ? const Color(0xFF4ADE60) : AppEstilos.platoMesero,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppEstilos.bordeOscuro),
                    ),
                    child: Text(
                      etiquetas[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: i == seleccionada ? Colors.black : Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}

/// Barra "Mesa 4 / 5 personas · Tamal, Chorizo ......... Valor total: 50.000"
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
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppEstilos.platoMesero,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: items > 0 ? AppEstilos.meseroOliva : AppEstilos.bordeOscuro),
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
                      style: TextStyle(color: mesa == null ? Colors.white38 : Colors.white, fontSize: 13, fontFamily: 'serif'),
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
                          Text('$notas nota${notas == 1 ? '' : 's'} para cocina',
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
                  Text(formatoPesos(total), style: const TextStyle(color: _amarillo, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'serif')),
                  Text('$items artículos', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
      );
}

/// Botón dorado "Hacer pedido". Altura 48 y texto con altura de línea fija:
/// con 40 el serif quedaba recortado contra el borde inferior.
class BotonHacerPedido extends StatelessWidget {
  final int cantidad;
  final bool enviando;
  final VoidCallback onPressed;
  const BotonHacerPedido({super.key, required this.cantidad, required this.enviando, required this.onPressed});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        child: Center(
          child: SizedBox(
            width: 210,
            height: 48,
            child: ElevatedButton(
              onPressed: enviando ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppEstilos.botonMesero,
                foregroundColor: Colors.black87,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: const StadiumBorder(),
              ),
              child: enviando
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black54))
                  : const Text('Hacer pedido',
                      style: TextStyle(color: Colors.black87, fontSize: 15, fontFamily: 'serif', height: 1)),
            ),
          ),
        ),
      );
}