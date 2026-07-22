class ParticipantProfile {
  const ParticipantProfile({
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  final String name;
  final DateTime? startDate;
  final DateTime? endDate;

  factory ParticipantProfile.fromResponse(Map<String, dynamic> response) {
    final data = (response['data'] as Map?)?.cast<String, dynamic>() ?? {};
    final user = (data['user'] as Map?)?.cast<String, dynamic>() ?? {};
    final peserta = (data['peserta'] as Map?)?.cast<String, dynamic>() ?? {};
    return ParticipantProfile(
      name: user['name']?.toString().trim().isNotEmpty == true
          ? user['name'].toString()
          : 'Peserta Magang',
      startDate: DateTime.tryParse(peserta['start_date']?.toString() ?? ''),
      endDate: DateTime.tryParse(peserta['end_date']?.toString() ?? ''),
    );
  }
}
