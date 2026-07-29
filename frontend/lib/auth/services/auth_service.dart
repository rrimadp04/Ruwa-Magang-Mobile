import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/network/api_client.dart';

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthLoginResponse {
  const AuthLoginResponse({
    required this.token,
    required this.user,
  });

  final String token;
  final Map<String, dynamic> user;
}

class AuthService {
  AuthService({
    required this.baseUrl,
  });

  final String baseUrl;

  Future<AuthLoginResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _post('/login', {
      'email': email,
      'password': password,
    });

    final body = _decode(response);

    final data = _dataFrom(body);
    final token = data['token']?.toString() ?? '';
    final user = (data['user'] as Map?)?.cast<String, dynamic>() ?? {};

    if (token.isEmpty) {
      throw const ApiException('Token tidak ditemukan dari respons server.');
    }

    return AuthLoginResponse(token: token, user: user);
  }

  /// Mendaftarkan akun peserta baru. Endpoint mengembalikan token dengan
  /// format yang sama seperti login, sehingga pengguna bisa langsung masuk.
  Future<AuthLoginResponse> register({
    required String name,
    required String email,
    required String university,
    required String role,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _post('/register', {
      'name': name,
      'email': email,
      'university': university,
      'role': role,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });

    final body = _decode(response);
    final data = _dataFrom(body);
    final token = data['token']?.toString() ?? '';
    final user = (data['user'] as Map?)?.cast<String, dynamic>() ?? {};

    if (token.isEmpty) {
      throw const ApiException('Token tidak ditemukan dari respons server.');
    }

    return AuthLoginResponse(token: token, user: user);
  }

  /// Requests a six-digit OTP for the password-reset flow.
  Future<void> sendOtp({required String email}) async {
    final response = await _post('/forgot-password', {
      'email': email,
    });

    _decode(response);
  }

  /// Resets a password after the OTP sent to the registered email is verified.
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _post('/reset-password', {
      'email': email,
      'otp': otp,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });

    _decode(response);
  }

  /// Jika endpoint logout ada, gunakan endpoint ini.
  /// Spec kamu: POST /api/logout dengan header Authorization Bearer TOKEN.
  Future<void> logout({required String token}) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/logout'),
          headers: ApiClient.authenticatedHeaders(token, json: true),
        )
        .timeout(const Duration(seconds: 12));

    final body = _decode(response);
    final status = body['status']?.toString();
    if (status != 'success') {
      throw ApiException((body['message'] ?? 'Logout gagal.').toString());
    }
  }

  /// Memastikan token masih diterima oleh middleware Laravel sebelum aplikasi
  /// memperlakukan pengguna sebagai sudah masuk. Endpoint profile berada di
  /// balik middleware `api.token` dan tidak mengubah data pengguna.
  Future<bool> hasValidSession({required String token}) async {
    if (token.trim().isEmpty) return false;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/peserta/profile'),
            headers: ApiClient.authenticatedHeaders(token),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return false;
      }

      final body = jsonDecode(response.body);
      return body is Map && body['status']?.toString() == 'success';
    } on TimeoutException {
      return false;
    } on http.ClientException {
      return false;
    } on FormatException {
      return false;
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    // Log payload mentah agar respons HTML (misalnya error proxy/Laravel)
    // tidak lagi tersamarkan sebagai kegagalan parsing umum.
    debugPrint('[AuthService] HTTP ${response.statusCode} '
        '${response.request?.method ?? ''} ${response.request?.url ?? ''}');
    debugPrint('[AuthService] Response body: ${response.body}');

    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw ApiException(
        'Respons server tidak valid (HTTP ${response.statusCode}). '
        'Periksa log respons API.',
      );
    }

    if (decoded is! Map) {
      throw ApiException(
        'Format respons server tidak valid (HTTP ${response.statusCode}). '
        'Periksa log respons API.',
      );
    }

    final body = Map<String, dynamic>.from(decoded);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException((body['message'] ?? 'Permintaan gagal.').toString());
    }

    if (body['status'] == 'error') {
      throw ApiException((body['message'] ?? 'Permintaan gagal.').toString());
    }

    return body;
  }

  Map<String, dynamic> _dataFrom(Map<String, dynamic> body) {
    final data = body['data'];
    return data is Map ? Map<String, dynamic>.from(data) : const {};
  }

  Future<http.Response> _post(String path, Map<String, dynamic> payload) async {
    try {
      return await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw const ApiException('Koneksi ke server terlalu lama. Silakan coba lagi.');
    }
  }
}

