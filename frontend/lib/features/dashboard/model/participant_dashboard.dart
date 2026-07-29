class ParticipantDashboard {
  const ParticipantDashboard({
    required this.statusLabel,
    required this.hasPresensiToday,
    required this.logbookCount,
    required this.presensiCount,
    required this.sertifikatCount,
    this.startDate,
    this.endDate,
  });

  final String statusLabel;
  final bool hasPresensiToday;
  final int logbookCount;
  final int presensiCount;
  final int sertifikatCount;
  final DateTime? startDate;
  final DateTime? endDate;

  factory ParticipantDashboard.fromResponse(Map<String, dynamic> response) {
    final data = (response['data'] as Map?)?.cast<String, dynamic>() ?? {};
    return ParticipantDashboard(
      statusLabel: data['status_label']?.toString() ?? '-',
      hasPresensiToday: data['has_presensi_today'] == true,
      logbookCount: (data['logbook_count'] as num?)?.toInt() ?? 0,
      presensiCount: (data['presensi_count'] as num?)?.toInt() ?? 0,
      sertifikatCount: (data['sertifikat_count'] as num?)?.toInt() ?? 0,
      startDate: DateTime.tryParse(data['start_date']?.toString() ?? ''),
      endDate: DateTime.tryParse(data['end_date']?.toString() ?? ''),
    );
  }
}
