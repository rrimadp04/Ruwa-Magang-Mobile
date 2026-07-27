import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../model/attachment_model.dart';
import '../model/logbook_model.dart';
import '../model/review_model.dart';
import '../repository/logbook_repository.dart';
import '../widget/logbook_ui.dart';
import 'detail_feedback_screen.dart';

class EditLogbookScreen extends StatefulWidget {
  const EditLogbookScreen({
    super.key,
    required this.repository,
    required this.item,
  });

  final LogbookRepository repository;
  final LogbookModel item;

  @override
  State<EditLogbookScreen> createState() => _EditLogbookScreenState();
}

class _EditLogbookScreenState extends State<EditLogbookScreen> {
  late final TextEditingController _activityController;
  late final TextEditingController _descriptionController;
  late DateTime _date;
  late final LogbookStatus _status;
  late List<AttachmentModel> _attachments;
  bool _saving = false;

  bool get _canEdit =>
      _status == LogbookStatus.draft || _status == LogbookStatus.revision;

  @override
  void initState() {
    super.initState();
    _activityController = TextEditingController(text: widget.item.title)
      ..addListener(_refresh);
    _descriptionController = TextEditingController(
      text: widget.item.activityDescription,
    )..addListener(_refresh);
    _date = widget.item.activityDate;
    _status = widget.item.status;
    _attachments = List<AttachmentModel>.from(widget.item.attachments);
  }

  @override
  void dispose() {
    _activityController.removeListener(_refresh);
    _descriptionController.removeListener(_refresh);
    _activityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_canEdit) {
      return _LockedEditScreen(onBack: () => Navigator.pop(context));
    }

    return Scaffold(
      backgroundColor: logbookBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: logbookInk),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Logbook',
          style: TextStyle(
            color: logbookInk,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (_status == LogbookStatus.revision) ...[
            RevisionBanner(review: widget.item.latestRevisionReview, item: widget.item, repository: widget.repository),
            const SizedBox(height: 22),
          ],
          LogbookForm(
            date: _date,
            activityController: _activityController,
            descriptionController: _descriptionController,
            attachments: _attachments,
            onPickDate: _pickDate,
            onAddAttachment: _addAttachment,
            onPreviewAttachment: _previewAttachment,
            onReplaceAttachment: _replaceAttachment,
            onRemoveAttachment: _removeAttachment,
          ),
          const SizedBox(height: 28),
          if (_status == LogbookStatus.revision)
            BottomActionBar(
              primaryLabel: _saving ? 'Menyimpan...' : 'Simpan Perubahan',
              secondaryLabel: 'Hapus Logbook',
              onPrimary: _saving ? null : _saveAndResubmit,
              onSecondary: _saving ? null : _deleteLogbook,
              secondaryDestructive: true,
            )
          else
            BottomActionBar(
              primaryLabel: _saving ? 'Menyimpan...' : 'Simpan Draft',
              secondaryLabel: 'Kirim Logbook',
              onPrimary: _saving ? null : _saveDraft,
              onSecondary: _saving ? null : _sendLogbook,
            ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2025),
      lastDate: DateTime(2035),
    );
    if (result != null) setState(() => _date = result);
  }

  Future<void> _addAttachment() async {
    if (_attachments.length >= 5) return;
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    final size = await file.length();
    if (size > 5 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ukuran foto maksimal 5 MB.')),
        );
      }
      return;
    }
    final bytes = await file.readAsBytes();
    setState(
      () => _attachments.add(AttachmentModel(name: file.name, bytes: bytes)),
    );
  }

  Future<void> _replaceAttachment(int index) async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    final size = await file.length();
    if (size > 5 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ukuran foto maksimal 5 MB.')),
        );
      }
      return;
    }
    final bytes = await file.readAsBytes();
    setState(
      () =>
          _attachments[index] = AttachmentModel(name: file.name, bytes: bytes),
    );
  }

  void _removeAttachment(int index) =>
      setState(() => _attachments.removeAt(index));

  void _previewAttachment(AttachmentModel item) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.black,
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _AttachmentImage(attachment: item, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  Future<void> _saveDraft() async {
    await _persist(
      status: LogbookStatus.draft,
      message: 'Draft disimpan.',
      popAfterSave: false,
    );
  }

  Future<void> _sendLogbook() async {
    await _persist(
      status: LogbookStatus.pending,
      message: 'Logbook dikirim untuk review Admin OPD.',
      popAfterSave: true,
    );
  }

  Future<void> _saveAndResubmit() async {
    await _persist(
      status: LogbookStatus.pending,
      message: 'Perbaikan dikirim ulang.',
      popAfterSave: true,
    );
  }

  Future<void> _persist({
    required LogbookStatus status,
    required String message,
    required bool popAfterSave,
  }) async {
    final activity = _activityController.text.trim();
    final description = _descriptionController.text.trim();
    if (activity.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aktivitas dan deskripsi wajib diisi.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.repository.updateLogbook(
        widget.item.copyWith(
          activity: activity,
          description: description,
          activityDate: _date,
          status: status,
          attachments: List<AttachmentModel>.from(_attachments),
          reviews:
              status == LogbookStatus.pending &&
                  widget.item.status == LogbookStatus.revision
              ? [
                  ...widget.item.reviews,
                  ReviewModel(
                    reviewer: 'Peserta Magang',
                    role: 'Perbaikan Dikirim Ulang',
                    institution: 'Ruwa Magang',
                    message: 'Perbaikan dikirim ulang untuk review Admin OPD.',
                    createdAt: DateTime.now(),
                    approved: false,
                    status: ReviewStatus.resubmitted,
                  ),
                ]
              : widget.item.reviews,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      if (popAfterSave) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteLogbook() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const DeleteConfirmationDialog(),
    );
    if (confirmed != true) return;
    await widget.repository.deleteLogbook(widget.item.id);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logbook berhasil dihapus.')));
    Navigator.pop(context);
  }
}

class RevisionBanner extends StatelessWidget {
  const RevisionBanner({super.key, required this.review, required this.item, required this.repository});
  final ReviewModel? review;
  final LogbookModel item;
  final LogbookRepository repository;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: logbookWarningSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: logbookWarning,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.priority_high_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Perlu Revisi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: logbookWarning,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  review?.message ??
                      'Mohon perbaiki logbook sesuai catatan reviewer.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: logbookBody,
                    height: 1.55,
                  ),
                ),
                if (review != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    '${review!.reviewer} - ${fullDate(review!.createdAt)} - ${timeWib(review!.createdAt)}',
                    style: const TextStyle(fontSize: 12, color: logbookMuted),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailFeedbackScreen(review: review!, logbook: item, repository: repository))),
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 17),
                    label: const Text('Lihat Detail Feedback'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LogbookForm extends StatelessWidget {
  const LogbookForm({
    super.key,
    required this.date,
    required this.activityController,
    required this.descriptionController,
    required this.attachments,
    required this.onPickDate,
    required this.onAddAttachment,
    required this.onPreviewAttachment,
    required this.onReplaceAttachment,
    required this.onRemoveAttachment,
  });

  final DateTime date;
  final TextEditingController activityController;
  final TextEditingController descriptionController;
  final List<AttachmentModel> attachments;
  final VoidCallback onPickDate;
  final VoidCallback onAddAttachment;
  final ValueChanged<AttachmentModel> onPreviewAttachment;
  final ValueChanged<int> onReplaceAttachment;
  final ValueChanged<int> onRemoveAttachment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal *',
          style: TextStyle(fontWeight: FontWeight.w800, color: logbookInk),
        ),
        const SizedBox(height: 8),
        _ReadonlyDateField(date: date, onTap: onPickDate),
        const SizedBox(height: 20),
        _FieldHeader(
          label: 'Aktivitas',
          count: activityController.text.length,
          max: 100,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: activityController,
          maxLength: 100,
          decoration: const InputDecoration(
            hintText: 'Perbaikan UI Dashboard',
            counterText: '',
          ),
        ),
        const SizedBox(height: 20),
        _FieldHeader(
          label: 'Deskripsi Aktivitas',
          count: descriptionController.text.length,
          max: 500,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: descriptionController,
          maxLength: 500,
          minLines: 5,
          maxLines: null,
          decoration: const InputDecoration(
            hintText: 'Jelaskan aktivitas secara detail...',
            counterText: '',
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Bukti Kegiatan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: logbookInk,
                ),
              ),
            ),
            Text(
              '(Maks. 5 Foto)',
              style: const TextStyle(fontSize: 12, color: logbookMuted),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AttachmentGrid(
          attachments: attachments,
          onAdd: onAddAttachment,
          onPreview: onPreviewAttachment,
          onReplace: onReplaceAttachment,
          onRemove: onRemoveAttachment,
        ),
        const SizedBox(height: 8),
        const Text(
          'Maksimal 5 foto - JPG, JPEG, PNG - Maks. 5 MB',
          style: TextStyle(fontSize: 12, color: logbookMuted),
        ),
      ],
    );
  }
}

class AttachmentGrid extends StatelessWidget {
  const AttachmentGrid({
    super.key,
    required this.attachments,
    required this.onAdd,
    required this.onPreview,
    required this.onReplace,
    required this.onRemove,
  });

  final List<AttachmentModel> attachments;
  final VoidCallback onAdd;
  final ValueChanged<AttachmentModel> onPreview;
  final ValueChanged<int> onReplace;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final itemCount = attachments.length < 5
        ? attachments.length + 1
        : attachments.length;
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index == attachments.length && attachments.length < 5) {
            return AttachmentPicker(onTap: onAdd);
          }
          return _AttachmentThumb(
            attachment: attachments[index],
            onPreview: () => onPreview(attachments[index]),
            onReplace: () => onReplace(index),
            onRemove: () => onRemove(index),
          );
        },
      ),
    );
  }
}

class AttachmentPicker extends StatelessWidget {
  const AttachmentPicker({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: 92,
        height: 128,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: const Center(
          child: Icon(Icons.add_rounded, color: logbookPrimary, size: 30),
        ),
      ),
    );
  }
}

class DeleteConfirmationDialog extends StatelessWidget {
  const DeleteConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Hapus Logbook',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      content: const Text('Apakah Anda yakin ingin menghapus logbook ini?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(backgroundColor: logbookDanger),
          child: const Text('Hapus'),
        ),
      ],
    );
  }
}

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    super.key,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
    this.secondaryDestructive = false,
  });

  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;
  final bool secondaryDestructive;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FilledButton(
          onPressed: onPrimary,
          style: FilledButton.styleFrom(
            backgroundColor: logbookPrimary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            primaryLabel,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: onSecondary,
          style: OutlinedButton.styleFrom(
            foregroundColor: secondaryDestructive
                ? logbookDanger
                : logbookPrimary,
            side: BorderSide(
              color: secondaryDestructive ? logbookDanger : logbookPrimary,
            ),
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            secondaryLabel,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _AttachmentThumb extends StatelessWidget {
  const _AttachmentThumb({
    required this.attachment,
    required this.onPreview,
    required this.onReplace,
    required this.onRemove,
  });
  final AttachmentModel attachment;
  final VoidCallback onPreview;
  final VoidCallback onReplace;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onPreview,
          child: Container(
            width: 92,
            height: 128,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: logbookPrimarySoft,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD5E3FF)),
            ),
            child: _AttachmentImage(attachment: attachment, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          right: 6,
          top: 6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: logbookInk,
              ),
            ),
          ),
        ),
        Positioned(
          right: 6,
          bottom: 6,
          child: GestureDetector(
            onTap: onReplace,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: .55),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit_rounded,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AttachmentImage extends StatelessWidget {
  const _AttachmentImage({required this.attachment, required this.fit});
  final AttachmentModel attachment;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (attachment.hasLocalBytes) {
      return Image.memory(attachment.bytes!, fit: fit);
    }
    if (attachment.hasNetworkUrl) {
      return Image.network(
        attachment.url,
        fit: fit,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.image_outlined, color: logbookPrimary),
      );
    }
    return const Icon(Icons.image_outlined, color: logbookPrimary);
  }
}

class _ReadonlyDateField extends StatelessWidget {
  const _ReadonlyDateField({required this.date, required this.onTap});
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD9E2F2)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              color: logbookMuted,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                fullDate(date),
                style: const TextStyle(
                  fontSize: 14,
                  color: logbookInk,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.event_rounded, color: logbookMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

class _FieldHeader extends StatelessWidget {
  const _FieldHeader({
    required this.label,
    required this.count,
    required this.max,
  });
  final String label;
  final int count;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label *',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: logbookInk,
          ),
        ),
        const Spacer(),
        Text(
          '$count/$max',
          style: const TextStyle(fontSize: 12, color: logbookMuted),
        ),
      ],
    );
  }
}

class _LockedEditScreen extends StatelessWidget {
  const _LockedEditScreen({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: logbookBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: logbookInk),
          onPressed: onBack,
        ),
        title: const Text(
          'Edit Logbook',
          style: TextStyle(
            color: logbookInk,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Logbook ini tidak dapat diedit karena sedang dalam proses review atau telah disetujui.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: logbookBody,
              height: 1.5,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
