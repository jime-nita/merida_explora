# Mérida Explora 🌸

App móvil hecha con Flutter para guardar los lugares que descubres en Mérida,
con foto, tu opinión y su ubicación en el mapa.

Proyecto del Parcial 2 de Programación de Dispositivos Móviles
(Universidad Anáhuac Mayab). Autora: Jimena Carolina Tun Sosa.

## ¿Qué problema resuelve?

Cuando descubres un buen café, un cenote o un parque, es fácil olvidar el nombre
o cómo volver. Mérida Explora guarda cada lugar con su foto, tu opinión y sus
coordenadas GPS, y desde el detalle puedes ver el mapa o abrir Google Maps.
Hoy cubre Mérida, pero la estructura permite crecer a otras ciudades.

## Funciones

| Requisito del parcial | Cómo se resolvió |
|---|---|
| UI avanzada | `Scaffold`, `AppBar` y `Drawer` con la opción actual resaltada |
| Navegación | Rutas con nombre (`AppRoutes`) y `Navigator` entre login, lista, formulario y detalle |
| Animaciones | `Hero` en la foto al pasar de la lista al detalle |
| Almacenamiento local | SQLite (`sqflite`); fotos y coordenadas guardadas como JSON en una columna de metadatos |
| Carga asíncrona | `FutureBuilder` con estados de carga, error, lista vacía y datos |
| Manejo de errores | `try-catch` en repositorio y servicios, con mensajes claros al usuario |
| Cámara y galería | `image_picker`; la foto se copia a la carpeta de la app |
| Audio y dictado | `speech_to_text` con el micrófono (ver notas) |
| GPS | `geolocator` captura la posición al guardar |
| Mapa | `flutter_map` con OpenStreetMap y botón para abrir Google Maps |
| Login biométrico | `local_auth` (huella, rostro o PIN) antes de entrar |
| Permisos | `permission_handler`; si se niegan, la app avisa y ofrece abrir Ajustes |

## Arquitectura por capas

```
lib/
├── models/     # Lugar (datos, toMap/fromMap, JSON)
├── data/       # LugarRepositorio (contrato) y LugarRepositorioSqlite
├── services/   # Permisos, imagen, ubicación, voz y biometría
├── screens/    # Login, lista, formulario y detalle
├── widgets/    # Menú lateral y foto con Hero
├── routes/     # Nombres de rutas
├── theme/      # Colores pastel y tema
└── main.dart
```

Se aplicaron principios SOLID: cada servicio tiene una sola responsabilidad,
las pantallas dependen del contrato `LugarRepositorio` y no de SQLite, y los
servicios reciben `ServicioPermisos` por su constructor.

## Cómo ejecutarla

1. Instala Flutter y Android Studio.
2. Clona el repositorio y ejecuta `flutter pub get`.
3. Abre un emulador Android (API 34 con Google Play) o conecta un celular.
4. Ejecuta `flutter run`.

La app es **solo para Android** (mínimo Android 7, API 24).

## Notas

- `permission_handler` se fijó en la versión 12 por compatibilidad con la
  versión de Gradle del proyecto.
- El dictado depende del servicio de reconocimiento de voz del dispositivo.
  En emuladores puede no estar disponible; en ese caso la opinión se escribe a mano.
- El mapa necesita conexión a internet para cargar los mosaicos.