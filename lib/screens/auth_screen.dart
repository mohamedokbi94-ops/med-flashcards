import 'package:flutter/material.dart';
import '../utils/firebase_service.dart';
import '../utils/theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _loading = false;

  final _signInEmail = TextEditingController();
  final _signInPassword = TextEditingController();
  final _signUpName = TextEditingController();
  final _signUpEmail = TextEditingController();
  final _signUpPassword = TextEditingController();
  final _signUpConfirm = TextEditingController();
  bool _signInPwVisible = false;
  bool _signUpPwVisible = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _signInEmail.dispose(); _signInPassword.dispose();
    _signUpName.dispose(); _signUpEmail.dispose();
    _signUpPassword.dispose(); _signUpConfirm.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool error = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppTheme.badRed : AppTheme.goodGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Future<void> _signIn() async {
    if (_signInEmail.text.isEmpty || _signInPassword.text.isEmpty) {
      _snack('Remplissez tous les champs'); return;
    }
    setState(() => _loading = true);
    final err = await FirebaseService.signIn(_signInEmail.text, _signInPassword.text);
    setState(() => _loading = false);
    if (err != null) _snack(err);
  }

  Future<void> _signUp() async {
    if (_signUpName.text.isEmpty || _signUpEmail.text.isEmpty || _signUpPassword.text.isEmpty) {
      _snack('Remplissez tous les champs'); return;
    }
    if (_signUpPassword.text != _signUpConfirm.text) {
      _snack('Les mots de passe ne correspondent pas'); return;
    }
    setState(() => _loading = true);
    final err = await FirebaseService.signUp(_signUpEmail.text, _signUpPassword.text, _signUpName.text);
    setState(() => _loading = false);
    if (err != null) _snack(err);
    else _snack('Compte créé !', error: false);
  }

  Future<void> _resetPw() async {
    if (_signInEmail.text.isEmpty) { _snack('Entrez votre email'); return; }
    final err = await FirebaseService.resetPassword(_signInEmail.text);
    if (err != null) _snack(err);
    else _snack('Email envoyé !', error: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const SizedBox(height: 40),
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: AppTheme.navy, borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.medical_information, color: Colors.white, size: 44),
            ),
            const SizedBox(height: 16),
            const Text('Maladies Infectieuses',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.navy)),
            const SizedBox(height: 6),
            const Text('Connectez-vous pour sauvegarder votre progression',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(12)),
              child: TabBar(
                controller: _tabCtrl,
                indicator: BoxDecoration(color: AppTheme.navy, borderRadius: BorderRadius.circular(10)),
                labelColor: Colors.white,
                unselectedLabelColor: AppTheme.textSecondary,
                dividerColor: Colors.transparent,
                tabs: const [Tab(text: 'Connexion'), Tab(text: 'Inscription')],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 420,
              child: TabBarView(
                controller: _tabCtrl,
                children: [_buildSignIn(), _buildSignUp()],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildSignIn() => Column(children: [
    _field('Email', _signInEmail, Icons.email_outlined, keyboardType: TextInputType.emailAddress),
    const SizedBox(height: 14),
    _field('Mot de passe', _signInPassword, Icons.lock_outline,
        isPassword: true, isVisible: _signInPwVisible,
        onToggle: () => setState(() => _signInPwVisible = !_signInPwVisible)),
    Align(
      alignment: Alignment.centerRight,
      child: TextButton(onPressed: _resetPw,
          child: const Text('Mot de passe oublié ?',
              style: TextStyle(fontSize: 12, color: AppTheme.teal))),
    ),
    const SizedBox(height: 8),
    _submitBtn('Se connecter', _signIn),
  ]);

  Widget _buildSignUp() => Column(children: [
    _field('Nom complet', _signUpName, Icons.person_outline),
    const SizedBox(height: 12),
    _field('Email', _signUpEmail, Icons.email_outlined, keyboardType: TextInputType.emailAddress),
    const SizedBox(height: 12),
    _field('Mot de passe', _signUpPassword, Icons.lock_outline,
        isPassword: true, isVisible: _signUpPwVisible,
        onToggle: () => setState(() => _signUpPwVisible = !_signUpPwVisible)),
    const SizedBox(height: 12),
    _field('Confirmer', _signUpConfirm, Icons.lock_outline, isPassword: true, isVisible: _signUpPwVisible),
    const SizedBox(height: 20),
    _submitBtn('Créer un compte', _signUp),
  ]);

  Widget _field(String label, TextEditingController ctrl, IconData icon,
      {bool isPassword = false, bool isVisible = false,
      VoidCallback? onToggle, TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      obscureText: isPassword && !isVisible,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: AppTheme.textSecondary),
        suffixIcon: isPassword && onToggle != null
            ? IconButton(
                icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility,
                    size: 20, color: AppTheme.textSecondary),
                onPressed: onToggle)
            : null,
        filled: true, fillColor: AppTheme.bgCard,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.teal, width: 1.5)),
      ),
    );
  }

  Widget _submitBtn(String label, VoidCallback onTap) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.navy, foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: _loading ? null : onTap,
      child: _loading
          ? const SizedBox(width: 20, height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
    ),
  );
}
