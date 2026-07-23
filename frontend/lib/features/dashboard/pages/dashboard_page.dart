import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/dashboard_menu.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.onNavigate});

  final void Function(int index) onNavigate;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 23,
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.person, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Selamat datang,', style: TextStyle(color: AppColors.grey)),
                  Text(
                    'Peserta Magang',
                    style: TextStyle(color: AppColors.ink, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded, color: AppColors.ink),
            ),
          ],
        ),
        const SizedBox(height: 26),
        Text(_date(now), style: const TextStyle(color: Color(0xFF687386), fontSize: 14)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF2F73E6)]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Color(0x330757D8), blurRadius: 18, offset: Offset(0, 9))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.fact_check_outlined, color: Colors.white),
                  SizedBox(width: 9),
                  Text('STATUS PRESENSI HARI INI', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 14),
              const Text('Belum Presensi', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              const Text('Pastikan presensi Anda tercatat hari ini.', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.fingerprint_rounded),
                label: const Text('Mulai Presensi', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        const Text('Menu Utama', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink)),
        const SizedBox(height: 14),
        Row(
          children: [
            DashboardMenu(icon: Icons.assignment_outlined, label: 'Daftar', onTap: () => onNavigate(1)),
            const SizedBox(width: 10),
            DashboardMenu(icon: Icons.edit_note_outlined, label: 'Logbook', onTap: () => onNavigate(2)),
            const SizedBox(width: 10),
            DashboardMenu(icon: Icons.workspace_premium_outlined, label: 'Nilai & Sertifikat', onTap: () => onNavigate(3)),
          ],
        ),
      ],
    );
  }
}

String _date(DateTime value) =>
    '${const ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'][value.weekday - 1]}, ${value.day} ${const ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'][value.month - 1]} ${value.year}';
