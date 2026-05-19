import 'dart:async';
import 'package:flutter/material.dart';

/// Shows messages (success, error, warning, info) above every layer including dialogs.
/// Uses the root overlay so the message is always visible regardless of open dialogs.
class AppOverlay {
  static void showMessage(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isWarning = false,
    bool isSuccess = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _OverlayMessage(
        message: message,
        isError: isError,
        isWarning: isWarning,
        isSuccess: isSuccess,
        duration: duration,
        onDismiss: () {
          if (entry.mounted) entry.remove();
        },
      ),
    );
    overlay.insert(entry);
  }
}

class _OverlayMessage extends StatefulWidget {
  final String message;
  final bool isError;
  final bool isWarning;
  final bool isSuccess;
  final Duration duration;
  final VoidCallback onDismiss;

  const _OverlayMessage({
    required this.message,
    required this.isError,
    required this.isWarning,
    required this.isSuccess,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_OverlayMessage> createState() => _OverlayMessageState();
}

class _OverlayMessageState extends State<_OverlayMessage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );
    _slide = Tween<Offset>(begin: const Offset(0, 1.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
    _timer = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    _timer?.cancel();
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final IconData icon;
    final Color iconColor;

    if (widget.isError) {
      bg = const Color(0xFFB71C1C);
      icon = Icons.error_outline_rounded;
      iconColor = Colors.red.shade200;
    } else if (widget.isWarning) {
      bg = const Color(0xFFBF360C);
      icon = Icons.warning_amber_rounded;
      iconColor = Colors.orange.shade200;
    } else if (widget.isSuccess) {
      bg = const Color(0xFF1B5E20);
      icon = Icons.check_circle_outline_rounded;
      iconColor = Colors.green.shade200;
    } else {
      bg = const Color(0xFF212121);
      icon = Icons.info_outline_rounded;
      iconColor = Colors.blue.shade200;
    }

    final bottom = MediaQuery.of(context).padding.bottom + 16;

    return Positioned(
      bottom: bottom,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Material(
            elevation: 12,
            borderRadius: BorderRadius.circular(14),
            color: bg,
            shadowColor: Colors.black54,
            child: InkWell(
              onTap: _dismiss,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(
                  children: [
                    Icon(icon, color: iconColor, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.close, color: Colors.white.withValues(alpha: 0.6), size: 18),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
