import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

/// Header con logo + flecha (ícono espejado) usado en las pantallas de
/// recuperar/nueva contraseña. Mismo diseño exacto que ya tenías,
/// solo que ahora vive en un único lugar.
class AuthHeader extends StatelessWidget {
  final String logoAssetPath;

  const AuthHeader({super.key, this.logoAssetPath = 'assets/image/logo.png'});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
      decoration: BoxDecoration(
        gradient: AppEstilos.degradadoHeader,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: AppEstilos.sombraSuave,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            logoAssetPath,
            height: 90,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.house, size: 60, color: Colors.white),
          ),
          Positioned(
            right: 0,
            child: IconButton(
              icon: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi),
                child: const Icon(Icons.logout, color: Colors.white),
              ),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      ),
    );
  }
}