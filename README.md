# La Casa del Tamal 🫔

¡Bienvenido al repositorio de **La Casa del Tamal**! Este proyecto es una aplicación web y móvil multiplataforma completa que consta de un entorno cliente y un servidor dedicado.

## 🚀 Estructura del Proyecto

A continuación se detalla la organización de los directorios principales del proyecto:

```text
la-casa-del-tamal/
├── backend/                  # Servidor y API (Node.js)
│   ├── src/                  # Código fuente del servidor
│   ├── package.json          # Dependencias del backend
│   └── .env.example          # Plantilla de variables de entorno
├── frontend/                 # Aplicación cliente (Flutter)
│   ├── lib/                  # Código fuente de Dart (pantallas, widgets, lógica)
│   ├── pubspec.yaml          # Dependencias de Flutter
│   └── assets/               # Imágenes, fuentes y recursos estáticos
└── README.md                 # Documentación del proyecto
```

## 🛠️ Tecnologías Utilizadas

* **Frontend:** Dart, Flutter (Web/Mobile)
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

