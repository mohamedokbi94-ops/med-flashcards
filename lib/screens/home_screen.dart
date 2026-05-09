import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';
import 'session_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<Course> courses;
  const HomeScreen({super.key, required this.courses});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _search = '';

  final List<List<Color>> _gradients = [
    [Color(0xFF00C9B1), Color(0xFF0098A6)],
    [Color(0xFF7C5CBF), Color(0xFF5B3FA0)],
    [Color(0xFFFF7043), Color(0xFFE64A19)],
    [Color(0xFF2196F3), Color(0xFF1565C0)],
    [Color(0xFF00BFA5), Color(0xFF00796B)],
    [Color(0xFFAB47BC), Color(0xFF7B1FA2)],
    [Color(0xFFFF5722), Color(0xFFBF360C)],
    [Color(0xFF26A69A), Color(0xFF00695C)],
    [Color(0xFF5C6BC0), Color(0xFF283593)],
    [Color(0xFFEC407A), Color(0xFFC2185B)],
    [Color(0xFF42A5F5), Color(0xFF1976D2)],
    [Color(0xFF66BB6A), Color(0xFF388E3C)],
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Course> get _filtered => widget.courses
      .where((c) => c.name.toLowerCase().contains(_search.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    final courses = _filtered;
    final totalDue = widget.courses.fold(0, (sum, c) => sum + c.dueCards.length);

    return Column(
      children: [
        // Header
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.navy, Color(0xFF2D3561)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (totalDue > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.gold.withOpacity(0.4)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.notifications_active, color: AppTheme.gold, size: 14),
                    const SizedBox(width: 6),
                    Text('$totalDue cartes à réviser aujourd\'hui',
                        style: const TextStyle(color: AppTheme.gold, fontSize: 12, fontWeight: FontWeight.w600)),
                  ]),
                ),
              const SizedBox(height: 16),
              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un cours…',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5), size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Grid
        Expanded(
          child: courses.isEmpty
              ? const Center(child: Text('Aucun cours trouvé',
                  style: TextStyle(color: AppTheme.textSecondary)))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: courses.length,
                  itemBuilder: (ctx, i) {
                    final delay = (i * 0.05).clamp(0.0, 1.0);
                    final anim = CurvedAnimation(
                      parent: _controller,
                      curve: Interval(delay, (delay + 0.4).clamp(0.0, 1.0),
                          curve: Curves.easeOutBack),
                    );
                    return AnimatedBuilder(
                      animation: anim,
                      builder: (_, child) => Transform.scale(
                        scale: anim.value,
                        child: Opacity(opacity: anim.value.clamp(0.0, 1.0), child: child),
                      ),
                      child: _CourseCard(
                        course: courses[i],
                        gradient: _gradients[i % _gradients.length],
                        onTap: () => Navigator.push(
                          ctx,
                          MaterialPageRoute(builder: (_) => SessionScreen(
                            course: courses[i],
                            allCourses: widget.courses,
                          )),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _CourseCard extends StatefulWidget {
  final Course course;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _CourseCard({required this.course, required this.gradient, required this.onTap});

  @override
  State<_CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<_CourseCard> with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scaleAnim = Tween(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final due = widget.course.dueCards.length;
    final total = widget.course.cards.length;
    final known = widget.course.cards.where((c) => c.repetitions >= 2).length;
    final progress = total > 0 ? known / total : 0.0;

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (_, child) => Transform.scale(scale: _scaleAnim.value, child: child),
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) { _pressCtrl.reverse(); widget.onTap(); },
        onTapCancel: () => _pressCtrl.reverse(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.gradient[0].withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.menu_book, color: Colors.white, size: 20),
                  ),
                  if (due > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$due',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: widget.gradient[0])),
                    ),
                ]),
                const Spacer(),
                Text(widget.course.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text('$total cartes',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    color: Colors.white,
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
