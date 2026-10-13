import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum RetroPaletteType {
  arcade,
  cyberpunk,
  gameboy,
}

class RetroThemePalette {
  final String name;
  final Color background;
  final Color surface;
  final Color surfaceLight;
  final Color boardBackground;
  final Color boardHole;
  final Color player1;
  final Color player2;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color winGlow;

  const RetroThemePalette({
    required this.name,
    required this.background,
    required this.surface,
    required this.surfaceLight,
    required this.boardBackground,
    required this.boardHole,
    required this.player1,
    required this.player2,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.winGlow,
  });

  static const RetroThemePalette arcade = RetroThemePalette(
    name: 'CLASSIC ARCADE',
    background: Color(0xFF0C0D14),
    surface: Color(0xFF16192B),
    surfaceLight: Color(0xFF232845),
    boardBackground: Color(0xFF1044A5),
    boardHole: Color(0xFF080B18),
    player1: Color(0xFFFF2A55),
    player2: Color(0xFFFFD214),
    accent: Color(0xFF00E5FF),
    textPrimary: Color(0xFFF4F6FF),
    textSecondary: Color(0xFF8A93BA),
    border: Color(0xFF00E5FF),
    winGlow: Color(0xFF39FF14),
  );

  static const RetroThemePalette cyberpunk = RetroThemePalette(
    name: 'CYBERPUNK NEON',
    background: Color(0xFF0D0221),
    surface: Color(0xFF1B0B3B),
    surfaceLight: Color(0xFF2C135E),
    boardBackground: Color(0xFF541388),
    boardHole: Color(0xFF0D0221),
    player1: Color(0xFFFF007F),
    player2: Color(0xFF00F0FF),
    accent: Color(0xFFFFE600),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFA58BC7),
    border: Color(0xFFFF007F),
    winGlow: Color(0xFFFFE600),
  );

  static const RetroThemePalette gameboy = RetroThemePalette(
    name: 'GAME BOY 8-BIT',
    background: Color(0xFF0F380F),
    surface: Color(0xFF1B4D1B),
    surfaceLight: Color(0xFF306230),
    boardBackground: Color(0xFF306230),
    boardHole: Color(0xFF0F380F),
    player1: Color(0xFF8BAC0F),
    player2: Color(0xFF9BBC0F),
    accent: Color(0xFF8BAC0F),
    textPrimary: Color(0xFF9BBC0F),
    textSecondary: Color(0xFF8BAC0F),
    border: Color(0xFF8BAC0F),
    winGlow: Color(0xFFE0F8D0),
  );

  static RetroThemePalette fromType(RetroPaletteType type) {
    switch (type) {
      case RetroPaletteType.arcade:
        return arcade;
      case RetroPaletteType.cyberpunk:
        return cyberpunk;
      case RetroPaletteType.gameboy:
        return gameboy;
    }
  }
}

class RetroTypography {
  static TextStyle pixel({
    double fontSize = 12,
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.normal,
    double? letterSpacing = 1.0,
    double? height,
  }) =>
      GoogleFonts.pressStart2p(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
      );

  static TextStyle readout({
    double fontSize = 18,
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.bold,
    double? letterSpacing = 1.5,
  }) =>
      GoogleFonts.vt323(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
      );
}
