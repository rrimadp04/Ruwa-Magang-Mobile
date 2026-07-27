import 'package:flutter/material.dart';

import '../ds.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kWhite,
        surfaceTintColor: kWhite,
        title: const Text(
          'Notifikasi',
          style: TextStyle(color: kInk, fontSize: 18, fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: kInk),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Tandai dibaca'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(kPadH, 20, kPadH, 32),
        children: const [
          Text('Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          SizedBox(height: 12),
          _NotificationItem(
            icon: Icons.workspace_premium_rounded,
            iconColor: kGreen,
            iconBackground: kGreenLight,
            title: 'Sertifikat berhasil diterbitkan',
            message: 'Sertifikat magang Anda telah aktif dan siap diunduh.',
            time: 'Baru saja',
            unread: true,
          ),
          SizedBox(height: 12),
          _NotificationItem(
            icon: Icons.verified_rounded,
            iconColor: kBlue,
            iconBackground: kBlueLight,
            title: 'Penilaian telah disetujui',
            message: 'Nilai akhir Anda adalah 92 dengan predikat Sangat Baik.',
            time: '12 Juli 2026',
            unread: true,
          ),
          SizedBox(height: 12),
          _NotificationItem(
            icon: Icons.schedule_rounded,
            iconColor: kOrange,
            iconBackground: kOrangeLight,
            title: 'Administrasi sertifikat diproses',
            message: 'Estimasi penerbitan sertifikat adalah 3–7 hari kerja.',
            time: '10 Juli 2026',
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.message,
    required this.time,
    this.unread = false,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String message;
  final String time;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unread ? const Color(0xFFF5F8FF) : kWhite,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(color: unread ? kBlueMid : kBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x05000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: iconBackground, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800, color: kInk)),
                    ),
                    if (unread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: kBlue, shape: BoxShape.circle),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(message, style: kStyleCaption),
                const SizedBox(height: 8),
                Text(time,
                    style: const TextStyle(fontSize: 11, color: kGray, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
