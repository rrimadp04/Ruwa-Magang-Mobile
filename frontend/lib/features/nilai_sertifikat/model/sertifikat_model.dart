class SertifikatModel {
  final bool tersedia;
  final String nama;
  final String nomor;
  final String tanggalTerbit;
  final String penerbit;
  final String fileUrl;

  const SertifikatModel({
    required this.tersedia,
    required this.nama,
    required this.nomor,
    required this.tanggalTerbit,
    required this.penerbit,
    this.fileUrl = '',
  });

  factory SertifikatModel.fromJson(Map<String, dynamic> json) {
    final status = '${json['status'] ?? ''}'.toLowerCase();
    return SertifikatModel(
      tersedia: status == 'issued' || status == 'active' || status == 'terbit' ||
          json['tersedia'] == true || json['file_url'] != null,
      nama: '${json['nama'] ?? json['nama_sertifikat'] ?? 'Sertifikat Magang'}',
      nomor: '${json['nomor'] ?? json['nomor_sertifikat'] ?? '-'}',
      tanggalTerbit: '${json['tanggal_terbit'] ?? json['issued_at'] ?? '-'}',
      penerbit: '${json['penerbit'] ?? json['diterbitkan_oleh'] ?? '-'}',
      fileUrl: '${json['file_url'] ?? json['url'] ?? ''}',
    );
  }
}
