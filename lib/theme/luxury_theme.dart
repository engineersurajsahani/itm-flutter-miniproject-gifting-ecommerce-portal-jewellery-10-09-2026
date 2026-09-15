import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LuxuryTheme {
  // Set by ThemeProvider whenever dark mode is toggled.
  //
  // Design: the "paper" elements (spec cards, receipts, gifting cards,
  // input fills — see whitePremium) are meant to read as literal cream
  // stationery, and a lot of text sitting on them is explicitly forced to
  // a fixed dark green/black rather than a theme-aware default. Flipping
  // that paper dark independently of its text broke contrast everywhere.
  // So the paper system (whitePremium/blackJet/grayMuted/warmSand) stays
  // fixed — dark mode instead swaps the page canvas behind it (cream)
  // from light to dark, the same way a dark-mode document editor still
  // shows white pages on a dark surround. Brand accents (emerald/
  // forestGreen/gold) are fixed too, and creamText is the light
  // foreground color for text/icons placed on those fixed-dark surfaces
  // (appbars, hero cards, buttons) — always light, regardless of mode.
  static bool isDark = false;

  // Brand Colors (fixed across both modes)
  static const Color emerald = Color(0xFF0F5B4C);
  static const Color forestGreen = Color(0xFF1E4738);
  static const Color gold = Color(0xFFC9A84C);

  // Page canvas (mode-dependent) vs. fixed light text-on-dark-surface color
  static Color get cream => isDark ? _darkCream : _lightCream;
  static const Color creamText = _lightCream;

  // Paper/card system (fixed — see design note above)
  static const Color warmSand = Color(0xFFD9CDBA);
  static const Color blackJet = Color(0xFF1A1A1A);
  static const Color whitePremium = Color(0xFFFFFFFF);
  static const Color grayMuted = Color(0xFF8E8E93);

  static const Color _lightCream = Color(0xFFF5F0E6);
  // Dark canvas leans into the forest-green brand tone rather than neutral
  // black, so it still reads as "Aurelia" rather than generic dark UI.
  static const Color _darkCream = Color(0xFF11201A);

  // Gradient definitions for elegant overlays
  static const Gradient goldGradient = LinearGradient(
    colors: [Color(0xFFE5C07B), Color(0xFFC9A84C), Color(0xFF9E8131)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF1E4738), Color(0xFF0F5B4C), Color(0xFF0B3A2F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient creamGradient = LinearGradient(
    colors: [Color(0xFFFAFAFA), Color(0xFFF5F0E6), Color(0xFFECE5D7)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Decorative Box Shadows
  static List<BoxShadow> luxuryShadow({double blur = 12, Color? color}) {
    return [
      BoxShadow(
        color: color ?? blackJet.withValues(alpha: 0.06),
        blurRadius: blur,
        offset: const Offset(0, 6),
      ),
    ];
  }

  static List<BoxShadow> goldGlowShadow() {
    return [
      BoxShadow(
        color: gold.withValues(alpha: 0.3),
        blurRadius: 15,
        offset: const Offset(0, 4),
      ),
    ];
  }

  // Typography Settings
  static TextStyle headlineElegant({double size = 28, Color color = forestGreen, bool bold = true}) {
    return GoogleFonts.playfairDisplay(
      fontSize: size,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      color: color,
      height: 1.25,
      letterSpacing: 0.5,
    );
  }

  static TextStyle displayBrand({double size = 32, Color color = gold}) {
    return GoogleFonts.cinzel(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: 3.5,
    );
  }

  static TextStyle bodySerif({double size = 16, Color? color, bool bold = false}) {
    return GoogleFonts.cormorantGaramond(
      fontSize: size,
      fontWeight: bold ? FontWeight.bold : FontWeight.w500,
      color: color ?? blackJet,
      height: 1.4,
    );
  }

  static TextStyle bodySans({double size = 14, Color? color, bool bold = false}) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: bold ? FontWeight.bold : FontWeight.w400,
      color: color ?? blackJet,
      letterSpacing: 0.25,
    );
  }

  static TextStyle buttonText({Color? color}) {
    return GoogleFonts.cinzel(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: color ?? creamText,
      letterSpacing: 2.0,
    );
  }

  // Complete Theme Data for the application
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: cream,
      primaryColor: emerald,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: emerald,
        onPrimary: creamText,
        secondary: gold,
        onSecondary: blackJet,
        error: Colors.redAccent,
        onError: creamText,
        surface: whitePremium,
        onSurface: blackJet,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: forestGreen,
        foregroundColor: gold,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: TextTheme(
        displayLarge: displayBrand(),
        headlineMedium: headlineElegant(),
        bodyMedium: bodySans(),
        bodySmall: bodySans(size: 12, color: grayMuted),
      ),
    );
  }
}
