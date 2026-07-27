import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class StatusCard extends StatelessWidget {
  const StatusCard({
    super.key,
    required this.status,
    required this.regId,
    required this.opdNama,
  });

  final String status;
  final String regId;
  final String opdNama;

  Color get _color => switch (status.toLowerCase()) {
    'menunggu' => AppColors.warning,
    'diterima' => AppColors.success,
    'ditolak' => AppColors.error,
    _ => AppColors.grey,
  };

  IconData get _icon => switch (status.toLowerCase()) {
    'menunggu' => Icons.access_time,
    'diterima' => Icons.check_circle_outline,
    'ditolak' => Icons.cancel_outlined,
    _ => Icons.info_outline,
  };

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(_icon, color: _color, size: 18),
                const SizedBox(width: 6),
                Text(status, style: TextStyle(color: _color, fontWeight: FontWeight.w700)),
              ],
            ),
            Text(regId, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 10),
        Text(opdNama, style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700)),
      ],
    ),
  );
}
