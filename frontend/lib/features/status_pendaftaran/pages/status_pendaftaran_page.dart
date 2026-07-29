import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../profile/screen/guide_screen.dart';

class StatusPendaftaranPage extends StatelessWidget {
  const StatusPendaftaranPage({
    super.key,
    required this.status,
    required this.opdNama,
    required this.bidang,
    this.prodi,
    this.cvName,
    this.transkripName,
    this.suratName,
    this.tanggalMulai,
    this.tanggalSelesai,
    this.alasanPenolakan,
    this.idPendaftaran,
  });

  final String status;
  final String opdNama;
  final String bidang;
  final String? prodi;
  final String? cvName;
  final String? transkripName;
  final String? suratName;
  final DateTime? tanggalMulai;
  final DateTime? tanggalSelesai;
  final String? alasanPenolakan;
  final String? idPendaftaran;

  bool get _berhasil => status == 'berhasil';
  String get _regId => idPendaftaran ?? (_berhasil ? '#REG-20260714' : '#REG-2024-0892');

  String _fmt(DateTime? d) {
    if (d == null) return '-';
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agt','Sep','Okt','Nov','Des'];
    return '${d.day.toString().padLeft(2,'0')} ${months[d.month-1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bg,
    appBar: AppBar(
      backgroundColor: AppColors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.ink),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: const Text('Ruwa Magang'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryLight,
            child: const Text('N', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
      children: [
        // Banner notifikasi
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _berhasil ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                _berhasil ? Icons.check_circle_outline : Icons.error_outline,
                color: _berhasil ? AppColors.success : AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _berhasil
                      ? 'Pendaftaran berhasil dikirim. Tunggu konfirmasi admin OPD.'
                      : 'Pendaftaran ditolak. Silakan cek alasan atau hubungi admin.',
                  style: TextStyle(color: _berhasil ? AppColors.success : AppColors.error, fontSize: 13),
                ),
              ),
              if (_berhasil)
                GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.close, size: 16, color: AppColors.grey),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Ikon status
        Center(
          child: Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _berhasil ? AppColors.primary : AppColors.error, width: 3),
              color: _berhasil ? const Color(0xFFEFF6FF) : const Color(0xFFFEF2F2),
            ),
            child: Icon(_berhasil ? Icons.check : Icons.close, size: 40, color: _berhasil ? AppColors.primary : AppColors.error),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _berhasil ? 'Pendaftaran Berhasil Dikirim!' : 'Pendaftaran Ditolak',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink),
        ),
        const SizedBox(height: 8),
        Text(
          _berhasil
              ? 'Terima kasih. Berkas pendaftaran Anda telah masuk ke sistem kami dan sedang dalam antrean peninjauan oleh admin OPD.'
              : 'Mohon maaf, permohonan magang Anda belum dapat diterima pada periode ini.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.grey, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 20),
        // Alasan penolakan
        if (!_berhasil) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4, height: 60,
                  decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(4)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.error, size: 16),
                          SizedBox(width: 6),
                          Text('ALASAN PENOLAKAN', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.error, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          '"${alasanPenolakan ?? 'Kualifikasi prodi tidak sesuai dengan kebutuhan unit kerja saat ini.'}"',
                          style: const TextStyle(color: AppColors.ink, fontSize: 13, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        // Info card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_berhasil) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('STATUS PENDAFTARAN', style: TextStyle(color: AppColors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time, color: AppColors.warning, size: 16),
                            SizedBox(width: 4),
                            Text('Menunggu', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('ID REG', style: TextStyle(color: AppColors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(_regId, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 20),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('ID PENDAFTARAN', style: TextStyle(color: AppColors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
                    Text(_regId, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                  ],
                ),
                const Divider(height: 20),
              ],
              const Text('OPD Tujuan', style: TextStyle(color: AppColors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              Text(opdNama, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 12),
              Text(_berhasil ? 'Bidang' : 'Bidang / Unit', style: const TextStyle(color: AppColors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              Text(bidang.isNotEmpty ? bidang : '-', style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700, fontSize: 13)),
              if (_berhasil && prodi != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Prodi / Jurusan', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(prodi!, style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Dikirim pada', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(_fmt(DateTime.now()), style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              if (!_berhasil) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TANGGAL MULAI', style: TextStyle(color: AppColors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Row(children: [
                            const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.grey),
                            const SizedBox(width: 4),
                            Text(_fmt(tanggalMulai ?? DateTime(2024, 8, 1)), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          ]),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TANGGAL SELESAI', style: TextStyle(color: AppColors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Row(children: [
                            const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.grey),
                            const SizedBox(width: 4),
                            Text(_fmt(tanggalSelesai ?? DateTime(2024, 10, 31)), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        // Berkas terunggah
        if (_berhasil) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('BERKAS TERUNGGAH', style: TextStyle(color: AppColors.grey, fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                _berkasItem(Icons.description_outlined, 'Curriculum Vitae (CV)', cvName != null ? 'PDF • ${cvName!}' : 'PDF • 1.2 MB'),
                const Divider(height: 16),
                _berkasItem(Icons.receipt_long_outlined, 'Transkrip Nilai', transkripName != null ? 'PDF • ${transkripName!}' : 'PDF • 850 KB'),
                const Divider(height: 16),
                _berkasItem(Icons.mail_outline, 'Surat Pengantar Kampus', suratName != null ? 'PDF • ${suratName!}' : 'PDF • 520 KB'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppColors.warning, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Status pendaftaran akan diperbarui setelah dilakukan verifikasi oleh admin OPD terkait. Pantau menu Logbook atau email Anda secara berkala.',
                    style: TextStyle(color: AppColors.warning, fontSize: 12, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        // Tombol Kembali ke Beranda
        FilledButton.icon(
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          icon: const Icon(Icons.home_outlined, size: 18),
          label: const Text('Kembali ke Beranda', style: TextStyle(fontWeight: FontWeight.w700)),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 10),
        // Tombol kedua — Lihat Panduan Magang (berhasil) atau Cari Lowongan Lain (ditolak)
        OutlinedButton.icon(
          onPressed: () {
            if (_berhasil) {
              // Navigasi ke GuideScreen dari modul profile
              Navigator.push(context, MaterialPageRoute(builder: (_) => const GuideScreen()));
            } else {
              Navigator.of(context).popUntil((r) => r.isFirst);
            }
          },
          icon: Icon(_berhasil ? Icons.menu_book_outlined : Icons.search, size: 18),
          label: Text(
            _berhasil ? 'Lihat Panduan Magang' : 'Cari Lowongan Lain',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            side: const BorderSide(color: AppColors.primary),
            foregroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '© 2026 • Dinas Komunikasi, Informatika, dan Statistik (Diskominfotik) Provinsi Lampung',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.grey, fontSize: 11),
        ),
      ],
    ),
    bottomNavigationBar: _bottomNav(),
  );

  Widget _berkasItem(IconData icon, String nama, String ukuran) => Row(
    children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(nama, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.ink)),
            Text(ukuran, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
          ],
        ),
      ),
      const Icon(Icons.open_in_new, size: 18, color: AppColors.primary),
    ],
  );

  Widget _bottomNav() => NavigationBar(
    selectedIndex: _berhasil ? 1 : 0,
    onDestinationSelected: (_) {},
    height: 74,
    indicatorColor: AppColors.primaryLight,
    destinations: const [
      NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Beranda'),
      NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'Daftar'),
      NavigationDestination(icon: Icon(Icons.edit_note_outlined), selectedIcon: Icon(Icons.edit_note), label: 'Logbook'),
      NavigationDestination(icon: Icon(Icons.workspace_premium_outlined), selectedIcon: Icon(Icons.workspace_premium), label: 'Sertifikat'),
      NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
    ],
  );
}
