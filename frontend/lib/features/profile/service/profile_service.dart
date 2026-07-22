import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ProfileApiException implements Exception {
  const ProfileApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ProfileService {
  ProfileService({required this.baseUrl, required this.accessToken});

  final String baseUrl;
  final String accessToken;

  Future<Map<String, dynamic>> fetchProfile() async {
    if (accessToken.isEmpty) {
      throw const ProfileApiException('Sesi login tidak ditemukan. Silakan masuk kembali.');
    }

    late http.Response response;
    try {
      response = await http
          .get(
            Uri.parse('$baseUrl/peserta/profile'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw const ProfileApiException('Koneksi ke server terlalu lama. Silakan coba lagi.');
    } on http.ClientException {
      throw const ProfileApiException('Tidak dapat terhubung ke server.');
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const ProfileApiException('Respons profil dari server tidak valid.');
    }

    if (decoded is! Map<String, dynamic> ||
        response.statusCode < 200 ||
        response.statusCode >= 300 ||
        decoded['status'] == 'error') {
      throw ProfileApiException(
        decoded is Map
            ? (decoded['message'] ?? 'Gagal memuat profil.').toString()
            : 'Gagal memuat profil.',
      );
    }
    return decoded;
  }

  Future<void> updateProfile({required String name, required String email}) =>
      _post('/peserta/pengaturan-akun/update', {'name': name, 'email': email});

  Future<void> updatePassword({
    required String currentPassword,
    required String password,
    required String confirmation,
  }) => _post('/peserta/pengaturan-akun/password', {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': confirmation,
      });

  Future<void> uploadPhoto({required List<int> bytes, required String filename}) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/peserta/pengaturan-akun/photo'))
      ..headers.addAll({'Accept': 'application/json', 'Authorization': 'Bearer $accessToken'})
      ..files.add(http.MultipartFile.fromBytes('photo', bytes, filename: filename));
    try {
      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);
      _decodeSuccess(response);
    } on TimeoutException {
      throw const ProfileApiException('Upload foto terlalu lama. Silakan coba lagi.');
    } on http.ClientException {
      throw const ProfileApiException('Tidak dapat terhubung ke server.');
    }
  }

  Future<void> logout() => _post('/logout', const {});

  Future<void> _post(String path, Map<String, dynamic> payload) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: {'Accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));
      _decodeSuccess(response);
    } on TimeoutException {
      throw const ProfileApiException('Koneksi ke server terlalu lama. Silakan coba lagi.');
    } on http.ClientException {
      throw const ProfileApiException('Tidak dapat terhubung ke server.');
    }
  }

  void _decodeSuccess(http.Response response) {
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const ProfileApiException('Respons server tidak valid.');
    }
    if (decoded is! Map || response.statusCode < 200 || response.statusCode >= 300 || decoded['status'] == 'error') {
      throw ProfileApiException(decoded is Map ? (decoded['message'] ?? 'Permintaan gagal.').toString() : 'Permintaan gagal.');
    }
  }
}
