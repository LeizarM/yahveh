import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/network_info.dart';
import '../../core/theme/app_theme.dart';
import '../providers/connectivity_provider.dart';

/// Widget que envuelve la aplicación y muestra alertas de conectividad
class ConnectivityWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  ConsumerState<ConnectivityWrapper> createState() =>
      _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends ConsumerState<ConnectivityWrapper> {
  ConnectionStatus? _lastStatus;
  bool _isShowingBanner = false;

  @override
  Widget build(BuildContext context) {
    // Escuchar cambios en el estado de conexión
    ref.listen<AsyncValue<NetworkConnectionState>>(connectionStateProvider, (
      previous,
      next,
    ) {
      next.whenData((state) {
        _handleConnectionChange(state);
      });
    });

    final connectionState = ref.watch(connectionStateProvider);

    return Stack(
      children: [
        widget.child,
        // Banner persistente cuando no hay conexión
        if (_isShowingBanner)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: connectionState.when(
                data: (state) => _buildConnectionBanner(state),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => _buildConnectionBanner(
                  NetworkConnectionState.disconnected(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _handleConnectionChange(NetworkConnectionState state) {
    // Si el estado cambió
    if (_lastStatus != state.status) {
      final previousStatus = _lastStatus;
      _lastStatus = state.status;

      // Mostrar u ocultar el banner según el estado
      switch (state.status) {
        case ConnectionStatus.connected:
          // Si venimos de un estado malo, mostrar mensaje de reconexión
          if (previousStatus != null &&
              previousStatus != ConnectionStatus.connected) {
            _showSnackBar(
              message: '✓ Conexión restablecida',
              backgroundColor: AppTheme.successColor,
              duration: const Duration(seconds: 3),
            );
          }
          // Ocultar banner
          if (_isShowingBanner) {
            setState(() => _isShowingBanner = false);
          }
          break;

        case ConnectionStatus.weak:
          _showSnackBar(
            message: '⚠ ${state.message}',
            backgroundColor: Colors.orange.shade700,
            duration: const Duration(seconds: 4),
          );
          // No mostramos banner persistente para conexión débil
          if (_isShowingBanner) {
            setState(() => _isShowingBanner = false);
          }
          break;

        case ConnectionStatus.disconnected:
          _showSnackBar(
            message: '✗ ${state.message}',
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 5),
          );
          // Mostrar banner persistente
          setState(() => _isShowingBanner = true);
          break;
      }
    }
  }

  void _showSnackBar({
    required String message,
    required Color backgroundColor,
    required Duration duration,
  }) {
    // Usar addPostFrameCallback para evitar llamar durante el build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  _getIconForStatus(_lastStatus),
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: backgroundColor,
            behavior: SnackBarBehavior.floating,
            duration: duration,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    });
  }

  IconData _getIconForStatus(ConnectionStatus? status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Icons.wifi;
      case ConnectionStatus.weak:
        return Icons.signal_wifi_statusbar_connected_no_internet_4;
      case ConnectionStatus.disconnected:
        return Icons.wifi_off;
      default:
        return Icons.wifi;
    }
  }

  Widget _buildConnectionBanner(NetworkConnectionState state) {
    if (state.status == ConnectionStatus.connected) {
      return const SizedBox.shrink();
    }

    Color backgroundColor;
    IconData icon;
    String message;

    switch (state.status) {
      case ConnectionStatus.weak:
        backgroundColor = Colors.orange.shade700;
        icon = Icons.signal_wifi_statusbar_connected_no_internet_4;
        message = state.message;
        break;
      case ConnectionStatus.disconnected:
        backgroundColor = AppTheme.errorColor;
        icon = Icons.wifi_off;
        message = state.message;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Material(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: backgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 10),
            // Botón para reintentar
            TextButton(
              onPressed: () async {
                // Forzar verificación de conexión
                final networkInfo = ref.read(networkInfoProvider);
                final newState = await networkInfo.connectionState;
                if (newState.status == ConnectionStatus.connected) {
                  setState(() => _isShowingBanner = false);
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Colors.white54),
                ),
              ),
              child: const Text('Reintentar', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
