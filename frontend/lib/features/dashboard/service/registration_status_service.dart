import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/network/api_client.dart';

enum RegistrationStatus { notRegistered, pending, accepted }

class RegistrationStatusService {
  RegistrationStatusService({required this.baseUrl, required this.accessToken});

  final String baseUrl;
  final String accessToken;

  Future<RegistrationStatus> fetchStatus() async {
    final url = Uri.parse('$baseUrl/peserta/registration-status');
    debugPrint('[RegistrationStatusService] GET $url');

    late http.Response response;
    try {
      response = await http
          .get(url, headers: ApiClient.authenticatedHeaders(accessToken))
          .timeout(const Duration(seconds: 20));
      debugPrint('[RegistrationStatusService] Status: ${response.statusCode}');
    } on TimeoutException {
      throw Exception('Koneksi ke server terlalu lama.');
    } on http.ClientException catch (e) {
      throw Exception('Tidak dapat terhubung ke server: $e');
    }

    final decoded = jsonDecode(response.body);
    final raw = decoded['registration_status']?.toString() ?? '';
    return switch (raw) {
      'accepted' => RegistrationStatus.accepted,
      'pending' => RegistrationStatus.pending,
      _ => RegistrationStatus.notRegistered,
    };
  }
}
