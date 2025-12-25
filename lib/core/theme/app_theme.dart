import 'package:flutter/material.dart';

/// Professional 2025 Color Palette (60-30-10 Rule)
/// Stable Professionalism & Innovative Tech
class AppTheme {
  // ============================================================
  // 60-30-10 COLOR SYSTEM
  // ============================================================

  // Background (60%) - Soft Professional Grey / Pure White
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F2F5);

  // Primary (30%) - Deep Corporate Blue
  static const Color primaryColor = Color(0xFF003F75);
  static const Color primaryDark = Color(0xFF002D54);
  static const Color primaryLight = Color(0xFF1A5A8F);
  static const Color onPrimary = Colors.white;

  // Secondary - Tech Blue (Sub-headers, Active States)
  static const Color secondaryColor = Color(0xFF2884BD);
  static const Color secondaryDark = Color(0xFF1A6A9A);
  static const Color secondaryLight = Color(0xFF4A9DD0);
  static const Color onSecondary = Colors.white;

  // Accent (10%) - Turquoise/Teal (CTAs, Reality Tasks)
  static const Color accentColor = Color(0xFF0FACB0);
  static const Color accentDark = Color(0xFF0A8A8D);
  static const Color accentLight = Color(0xFF3DBFC2);
  static const Color onAccent = Colors.white;

  // Destructive - Deep Professional Red (Subtle)
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFEF5350);

  // Success & Warning
  static const Color successColor = Color(0xFF2E7D32);
  static const Color warningColor = Color(0xFFED6C02);

  // Neutral / Outline
  static const Color outlineColor = Color(0xFFE0E3E7);
  static const Color outlineVariant = Color(0xFFD0D4D9);
  static const Color dividerColor = Color(0xFFEEF0F2);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1D21);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color textHint = Color(0xFF9AA0A6);
  static const Color textDisabled = Color(0xFFBDC1C6);

  // Role Colors (Aliases)
  static const Color studentColor = primaryColor;
  static const Color teacherColor = secondaryColor;

  // ============================================================
  // ROLE-BASED THEME GETTERS
  // ============================================================

  static ThemeData getThemeForRole(String? role) {
    if (role == 'teacher') return teacherTheme;
    return studentTheme;
  }

  static ThemeData get studentTheme => _buildTheme(
        primary: primaryColor,
        secondary: secondaryColor,
        appBarColor: primaryColor,
      );

  static ThemeData get teacherTheme => _buildTheme(
        primary: secondaryColor,
        secondary: primaryColor,
        appBarColor: secondaryColor,
      );

  static ThemeData get lightTheme => studentTheme;

  // ============================================================
  // THEME BUILDER
  // ============================================================

  static ThemeData _buildTheme({
    required Color primary,
    required Color secondary,
    required Color appBarColor,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundColor,

      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primary.withOpacity(0.12),
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondary.withOpacity(0.12),
        tertiary: accentColor,
        onTertiary: onAccent,
        tertiaryContainer: accentLight.withOpacity(0.2),
        error: errorColor,
        surface: surfaceColor,
        onSurface: textPrimary,
        surfaceContainerHighest: surfaceVariant,
        outline: outlineColor,
        outlineVariant: outlineVariant,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: appBarColor,
        foregroundColor: onPrimary,
        titleTextStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: outlineColor),
        ),
        color: surfaceColor,
        margin: EdgeInsets.zero,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: primary, width: 1.5),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // FAB Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: onAccent,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        selectedColor: secondary.withOpacity(0.15),
        labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),

      // Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,
        elevation: 0,
        indicatorColor: primary.withOpacity(0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primary,
            );
          }
          return const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primary, size: 24);
          }
          return const IconThemeData(color: textSecondary, size: 24);
        }),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        hintStyle: const TextStyle(fontFamily: 'Poppins', color: textHint, fontSize: 14),
        labelStyle: const TextStyle(fontFamily: 'Poppins', color: textSecondary, fontSize: 14),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),

      // Text Theme (Poppins)
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontFamily: 'Poppins', fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary, letterSpacing: -0.5),
        headlineMedium: TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.bold, color: textPrimary, letterSpacing: -0.25),
        headlineSmall: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
        titleLarge: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
        titleMedium: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary),
        titleSmall: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
        bodyLarge: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: textPrimary, height: 1.5),
        bodyMedium: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: textSecondary, height: 1.5),
        bodySmall: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: textSecondary, height: 1.4),
        labelLarge: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
        labelMedium: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary),
        labelSmall: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w500, color: textHint),
      ),
    );
  }

  // ============================================================
  // GRADE & PHASE COLORS
  // ============================================================

  static Color getGradeColor(int grade) {
    switch (grade) {
      case 7: return const Color(0xFF00897B);
      case 8: return const Color(0xFF0288D1);
      case 9: return const Color(0xFF5E35B1);
      case 10: return const Color(0xFF8E24AA);
      case 11: return const Color(0xFFE65100);
      case 12: return const Color(0xFFC62828);
      default: return primaryColor;
    }
  }

  static Color getPhaseColor(String phase) {
    switch (phase.toLowerCase()) {
      case 'discovery': return const Color(0xFF00897B);
      case 'bridge': return const Color(0xFF5E35B1);
      case 'execution': return const Color(0xFFE65100);
      default: return primaryColor;
    }
  }

  static Color getStreamColor(String streamTag) {
    switch (streamTag.toLowerCase()) {
      case 'mpc': return const Color(0xFF1976D2);
      case 'bipc': return const Color(0xFF388E3C);
      case 'mec': return const Color(0xFF7B1FA2);
      case 'cec': return const Color(0xFFE64A19);
      case 'hec': return const Color(0xFF303F9F);
      case 'vocational': return const Color(0xFF00796B);
      default: return primaryColor;
    }
  }

  // ============================================================
  // COMMON DECORATIONS
  // ============================================================

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: outlineColor),
      );

  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static BoxDecoration gradientDecoration(Color color) => BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      );
}
