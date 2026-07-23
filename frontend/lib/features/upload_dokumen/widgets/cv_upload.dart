import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CvUpload extends StatelessWidget {
  const CvUpload({super.key, required this.fileName, required this.onPick});

  final String? fileName;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) => _UploadTile(
    icon: Icons.description_outlined,
    label: 'Curriculum Vitae (CV)',
    hint: 'PDF/DOC, maks 5MB',
    fileName: fileName,
    onPick: onPick,
  );
}

class SuratPengantarUpload extends StatelessWidget {
  const SuratPengantarUpload({super.key, required this.fileName, required this.onPick});

  final String? fileName;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) => _UploadTile(
    icon: Icons.mail_outline,
    label: 'Surat Pengantar Kampus',
    hint: 'PDF/DOC, maks 5MB',
    fileName: fileName,
    onPick: onPick,
  );
}

class TranskripUpload extends StatelessWidget {
  const TranskripUpload({super.key, required this.fileName, required this.onPick});

  final String? fileName;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) => _UploadTile(
    icon: Icons.receipt_long_outlined,
    label: 'Transkrip Nilai',
    hint: 'PDF, maks 5MB',
    fileName: fileName,
    onPick: onPick,
  );
}

class _UploadTile extends StatelessWidget {
  const _UploadTile({
    required this.icon,
    required this.label,
    required this.hint,
    required this.fileName,
    required this.onPick,
  });

  final IconData icon;
  final String label;
  final String hint;
  final String? fileName;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onPick,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: fileName != null ? AppColors.primary : AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: fileName != null ? AppColors.primary : AppColors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.ink)),
                Text(
                  fileName ?? hint,
                  style: TextStyle(color: fileName != null ? AppColors.primary : AppColors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(
            fileName != null ? Icons.check_circle : Icons.upload_outlined,
            color: fileName != null ? AppColors.success : AppColors.grey,
          ),
        ],
      ),
    ),
  );
}
