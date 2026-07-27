import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class DashboardService {
  DashboardService({required this.baseUrl, required this.accessToken});

  final String baseUrl;
  final String accessToken;

  Future<Map<String, dynamic>> fetchDashboard() async {
    if (accessToken.isEmpty) {
      debugPrint('[DashboardService] ERROR: accessToken kosong');
      throw const DashboardApiException('Sesi login tidak ditemukan. Silakan masuk kembali.');
    }

    final url = Uri.parse('$baseUrl/peserta/dashboard');
    final tokenPreview = accessToken.length > 20
        ? '${accessToken.substring(0, 20)}...'
        : accessToken;
    debugPrint('[DashboardService] GET $url');
    debugPrint('[DashboardService] Authorization: Bearer $tokenPreview');

    late http.Response response;
    try {
      response = await http
          .get(
            url,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(const Duration(seconds: 20));
      debugPrint('[DashboardService] Status: ${response.statusCode}');
      debugPrint('[DashboardService] Body: ${response.body}');
    } on TimeoutException {
      debugPrint('[DashboardService] ERROR: Request timeout');
      throw const DashboardApiException(
        'Koneksi ke server terlalu lama. Periksa jaringan lalu coba lagi.',
      );
    } on http.ClientException catch (e) {
      debugPrint('[DashboardService] ERROR: ClientException - $e');
      throw const DashboardApiException('Tidak dapat terhubung ke server.');
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const DashboardApiException('Respons dashboard dari server tidak valid.');
    }

    if (decoded is! Map<String, dynamic> ||
        response.statusCode < 200 ||
        response.statusCode >= 300 ||
        decoded['status'] == 'error') {
      throw DashboardApiException(
        decoded is Map
            ? (decoded['message'] ?? 'Gagal memuat dashboard.').toString()
            : 'Respons server tidak valid.',
      );
    }
    return decoded;
  }
}

class DashboardApiException implements Exception {
  const DashboardApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
