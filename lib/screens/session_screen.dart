import 'dart:math';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';
import '../utils/storage.dart';

class SessionScreen extends StatefulWidget {
  final Course course;
  final List<Course> allCourses;

  const SessionScreen({
    super.key,
    required this.course,
    required this.allCourses,
  });

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen>
    with SingleTickerProviderStateMixin {
  late List<Flashcard> _queue;
  int _idx = 0;
  bool _isFlipped = false;
  bool _sessionDone = false;
  int _good = 0;
  int _bad = 0;

  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut),
    );
    _buildQueue();
  }

  void _buildQueue() {
    final due = widget.course.dueCards;
    final cards = due.isNotEmpty ? due : List.of(widget.course.cards);
    cards.shuffle(Random());
    setState(() {
      _queue = cards;
      _idx = 0;
      _good = 0;
      _bad = 0;
      _isFlipped = false;
      _sessionDone = false;
    });
    _flipCtrl.reset();
  }

  void _flip() {
    if (_isFlipped) return;
    setState(() => _isFlipped = true);
    _flipCtrl.forward();
  }

  void _evaluate(int quality) async {
    final card = _queue[_idx];
    card.review(quality);
    if (quality == 1) {
      setState(() => _good++);
    } else {
      setState(() => _bad++);
    }
    await StorageService.saveProgress(widget.allCourses);

    if (_idx + 1 >= _queue.length) {
      setState(() => _sessionDone = true);
    } else {
      _flipCtrl.reset();
      setState(() {
        _idx++;
        _isFlipped = false;
      });
    }
  }

  void _restartHard() {
    // Rebuild queue with only failed cards
    final hard = widget.course.cards
        .where((c) => c.repetitions == 0 && c.totalReviews > 0)
        .toList();
    final cards = hard.isNotEmpty ? hard : List.of(widget.course.cards);
    cards.shuffle(Random());
    setState(() {
      _queue = cards;
      _idx = 0;
      _good = 0;
      _bad = 0;
      _isFlipped = false;
      _sessionDone = false;
    });
    _flipCtrl.reset();
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(widget.course.name,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        backgroundColor: AppTheme.navy,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _sessionDone ? _buildDoneView() : _buildCardView(),
    );
  }

  Widget _buildCardView() {
    if (_queue.isEmpty) {
      return const Center(child: Text('Aucune carte à réviser.'));
    }
    final card = _queue[_idx];
    final total = _queue.length;
    final progress = (_idx + 1) / total;

    return Column(
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_idx + 1} / $total',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary)),
                  Row(
                    children: [
                      const Icon(Icons.check, size: 14, color: AppTheme.goodGreen),
                      Text(' $_good',
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.goodGreen)),
                      const SizedBox(width: 10),
                      const Icon(Icons.close, size: 14, color: AppTheme.badRed),
                      Text(' $_bad',
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.badRed)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppTheme.border,
                  color: AppTheme.teal,
                  minHeight: 5,
                ),
              ),
            ],
          ),
        ),

        // Card flip area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: GestureDetector(
              onTap: _flip,
              child: AnimatedBuilder(
                animation: _flipAnim,
                builder: (_, __) {
                  final angle = _flipAnim.value * pi;
                  final showBack = angle > pi / 2;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(angle),
                    child: showBack
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(pi),
                            child: _buildBackFace(card),
                          )
                        : _buildFrontFace(card, widget.course.name),
                  );
                },
              ),
            ),
          ),
        ),

        // Eval buttons (shown after flip)
        AnimatedOpacity(
          opacity: _isFlipped ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: !_isFlipped,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Row(
                children: [
                  Expanded(child: _evalBtn(0, '✗  Je ne savais pas', AppTheme.badRed, AppTheme.badRedSurface)),
                  const SizedBox(width: 10),
                  Expanded(child: _evalBtn(1, '✓  Je savais', AppTheme.goodGreen, AppTheme.goodGreenSurface)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFrontFace(Flashcard card, String courseName) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.tealSurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(courseName,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.teal,
                      letterSpacing: 0.5)),
            ),
            const SizedBox(height: 24),
            Text(
              card.question,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app_outlined, size: 16, color: AppTheme.textSecondary),
                SizedBox(width: 6),
                Text('Appuyer pour voir la réponse',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackFace(Flashcard card) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.teal.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.teal.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.tealSurface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('RÉPONSE',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.teal,
                          letterSpacing: 1.2)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  card.answer,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                    height: 1.65,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _evalBtn(int quality, String label, Color textColor, Color bgColor) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _evaluate(quality),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: textColor.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor)),
          ),
        ),
      ),
    );
  }

  Widget _buildDoneView() {
    final total = _queue.length;
    final pct = total > 0 ? ((_good / total) * 100).round() : 0;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final dueCount = widget.course.cards
        .where((c) => c.dueDate.isAfter(DateTime.now()) && c.dueDate.isBefore(tomorrow))
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.teal.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                const Text('Session terminée !',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 6),
                Text('Score : $pct% de bonnes réponses sur $total cartes',
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _statBox('$_good', 'Connu', AppTheme.goodGreen, AppTheme.goodGreenSurface),
              const SizedBox(width: 12),
              _statBox('$_bad', 'À revoir', AppTheme.badRed, AppTheme.badRedSurface),
              const SizedBox(width: 12),
              _statBox('$dueCount', 'Demain', AppTheme.teal, AppTheme.tealSurface),
            ],
          ),
          const SizedBox(height: 30),
          _actionBtn(
            label: 'Recommencer les cartes difficiles',
            icon: Icons.refresh,
            onTap: _restartHard,
            primary: false,
          ),
          const SizedBox(height: 12),
          _actionBtn(
            label: 'Nouvelle session complète',
            icon: Icons.play_arrow,
            onTap: _buildQueue,
            primary: true,
          ),
          const SizedBox(height: 12),
          _actionBtn(
            label: 'Retour aux cours',
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
            primary: false,
          ),
        ],
      ),
    );
  }

  Widget _statBox(String value, String label, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: color)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool primary,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: primary ? AppTheme.teal : AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: primary ? AppTheme.teal : AppTheme.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 18,
                    color: primary ? Colors.white : AppTheme.textPrimary),
                const SizedBox(width: 8),
                Text(label,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primary ? Colors.white : AppTheme.textPrimary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
