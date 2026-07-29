import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/opd_model.dart';

class OpdCard extends StatelessWidget {
  const OpdCard({super.key, required this.opd, required this.onDetail});

  final OpdModel opd;
  final VoidCallback onDetail;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header gradient
        Container(
          height: 80,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D9488), AppColors.primary],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
          ),
          padding: const EdgeInsets.all(14),
          alignment: Alignment.centerLeft,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              opd.initial,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.ink),
            ),
          ),
        ),
        // Body
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      opd.nama,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.ink),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      opd.status,
                      style: const TextStyle(color: Color(0xFF065F46), fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(opd.bidang, style: const TextStyle(color: AppColors.primary, fontSize: 13)),
              const SizedBox(height: 8),
              Text(
                opd.deskripsi ?? 'Informasi singkat OPD belum tersedia.',
                style: const TextStyle(color: AppColors.grey, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // Bidang chips
              if (opd.bidangs.isNotEmpty) ...[
                const SizedBox(height: 10),
                _bidangChips(),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.grey),
                  const SizedBox(width: 4),
                  Text(opd.alamat ?? '-', style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.people_outline, size: 14, color: AppColors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Terisi: ${opd.pesertaAktif} / ${opd.kuota}',
                    style: const TextStyle(color: AppColors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onDetail,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(42),
                  side: const BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Lihat Detail'),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _bidangChips() {
    const maxShow = 3;
    final show = opd.bidangs.take(maxShow).toList();
    final extra = opd.bidangs.length - maxShow;
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        ...show.map((b) => _chip(b.name)),
        if (extra > 0) _chip('+$extra lainnya', isExtra: true),
      ],
    );
  }

  Widget _chip(String label, {bool isExtra = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: isExtra ? const Color(0xFFE0EAFF) : const Color(0xFFF0FDF4),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: isExtra ? AppColors.primary : const Color(0xFF86EFAC)),
    ),
    child: Text(
      label.length > 18 ? '${label.substring(0, 18)}...' : label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: isExtra ? AppColors.primary : const Color(0xFF166534),
      ),
    ),
  );
}
