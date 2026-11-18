import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/core/colores.dart';

class MeseroTitulo extends StatefulWidget {
  final double tamano;
  const MeseroTitulo({super.key, this.tamano = 20});

  @override
  State<MeseroTitulo> createState() => _MeseroTituloState();
}

class _MeseroTituloState extends State<MeseroTitulo> {
  String _nombre = '';

  @override
  void initState() {
    super.initState();
    _cargarNombre();
  }

  Future<void> _cargarNombre() async {
    final prefs = await SharedPreferences.getInstance();
    final n = prefs.getString('user_name') ?? '';
    if (mounted) setState(() => _nombre = n);
  }

  @override
  Widget build(BuildContext context) {
    final texto = _nombre.isNotEmpty ? 'Hola, $_nombre' : 'Mesero';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(texto, style: TextStyle(color: AppEstilos.meseroOliva, fontSize: widget.tamano, fontFamily: 'serif', fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Icon(Icons.receipt_long, color: AppEstilos.meseroOliva, size: widget.tamano * 0.6),
      ],
    );
  }
}

class MeseroPerfil extends StatelessWidget {
  const MeseroPerfil({super.key});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => shellScaffoldKey.currentState?.openEndDrawer(),
        child: const Icon(Icons.account_circle_outlined, color: AppEstilos.meseroOliva, size: 38),
      );
}

/// Salir a la izquierda; perfil y "Mesero" debajo, a la derecha.
class MeseroTopBar extends StatelessWidget {
  const MeseroTopBar({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 24, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.arrow_back, color: Colors.white70, size: 28),
              ),
            ),
            const Spacer(),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [MeseroPerfil(), SizedBox(height: 2), MeseroTitulo(tamano: 17)],
            ),
          ],
        ),
      );
}