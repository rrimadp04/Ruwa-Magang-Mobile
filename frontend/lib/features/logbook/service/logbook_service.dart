import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/network/api_client.dart';
import '../model/attachment_model.dart';
import '../model/logbook_model.dart';

class LogbookService {
  LogbookService({this.baseUrl = '', this.accessToken = ''});

  final String baseUrl;
  final String accessToken;

  Future<List<LogbookModel>> fetchAll() async {
    final body = await _request('GET', '/peserta/logbooks');
    final data = body['data'];
    return data is List
        ? data.whereType<Map>().map((item) => LogbookModel.fromJson(item.cast<String, dynamic>())).toList()
        : const [];
  }

  Future<LogbookModel> create({required DateTime date, required String activity, List<AttachmentModel>? attachments}) async {
    final body = await _request('POST', '/peserta/logbooks', payload: {'activity': activity, 'logbook_date': _date(date)});
    return LogbookModel.fromJson((body['data'] as Map).cast<String, dynamic>());
  }

  Future<LogbookModel> update(LogbookModel item) async {
    final body = await _request('PUT', '/peserta/logbooks/${item.id}', payload: {'activity': item.activity, 'logbook_date': _date(item.activityDate)});
    return LogbookModel.fromJson((body['data'] as Map).cast<String, dynamic>());
  }

  Future<void> delete(String id) async => _request('DELETE', '/peserta/logbooks/$id');

  Future<Map<String, dynamic>> _request(String method, String path, {Map<String, dynamic>? payload}) async {
    final request = http.Request(method, Uri.parse('$baseUrl$path'));
    request.headers.addAll(ApiClient.authenticatedHeaders(accessToken, json: true));
    request.body = payload == null ? '' : jsonEncode(payload);
    final streamed = await request.send().timeout(const Duration(seconds: 20));
    final result = await http.Response.fromStream(streamed);
    final body = jsonDecode(result.body) as Map<String, dynamic>;
    if (result.statusCode < 200 || result.statusCode >= 300 || body['status'] == 'error') {
      throw Exception((body['message'] ?? 'Permintaan logbook gagal.').toString());
    }
    return body;
  }

  String _date(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
