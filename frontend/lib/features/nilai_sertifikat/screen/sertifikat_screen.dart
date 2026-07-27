import 'package:flutter/material.dart';
import '../ds.dart';
import 'notification_screen.dart';

class SertifikatScreen extends StatelessWidget {
  const SertifikatScreen({super.key});

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
        title: const Text(
          'Sertifikat',
          style: TextStyle(
            color: kInk,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
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
                  border: Border.all(color: kBorder),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: kInk,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(kPadH, 20, kPadH, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statusBanner(),
                const SizedBox(height: 20),
                _previewSection(),
                const SizedBox(height: 20),
                _infoSection(),
                const SizedBox(height: 24),
                _actionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Status banner ──────────────────────────────────────────────────────────
  Widget _statusBanner() => Container(
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
          decoration: const BoxDecoration(
            color: kGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.verified_rounded, color: kWhite, size: 20),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sertifikat Aktif',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: kGreen,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Sudah diterbitkan oleh Admin OPD.',
                style: TextStyle(fontSize: 12, color: kGreen),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: kGreen,
            borderRadius: BorderRadius.circular(kRadiusChip),
          ),
          child: const Text(
            'Aktif & Terverifikasi',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: kWhite,
            ),
          ),
        ),
      ],
    ),
  );

  // ── Preview sertifikat ─────────────────────────────────────────────────────
  Widget _previewSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Preview Sertifikat',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: kInk,
        ),
      ),
      const SizedBox(height: 12),
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(kRadiusCard),
          border: Border.all(color: kBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Watermark
            Positioned.fill(
              child: Center(
                child: Opacity(
                  opacity: 0.04,
                  child: Text(
                    'RUWA\nMAGANG',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: kBlue,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header sertifikat
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: kBlueLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.account_balance_rounded,
                          color: kBlue,
                          size: 22,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'No. 001/CERT/2026',
                            style: TextStyle(fontSize: 10, color: kGray),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: kGreenLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Terverifikasi',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: kGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'SERTIFIKAT',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: kBlue,
                      letterSpacing: 4,
                    ),
                  ),
                  const Text(
                    'MAGANG',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kInkMid,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(width: 60, height: 2, color: kBlue),
                  const SizedBox(height: 16),
                  const Text(
                    'Diberikan kepada:',
                    style: TextStyle(fontSize: 12, color: kGray),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Hikmah Nur Aulia',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: kBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Universitas Teknokrat Indonesia',
                    style: TextStyle(fontSize: 12, color: kInkMid),
                  ),
                  const SizedBox(height: 16),
                  // QR + tanda tangan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // QR Code mock
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: kBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: kBorder),
                        ),
                        child: const Icon(
                          Icons.qr_code_2_rounded,
                          color: kInk,
                          size: 40,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(width: 80, height: 1, color: kInk),
                          const SizedBox(height: 4),
                          const Text(
                            'Admin OPD',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: kInk,
                            ),
                          ),
                          const Text(
                            'Tanda tangan elektronik sah',
                            style: TextStyle(fontSize: 9, color: kGray),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );

  // ── Info sertifikat ────────────────────────────────────────────────────────
  Widget _infoSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Informasi Sertifikat',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: kInk,
        ),
      ),
      const SizedBox(height: 12),
      Container(
        decoration: kCardDecoration,
        child: Column(
          children: [
            _infoRow(
              Icons.badge_outlined,
              'Nama Sertifikat',
              'Magang Diskominfotik\nProvinsi Lampung',
            ),
            const Divider(height: 1, color: kBorder),
            _infoRow(
              Icons.tag_rounded,
              'Nomor Sertifikat',
              '0001/KP/DISKOMINFO/2026',
            ),
            const Divider(height: 1, color: kBorder),
            _infoRow(
              Icons.date_range_outlined,
              'Periode',
              'Jan 2026 – Jul 2026',
            ),
            const Divider(height: 1, color: kBorder),
            _infoRow(
              Icons.style_outlined,
              'Template',
              'Sertifikat Kominfo 2026',
            ),
            const Divider(height: 1, color: kBorder),
            _infoRow(
              Icons.calendar_today_outlined,
              'Tanggal Terbit',
              '20 Juli 2026',
            ),
            const Divider(height: 1, color: kBorder),
            _infoRow(
              Icons.business_outlined,
              'Instansi',
              'Diskominfotik Provinsi Lampung',
            ),
            const Divider(height: 1, color: kBorder),
            _infoRow(
              Icons.verified_outlined,
              'Status',
              'Aktif & Terverifikasi',
              valueColor: kGreen,
            ),
          ],
        ),
      ),
    ],
  );

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: kBlueLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: kBlue, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: kStyleLabel),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? kInk,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ── Action buttons ─────────────────────────────────────────────────────────
  Widget _actionButtons(BuildContext context) => Row(
    children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kRadiusCard),
              ),
              title: const Text(
                'Preview Penuh',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              content: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: kBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    size: 80,
                    color: kBlue,
                  ),
                ),
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: kBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kRadiusBtn),
                    ),
                  ),
                  child: const Text('Tutup'),
                ),
              ],
            ),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            side: const BorderSide(color: kBlue),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kRadiusBtn),
            ),
          ),
          icon: const Icon(
            Icons.remove_red_eye_outlined,
            color: kBlue,
            size: 18,
          ),
          label: const Text(
            'Preview\nPenuh',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kBlue,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: FilledButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mengunduh PDF sertifikat...')),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: kBlue,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kRadiusBtn),
            ),
          ),
          icon: const Icon(Icons.download_rounded, size: 18),
          label: const Text(
            'Download\nPDF',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
      ),
    ],
  );
}
