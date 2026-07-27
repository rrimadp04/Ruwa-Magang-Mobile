import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_textfield.dart';

class PendidikanForm extends StatelessWidget {
  const PendidikanForm({super.key, required this.prodiCtrl, required this.universitasCtrl});

  final TextEditingController prodiCtrl;
  final TextEditingController universitasCtrl;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Prodi / Jurusan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      const SizedBox(height: 6),
      CustomTextField(hint: 'Masukkan Program Studi / Jurusan', controller: prodiCtrl),
      const SizedBox(height: 14),
      const Text('Universitas / Sekolah', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      const SizedBox(height: 6),
      CustomTextField(hint: 'Masukkan nama institusi', controller: universitasCtrl),
    ],
  );
}
