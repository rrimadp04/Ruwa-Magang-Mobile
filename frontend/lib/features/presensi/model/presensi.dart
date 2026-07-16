class Presensi {
  const Presensi({
    required this.id,
    required this.status,
    required this.type,
    required this.presensiDate,
    required this.createdAt,
    this.note,
    this.photo,
    this.latitude,
    this.longitude,
    this.locationAccuracy,
    this.locationDistanceMeters,
    this.locationValid,
  });

  final int id;
  final String status;
  final String type;
  final DateTime presensiDate;
  final DateTime createdAt;
  final String? note;
  final String? photo;
  final double? latitude;
  final double? longitude;
  final int? locationAccuracy;
  final int? locationDistanceMeters;
  final bool? locationValid;

  factory Presensi.fromJson(Map<String, dynamic> json) => Presensi(
    id: (json['id'] as num).toInt(),
    status: (json['status'] ?? '').toString(),
    type: (json['type'] ?? '').toString(),
    presensiDate: DateTime.parse(json['presensi_date'] as String),
    createdAt: DateTime.parse(json['created_at'] as String),
    note: json['note'] as String?,
    photo: json['photo'] as String?,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    locationAccuracy: (json['location_accuracy'] as num?)?.toInt(),
    locationDistanceMeters: (json['location_distance_meters'] as num?)?.toInt(),
    locationValid: json['location_valid'] as bool?,
  );
}

enum PresensiAction { hadir, pulang, izin, selesai }

extension PresensiActionLabel on PresensiAction {
  String get label => switch (this) {
    PresensiAction.hadir => 'Absen Masuk',
    PresensiAction.pulang => 'Absen Pulang',
    PresensiAction.izin => 'Kirim Permohonan',
    PresensiAction.selesai => 'Presensi Hari Ini Selesai',
  };
}
