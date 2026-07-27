import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/api_client.dart';
import '../services/auth_service.dart';

class AuthRepository {
  AuthRepository({
    required this.service,
    required this.prefs,
  });

  final AuthService service;
  final SharedPreferences prefs;

  static const tokenKey = 'access_token';

  /// Token yang dipakai oleh layanan API harus selalu berupa nilai token
  /// mentah. Versi aplikasi sebelumnya dapat meninggalkan nilai dengan
  /// awalan `Bearer ` di SharedPreferences; bila awalan itu dikirim lagi oleh
  /// service, header menjadi `Bearer Bearer <token>` dan middleware Laravel
  /// tidak dapat menemukannya di database.
  String get accessToken => normalizeToken(prefs.getString(tokenKey) ?? '');

  Future<void> persistToken(String token) async {
    final normalizedToken = normalizeToken(token);
    if (normalizedToken.isEmpty) {
      throw const ApiException('Token tidak valid dari respons server.');
    }

    await prefs.setString(tokenKey, normalizedToken);
  }

  static String normalizeToken(String token) {
    return ApiClient.normalizeToken(token);
  }

  Future<void> clearToken() async {
    await prefs.remove(tokenKey);
  }

  Future<bool> hasValidSession() {
    final token = accessToken;
    return service.hasValidSession(token: token);
  }


  Future<AuthLoginResponse> login({
    required String email,
    required String password,
  }) {
    return service.login(email: email, password: password);
  }

  Future<AuthLoginResponse> register({
    required String name,
    required String email,
    required String university,
    required String role,
    required String password,
    required String passwordConfirmation,
  }) {
    return service.register(
      name: name,
      email: email,
      university: university,
      role: role,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }

  Future<void> logout() async {
    final token = accessToken;
    if (token.isEmpty) {
      await clearToken();
      return;
    }
    await service.logout(token: token);
    await clearToken();
  }
}

