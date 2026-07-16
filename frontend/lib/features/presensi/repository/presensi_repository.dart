import '../model/presensi.dart';
import '../service/presensi_service.dart';

class PresensiRepository {
  PresensiRepository(this._service);
  final PresensiService _service;

  Future<List<Presensi>> getHistory() async {
    final data = await _service.fetchHistory();
    return data
        .map((item) => Presensi.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<bool> isInternshipFinished() async {
    final profile = await _service.profile();
    final peserta = profile['data']?['peserta'] as Map<String, dynamic>?;
    return peserta?['status'] == 'selesai';
  }

  Future<Presensi> submit({
    required PresensiAction action,
    required double latitude,
    required double longitude,
    required double accuracy,
    String? photoBase64,
    String? note,
  }) async {
    final body = await _service.submit({
      'action': action.name,
      'latitude': latitude,
      'longitude': longitude,
      'location_accuracy': accuracy,
      if (photoBase64 != null) 'photo': photoBase64,
      if (note != null) 'note': note,
    });
    return Presensi.fromJson(body['data'] as Map<String, dynamic>);
  }
}
