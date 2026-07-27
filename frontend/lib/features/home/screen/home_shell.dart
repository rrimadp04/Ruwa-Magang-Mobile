import 'package:flutter/material.dart';

import '../../presensi/repository/presensi_repository.dart';
import '../../presensi/screen/presensi_screen.dart';
import '../../nilai_sertifikat/screen/nilai_sertifikat_screen.dart';
import '../../nilai_sertifikat/repository/nilai_repository.dart';
import '../../logbook/repository/logbook_repository.dart';
import '../../logbook/screen/list_logbook_screen.dart';

const _blue = Color(0xFF0757D8);
const _ink = Color(0xFF10213A);

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.repository, required this.nilaiRepository, required this.logbookRepository});
  final PresensiRepository repository;
  final NilaiRepository nilaiRepository;
  final LogbookRepository logbookRepository;

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
          _home(),
          _comingSoon(1),
          ListLogbookScreen(repository: widget.logbookRepository),
          NilaiSertifikatScreen(repository: widget.nilaiRepository),
          _comingSoon(4),
        ],
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (index) => setState(() => _index = index),
      height: 74,
      indicatorColor: const Color(0xFFDCE8FF),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Beranda',
        ),
        NavigationDestination(
          icon: Icon(Icons.assignment_outlined),
          selectedIcon: Icon(Icons.assignment),
          label: 'Daftar',
        ),
        NavigationDestination(
          icon: Icon(Icons.edit_note_outlined),
          selectedIcon: Icon(Icons.edit_note),
          label: 'Logbook',
        ),
        NavigationDestination(
          icon: Icon(Icons.workspace_premium_outlined),
          selectedIcon: Icon(Icons.workspace_premium),
          label: 'Nilai',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    ),
  );

  Widget _home() {
    final now = DateTime.now();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 23,
              backgroundColor: Color(0xFFDDE8FF),
              child: Icon(Icons.person, color: _blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selamat datang,',
                    style: TextStyle(color: Color(0xFF667085)),
                  ),
                  const Text(
                    'Peserta Magang',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded, color: _ink),
            ),
          ],
        ),
        const SizedBox(height: 26),
        Text(
          _date(now),
          style: const TextStyle(color: Color(0xFF687386), fontSize: 14),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_blue, Color(0xFF2F73E6)]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x330757D8),
                blurRadius: 18,
                offset: Offset(0, 9),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.fact_check_outlined, color: Colors.white),
                  SizedBox(width: 9),
                  Text(
                    'STATUS PRESENSI HARI INI',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Belum Presensi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Pastikan presensi Anda tercatat hari ini.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _openPresensi,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _blue,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.fingerprint_rounded),
                label: const Text(
                  'Mulai Presensi',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          'Menu Utama',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _quick(Icons.assignment_outlined, 'Daftar', 1),
            const SizedBox(width: 10),
            _quick(Icons.edit_note_outlined, 'Logbook', 2),
            const SizedBox(width: 10),
            _quick(Icons.workspace_premium_outlined, 'Nilai & Sertifikat', 3),
          ],
        ),
      ],
    );
  }

  Widget _quick(IconData icon, String label, int index) => Expanded(
    child: InkWell(
      onTap: () => setState(() => _index = index),
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        height: 104,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFE5EEFF),
              child: Icon(icon, color: _blue),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _comingSoon(int index) {
    const titles = ['Daftar', 'Logbook', 'Nilai & Sertifikat', 'Profil'];
    const icons = [
      Icons.assignment_outlined,
      Icons.edit_note_outlined,
      Icons.workspace_premium_outlined,
      Icons.person_outline,
    ];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 18),
          Text(
            titles[index - 1],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
          const Spacer(),
          Container(
            width: 132,
            height: 132,
            decoration: const BoxDecoration(
              color: Color(0xFFE3EDFF),
              shape: BoxShape.circle,
            ),
            child: Icon(icons[index - 1], size: 68, color: _blue),
          ),
          const SizedBox(height: 30),
          const Text(
            'Coming Soon',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Fitur ini sedang dalam tahap pengembangan dan akan segera tersedia.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Color(0xFF697386),
            ),
          ),
          const SizedBox(height: 30),
          FilledButton(
            onPressed: null,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              disabledBackgroundColor: const Color(0xFFE5E7EB),
              disabledForegroundColor: const Color(0xFF98A2B3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Segera Hadir',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  void _openPresensi() => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => PresensiScreen(repository: widget.repository),
    ),
  );
}

String _date(DateTime value) =>
    '${const ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'][value.weekday - 1]}, ${value.day} ${const ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'][value.month - 1]} ${value.year}';
