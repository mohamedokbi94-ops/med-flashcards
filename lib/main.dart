import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'utils/theme.dart';
import 'utils/data.dart';
import 'utils/storage.dart';
import 'utils/update_service.dart';
import 'utils/firebase_service.dart';
import 'models/models.dart';
import 'screens/home_screen.dart';
import 'screens/antibiotic_screen.dart';
import 'screens/add_card_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/stats_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }
  runApp(const MedFlashcardsApp());
}

class MedFlashcardsApp extends StatefulWidget {
  const MedFlashcardsApp({super.key});

  static _MedFlashcardsAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MedFlashcardsAppState>();

  @override
  State<MedFlashcardsApp> createState() => _MedFlashcardsAppState();
}

class _MedFlashcardsAppState extends State<MedFlashcardsApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  bool get isDark => _themeMode == ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maladies Infectieuses',
      theme: AppTheme.theme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(
                child: CircularProgressIndicator(color: AppTheme.teal)));
          }
          return snapshot.hasData ? const RootPage() : const AuthScreen();
        },
      ),
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
    await FirebaseService.loadProgress(_courses);
    await FirebaseService.loadCustomCards(_courses);
    await StorageService.loadProgress(_courses);
    if (mounted) {
      setState(() => _loaded = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) UpdateService.checkForUpdate(context);
      });
    }
  }

  void _confirmReset(BuildContext ctx) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      title: const Text('Réinitialiser la progression ?'),
      content: const Text('Toutes vos données seront effacées.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
        TextButton(
          onPressed: () async {
            await StorageService.clearProgress();
            setState(() { _courses = buildCourses(); _loaded = true; });
            if (ctx.mounted) Navigator.pop(ctx);
          },
          child: const Text('Réinitialiser', style: TextStyle(color: Colors.red)),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final appState = MedFlashcardsApp.of(context);
    final isDark = appState?.isDark ?? false;
    final userName = FirebaseService.currentUser?.displayName ?? '';
    final userEmail = FirebaseService.userEmail ?? '';

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Maladies Infectieuses',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        backgroundColor: AppTheme.navy,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: Colors.white),
            onPressed: () => appState?.toggleTheme(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) async {
              if (value == 'reset') _confirmReset(context);
              if (value == 'logout') await FirebaseService.signOut();
            },
            itemBuilder: (_) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                enabled: false,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(userName.isNotEmpty ? userName : 'Utilisateur',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(userEmail, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ]),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'reset',
                child: Row(children: [
                  Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  SizedBox(width: 10),
                  Text('Réinitialiser', style: TextStyle(color: Colors.red)),
                ]),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(children: [
                  Icon(Icons.logout, size: 18),
                  SizedBox(width: 10),
                  Text('Déconnexion'),
                ]),
              ),
            ],
          ),
        ],
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator(color: AppTheme.teal))
          : IndexedStack(index: _tab, children: [
              HomeScreen(courses: _courses),
              const AntibioticScreen(),
              AddCardScreen(courses: _courses),
              StatsScreen(courses: _courses),
            ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: AppTheme.bgCard,
        indicatorColor: AppTheme.tealSurface,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.style_outlined),
            selectedIcon: Icon(Icons.style, color: AppTheme.teal),
            label: 'Flashcards'),
          NavigationDestination(
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication, color: AppTheme.teal),
            label: 'Antibiotiques'),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle, color: AppTheme.teal),
            label: 'Ajouter'),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: AppTheme.teal),
            label: 'Statistiques'),
        ],
      ),
    );
  }
}
