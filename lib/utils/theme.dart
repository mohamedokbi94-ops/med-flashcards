import 'package:flutter/material.dart';

class AppTheme {
  static const Color navy = Color(0xFF1A2B4A);
  static const Color teal = Color(0xFF2BB5A0);
  static const Color tealSurface = Color(0xFFE6F7F5);
  static const Color gold = Color(0xFFF5A623);
  static const Color goldLight = Color(0xFFFEF6E0);
  static const Color bg = Color(0xFFF4F6F9);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE8ECF0);
  static const Color textPrimary = Color(0xFF1A2B4A);
  static const Color textSecondary = Color(0xFF6B7C93);
  static const Color goodGreen = Color(0xFF27AE60);
  static const Color goodGreenSurface = Color(0xFFE8F8EE);
  static const Color badRed = Color(0xFFE74C3C);
  static const Color badRedSurface = Color(0xFFFDECEA);
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
      secondary: teal,
      surface: bgCard,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: bgCard,
      indicatorColor: tealSurface,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: navy,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: Colors.white,
      unselectedLabelColor: Color(0xAAFFFFFF),
      indicatorColor: goldLight,
    ),
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFF0F1117),
    colorScheme: ColorScheme.dark(
      primary: teal,
      secondary: teal,
      surface: const Color(0xFF1C1F2E),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF1C1F2E),
      indicatorColor: teal.withOpacity(0.2),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: navy,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    useMaterial3: true,
  );
}
