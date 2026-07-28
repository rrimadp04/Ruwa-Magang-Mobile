import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_textfield.dart';

class IdentitasForm extends StatelessWidget {
  const IdentitasForm({super.key, required this.namaCtrl, required this.nimCtrl});

  final TextEditingController namaCtrl;
  final TextEditingController nimCtrl;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      const SizedBox(height: 6),
      CustomTextField(hint: 'Masukkan nama lengkap', controller: namaCtrl),
      const SizedBox(height: 14),
      const Text('NIM / NIS', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      const SizedBox(height: 6),
      CustomTextField(hint: 'Masukkan NIM / NIS', controller: nimCtrl),
    ],
  );
}
