import 'package:flutter/material.dart';

class AppTheme {
  static const Color navy = Color(0xFF1A1F3C);
  static const Color teal = Color(0xFF00C9B1);
  static const Color tealSurface = Color(0xFFE0FAF7);
  static const Color purple = Color(0xFF7C5CBF);
  static const Color purpleSurface = Color(0xFFF0EBFF);
  static const Color gold = Color(0xFFFFB547);
  static const Color goldLight = Color(0xFFFFF3DC);
  static const Color bg = Color(0xFFF0F4F8);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF1A1F3C);
  static const Color textSecondary = Color(0xFF8896A5);
  static const Color goodGreen = Color(0xFF00C48C);
  static const Color goodGreenSurface = Color(0xFFDFFBF1);
  static const Color badRed = Color(0xFFFF5B5B);
  static const Color badRedSurface = Color(0xFFFFEDED);
  static const Color categoryBact = Color(0xFF2E86AB);
  static const Color categoryBactBg = Color(0xFFE3F4FB);
  static const Color categoryPara = Color(0xFF8B5E3C);
  static const Color categoryParaBg = Color(0xFFF5EDE4);
  static const Color categoryViral = Color(0xFF6B4FA0);
  static const Color categoryViralBg = Color(0xFFF0EBF8);

  static final ThemeData theme = ThemeData(
    fontFamily: 'SF Pro Display',
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.light(
      primary: teal,
      secondary: purple,
      surface: bgCard,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: bgCard,
      indicatorColor: tealSurface,
      elevation: 8,
      shadowColor: Colors.black12,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: navy,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: bgCard,
    ),
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFF0D1117),
    colorScheme: ColorScheme.dark(
      primary: teal,
      secondary: purple,
      surface: const Color(0xFF161B22),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF161B22),
      indicatorColor: teal.withOpacity(0.15),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF161B22),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    useMaterial3: true,
  );
}
