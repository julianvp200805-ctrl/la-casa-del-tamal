import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

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
        padding: const EdgeInsets.fromLTRB(36, 8, 24, 16),
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

/// Barra "Mesa 4 / detalle ........ Valor total: 50.000"
class ResumenPedido extends StatelessWidget {
  final int? mesa;
  final String detalle;
  final double total;
  const ResumenPedido({super.key, required this.mesa, required this.detalle, required this.total});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: AppEstilos.platoMesero, borderRadius: BorderRadius.circular(10)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mesa == null ? 'Mesa' : 'Mesa $mesa', style: const TextStyle(color: Colors.white, fontSize: 14)),
                    Text(detalle.isEmpty ? 'Sin platos' : detalle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'serif')),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text('Valor total: ${formatoPesos(total)}',
                  style: const TextStyle(color: _amarillo, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
}

/// Botón dorado 162 x 40.
class BotonHacerPedido extends StatelessWidget {
  final int cantidad;
  final bool enviando;
  final VoidCallback onPressed;
  const BotonHacerPedido({super.key, required this.cantidad, required this.enviando, required this.onPressed});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
        child: SizedBox(
          width: 162,
          height: 40,
          child: ElevatedButton(
            onPressed: enviando ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppEstilos.botonMesero,
              elevation: 0,
              shape: const StadiumBorder(side: BorderSide(color: Color(0xFFD9B35A))),
            ),
            child: enviando
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Hacer pedido', style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'serif')),
          ),
        ),
      );
}