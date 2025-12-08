import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/network_info.dart';

/// Provider para la instancia de NetworkInfo
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  final networkInfo = NetworkInfoImpl();
  ref.onDispose(() => networkInfo.dispose());
  return networkInfo;
});

/// Provider que expone el estado actual de la conexión
final connectionStateProvider = StreamProvider<NetworkConnectionState>((ref) {
  final networkInfo = ref.watch(networkInfoProvider);

  // Crear un StreamController para combinar el estado inicial con los cambios
  final controller = StreamController<NetworkConnectionState>();

  // Obtener estado inicial
  networkInfo.connectionState.then((state) {
    if (!controller.isClosed) {
      controller.add(state);
    }
  });

  // Escuchar cambios
  final subscription = networkInfo.onConnectionChanged.listen(
    (state) {
      if (!controller.isClosed) {
        controller.add(state);
      }
    },
    onError: (error) {
      if (!controller.isClosed) {
        controller.addError(error);
      }
    },
  );

  ref.onDispose(() {
    subscription.cancel();
    controller.close();
  });

  return controller.stream;
});

/// Provider simple para saber si hay conexión (bool)
final isConnectedProvider = Provider<bool>((ref) {
  final connectionState = ref.watch(connectionStateProvider);
  return connectionState.when(
    data: (state) => state.status != ConnectionStatus.disconnected,
    loading: () => true, // Asumimos conectado mientras carga
    error: (_, __) => false,
  );
});

/// Provider para saber si la conexión es débil
final isConnectionWeakProvider = Provider<bool>((ref) {
  final connectionState = ref.watch(connectionStateProvider);
  return connectionState.when(
    data: (state) => state.status == ConnectionStatus.weak,
    loading: () => false,
    error: (_, __) => false,
  );
});
