class ParticipantProfile {
  const ParticipantProfile({
    required this.name,
    required this.email,
    required this.nim,
    required this.university,
    required this.studyProgram,
    required this.statusLabel,
    required this.opdPlacement,
    required this.internshipPeriod,
    this.photoUrl,
  });

  final String name;
  final String email;
  final String nim;
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
    final peserta = (data['peserta'] as Map?)?.cast<String, dynamic>() ?? data;
    final opd = (data['opd'] as Map?)?.cast<String, dynamic>() ?? {};
    final rawPhoto = data['photo_url']?.toString().trim();

    return ParticipantProfile(
      name: _value(data['nama'], user['name'], fallback: 'Peserta Magang'),
      email: _value(data['email'], user['email']),
      nim: _value(data['nim'], peserta['nim_nisn'], fallback: '-'),
      university: _value(
        data['universitas'],
        peserta['sekolah_kampus'],
        fallback: '-',
      ),
      studyProgram: _value(
        data['program_studi'],
        peserta['jurusan'],
        fallback: '-',
      ),
      statusLabel: _value(
        data['status_label'],
        peserta['status'] == 'aktif' ? 'Aktif Magang' : peserta['status'],
        fallback: 'Peserta Aktif',
      ),
      opdPlacement: _value(data['opd_penempatan'], opd['nama_opd'] ?? opd['name'], fallback: 'Belum ditentukan'),
      internshipPeriod: _period(peserta['start_date'], peserta['end_date']),
      photoUrl: rawPhoto == null || rawPhoto.isEmpty ? null : rawPhoto,
    );
  }

  static String _value(Object? primary, Object? secondary, {String fallback = '-'}) {
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
}
