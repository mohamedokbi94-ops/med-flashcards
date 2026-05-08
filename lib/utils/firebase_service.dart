import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class FirebaseService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;
  static bool get isLoggedIn => currentUser != null;
  static String? get userId => currentUser?.uid;
  static String? get userEmail => currentUser?.email;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<String?> signUp(String email, String password, String name) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);
      await cred.user?.updateDisplayName(name);
      await _db.collection('users').doc(cred.user!.uid).set({
        'name': name,
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return null;
    } on FirebaseAuthException catch (e) {
      return _authError(e.code);
    }
  }

  static Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _authError(e.code);
    }
  }

  static Future<void> signOut() async => await _auth.signOut();

  static Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _authError(e.code);
    }
  }

  static String _authError(String code) {
    switch (code) {
      case 'email-already-in-use': return 'Email déjà utilisé';
      case 'invalid-email': return 'Email invalide';
      case 'weak-password': return 'Mot de passe trop court (min 6 caractères)';
      case 'user-not-found': return 'Aucun compte avec cet email';
      case 'wrong-password': return 'Mot de passe incorrect';
      case 'too-many-requests': return 'Trop de tentatives, réessayez plus tard';
      default: return 'Erreur : $code';
    }
  }

  static Future<void> saveProgress(List<Course> courses) async {
    if (!isLoggedIn) return;
    final Map<String, dynamic> data = {};
    for (final course in courses) {
      data[course.id] = {
        for (final card in course.cards) card.id: card.toJson()
      };
    }
    await _db.collection('progress').doc(userId).set(data);
  }

  static Future<void> loadProgress(List<Course> courses) async {
    if (!isLoggedIn) return;
    try {
      final doc = await _db.collection('progress').doc(userId).get();
      if (!doc.exists) return;
      final data = doc.data()!;
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

  static Future<void> saveCustomCards(List<Course> courses) async {
    if (!isLoggedIn) return;
    final Map<String, dynamic> customCards = {};
    for (final course in courses) {
      final custom = course.cards
          .where((c) => c.id.startsWith('custom_'))
          .map((c) => {'id': c.id, 'question': c.question, 'answer': c.answer})
          .toList();
      if (custom.isNotEmpty) customCards[course.id] = custom;
    }
    await _db.collection('custom_cards').doc(userId).set(customCards);
  }

  static Future<void> loadCustomCards(List<Course> courses) async {
    if (!isLoggedIn) return;
    try {
      final doc = await _db.collection('custom_cards').doc(userId).get();
      if (!doc.exists) return;
      final data = doc.data()!;
      for (final course in courses) {
        final cards = data[course.id] as List?;
        if (cards != null) {
          for (final c in cards) {
            final exists = course.cards.any((card) => card.id == c['id']);
            if (!exists) {
              course.cards.add(Flashcard(
                id: c['id'],
                question: c['question'],
                answer: c['answer'],
              ));
            }
          }
        }
      }
    } catch (_) {}
  }
}
