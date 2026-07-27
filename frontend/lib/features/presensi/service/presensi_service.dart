import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/network/api_client.dart';

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
}

class PresensiService {
  PresensiService({required this.baseUrl, required this.accessToken});

  final String baseUrl;
  final String accessToken;
  static const _requestTimeout = Duration(seconds: 12);

  Map<String, String> get _headers =>
      ApiClient.authenticatedHeaders(accessToken, json: true);

  Future<List<dynamic>> fetchHistory({DateTime? start, DateTime? end}) async {
    final uri = Uri.parse('$baseUrl/peserta/presensi').replace(queryParameters: {
      if (start != null) 'date_start': _date(start),
      if (end != null) 'date_end': _date(end),
    });
    final response = await http
        .get(uri, headers: _headers)
        .timeout(_requestTimeout);
    final body = _decode(response);
    return body['data'] as List<dynamic>;
  }

  String _date(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

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

  Future<Map<String, dynamic>> fetchAttendanceSettings() async {
    final response = await http
        .get(Uri.parse('$baseUrl/peserta/presensi/settings'), headers: _headers)
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
      final errors = body['errors'];
      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            throw ApiException(value.first.toString());
          }
        }
      }
      throw ApiException((body['message'] ?? 'Permintaan gagal.').toString());
    }
    return body;
  }
}
