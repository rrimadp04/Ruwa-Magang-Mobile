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
  });

  String get initial => nama.isNotEmpty ? nama[0].toUpperCase() : '?';
}

final dummyOpds = [
  const OpdModel(
    id: 1,
    nama: 'ASISTEN ADMINISTRASI UMUM',
    kategori: 'Asisten',
    bidang: 'Administrasi Pemerintahan',
    deskripsi: null,
    alamat: null,
    pesertaAktif: 0,
    kuota: 10,
    status: 'Terbuka',
    pendaftar: 0,
    mentor: 0,
  ),
  const OpdModel(
    id: 2,
    nama: 'BADAN KEPEGAWAIAN DAERAH',
    kategori: 'Badan',
    bidang: 'Administrasi Pemerintahan',
    deskripsi: 'Mengelola administrasi kepegawaian daerah secara profesional.',
    alamat: 'Gedung Sate, Lt. 2',
    pesertaAktif: 4,
    kuota: 10,
    status: 'Terbuka',
    pendaftar: 4,
    mentor: 2,
  ),
  const OpdModel(
    id: 3,
    nama: 'DINAS KOMUNIKASI DAN INFORMATIKA',
    kategori: 'Dinas',
    bidang: 'Teknologi Informasi',
    deskripsi: 'Fokus pada transformasi digital dan tata kelola data pemerintah.',
    alamat: 'Jl. Diponegoro No. 22',
    pesertaAktif: 8,
    kuota: 15,
    status: 'Terbuka',
    pendaftar: 8,
    mentor: 3,
  ),
];
