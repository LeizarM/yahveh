# Arquitectura Clean en Yahveh

Este proyecto implementa **Clean Architecture** con Flutter, siguiendo los principios de separación de responsabilidades y diseño modular.

## 📁 Estructura del Proyecto

```
lib/
├── core/                       # Núcleo de la aplicación
│   ├── config/                # Configuraciones globales
│   │   └── app_config.dart
│   ├── constants/             # Constantes de la aplicación
│   │   ├── api_constants.dart
│   │   └── app_constants.dart
│   ├── error/                 # Manejo de errores
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/               # Cliente HTTP y conectividad
│   │   ├── dio_client.dart
│   │   └── network_info.dart
│   ├── state/                 # Estados genéricos
│   │   └── app_state.dart
│   ├── theme/                 # Temas de la aplicación
│   │   └── app_theme.dart
│   └── utils/                 # Utilidades generales
│       ├── extensions.dart
│       └── validators.dart
├── data/                      # Capa de Datos
│   ├── datasources/          # Fuentes de datos (API, local)
│   │   ├── auth_remote_datasource.dart
│   │   └── auth_local_datasource.dart
│   ├── models/               # Modelos de datos (JSON)
│   │   └── user_model.dart
│   └── repositories/         # Implementaciones de repositorios
│       └── auth_repository_impl.dart
├── domain/                    # Capa de Dominio (Lógica de Negocio)
│   ├── entities/             # Entidades de negocio
│   │   └── user_entity.dart
│   ├── repositories/         # Interfaces de repositorios
│   │   └── auth_repository.dart
│   └── usecases/             # Casos de uso
│       └── login_usecase.dart
└── presentation/              # Capa de Presentación (UI)
    ├── providers/            # Providers de Riverpod
    │   ├── providers.dart
    │   └── auth_provider.dart
    ├── routes/               # Configuración de rutas
    │   └── app_router.dart
    ├── screens/              # Pantallas de la aplicación
    │   ├── login_screen.dart
    │   └── home_screen.dart
    └── widgets/              # Widgets reutilizables
        ├── custom_button.dart
        ├── custom_text_field.dart
        └── state_widgets.dart
```

## 🏗️ Capas de la Arquitectura

### 1. **Core (Núcleo)**
Contiene código compartido por todas las capas:
- **Config**: Configuraciones como URLs de API, timeouts, keys, etc.
- **Constants**: Constantes de la aplicación (rutas, mensajes, etc.)
- **Error**: Excepciones y Failures para manejo de errores
- **Network**: Cliente HTTP (Dio) con interceptores
- **State**: Estados genéricos para la UI (Loading, Success, Error, etc.)
- **Theme**: Temas claro y oscuro
- **Utils**: Extensiones, validadores y utilidades

### 2. **Domain (Dominio)**
Contiene la lógica de negocio pura, sin dependencias externas:
- **Entities**: Objetos de negocio inmutables
- **Repositories**: Interfaces (contratos) que definen qué hacer
- **UseCases**: Casos de uso que contienen la lógica de negocio específica

### 3. **Data (Datos)**
Implementa el acceso a datos:
- **DataSources**: Fuentes de datos (Remote: API, Local: Storage)
- **Models**: Modelos que extienden entities + serialización JSON
- **Repositories**: Implementaciones de las interfaces del dominio

### 4. **Presentation (Presentación)**
Capa de UI con Flutter:
- **Providers**: Gestión de estado con Riverpod
- **Routes**: Configuración de navegación con GoRouter
- **Screens**: Pantallas completas de la app
- **Widgets**: Componentes reutilizables

## 🔄 Flujo de Datos

```
UI (Screen/Widget)
    ↓
Provider (Riverpod)
    ↓
UseCase (Domain)
    ↓
Repository Interface (Domain)
    ↓
Repository Implementation (Data)
    ↓
DataSource (Remote/Local)
    ↓
API/Storage
```

## 📦 Dependencias Principales

```yaml
dependencies:
  # Estado y navegación
  flutter_riverpod: ^3.0.3
  go_router: ^16.2.4
  
  # Networking
  dio: ^5.9.0
  
  # Almacenamiento
  flutter_secure_storage: ^9.2.4
  shared_preferences: ^2.5.3
  
  # Manejo funcional de errores
  dartz: ^0.10.1
  
  # Utilidades
  logger: ^2.6.2
  intl: ^0.20.2
```

## 🚀 Cómo Usar

### 1. Crear una Nueva Feature

#### 1.1 Dominio
```dart
// Entity
class ProductEntity {
  final String id;
  final String name;
  const ProductEntity({required this.id, required this.name});
}

// Repository Interface
abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts();
}

// UseCase
class GetProductsUseCase {
  final ProductRepository repository;
  const GetProductsUseCase(this.repository);
  
  Future<Either<Failure, List<ProductEntity>>> call() {
    return repository.getProducts();
  }
}
```

#### 1.2 Data
```dart
// Model
class ProductModel extends ProductEntity {
  const ProductModel({required super.id, required super.name});
  
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(id: json['id'], name: json['name']);
  }
}

// DataSource
abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
}

// Repository Implementation
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  
  ProductRepositoryImpl(this.remoteDataSource);
  
  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async {
    try {
      final products = await remoteDataSource.getProducts();
      return Right(products);
    } catch (e) {
      return Left(ServerFailure('Error al obtener productos'));
    }
  }
}
```

#### 1.3 Presentation
```dart
// Provider
final productProvider = NotifierProvider<ProductNotifier, AppState<List<ProductEntity>>>(() {
  return ProductNotifier();
});

class ProductNotifier extends Notifier<AppState<List<ProductEntity>>> {
  @override
  AppState<List<ProductEntity>> build() => const InitialState();
  
  Future<void> loadProducts() async {
    state = const LoadingState();
    final useCase = ref.read(getProductsUseCaseProvider);
    final result = await useCase();
    
    result.fold(
      (failure) => state = ErrorState(failure.message),
      (products) => state = SuccessState(products),
    );
  }
}

// Screen
class ProductsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productProvider);
    
    return Scaffold(
      body: state.when(
        initial: () => Center(child: Text('Carga productos')),
        loading: () => LoadingWidget(),
        success: (products) => ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(products[index].name),
          ),
        ),
        error: (message) => ErrorWidget(message: message),
      ),
    );
  }
}
```

## 🎯 Principios SOLID

- **S** - Single Responsibility: Cada clase tiene una única responsabilidad
- **O** - Open/Closed: Abierto para extensión, cerrado para modificación
- **L** - Liskov Substitution: Las implementaciones pueden sustituir interfaces
- **I** - Interface Segregation: Interfaces específicas en lugar de generales
- **D** - Dependency Inversion: Depender de abstracciones, no de implementaciones

## ✅ Ventajas de Esta Arquitectura

1. **Testeable**: Cada capa puede probarse independientemente
2. **Escalable**: Fácil de agregar nuevas features sin afectar el código existente
3. **Mantenible**: Código organizado y fácil de entender
4. **Reutilizable**: Componentes desacoplados y reutilizables
5. **Flexible**: Fácil cambiar implementaciones (cambiar Dio por http, etc.)

## 📝 Convenciones de Código

- Los archivos se nombran en `snake_case`
- Las clases en `PascalCase`
- Las variables y funciones en `camelCase`
- Los providers terminan en `Provider`
- Los use cases terminan en `UseCase`
- Los models terminan en `Model`
- Las entities terminan en `Entity`

## 🔐 Seguridad

- Tokens almacenados en `flutter_secure_storage`
- Interceptores de Dio para agregar automáticamente tokens
- Validación de formularios con `Validators`
- Manejo de errores centralizado

## 🧪 Testing

Para probar esta arquitectura, ejecuta:
```bash
flutter test
```

## 📚 Recursos Adicionales

- [Clean Architecture - Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Riverpod](https://riverpod.dev/)
- [GoRouter](https://pub.dev/packages/go_router)
- [Dio](https://pub.dev/packages/dio)

---

**Autor**: Yahveh Development Team  
**Versión**: 1.0.0  
**Última actualización**: Octubre 2025
