import 'package:flutter/material.dart';
import '../model/logbook_model.dart';
import 'logbook_ui.dart';
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});
  final LogbookStatus status;
  @override Widget build(BuildContext context) {
    final color = logbookStatusColor(status);
    final icon = switch (status) { LogbookStatus.draft => Icons.edit_note_rounded, LogbookStatus.pending => Icons.schedule_rounded, LogbookStatus.revision => Icons.error_outline_rounded, LogbookStatus.approved => Icons.check_circle_rounded };
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(999), border: Border.all(color: color.withValues(alpha: .16))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: color, size: 14), const SizedBox(width: 5), Text(logbookStatusLabel(status), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800))]),
    );
  }
}
