class NilaiModel {
  final double nilai;
  final String predikat;
  final String status;
  final String reviewerInternal;
  final String reviewerEksternal;
  final String tanggalReview;
  final String komentarInternal;
  final String komentarEksternal;
  final String fileUrl;

  const NilaiModel({
    required this.nilai,
    required this.predikat,
    required this.status,
    required this.reviewerInternal,
    required this.reviewerEksternal,
    required this.tanggalReview,
    required this.komentarInternal,
    required this.komentarEksternal,
    this.fileUrl = '',
  });

  factory NilaiModel.fromJson(Map<String, dynamic> json) => NilaiModel(
        nilai: double.tryParse('${json['nilai_akhir'] ?? json['nilai'] ?? 0}') ?? 0,
        predikat: '${json['predikat'] ?? json['grade_label'] ?? '-'}',
        status: '${json['status'] ?? 'menunggu'}',
        reviewerInternal: '${json['reviewer_internal'] ?? json['reviewer'] ?? '-'}',
        reviewerEksternal: '${json['reviewer_eksternal'] ?? '-'}',
        tanggalReview: '${json['tanggal_review'] ?? json['reviewed_at'] ?? '-'}',
        komentarInternal: '${json['komentar_internal'] ?? json['komentar'] ?? '-'}',
        komentarEksternal: '${json['komentar_eksternal'] ?? '-'}',
        fileUrl: '${json['file_url'] ?? json['url'] ?? ''}',
      );
}
