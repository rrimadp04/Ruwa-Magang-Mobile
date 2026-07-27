import 'package:flutter/material.dart';

import '../../nilai_sertifikat/screen/notification_screen.dart';
import '../model/attachment_model.dart';
import '../model/logbook_model.dart';
import '../model/review_model.dart';
import '../repository/logbook_repository.dart';
import '../widget/logbook_ui.dart';
import '../widget/status_chip.dart';
import 'detail_feedback_screen.dart';
import 'edit_logbook_screen.dart';
import 'riwayat_review_screen.dart';

class DetailLogbookScreen extends StatelessWidget {
  const DetailLogbookScreen({
    super.key,
    required this.repository,
    required this.item,
  });

  final LogbookRepository repository;
  final LogbookModel item;

  @override
  Widget build(BuildContext context) {
    final showRevision = item.status == LogbookStatus.revision;
    final showApproved = item.status == LogbookStatus.approved;
    final showReviews = item.reviews.isNotEmpty && showApproved;
    final internalReview = _findReview(item, 'internal');
    final externalReview = _findReview(item, 'eksternal');

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
          'Detail Logbook',
          style: TextStyle(
            color: logbookInk,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            ),
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: logbookInk,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: logbookInk),
            onSelected: (value) {
              if (value == 'edit') _openEdit(context);
              if (value == 'delete') _delete(context);
            },
            itemBuilder: (context) => [
              if (item.canEdit)
                const PopupMenuItem(value: 'edit', child: Text('Edit Logbook')),
              if (item.canEdit)
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Hapus Logbook'),
                ),
              if (!item.canEdit)
                const PopupMenuItem(
                  value: 'locked',
                  enabled: false,
                  child: Text('Logbook terkunci'),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        children: [
          _FadeSlide(index: 0, child: LogbookHeaderCard(item: item)),
          const SizedBox(height: 20),
          _FadeSlide(index: 1, child: ActivityInformationCard(item: item)),
          const SizedBox(height: 20),
          _FadeSlide(index: 2, child: AttachmentSection(item: item)),
          if (showRevision) ...[
            const SizedBox(height: 20),
            _FadeSlide(
              index: 3,
              child: RevisionFeedbackCard(review: item.latestRevisionReview),
            ),
          ],
          if (showReviews && internalReview != null) ...[
            const SizedBox(height: 20),
            _FadeSlide(
              index: 4,
              child: InternalReviewCard(review: internalReview),
            ),
          ],
          if (showReviews && externalReview != null) ...[
            const SizedBox(height: 16),
            _FadeSlide(
              index: 5,
              child: ExternalReviewCard(review: externalReview),
            ),
          ],
          if (showReviews) ...[
            const SizedBox(height: 20),
            _FadeSlide(index: 6, child: TimelineReviewPreview(item: item, repository: repository)),
          ] else ...[
            const SizedBox(height: 20),
            _FadeSlide(index: 6, child: TimelineReviewPreview(item: item, repository: repository)),
          ],
          const SizedBox(height: 20),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        item: item,
        onEdit: () => _openEdit(context),
      ),
    );
  }

  ReviewModel? _findReview(LogbookModel item, String keyword) {
    for (final review in item.reviews) {
      final role = review.role.toLowerCase();
      final reviewer = review.reviewer.toLowerCase();
      if (role.contains(keyword) || reviewer.contains(keyword)) {
        return review;
      }
    }
    return null;
  }

  void _openEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditLogbookScreen(repository: repository, item: item),
      ),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final yes = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hapus Logbook?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text('Catatan yang dihapus tidak dapat dikembalikan.'),
            const SizedBox(height: 20),
            FilledButton.tonal(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: logbookDanger,
                foregroundColor: Colors.white,
              ),
              child: const SizedBox(
                width: double.infinity,
                child: Center(child: Text('Hapus')),
              ),
            ),
          ],
        ),
      ),
    );
    if (yes != true) return;
    await repository.deleteLogbook(item.id);
    if (context.mounted) Navigator.pop(context);
  }
}

class LogbookHeaderCard extends StatelessWidget {
  const LogbookHeaderCard({super.key, required this.item});
  final LogbookModel item;

  @override
  Widget build(BuildContext context) {
    final statusLabel = switch (item.status) {
      LogbookStatus.draft => 'Draft',
      LogbookStatus.pending => 'Menunggu Review Admin',
      LogbookStatus.revision => 'Perlu Revisi',
      LogbookStatus.approved => 'Disetujui',
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: logbookCardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: logbookPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.description_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    color: logbookInk,
                  ),
                ),
                const SizedBox(height: 10),
                StatusChip(status: item.status),
                const SizedBox(height: 10),
                Text(
                  statusLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: logbookBody,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 15,
                      color: logbookBody,
                    ),
                    Text(
                      fullDate(item.activityDate),
                      style: const TextStyle(
                        fontSize: 12,
                        color: logbookBody,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text('•', style: TextStyle(color: logbookMuted)),
                    const Icon(
                      Icons.schedule_rounded,
                      size: 15,
                      color: logbookBody,
                    ),
                    Text(
                      timeWib(item.activityDate),
                      style: const TextStyle(
                        fontSize: 12,
                        color: logbookBody,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityInformationCard extends StatelessWidget {
  const ActivityInformationCard({super.key, required this.item});
  final LogbookModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: logbookCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('Aktivitas'),
          const SizedBox(height: 8),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 15,
              color: logbookInk,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Divider(height: 22, color: logbookBorder),
          const _SectionLabel('Deskripsi Aktivitas'),
          const SizedBox(height: 8),
          Text(
            item.activityDescription,
            style: const TextStyle(
              fontSize: 14,
              height: 1.65,
              color: logbookBody,
            ),
          ),
        ],
      ),
    );
  }
}

class AttachmentSection extends StatelessWidget {
  const AttachmentSection({super.key, required this.item});
  final LogbookModel item;

  @override
  Widget build(BuildContext context) {
    final photos = item.attachments.where((entry) => entry.isPhoto).toList();
    if (photos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: logbookCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _SectionLabel('Bukti Kegiatan'),
              Text(
                ' (${photos.length} Foto)',
                style: const TextStyle(
                  fontSize: 13,
                  color: logbookBody,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 118,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) => _PhotoThumb(
                photo: photos[index],
                index: index,
                total: photos.length,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        _PhotoPreview(photos: photos, initialIndex: index),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RevisionFeedbackCard extends StatelessWidget {
  const RevisionFeedbackCard({super.key, required this.review});
  final ReviewModel? review;

  @override
  Widget build(BuildContext context) {
    if (review == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: logbookCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Feedback Revisi',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: logbookInk,
            ),
          ),
          const SizedBox(height: 16),
          _reviewMeta(review!, accent: logbookDanger, title: 'Reviewer'),
          const SizedBox(height: 12),
          const _SectionLabel('Komentar'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: logbookDangerSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Text(
              review!.message,
              style: const TextStyle(
                fontSize: 14,
                height: 1.65,
                color: logbookBody,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const _SectionLabel('Checklist Revisi'),
          const SizedBox(height: 8),
          const _ChecklistItem(label: 'Lengkapi bukti kegiatan'),
          _ChecklistItem(label: 'Perbaiki deskripsi aktivitas', done: false),
          _ChecklistItem(label: 'Kirim ulang logbook', done: false),
        ],
      ),
    );
  }
}

class InternalReviewCard extends StatelessWidget {
  const InternalReviewCard({super.key, required this.review});
  final ReviewModel review;

  @override
  Widget build(BuildContext context) => _ReviewCard(
    title: 'Penilaian Pembimbing Internal (OPD)',
    review: review,
    color: logbookSuccess,
    softColor: logbookSuccessSoft,
    quoteColor: const Color(0xFFF0F9EA),
    quoteBorder: const Color(0xFFCBE7BE),
    quoteMark: const Color(0xFFB8E0A8),
    rating: _ratingFromReview(review, preferred: 'Sangat Baik'),
    ratingIcon: Icons.star_rounded,
  );
}

class ExternalReviewCard extends StatelessWidget {
  const ExternalReviewCard({super.key, required this.review});
  final ReviewModel review;

  @override
  Widget build(BuildContext context) => _ReviewCard(
    title: 'Penilaian Pembimbing Eksternal (Dosen)',
    review: review,
    color: logbookPrimary,
    softColor: const Color(0xFFDBEAFE),
    quoteColor: const Color(0xFFF0F6FF),
    quoteBorder: const Color(0xFFBFD4F5),
    quoteMark: const Color(0xFF93BDF5),
    rating: _ratingFromReview(review, preferred: 'Baik'),
    ratingIcon: Icons.thumb_up_alt_rounded,
  );
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.title,
    required this.review,
    required this.color,
    required this.softColor,
    required this.quoteColor,
    required this.quoteBorder,
    required this.quoteMark,
    required this.rating,
    required this.ratingIcon,
  });

  final String title;
  final ReviewModel review;
  final Color color;
  final Color softColor;
  final Color quoteColor;
  final Color quoteBorder;
  final Color quoteMark;
  final String rating;
  final IconData ratingIcon;

  @override
  Widget build(BuildContext context) {
    final tone = _ratingTone(rating);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: logbookCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color,
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                    color: logbookInk,
                  ),
                ),
              ),
              _Pill(label: 'Sudah Dinilai', color: color, softColor: softColor),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InfoColumn(
                  label: 'Status Penilaian',
                  child: _Pill(
                    label: rating,
                    color: tone.color,
                    softColor: tone.softColor,
                    icon: ratingIcon,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _InfoColumn(
                  label: 'Tanggal Review',
                  child: Text(
                    '${fullDate(review.createdAt)}\n${timeWib(review.createdAt)}',
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      color: logbookInk,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _SectionLabel('Komentar'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: quoteColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: quoteBorder),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -10,
                  left: 0,
                  child: Icon(
                    Icons.format_quote_rounded,
                    color: quoteMark,
                    size: 34,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 6),
                  child: Text(
                    review.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.65,
                      color: logbookBody,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 34, color: logbookBorder),
          Row(
            children: [
              const Icon(Icons.badge_outlined, color: logbookBody, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: logbookBody,
                      height: 1.45,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: review.reviewer,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(text: ' -\n'),
                      TextSpan(text: review.role),
                    ],
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailFeedbackScreen(review: review),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  minimumSize: const Size(92, 52),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Lihat\nReview', textAlign: TextAlign.center),
                    SizedBox(width: 6),
                    Icon(Icons.chevron_right_rounded, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TimelineReviewCard extends StatelessWidget {
  const TimelineReviewCard({super.key, required this.item});
  final LogbookModel item;

  @override
  Widget build(BuildContext context) {
    final steps = <_TimelineStep>[
      _TimelineStep(
        'Draft dibuat',
        item.createdAt ?? item.activityDate,
        Icons.check_circle_rounded,
        logbookSuccess,
        true,
        null,
      ),
    ];

    if (item.status != LogbookStatus.draft) {
      steps.add(
        _TimelineStep(
          'Dikirim',
          item.activityDate,
          Icons.send_rounded,
          logbookPrimary,
          true,
          null,
        ),
      );
    }
    if (item.status == LogbookStatus.pending ||
        item.status == LogbookStatus.revision ||
        item.status == LogbookStatus.approved) {
      steps.add(
        _TimelineStep(
          'Direview Admin',
          item.activityDate.add(const Duration(hours: 2)),
          Icons.rate_review_rounded,
          logbookWarning,
          true,
          null,
        ),
      );
    }
    if (item.status == LogbookStatus.revision) {
      steps.add(
        _TimelineStep(
          'Perlu Revisi',
          item.activityDate.add(const Duration(hours: 3)),
          Icons.error_rounded,
          logbookDanger,
          true,
          'Peserta perlu memperbaiki logbook',
        ),
      );
    }
    if (item.status == LogbookStatus.approved) {
      steps.add(
        _TimelineStep(
          'Disetujui',
          _approvedAt(),
          Icons.check_circle_rounded,
          logbookSuccess,
          true,
          'Logbook selesai direview',
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: logbookCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Riwayat Review',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: logbookInk,
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(
            steps.length,
            (index) => _TimelineItem(
              step: steps[index],
              isLast: index == steps.length - 1,
            ),
          ),
        ],
      ),
    );
  }

  DateTime _approvedAt() {
    for (final review in item.reviews.reversed) {
      if (review.isApproved) return review.createdAt;
    }
    return item.activityDate.add(const Duration(hours: 2, minutes: 15));
  }
}

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.item, required this.onEdit});
  final LogbookModel item;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    if (item.status == LogbookStatus.pending ||
        item.status == LogbookStatus.approved) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: logbookBorder)),
        ),
        child: FilledButton(
          onPressed: onEdit,
          style: FilledButton.styleFrom(
            backgroundColor: logbookPrimary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Edit Logbook',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}

class _PhotoThumb extends StatefulWidget {
  const _PhotoThumb({
    required this.photo,
    required this.index,
    required this.total,
    required this.onTap,
  });
  final AttachmentModel photo;
  final int index;
  final int total;
  final VoidCallback onTap;

  @override
  State<_PhotoThumb> createState() => _PhotoThumbState();
}

class _PhotoThumbState extends State<_PhotoThumb> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? .96 : 1,
        duration: const Duration(milliseconds: 120),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              SizedBox(
                width: 120,
                height: 118,
                child: Image.network(
                  widget.photo.url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: logbookPrimarySoft,
                    child: const Icon(
                      Icons.image_outlined,
                      color: logbookPrimary,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .45),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${widget.index + 1}/${widget.total}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPreview extends StatefulWidget {
  const _PhotoPreview({required this.photos, required this.initialIndex});
  final List<AttachmentModel> photos;
  final int initialIndex;

  @override
  State<_PhotoPreview> createState() => _PhotoPreviewState();
}

class _PhotoPreviewState extends State<_PhotoPreview> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          '${_index + 1}/${widget.photos.length}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.photos.length,
        onPageChanged: (value) => setState(() => _index = value),
        itemBuilder: (context, index) => InteractiveViewer(
          child: Center(
            child: Image.network(widget.photos[index].url, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.step, required this.isLast});
  final _TimelineStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(step.icon, color: step.color, size: 20),
            if (!isLast)
              Container(
                width: 2,
                height: 42,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: step.color.withValues(alpha: .28),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: logbookInk,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${fullDate(step.date)} - ${timeWib(step.date).replaceAll(' WIB', '')}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: logbookBody,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (step.note != null) ...[
                  const SizedBox(height: 8),
                  _Pill(
                    label: step.note!,
                    color: step.color,
                    softColor: step.color.withValues(alpha: .10),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoColumn extends StatelessWidget {
  const _InfoColumn({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: logbookBody,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        child,
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.color,
    required this.softColor,
    this.icon,
  });
  final String label;
  final Color color;
  final Color softColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: softColor,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      color: logbookBody,
      fontWeight: FontWeight.w800,
    ),
  );
}

class _FadeSlide extends StatelessWidget {
  const _FadeSlide({required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 360 + index * 70),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - value)),
          child: child,
        ),
      ),
    );
  }
}

Widget _reviewMeta(
  ReviewModel review, {
  required Color accent,
  required String title,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CircleAvatar(
        radius: 20,
        backgroundColor: accent,
        child: const Icon(
          Icons.person_outline_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: logbookMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              review.reviewer,
              style: const TextStyle(
                fontSize: 14,
                color: logbookInk,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              review.role,
              style: const TextStyle(fontSize: 12, color: logbookBody),
            ),
          ],
        ),
      ),
      Text(
        '${fullDate(review.createdAt)}\n${timeWib(review.createdAt)}',
        textAlign: TextAlign.right,
        style: const TextStyle(fontSize: 12, color: logbookBody, height: 1.35),
      ),
    ],
  );
}

class _Tone {
  const _Tone(this.color, this.softColor);
  final Color color;
  final Color softColor;
}

class _TimelineStep {
  const _TimelineStep(
    this.title,
    this.date,
    this.icon,
    this.color,
    this.done,
    this.note,
  );
  final String title;
  final DateTime date;
  final IconData icon;
  final Color color;
  final bool done;
  final String? note;
}

_Tone _ratingTone(String rating) => switch (rating.toLowerCase()) {
  'sangat baik' => const _Tone(logbookSuccess, logbookSuccessSoft),
  'baik' => const _Tone(logbookPrimary, Color(0xFFDBEAFE)),
  'cukup' => const _Tone(logbookWarning, logbookWarningSoft),
  'buruk' => const _Tone(logbookDanger, logbookDangerSoft),
  _ => const _Tone(logbookMuted, Color(0xFFF1F5F9)),
};

String _ratingFromReview(ReviewModel review, {required String preferred}) {
  final message = review.message.toLowerCase();
  if (message.contains('buruk')) return 'Buruk';
  if (message.contains('cukup')) return 'Cukup';
  if (message.contains('sangat baik')) return 'Sangat Baik';
  if (message.contains('baik')) return 'Baik';
  return preferred;
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.label, this.done = true});
  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final color = done ? logbookSuccess : logbookMuted;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
