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

  // "maíz, cerdo, papa" -> ['maíz', 'cerdo', 'papa']
  List<String> get _ingredientes => (widget.plato.ingredientes ?? '')
      .split(RegExp(r'[,;\n]'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .take(8)
      .toList();

  bool _lleva(String ingrediente) => _controlador.text.toLowerCase().contains(ingrediente.toLowerCase());

  void _alternar(String ingrediente) {
    final texto = _controlador.text.trim();
    if (_lleva(ingrediente)) {
      final restante = texto
          .split(RegExp(r',\s*'))
          .where((p) => !p.trim().toLowerCase().contains(ingrediente.toLowerCase()))
          .join(', ');
      _controlador.text = restante;
      _controlador.selection = TextSelection.collapsed(offset: restante.length);
    } else {
      final frase = texto.isEmpty ? 'Sin $ingrediente' : 'sin $ingrediente';
      final nuevo = texto.isEmpty ? frase : '$texto, $frase';
      _controlador.text = nuevo.length > 200 ? nuevo.substring(0, 200) : nuevo;
      _controlador.selection = TextSelection.collapsed(offset: _controlador.text.length);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ingredientes = _ingredientes;
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
            if (ingredientes.isNotEmpty) ...[
              const Text('El cliente se deja:', style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [for (final ing in ingredientes) _chip(ing)],
              ),
              const SizedBox(height: 14),
            ],
            TextField(
              controller: _controlador,
              maxLines: 3,
              maxLength: 200,
              autofocus: ingredientes.isEmpty,
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

  Widget _chip(String ingrediente) {
    final activo = _lleva(ingrediente);
    return GestureDetector(
      onTap: () => _alternar(ingrediente),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: activo ? AppEstilos.meseroOliva : AppEstilos.fondoOscuro,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: activo ? AppEstilos.meseroOliva : AppEstilos.bordeOscuro),
        ),
        child: Text(
          'Sin $ingrediente',
          style: TextStyle(color: activo ? Colors.black87 : Colors.white70, fontSize: 12),
        ),
      ),
    );
  }
}
