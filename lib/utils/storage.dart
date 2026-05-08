import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static const _key = 'card_progress_v1';

  static Future<void> saveProgress(List<Course> courses) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> data = {};
    for (final course in courses) {
      data[course.id] = {
        for (final card in course.cards) card.id: card.toJson()
      };
    }
    await prefs.setString(_key, jsonEncode(data));
  }

  static Future<void> loadProgress(List<Course> courses) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final Map<String, dynamic> data = jsonDecode(raw);
      for (final course in courses) {
        final courseData = data[course.id];
        if (courseData is Map<String, dynamic>) {
          for (final card in course.cards) {
            final cardData = courseData[card.id];
            if (cardData is Map<String, dynamic>) {
              card.loadProgress(cardData);
            }
          }
        }
      }
    } catch (_) {}
  }

  static Future<void> clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
