import 'package:flutter/material.dart';
import 'package:frontend/components/gerente/gerent.dart';
import 'package:frontend/components/mesero/mesero_home_page.dart';
import 'package:frontend/components/recuperar/boton_verde.dart';
import 'package:frontend/components/recuperar/recuperar_contrasena.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/pantallas/menu/campo_inicio.dart';
import 'package:frontend/pantallas/principal/encabezado_inicio.dart';
import 'package:frontend/services/gerente/gerent_services.dart';

class InicioSesion extends StatefulWidget {
  const InicioSesion({super.key});

  @override
  State<InicioSesion> createState() => _InicioSesionState();
}

class _InicioSesionState extends State<InicioSesion> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final UserService _userService = UserService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    final email = _emailController.text.trim();
    final contrasena = _passwordController.text.trim();

    if (email.isEmpty || contrasena.isEmpty) {
      _mensaje('Ingresa tu correo y contraseña', esError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final usuario = await _userService.login(email, contrasena);
      if (!mounted) return;

      // Cada rol entra a su panel; otros roles no tienen acceso a la app.
      final rol = (usuario.rol ?? '').toLowerCase();
      final Widget? destino = rol == 'admin'
          ? const AdminHomePage()
          : (rol == 'mesero' ? const MeseroHomePage() : null);

      if (destino == null) {
        await _userService.cerrarSesion();
        if (!mounted) return;
        _mensaje('Tu cuenta no tiene acceso a esta aplicación', esError: true);
        return;
      }
      _mensaje('¡Bienvenido, ${usuario.nombre}!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destino),
      );
    } catch (e) {
      _mensaje(e.toString(), esError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mensaje(String texto, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppEstilos.fondoOscuro,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EncabezadoInicio(),
              const SizedBox(height: 28),
              CampoInicio(
                controller: _emailController,
                hint: 'Correo electrónico',
                icono: Icons.mail_outline,
              ),
              const SizedBox(height: 20),
              CampoInicio(
                controller: _passwordController,
                hint: 'Contraseña',
                icono: Icons.lock_outline,
                esPassword: true,
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RecuperarContrasenaPage(),
                    ),
                  ),
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      color: AppEstilos.verdeBoton,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              BotonVerde(
                texto: 'Iniciar Sesión',
                onPressed: _iniciarSesion,
                cargando: _isLoading,
                colorDeshabilitado: AppEstilos.verdeBoton.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}