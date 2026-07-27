import '../model/nilai_model.dart';
import '../model/sertifikat_model.dart';
import '../service/nilai_service.dart';

class NilaiSertifikatData {
  const NilaiSertifikatData({this.penilaian, this.sertifikat});
  final NilaiModel? penilaian;
  final SertifikatModel? sertifikat;
}

class NilaiRepository {
  NilaiRepository(this._service);
  final NilaiService _service;

  Future<NilaiSertifikatData> load() async {
    final results = await Future.wait([
      _service.fetchPenilaian(),
      _service.fetchSertifikat(),
    ]);
    final penilaian = results[0].isEmpty
        ? null
        : NilaiModel.fromJson(results[0].first as Map<String, dynamic>);
    final certificates = results[1]
        .map((item) => SertifikatModel.fromJson(item as Map<String, dynamic>))
        .toList();
    final active = certificates.where((item) => item.tersedia).toList();
    final sertifikat = active.isNotEmpty
        ? active.first
        : (certificates.isEmpty ? null : certificates.first);
    return NilaiSertifikatData(penilaian: penilaian, sertifikat: sertifikat);
  }

  Future<SertifikatModel?> latestSertifikat() async {
    final records = await _service.fetchSertifikat();
    final items = records
        .map((item) => SertifikatModel.fromJson(item as Map<String, dynamic>))
        .toList();
    for (final item in items) {
      if (item.tersedia) return item;
    }
    return null;
  }

  NilaiModel getNilai() {
    return const NilaiModel(
      nilai: 92,

      predikat: "Sangat Baik",

      status: "Disetujui",

      reviewerInternal: "Dr. Ahmad Rizki, S.Kom., M.T.",

      reviewerEksternal: "Budi Santoso, S.Kom.",

      tanggalReview: "12 Juli 2026",

      komentarInternal:
          "Mahasiswa aktif, disiplin, serta mampu menyelesaikan tugas dengan sangat baik.",

      komentarEksternal:
          "Peserta cepat beradaptasi dan memiliki komunikasi yang baik selama kegiatan magang.",
    );
  }

  SertifikatModel getSertifikat() {
    return const SertifikatModel(
      tersedia: true,
      nama: "Magang Diskominfotik Provinsi Lampung",
      nomor: "0001/KP/DISKOMINFO/2026",
      tanggalTerbit: "20 Juli 2026",
      penerbit: "Diskominfotik Provinsi Lampung",
    );
  }

  double getProgress() {
    return .85;
  }
}
