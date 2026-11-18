import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:frontend/core/colores.dart';

/// Pantalla que muestra el manual de usuario (PDF incluido en assets).
class ManualUsuarioPage extends StatefulWidget {
  static const String routeName = '/manual-usuario';
  const ManualUsuarioPage({super.key});

  @override
  State<ManualUsuarioPage> createState() => _ManualUsuarioPageState();
}

class _ManualUsuarioPageState extends State<ManualUsuarioPage> {
  Uint8List? _bytes;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final data = await rootBundle.load('assets/manuales/manual_usuario.pdf');
      if (!mounted) return;
      setState(() {
        _bytes = data.buffer.asUint8List();
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      appBar: AppBar(
        backgroundColor: AppEstilos.fondoOscuro,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Manual de usuario', style: TextStyle(color: Colors.white, fontFamily: 'serif', fontWeight: FontWeight.bold)),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: AppEstilos.verdeBoton))
          : _error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!, style: const TextStyle(color: Colors.white))))
              : PDFView(
                  pdfData: _bytes,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: true,
                  pageFling: true,
                  onError: (e) => setState(() => _error = e.toString()),
                ),
    );
  }
}