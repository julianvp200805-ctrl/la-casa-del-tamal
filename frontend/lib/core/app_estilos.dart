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
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static const double radioBoton = 16;
  static const double radioTarjeta = 24;

  // ---- Paleta nueva del panel admin / Ventas (medida de tus mockups) ----
  static const Color fondoAdmin = Color(0xFFCAD0C8); // fondo plano claro
  static const Color headerAdmin = Color(0xFF436645); // barra superior (logo+ADMIN)
  static const Color tituloVerde = Color(0xFF178A38); // "Hola, admin" / títulos
  static const Color botonOscuro = Color(0xFF486242); // botones del home
  static const Color botonClaro = Color(0xFF71856D); // botones de Ventas/días/semanas

  // ---- Paleta oscura nueva (home/splash/login/recuperar) ----
  static const Color fondoOscuro = Color(0xFF16221C); // fondo de toda la pantalla
  static const Color inputOscuro = Color(0xFF1F2E27); // fondo de los campos de texto
  static const Color verdeBoton = Color(0xFF4ADE60); // botones grandes (menu/Iniciar Sesion/Enviar/Verificar)
  static const Color verdePildora = Color(0xFF7AC142); // insignia "Iniciar Sesión" arriba
  static const Color bordeOscuro = Color(0xFF2C4136); // borde sutil de tarjetas y filas oscuras

  // ---- Inventario, Modificar menú y chat (medidos de tus mockups) ----
  static const Color filaInventario = Color(0xFF385346); // filas de productos
  static const Color tablaInventario = Color(0xFF1C2A24); // tarjeta que envuelve la tabla
  static const Color pillFresco = Color(0xFF45B458); // lote en buen estado
  static const Color pillPorVencer = Color(0xFFA9B449); // lote que vence en 3 días o menos
  static const Color rojoVencido = Color(0xFFDE4C4A); // texto "Descartar" / alertas
  static const Color rojoFondo = Color(0xFF633938); // banner de productos vencidos
  static const Color rojoChip = Color(0xFFAC4E49); // fecha de un producto vencido
  static const Color hojaOscura = Color(0xFF495751); // hoja "Editar producto"
  static const Color verdeAccion = Color(0xFF34C759); // Guardar / burbuja del usuario
  static const Color burbujaBot = Color(0xFF2F3C37); // burbuja del asistente
  static const Color bordeAgregar = Color(0xFF297A40); // borde de "+ Agregar producto"
  static const Color botonMas = Color(0xFF499945); // botón "+" de Productos

  // ---- Rol mesero (medidos de tu mockup) ----
  static const Color meseroOliva = Color(0xFF97B510); // "Mesero" y perfil
  static const Color platoMesero = Color(0xFF35433D); // tarjeta de cada plato
  static const Color botonMesero = Color(0xFFB28C37); // botón "Hacer pedido"
}