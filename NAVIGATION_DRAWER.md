# NavigationDrawer con Menú Dinámico

## 📱 Implementación Completa

Se ha implementado un **NavigationDrawer** que carga dinámicamente el menú desde el backend, respetando la arquitectura Clean simplificada.

## 🏗️ Arquitectura Implementada

### 1. Domain Layer

#### VistaEntity (`domain/entities/vista_entity.dart`)
```dart
class VistaEntity {
  int codVista;
  int codVistaPadre;
  String direccion;      // URL/ruta de navegación
  String titulo;         // Título del menú
  int audUsuario;
}
```

#### VistaRepository (`domain/repositories/vista_repository.dart`)
```dart
abstract class VistaRepository {
  Future<List<VistaEntity>> getMenu();
}
```

### 2. Data Layer

#### VistaModel (`data/models/vista_model.dart`)
- Extiende de `VistaEntity`
- Implementa `fromJson()` y `toJson()`
- Mapea la respuesta del backend

#### VistaRemoteDataSource (`data/datasources/vista_remote_datasource.dart`)
- Método: `POST /vistas/menu`
- Usa el token automáticamente (DioClient)
- Maneja errores de servidor y conexión

#### VistaRepositoryImpl (`data/repositories/vista_repository_impl.dart`)
- Implementa `VistaRepository`
- Convierte excepciones del servidor en excepciones simples
- Sin uso de Dartz

### 3. Presentation Layer

#### MenuProvider (`presentation/providers/menu_provider.dart`)
```dart
final menuProvider = NotifierProvider<MenuNotifier, AsyncValue<List<VistaEntity>>>();
```

Características:
- Usa `AsyncValue` para manejar estados (loading, data, error)
- Carga el menú automáticamente al inicializar
- Método `refreshMenu()` para recargar

#### AppDrawer (`presentation/widgets/app_drawer.dart`)
Widget completo del NavigationDrawer con:
- **Header con datos del usuario** (foto, nombre, tipo)
- **Menú dinámico** cargado desde el backend
- **Iconos automáticos** según el tipo de vista
- **Manejo de errores** con opción de reintentar
- **Botón de cerrar sesión**

## 🌐 Endpoint de Menú

### Request
```
POST http://192.168.68.51:8080/api/vistas/menu

Headers:
Authorization: Bearer {token}
```

### Response
```json
{
  "success": true,
  "message": "Operación exitosa",
  "data": [
    {
      "codVista": 1,
      "codVistaPadre": 0,
      "direccion": "dashboard",
      "titulo": "Dashboard"
    },
    {
      "codVista": 2,
      "codVistaPadre": 0,
      "direccion": "items",
      "titulo": "Articulos"
    },
    {
      "codVista": 3,
      "codVistaPadre": 0,
      "direccion": "linea",
      "titulo": "Lineas"
    }
  ]
}
```

## 🎨 Características del Drawer

### 1. Header del Usuario
- Avatar circular con inicial del nombre
- Nombre completo del usuario
- Tipo de usuario (Admin, Usuario, etc.)
- Color del tema principal

### 2. Menú Dinámico
- Se carga automáticamente al abrir el drawer
- Iconos asignados automáticamente según el contenido:
  - 📊 Dashboard → `Icons.dashboard`
  - 📦 Artículos/Items → `Icons.inventory_2`
  - 📑 Líneas/Categorías → `Icons.category`
  - 👥 Usuarios → `Icons.people`
  - ⚙️ Configuración → `Icons.settings`
  - 📈 Reportes → `Icons.assessment`
  - ➡️ Otros → `Icons.arrow_forward_ios`

### 3. Navegación
- Al hacer clic en un item, cierra el drawer
- Navega a la ruta especificada en `direccion`
- Maneja rutas con o sin `/` inicial

### 4. Estados

#### Loading
```dart
┌─────────────────────┐
│  🔄 Loading...      │
│  (Progress)         │
└─────────────────────┘
```

#### Error
```dart
┌─────────────────────┐
│  ❌ Error          │
│  Error al cargar    │
│  [🔄 Reintentar]   │
└─────────────────────┘
```

#### Success
```dart
┌─────────────────────┐
│  📊 Dashboard      │
│  📦 Artículos      │
│  📑 Líneas         │
│  ─────────────     │
│  🚪 Cerrar Sesión  │
└─────────────────────┘
```

## 🔐 Seguridad

1. **Token JWT Automático**: El `DioClient` añade automáticamente el token a la petición
2. **401 Handling**: Si el token expira, cierra sesión automáticamente
3. **Error Handling**: Manejo de errores de red y servidor

## 📝 Uso en HomeScreen

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Yahveh - Dashboard'),
    ),
    drawer: const AppDrawer(),  // ← Drawer con menú dinámico
    body: /* ... */,
  );
}
```

## 🎯 Flujo Completo

```
1. Usuario autenticado abre HomeScreen
   ↓
2. HomeScreen incluye AppDrawer
   ↓
3. AppDrawer inicializa MenuProvider
   ↓
4. MenuProvider.build() se ejecuta automáticamente
   ↓
5. MenuProvider llama a repository.getMenu()
   ↓
6. Repository llama a remoteDataSource.getMenu()
   ↓
7. DataSource hace POST a /vistas/menu
   ↓
8. DioClient intercepta y añade Bearer token
   ↓
9. Backend valida token y responde con menú del usuario
   ↓
10. Response se mapea a List<VistaModel>
    ↓
11. State se actualiza a AsyncValue.data(menu)
    ↓
12. AppDrawer.when() detecta el estado 'data'
    ↓
13. Se construye la UI con los items del menú
    ↓
14. Usuario hace clic en un item
    ↓
15. Drawer se cierra
    ↓
16. GoRouter navega a la ruta especificada
```

## 🛠️ Providers Agregados

### En `providers.dart`

```dart
/// Provider para VistaRemoteDataSource
final vistaRemoteDataSourceProvider = Provider<VistaRemoteDataSource>((ref) {
  final client = ref.watch(dioClientProvider);
  return VistaRemoteDataSourceImpl(client);
});

/// Provider para VistaRepository
final vistaRepositoryProvider = Provider<VistaRepository>((ref) {
  final remoteDataSource = ref.watch(vistaRemoteDataSourceProvider);
  return VistaRepositoryImpl(remoteDataSource: remoteDataSource);
});
```

### MenuProvider

```dart
final menuProvider = NotifierProvider<MenuNotifier, AsyncValue<List<VistaEntity>>>(() {
  return MenuNotifier();
});
```

## 🎨 Personalización de Iconos

Para agregar más iconos personalizados, edita el método `_getIconForVista` en `app_drawer.dart`:

```dart
IconData _getIconForVista(VistaEntity vista) {
  final direccion = vista.direccion.toLowerCase();
  final titulo = vista.titulo.toLowerCase();

  // Agrega tus propias condiciones aquí
  if (direccion.contains('ventas') || titulo.contains('ventas')) {
    return Icons.shopping_cart;
  }
  
  // ... más condiciones
  
  return Icons.arrow_forward_ios; // Ícono por defecto
}
```

## 🔄 Refrescar Menú

Para recargar el menú manualmente:

```dart
ref.read(menuProvider.notifier).refreshMenu();
```

Esto es útil si:
- Los permisos del usuario cambian
- Se actualiza el menú en el backend
- Hay un error de carga y se quiere reintentar

## ⚡ Rendimiento

- El menú se carga **una sola vez** al inicializar el provider
- Se cachea en el estado del provider
- No se recarga en cada apertura del drawer
- Uso eficiente de AsyncValue para evitar rebuilds innecesarios

## 📦 Archivos Nuevos Creados

```
lib/
├── domain/
│   └── repositories/
│       └── vista_repository.dart          ✨ NUEVO
├── data/
│   ├── datasources/
│   │   └── vista_remote_datasource.dart   ✨ NUEVO
│   └── repositories/
│       └── vista_repository_impl.dart     ✨ NUEVO
└── presentation/
    ├── providers/
    │   └── menu_provider.dart             ✨ NUEVO
    └── widgets/
        └── app_drawer.dart                ✨ NUEVO
```

## 📝 Archivos Modificados

```
lib/
├── core/
│   └── constants/
│       └── api_constants.dart             ✏️ MODIFICADO (agregado endpoint /vistas/menu)
├── data/
│   └── models/
│       └── vista_model.dart               ✏️ MODIFICADO (extiende VistaEntity)
├── presentation/
│   ├── providers/
│   │   └── providers.dart                 ✏️ MODIFICADO (agregados providers de Vista)
│   └── screens/
│       └── home_screen.dart               ✏️ MODIFICADO (agregado AppDrawer)
```

## ✅ Verificación

```bash
flutter analyze
# Output: No issues found! ✅
```

## 🚀 Siguientes Pasos

1. **Crear las pantallas** para las rutas del menú:
   - `/dashboard` o `/`
   - `/items` o `/articulos`
   - `/linea` o `/lineas`

2. **Actualizar app_router.dart** con las nuevas rutas

3. **Implementar navegación jerárquica** si hay menús con submenús (codVistaPadre != 0)

4. **Agregar permisos** si es necesario validar accesos por vista

## 🎯 Resultado Final

Al abrir el drawer, el usuario verá:
- Su foto/inicial y nombre
- Su rol/tipo de usuario
- Lista completa de opciones del menú según sus permisos
- Opción de cerrar sesión

¡Todo cargado dinámicamente desde el backend con manejo automático de token JWT! 🎉
