import 'package:flutter/material.dart';

import '../../core/config/api_config.dart';
import '../services/auth_service.dart';
import 'login_style.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Langkah 1: kirim OTP — Langkah 2: verifikasi OTP + reset password
  bool _otpSent = false;
  bool _isLoading = false;
  String? _errorText;
  String? _successText;

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorText = 'Email wajib diisi.');
      return;
    }
    setState(() { _isLoading = true; _errorText = null; _successText = null; });
    try {
      await AuthService(baseUrl: ApiConfig.baseUrl).sendOtp(email: email);
      setState(() {
        _otpSent = true;
        _successText = 'Kode OTP telah dikirim ke $email. Periksa inbox atau folder spam.';
      });
    } catch (e) {
      setState(() => _errorText = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final otp = _otpController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (otp.length != 6) {
      setState(() => _errorText = 'Kode OTP harus 6 digit.');
      return;
    }
    if (password.length < 8) {
      setState(() => _errorText = 'Password minimal 8 karakter.');
      return;
    }
    if (password != confirm) {
      setState(() => _errorText = 'Konfirmasi password tidak sama.');
      return;
    }

    setState(() { _isLoading = true; _errorText = null; _successText = null; });
    try {
      await AuthService(baseUrl: ApiConfig.baseUrl).resetPassword(
        email: _emailController.text.trim(),
        otp: otp,
        password: password,
        passwordConfirmation: confirm,
      );
      if (!mounted) return;
      // Kembali ke login dengan pesan sukses
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil direset. Silakan masuk dengan password baru.')),
      );
    } catch (e) {
      setState(() => _errorText = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _decoration({required IconData icon, required String hint, Widget? suffix}) {
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
        width: 44, height: 44,
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
      focusedBorder: border.copyWith(borderSide: const BorderSide(color: LoginStyle.primary, width: 1.4)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginStyle.background,
      appBar: AppBar(
        backgroundColor: LoginStyle.background,
        elevation: 0,
        leading: const BackButton(color: LoginStyle.primary),
        title: const Text('Lupa Password', style: TextStyle(color: LoginStyle.primary, fontWeight: FontWeight.w700, fontSize: 16)),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [LoginStyle.cardShadow],
                ),
                child: _otpSent ? _stepTwo() : _stepOne(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepOne() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Icon(Icons.lock_reset_outlined, size: 48, color: LoginStyle.primary),
      const SizedBox(height: 16),
      const Text('Reset Password', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: LoginStyle.primary)),
      const SizedBox(height: 6),
      const Text('Masukkan email akun Anda. Kami akan mengirimkan kode OTP untuk mereset password.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: LoginStyle.muted)),
      const SizedBox(height: 24),
      const Text('Email', style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 7),
      TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: _decoration(icon: Icons.email_outlined, hint: 'Masukkan email terdaftar'),
      ),
      if (_errorText != null) ...[
        const SizedBox(height: 10),
        Text(_errorText!, style: const TextStyle(color: Colors.red, fontSize: 13)),
      ],
      const SizedBox(height: 20),
      SizedBox(
        height: 50,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(colors: [LoginStyle.primary, LoginStyle.primaryLight]),
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _sendOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Kirim Kode OTP', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    ],
  );

  Widget _stepTwo() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Icon(Icons.verified_outlined, size: 48, color: LoginStyle.primary),
      const SizedBox(height: 16),
      const Text('Masukkan Kode OTP', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: LoginStyle.primary)),
      const SizedBox(height: 6),
      if (_successText != null)
        Text(_successText!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF16A87A))),
      const SizedBox(height: 20),
      const Text('Kode OTP (6 digit)', style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 7),
      TextField(
        controller: _otpController,
        keyboardType: TextInputType.number,
        maxLength: 6,
        decoration: _decoration(icon: Icons.pin_outlined, hint: '123456'),
      ),
      const SizedBox(height: 14),
      const Text('Password Baru', style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 7),
      TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: _decoration(
          icon: Icons.lock_outline,
          hint: 'Minimal 8 karakter',
          suffix: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ),
      const SizedBox(height: 14),
      const Text('Konfirmasi Password', style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 7),
      TextField(
        controller: _confirmController,
        obscureText: _obscureConfirm,
        decoration: _decoration(
          icon: Icons.lock_outline,
          hint: 'Ulangi password baru',
          suffix: IconButton(
            icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
        ),
      ),
      if (_errorText != null) ...[
        const SizedBox(height: 10),
        Text(_errorText!, style: const TextStyle(color: Colors.red, fontSize: 13)),
      ],
      const SizedBox(height: 20),
      SizedBox(
        height: 50,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(colors: [LoginStyle.primary, LoginStyle.primaryLight]),
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _resetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Reset Password', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ),
      const SizedBox(height: 12),
      Center(
        child: TextButton(
          onPressed: _isLoading ? null : () => setState(() { _otpSent = false; _errorText = null; _successText = null; }),
          child: const Text('Kirim ulang kode', style: TextStyle(fontSize: 13, color: LoginStyle.primary)),
        ),
      ),
    ],
  );
}
