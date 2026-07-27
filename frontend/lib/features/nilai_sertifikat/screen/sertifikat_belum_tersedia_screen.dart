import 'package:flutter/material.dart';
import '../ds.dart';
import 'notification_screen.dart';
import 'sertifikat_detail_screen.dart';
import '../repository/nilai_repository.dart';

class SertifikatBelumTersediaScreen extends StatelessWidget {
  const SertifikatBelumTersediaScreen({super.key, required this.repository});
  final NilaiRepository repository;

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
        title: const Text('Sertifikat',
            style: TextStyle(
                color: kInk, fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: false,
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
        padding: const EdgeInsets.fromLTRB(kPadH, 24, kPadH, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _illustration(),
            const SizedBox(height: 28),
            const Text('Sertifikat Sedang Diproses',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: kInk),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text(
              'Sertifikat akan tersedia setelah seluruh\nproses administrasi selesai.',
              style: kStyleSubtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _timelineCard(),
            const SizedBox(height: 16),
            _estimasiCard(),
            const SizedBox(height: 16),
            _notifCard(),
            const SizedBox(height: 24),
            _refreshButton(context),
          ],
        ),
      ),
    );
  }

  // ── Ilustrasi ──────────────────────────────────────────────────────────────
  Widget _illustration() => Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: kBlueMid,
          borderRadius: BorderRadius.circular(kRadiusCard),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Sertifikat mock
            Positioned(
              left: 32,
              top: 24,
              child: Container(
                width: 150,
                height: 110,
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x18000000),
                        blurRadius: 12,
                        offset: Offset(0, 4))
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('SERTIFIKAT',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: kBlue,
                            letterSpacing: 2)),
                    const SizedBox(height: 8),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                          color: kBlueLight, shape: BoxShape.circle),
                      child: const Icon(Icons.workspace_premium_rounded,
                          color: kBlue, size: 20),
                    ),
                    const SizedBox(height: 8),
                    Container(
                        width: 70,
                        height: 3,
                        decoration: BoxDecoration(
                            color: kBorder,
                            borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 4),
                    Container(
                        width: 50,
                        height: 3,
                        decoration: BoxDecoration(
                            color: kBorder,
                            borderRadius: BorderRadius.circular(2))),
                  ],
                ),
              ),
            ),
            // Hourglass badge
            Positioned(
              right: 36,
              bottom: 20,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: kOrangeLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: kOrange, width: 2),
                ),
                child: const Icon(Icons.hourglass_bottom_rounded,
                    color: kOrange, size: 28),
              ),
            ),
            // Label
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kOrangeLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Belum Tersedia',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: kOrange)),
              ),
            ),
          ],
        ),
      );

  // ── Timeline card ──────────────────────────────────────────────────────────
  Widget _timelineCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: kCardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Proses yang Sedang Berjalan',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: kInk)),
            const SizedBox(height: 20),
            _timelineItem(
              icon: Icons.check_circle_rounded,
              iconColor: kGreen,
              bgColor: kGreenLight,
              title: 'Penilaian Disetujui',
              sub: '12 Juli 2026',
              isDone: true,
              isLast: false,
            ),
            _timelineItem(
              icon: Icons.radio_button_checked,
              iconColor: kBlue,
              bgColor: kBlueLight,
              title: 'Validasi Admin',
              sub: 'Oleh Admin OPD',
              badge: 'Sedang Diproses',
              isActive: true,
              isDone: false,
              isLast: false,
            ),
            _timelineItem(
              icon: Icons.radio_button_unchecked,
              iconColor: kGrayLight,
              bgColor: const Color(0xFFF1F5F9),
              title: 'Generate Sertifikat',
              sub: 'Menunggu validasi',
              isDone: false,
              isLast: false,
            ),
            _timelineItem(
              icon: Icons.radio_button_unchecked,
              iconColor: kGrayLight,
              bgColor: const Color(0xFFF1F5F9),
              title: 'Sertifikat Terbit',
              sub: 'Akan segera tersedia',
              isDone: false,
              isLast: true,
            ),
          ],
        ),
      );

  Widget _timelineItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String sub,
    String? badge,
    bool isActive = false,
    required bool isDone,
    required bool isLast,
  }) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration:
                    BoxDecoration(color: bgColor, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              if (!isLast)
                Container(
                    width: 2,
                    height: 40,
                    color: isDone ? kGreen : kBorder),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: isActive
                              ? kBlue
                              : (isDone ? kInk : kGrayLight))),
                  const SizedBox(height: 2),
                  Text(sub,
                      style: TextStyle(
                          fontSize: 12,
                          color: isDone ? kGray : kGrayLight)),
                  if (badge != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: kBlueLight,
                          borderRadius:
                              BorderRadius.circular(kRadiusChip)),
                      child: Text(badge,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: kBlue)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      );

  // ── Estimasi card ──────────────────────────────────────────────────────────
  Widget _estimasiCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kBlueLight,
          borderRadius: BorderRadius.circular(kRadiusCard),
          border: Border.all(color: kBlueMid),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: kBlueMid,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.schedule_rounded,
                  color: kBlue, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Estimasi Selesai',
                      style: TextStyle(
                          fontSize: 12,
                          color: kBlue,
                          fontWeight: FontWeight.w600)),
                  Text('3–7 hari kerja',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: kBlueDark)),
                ],
              ),
            ),
          ],
        ),
      );

  // ── Notif card ─────────────────────────────────────────────────────────────
  Widget _notifCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kGreenLight,
          borderRadius: BorderRadius.circular(kRadiusCard),
          border: Border.all(color: const Color(0xFFBBF7D0)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: kGreen,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.notifications_active_rounded,
                  color: kWhite, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Anda akan menerima notifikasi otomatis ketika sertifikat berhasil diterbitkan.',
                style: TextStyle(
                    fontSize: 13, color: kGreen, height: 1.5),
              ),
            ),
          ],
        ),
      );

  // ── Refresh button ─────────────────────────────────────────────────────────
  Widget _refreshButton(BuildContext context) => OutlinedButton(
        onPressed: () async {
          try {
            final sertifikat = await repository.latestSertifikat();
            if (!context.mounted) return;
            if (sertifikat != null) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (_) => SertifikatDetailScreen(sertifikat: sertifikat)),
              );
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sertifikat masih dalam proses penerbitan.')),
            );
          } catch (_) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Status sertifikat tidak dapat diperbarui.')),
            );
          }
        },
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: kBlue),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kRadiusBtn)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh_rounded, color: kBlue, size: 20),
            SizedBox(width: 8),
            Text('Perbarui Status',
                style: TextStyle(
                    color: kBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
          ],
        ),
      );
}
