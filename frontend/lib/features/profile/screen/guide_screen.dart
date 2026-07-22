import 'package:flutter/material.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  int _selected = 0;

  static const _guides = <({String title, String description, List<String> steps})>[
    (
      title: 'Registrasi Akun & Pengisian Profil',
      description: 'Buat akun Ruwa Magang dan lengkapi identitas Anda agar proses magang dapat dipantau.',
      steps: ['Buka halaman registrasi.', 'Isi nama, email, universitas, dan password.', 'Login lalu lengkapi informasi profil Anda.'],
    ),
    (
      title: 'Alur Pengajuan Pendaftaran Magang',
      description: 'Pahami langkah pengajuan pendaftaran magang hingga memperoleh penempatan.',
      steps: ['Pilih OPD dan lengkapi data pendaftaran.', 'Kirim pengajuan magang.', 'Pantau status pengajuan pada halaman Daftar.'],
    ),
    (
      title: 'Pengisian Presensi & Logbook Harian',
      description: 'Catat kehadiran dan aktivitas harian agar progres magang selalu tercatat.',
      steps: ['Buka menu Presensi dan ambil foto selfie.', 'Kirim presensi sesuai waktu yang berlaku.', 'Lengkapi logbook aktivitas setiap hari.'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final guide = _guides[_selected];
    return Scaffold(
      appBar: AppBar(title: const Text('Panduan Penggunaan')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Panduan Penggunaan', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Pusat pembelajaran dan panduan penggunaan sistem magang.'),
            const SizedBox(height: 18),
            _videoPlaceholder(),
            const SizedBox(height: 20),
            const Text('Daftar Video Tutorial', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            ...List.generate(_guides.length, _tutorialTile),
            const SizedBox(height: 16),
            _articleCard(guide),
          ],
        ),
      ),
    );
  }

  Widget _videoPlaceholder() => Container(
        height: 164,
        decoration: BoxDecoration(color: const Color(0xFF2E3754), borderRadius: BorderRadius.circular(16)),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 26, backgroundColor: Color(0xFF4A5573), child: Icon(Icons.play_arrow_rounded, color: Color(0xFF3A7BFF))),
            SizedBox(height: 12),
            Text('Video tutorial belum diunggah oleh\nAdministrator.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFD2D8E6))),
          ],
        ),
      );

  Widget _tutorialTile(int index) {
    final isSelected = index == _selected;
    return Card(
      color: isSelected ? const Color(0xFF2F6FED) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () => setState(() => _selected = index),
        leading: Icon(Icons.play_circle_outline, color: isSelected ? Colors.white : const Color(0xFF2F6FED)),
        title: Text('${index + 1}. ${_guides[index].title}', style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : null, fontWeight: FontWeight.w600)),
        subtitle: Text('Peran: Peserta', style: TextStyle(fontSize: 10, color: isSelected ? Colors.white70 : null)),
      ),
    );
  }

  Widget _articleCard(({String title, String description, List<String> steps}) guide) => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Chip(label: Text('Panduan')),
              Text(guide.title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text(guide.description, style: const TextStyle(height: 1.45)),
              const Divider(height: 28),
              ...List.generate(
                guide.steps.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(radius: 12, child: Text('${index + 1}', style: const TextStyle(fontSize: 11))),
                      const SizedBox(width: 10),
                      Expanded(child: Text(guide.steps[index])),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
