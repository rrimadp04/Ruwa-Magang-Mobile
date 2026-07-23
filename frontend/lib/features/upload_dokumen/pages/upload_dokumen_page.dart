import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/cv_upload.dart';

class UploadDokumenPage extends StatefulWidget {
  const UploadDokumenPage({super.key});

  @override
  State<UploadDokumenPage> createState() => _UploadDokumenPageState();
}

class _UploadDokumenPageState extends State<UploadDokumenPage> {
  String? _cvName;
  String? _transkripName;
  String? _suratName;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bg,
    appBar: AppBar(
      title: const Text('Upload Dokumen'),
      backgroundColor: AppColors.white,
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Upload Berkas',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink),
        ),
        const SizedBox(height: 4),
        const Text('Unggah dokumen persyaratan magang Anda.', style: TextStyle(color: AppColors.grey)),
        const SizedBox(height: 20),
        CvUpload(fileName: _cvName, onPick: () => setState(() => _cvName = 'cv_saya.pdf')),
        const SizedBox(height: 12),
        TranskripUpload(fileName: _transkripName, onPick: () => setState(() => _transkripName = 'transkrip.pdf')),
        const SizedBox(height: 12),
        SuratPengantarUpload(fileName: _suratName, onPick: () => setState(() => _suratName = 'surat_pengantar.pdf')),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () {},
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Simpan Dokumen', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
}
