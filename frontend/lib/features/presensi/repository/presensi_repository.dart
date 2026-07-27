import '../model/presensi.dart';
import '../service/presensi_service.dart';

class PresensiRepository {
  PresensiRepository(this._service);
  final PresensiService _service;

  /// baseUrl service ini berbentuk "http://host/api" (dipakai untuk
  /// memanggil endpoint). Untuk menampilkan foto ("storage/presensis/xxx.jpg")
  /// kita butuh root host TANPA "/api", karena foto disajikan lewat
  /// symlink public/storage, bukan lewat prefix /api.
  String get photoBaseUrl =>
      _service.baseUrl.replaceFirst(RegExp(r'/api/?$'), '');

  Future<List<Presensi>> getHistory({DateTime? start, DateTime? end}) async {
    final data = await _service.fetchHistory(start: start, end: end);
    return data
        .map((item) => Presensi.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<bool> isInternshipFinished() async {
    final profile = await _service.profile();
    final peserta = profile['data']?['peserta'] as Map<String, dynamic>?;
    return peserta?['status'] == 'selesai';
  }

  Future<AttendanceSchedule> getAttendanceSchedule() async {
    final body = await _service.fetchAttendanceSettings();
    return AttendanceSchedule.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<Presensi> submit({
    required PresensiAction action,
    required double latitude,
    required double longitude,
    required double accuracy,
    String? locationAddress,
    String? photoBase64,
    String? note,
    String? proofBase64,
    String? proofName,
  }) async {
    final body = await _service.submit({
      'action': action.name,
      'latitude': latitude,
      'longitude': longitude,
      'location_accuracy': accuracy,
      if (locationAddress != null) 'location_address': locationAddress,
      if (photoBase64 != null) 'photo': photoBase64,
      if (note != null) 'note': note,
      if (proofBase64 != null) 'proof': proofBase64,
      if (proofName != null) 'proof_name': proofName,
    });
    return Presensi.fromJson(body['data'] as Map<String, dynamic>);
  }
}

class AttendanceSchedule {
  const AttendanceSchedule({
    required this.checkInTime,
    required this.checkOutTime,
    required this.timezone,
  });

  final String checkInTime;
  final String checkOutTime;
  final String timezone;

  factory AttendanceSchedule.fromJson(Map<String, dynamic> json) => AttendanceSchedule(
    checkInTime: (json['check_in_time'] ?? '07:30').toString(),
    checkOutTime: (json['check_out_time'] ?? '16:00').toString(),
    timezone: (json['timezone'] ?? 'Asia/Jakarta').toString(),
  );
}
