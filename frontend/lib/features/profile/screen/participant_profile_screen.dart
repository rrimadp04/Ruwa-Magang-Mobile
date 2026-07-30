import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/repositories/auth_repository.dart';
import '../model/participant_profile.dart';
import '../repository/profile_repository.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';
import 'help_screen.dart';
import 'guide_screen.dart';

class ParticipantProfileScreen extends StatefulWidget {
  const ParticipantProfileScreen({super.key, required this.repository});
  final ProfileRepository repository;

  @override
  State<ParticipantProfileScreen> createState() => _ParticipantProfileScreenState();
}

class _ParticipantProfileScreenState extends State<ParticipantProfileScreen> {
  late Future<ParticipantProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = widget.repository.getProfile();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Profil Peserta')),
        body: SafeArea(
          child: FutureBuilder<ParticipantProfile>(
            future: _profileFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) return _errorState(snapshot.error);
              return _content(snapshot.requireData);
            },
          ),
        ),
      );

  Widget _content(ParticipantProfile profile) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          _profileHeader(profile),
          const SizedBox(height: 18),
          const Text('INFORMASI AKUN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF667085))),
          const SizedBox(height: 8),
          _accountCard(profile),
          const SizedBox(height: 20),
          const Text('LAYANAN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF667085))),
          const SizedBox(height: 8),
          _servicesCard(),
        ],
      );

  Widget _profileHeader(ParticipantProfile profile) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF377CFA), Color(0xFF2457D6)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x26325AD9), blurRadius: 14, offset: Offset(0, 6))],
        ),
        child: Column(
          children: [
            _avatar(profile),
            const SizedBox(height: 12),
            Text(profile.name, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(profile.email, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFE8EFFF), fontSize: 12)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(color: const Color(0x335CE8D0), borderRadius: BorderRadius.circular(20)),
              child: Text(profile.statusLabel.isEmpty ? 'Peserta Aktif' : profile.statusLabel, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );

  Widget _avatar(ParticipantProfile profile) => GestureDetector(
        onTap: _showPhotoSheet,
        child: SizedBox(
          width: 92,
          height: 92,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x334F8AFF)),
                clipBehavior: Clip.antiAlias,
                child: profile.photoUrl == null
                    ? const Icon(Icons.person_outline_rounded, color: Colors.white, size: 43)
                    : Image.network(
                        profile.photoUrl!,
                        key: ValueKey(profile.photoUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.person_outline_rounded, color: Colors.white, size: 43),
                      ),
              ),
              Positioned(
                right: 0,
                bottom: 5,
                child: Container(
                  width: 31,
                  height: 31,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_outlined, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _accountCard(ParticipantProfile profile) => Card(
        elevation: 1.5,
        shadowColor: const Color(0x1A10213A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                title: const Text('Informasi Akun', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                trailing: IconButton(
                  tooltip: 'Edit profil',
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF2563EB)),
                  onPressed: () async {
                    final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => EditProfileScreen(repository: widget.repository, profile: profile)));
                    if (changed == true && mounted) _refreshProfile();
                  },
                ),
              ),
              const Divider(height: 1),
              _infoRow('Universitas', profile.university),
              _infoRow('Program Studi', profile.studyProgram),
              _infoRow('Status Magang', profile.statusLabel, valueColor: const Color(0xFF08794D)),
              _infoRow('OPD Penempatan', profile.opdPlacement),
              _infoRow('Periode Magang', profile.internshipPeriod, isLast: true),
            ],
          ),
        ),
      );

  Widget _infoRow(String label, String value, {Color? valueColor, bool isLast = false}) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Row(
              children: [
                Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF667085)))),
                Flexible(child: Text(value, textAlign: TextAlign.end, style: TextStyle(fontSize: 12, color: valueColor ?? const Color(0xFF172033), fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          if (!isLast) const Divider(height: 1),
        ],
      );

  Widget _servicesCard() => Card(
        elevation: 1.5,
        shadowColor: const Color(0x1A10213A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            ListTile(
              onTap: () async {
                final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => ChangePasswordScreen(repository: widget.repository)));
                if (changed == true && mounted) _showSuccess('Password berhasil diperbarui.');
              },
              leading: const _ServiceIcon(icon: Icons.lock_outline_rounded, color: Color(0xFF8B5CF6)),
              title: const Text('Ganti Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              subtitle: const Text('Perbarui keamanan akun', style: TextStyle(fontSize: 11)),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
            const Divider(height: 1, indent: 72),
            ListTile(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GuideScreen())),
              leading: _ServiceIcon(icon: Icons.menu_book_outlined, color: Color(0xFF356CF2)),
              title: const Text('Panduan Penggunaan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              subtitle: const Text('Tutorial penggunaan Ruwa Magang', style: TextStyle(fontSize: 11)),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
            const Divider(height: 1, indent: 72),
            ListTile(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HelpScreen())),
              leading: const _ServiceIcon(icon: Icons.support_agent_outlined, color: Color(0xFF16A87A)),
              title: const Text('Bantuan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              subtitle: const Text('Hubungi tim support kami', style: TextStyle(fontSize: 11)),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
            const Divider(height: 1, indent: 72),
            ListTile(
              onTap: _confirmLogout,
              leading: const _ServiceIcon(icon: Icons.logout_rounded, color: Color(0xFFDC2626)),
              title: const Text('Logout', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFB42318))),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      );

  Future<void> _refreshProfile() async {
    final profile = await widget.repository.getProfile();
    if (!mounted) return;
    setState(() {
      _profileFuture = Future<ParticipantProfile>.value(profile);
    });
  }

  Future<void> _showPhotoSheet() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Wrap(children: [
          ListTile(leading: const Icon(Icons.camera_alt_outlined), title: const Text('Ambil Foto'), onTap: () => Navigator.pop(context, ImageSource.camera)),
          ListTile(leading: const Icon(Icons.photo_library_outlined), title: const Text('Pilih dari Galeri'), onTap: () => Navigator.pop(context, ImageSource.gallery)),
          ListTile(title: const Center(child: Text('Batal')), onTap: () => Navigator.pop(context)),
        ]),
      ),
    );
    if (source == null || !mounted) return;
    final image = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (image == null || !mounted) return;

    try {
      // Semua proses asinkron dilakukan sebelum setState.
      final bytes = await image.readAsBytes();
      await widget.repository.uploadPhoto(
        bytes: bytes,
        filename: image.name,
      );

      final updatedProfile = await widget.repository.getProfile();
      if (!mounted) return;
      setState(() {
        _profileFuture = Future<ParticipantProfile>.value(updatedProfile);
      });
      _showSuccess('Foto profil berhasil diperbarui.');
    } catch (error) {
      if (mounted) _showError(error.toString());
    }
  }

  Future<void> _confirmLogout() async {
    final logout = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('Logout'), content: const Text('Yakin ingin keluar dari akun ini?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout'))]));
    if (logout != true || !mounted) return;
    try {
      await widget.repository.logout();
      await (await SharedPreferences.getInstance()).remove(AuthRepository.tokenKey);
      if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    } catch (error) {
      if (mounted) _showError(error.toString());
    }
  }

  void _showSuccess(String message) => showDialog<void>(context: context, builder: (context) => AlertDialog(icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A87A)), title: const Text('Berhasil'), content: Text(message), actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))]));
  void _showError(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: const Color(0xFFB42318)));

  Widget _errorState(Object? error) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: Color(0xFFB42318), size: 42),
              const SizedBox(height: 12),
              Text(error?.toString() ?? 'Profil gagal dimuat.', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _refreshProfile,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
}

class _ServiceIcon extends StatelessWidget {
  const _ServiceIcon({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      );
}
