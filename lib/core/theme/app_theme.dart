import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Spacing Scale
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 20.0;

  // Colors - Clinic Brand (Modern Teal/Blue)
  static const Color primaryColor = Color(0xFF00796B);
  static const Color secondaryColor = Color(0xFF004D40);

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        elevation: 0,
        color: Colors.white.withValues(alpha: 0.8),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        surface: const Color(0xFF121212),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        elevation: 0,
        color: const Color(0xFF1E1E1E).withValues(alpha: 0.8),
      ),
    );
  }

  // Glassmorphism Decoration
  static BoxDecoration glassDecoration({
    required BuildContext context,
    double blur = 15.0,
    double opacity = 0.7,
    BorderRadius? borderRadius,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: (isDark ? const Color(0xFF1E1E1E) : Colors.white).withValues(alpha: opacity),
      borderRadius: borderRadius ?? BorderRadius.circular(radiusMedium),
      border: Border.all(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
      ),
    );
  }

  static Widget glassEffect({
    required Widget child,
    double blur = 15.0,
  }) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: child,
      ),
    );
  }
}
