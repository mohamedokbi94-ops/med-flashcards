import 'package:flutter/material.dart';

class AppTheme {
  static const Color navy = Color(0xFF0F2344);
  static const Color teal = Color(0xFF1A6B8A);
  static const Color tealLight = Color(0xFF2A8AAD);
  static const Color tealSurface = Color(0xFFE8F4F9);
  static const Color gold = Color(0xFFC9A84C);
  static const Color goldLight = Color(0xFFE8C87A);
  static const Color bg = Color(0xFFF7F4EE);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF5A6070);
  static const Color border = Color(0xFFDDD8CC);
  static const Color goodGreen = Color(0xFF2E7D32);
  static const Color goodGreenSurface = Color(0xFFE8F5E9);
  static const Color badRed = Color(0xFFC62828);
  static const Color badRedSurface = Color(0xFFFFEBEE);
  static const Color categoryBact = Color(0xFF1A3A80);
  static const Color categoryBactBg = Color(0xFFDCE9FF);
  static const Color categoryPara = Color(0xFF1A5A1A);
  static const Color categoryParaBg = Color(0xFFE0F5E0);
  static const Color categoryViral = Color(0xFF6A1A6A);
  static const Color categoryViralBg = Color(0xFFF5E0F5);

  static ThemeData get theme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: teal,
          background: bg,
        ),
        scaffoldBackgroundColor: bg,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: Colors.white,
          unselectedLabelColor: Color(0xAAFFFFFF),
          indicatorColor: goldLight,
        ),
        useMaterial3: true,
      );
}
