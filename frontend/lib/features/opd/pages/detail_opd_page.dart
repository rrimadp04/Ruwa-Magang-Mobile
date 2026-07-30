import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/opd_model.dart';
import '../../pendaftaran/pages/pendaftaran_page.dart';

class DetailOpdPage extends StatelessWidget {
  const DetailOpdPage({super.key, required this.opd});

  final OpdModel opd;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bg,
    appBar: AppBar(
      backgroundColor: AppColors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.ink),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('Ruwa Magang'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryLight,
            child: const Icon(Icons.person, color: AppColors.primary, size: 20),
          ),
        ),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: 1,
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
    ),
    body: ListView(
      padding: const EdgeInsets.only(bottom: 30),
      children: [
        // Header gradient
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF1E40AF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF16A34A), borderRadius: BorderRadius.circular(20)),
                child: Text(opd.status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.center,
                    child: Text(opd.initial, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: AppColors.ink)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(opd.nama, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(opd.bidang, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Profil OPD
        _section(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Profil OPD', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.ink)),
            const SizedBox(height: 6),
            Text(opd.deskripsi ?? 'Profil lengkap OPD belum tersedia.', style: const TextStyle(color: AppColors.grey, fontSize: 13)),
          ],
        )),
        // Kriteria
        _sectionBorder(icon: Icons.check_circle, title: 'Kriteria yang Dibutuhkan', content: opd.kriteria ?? 'Kriteria khusus belum ditentukan oleh instansi ini.'),
        // Info items
        _infoItem(Icons.work_outline, 'Bidang Kerja', opd.bidangKerja ?? opd.bidang),
        _infoItem(Icons.layers_outlined, 'Divisi Tersedia', opd.divisi ?? '-'),
        _infoItem(Icons.assignment_outlined, 'Kegiatan Magang', opd.kegiatanMagang ?? '-'),
        _infoItem(Icons.build_outlined, 'Skill Dipelajari', opd.skillDipelajari ?? '-'),
        // Informasi Praktis
        _section(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Informasi Praktis', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.ink)),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _infoGrid('KATEGORI', opd.kategori)),
              Expanded(child: _infoGrid('LOKASI', opd.alamat ?? '-')),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _infoGrid('KONTAK', opd.kontak ?? '-')),
              Expanded(child: _infoGrid('EMAIL', opd.email ?? '-')),
            ]),
          ],
        )),
        // Bidang & Kuota Tersedia
        _section(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.account_tree_outlined, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text('Bidang & Kuota Tersedia', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.ink)),
              ],
            ),
            const SizedBox(height: 14),
            _bidangKuotaGrid(context),
          ],
        )),
        // Ringkasan
        _section(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ringkasan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.ink)),
                FilledButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PendaftaranPage(selectedOpd: opd))),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Daftar', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _ringkasanRow('Peserta Aktif / Kuota', '${opd.pesertaAktif} / ${opd.kuota}'),
            const Divider(height: 20),
            _ringkasanRow('Pendaftar', '${opd.pendaftar}'),
            const Divider(height: 20),
            _ringkasanRow('Mentor', '${opd.mentor}'),
          ],
        )),
        // Testimoni
        _section(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.chat_bubble_outline, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Testimoni Alumni Magang', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.ink)),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
              child: const Column(
                children: [
                  Icon(Icons.help_outline, size: 40, color: Color(0xFFCBD5E1)),
                  SizedBox(height: 10),
                  Text('Belum ada testimoni dari alumni\nmagang untuk instansi ini.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.grey, fontSize: 13)),
                ],
              ),
            ),
          ],
        )),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text('© 2026 • Dinas Komunikasi, Informatika, dan Statistik\n(Diskominfotik) Provinsi Lampung', textAlign: TextAlign.center, style: TextStyle(color: AppColors.grey, fontSize: 11)),
        ),
      ],
    ),
  );

  // ── Bidang & Kuota grid ────────────────────────────────────────────────────
  Widget _bidangKuotaGrid(BuildContext context) {
    // Gunakan bidangs dari API jika ada, fallback ke kDaftarBidang
    final items = opd.bidangs.isNotEmpty
        ? opd.bidangs
        : kDaftarBidang.map((name) => OpdBidangModel(id: 0, name: name, kuota: 5, pesertaAktif: 0, sisa: 5, isFull: false, status: 'tersedia')).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.25,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _bidangKuotaCard(items[i]),
    );
  }

  Widget _bidangKuotaCard(OpdBidangModel b) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(b.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: AppColors.ink), maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: b.isFull ? const Color(0xFFFEF2F2) : const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                b.isFull ? 'Penuh' : 'Tersedia',
                style: TextStyle(color: b.isFull ? AppColors.error : const Color(0xFF065F46), fontSize: 9, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const Divider(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _kuotaInfo('Terisi', '${b.pesertaAktif}'),
            _kuotaInfo('Kuota', '${b.kuota}'),
            _kuotaInfo('Sisa', '${b.sisa}'),
          ],
        ),
      ],
    ),
  );

  Widget _kuotaInfo(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 9)),
      Text(value, style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700, fontSize: 11)),
    ],
  );

  Widget _section({required Widget child}) => Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
    child: child,
  );

  Widget _sectionBorder({required IconData icon, required String title, required String content}) => Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 4, height: 50, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [Icon(icon, color: AppColors.primary, size: 18), const SizedBox(width: 6), Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink))]),
              const SizedBox(height: 6),
              Text(content, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _infoItem(IconData icon, String title, String value) => Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
    child: Row(
      children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.primary, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
        ])),
      ],
    ),
  );

  Widget _infoGrid(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700, fontSize: 13)),
    ],
  );

  Widget _ringkasanRow(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
      Text(value, style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700, fontSize: 13)),
    ],
  );
}
