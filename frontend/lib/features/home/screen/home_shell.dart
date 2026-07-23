import 'package:flutter/material.dart';

import '../../presensi/repository/presensi_repository.dart';
import '../../dashboard/pages/dashboard_page.dart';
import '../../opd/pages/opd_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.repository});
  final PresensiRepository repository;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: IndexedStack(
        index: _index,
        children: [
          DashboardPage(onNavigate: (i) => setState(() => _index = i)),
          const OpdPage(),
          _comingSoon(2, 'Logbook', Icons.edit_note_outlined),
          _comingSoon(3, 'Sertifikat', Icons.workspace_premium_outlined),
          _comingSoon(4, 'Profil', Icons.person_outline),
        ],
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (i) => setState(() => _index = i),
      height: 74,
      indicatorColor: const Color(0xFFDCE8FF),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Beranda'),
        NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'Daftar'),
        NavigationDestination(icon: Icon(Icons.edit_note_outlined), selectedIcon: Icon(Icons.edit_note), label: 'Logbook'),
        NavigationDestination(icon: Icon(Icons.workspace_premium_outlined), selectedIcon: Icon(Icons.workspace_premium), label: 'Sertifikat'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
      ],
    ),
  );

  Widget _comingSoon(int index, String title, IconData icon) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        const SizedBox(height: 18),
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF10213A))),
        const Spacer(),
        Container(
          width: 132,
          height: 132,
          decoration: const BoxDecoration(color: Color(0xFFE3EDFF), shape: BoxShape.circle),
          child: Icon(icon, size: 68, color: const Color(0xFF0757D8)),
        ),
        const SizedBox(height: 30),
        const Text('Coming Soon', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF10213A))),
        const SizedBox(height: 12),
        const Text(
          'Fitur ini sedang dalam tahap pengembangan dan akan segera tersedia.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF697386)),
        ),
        const Spacer(),
      ],
    ),
  );

}
