import 'package:flutter/material.dart';

/// Estilos y widgets compartidos - Casa del Tamal
/// Reutiliza esto en TODAS las pantallas para que se vean consistentes:
/// mismo degradado, mismas sombras, mismos botones.
class AppEstilos {
  // Paleta ya usada en las pantallas de login/recuperar contraseña
  static const Color fondoClaro = Color(0xFF96C69F);
  static const Color headerInicio = Color(0xFF339A3A);
  static const Color headerFin = Color(0xFF113514);
  static const Color botonVerde = Color(0xFF4E9F5D);
  static const Color botonBorde = Color(0xFF96C69F);
  static const Color colorInput = Color(0xFFF2F2EB);
  static const Color colorDorado = Color(0xFFC0B412);

  static const LinearGradient degradadoHeader = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [headerInicio, headerFin],
  );

  // Fondo con degradado suave de verde claro a un poco más oscuro,
  // le da "cuerpo" a la pantalla en vez de un color plano.
  static const LinearGradient degradadoFondo = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [fondoClaro, Color(0xFF7FB88C)],
  );

  // Sombra suave para tarjetas/botones -> le da profundidad a la UI
  static List<BoxShadow> sombraSuave = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static const double radioBoton = 16;
  static const double radioTarjeta = 24;
}

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
              IconButton(
                icon: Icon(iconoDerecho, color: Colors.white),
                onPressed: onIconoDerecho,
              ),
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

/// Botón grande de menú, con sombra y borde, igual al de las pantallas
/// de Ventas / Inventario / Pedidos / Modificar menú.
class AppBotonMenu extends StatelessWidget {
  final String texto;
  final VoidCallback onTap;
  final bool cargando;

  const AppBotonMenu({
    super.key,
    required this.texto,
    required this.onTap,
    this.cargando = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppEstilos.radioBoton),
        boxShadow: AppEstilos.sombraSuave,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: cargando ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppEstilos.botonVerde,
            side: const BorderSide(color: AppEstilos.botonBorde, width: 1.5),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppEstilos.radioBoton),
            ),
          ),
          child: cargando
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  texto,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontFamily: 'serif',
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Tarjeta blanca/verde suave para mostrar datos (usada en los reportes).
class AppTarjeta extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AppTarjeta({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppEstilos.radioTarjeta),
        boxShadow: AppEstilos.sombraSuave,
      ),
      child: child,
    );
  }
}