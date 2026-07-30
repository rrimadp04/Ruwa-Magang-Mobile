import 'package:flutter/material.dart';

import '../../dashboard/model/participant_dashboard.dart';
import '../../dashboard/repository/dashboard_repository.dart';
import '../../dashboard/repository/registration_status_repository.dart';
import '../../dashboard/widget/registration_status_card.dart';
import '../../logbook/repository/logbook_repository.dart';
import '../../logbook/screen/list_logbook_screen.dart';
import '../../nilai_sertifikat/repository/nilai_repository.dart';
import '../../nilai_sertifikat/screen/nilai_sertifikat_screen.dart';
import '../../opd/pages/opd_page.dart';
import '../../presensi/repository/presensi_repository.dart';
import '../../presensi/screen/presensi_screen.dart';
import '../../profile/repository/profile_repository.dart';
import '../../profile/screen/participant_profile_screen.dart';

const _primary = Color(0xFF3F32E6);
const _ink = Color(0xFF172033);

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.dashboardRepository, required this.registrationStatusRepository, required this.logbookRepository, required this.nilaiRepository, required this.presensiRepository, required this.profileRepository});
  final DashboardRepository dashboardRepository;
  final RegistrationStatusRepository registrationStatusRepository;
  final LogbookRepository logbookRepository;
  final NilaiRepository nilaiRepository;
  final PresensiRepository presensiRepository;
  final ProfileRepository profileRepository;
  @override State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  late Future<ParticipantDashboard> _dashboardFuture;
  late Future<RegistrationStatus> _statusFuture;

  @override void initState() { super.initState(); _dashboardFuture = widget.dashboardRepository.getDashboard(); _statusFuture = widget.registrationStatusRepository.getStatus(); }

  @override Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: IndexedStack(index: _index, children: [_dashboard(), OpdPage(onRegistered: refreshStatus), ListLogbookScreen(repository: widget.logbookRepository), NilaiSertifikatScreen(repository: widget.nilaiRepository), ParticipantProfileScreen(repository: widget.profileRepository)])),
    bottomNavigationBar: NavigationBar(selectedIndex: _index, onDestinationSelected: _selectTab, indicatorColor: const Color(0xFFE4E0FF), destinations: const [NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Dashboard'), NavigationDestination(icon: Icon(Icons.assignment_outlined), label: 'Daftar'), NavigationDestination(icon: Icon(Icons.book_outlined), label: 'Logbook'), NavigationDestination(icon: Icon(Icons.workspace_premium_outlined), label: 'Nilai & Sertif'), NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil')]),
  );

  Future<void> _selectTab(int index) async {
    // Tab Logbook (2) dan Nilai & Sertif (3): hanya bisa diakses jika accepted
    if (index == 2 || index == 3) {
      final status = await _statusFuture;
      if (status != RegistrationStatus.accepted) {
        if (!mounted) return;
        final message = status == RegistrationStatus.pending
            ? 'Pendaftaran Anda masih diproses. Fitur ini tersedia setelah pendaftaran diterima.'
            : 'Silakan lengkapi pendaftaran terlebih dahulu untuk membuka fitur ini.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        setState(() => _index = 1);
        return;
      }
    }
    // Tab Daftar (1): di-lock jika sudah accepted
    if (index == 1) {
      final status = await _statusFuture;
      if (status == RegistrationStatus.accepted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pendaftaran Anda sudah diterima. Halaman pendaftaran tidak dapat diakses.')),
        );
        return;
      }
    }
    if (mounted) setState(() => _index = index);
  }

  void refreshStatus() {
    setState(() => _statusFuture = widget.registrationStatusRepository.getStatus());
  }

  Widget _dashboard() => FutureBuilder<ParticipantDashboard>(
    future: _dashboardFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
      if (snapshot.hasError) return Center(child: FilledButton.icon(onPressed: () => setState(() => _dashboardFuture = widget.dashboardRepository.getDashboard()), icon: const Icon(Icons.refresh), label: const Text('Coba lagi')));
      return _monitoring(snapshot.requireData);
    },
  );

  Widget _monitoring(ParticipantDashboard data) => FutureBuilder<RegistrationStatus>(
    future: _statusFuture,
    builder: (context, statusSnapshot) => _monitoringContent(
      data,
      statusSnapshot.data ?? RegistrationStatus.notRegistered,
    ),
  );

  Widget _monitoringContent(ParticipantDashboard data, RegistrationStatus status) {
    final today = DateTime.now();
    final progress = _Progress.fromDates(DateTime(2026, 6, 1), DateTime(2026, 8, 31), today);
    return RefreshIndicator(onRefresh: () async => setState(() => _dashboardFuture = widget.dashboardRepository.getDashboard()), child: ListView(padding: const EdgeInsets.fromLTRB(15, 8, 15, 24), children: [
      Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset('lib/auth/screen/asset/logo.png', width: 32, height: 32, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ruwa Magang', style: TextStyle(fontWeight: FontWeight.w700)),
                Text(_date(today), style: const TextStyle(fontSize: 10, color: Color(0xFF667085))),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _selectTab(4),
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFE6E2FF),
              child: Text('P', style: TextStyle(color: _primary, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
      const SizedBox(height: 26), const Text('Dashboard Peserta', style: TextStyle(color: _ink, fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 5), const Text('Selamat datang kembali di panel monitoring Anda.', style: TextStyle(color: Color(0xFF667085), fontSize: 13)), const SizedBox(height: 25),
      if (status != RegistrationStatus.accepted) ...[RegistrationStatusCard(status: status), const SizedBox(height: 8)],
      Row(children: [_stat(Icons.book_outlined, 'LOGBOOK', '${data.logbookCount}', 'Hari ini / total', const Color(0xFFEAE8FF), () => _openDashboardFeature(2)), const SizedBox(width: 12), _stat(Icons.check_circle_outline, 'PRESENSI', data.hasPresensiToday ? '1' : '0', 'Kehadiran', const Color(0xFFD7F9E9), _openPresensi), const SizedBox(width: 12), _stat(Icons.workspace_premium_outlined, 'SERTIFIKAT', '0', 'Diterbitkan', const Color(0xFFFFEAD5), () => _openDashboardFeature(3))]),
      const SizedBox(height: 26), _progress(progress), const SizedBox(height: 26), const Text('Aktivitas Terbaru', style: TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w800)), const SizedBox(height: 14), _activity(Icons.visibility_outlined, 'Presensi', 'Catat kehadiran harian Anda', const Color(0xFFEAE8FF), Icons.login_rounded, _openPresensi), const SizedBox(height: 12), _activity(Icons.edit_note_outlined, 'Input Logbook', 'Lengkapi aktivitas harian Anda', const Color(0xFFE8F6F0), Icons.add, () => _openDashboardFeature(2)),
    ]));
  }

  Widget _stat(IconData icon, String label, String value, String detail, Color tint, VoidCallback tap) => Expanded(child: Material(color: Colors.white, borderRadius: BorderRadius.circular(14), child: InkWell(onTap: tap, borderRadius: BorderRadius.circular(14), child: Container(height: 120, padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EF)), borderRadius: BorderRadius.circular(14)), child: Column(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(9)), child: Icon(icon, size: 18, color: _primary)), const Spacer(), Text(label, style: const TextStyle(fontSize: 8, color: Color(0xFF667085))), Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)), Text(detail, style: const TextStyle(fontSize: 8, color: Color(0xFF667085)))])))));
  Widget _progress(_Progress p) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE5E7EF)), borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Kemajuan Magang', style: TextStyle(fontWeight: FontWeight.w800, color: _ink)), SizedBox(height: 4), Text('Berdasarkan durasi kontrak', style: TextStyle(fontSize: 10, color: Color(0xFF667085)))])), Text('${p.percent}%', style: const TextStyle(fontSize: 23, color: _primary))]), const SizedBox(height: 19), LinearProgressIndicator(value: p.value, minHeight: 9, backgroundColor: const Color(0xFFE8EDFA), color: _primary), const SizedBox(height: 14), Text('Minggu ${p.week} dari ${p.totalWeeks} • ${p.remainingDays} Hari Lagi', style: const TextStyle(fontSize: 10, color: Color(0xFF475467)))]));
  Widget _activity(IconData icon, String title, String subtitle, Color tint, IconData action, VoidCallback tap) => Material(color: Colors.white, borderRadius: BorderRadius.circular(14), child: InkWell(onTap: tap, borderRadius: BorderRadius.circular(14), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EF)), borderRadius: BorderRadius.circular(14)), child: Row(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: _primary)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)), Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF667085)))])), Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(10)), child: Icon(action, color: Colors.white, size: 18))]))));
  void _openPresensi() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PresensiScreen(repository: widget.presensiRepository)));

  void _openDashboardFeature(int index) => setState(() => _index = index);
}

class _Progress { const _Progress(this.value, this.percent, this.week, this.totalWeeks, this.remainingDays); final double value; final int percent, week, totalWeeks, remainingDays; factory _Progress.fromDates(DateTime start, DateTime end, DateTime now) { final total = end.difference(start).inDays + 1; final passed = now.isBefore(start) ? 0 : now.isAfter(end) ? total : now.difference(start).inDays + 1; return _Progress(passed / total, ((passed / total) * 100).round(), (passed / 7).ceil(), (total / 7).ceil(), total - passed); } }
String _date(DateTime date) => '${const ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'][date.weekday - 1]}, ${date.day} ${const ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'][date.month - 1]} ${date.year}';
