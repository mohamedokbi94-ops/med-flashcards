import 'package:flutter/material.dart';
import 'utils/theme.dart';
import 'utils/data.dart';
import 'utils/storage.dart';
import 'utils/update_service.dart';
import 'models/models.dart';
import 'screens/home_screen.dart';
import 'screens/antibiotic_screen.dart';
import 'screens/add_card_screen.dart';

void main() {
  runApp(const MedFlashcardsApp());
}

class MedFlashcardsApp extends StatelessWidget {
  const MedFlashcardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maladies Infectieuses',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const RootPage(),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _tab = 0;
  late List<Course> _courses;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _courses = buildCourses();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    await StorageService.loadProgress(_courses);
    if (mounted) {
      setState(() => _loaded = true);
      // Check for updates after app loads
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) UpdateService.checkForUpdate(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Maladies Infectieuses',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        backgroundColor: AppTheme.navy,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 22),
            tooltip: 'Réinitialiser la progression',
            onPressed: () => _confirmReset(context),
          ),
        ],
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator(color: AppTheme.teal))
          : IndexedStack(
              index: _tab,
              children: [
                HomeScreen(courses: _courses),
                const AntibioticScreen(),
                AddCardScreen(courses: _courses),
              ],
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: AppTheme.bgCard,
        indicatorColor: AppTheme.tealSurface,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.style_outlined),
            selectedIcon: Icon(Icons.style, color: AppTheme.teal),
            label: 'Flashcards',
          ),
          NavigationDestination(
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication, color: AppTheme.teal),
            label: 'Antibiotiques',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle, color: AppTheme.teal),
            label: 'Ajouter',
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Réinitialiser la progression ?'),
        content: const Text('Toutes vos données de révision seront effacées.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              await StorageService.clearProgress();
              setState(() {
                _courses = buildCourses();
                _loaded = true;
              });
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Réinitialiser',
                style: TextStyle(color: AppTheme.badRed)),
          ),
        ],
      ),
    );
  }
}
