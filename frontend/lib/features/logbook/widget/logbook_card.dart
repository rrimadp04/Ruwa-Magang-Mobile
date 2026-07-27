import 'package:flutter/material.dart';

import '../model/attachment_model.dart';
import '../model/logbook_model.dart';
import 'logbook_ui.dart';
import 'status_chip.dart';

class LogbookCard extends StatefulWidget {
  const LogbookCard({super.key, required this.item, required this.onTap});

  final LogbookModel item;
  final VoidCallback onTap;

  @override
  State<LogbookCard> createState() => _LogbookCardState();
}

class _LogbookCardState extends State<LogbookCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => AnimatedScale(
        scale: _pressed ? .985 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: _pressed ? .10 : .04),
                blurRadius: _pressed ? 18 : 10,
                offset: Offset(0, _pressed ? 8 : 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: widget.onTap,
              onTapDown: (_) => setState(() => _pressed = true),
              onTapCancel: () => setState(() => _pressed = false),
              onTapUp: (_) => setState(() => _pressed = false),
              borderRadius: BorderRadius.circular(20),
              child: Ink(
                padding: const EdgeInsets.all(16),
                decoration: logbookCardDecoration(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _dateBox(),
                    const SizedBox(width: 14),
                    Expanded(child: _content()),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget _content() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, height: 1.25, color: logbookInk),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.schedule_outlined, size: 13, color: logbookMuted),
                  const SizedBox(width: 4),
                  Text(timeWib(widget.item.activityDate), style: const TextStyle(fontSize: 11, color: logbookMuted)),
                ],
              ),
              StatusChip(status: widget.item.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(widget.item.activityDescription, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: logbookMuted, height: 1.5)),
          if (widget.item.attachments.isNotEmpty || widget.item.commentCount > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (widget.item.attachments.isNotEmpty) _attachmentHint(widget.item.attachments.first),
                if (widget.item.attachments.isNotEmpty && widget.item.commentCount > 0) const SizedBox(width: 10),
                if (widget.item.commentCount > 0) const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: logbookMuted),
                if (widget.item.commentCount > 0) const SizedBox(width: 5),
                if (widget.item.commentCount > 0) Text('${widget.item.commentCount} komentar', style: const TextStyle(fontSize: 11, color: logbookMuted)),
              ],
            ),
          ],
        ],
      );

  Widget _attachmentHint(AttachmentModel attachment) => Container(
        width: 24,
        height: 24,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: logbookPrimarySoft, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFD8E6FF))),
        child: attachment.hasLocalBytes
            ? Image.memory(attachment.bytes!, fit: BoxFit.cover)
            : attachment.hasNetworkUrl
            ? Image.network(attachment.url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imageIcon())
            : _imageIcon(),
      );

  Widget _imageIcon() => const Icon(Icons.image_outlined, size: 14, color: logbookPrimary);

  Widget _dateBox() => Container(
        width: 58,
        height: 66,
        decoration: BoxDecoration(color: logbookPrimarySoft, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFD8E6FF))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${widget.item.activityDate.day}'.padLeft(2, '0'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: logbookPrimary)),
            const SizedBox(height: 2),
            Text(shortMonth(widget.item.activityDate), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: logbookPrimary)),
          ],
        ),
      );
}
