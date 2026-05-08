import 'dart:convert';

// ─── Flashcard ────────────────────────────────────────────────────────────────
class Flashcard {
  final String id;
  final String question;
  final String answer;

  // SM-2 Spaced Repetition fields
  int repetitions;
  double easeFactor;
  int intervalDays;
  DateTime dueDate;
  int totalReviews;
  int correctReviews;

  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    this.repetitions = 0,
    this.easeFactor = 2.5,
    this.intervalDays = 0,
    DateTime? dueDate,
    this.totalReviews = 0,
    this.correctReviews = 0,
  }) : dueDate = dueDate ?? DateTime.now();

  bool get isDue => DateTime.now().isAfter(dueDate) || DateTime.now().isAtSameMomentAs(dueDate);

  double get accuracy => totalReviews == 0 ? 0 : correctReviews / totalReviews;

  /// SM-2 algorithm: quality 0 = bad, 1 = good
  void review(int quality) {
    totalReviews++;
    if (quality >= 1) {
      correctReviews++;
      if (repetitions == 0) {
        intervalDays = 1;
      } else if (repetitions == 1) {
        intervalDays = 6;
      } else {
        intervalDays = (intervalDays * easeFactor).round();
      }
      easeFactor += 0.1 - (1 - quality) * (0.08 + (1 - quality) * 0.02);
      if (easeFactor < 1.3) easeFactor = 1.3;
      repetitions++;
    } else {
      repetitions = 0;
      intervalDays = 1;
    }
    dueDate = DateTime.now().add(Duration(days: intervalDays));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'repetitions': repetitions,
        'easeFactor': easeFactor,
        'intervalDays': intervalDays,
        'dueDate': dueDate.toIso8601String(),
        'totalReviews': totalReviews,
        'correctReviews': correctReviews,
      };

  void loadProgress(Map<String, dynamic> json) {
    repetitions = json['repetitions'] ?? 0;
    easeFactor = (json['easeFactor'] ?? 2.5).toDouble();
    intervalDays = json['intervalDays'] ?? 0;
    dueDate = json['dueDate'] != null
        ? DateTime.parse(json['dueDate'])
        : DateTime.now();
    totalReviews = json['totalReviews'] ?? 0;
    correctReviews = json['correctReviews'] ?? 0;
  }
}

// ─── Course ───────────────────────────────────────────────────────────────────
class Course {
  final String id;
  final String name;
  final List<Flashcard> cards;

  Course({required this.id, required this.name, required this.cards});

  int get dueCount => cards.where((c) => c.isDue).length;
  int get totalCards => cards.length;

  List<Flashcard> get dueCards => cards.where((c) => c.isDue).toList();

  double get overallAccuracy {
    if (cards.isEmpty) return 0;
    final total = cards.fold(0, (sum, c) => sum + c.totalReviews);
    if (total == 0) return 0;
    final correct = cards.fold(0, (sum, c) => sum + c.correctReviews);
    return correct / total;
  }
}

// ─── Antibiotic Table ─────────────────────────────────────────────────────────
class AntibioticEntry {
  final String disease;
  final String category; // 'bacterial', 'parasitic', 'viral'
  final String agent;
  final String firstLine;
  final String alternative;
  final String duration;
  final String notes;

  const AntibioticEntry({
    required this.disease,
    required this.category,
    required this.agent,
    required this.firstLine,
    required this.alternative,
    required this.duration,
    required this.notes,
  });
}
