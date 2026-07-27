import 'package:flutter/material.dart';
import '../ds.dart';
import 'notification_screen.dart';

class DetailNilaiScreen extends StatelessWidget {
  const DetailNilaiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        surfaceTintColor: kWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: kInk),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Detail Nilai',
            style: TextStyle(
                color: kInk, fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              ),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: kBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kBorder)),
                child: const Icon(Icons.notifications_outlined,
                    color: kInk, size: 18),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(kPadH, 20, kPadH, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statusHeader(),
            const SizedBox(height: 20),
            _nilaiCard(),
            const SizedBox(height: 16),
            _infoCard(),
            const SizedBox(height: 20),
            _komentarSection(),
            const SizedBox(height: 20),
            _checklistSection(),
          ],
        ),
      ),
    );
  }

  // ── Status header ──────────────────────────────────────────────────────────
  Widget _statusHeader() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: kCardDecoration,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                  color: kGreen, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded,
                  color: kWhite, size: 28),
            ),
            const SizedBox(height: 12),
            const Text('Disetujui',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: kGreen)),
            const SizedBox(height: 4),
            const Text('Penilaian telah disetujui oleh Admin OPD.',
                style: kStyleCaption, textAlign: TextAlign.center),
          ],
        ),
      );

  // ── Nilai card ─────────────────────────────────────────────────────────────
  Widget _nilaiCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: kCardDecoration,
        child: Column(
          children: [
            const Text('NILAI AKHIR',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: kGray,
                    letterSpacing: 1.5)),
            const SizedBox(height: 8),
            const Text('92',
                style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: kBlue,
                    height: 1)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: kBlue,
                    borderRadius: BorderRadius.circular(kRadiusChip),
                  ),
                  child: const Text('Sangat Baik',
                      style: TextStyle(
                          color: kWhite,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: kBlueLight,
                    borderRadius: BorderRadius.circular(kRadiusChip),
                  ),
                  child: const Text('Grade A+',
                      style: TextStyle(
                          color: kBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      );

  // ── Info card ──────────────────────────────────────────────────────────────
  Widget _infoCard() => Container(
        decoration: kCardDecoration,
        child: Column(
          children: [
            _infoRow(Icons.person_outline_rounded, 'Reviewer', 'Admin OPD',
                'Diskominfotik Provinsi Lampung'),
            const Divider(height: 1, color: kBorder),
            _infoRow(Icons.calendar_today_outlined, 'Tanggal Review',
                '12 Juli 2026', '10.30 WIB'),
            const Divider(height: 1, color: kBorder),
            _infoRow(Icons.assignment_outlined, 'Metode Penilaian',
                'Penilaian Magang', ''),
          ],
        ),
      );

  Widget _infoRow(
          IconData icon, String label, String value, String sub) =>
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: kBlueLight,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: kBlue, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: kStyleLabel),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: kInk)),
                  if (sub.isNotEmpty)
                    Text(sub, style: kStyleCaption),
                ],
              ),
            ),
          ],
        ),
      );

  // ── Komentar section ───────────────────────────────────────────────────────
  Widget _komentarSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Komentar Reviewer',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: kInk)),
          const SizedBox(height: 12),
          _komentarCard(
            name: 'Admin OPD (Internal)',
            jabatan: 'Diskominfotik Provinsi Lampung',
            komentar:
                '"Peserta mampu menyelesaikan seluruh aktivitas magang dengan sangat baik. Terus tingkatkan kinerja dan semangat belajar."',
          ),
          const SizedBox(height: 10),
          _komentarCard(
            name: 'Pembimbing Lapangan',
            jabatan: 'Supervisor Teknis',
            komentar:
                '"Mahasiswa aktif, disiplin, serta mampu menyelesaikan tugas dengan sangat baik dan tepat waktu."',
          ),
        ],
      );

  Widget _komentarCard(
          {required String name,
          required String jabatan,
          required String komentar}) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kBg,
          borderRadius: BorderRadius.circular(kRadiusCard),
          border: Border.all(color: kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: kBlueMid, shape: BoxShape.circle),
                  child: const Icon(Icons.person_rounded,
                      color: kBlue, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: kInk)),
                      Text(jabatan, style: kStyleCaption),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(komentar, style: kStyleBody),
          ],
        ),
      );

  // ── Checklist section ──────────────────────────────────────────────────────
  Widget _checklistSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Checklist Penilaian',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: kInk)),
          const SizedBox(height: 12),
          Container(
            decoration: kCardDecoration,
            child: Column(
              children: [
                _checkItem('Presensi'),
                const Divider(height: 1, color: kBorder),
                _checkItem('Logbook'),
                const Divider(height: 1, color: kBorder),
                _checkItem('Kinerja / Sikap'),
                const Divider(height: 1, color: kBorder),
                _checkItem('Kompetensi'),
              ],
            ),
          ),
        ],
      );

  Widget _checkItem(String label) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                  color: kGreen, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded,
                  color: kWhite, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: kInk)),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: kGreenLight,
                  borderRadius: BorderRadius.circular(kRadiusChip)),
              child: const Text('Sesuai',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: kGreen)),
            ),
          ],
        ),
      );
}
