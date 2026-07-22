import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

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

    final token = body['data']?['token']?.toString() ?? '';
    final user = (body['data']?['user'] as Map?)?.cast<String, dynamic>() ?? {};

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
    final token = body['data']?['token']?.toString() ?? '';
    final user = (body['data']?['user'] as Map?)?.cast<String, dynamic>() ?? {};

    if (token.isEmpty) {
      throw const ApiException('Token tidak ditemukan dari respons server.');
    }

    return AuthLoginResponse(token: token, user: user);
  }

  /// Jika endpoint logout ada, gunakan endpoint ini.
  /// Spec kamu: POST /api/logout dengan header Authorization Bearer TOKEN.
  Future<void> logout({required String token}) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
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
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
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
    Map<String, dynamic> body = {};
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const ApiException('Respons server tidak dapat diproses.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException((body['message'] ?? 'Permintaan gagal.').toString());
    }

    if (body['status'] == 'error') {
      throw ApiException((body['message'] ?? 'Permintaan gagal.').toString());
    }

    return body;
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

