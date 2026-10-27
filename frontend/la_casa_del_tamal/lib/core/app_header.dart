import 'package:flutter/material.dart';
import 'app_estilos.dart';

/// Fondo reutilizable con degradado para el body de cualquier pantalla.
class AppFondo extends StatelessWidget {
  final Widget child;
  const AppFondo({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppEstilos.degradadoFondo),
      child: child,
    );
  }
}

/// Encabezado reutilizable: degradado verde, logo, flecha de volver y
/// un ícono de acción a la derecha (chatbot, perfil, etc).
class AppEncabezado extends StatelessWidget {
  final String? titulo;
  final String logoAssetPath;
  final bool mostrarLogo;
  final IconData iconoDerecho;
  final VoidCallback? onIconoDerecho;

  const AppEncabezado({
    super.key,
    this.titulo,
    this.logoAssetPath = 'assets/image/logo.png',
    this.mostrarLogo = true,
    this.iconoDerecho = Icons.eco,
    this.onIconoDerecho,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: AppEstilos.degradadoHeader,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: AppEstilos.sombraSuave,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: mostrarLogo
                    ? Image.asset(
                        logoAssetPath,
                        height: 60,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.house,
                          size: 40,
                          color: Colors.white,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              onIconoDerecho != null
                  ? IconButton(icon: Icon(iconoDerecho, color: Colors.white), onPressed: onIconoDerecho)
                  : const SizedBox(width: 48),
            ],
          ),
          if (titulo != null) ...[
            const SizedBox(height: 4),
            Text(
              titulo!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'serif',
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}