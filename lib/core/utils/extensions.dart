import 'package:flutter/material.dart';

/// Extensiones útiles para String
extension StringExtensions on String {
  /// Capitaliza la primera letra
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitaliza cada palabra
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// Verifica si es un email válido
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Verifica si es un número
  bool get isNumeric {
    return double.tryParse(this) != null;
  }
}

/// Extensiones para DateTime
extension DateTimeExtensions on DateTime {
  /// Formatea a dd/MM/yyyy
  String toFormattedDate() {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
  }

  /// Formatea a HH:mm
  String toFormattedTime() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Formatea a dd/MM/yyyy HH:mm
  String toFormattedDateTime() {
    return '${toFormattedDate()} ${toFormattedTime()}';
  }

  /// Verifica si es hoy
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Verifica si es ayer
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
}

/// Extensiones para BuildContext
extension BuildContextExtensions on BuildContext {
  /// Obtiene el tamaño de la pantalla
  Size get screenSize => MediaQuery.of(this).size;

  /// Obtiene el ancho de la pantalla
  double get screenWidth => screenSize.width;

  /// Obtiene el alto de la pantalla
  double get screenHeight => screenSize.height;

  /// Verifica si es modo oscuro
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Obtiene el theme
  ThemeData get theme => Theme.of(this);

  /// Obtiene el color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Muestra un SnackBar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  /// Oculta el teclado
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }
}

/// Extensiones para List
extension ListExtensions<T> on List<T> {
  /// Verifica si la lista no es nula ni vacía
  bool get isNotNullOrEmpty => isNotEmpty;

  /// Obtiene un elemento de forma segura
  T? getOrNull(int index) {
    if (index >= 0 && index < length) {
      return this[index];
    }
    return null;
  }
}
