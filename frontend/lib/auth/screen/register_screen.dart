import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/presensi/repository/presensi_repository.dart';
import '../../core/config/api_config.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_service.dart';
import 'dashboard/dashboard_screen.dart';
import 'login_style.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.repository, this.onAuthenticated});

  static const routeName = '/register';
  final PresensiRepository repository;
  final VoidCallback? onAuthenticated;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _universityController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  String _role = 'peserta';
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _universityController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final university = _universityController.text.trim();
    final password = _passwordController.text;
    final confirmation = _confirmController.text;
    if (name.isEmpty || email.isEmpty || university.isEmpty || password.isEmpty) {
      setState(() => _errorText = 'Lengkapi semua data pendaftaran.');
      return;
    }
    if (password != confirmation) {
      setState(() => _errorText = 'Konfirmasi password tidak sama.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorText = null;
    });
    try {
      final repository = AuthRepository(
        service: AuthService(baseUrl: ApiConfig.baseUrl),
        prefs: await SharedPreferences.getInstance(),
      );
      final result = await repository.register(
        name: name,
        email: email,
        university: university,
        role: _role,
        password: password,
        passwordConfirmation: confirmation,
      );
      await repository.persistToken(result.token);
      if (!mounted) return;
      if (widget.onAuthenticated != null) {
        widget.onAuthenticated!();
      } else {
        Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
      }
    } catch (error) {
      if (mounted) setState(() => _errorText = error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _decoration({required IconData icon, Widget? suffix, String? hintText}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: LoginStyle.inputBorder),
    );
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 14),
      prefixIcon: Container(
        width: 44,
        height: 44,
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(color: LoginStyle.background),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [LoginStyle.cardShadow],
        ),
        child: Icon(icon, size: 19, color: LoginStyle.muted),
      ),
      suffixIcon: suffix,
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFFB0B7C3), fontWeight: FontWeight.w400),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(borderSide: const BorderSide(color: LoginStyle.primary, width: 1.4)),
    );
  }

  Widget _field(String label, TextEditingController controller, IconData icon, {bool password = false, bool confirmation = false, TextInputType? keyboardType, String? hintText, String? helpText}) {
    final obscure = confirmation ? _obscureConfirmation : _obscurePassword;
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        if (helpText != null) Text(helpText, style: const TextStyle(fontSize: 11, color: LoginStyle.muted)),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          obscureText: password && obscure,
          keyboardType: keyboardType,
          decoration: _decoration(
            icon: icon,
            hintText: hintText,
            suffix: password ? IconButton(
              icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: () => setState(() {
                if (confirmation) {
                  _obscureConfirmation = !_obscureConfirmation;
                } else {
                  _obscurePassword = !_obscurePassword;
                }
              }),
            ) : null,
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginStyle.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 28),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: const [LoginStyle.cardShadow]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Image.asset('lib/auth/screen/asset/logo.png', height: 68, fit: BoxFit.contain),
                  const SizedBox(height: 12),
                  const Text('Daftar Akun Baru', textAlign: TextAlign.center, style: TextStyle(color: LoginStyle.primary, fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  const Text('Lengkapi data untuk membuat akun Ruwa Magang', textAlign: TextAlign.center, style: TextStyle(color: LoginStyle.muted, fontSize: 14)),
                  _field('Nama Lengkap', _nameController, Icons.person_outline, hintText: 'Contoh: John Doe'),
                  _field('Email', _emailController, Icons.email_outlined, keyboardType: TextInputType.emailAddress, hintText: 'jhon@gmail.com'),
                  _field('Password', _passwordController, Icons.lock_outline, password: true, hintText: 'Buat password', helpText: '* Minimal 8 karakter dengan kombinasi huruf dan angka'),
                  _field('Confirm Password', _confirmController, Icons.lock_outline, password: true, confirmation: true, hintText: 'Ulangi password'),
                  _field('Universitas / Sekolah', _universityController, Icons.business_outlined),
                  const SizedBox(height: 18),
                  const Text('Daftar sebagai', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: _roleButton('peserta', 'Peserta Magang', Icons.school_outlined)),
                    const SizedBox(width: 10),
                    Expanded(child: _roleButton('pembimbing_external', 'Pembimbing External', Icons.schedule_outlined)),
                  ]),
                  if (_role == 'pembimbing_external') const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('Pembimbing external dapat memantau peserta dari universitas yang sama.', style: TextStyle(color: LoginStyle.muted, fontSize: 12)),
                  ),
                  if (_errorText != null) Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_errorText!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(height: 50, child: DecoratedBox(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: const LinearGradient(colors: [LoginStyle.primary, LoginStyle.primaryLight])),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onRegister,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, disabledBackgroundColor: Colors.transparent, foregroundColor: Colors.white, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(_role == 'peserta' ? 'Daftar sebagai Peserta' : 'Daftar sebagai Pembimbing External', style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  )),
                  const SizedBox(height: 12),
                  Center(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text.rich(TextSpan(text: 'Sudah punya akun? ', style: TextStyle(color: LoginStyle.muted), children: [TextSpan(text: 'Login', style: TextStyle(color: LoginStyle.primary, fontWeight: FontWeight.w600))])))),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleButton(String value, String label, IconData icon) {
    final selected = _role == value;
    return OutlinedButton.icon(
      onPressed: () => setState(() => _role = value),
      icon: Icon(icon, size: 18),
      label: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        foregroundColor: selected ? Colors.white : LoginStyle.primary,
        backgroundColor: selected ? LoginStyle.primary : Colors.white,
        side: const BorderSide(color: LoginStyle.primary),
        minimumSize: const Size.fromHeight(50),
        padding: const EdgeInsets.symmetric(horizontal: 6),
      ),
    );
  }
}
