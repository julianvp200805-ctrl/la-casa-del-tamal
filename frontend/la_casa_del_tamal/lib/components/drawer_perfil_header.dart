import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Encabezado del drawer lateral: icono grande + nombre + correo + rol.
/// Se carga desde SharedPreferences (guardado al iniciar sesión).
class DrawerPerfilHeader extends StatefulWidget {
  final Color color;
  final String rolLabel;
  const DrawerPerfilHeader({super.key, required this.color, required this.rolLabel});

  @override
  State<DrawerPerfilHeader> createState() => _DrawerPerfilHeaderState();
}

class _DrawerPerfilHeaderState extends State<DrawerPerfilHeader> {
  String _nombre = '';
  String _email = '';
  String _rol = '';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _nombre = prefs.getString('user_name') ?? '';
      _email = prefs.getString('user_email') ?? '';
      _rol = prefs.getString('user_rol') ?? widget.rolLabel.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Column(
        children: [
          Icon(Icons.account_circle, size: 72, color: widget.color),
          const SizedBox(height: 10),
          Text(
            _nombre.isNotEmpty ? _nombre : widget.rolLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'serif'),
          ),
          if (_email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(_email, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: widget.color),
            ),
            child: Text(
              _rol.isNotEmpty ? _rol.toUpperCase() : widget.rolLabel,
              style: TextStyle(color: widget.color, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}