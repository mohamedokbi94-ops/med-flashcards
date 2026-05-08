import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';
import '../utils/storage.dart';

class AddCardScreen extends StatefulWidget {
  final List<Course> courses;

  const AddCardScreen({super.key, required this.courses});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _questionCtrl = TextEditingController();
  final _answerCtrl = TextEditingController();
  Course? _selectedCourse;
  bool _saved = false;

  @override
  void dispose() {
    _questionCtrl.dispose();
    _answerCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (_selectedCourse == null) {
      _showSnack('Choisissez un cours');
      return;
    }
    if (_questionCtrl.text.trim().isEmpty) {
      _showSnack('Entrez une question');
      return;
    }
    if (_answerCtrl.text.trim().isEmpty) {
      _showSnack('Entrez une réponse');
      return;
    }

    final newCard = Flashcard(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      question: _questionCtrl.text.trim(),
      answer: _answerCtrl.text.trim(),
    );

    _selectedCourse!.cards.add(newCard);
    await StorageService.saveProgress(widget.courses);

    setState(() => _saved = true);
    _questionCtrl.clear();
    _answerCtrl.clear();
    _showSnack('✅ Carte ajoutée à "${_selectedCourse!.name}"');
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.navy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text('Ajouter une flashcard',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          const Text('Créez vos propres questions de révision',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 24),

          // Course selector
          const Text('Cours', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Course>(
                value: _selectedCourse,
                hint: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Text('Choisir un cours', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                ),
                isExpanded: true,
                borderRadius: BorderRadius.circular(12),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                items: widget.courses.map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c.name, style: const TextStyle(fontSize: 14)),
                )).toList(),
                onChanged: (c) => setState(() => _selectedCourse = c),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Question
          const Text('Question', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          TextField(
            controller: _questionCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Ex: Quel est le traitement de 1ère intention ?',
              hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              filled: true,
              fillColor: AppTheme.bgCard,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.teal, width: 1.5)),
            ),
          ),
          const SizedBox(height: 20),

          // Answer
          const Text('Réponse', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          TextField(
            controller: _answerCtrl,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Ex: Amoxicilline 50 mg/kg/j PO × 7 jours',
              hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              filled: true,
              fillColor: AppTheme.bgCard,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.teal, width: 1.5)),
            ),
          ),
          const SizedBox(height: 30),

          // Save button
          SizedBox(
            width: double.infinity,
            child: Material(
              color: AppTheme.teal,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _save,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('Ajouter la carte',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Preview
          if (_questionCtrl.text.isNotEmpty || _answerCtrl.text.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 12),
            const Text('Aperçu', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
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
                  const Text('Q:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.teal)),
                  const SizedBox(height: 4),
                  Text(_questionCtrl.text, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
                  const Divider(height: 20),
                  const Text('R:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.goodGreen)),
                  const SizedBox(height: 4),
                  Text(_answerCtrl.text, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
