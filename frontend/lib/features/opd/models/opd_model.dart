class OpdModel {
  final int id;
  final String nama;
  final String kategori;
  final String bidang;
  final String? deskripsi;
  final String? alamat;
  final int pesertaAktif;
  final int kuota;
  final String status;
  final String? kriteria;
  final String? bidangKerja;
  final String? divisi;
  final String? kegiatanMagang;
  final String? skillDipelajari;
  final String? kontak;
  final String? email;
  final int pendaftar;
  final int mentor;
  final List<OpdBidangModel> bidangs;

  const OpdModel({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.bidang,
    this.deskripsi,
    this.alamat,
    required this.pesertaAktif,
    required this.kuota,
    required this.status,
    this.kriteria,
    this.bidangKerja,
    this.divisi,
    this.kegiatanMagang,
    this.skillDipelajari,
    this.kontak,
    this.email,
    required this.pendaftar,
    required this.mentor,
    this.bidangs = const [],
  });

  String get initial => nama.isNotEmpty ? nama[0].toUpperCase() : '?';

  factory OpdModel.fromJson(Map<String, dynamic> json) {
    final bidangsList = (json['bidangs'] as List? ?? [])
        .map((b) => OpdBidangModel.fromJson(b as Map<String, dynamic>))
        .toList();
    return OpdModel(
      id:             json['id'] as int,
      nama:           json['name'] as String? ?? '',
      kategori:       json['catalog_category'] as String? ?? '',
      bidang:         json['catalog_field'] as String? ?? '',
      deskripsi:      json['short_description'] as String?,
      alamat:         json['location'] as String?,
      pesertaAktif:   json['total_peserta_aktif'] as int? ?? 0,
      kuota:          json['total_kuota'] as int? ?? 10,
      status:         json['internship_status_label'] as String? ?? 'Terbuka',
      kriteria:       json['kriteria'] as String?,
      bidangKerja:    json['catalog_field'] as String?,
      divisi:         json['divisions'] as String?,
      kegiatanMagang: json['internship_tasks'] as String?,
      skillDipelajari:json['skills'] as String?,
      kontak:         json['contact_phone'] as String?,
      email:          json['contact_email'] as String?,
      pendaftar:      json['pendaftarans_count'] as int? ?? 0,
      mentor:         json['mentors_count'] as int? ?? 0,
      bidangs:        bidangsList,
    );
  }
}

class OpdBidangModel {
  final int id;
  final String name;
  final int kuota;
  final int pesertaAktif;
  final int sisa;
  final bool isFull;
  final String status;

  const OpdBidangModel({
    required this.id,
    required this.name,
    required this.kuota,
    required this.pesertaAktif,
    required this.sisa,
    required this.isFull,
    required this.status,
  });

  factory OpdBidangModel.fromJson(Map<String, dynamic> json) => OpdBidangModel(
    id:           json['id'] as int? ?? 0,
    name:         json['name'] as String? ?? '',
    kuota:        json['kuota'] as int? ?? 5,
    pesertaAktif: json['peserta_aktif'] as int? ?? 0,
    sisa:         json['sisa'] as int? ?? 5,
    isFull:       json['is_full'] as bool? ?? false,
    status:       json['status'] as String? ?? 'tersedia',
  );
}

// ── 15 Bidang tetap ───────────────────────────────────────────────────────────
const List<String> kDaftarBidang = [
  'BIDANG LAYANAN, TEKNOLOGI INFORMASI DAN KOMUNIKASI, PELESTARIAN, DAN KERJASAMA',
  'BIDANG AKUNTANSI',
  'BIDANG KESEHATAN MASYARAKAT',
  'BIDANG ENERGI',
  'BIDANG HUKUM',
  'BIDANG PENGELOLAAN DAN LAYANAN INFORMASI PUBLIK',
  'BIDANG PENGELOLAAN DAERAH ALIRAN SUNGAI (DAS) DAN REHABILITASI HUTAN DAN LAHAN (RHL)',
  'BIDANG PERENCANAAN DAN PEMANFAATAN HUTAN',
  'BIDANG PERLINDUNGAN DAN KONSERVASI HUTAN',
  'BIDANG PERSANDIAN DAN STATISTIK',
  'BIDANG PENYULUHAN, PEMBERDAYAAN MASYARAKAT DAN USAHA KEHUTANAN',
  'BIDANG PENGADAAN, PEMBERHENTIAN DAN INFORMASI KEPEGAWAIAN',
  'BIDANG TEKNOLOGI INFORMASI DAN KOMUNIKASI',
  'BIDANG BINA KONSTRUKSI',
  'SEKRETARIAT',
];

// ── 10 OPD default untuk dropdown (tampil tanpa ketik) ───────────────────────
final List<OpdModel> kDefaultOpds = [
  const OpdModel(id: 6, nama: 'ASISTEN ADMINISTRASI UMUM', kategori: 'Asisten', bidang: 'Administrasi Pemerintahan', pesertaAktif: 0, kuota: 75, status: 'Terbuka', pendaftar: 0, mentor: 0),
  const OpdModel(id: 4, nama: 'ASISTEN PEMERINTAHAN DAN KESEJAHTERAAN RAKYAT', kategori: 'Asisten', bidang: 'Administrasi Pemerintahan', pesertaAktif: 0, kuota: 75, status: 'Terbuka', pendaftar: 0, mentor: 0),
  const OpdModel(id: 5, nama: 'ASISTEN PEREKONOMIAN, DAN PEMBANGUNAN', kategori: 'Asisten', bidang: 'Perencanaan dan Pembangunan', pesertaAktif: 0, kuota: 75, status: 'Terbuka', pendaftar: 0, mentor: 0),
  const OpdModel(id: 29, nama: 'DINAS KOMUNIKASI, INFORMATIKA DAN STATISTIK', kategori: 'Dinas', bidang: 'Komunikasi dan Informatika', pesertaAktif: 0, kuota: 75, status: 'Terbuka', pendaftar: 0, mentor: 0),
  const OpdModel(id: 18, nama: 'DINAS KESEHATAN', kategori: 'Dinas', bidang: 'Kesehatan', pesertaAktif: 0, kuota: 75, status: 'Terbuka', pendaftar: 0, mentor: 0),
  const OpdModel(id: 17, nama: 'DINAS PENDIDIKAN DAN KEBUDAYAAN', kategori: 'Dinas', bidang: 'Pendidikan', pesertaAktif: 0, kuota: 75, status: 'Terbuka', pendaftar: 0, mentor: 0),
  const OpdModel(id: 41, nama: 'BADAN KEPEGAWAIAN DAERAH', kategori: 'Badan', bidang: 'Administrasi Pemerintahan', pesertaAktif: 0, kuota: 75, status: 'Terbuka', pendaftar: 0, mentor: 0),
  const OpdModel(id: 40, nama: 'BADAN PERENCANAAN PEMBANGUNAN DAERAH', kategori: 'Badan', bidang: 'Perencanaan dan Pembangunan', pesertaAktif: 0, kuota: 75, status: 'Terbuka', pendaftar: 0, mentor: 0),
  const OpdModel(id: 8, nama: 'BIRO HUKUM', kategori: 'Biro', bidang: 'Hukum', pesertaAktif: 0, kuota: 75, status: 'Terbuka', pendaftar: 0, mentor: 0),
  const OpdModel(id: 3, nama: 'SEKRETARIAT DAERAH PROVINSI', kategori: 'Sekretariat', bidang: 'Administrasi Pemerintahan', pesertaAktif: 0, kuota: 75, status: 'Terbuka', pendaftar: 0, mentor: 0),
];

// ── Dummy untuk tampilan offline / fallback ───────────────────────────────────
final List<OpdModel> dummyOpds = kDefaultOpds;
