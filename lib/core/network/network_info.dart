import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Estados posibles de la conexión a internet
enum ConnectionStatus {
  /// Conectado con buena señal
  connected,

  /// Conectado pero con señal débil o inestable
  weak,

  /// Sin conexión a internet
  disconnected,
}

/// Información detallada del estado de la conexión
class NetworkConnectionState {
  final ConnectionStatus status;
  final String message;
  final ConnectivityResult? connectionType;

  const NetworkConnectionState({
    required this.status,
    required this.message,
    this.connectionType,
  });

  /// Estado por defecto (conectado)
  factory NetworkConnectionState.connected([ConnectivityResult? type]) {
    return NetworkConnectionState(
      status: ConnectionStatus.connected,
      message: 'Conectado a internet',
      connectionType: type,
    );
  }

  /// Estado de conexión débil
  factory NetworkConnectionState.weak([ConnectivityResult? type]) {
    String typeMessage = '';
    if (type == ConnectivityResult.mobile) {
      typeMessage = ' (Datos móviles)';
    } else if (type == ConnectivityResult.wifi) {
      typeMessage = ' (WiFi)';
    }
    return NetworkConnectionState(
      status: ConnectionStatus.weak,
      message: 'Conexión débil o inestable$typeMessage',
      connectionType: type,
    );
  }

  /// Estado sin conexión
  factory NetworkConnectionState.disconnected() {
    return const NetworkConnectionState(
      status: ConnectionStatus.disconnected,
      message: 'Sin conexión a internet',
      connectionType: null,
    );
  }

  bool get isConnected => status == ConnectionStatus.connected;
  bool get isWeak => status == ConnectionStatus.weak;
  bool get isDisconnected => status == ConnectionStatus.disconnected;
}

/// Interface para verificar la conectividad de red
abstract class NetworkInfo {
  /// Verifica si hay conexión a internet
  Future<bool> get isConnected;

  /// Obtiene el estado detallado de la conexión
  Future<NetworkConnectionState> get connectionState;

  /// Stream que emite cambios en el estado de la conexión
  Stream<NetworkConnectionState> get onConnectionChanged;

  /// Libera recursos
  void dispose();
}

/// Implementación de NetworkInfo usando connectivity_plus
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;
  StreamController<NetworkConnectionState>? _connectionController;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  NetworkConnectionState _lastState = NetworkConnectionState.connected();

  NetworkInfoImpl({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity() {
    _initializeStream();
  }

  void _initializeStream() {
    _connectionController =
        StreamController<NetworkConnectionState>.broadcast();

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (results) async {
        final state = await _checkConnectionQuality(results);
        if (state.status != _lastState.status) {
          _lastState = state;
          _connectionController?.add(state);
        }
      },
      onError: (error) {
        debugPrint('Error en connectivity stream: $error');
        _lastState = NetworkConnectionState.disconnected();
        _connectionController?.add(_lastState);
      },
    );
  }

  @override
  Future<bool> get isConnected async {
    final state = await connectionState;
    return state.status != ConnectionStatus.disconnected;
  }

  @override
  Future<NetworkConnectionState> get connectionState async {
    try {
      final results = await _connectivity.checkConnectivity();
      return await _checkConnectionQuality(results);
    } catch (e) {
      debugPrint('Error al verificar conectividad: $e');
      return NetworkConnectionState.disconnected();
    }
  }

  @override
  Stream<NetworkConnectionState> get onConnectionChanged {
    return _connectionController?.stream ?? const Stream.empty();
  }

  /// Verifica la calidad de la conexión haciendo un ping real
  Future<NetworkConnectionState> _checkConnectionQuality(
    List<ConnectivityResult> results,
  ) async {
    // Si no hay resultados o solo hay "none", no hay conexión
    if (results.isEmpty || results.every((r) => r == ConnectivityResult.none)) {
      return NetworkConnectionState.disconnected();
    }

    // Obtener el tipo de conexión principal (excluir 'none')
    final activeResults = results
        .where((r) => r != ConnectivityResult.none)
        .toList();
    if (activeResults.isEmpty) {
      return NetworkConnectionState.disconnected();
    }

    final primaryConnection = activeResults.first;

    // Verificar conexión real haciendo un ping
    try {
      final stopwatch = Stopwatch()..start();

      // Intentar conectar a Google DNS para verificar internet real
      final socket = await Socket.connect(
        '8.8.8.8',
        53,
        timeout: const Duration(seconds: 5),
      );
      socket.destroy();

      stopwatch.stop();
      final latency = stopwatch.elapsedMilliseconds;

      // Determinar calidad basada en latencia
      if (latency > 2000) {
        // Más de 2 segundos = conexión débil
        return NetworkConnectionState.weak(primaryConnection);
      } else if (latency > 1000) {
        // Entre 1-2 segundos = conexión algo lenta pero funcional
        return NetworkConnectionState.weak(primaryConnection);
      } else {
        // Menos de 1 segundo = buena conexión
        return NetworkConnectionState.connected(primaryConnection);
      }
    } on SocketException {
      // No hay conexión real a internet
      return NetworkConnectionState.disconnected();
    } on TimeoutException {
      // Timeout = conexión muy débil o sin internet
      return NetworkConnectionState.weak(primaryConnection);
    } catch (e) {
      debugPrint('Error al verificar calidad de conexión: $e');
      // En caso de error, asumimos que hay conexión pero posiblemente débil
      return NetworkConnectionState.weak(primaryConnection);
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionController?.close();
  }
}
