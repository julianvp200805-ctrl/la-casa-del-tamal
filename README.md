# La Casa del Tamal 🫔

¡Bienvenido al repositorio de **La Casa del Tamal**! Este proyecto es una aplicación web y móvil multiplataforma completa que consta de un entorno cliente y un servidor dedicado.

## 🚀 Estructura del Proyecto

A continuación se detalla la organización de los directorios principales del frontend:

```text
la-casa-del-tamal/
├── backend/                  # Servidor y API (Node.js)
└── frontend/                 # Aplicación cliente (Flutter)
    ├── assets/
    │   └── image/            # Recursos visuales (logo.png)
    ├── lib/
    │   ├── components/       # Componentes reutilizables de la interfaz
    │   │   └── genert/       # Vistas de autenticación y gestión (inicio_sesion, recuperar_contrasena)
    │   ├── core/             # Configuraciones globales y constantes del sistema
    │   ├── models/           # Modelos de datos estructurados (gerent.dart)
    │   ├── pantallas/        # Vistas principales de la aplicación (pantalla_principal.dart)
    │   ├── services/         # Conexión con la API del backend (api_config, gerent_services)
    │   └── main.dart         # Punto de entrada de la aplicación
    └── pubspec.yaml          # Dependencias y recursos de Flutter
```

## 🛠️ Tecnologías Utilizadas

* **Frontend:** Dart, Flutter (Soporte para Android, iOS, Web, Windows, macOS, Linux)
* **Backend:** JavaScript, Node.js, Express

## 📦 Instalación y Configuración

Sigue estos pasos para clonar el proyecto y ejecutarlo en tu entorno local:

### 1. Clonar el repositorio
```bash
git clone https://github.com
cd la-casa-del-tamal
```

### 2. Configurar y lanzar el Backend
Asegúrate de tener instalado [Node.js](https://nodejs.org).
```bash
cd backend
npm install
# Si manejas variables de entorno, configura tu archivo .env aquí
npm start
```

### 3. Configurar y lanzar el Frontend
Asegúrate de tener instalado el SDK de [Flutter](https://flutter.dev).
```bash
cd ../frontend
flutter pub get
# Para ejecutar en el navegador web:
flutter run -d chrome
```

## 👥 Colaboradores
* **Eder Ramos Plaza** - [@ederramosplaza7-eng](https://github.com)
* **Julian** - [@julianvp200805-ctrl](https://github.com)

