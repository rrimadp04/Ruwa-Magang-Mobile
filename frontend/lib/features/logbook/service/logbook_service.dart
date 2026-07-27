import '../model/attachment_model.dart';
import '../model/logbook_model.dart';
import '../model/review_model.dart';

class LogbookService {
  LogbookService({this.baseUrl = '', this.accessToken = ''});

  final String baseUrl;
  final String accessToken;

  final List<LogbookModel> _items = [
    LogbookModel(
      id: '1',
      userId: 15,
      opdId: 1,
      activity: 'Membuat Dashboard Statistik',
      description:
          'Membuat dashboard statistik presensi dan logbook peserta magang. Dashboard menampilkan grafik kehadiran, logbook terbaru, dan ringkasan aktivitas peserta.',
      activityDate: DateTime(2026, 7, 12, 8, 30),
      status: LogbookStatus.approved,
      createdAt: DateTime(2026, 7, 12, 7, 45),
      attachments: const [
        AttachmentModel(
          name: 'Dashboard 1',
          url:
              'https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=600&q=80',
        ),
        AttachmentModel(
          name: 'Dashboard 2',
          url:
              'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=600&q=80',
        ),
        AttachmentModel(
          name: 'Dashboard 3',
          url:
              'https://images.unsplash.com/photo-1556155092-490a1ba16284?auto=format&fit=crop&w=600&q=80',
        ),
      ],
      reviews: [
        ReviewModel(
          reviewer: 'Admin OPD',
          role: 'Pembimbing Internal',
          institution: 'Diskominfotik Provinsi Lampung',
          message:
              'Mohon tambahkan dokumentasi rapat pada bukti kegiatan. Pastikan foto menunjukkan peserta terlibat aktif dalam kegiatan.',
          createdAt: DateTime(2026, 7, 12, 10, 30),
          approved: false,
          status: ReviewStatus.revision,
          checklist: const [
            ReviewChecklist(label: 'Judul Aktivitas', passed: true),
            ReviewChecklist(label: 'Deskripsi Aktivitas', passed: true),
            ReviewChecklist(
              label: 'Dokumentasi',
              passed: false,
              note: 'Foto belum menunjukkan peserta terlibat aktif.',
            ),
            ReviewChecklist(label: 'Tanggal & Waktu', passed: true),
          ],
        ),
        ReviewModel(
          reviewer: 'Peserta Magang',
          role: 'Perbaikan Dikirim Ulang',
          institution: 'Ruwa Magang',
          message:
              'Perbaikan dikirim ulang setelah melengkapi dokumentasi kegiatan.',
          createdAt: DateTime(2026, 7, 12, 13, 10),
          approved: false,
          status: ReviewStatus.resubmitted,
        ),
        ReviewModel(
          reviewer: 'Ibu Siti Aminah',
          role: 'Pembimbing Internal',
          institution: 'Diskominfotik Provinsi Lampung',
          message:
              'Logbook sudah sangat baik. Deskripsi jelas, dokumentasi lengkap, dan dashboard informatif. Pertahankan kualitas kerja yang konsisten!',
          createdAt: DateTime(2026, 7, 15, 10, 45),
          approved: true,
          status: ReviewStatus.approved,
          checklist: const [
            ReviewChecklist(label: 'Judul Aktivitas', passed: true),
            ReviewChecklist(label: 'Deskripsi Aktivitas', passed: true),
            ReviewChecklist(label: 'Dokumentasi', passed: true),
            ReviewChecklist(label: 'Tanggal & Waktu', passed: true),
          ],
        ),
        ReviewModel(
          reviewer: 'Bapak Andi Setiawan',
          role: 'Pembimbing Eksternal',
          institution: 'Universitas Teknokrat Indonesia',
          message:
              'Dashboard sudah baik dan informatif. Tambahkan insight atau kesimpulan dari data agar lebih mendalam. Semangat terus!',
          createdAt: DateTime(2026, 7, 15, 11, 30),
          approved: true,
          status: ReviewStatus.approved,
          checklist: const [
            ReviewChecklist(label: 'Judul Aktivitas', passed: true),
            ReviewChecklist(label: 'Deskripsi Aktivitas', passed: true),
            ReviewChecklist(label: 'Dokumentasi', passed: true),
            ReviewChecklist(label: 'Tanggal & Waktu', passed: true),
          ],
        ),
      ],
    ),
    LogbookModel(
      id: '2',
      userId: 15,
      opdId: 1,
      activity: 'Implementasi API Logbook',
      description:
          'Integrasi endpoint logbook dengan halaman mobile, termasuk daftar, tambah, edit, dan status review.',
      activityDate: DateTime(2026, 7, 11, 14, 20),
      status: LogbookStatus.pending,
      createdAt: DateTime(2026, 7, 11, 14, 20),
      reviews: const [],
    ),
    LogbookModel(
      id: '3',
      userId: 15,
      opdId: 1,
      activity: 'Perbaikan UI Dashboard',
      description:
          'Memperbaiki tampilan chart pada dashboard utama agar lebih mudah dibaca peserta dan pembimbing.',
      activityDate: DateTime(2026, 7, 10, 10, 15),
      status: LogbookStatus.revision,
      createdAt: DateTime(2026, 7, 10, 10, 15),
      commentCount: 2,
      reviews: [
        ReviewModel(
          reviewer: 'Admin OPD',
          role: 'Pembimbing Internal',
          institution: 'Diskominfotik Provinsi Lampung',
          message:
              'Mohon tambahkan dokumentasi rapat pada bukti kegiatan. Pastikan foto menunjukkan peserta terlibat aktif dalam kegiatan.',
          createdAt: DateTime(2026, 7, 12, 10, 30),
          approved: false,
          status: ReviewStatus.revision,
          checklist: [
            ReviewChecklist(label: 'Judul Aktivitas', passed: true),
            ReviewChecklist(label: 'Deskripsi Aktivitas', passed: true),
            ReviewChecklist(
              label: 'Dokumentasi',
              passed: false,
              note: 'Dokumentasi belum cukup mendukung kegiatan.',
            ),
            ReviewChecklist(label: 'Tanggal & Waktu', passed: true),
          ],
        ),
      ],
    ),
    LogbookModel(
      id: '4',
      userId: 15,
      opdId: 1,
      activity: 'Rapat Tim Evaluasi',
      description:
          'Rapat evaluasi progress mingguan bersama tim magang dan pembimbing lapangan.',
      activityDate: DateTime(2026, 7, 9, 9, 0),
      status: LogbookStatus.approved,
      createdAt: DateTime(2026, 7, 9, 9, 0),
      reviews: const [],
    ),
  ];

  Future<List<LogbookModel>> fetchAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return List.unmodifiable(_items);
  }

  Future<LogbookModel> create({
    required DateTime date,
    required String activity,
    List<AttachmentModel>? attachments,
  }) async {
    final item = LogbookModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      userId: 15,
      opdId: 1,
      activity: activity,
      description: activity,
      activityDate: date,
      status: LogbookStatus.pending,
      createdAt: DateTime.now(),
      reviews: const [],
      attachments: attachments ?? const [],
    );
    _items.insert(0, item);
    return item;
  }

  Future<LogbookModel> update(LogbookModel item) async {
    final index = _items.indexWhere((entry) => entry.id == item.id);
    if (index >= 0) _items[index] = item;
    return item;
  }

  Future<void> delete(String id) async =>
      _items.removeWhere((item) => item.id == id);
}
