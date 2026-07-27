import 'package:flutter/material.dart';

import 'logbook_ui.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.total,
    required this.approved,
    required this.pending,
    required this.revision,
  });

  final int total;
  final int approved;
  final int pending;
  final int revision;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) => Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1D4ED8), logbookPrimary, Color(0xFF60A5FA)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3D2563EB),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ringkasan aktivitas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Pantau perkembangan logbook magangmu',
                          style: TextStyle(color: Color(0xFFDCEBFF), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .16),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.auto_graph_rounded, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) => Row(
                  children: [
                    _stat('Total', total, value),
                    _divider(),
                    _stat('Disetujui', approved, value),
                    _divider(),
                    _stat('Menunggu', pending, value),
                    _divider(),
                    _stat('Revisi', revision, value),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _divider() => Container(height: 40, width: 1, color: Colors.white24);

  Widget _stat(String label, int number, double animation) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${(number * animation).round()}',
                style: const TextStyle(
                  fontSize: 24,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFDCEBFF),
                ),
              ),
            ),
          ],
        ),
      );
}
