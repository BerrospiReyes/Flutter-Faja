# 🏭 Faja IoT - App de Control y Monitoreo

Aplicación móvil desarrollada en **Flutter** para el control y supervisión en tiempo real de una faja transportadora clasificadora de objetos. Este proyecto actúa como la interfaz de usuario (Frontend) de un sistema IoT completo que integra un **ESP32** y un **Backend**.

## 📋 Características Principales

* **🕹️ Control Remoto:** Encendido y apagado del motor de la faja mediante peticiones HTTP.
* **📡 Monitoreo de Sensores:** Visualización en tiempo real del estado de los 3 sensores ópticos (S1, S2, S3).
* **📦 Conteo de Objetos:** Panel estadístico que muestra la cantidad de cajas clasificadas por tamaño:
    * 🔴 Pequeñas
    * 🔵 Medianas
    * 🟢 Grandes
* **⚡ Feedback Visual:** Indicadores de estado de conexión y actividad del motor ("MOTOR: ANDANDO" / "MOTOR: DETENIDO").

## 🛠️ Tecnologías Utilizadas

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **Comunicación:** HTTP (REST API)
* **Plataformas Soportadas:** Android (Probado).

## ⚙️ Configuración del Proyecto

### Prerrequisitos
* Flutter SDK instalado (Versión recomendada: >=3.10.1).
* Dispositivo Android o Emulador.
* Conexión a Internet (para comunicar con el servidor Render).

### Instalación

1.  **Clonar el repositorio:**
    ```bash
    git clone [https://github.com/TU_USUARIO/faja-iot-flutter.git](https://github.com/TU_USUARIO/faja-iot-flutter.git)
    cd faja_iot
    ```

2.  **Instalar dependencias:**
    ```bash
    flutter pub get
    ```

3.  **Configurar la API:**
    Abre el archivo `lib/main.dart` y busca la variable de la URL. Asegúrate de que apunte a tu servidor Backend activo:
    ```dart
    // Ejemplo en lib/main.dart
    final String apiUrl = "[https://tu-backend-en-render.com](https://tu-backend-en-render.com)";
    ```

4.  **Ejecutar la App:**
    ```bash
    flutter run
    ```

## 📱 Estructura del Proyecto

* `lib/main.dart`: Contiene toda la lógica de la UI, el estado de los sensores (`s1`, `s2`, `s3`) y las funciones de control (`controlMotor`).
* `android/app/src/main/AndroidManifest.xml`: Configurado con permisos de INTERNET para permitir las peticiones HTTP.
* `pubspec.yaml`: Gestión de dependencias (`http`, `cupertino_icons`).

## 🔍 Solución de Problemas Comunes

**Error de conexión (SocketException):**
* Asegúrate de que tu celular/emulador tenga acceso a internet.
* Verifica que la URL del backend en `lib/main.dart` no tenga errores de escritura y use `https`.
