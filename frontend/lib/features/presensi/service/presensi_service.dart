import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
}

class PresensiService {
  PresensiService({required this.baseUrl, required this.accessToken});

  final String baseUrl;
  final String accessToken;
  static const _requestTimeout = Duration(seconds: 12);

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
  };

  Future<List<dynamic>> fetchHistory() async {
    final response = await http
        .get(Uri.parse('$baseUrl/peserta/presensi'), headers: _headers)
        .timeout(_requestTimeout);
    final body = _decode(response);
    return body['data'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> submit(Map<String, dynamic> payload) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/peserta/presensi'),
          headers: _headers,
          body: jsonEncode(payload),
        )
        .timeout(_requestTimeout);
    return _decode(response);
  }

  Future<Map<String, dynamic>> profile() async {
    final response = await http
        .get(Uri.parse('$baseUrl/peserta/profile'), headers: _headers)
        .timeout(_requestTimeout);
    return _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic> body = {};
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const ApiException('Respons server tidak dapat diproses.');
    }
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        body['status'] == 'error') {
      throw ApiException((body['message'] ?? 'Permintaan gagal.').toString());
    }
    return body;
  }
}
