import 'package:flutter/material.dart';
import '../ds.dart';
import 'detail_nilai_screen.dart';
import 'sertifikat_belum_tersedia_screen.dart';
import '../repository/nilai_repository.dart';

class NilaiSertifikatScreen extends StatefulWidget {
  const NilaiSertifikatScreen({super.key, required this.repository});
  final NilaiRepository repository;
  @override
  State<NilaiSertifikatScreen> createState() => _State();
}

class _State extends State<NilaiSertifikatScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  bool _komentarExpanded = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBg,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(kPadH, 16, kPadH, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: kSpaceSection),
                _progressCard(),
                const SizedBox(height: 16),
                _infoConnectionCard(),
                const SizedBox(height: kSpaceSection),
                _segmentedTab(),
                const SizedBox(height: kSpaceSection),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: _tab.index == 0
                      ? KeyedSubtree(
                          key: const ValueKey('nilai'),
                          child: _nilaiCard(),
                        )
                      : KeyedSubtree(
                          key: const ValueKey('sertifikat'),
                          child: _sertifikatCard(),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _header() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [kBlue, kBlueDark]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x332563EB), blurRadius: 14, offset: Offset(0, 7))],
        ),
        child: const Icon(Icons.workspace_premium_rounded, color: kWhite, size: 24),
      ),
      const SizedBox(width: 13),
      const Expanded(
        child: Padding(
          padding: EdgeInsets.only(top: 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text('Nilai & Sertifikat', style: kStyleTitle),
              ),
              SizedBox(height: 3),
              Text('Perkembangan akhir magang Anda', style: kStyleSubtitle),
            ],
          ),
        ),
      ),
    ],
  );

  // ── Progress Card ──────────────────────────────────────────────────────────
  Widget _progressCard() {
    const progress = 0.85;
    return Container(
        decoration: kCardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress Penyelesaian Magang',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kInk,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Hampir selesai! Sertifikat sedang diproses.',
                      style: kStyleCaption,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0EAFF),
                  borderRadius: BorderRadius.circular(kRadiusChip),
                ),
                child: const Text(
                  '85%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: kBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: kBlueMid,
              color: kBlue,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _stepItem(
                Icons.check_circle_rounded,
                'Presensi',
                'Selesai',
                true,
              ),
              _stepDivider(true),
              _stepItem(Icons.check_circle_rounded, 'Logbook', 'Selesai', true),
              _stepDivider(true),
              _stepItem(
                Icons.check_circle_rounded,
                'Penilaian',
                'Selesai',
                true,
              ),
              _stepDivider(false),
              _stepItem(
                Icons.radio_button_unchecked,
                'Sertifikat',
                'Proses',
                false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepItem(IconData icon, String label, String sub, bool done) =>
      Expanded(
        child: Column(
          children: [
            Icon(icon, color: done ? kGreen : kGrayLight, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: done ? kInk : kGrayLight,
              ),
            ),
            Text(
              sub,
              style: TextStyle(fontSize: 9, color: done ? kGreen : kGrayLight),
            ),
          ],
        ),
      );

  Widget _stepDivider(bool done) => Expanded(
    child: Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 24),
      color: done ? kGreen : kBorder,
    ),
  );

  Widget _infoConnectionCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFEFF6FF),
      borderRadius: BorderRadius.circular(kRadiusCard),
      border: Border.all(color: const Color(0xFFD1E5FF)),
    ),
    child: Row(
      children: const [
        Icon(Icons.link_rounded, color: kBlue, size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'Nilai dan sertifikat ini dihitung berdasarkan logbook Anda. Pastikan semua aktivitas telah dikirim dengan lengkap.',
            style: TextStyle(fontSize: 13, color: kInkMid, height: 1.5),
          ),
        ),
      ],
    ),
  );

  // ── Segmented Tab ──────────────────────────────────────────────────────────
  Widget _segmentedTab() => Container(
    height: 48,
    decoration: BoxDecoration(
      color: kBlueMid,
      borderRadius: BorderRadius.circular(kRadiusChip),
    ),
    padding: const EdgeInsets.all(4),
    child: Row(children: [_tabItem('Nilai', 0), _tabItem('Sertifikat', 1)]),
  );

  Widget _tabItem(String label, int index) {
    final active = _tab.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab.index = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: active ? kBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: active ? kWhite : kBlue,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Card Nilai ─────────────────────────────────────────────────────────────
  Widget _nilaiCard() => Container(
    decoration: kCardDecoration,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header status
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: kGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: kWhite,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Penilaian',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: kInk,
                      ),
                    ),
                    SizedBox(height: 4),
                    _Badge(
                      label: 'Disetujui',
                      color: kGreenLight,
                      textColor: kGreen,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: kBlueLight,
                  borderRadius: BorderRadius.circular(kRadiusChip),
                ),
                child: const Text(
                  'A+',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: kBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: kBorder),
        // Nilai + reviewer
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nilai Akhir', style: kStyleLabel),
                  const SizedBox(height: 2),
                  const Text(
                    '92',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      color: kBlue,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: kBlueLight,
                      borderRadius: BorderRadius.circular(kRadiusChip),
                    ),
                    child: const Text(
                      'Sangat Baik',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: kBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _infoRow(
                      Icons.person_outline_rounded,
                      'Reviewer',
                      'Admin OPD',
                    ),
                    const SizedBox(height: 12),
                    _infoRow(
                      Icons.business_outlined,
                      'Instansi',
                      'Diskominfotik\nProvinsi Lampung',
                    ),
                    const SizedBox(height: 12),
                    _infoRow(
                      Icons.calendar_today_outlined,
                      'Tanggal Review',
                      '12 Juli 2026',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: kBorder),
        // Komentar preview
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.format_quote_rounded,
                    color: kBlue,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text('Komentar Reviewer', style: kStyleLabel),
                  const Spacer(),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _komentarExpanded = !_komentarExpanded),
                    child: Text(
                      _komentarExpanded ? 'Sembunyikan' : 'Lihat Selengkapnya',
                      style: const TextStyle(
                        fontSize: 12,
                        color: kBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorder),
                ),
                child: Text(
                  '"Peserta mampu menyelesaikan seluruh aktivitas magang dengan sangat baik. Terus tingkatkan kinerja dan semangat belajar."',
                  style: kStyleBody,
                  maxLines: _komentarExpanded ? null : 2,
                  overflow: _komentarExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // CTA
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DetailNilaiScreen()),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: kBlue,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kRadiusBtn),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Lihat Detail Nilai',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _infoRow(IconData icon, String label, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: kBlueLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: kBlue, size: 16),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: kStyleLabel),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: kInk,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  // ── Card Sertifikat ────────────────────────────────────────────────────────
  Widget _sertifikatCard() => Container(
    decoration: BoxDecoration(
      color: kWhite,
      borderRadius: BorderRadius.circular(kRadiusCard),
      border: Border.all(color: const Color(0xFFFDE68A)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x06000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: kOrange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  color: kWhite,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Sertifikat',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: kInk,
                      ),
                    ),
                    SizedBox(height: 4),
                    _Badge(
                      label: 'Menunggu Penerbitan',
                      color: kOrangeLight,
                      textColor: kOrange,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.hourglass_empty_rounded,
                color: kOrange,
                size: 20,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kOrangeLight,
              borderRadius: BorderRadius.circular(12),
              border: const Border(left: BorderSide(color: kOrange, width: 3)),
            ),
            child: const Text(
              'Sertifikat akan tersedia setelah seluruh proses administrasi selesai.',
              style: TextStyle(fontSize: 13, color: kInkMid, height: 1.5),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: _certificateMeta(
                  Icons.schedule_rounded,
                  'Estimasi selesai',
                  '3–7 Hari Kerja',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _certificateMeta(
                  Icons.notifications_active_outlined,
                  'Notifikasi',
                  'Otomatis',
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SertifikatBelumTersediaScreen(
                  repository: widget.repository,
                ),
              ),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: kBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kRadiusBtn),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timeline_rounded, color: kWhite, size: 18),
                SizedBox(width: 8),
                Text(
                  'Lihat Status Sertifikat',
                  style: TextStyle(
                    color: kWhite,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _certificateMeta(IconData icon, String label, String value) =>
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: kBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: kBlue, size: 16),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: kStyleLabel),
                  Text(
                    value,
                    style: const TextStyle(
                      color: kInk,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  const _Badge({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(kRadiusChip),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    ),
  );
}
