import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';
import 'session_screen.dart';

class HomeScreen extends StatelessWidget {
  final List<Course> courses;

  const HomeScreen({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Choisissez un cours',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Appuyez sur un cours pour commencer la révision',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.3,
            ),
            itemCount: courses.length,
            itemBuilder: (ctx, i) => _CourseCard(
              course: courses[i],
              allCourses: courses,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;
  final List<Course> allCourses;

  const _CourseCard({required this.course, required this.allCourses});

  @override
  Widget build(BuildContext context) {
    final due = course.dueCount;
    final accuracy = course.overallAccuracy;
    final hasProgress = course.cards.any((c) => c.totalReviews > 0);

    return Material(
      color: AppTheme.bgCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SessionScreen(
              course: course,
              allCourses: allCourses,
            ),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: due > 0 ? AppTheme.teal.withOpacity(0.4) : AppTheme.border,
              width: due > 0 ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (due > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAEEDA),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('$due à réviser',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF854F0B))),
                ),
              Expanded(
                child: Text(
                  course.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${course.totalCards} cartes',
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary)),
                  if (hasProgress)
                    Text('${(accuracy * 100).round()}%',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: accuracy >= 0.7
                                ? AppTheme.goodGreen
                                : AppTheme.badRed)),
                ],
              ),
              if (hasProgress) ...[
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: accuracy,
                    backgroundColor: AppTheme.border,
                    color: accuracy >= 0.7 ? AppTheme.goodGreen : AppTheme.teal,
                    minHeight: 3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
