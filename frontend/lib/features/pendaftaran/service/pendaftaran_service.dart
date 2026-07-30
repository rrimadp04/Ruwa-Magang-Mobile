import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/network/api_client.dart';

class PendaftaranService {
  PendaftaranService({required this.baseUrl, required this.accessToken});

  final String baseUrl;
  final String accessToken;

  Future<Map<String, dynamic>> submit({
    required int opdId,
    required String prodi,
    required String startDate,
    required String endDate,
    String? bidang,
    int? bidangId,
    String? cvPath,
    Uint8List? cvBytes,
    String? cvName,
    String? transkripPath,
    Uint8List? transkripBytes,
    String? transkripName,
    String? suratPath,
    Uint8List? suratBytes,
    String? suratName,
  }) async {
    final uri = Uri.parse('$baseUrl/peserta/pendaftaran');
    final headers = ApiClient.authenticatedHeaders(accessToken);
    final request = http.MultipartRequest('POST', uri)..headers.addAll(headers);

    request.fields['opd_id']     = opdId.toString();
    request.fields['prodi']      = prodi;
    request.fields['start_date'] = startDate;
    request.fields['end_date']   = endDate;
    if (bidang != null && bidang.isNotEmpty) request.fields['bidang'] = bidang;
    if (bidangId != null) request.fields['bidang_id'] = bidangId.toString();

    if (cvBytes != null) {
      request.files.add(http.MultipartFile.fromBytes('cv', cvBytes, filename: cvName ?? 'cv.pdf'));
    } else if (cvPath != null) {
      request.files.add(await http.MultipartFile.fromPath('cv', cvPath, filename: cvName));
    }

    if (transkripBytes != null) {
      request.files.add(http.MultipartFile.fromBytes('transkrip', transkripBytes, filename: transkripName ?? 'transkrip.pdf'));
    } else if (transkripPath != null) {
      request.files.add(await http.MultipartFile.fromPath('transkrip', transkripPath, filename: transkripName));
    }

    if (suratBytes != null) {
      request.files.add(http.MultipartFile.fromBytes('surat', suratBytes, filename: suratName ?? 'surat.pdf'));
    } else if (suratPath != null) {
      request.files.add(await http.MultipartFile.fromPath('surat', suratPath, filename: suratName));
    }

    final streamed  = await request.send().timeout(const Duration(seconds: 60));
    final response  = await http.Response.fromStream(streamed);
    debugPrint('[PendaftaranService] ${response.statusCode}: ${response.body}');

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 409) {
      throw Exception(body['message'] ?? 'Anda sudah memiliki pendaftaran aktif.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final msg = body['message'] ?? body['errors']?.toString() ?? 'Pendaftaran gagal.';
      throw Exception(msg);
    }
    return body;
  }
}
