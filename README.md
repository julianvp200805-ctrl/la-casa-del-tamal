# La Casa del Tamal 🫔

¡Bienvenido al repositorio de **La Casa del Tamal**! Este proyecto es una solución tecnológica multiplataforma diseñada para optimizar y gestionar de forma eficiente la venta, control de inventario y pedidos del negocio. Consta de un backend robusto basado en microservicios y un frontend moderno y responsivo.

## ✨ Características del Proyecto

* **Gestión Integral de Menús e Inventario:** Control total sobre los productos, categorías y disponibilidad de los diferentes tipos de tamales y acompañamientos en tiempo real.
* **Control de Pedidos y Ventas:** Sistema automatizado para el procesamiento, seguimiento y actualización del estado de las órdenes desde su creación hasta la entrega.
* **Autenticación y Seguridad:** Arquitectura segura con middlewares dedicados para la verificación de tokens, roles de usuario y protección de rutas críticas de administración.
* **Gestión de Usuarios y Roles:** Control de accesos modular diferenciando clientes generales y paneles de administración gerencial (`gerent`).
* **Recuperación de Cuentas:** Flujo seguro integrado en backend y frontend para la restauración de contraseñas de accesos bloqueados u olvidados.
* **Sincronización en Tiempo Real:** Conexión directa a base de datos de alta velocidad para reflejar cambios en menús y pedidos instantáneamente.

---

## 🚀 Estructura del Proyecto

Organización completa de los directorios del repositorio, dividida bajo la arquitectura Cliente-Servidor:

```text
la-casa-del-tamal/
├── backend/                      # Servidor, API y Lógica de Negocio (Node.js)
│   ├── config/                   # Ajustes globales y conexiones externas
│   │   └── supabase.js           # Cliente de inicialización de Supabase
│   ├── controllers/              # Controladores encargados de la lógica comercial
│   │   ├── menu.js               # Lógica para visualización y cambios del menú
│   │   ├── pedido.js             # Lógica para transacciones y creación de órdenes
│   │   ├── productos.js          # CRUD de artículos e inventario
│   │   ├── recuperar.js          # Procesamiento de restablecimiento de claves
│   │   ├── tipos_producto.js     # Clasificaciones y categorías de los productos
│   │   └── user.js               # Registro y perfiles de usuarios generales / gerencia
│   ├── middlewares/              # Filtros interceptores de peticiones HTTP
│   │   └── userMiddleware.js     # Validación de tokens y sesiones activas
│   ├── models/                   # Definición de esquemas de datos y entidades
│   │   ├── menu.js | pedido.js | productos.js | recuperar.js | tipos_productos.js | user.js
│   ├── routes/                   # Definición de Endpoints expuestos de la API REST
│   │   ├── menu.js | pedido.js | productos.js | tipo_producto.js | user.js
│   ├── .env                      # Credenciales privadas de base de datos y puertos
│   ├── index.js                  # Punto de entrada de la aplicación Node.js
│   └── package.json              # Dependencias del servidor (Express, etc.)
└── frontend/                     # Aplicación Cliente Multiplataforma (Flutter)
    ├── assets/image/             # Recursos estáticos y logotipos (`logo.png`)
    ├── lib/                      # Archivos de código Dart
    │   ├── components/genert/    # Formularios y vistas modulares (`inicio_sesion.dart`, `recuperar_contrasena.dart`)
    │   ├── core/                 # Configuración de estilos y utilidades globales
    │   ├── models/               # Clases estructuradas para el mapeo de objetos (`gerent.dart`)
    │   ├── pantallas/            # Pantallas completas del flujo (`pantalla_principal.dart`)
    │   ├── services/             # Clientes de consumo HTTP hacia el backend (`api_config.dart`, `gerent_services.dart`)
    │   └── main.dart             # Inicializador maestro del Frontend
    └── pubspec.yaml              # Dependencias y paquetes de Flutter
```

---

## 🛠️ Tecnologías Utilizadas

* **Frontend:** Dart, Flutter Framework (Android, iOS, Web, Escritorio)
* **Backend:** JavaScript, Node.js, Express Framework
* **Base de Datos / BaaS:** Supabase (PostgreSQL subyacente)

---

## 📦 Instalación y Configuración

Sigue minuciosamente estos pasos para clonar, configurar e iniciar todo el entorno de manera local:

### 1. Clonar el repositorio
```bash
git clone https://github.com
cd la-casa-del-tamal
```

### 2. Configuración y Ejecución del Servidor (Backend)
El servidor está desarrollado sobre el entorno **Node.js**.

1. Ingresa al directorio e instala todas las librerías necesarias:
   ```bash
   cd backend
   npm install
   ```
2. Configura los accesos creando un archivo llamado `.env` en la raíz del backend con tu llave de base de datos:
   ```env
   SUPABASE_URL=tu_url_de_supabase_proyecto
   SUPABASE_KEY=tu_clave_anon_o_service_role
   PORT=3000
   ```
3. **Ejecutar el servidor en desarrollo:**
   Inicia el backend en modo de desarrollo con recarga en caliente utilizando:
   ```bash
   npm run dev
   ```

### 3. Configuración y Ejecución del Cliente (Frontend)
Requiere tener previamente configurado el SDK de **Flutter**.

1. Muévete hacia el directorio del frontend e importa los paquetes necesarios:
   ```bash
   cd ../frontend
   flutter pub get
   ```
2. Inicia la aplicación en el navegador web (o cambia al emulador que requieras):
   ```bash
   flutter run -d chrome
   ```

---

## 👥 Colaboradores
* **Eder Ramos Plaza** - [@ederramosplaza7-eng](https://github.com)
* **Julian** - [@julianvp200805-ctrl](https://github.com)

