import 'package:flutter/material.dart';
import '../repository/profile_repository.dart';

class ChangePasswordScreen extends StatefulWidget { const ChangePasswordScreen({super.key, required this.repository}); final ProfileRepository repository; @override State<ChangePasswordScreen> createState() => _ChangePasswordScreenState(); }
class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _old = TextEditingController(), _new = TextEditingController(), _confirm = TextEditingController(); bool _saving = false;
  @override void dispose() { _old.dispose(); _new.dispose(); _confirm.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Ganti Password')), body: SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [_field(_old, 'Password Lama'), const SizedBox(height: 14), _field(_new, 'Password Baru'), const SizedBox(height: 14), _field(_confirm, 'Konfirmasi Password')]))), const SizedBox(height: 20), FilledButton(onPressed: _saving ? null : _save, style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)), child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('Simpan Password'))])));
  Widget _field(TextEditingController controller, String label) => TextField(controller: controller, obscureText: true, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()));
  Future<void> _save() async { if (_new.text != _confirm.text) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konfirmasi password tidak sama.'))); return; } setState(() => _saving = true); try { await widget.repository.updatePassword(currentPassword: _old.text, password: _new.text, confirmation: _confirm.text); if (mounted) Navigator.pop(context, true); } catch (error) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString()))); } finally { if (mounted) setState(() => _saving = false); } }
}
