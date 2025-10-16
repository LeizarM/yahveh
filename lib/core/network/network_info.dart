/// Interface para verificar la conectividad de red
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Implementación de NetworkInfo
class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // TODO: Implementar verificación real de conectividad
    // Puedes usar el paquete connectivity_plus o internet_connection_checker
    return true;
  }
}
