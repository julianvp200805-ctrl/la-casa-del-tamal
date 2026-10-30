import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

/// "Mesa   4 ⌄" + chip "8 personas".
class SelectorMesa extends StatelessWidget {
  final int? mesa;
  final ValueChanged<int?> onChanged;
  final int totalMesas;
  final int personas;
  final ValueChanged<int> onPersonas;

  const SelectorMesa({
    super.key,
    required this.mesa,
    required this.onChanged,
    required this.personas,
    required this.onPersonas,
    this.totalMesas = 20,
  });

  @override
  Widget build(BuildContext context) {
    const estilo = TextStyle(color: Colors.white, fontSize: 13);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Row(
        children: [
          Container(
            width: 146,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppEstilos.platoMesero,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppEstilos.bordeOscuro),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: mesa,
                isExpanded: true,
                hint: const Text('Mesa', style: estilo),
                dropdownColor: AppEstilos.platoMesero,
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFFFD60A)),
                style: estilo,
                selectedItemBuilder: (_) => [
                  for (int m = 1; m <= totalMesas; m++)
                    Row(children: [
                      const Text('Mesa', style: estilo),
                      const Spacer(),
                      Text('$m', style: estilo),
                      const SizedBox(width: 6),
                    ]),
                ],
                items: [for (int m = 1; m <= totalMesas; m++) DropdownMenuItem(value: m, child: Text('Mesa $m'))],
                onChanged: onChanged,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: PopupMenuButton<int>(
              color: AppEstilos.platoMesero,
              onSelected: onPersonas,
              itemBuilder: (_) => [
                for (int i = 1; i <= 20; i++)
                  PopupMenuItem(value: i, child: Text('$i personas', style: const TextStyle(color: Colors.white))),
              ],
              child: Container(
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: const Color(0xFF1F3A2C), borderRadius: BorderRadius.circular(8)),
                child: Text('$personas personas', style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}