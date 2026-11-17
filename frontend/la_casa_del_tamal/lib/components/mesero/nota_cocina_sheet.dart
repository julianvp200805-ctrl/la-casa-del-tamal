import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/menu/menu_services.dart';

/// Hoja del lápiz de cada plato: la nota que la cocina recibe con el pedido
/// cuando el cliente se deja algún ingrediente ("sin mayonesa").
/// Devuelve el texto nuevo, o null si el mesero cancela.
Future<String?> abrirNotaCocina(BuildContext context, {required MenuItem plato, required String nota}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _NotaCocinaSheet(plato: plato, notaInicial: nota),
  );
}

class _NotaCocinaSheet extends StatefulWidget {
  final MenuItem plato;
  final String notaInicial;

  const _NotaCocinaSheet({required this.plato, required this.notaInicial});

  @override
  State<_NotaCocinaSheet> createState() => _NotaCocinaSheetState();
}

class _NotaCocinaSheetState extends State<_NotaCocinaSheet> {
  late final TextEditingController _controlador = TextEditingController(text: widget.notaInicial);

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppEstilos.hojaOscura,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 14),
            Text(widget.plato.nombre, style: const TextStyle(color: Colors.white, fontSize: 17, fontFamily: 'serif')),
            const SizedBox(height: 2),
            const Text('Nota para cocina', style: TextStyle(color: AppEstilos.meseroOliva, fontSize: 12, fontStyle: FontStyle.italic)),
            const SizedBox(height: 14),
            TextField(
              controller: _controlador,
              maxLines: 3,
              maxLength: 200,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Escribe la indicación para cocina',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                counterStyle: const TextStyle(color: Colors.white30, fontSize: 10),
                filled: true,
                fillColor: AppEstilos.fondoOscuro,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (widget.notaInicial.isNotEmpty)
                  TextButton(
                    onPressed: () => Navigator.pop(context, ''),
                    child: const Text('Quitar nota', style: TextStyle(color: AppEstilos.rojoVencido)),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, _controlador.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppEstilos.verdeAccion,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                  ),
                  child: const Text('Guardar', style: TextStyle(fontSize: 14, fontFamily: 'serif')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
