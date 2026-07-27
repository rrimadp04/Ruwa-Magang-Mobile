import 'package:flutter/material.dart';

import '../model/review_model.dart';
import '../model/logbook_model.dart';
import '../repository/logbook_repository.dart';
import '../widget/custom_appbar.dart';
import '../widget/logbook_ui.dart';
import 'edit_logbook_screen.dart';

class DetailFeedbackScreen extends StatelessWidget {
  const DetailFeedbackScreen({super.key, required this.review, this.logbook, this.repository});
  final ReviewModel review;
  final LogbookModel? logbook;
  final LogbookRepository? repository;

  @override
  Widget build(BuildContext context) {
    final color = review.requiresRevision ? logbookDanger : review.isApproved ? logbookSuccess : logbookPrimary;
    final soft = review.requiresRevision ? logbookDangerSoft : review.isApproved ? logbookSuccessSoft : logbookPrimarySoft;
    return Scaffold(
      backgroundColor: logbookBackground,
      appBar: const CustomAppbar(title: 'Detail Feedback'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: logbookCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(backgroundColor: color, child: const Icon(Icons.person_outline_rounded, color: Colors.white)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(review.reviewer, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: logbookInk)),
                          Text(review.role, style: const TextStyle(fontSize: 12, color: logbookMuted)),
                        ],
                      ),
                    ),
                    _StatusBadge(review: review),
                  ],
                ),
                const Divider(height: 28, color: logbookBorder),
                _InfoRow(icon: Icons.business_outlined, label: 'Instansi', value: review.institution),
                const SizedBox(height: 12),
                _InfoRow(icon: Icons.calendar_today_outlined, label: 'Tanggal Review', value: fullDate(review.createdAt)),
                const SizedBox(height: 12),
                _InfoRow(icon: Icons.schedule_rounded, label: 'Jam Review', value: timeWib(review.createdAt)),
                const SizedBox(height: 18),
                const Text('Komentar Lengkap', style: TextStyle(fontWeight: FontWeight.w800, color: logbookInk)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: soft, borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: .22))),
                  child: Text(review.message, style: const TextStyle(color: logbookBody, height: 1.6, fontSize: 14)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: logbookCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Checklist Review', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: logbookInk)),
                const SizedBox(height: 14),
                if (review.checklist.isEmpty)
                  const Text('Belum ada checklist review.', style: TextStyle(color: logbookMuted))
                else
                  ...review.checklist.map((item) => _ChecklistRow(item: item)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: review.requiresRevision && logbook?.canEdit == true && repository != null
          ? SafeArea(
              minimum: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditLogbookScreen(repository: repository!, item: logbook!)),
                ),
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Edit Logbook'),
                style: FilledButton.styleFrom(backgroundColor: logbookPrimary, minimumSize: const Size.fromHeight(52)),
              ),
            )
          : null,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 18, color: logbookPrimary),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(color: logbookMuted, fontSize: 12))),
          Text(value, style: const TextStyle(color: logbookInk, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      );
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.item});
  final ReviewChecklist item;

  @override
  Widget build(BuildContext context) {
    final color = item.passed ? logbookSuccess : logbookDanger;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.passed ? Icons.check_circle_rounded : Icons.cancel_rounded, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13)),
                if (item.note != null) ...[
                  const SizedBox(height: 3),
                  Text(item.note!, style: const TextStyle(color: logbookMuted, fontSize: 12, height: 1.35)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.review});
  final ReviewModel review;

  @override
  Widget build(BuildContext context) {
    final label = switch (review.effectiveStatus) {
      ReviewStatus.revision => 'Perlu Revisi',
      ReviewStatus.approved => 'Disetujui',
      ReviewStatus.resubmitted => 'Dikirim Ulang',
      ReviewStatus.pending => 'Menunggu',
    };
    final color = review.requiresRevision ? logbookDanger : review.isApproved ? logbookSuccess : logbookPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
    );
  }
}
