import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PeriodeForm extends StatelessWidget {
  const PeriodeForm({
    super.key,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.onPickMulai,
    required this.onPickSelesai,
  });

  final DateTime? tanggalMulai;
  final DateTime? tanggalSelesai;
  final VoidCallback onPickMulai;
  final VoidCallback onPickSelesai;

  String _fmt(DateTime? d) {
    if (d == null) return 'mm/dd/yyyy';
    return '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Tanggal Mulai', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      const SizedBox(height: 6),
      _dateTile(_fmt(tanggalMulai), onPickMulai),
      const SizedBox(height: 14),
      const Text('Tanggal Selesai', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      const SizedBox(height: 6),
      _dateTile(_fmt(tanggalSelesai), onPickSelesai),
    ],
  );

  Widget _dateTile(String text, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(child: Text(text, style: const TextStyle(color: AppColors.grey, fontSize: 13))),
          const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.grey),
        ],
      ),
    ),
  );
}
