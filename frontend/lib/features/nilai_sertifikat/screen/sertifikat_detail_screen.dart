import 'package:flutter/material.dart';
import '../model/sertifikat_model.dart';
import 'notification_screen.dart';

const _blue = Color(0xFF0757D8);
const _ink = Color(0xFF10213A);
const _green = Color(0xFF22A45D);
const _bg = Color(0xFFF7F9FC);
const _border = Color(0xFFE7ECF5);
const _sub = Color(0xFF667085);

class SertifikatDetailScreen extends StatefulWidget {
  const SertifikatDetailScreen({super.key, this.sertifikat});
  final SertifikatModel? sertifikat;

  @override
  State<SertifikatDetailScreen> createState() => _SertifikatDetailScreenState();
}

class _SertifikatDetailScreenState extends State<SertifikatDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sertifikat =
        widget.sertifikat ??
        const SertifikatModel(
          tersedia: true,
          nama: 'Magang Diskominfotik Provinsi Lampung',
          nomor: '0001/KP/DISKOMINFO/2026',
          tanggalTerbit: '20 Juli 2026',
          penerbit: 'Diskominfotik Provinsi Lampung',
        );
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _ink,
            size: 18,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Sertifikat',
          style: TextStyle(
            color: _ink,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              ),
              icon: const Icon(Icons.notifications_outlined, color: _ink),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBanner(sertifikat),
              const SizedBox(height: 20),
              _buildPreview(context),
              const SizedBox(height: 20),
              _buildInfoCard(sertifikat),
              const SizedBox(height: 24),
              _buildButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  // ── Banner ─────────────────────────────────────────────────────────────────

  Widget _buildBanner(SertifikatModel s) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A7A4A), Color(0xFF22A45D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2522A45D),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sertifikat Telah Terbit',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Sertifikat telah diterbitkan oleh Admin OPD.',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
            ),
            child: const Text(
              'Aktif',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Preview Sertifikat ─────────────────────────────────────────────────────

  Widget _buildPreview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preview Sertifikat',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _showFullscreen(context),
          child: Hero(
            tag: 'sertifikat_preview',
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    // Header sertifikat
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5EEFF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.account_balance_rounded,
                              color: _blue,
                              size: 22,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: const [
                              Text(
                                'No. 0001/KP/DISKOMINFO/2026',
                                style: TextStyle(fontSize: 9, color: _sub),
                              ),
                              Text(
                                'Diskominfotik Prov. Lampung',
                                style: TextStyle(fontSize: 9, color: _sub),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Judul
                    const Text(
                      'SERTIFIKAT',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: _blue,
                        letterSpacing: 4,
                      ),
                    ),
                    const Text(
                      'MAGANG',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 60,
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_blue, Color(0xFF3B82F6)],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Diberikan kepada:',
                      style: TextStyle(fontSize: 12, color: _sub),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Hikmah Nur Aulia',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Universitas Teknokrat Indonesia',
                      style: TextStyle(fontSize: 12, color: _ink),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Program Studi Informatika',
                      style: TextStyle(fontSize: 11, color: _sub),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9FC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _border),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _CertStat(label: 'Periode', value: 'Jan – Jul 2026'),
                          _CertDivider(),
                          _CertStat(label: 'Nilai', value: '92 / A+'),
                          _CertDivider(),
                          _CertStat(label: 'Predikat', value: 'Sangat Baik'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Diterbitkan oleh',
                                style: TextStyle(fontSize: 10, color: _sub),
                              ),
                              const Text(
                                'Diskominfotik Prov. Lampung',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _ink,
                                ),
                              ),
                              const Text(
                                '20 Juli 2026',
                                style: TextStyle(fontSize: 10, color: _sub),
                              ),
                            ],
                          ),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5EEFF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.qr_code_2_rounded,
                              color: _blue,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Tap hint
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      color: const Color(0xFFE5EEFF),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.zoom_out_map_rounded,
                            color: _blue,
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Ketuk untuk melihat penuh',
                            style: TextStyle(
                              fontSize: 11,
                              color: _blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Info Card ──────────────────────────────────────────────────────────────

  Widget _buildInfoCard(SertifikatModel s) {
    final rows = [
      {
        'icon': Icons.workspace_premium_outlined,
        'label': 'Nama Sertifikat',
        'value': s.nama,
      },
      {
        'icon': Icons.tag_rounded,
        'label': 'Nomor Sertifikat',
        'value': s.nomor,
      },
      {
        'icon': Icons.description_outlined,
        'label': 'Template',
        'value': 'Sertifikat Kominfo 2026',
      },
      {
        'icon': Icons.calendar_today_outlined,
        'label': 'Tanggal Terbit',
        'value': s.tanggalTerbit.isNotEmpty ? s.tanggalTerbit : '-',
      },
      {
        'icon': Icons.account_balance_outlined,
        'label': 'Diterbitkan Oleh',
        'value': s.penerbit,
      },
      {
        'icon': Icons.verified_outlined,
        'label': 'Status',
        'value': 'Aktif & Terverifikasi',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informasi Sertifikat',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: List.generate(rows.length, (i) {
              final r = rows[i];
              final isStatus = r['label'] == 'Status';
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5EEFF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            r['icon'] as IconData,
                            color: _blue,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r['label'] as String,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _sub,
                                ),
                              ),
                              Text(
                                r['value'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: _ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isStatus)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F4EA),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '✓ Aktif',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _green,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (i < rows.length - 1)
                    const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: _border,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  // ── Buttons ────────────────────────────────────────────────────────────────

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showFullscreen(context),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _blue, width: 1.5),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.zoom_out_map_rounded, color: _blue, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Preview Penuh',
                      style: TextStyle(
                        color: _blue,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Material(
            color: _blue,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text('Download PDF berhasil dimulai!'),
                    ],
                  ),
                  backgroundColor: _green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              ),
              child: const SizedBox(
                height: 52,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.download_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Download PDF',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Fullscreen Preview ─────────────────────────────────────────────────────

  void _showFullscreen(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Hero(
          tag: 'sertifikat_preview',
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Preview Sertifikat',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: _ink,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: _ink),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: _border),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF0F4FF), Color(0xFFEEF2FB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _border),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.account_balance_rounded,
                          color: _blue,
                          size: 40,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'SERTIFIKAT',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: _blue,
                            letterSpacing: 4,
                          ),
                        ),
                        const Text(
                          'MAGANG',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(width: 60, height: 3, color: _blue),
                        const SizedBox(height: 20),
                        const Text(
                          'Diberikan kepada:',
                          style: TextStyle(fontSize: 13, color: _sub),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Hikmah Nur Aulia',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: _blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Universitas Teknokrat Indonesia',
                          style: TextStyle(fontSize: 13, color: _ink),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Diskominfotik Provinsi Lampung',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                        const Text(
                          '20 Juli 2026',
                          style: TextStyle(fontSize: 12, color: _sub),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Material(
                    color: _blue,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.of(context).pop(),
                      child: const SizedBox(
                        height: 46,
                        child: Center(
                          child: Text(
                            'Tutup',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Cert Stat ──────────────────────────────────────────────────────────────────

class _CertStat extends StatelessWidget {
  final String label;
  final String value;
  const _CertStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: _sub)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
      ],
    );
  }
}

class _CertDivider extends StatelessWidget {
  const _CertDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 28, color: _border);
  }
}
