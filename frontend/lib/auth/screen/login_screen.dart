import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/presensi/repository/presensi_repository.dart';
import '../../core/config/api_config.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_service.dart';
import 'dashboard/dashboard_screen.dart';
import 'forgot_password_screen.dart';
import 'login_style.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.repository, this.onAuthenticated});

  static const routeName = '/login';
  final PresensiRepository repository;
  final void Function(String token)? onAuthenticated;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorText = 'Email dan password wajib diisi.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final baseUrl = ApiConfig.baseUrl;
      debugPrint('[LoginScreen] POST $baseUrl/login');

      final repository = AuthRepository(
        service: AuthService(baseUrl: baseUrl),
        prefs: await SharedPreferences.getInstance(),
      );

      final result = await repository.login(email: email, password: password);
      await repository.persistToken(result.token);

      debugPrint('[LoginScreen] Token persisted: ${result.token.substring(0, result.token.length.clamp(0, 20))}...');

      if (!mounted) return;
      if (widget.onAuthenticated != null) {
        widget.onAuthenticated!(result.token);
      } else {
        Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
      }
    } catch (error) {
      debugPrint('[LoginScreen] Login error: $error');
      if (mounted) setState(() => _errorText = error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration({
    required IconData icon,
    required String hint,
    Widget? suffix,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: LoginStyle.inputBorder),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: LoginStyle.muted),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
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
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: LoginStyle.primary, width: 1.4),
      ),
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
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 34),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [LoginStyle.cardShadow],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset('lib/auth/screen/asset/logo.png', height: 68, fit: BoxFit.contain),
                    const SizedBox(height: 26),
                    const Text('Username / Email', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 7),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration(icon: Icons.person_outline, hint: 'Masukkan username'),
                    ),
                    const SizedBox(height: 18),
                    const Text('Password', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 7),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: _inputDecoration(
                        icon: Icons.lock_outline,
                        hint: '',
                        suffix: IconButton(
                          tooltip: _obscurePassword ? 'Tampilkan password' : 'Sembunyikan password',
                          icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    if (_errorText != null) ...[
                      const SizedBox(height: 10),
                      Text(_errorText!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                    ],
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          activeColor: LoginStyle.primary,
                          onChanged: (value) => setState(() => _rememberMe = value ?? false),
                        ),
                        const Text('Ingat saya', style: TextStyle(fontSize: 13)),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                          ),
                          child: const Text('Lupa Password?', style: TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 50,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(colors: [LoginStyle.primary, LoginStyle.primaryLight]),
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _onLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            disabledBackgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Masuk ke Sistem', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(context, RegisterScreen.routeName),
                        child: const Text.rich(TextSpan(
                          text: 'Belum punya akun? ',
                          style: TextStyle(color: LoginStyle.muted, fontSize: 14),
                          children: [TextSpan(text: 'Registrasi Mandiri', style: TextStyle(color: LoginStyle.primary, fontWeight: FontWeight.w600))],
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
