import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../presensi/service/presensi_service.dart';

class NilaiService {
  NilaiService({required this.baseUrl, required this.accessToken});

  final String baseUrl;
  final String accessToken;
  static const _timeout = Duration(seconds: 12);

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        if (accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
      };

  Future<List<dynamic>> fetchPenilaian() => _getList('/peserta/penilaian');

  Future<List<dynamic>> fetchSertifikat() => _getList('/peserta/sertifikat');

  Future<void> uploadPenilaian({
    required Uint8List bytes,
    required String filename,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/peserta/penilaian'),
    )
      ..headers.addAll(_headers)
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
    final response = await request.send().timeout(_timeout);
    final body = await response.stream.bytesToString();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_message(body));
    }
  }

  Future<List<dynamic>> _getList(String path) async {
    final response = await http
        .get(Uri.parse('$baseUrl$path'), headers: _headers)
        .timeout(_timeout);
    final body = _decode(response);
    final data = body['data'];
    if (data is List) return data;
    if (data is Map<String, dynamic> && data['data'] is List) {
      return data['data'] as List<dynamic>;
    }
    return const [];
  }

  Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const ApiException('Respons server tidak dapat diproses.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300 || body['status'] == 'error') {
      throw ApiException((body['message'] ?? 'Permintaan gagal.').toString());
    }
    return body;
  }

  String _message(String responseBody) {
    try {
      final body = jsonDecode(responseBody) as Map<String, dynamic>;
      return (body['message'] ?? 'Upload penilaian gagal.').toString();
    } catch (_) {
      return 'Upload penilaian gagal.';
    }
  }
}
