import 'package:flutter/material.dart';
import 'package:frontend/core/app_estilos.dart';

/// Selector tipo "segmented control" de las maquetas (Diario|Semana|Mes y
/// Productos|Vencidos): pastilla verde sobre una banda oscura redondeada.
class BotoneraSegmentada extends StatelessWidget {
  final List<String> opciones;
  final int indiceActivo;
  final ValueChanged<int> onTap;

  const BotoneraSegmentada({
    super.key,
    required this.opciones,
    required this.indiceActivo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppEstilos.inputOscuro,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppEstilos.bordeOscuro),
      ),
      child: Row(
        children: [
          for (int i = 0; i < opciones.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(child: _segmento(i)),
          ],
        ],
      ),
    );
  }

  Widget _segmento(int i) {
    final activo = i == indiceActivo;
    return Material(
      color: activo ? AppEstilos.verdeBoton : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => onTap(i),
        child: SizedBox(
          height: 40,
          child: Center(
            child: Text(
              opciones[i],
              style: TextStyle(
                color: activo ? Colors.black87 : Colors.white70,
                fontSize: 14,
                fontWeight: activo ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
