import 'package:flutter/material.dart';

/// Tema moderno de la aplicación con glassmorphism y animaciones
class AppTheme {
  // ============================================================================
  // PALETA DE COLORES MODERNA - ESMERALDA OSCURO / PROFESIONAL
  // ============================================================================
  
  // Colores principales - Gradiente azul oscuro/esmeralda elegante
  static const Color primaryColor = Color(0xFF0f766e);      // Teal oscuro
  static const Color primaryDark = Color(0xFF0d5d56);       // Teal más oscuro
  static const Color primaryLight = Color(0xFF14b8a6);      // Teal brillante
  
  // Colores secundarios - Azul oscuro profundo
  static const Color secondaryColor = Color(0xFF1e3a5f);    // Azul noche
  static const Color secondaryDark = Color(0xFF0f172a);     // Azul muy oscuro
  static const Color secondaryLight = Color(0xFF3b82f6);    // Azul claro
  
  // Colores de acento
  static const Color accentPink = Color(0xFFfb7185);        // Rosa coral
  static const Color accentCyan = Color(0xFF06b6d4);        // Cian vibrante
  static const Color accentGreen = Color(0xFF22c55e);       // Verde esmeralda
  static const Color accentOrange = Color(0xFFf97316);      // Naranja cálido
  
  // Colores de estado
  static const Color successColor = Color(0xFF22c55e);
  static const Color warningColor = Color(0xFFf59e0b);
  static const Color errorColor = Color(0xFFef4444);
  static const Color infoColor = Color(0xFF0ea5e9);
  
  // Fondos - Tonos oscuros elegantes
  static const Color backgroundLight = Color(0xFFF0FDF4);   // Verde muy claro
  static const Color backgroundDark = Color(0xFF0a1628);    // Azul muy oscuro
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1a2e44);       // Azul noche
  
  // Colores para cards glassmorphism
  static const Color glassLight = Color(0x20FFFFFF);
  static const Color glassDark = Color(0x20000000);
  
  // Colores adicionales para gradientes
  static const Color gradientStart = Color(0xFF0f766e);     // Teal
  static const Color gradientMiddle = Color(0xFF1e3a5f);    // Azul noche
  static const Color gradientEnd = Color(0xFF0d3331);       // Verde oscuro profundo

  // ============================================================================
  // DECORACIONES GLASSMORPHISM
  // ============================================================================
  
  /// Decoración de vidrio para modo claro
  static BoxDecoration get glassDecorationLight => BoxDecoration(
    color: Colors.white.withValues(alpha: 0.7),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.5),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 20,
        spreadRadius: 0,
        offset: const Offset(0, 10),
      ),
    ],
  );

  /// Decoración de vidrio para modo oscuro
  static BoxDecoration get glassDecorationDark => BoxDecoration(
    color: Colors.white.withValues(alpha: 0.05),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.1),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 20,
        spreadRadius: 0,
        offset: const Offset(0, 10),
      ),
    ],
  );

  /// Gradiente principal
  static LinearGradient get primaryGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, secondaryColor],
  );

  /// Gradiente de fondo para pantallas - Elegante azul/verde oscuro
  static LinearGradient get backgroundGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      gradientStart,      // Teal oscuro
      gradientMiddle,     // Azul noche
      gradientEnd,        // Verde oscuro profundo
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // ============================================================================
  // TEMA CLARO
  // ============================================================================
  
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentPink,
      error: errorColor,
      surface: surfaceLight,
    ),
    scaffoldBackgroundColor: backgroundLight,
    
    // AppBar
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
        size: 24,
      ),
    ),
    
    // Botones elevados
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    
    // Botones filled
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Botones outlined
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        side: BorderSide(color: primaryColor.withValues(alpha: 0.5), width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Text buttons
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    // Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      labelStyle: TextStyle(
        color: Colors.grey.shade600,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 15,
      ),
      prefixIconColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return primaryColor;
        }
        return Colors.grey.shade500;
      }),
      suffixIconColor: Colors.grey.shade500,
    ),
    
    // Cards
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
    ),
    
    // Dialogs
    dialogTheme: DialogThemeData(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
    
    // Bottom sheets
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    
    // Snackbars
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: surfaceDark,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
    ),
    
    // Floating Action Button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 4,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      extendedTextStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
    
    // Navigation drawer
    navigationDrawerTheme: NavigationDrawerThemeData(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: primaryColor.withValues(alpha: 0.12),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          );
        }
        return TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade700,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: primaryColor, size: 24);
        }
        return IconThemeData(color: Colors.grey.shade600, size: 24);
      }),
    ),
    
    // List tiles
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      titleTextStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      subtitleTextStyle: TextStyle(
        fontSize: 13,
        color: Colors.grey.shade600,
      ),
    ),
    
    // Chips
    chipTheme: ChipThemeData(
      backgroundColor: primaryColor.withValues(alpha: 0.1),
      labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    
    // Dividers
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade200,
      thickness: 1,
      space: 1,
    ),
    
    // Progress indicators
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryColor,
      linearTrackColor: Color(0xFFE0E0E0),
      circularTrackColor: Color(0xFFE0E0E0),
    ),
    
    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return Colors.grey.shade400;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor;
        }
        return Colors.grey.shade300;
      }),
    ),
    
    // Tab bar
    tabBarTheme: TabBarThemeData(
      labelColor: primaryColor,
      unselectedLabelColor: Colors.grey.shade500,
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: primaryColor.withValues(alpha: 0.12),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
    ),
    
    // Page transitions
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  );

  // ============================================================================
  // TEMA OSCURO
  // ============================================================================
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryLight,
      secondary: secondaryLight,
      tertiary: accentPink,
      error: errorColor,
      surface: surfaceDark,
    ),
    scaffoldBackgroundColor: backgroundDark,
    
    // AppBar
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
        size: 24,
      ),
    ),
    
    // Botones elevados
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    
    // Botones filled
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Botones outlined
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        side: BorderSide(color: primaryLight.withValues(alpha: 0.5), width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Text buttons
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    // Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade800, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade800, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      labelStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: Colors.grey.shade600,
        fontSize: 15,
      ),
      prefixIconColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return primaryLight;
        }
        return Colors.grey.shade500;
      }),
      suffixIconColor: Colors.grey.shade500,
    ),
    
    // Cards
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: surfaceDark,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
    ),
    
    // Dialogs
    dialogTheme: DialogThemeData(
      elevation: 0,
      backgroundColor: surfaceDark,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    
    // Bottom sheets
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surfaceDark,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    
    // Snackbars
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: surfaceLight,
      contentTextStyle: const TextStyle(
        color: Colors.black87,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
    ),
    
    // Floating Action Button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 4,
      backgroundColor: primaryLight,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      extendedTextStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
    
    // Navigation drawer
    navigationDrawerTheme: NavigationDrawerThemeData(
      elevation: 0,
      backgroundColor: surfaceDark,
      surfaceTintColor: Colors.transparent,
      indicatorColor: primaryLight.withValues(alpha: 0.15),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: primaryLight,
          );
        }
        return TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade400,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: primaryLight, size: 24);
        }
        return IconThemeData(color: Colors.grey.shade500, size: 24);
      }),
    ),
    
    // List tiles
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      titleTextStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      subtitleTextStyle: TextStyle(
        fontSize: 13,
        color: Colors.grey.shade400,
      ),
    ),
    
    // Chips
    chipTheme: ChipThemeData(
      backgroundColor: primaryLight.withValues(alpha: 0.15),
      labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: primaryLight,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    
    // Dividers
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade800,
      thickness: 1,
      space: 1,
    ),
    
    // Progress indicators
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryLight,
      linearTrackColor: Color(0xFF374151),
      circularTrackColor: Color(0xFF374151),
    ),
    
    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return Colors.grey.shade600;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return Colors.grey.shade800;
      }),
    ),
    
    // Tab bar
    tabBarTheme: TabBarThemeData(
      labelColor: primaryLight,
      unselectedLabelColor: Colors.grey.shade500,
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: primaryLight.withValues(alpha: 0.15),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
    ),
    
    // Page transitions
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  );
}

// ============================================================================
// EXTENSION PARA ACCESO RÁPIDO A COLORES DEL TEMA
// ============================================================================

extension ThemeExtension on BuildContext {
  /// Obtiene el gradiente principal
  LinearGradient get primaryGradient => AppTheme.primaryGradient;
  
  /// Obtiene el gradiente de fondo
  LinearGradient get backgroundGradient => AppTheme.backgroundGradient;
  
  /// Obtiene la decoración glassmorphism según el tema
  BoxDecoration get glassDecoration => Theme.of(this).brightness == Brightness.light
      ? AppTheme.glassDecorationLight
      : AppTheme.glassDecorationDark;
}
