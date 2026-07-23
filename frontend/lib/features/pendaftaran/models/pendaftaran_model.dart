class PendaftaranModel {
  final String? opdId;
  final String? bidangUnit;
  final String? prodi;
  final String? cvPath;
  final String? transkripPath;
  final String? suratPengantarPath;
  final DateTime? tanggalMulai;
  final DateTime? tanggalSelesai;

  const PendaftaranModel({
    this.opdId,
    this.bidangUnit,
    this.prodi,
    this.cvPath,
    this.transkripPath,
    this.suratPengantarPath,
    this.tanggalMulai,
    this.tanggalSelesai,
  });
}
