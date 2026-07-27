import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../model/attachment_model.dart';
import '../model/logbook_model.dart';
import '../repository/logbook_repository.dart';
import '../widget/custom_appbar.dart';
import '../widget/primary_button.dart';
import '../../presensi/screen/selfie_camera_screen.dart';

class LogbookFormScreen extends StatefulWidget {
  const LogbookFormScreen({
    super.key,
    required this.title,
    required this.repository,
    this.initial,
  });
  final String title;
  final LogbookRepository repository;
  final LogbookModel? initial;
  @override
  State<LogbookFormScreen> createState() => _LogbookFormScreenState();
}

class _LogbookFormScreenState extends State<LogbookFormScreen> {
  late final _title = TextEditingController(
    text: _splitActivity(widget.initial?.activity).$1,
  );
  late final _description = TextEditingController(
    text: _splitActivity(widget.initial?.activity).$2,
  );
  late DateTime _date = widget.initial?.activityDate ?? DateTime.now();
  bool _submitting = false;
  String? _activityError;
  final List<XFile> _photos = [];
  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8FAFC),
    appBar: CustomAppbar(title: widget.title),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D0F172A),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tanggal *',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(
                        '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        'Aktivitas *',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      Text(
                        '${_title.text.length}/100',
                        style: TextStyle(
                          fontSize: 12,
                          color: _title.text.length > 90
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _title,
                    maxLength: 100,
                    onChanged: (_) => setState(() => _activityError = null),
                    decoration: InputDecoration(
                      hintText: 'Contoh: Membuat Dashboard Statistik',
                      errorText: _activityError,
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        'Deskripsi Aktivitas *',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      Text(
                        '${_description.text.length}/500',
                        style: TextStyle(
                          fontSize: 12,
                          color: _description.text.length > 450
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _description,
                    minLines: 6,
                    maxLines: null,
                    maxLength: 500,
                    onChanged: (_) => setState(() => _activityError = null),
                    decoration: const InputDecoration(
                      hintText:
                          'Jelaskan aktivitas yang dilakukan hari ini secara detail...',
                      alignLabelWithHint: true,
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Bukti Kegiatan',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Maksimal 5 foto. Foto disimpan lokal dan tidak dikirim ke API.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openCamera,
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Kamera'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openGallery,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Galeri'),
                        ),
                      ),
                    ],
                  ),
                  if (_photos.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _photos
                          .asMap()
                          .entries
                          .map((entry) => _photoTile(entry.key, entry.value))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 28),
                  PrimaryButton(
                    label: _submitting ? 'Mengirim...' : 'Kirim Logbook',
                    icon: Icons.send_rounded,
                    onPressed: _submitting ? null : _confirmSubmit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
    );
    if (result != null) setState(() => _date = result);
  }

  Future<void> _openCamera() async {
    if (_photos.length >= 5) {
      _showPhotoLimit();
      return;
    }
    final photo = await Navigator.of(context).push<XFile>(
      MaterialPageRoute(builder: (_) => const SelfieCameraScreen()),
    );
    if (photo != null) await _addPhoto(photo);
  }

  Future<void> _openGallery() async {
    if (_photos.length >= 5) {
      _showPhotoLimit();
      return;
    }
    final photo = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (photo != null) await _addPhoto(photo);
  }

  Future<void> _addPhoto(XFile photo) async {
    final bytes = await photo.length();
    if (bytes > 5 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ukuran foto maksimal 5 MB.')),
        );
      }
      return;
    }
    if (mounted) setState(() => _photos.add(photo));
  }

  void _showPhotoLimit() => ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('Maksimal 5 foto.')));
  Widget _photoTile(int index, XFile photo) => LayoutBuilder(
    builder: (context, constraints) {
      final size = constraints.maxWidth.isFinite
          ? constraints.maxWidth.clamp(64.0, 90.0)
          : 82.0;
      return Stack(
        children: [
          FutureBuilder<Uint8List>(
            future: photo.readAsBytes(),
            builder: (context, snapshot) => SizedBox.square(
              dimension: size,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: snapshot.hasData
                    ? Image.memory(snapshot.data!, fit: BoxFit.cover)
                    : const Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
              ),
            ),
          ),
          Positioned(
            right: 2,
            top: 2,
            child: InkWell(
              onTap: () => setState(() => _photos.removeAt(index)),
              child: const CircleAvatar(
                radius: 11,
                backgroundColor: Color(0xFFEF4444),
                child: Icon(Icons.close_rounded, color: Colors.white, size: 15),
              ),
            ),
          ),
        ],
      );
    },
  );
  Future<void> _confirmSubmit() async {
    if (_title.text.trim().isEmpty || _description.text.trim().isEmpty) {
      setState(() => _activityError = 'Aktivitas dan deskripsi wajib diisi.');
      return;
    }
    final confirm = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kirim Logbook?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pastikan aktivitas sudah benar sebelum dikirim untuk direview Admin OPD.',
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Ya, Kirim'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (confirm != true) return;
    setState(() => _submitting = true);
    final activity = '${_title.text.trim()}\n\n${_description.text.trim()}';
    try {
      final attachments = <AttachmentModel>[];
      for (final photo in _photos) {
        final bytes = await photo.readAsBytes();
        attachments.add(AttachmentModel(name: photo.name, bytes: bytes));
      }

      if (widget.initial == null) {
        await widget.repository.createLogbook(
          date: _date,
          activity: activity,
          attachments: attachments,
        );
      } else {
        await widget.repository.updateLogbook(
          widget.initial!.copyWith(
            activity: activity,
            activityDate: _date,
            attachments: attachments,
          ),
        );
      }
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) => Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF22C55E),
                size: 56,
              ),
              const SizedBox(height: 12),
              const Text(
                'Logbook Berhasil Dikirim',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Logbook sedang menunggu review Admin OPD.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(this.context);
                },
                child: const Text('Kembali ke Daftar Logbook'),
              ),
            ],
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  (String, String) _splitActivity(String? activity) {
    final content = activity ?? '';
    final chunks = content.split('\n\n');
    return (chunks.first, chunks.skip(1).join('\n\n'));
  }
}
