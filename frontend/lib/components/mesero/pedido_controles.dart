import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

/// "Mesa: 4 ⌄" — elige la mesa del pedido (1 a [totalMesas]).
class SelectorMesa extends StatelessWidget {
  final int? mesa;
  final ValueChanged<int?> onChanged;
  final int totalMesas;

  const SelectorMesa({super.key, required this.mesa, required this.onChanged, this.totalMesas = 20});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 24, 10),
      child: Row(
        children: [
          const Text('Mesa:', style: TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'serif')),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: mesa,
              isDense: true,
              hint: const Text('elegir', style: TextStyle(color: Colors.white54, fontSize: 13)),
              dropdownColor: AppEstilos.inputOscuro,
              iconEnabledColor: Colors.white,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'serif'),
              items: [for (int m = 1; m <= totalMesas; m++) DropdownMenuItem(value: m, child: Text('$m'))],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón dorado "Hacer pedido" (muestra cuántos platos lleva).
class BotonHacerPedido extends StatelessWidget {
  final int cantidad;
  final bool enviando;
  final VoidCallback onPressed;

  const BotonHacerPedido({super.key, required this.cantidad, required this.enviando, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(70, 6, 70, 20),
      child: SizedBox(
        width: double.infinity,
        height: 46,
        child: ElevatedButton(
          onPressed: enviando ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppEstilos.botonMesero,
            elevation: 0,
            shape: StadiumBorder(side: BorderSide(color: Colors.black.withValues(alpha: 0.35), width: 1.2)),
          ),
          child: enviando
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87))
              : Text(cantidad > 0 ? 'Hacer pedido ($cantidad)' : 'Hacer pedido', style: const TextStyle(color: Colors.black87, fontSize: 15, fontFamily: 'serif')),
        ),
      ),
    );
  }
}