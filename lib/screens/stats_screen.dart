import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';

class StatsScreen extends StatelessWidget {
  final List<Course> courses;
  const StatsScreen({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    int totalCards = 0;
    int totalReviewed = 0;
    int totalKnown = 0;
    int dueToday = 0;

    for (final course in courses) {
      totalCards += course.cards.length;
      for (final card in course.cards) {
        if (card.totalReviews > 0) totalReviewed++;
        if (card.repetitions >= 2) totalKnown++;
        if (card.dueDate.isBefore(DateTime.now().add(const Duration(days: 1)))) {
          dueToday++;
        }
      }
    }

    final pct = totalCards > 0 ? (totalKnown / totalCards * 100).round() : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text('Statistiques',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Vue d\'ensemble de ta progression',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 24),

          // Main stats
          Row(children: [
            _statCard('$totalCards', 'Cartes totales', Icons.style, AppTheme.teal, AppTheme.tealSurface),
            const SizedBox(width: 12),
            _statCard('$totalReviewed', 'Révisées', Icons.check_circle_outline, AppTheme.goodGreen, AppTheme.goodGreenSurface),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _statCard('$totalKnown', 'Maîtrisées', Icons.star_outline, AppTheme.gold, const Color(0xFFFEF6E0)),
            const SizedBox(width: 12),
            _statCard('$dueToday', 'À réviser', Icons.schedule, AppTheme.badRed, AppTheme.badRedSurface),
          ]),
          const SizedBox(height: 24),

          // Progress bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Progression globale',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  Text('$pct%',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.teal)),
                ]),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: totalCards > 0 ? totalKnown / totalCards : 0,
                    backgroundColor: AppTheme.border,
                    color: AppTheme.teal,
                    minHeight: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Per course
          const Text('Par cours',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...courses.map((course) {
            final known = course.cards.where((c) => c.repetitions >= 2).length;
            final total = course.cards.length;
            final p = total > 0 ? known / total : 0.0;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(child: Text(course.name,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis)),
                    Text('$known/$total',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ]),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: p,
                      backgroundColor: AppTheme.border,
                      color: p == 1.0 ? AppTheme.goodGreen : AppTheme.teal,
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}
