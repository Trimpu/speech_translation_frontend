import 'package:flutter/material.dart';

class AppTheme {
  // 🎨 Premium Color Palette
  static const Color primaryPurple = Color(0xFF6366F1);
  static const Color secondaryViolet = Color(0xFF8B5CF6);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color premiumGold = Color(0xFFFFD700);
  static const Color neonCyan = Color(0xFF00F5FF);
  
  // 🌌 Background Gradients
  static const Color darkBg1 = Color(0xFF0F0F23);
  static const Color darkBg2 = Color(0xFF1A1A2E);
  static const Color darkBg3 = Color(0xFF16213E);
  
  // 🤍 Glass & Surface Colors
  static const Color glassWhite = Color(0x20FFFFFF);
  static const Color glassBorder = Color(0x30FFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E2E);
  static const Color cardDark = Color(0xFF2A2A3E);
  
  // 📝 Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF);
  static const Color textMuted = Color(0x80FFFFFF);

  // 🎭 Main App Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Inter',
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryPurple,
        secondary: secondaryViolet,
        tertiary: accentCyan,
        surface: surfaceDark,
        onSurface: textPrimary,
        background: darkBg1,
        onBackground: textPrimary,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      
      // Card Theme (for glassmorphic effects)
      cardTheme: CardThemeData(
        color: glassWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: glassBorder,
            width: 1,
          ),
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: primaryPurple.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),
    );
  }

  // 🌈 Gradient Decorations
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkBg1, darkBg2, darkBg3],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x30FFFFFF),
      Color(0x10FFFFFF),
    ],
  );

  static const LinearGradient recordButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPurple, secondaryViolet, accentCyan],
  );

  static const LinearGradient activeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neonCyan, premiumGold],
  );

  // 💫 Box Shadows
  static List<BoxShadow> get glassShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 20,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: primaryPurple.withOpacity(0.1),
      blurRadius: 40,
      spreadRadius: 0,
      offset: const Offset(0, 16),
    ),
  ];

  static List<BoxShadow> get neumorphicShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 15,
      offset: const Offset(5, 5),
    ),
    BoxShadow(
      color: Colors.white.withOpacity(0.05),
      blurRadius: 15,
      offset: const Offset(-5, -5),
    ),
  ];

  // 📱 Responsive Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // 🎯 Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
}
