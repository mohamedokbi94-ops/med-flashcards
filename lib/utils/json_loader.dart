import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/models.dart';

class JsonLoader {

  static Future<List<Course>> loadCourses() async {

    final raw =
        await rootBundle.loadString('assets/flashcards.json');

    final data = json.decode(raw);

    List<Course> courses = [];

    for (final c in data['cours']) {

      List<Flashcard> cards = [];

      for (final f in c['flashcards']) {

        cards.add(
          Flashcard(
            id: DateTime.now()
                .microsecondsSinceEpoch
                .toString(),

            question: f['q'],
            answer: f['r'],
          ),
        );
      }

      courses.add(
        Course(
          id: c['id'].toString(),
          title: c['titre'],
          cards: cards,
        ),
      );
    }

    return courses;
  }
}