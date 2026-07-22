import 'package:flutter/material.dart';

import '../model/participant_profile.dart';
import '../repository/profile_repository.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.repository, required this.profile});
  final ProfileRepository repository;
  final ParticipantProfile profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _name = TextEditingController(text: widget.profile.name);
  late final TextEditingController _email = TextEditingController(text: widget.profile.email);
  bool _saving = false;

  @override
  void dispose() { _name.dispose(); _email.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Edit Profil')),
    body: SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [
      Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Informasi Profil', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        const SizedBox(height: 18),
        TextField(controller: _name, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Nama', border: OutlineInputBorder())),
        const SizedBox(height: 14),
        TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
      ]))),
      const SizedBox(height: 20),
      FilledButton(onPressed: _saving ? null : _save, style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)), child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('Simpan Perubahan')),
    ])),
  );

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _email.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      await widget.repository.updateProfile(name: _name.text.trim(), email: _email.text.trim());
      if (!mounted) return;
      await showDialog<void>(context: context, builder: (context) => AlertDialog(icon: const Icon(Icons.check_circle, color: Color(0xFF16A87A)), title: const Text('Berhasil'), content: const Text('Profil berhasil diperbarui.'), actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))]));
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally { if (mounted) setState(() => _saving = false); }
  }
}
