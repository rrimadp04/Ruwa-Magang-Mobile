import 'package:flutter/material.dart';

import '../model/logbook_model.dart';
import '../model/review_model.dart';
import '../repository/logbook_repository.dart';
import '../widget/custom_appbar.dart';
import '../widget/logbook_ui.dart';
import 'detail_feedback_screen.dart';

class RiwayatReviewScreen extends StatelessWidget {
  const RiwayatReviewScreen({super.key, required this.item, this.repository});
  final LogbookModel item;
  final LogbookRepository? repository;

  @override
  Widget build(BuildContext context) {
    final entries = buildReviewTimeline(item);
    return Scaffold(
      backgroundColor: logbookBackground,
      appBar: const CustomAppbar(title: 'Riwayat Review'),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        itemCount: entries.length,
        itemBuilder: (context, index) => _TimelineEventCard(
          entry: entries[index],
          isLast: index == entries.length - 1,
          onTap: entries[index].review == null
              ? null
              : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailFeedbackScreen(
                      review: entries[index].review!,
                      logbook: item,
                      repository: repository,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class TimelineReviewPreview extends StatelessWidget {
  const TimelineReviewPreview({
    super.key,
    required this.item,
    required this.repository,
  });
  final LogbookModel item;
  final LogbookRepository repository;
  @override
  Widget build(BuildContext context) {
    final entries = buildReviewTimeline(item);
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              RiwayatReviewScreen(item: item, repository: repository),
        ),
      ),
      borderRadius: BorderRadius.circular(20),
      child: Ink(
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
            const SizedBox(height: 18),
            ...entries
                .take(4)
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(entry.icon, size: 19, color: entry.color),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: logbookInk,
                            ),
                          ),
                        ),
                        Text(
                          timeWib(entry.time),
                          style: const TextStyle(
                            fontSize: 11,
                            color: logbookMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            const Divider(height: 24, color: logbookBorder),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Lihat Selengkapnya ›',
                style: TextStyle(
                  color: logbookPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewTimelineEntry {
  const ReviewTimelineEntry({
    required this.title,
    required this.time,
    required this.color,
    required this.icon,
    this.sender,
    this.summary,
    this.review,
  });
  final String title;
  final DateTime time;
  final Color color;
  final IconData icon;
  final String? sender;
  final String? summary;
  final ReviewModel? review;
}

List<ReviewTimelineEntry> buildReviewTimeline(LogbookModel item) {
  final entries = <ReviewTimelineEntry>[
    ReviewTimelineEntry(
      title: 'Draft dibuat',
      time: item.createdAt ?? item.activityDate,
      color: const Color(0xFF9CA3AF),
      icon: Icons.edit_note_rounded,
      sender: 'Peserta Magang',
      summary: 'Logbook dibuat.',
    ),
  ];
  if (item.status != LogbookStatus.draft) {
    entries.add(
      ReviewTimelineEntry(
        title: 'Dikirim',
        time: item.activityDate,
        color: logbookPrimary,
        icon: Icons.send_rounded,
        sender: 'Peserta Magang',
        summary: 'Logbook dikirim untuk direview.',
      ),
    );
  }
  for (final review in item.reviews) {
    final status = review.effectiveStatus;
    final title = switch (status) {
      ReviewStatus.revision => 'Perlu Revisi',
      ReviewStatus.resubmitted => 'Direview ulang',
      ReviewStatus.approved => 'Disetujui',
      ReviewStatus.pending => 'Direview Admin OPD',
    };
    final color = switch (status) {
      ReviewStatus.revision => logbookWarning,
      ReviewStatus.resubmitted => logbookPrimary,
      ReviewStatus.approved => logbookSuccess,
      ReviewStatus.pending => const Color(0xFF7C3AED),
    };
    final icon = switch (status) {
      ReviewStatus.revision => Icons.error_outline_rounded,
      ReviewStatus.resubmitted => Icons.refresh_rounded,
      ReviewStatus.approved => Icons.check_circle_rounded,
      ReviewStatus.pending => Icons.rate_review_rounded,
    };
    entries.add(
      ReviewTimelineEntry(
        title: title,
        time: review.createdAt,
        color: color,
        icon: icon,
        sender: review.reviewer,
        summary: review.message,
        review: review,
      ),
    );
  }
  if (item.reviews.isEmpty && item.status == LogbookStatus.pending) {
    entries.add(
      ReviewTimelineEntry(
        title: 'Menunggu review',
        time: item.activityDate,
        color: const Color(0xFF7C3AED),
        icon: Icons.hourglass_top_rounded,
        summary: 'Belum ada reviewer.',
      ),
    );
  }
  return entries;
}

class _TimelineEventCard extends StatelessWidget {
  const _TimelineEventCard({
    required this.entry,
    required this.isLast,
    this.onTap,
  });
  final ReviewTimelineEntry entry;
  final bool isLast;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 48,
        child: Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: entry.color,
                shape: BoxShape.circle,
              ),
              child: Icon(entry.icon, color: Colors.white, size: 18),
            ),
            if (!isLast)
              Container(width: 2, height: 132, color: const Color(0xFFE2E8F0)),
          ],
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Ink(
                padding: const EdgeInsets.all(18),
                decoration: logbookCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: entry.color,
                            ),
                          ),
                        ),
                        Text(
                          '${fullDate(entry.time)}\n${timeWib(entry.time)}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 11,
                            color: logbookMuted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                    if (entry.sender != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        entry.sender!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: logbookInk,
                        ),
                      ),
                    ],
                    if (entry.summary != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        entry.summary!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: logbookBody, height: 1.5),
                      ),
                    ],
                    if (onTap != null)
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            color: logbookPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
