import 'package:flutter/material.dart';

import '../../dashboard/model/participant_dashboard.dart';
import '../../dashboard/repository/dashboard_repository.dart';
import '../../dashboard/repository/registration_status_repository.dart';
import '../../dashboard/service/registration_status_service.dart';
import '../../dashboard/widget/registration_status_card.dart';
import '../../presensi/repository/presensi_repository.dart';

const _primary = Color(0xFF2457D6);
const _ink = Color(0xFF172033);

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.presensiRepository,
    required this.dashboardRepository,
    required this.registrationStatusRepository,
  });
  final PresensiRepository presensiRepository;
  final DashboardRepository dashboardRepository;
  final RegistrationStatusRepository registrationStatusRepository;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late Future<ParticipantDashboard> _future;
  late Future<RegistrationStatus> _statusFuture;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _statusFuture = widget.registrationStatusRepository.getStatus();
  }

  Future<ParticipantDashboard> _load() => widget.dashboardRepository.getDashboard();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: FutureBuilder<ParticipantDashboard>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) return _error();
              return _content(snapshot.requireData);
            },
          ),
        ),
        bottomNavigationBar: _bottomNavigation(),
      );

  Widget _content(ParticipantDashboard data) {
    final today = DateTime.now();
    // TODO: Ambil tanggal mulai/selesai dari respons profil peserta ketika
    // struktur data magang final tersedia pada endpoint dashboard.
    final progress = _InternshipProgress.fromDates(
      DateTime(2026, 6, 1),
      DateTime(2026, 8, 31),
      today,
    );
    return RefreshIndicator(
      onRefresh: () async => setState(() {
        _future = _load();
        _statusFuture = widget.registrationStatusRepository.getStatus();
      }),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(15, 8, 15, 24),
        children: [
          FutureBuilder<RegistrationStatus>(
            future: _statusFuture,
            builder: (context, snap) {
              if (!snap.hasData) return const SizedBox.shrink();
              return RegistrationStatusCard(status: snap.requireData);
            },
          ),
          Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset('lib/auth/screen/asset/logo.png', width: 32, height: 32, fit: BoxFit.cover),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Ruwa Magang', style: TextStyle(fontWeight: FontWeight.w700)), Text(_date(today), style: const TextStyle(fontSize: 10, color: Color(0xFF667085)))])),
            GestureDetector(
              onTap: () => _go('/profil'),
              child: const CircleAvatar(radius: 16, backgroundColor: Color(0xFFD6E4FF), child: Text('P', style: TextStyle(color: _primary, fontWeight: FontWeight.w700))),
            ),
          ]),
          const SizedBox(height: 26),
          const Text('Dashboard Peserta', style: TextStyle(color: _ink, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          const Text('Selamat datang kembali di panel monitoring Anda.', style: TextStyle(color: Color(0xFF667085), fontSize: 13)),
          const SizedBox(height: 25),
          Row(children: [
            _statCard(icon: Icons.book_outlined, label: 'LOGBOOK', value: '${data.logbookCount}', detail: 'Hari ini / total', tint: const Color(0xFFEAE8FF), onTap: () => _go('/logbook')),
            const SizedBox(width: 12),
            _statCard(icon: Icons.check_circle_outline, label: 'PRESENSI', value: data.hasPresensiToday ? '1' : '0', detail: 'Kehadiran', tint: const Color(0xFFD7F9E9), onTap: () => _go('/presensi')),
            const SizedBox(width: 12),
            _statCard(icon: Icons.workspace_premium_outlined, label: 'SERTIFIKAT', value: '0', detail: 'Diterbitkan', tint: const Color(0xFFFFEAD5), onTap: () => _go('/nilai-sertifikat')),
          ]),
          const SizedBox(height: 26),
          _progressCard(progress),
          const SizedBox(height: 26),
          const Text('Aktivitas Terbaru', style: TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          _activity(icon: Icons.visibility_outlined, title: 'Presensi', subtitle: 'Catat kehadiran harian Anda', color: const Color(0xFFEAE8FF), action: Icons.login_rounded, onTap: () => _go('/presensi')),
          const SizedBox(height: 12),
          _activity(icon: Icons.edit_note_outlined, title: 'Input Logbook', subtitle: 'Lengkapi aktivitas harian Anda', color: const Color(0xFFE8F6F0), action: Icons.add, onTap: () => _go('/logbook')),
        ],
      ),
    );
  }

  Widget _error() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('Dashboard belum dapat dimuat.'), const SizedBox(height: 8), FilledButton.icon(onPressed: () => setState(() => _future = _load()), icon: const Icon(Icons.refresh), label: const Text('Coba lagi'))]));

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required String detail,
    required Color tint,
    required VoidCallback onTap,
  }) => Expanded(
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EF)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(9)),
                child: Icon(icon, size: 18, color: _primary),
              ),
              const Spacer(),
              Text(label, style: const TextStyle(fontSize: 8, color: Color(0xFF667085))),
              Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
              Text(detail, style: const TextStyle(fontSize: 8, color: Color(0xFF667085))),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _progressCard(_InternshipProgress progress) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE5E7EF)), borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Kemajuan Magang', style: TextStyle(fontWeight: FontWeight.w800, color: _ink)), SizedBox(height: 4), Text('Berdasarkan durasi kontrak', style: TextStyle(fontSize: 10, color: Color(0xFF667085)))])), Text('${progress.percent}%', style: const TextStyle(fontSize: 23, color: _primary)),]), const SizedBox(height: 19), ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress.value, minHeight: 9, backgroundColor: const Color(0xFFE8EDFA), color: _primary)), const SizedBox(height: 17), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9), decoration: BoxDecoration(color: const Color(0xFFF4F6FF), borderRadius: BorderRadius.circular(10)), child: Row(children: [const Icon(Icons.calendar_today_outlined, size: 14, color: _primary), const SizedBox(width: 6), Expanded(child: Text('Minggu ${progress.week} dari ${progress.totalWeeks}', style: const TextStyle(fontSize: 10, color: Color(0xFF475467)))), Text('${progress.remainingDays} Hari Lagi', style: const TextStyle(fontSize: 10, color: _primary, fontWeight: FontWeight.w700)), const Icon(Icons.arrow_forward, size: 15, color: _primary)]))]));

  Widget _activity({required IconData icon, required String title, required String subtitle, required Color color, required IconData action, required VoidCallback onTap}) => Material(color: Colors.white, borderRadius: BorderRadius.circular(14), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EF)), borderRadius: BorderRadius.circular(14)), child: Row(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: _primary)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)), Text(subtitle, style: const TextStyle(color: Color(0xFF667085), fontSize: 10))])), Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(10)), child: Icon(action, color: Colors.white, size: 18))]))));

  Widget _bottomNavigation() => NavigationBar(selectedIndex: 0, indicatorColor: const Color(0xFFD6E4FF), onDestinationSelected: (index) { const routes = ['/dashboard', '/daftar', '/logbook', '/nilai-sertifikat', '/profil']; _go(routes[index]); }, destinations: const [NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Beranda'), NavigationDestination(icon: Icon(Icons.assignment_outlined), label: 'Daftar'), NavigationDestination(icon: Icon(Icons.book_outlined), label: 'Logbook'), NavigationDestination(icon: Icon(Icons.workspace_premium_outlined), label: 'Nilai & Sertif'), NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil')]);

  void _go(String route) { if (route != '/dashboard') Navigator.pushNamed(context, route); }
}

class _InternshipProgress { const _InternshipProgress(this.value, this.percent, this.week, this.totalWeeks, this.remainingDays); final double value; final int percent; final int week; final int totalWeeks; final int remainingDays; factory _InternshipProgress.fromDates(DateTime? start, DateTime? end, DateTime now) { if (start == null || end == null || end.isBefore(start)) return const _InternshipProgress(0, 0, 0, 0, 0); final total = end.difference(start).inDays + 1; final passed = now.isBefore(start) ? 0 : now.isAfter(end) ? total : now.difference(start).inDays + 1; return _InternshipProgress(passed / total, ((passed / total) * 100).round(), (passed / 7).ceil(), (total / 7).ceil(), (total - passed).clamp(0, total).toInt()); } }
String _date(DateTime date) => '${const ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'][date.weekday - 1]}, ${date.day} ${const ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'][date.month - 1]} ${date.year}';
