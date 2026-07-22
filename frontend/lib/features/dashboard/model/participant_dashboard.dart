class ParticipantDashboard {
  const ParticipantDashboard({
    required this.statusLabel,
    required this.hasPresensiToday,
    required this.logbookCount,
  });

  final String statusLabel;
  final bool hasPresensiToday;
  final int logbookCount;

  factory ParticipantDashboard.fromResponse(Map<String, dynamic> response) {
    final data = (response['data'] as Map?)?.cast<String, dynamic>() ?? {};
    return ParticipantDashboard(
      statusLabel: data['status_label']?.toString() ?? '-',
      hasPresensiToday: data['has_presensi_today'] == true,
      logbookCount: (data['logbook_count'] as num?)?.toInt() ?? 0,
    );
  }
}
