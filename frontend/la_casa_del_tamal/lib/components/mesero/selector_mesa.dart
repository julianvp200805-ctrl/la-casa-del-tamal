import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/core/mesas.dart';

const Color _amarillo = Color(0xFFFFD60A);

/// "Mesa 4 ⌄" + el cupo fijo de esa mesa. El cupo no se elige: cada una de las
/// 13 mesas del salón trae su número de personas ya fijado (4 a 6).
class SelectorMesa extends StatelessWidget {
  final int? mesa;
  final ValueChanged<int?> onChanged;

  const SelectorMesa({super.key, required this.mesa, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const estilo = TextStyle(color: Colors.white, fontSize: 13);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
      child: Row(
        children: [
          Container(
            width: 150,
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppEstilos.platoMesero,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: mesa == null ? AppEstilos.bordeOscuro : AppEstilos.meseroOliva),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: mesa,
                isExpanded: true,
                hint: const Text('Mesa', style: estilo),
                dropdownColor: AppEstilos.platoMesero,
                borderRadius: BorderRadius.circular(10),
                icon: const Icon(Icons.keyboard_arrow_down, color: _amarillo),
                style: estilo,
                selectedItemBuilder: (_) => [
                  for (int m = 1; m <= totalMesas; m++)
                    Row(children: [
                      const Text('Mesa', style: estilo),
                      const Spacer(),
                      Text('$m', style: estilo),
                    ]),
                ],
                items: [
                  for (int m = 1; m <= totalMesas; m++)
                    DropdownMenuItem(
                      value: m,
                      child: Row(
                        children: [
                          const Text('Mesa', style: estilo),
                          const Spacer(),
                          Text('$m', style: estilo),
                          const SizedBox(width: 8),
                          Text('${cupoMesa(m)} p', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                        ],
                      ),
                    ),
                ],
                onChanged: onChanged,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1F3A2C),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppEstilos.bordeOscuro),
              ),
              child: Row(
                children: [
                  Icon(mesa == null ? Icons.table_restaurant : Icons.group, color: AppEstilos.meseroOliva, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      mesa == null ? 'Elige la mesa' : '${cupoMesa(mesa!)} personas',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: mesa == null ? Colors.white38 : Colors.white70, fontSize: 13, fontFamily: 'serif'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
