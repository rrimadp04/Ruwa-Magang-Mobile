class ParticipantProfile {
  const ParticipantProfile({
    required this.name,
    required this.email,
    required this.university,
    required this.studyProgram,
    required this.statusLabel,
    required this.opdPlacement,
    required this.internshipPeriod,
    this.photoUrl,
  });

  final String name;
  final String email;
  final String university;
  final String studyProgram;
  final String statusLabel;
  final String opdPlacement;
  final String internshipPeriod;
  final String? photoUrl;

  factory ParticipantProfile.fromResponse(Map<String, dynamic> response) {
    final data = (response['data'] as Map?)?.cast<String, dynamic>() ?? {};

    // Mendukung kontrak profil mobile saat ini dan kontrak profil final.
    final user = (data['user'] as Map?)?.cast<String, dynamic>() ?? data;
    final pendaftaran =
        (data['pendaftaran'] as Map?)?.cast<String, dynamic>() ?? {};
    final rawPhoto = data['photo_url']?.toString().trim();

    return ParticipantProfile(
      name: _value(
        data['nama'],
        secondary: user['name'],
        fallback: 'Peserta Magang',
      ),
      email: _value(data['email'], secondary: user['email']),
      // University is account data from registration. Internship fields are
      // intentionally read only from the submitted registration.
      university: _value(user['university']),
      studyProgram: _value(pendaftaran['prodi']),
      statusLabel: _statusLabel(pendaftaran['status']),
      opdPlacement: _value(pendaftaran['opd_name'], fallback: 'Belum ditentukan'),
      internshipPeriod: _period(
        pendaftaran['start_date'],
        pendaftaran['end_date'],
      ),
      photoUrl: rawPhoto == null || rawPhoto.isEmpty ? null : rawPhoto,
    );
  }

  static String _value(
    Object? primary, {
    Object? secondary,
    String fallback = '-',
  }) {
    final first = primary?.toString().trim() ?? '';
    if (first.isNotEmpty) return first;
    final second = secondary?.toString().trim() ?? '';
    return second.isNotEmpty ? second : fallback;
  }

  static String _period(Object? start, Object? end) {
    final first = start?.toString().trim() ?? '';
    final last = end?.toString().trim() ?? '';
    return first.isNotEmpty && last.isNotEmpty ? '$first s.d. $last' : 'Belum ditentukan';
  }

  static String _statusLabel(Object? value) => switch (value?.toString()) {
        'accepted' || 'aktif' => 'Aktif Magang',
        'pending' => 'Menunggu Persetujuan',
        'rejected' || 'ditolak' => 'Ditolak',
        'selesai' => 'Selesai',
        _ => 'Belum terdaftar',
      };
}
