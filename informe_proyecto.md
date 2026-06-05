# INFORME DEL PROYECTO: PETROFLOW
**Curso**: Desarrollo de Aplicaciones Móviles con Flutter
**Estudiante**: [Tu Nombre Completo]
**Profesor**: [Nombre del Profesor]

---

## 1. Introducción

### Objetivo de la Aplicación
**PetroFlow** es una aplicación móvil transaccional diseñada específicamente para el sector de la ingeniería petrolera y la supervisión de operaciones en campo. Su objetivo principal es centralizar y digitalizar el registro diario de pozos activos y el control analítico de sus fluidos de perforación (lodos) en tiempo real. 

Tradicionalmente, los reportes de fluidos (densidad, viscosidad, presión, pH) se realizan en papel o en hojas de cálculo aisladas, lo que ralentiza la toma de decisiones críticas frente a posibles brotes o pérdidas de circulación. PetroFlow soluciona este problema proveyendo una interfaz móvil intuitiva, conectada a una API RESTful en la nube (Supabase), que permite a ingenieros de campo y supervisores registrar de forma segura métricas operativas clave y consultar historiales geolocalizados por campo petrolero, aumentando la eficiencia y minimizando el riesgo operativo.

---

## 2. Arquitectura

La aplicación implementa una arquitectura robusta combinando los principios de **Clean Architecture**, **Screaming Architecture**, **Vertical Slicing** y el patrón **MVVM** (Model-View-ViewModel).

```
lib/
├── app/                  # Núcleo de inicialización, rutas y DI manual
│   ├── di/               # Inyección de dependencias
│   ├── routes/           # Declaración y generador de rutas
│   └── theme/            # Material Theme 3
├── core/                 # Utilidades globales de red y sesión
│   ├── config/           # Parámetros y constantes
│   └── network/          # Cliente HTTP y excepciones limpias
└── features/             # Screaming Architecture + Vertical Slices
    ├── auth/             # Slice de Autenticación
    │   ├── data/         # Repositorios, DTOs y Fuentes de datos (Data)
    │   ├── domain/       # Entidades y Casos de uso (Domain)
    │   └── presentation/ # Vistas y ViewModels (Presentation)
    ├── wells/            # Slice de Gestión de Pozos
    └── reports/          # Slice de Reportes de Fluidos
```

### Principios Aplicados

1. **Clean Architecture (Arquitectura Limpia)**:
   Cada característica de la aplicación se divide en tres capas independientes con dependencias apuntando estrictamente hacia el interior:
   * **Capa de Dominio (Domain)**: Contiene las entidades puras del negocio (`Well`, `FluidReport`) y los casos de uso (`CreateWellUseCase`, `GetReportsByWellUseCase`). Es agnóstica de bases de datos, redes o frameworks visuales.
   * **Capa de Datos (Data)**: Contiene los repositorios (`WellsRepositoryImpl`) y los proveedores de red (`WellsRemoteDataSource`). Traduce la información cruda del API (DTOs como `WellDto`) en entidades del dominio.
   * **Capa de Presentación (Presentation)**: Formada por la UI en Flutter (`LoginPage`, `WellsPage`) y su intermediario de estado, el ViewModel (`WellsViewModel`).

2. **Screaming Architecture (Arquitectura Gritante)**:
   Al abrir la carpeta `lib/features/`, el diseño de directorios grita el dominio del problema: `auth`, `wells` y `reports` en lugar de carpetas genéricas como `models`, `views` y `controllers`.

3. **Vertical Slicing (Rebanado Vertical)**:
   Cada módulo funcional es independiente de los demás. Si se requiere modificar el módulo de reportes (`reports`), los cambios quedan completamente encapsulados en ese directorio sin impactar al de pozos (`wells`) ni al de autenticación (`auth`), lo que facilita la escalabilidad y mantenibilidad.

4. **Patrón MVVM (Model-View-ViewModel)**:
   * **Model**: Representa los datos y la lógica del negocio estructurada en la capa de Dominio.
   * **View**: Los widgets de Flutter que renderizan la interfaz gráfica y reaccionan al estado expuesto por el ViewModel.
   * **ViewModel**: Controla la lógica de presentación de la vista, realiza llamadas a los casos de uso y emite notificaciones de cambio de estado.

---

## 3. Gestión de Estado e Inyección de Dependencias

### Uso de Provider como Gestor de Estado
Se implementó la librería oficial **Provider** para notificar de manera reactiva cambios de estado a la interfaz de usuario. Cada ViewModel hereda de `ChangeNotifier`. Cuando se ejecutan procesos asíncronos (como guardar un pozo o consultar el API), el ViewModel modifica variables de control (`isLoading`, `errorMessage`, `wells`) y ejecuta `notifyListeners()`. Esto redibuja únicamente las partes de la UI que están escuchando (`Consumer` o `context.watch<T>()`).

### Inyección de Dependencias Manual
Siguiendo las restricciones técnicas, se evita el uso de librerías como `get_it` o generadores de código. Toda la inyección se maneja de forma explícita y manual en la clase [DependencyInjection](file:///home/productdeath/Documentos/UNIVERSIDAD/Mobiles%202/petroflow/lib/app/di/dependency_injection.dart) mediante `Provider` y `MultiProvider`. 

Los objetos se instancian en orden de jerarquía en el `initState` del Widget, pasando las dependencias por constructor:
1. Instanciación del `ApiClient`.
2. Instanciación de DataSources: `AuthRemoteDataSource(_apiClient)`.
3. Instanciación de Repositorios: `AuthRepositoryImpl(_authRemoteDataSource)`.
4. Instanciación de Casos de Uso: `LoginUseCase(_authRepository)`.
5. Exposición en el árbol de widgets usando `Provider<T>.value()`.

---

## 4. Cliente HTTP

La comunicación transaccional se realiza utilizando la librería oficial **http** como cliente HTTP base, encapsulado dentro de la clase [ApiClient](file:///home/productdeath/Documentos/UNIVERSIDAD/Mobiles%202/petroflow/lib/core/network/api_client.dart). El cliente realiza peticiones seguras enviando tokens Bearer a la API RESTful de Supabase.

### Ejemplos de Implementación del Consumo HTTP

A continuación se detallan ejemplos de cómo la aplicación ejecuta operaciones de red empleando `GET`, `POST`, `PUT` / `PATCH` y `DELETE`.

#### 1. Operación GET (Leer datos)
Utilizado para listar pozos activos. Se ejecuta a través de `http.Client.get()` enviando las cabeceras de autorización de Supabase:
```dart
Future<dynamic> getJson(String path, {Map<String, String>? headers}) async {
  final uri = _baseUri.resolve(path);
  final token = tokenProvider();
  final requestHeaders = {
    'apikey': apiKey,
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${token ?? apiKey}',
    ...?headers,
  };
  final response = await _client.get(uri, headers: requestHeaders);
  // Validación de códigos de estado e interpretación JSON
  return _handleResponse(response);
}
```

#### 2. Operación POST (Crear registros)
Utilizado para dar de alta nuevos pozos o reportes diarios. Envía el payload serializado en JSON:
```dart
Future<dynamic> postJson(String path, {Object? body, Map<String, String>? headers}) async {
  final uri = _baseUri.resolve(path);
  final requestHeaders = {
    'apikey': apiKey,
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${tokenProvider() ?? apiKey}',
    'Prefer': 'return=representation', // Le dice al API que devuelva el registro creado
    ...?headers,
  };
  final response = await _client.post(uri, headers: requestHeaders, body: jsonEncode(body));
  return _handleResponse(response);
}
```

#### 3. Operación PUT / PATCH (Actualizar registros)
Utilizado para modificar datos existentes. Supabase REST aprovecha `PATCH` para actualizaciones parciales sobre filtros condicionales en el query string:
```dart
Future<dynamic> patchJson(String path, {Object? body, Map<String, String>? headers}) async {
  final uri = _baseUri.resolve(path);
  final requestHeaders = {
    'apikey': apiKey,
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${tokenProvider() ?? apiKey}',
    'Prefer': 'return=representation',
    ...?headers,
  };
  final response = await _client.patch(uri, headers: requestHeaders, body: jsonEncode(body));
  return _handleResponse(response);
}
```

#### 4. Operación DELETE (Eliminar registros)
Utilizado para eliminar reportes de fluidos o pozos por su ID:
```dart
Future<dynamic> deleteJson(String path, {Map<String, String>? headers}) async {
  final uri = _baseUri.resolve(path);
  final requestHeaders = {
    'apikey': apiKey,
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${tokenProvider() ?? apiKey}',
    ...?headers,
  };
  final response = await _client.delete(uri, headers: requestHeaders);
  return _handleResponse(response);
}
```

---

## 5. Interfaz Gráfica (Material Theme 3.0)

La aplicación utiliza un diseño adaptativo de alta gama, aprovechando la paleta de colores nativa de Material 3 en tonalidades verde esmeralda y verde bosque (alusivos a fluidos e industria energética), y soporta el modo oscuro automático del sistema operativo.

### Explicación de Widgets Clave Utilizados

1. **CustomScrollView y Slivers**:
   Implementados en las pantallas principales (`DashboardShell`, `WellsPage`, `ReportsPage`) para lograr un desplazamiento fluido. Se utilizaron widgets como `SliverAppBar` con `pinned: true` (barra colapsable interactiva), `SliverPadding` y `SliverList.separated` para mejorar el rendimiento de renderizado en listas largas de pozos y reportes.

2. **Card**:
   Se emplea como el contenedor contenedor principal de registros en la UI (`_ReportCard`, `_HeaderCard`). Le otorga relieve, sombras suaves de elevación 3.0 y bordes redondeados consistentes para segmentar la información de cada pozo y sus respectivas métricas de densidad y viscosidad.

3. **ListTile**:
   Utilizado en la pantalla de pozos para estructurar cada elemento de la lista. Ofrece de manera limpia una estructura predefinida con un avatar a la izquierda (las siglas del pozo), título (nombre del pozo), subtítulo multilinea (ubicación, profundidad, estado operativo) y un menú de acciones contextuales a la derecha.

4. **DropdownButtonFormField**:
   Utilizado en el modal de creación de pozos y en el filtro superior de reportes de fluidos. Permite seleccionar de manera segura y limpia entre los campos petroleros registrados y los pozos activos, enlazándose directamente con la gestión del estado reactivo de Provider.

### Capturas de Pantalla (Placeholder para tus imágenes)

* *[Inserta aquí la captura de la Pantalla de Login: e.g. `![Login](login_screenshot.png)`]*
  *Explicación*: Vista de acceso al sistema con gradientes fluidos en verde bosque, campos de texto autovalidados para credenciales y navegación directa al registro.
* *[Inserta aquí la captura de la Pantalla de Registro: e.g. `![Registro](register_screenshot.png)`]*
  *Explicación*: Formulario de registro que expone de forma intuitiva los roles del sistema (Supervisor e Ingeniero de Campo).
* *[Inserta aquí la captura de la Pantalla del CRUD de Pozos: e.g. `![Pozos CRUD](wells_screenshot.png)`]*
  *Explicación*: Listado interactivo de pozos activos, menús emergentes para Editar/Eliminar y formulario modal inferior adaptado al teclado numérico.
* *[Inserta aquí la captura del Listado y CRUD de Reportes: e.g. `![Reportes CRUD](reports_screenshot.png)`]*
  *Explicación*: Detalle transaccional de fluidos diarios con chips métricos formateados.

---

## 6. Prompts Utilizados en el Proceso

A continuación se detallan los 5 prompts más representativos e ingenieriles utilizados en la conversación con el asistente de Inteligencia Artificial para el desarrollo exitoso del proyecto:

1. **Prompt de Planificación Arquitectónica**:
   > *"Necesito estructurar un proyecto en Flutter desde cero aplicando Arquitectura Limpia combinada con Screaming Architecture y Vertical Slicing. Las features independientes que requeriré son: autenticación, gestión de pozos y reportes de fluidos diarios. Muéstrame el árbol de directorios óptimo que cumpla con estas especificaciones y explica dónde debe situarse cada capa (datos, dominio y presentación) bajo este enfoque."*

2. **Prompt de Configuración del Cliente HTTP y Manejo de Errores**:
   > *"Diseña una clase cliente HTTP genérica (`ApiClient`) en Dart utilizando únicamente la librería `http`. Debe inyectarse de forma manual y admitir llamadas GET, POST, PUT, PATCH y DELETE. Asegúrate de incluir el pase dinámico del token de sesión para Supabase y un extractor de errores robusto que interprete las respuestas fallidas del API."*

3. **Prompt de Gestión de Estado e Inyección Manual**:
   > *"Implementa la inyección de dependencias manual y la gestión de estado de la aplicación utilizando la librería `Provider`. Crea un widget contenedor `DependencyInjection` que instancie y exponga todos los DataSources, Repositorios y Casos de Uso del módulo de Pozos en el orden de dependencias correcto para que estén disponibles de forma segura en las vistas."*

4. **Prompt de Limpieza de Errores Técnicos (Filtro Anti-Jargon)**:
   > *"Quiero remover todo vocabulario técnico, nombres de excepciones de sistema (como ApiException o SocketException) y referencias a JWT o Base de Datos de los mensajes de error mostrados al usuario. Escribe una función traductora en español que analice el error capturado en el catch, identifique patrones técnicos comunes (como 'relation not exist', 'jwt', 'credentials') y devuelva explicaciones amigables y claras."*

5. **Prompt de Creación del Esquema de Base de Datos para Supabase**:
   > *"Escribe un script SQL completo y autoejecutable para el editor de Supabase. Debe crear las tablas `campos`, `pozos`, `profiles` y `fluid_reports` con llaves primarias/secundarias y restricciones de integridad. Añade además un trigger automático en PostgreSQL que inserte un registro en `public.profiles` con el nombre y rol cada vez que un nuevo usuario se registre en `auth.users`."*

---

## 7. Conclusiones

### Retos Enfrentados
1. **Sincronización de Sesiones y Perfiles**:
   El principal reto arquitectónico consistió en vincular de forma transparente la base de datos de autenticación interna de Supabase (`auth.users`) con nuestra tabla de perfiles públicos (`public.profiles`). Se solventó implementando un trigger a nivel base de datos en PL/pgSQL que automatiza la duplicidad de datos en el registro.
2. **Abstracción de Errores para el Usuario Final**:
   Evitar que el usuario final visualice errores técnicos crudos provenientes del backend (como excepciones HTTP o errores de firma de tokens JWT). Esto requirió construir una capa de traducción adaptativa a nivel de ViewModels.
3. **Manejo de Operaciones Relacionales con Clientes HTTP Básicos**:
   Al no utilizar el SDK de Supabase por restricción pedagógica, se debió recrear de manera manual la sintaxis de filtros del API RESTful en la capa de datos móvil para operaciones anidadas (como la obtención del nombre del campo petrolero asociado a cada pozo mediante queries anidados).

### Aprendizajes Obtenidos
* **Beneficios de la Modularización Vertical**:
  El desacoplamiento de características facilita el trabajo aislado sobre una funcionalidad sin miedo a alterar otras partes críticas del software.
* **Control Absoluto del Ciclo de Vida**:
  Aprender a inyectar dependencias y manipular estados de forma manual (sin auto-generadores) otorga un entendimiento profundo sobre el flujo de datos y la administración de memoria en arquitecturas móviles de alto rendimiento.
