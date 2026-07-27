import 'package:flutter/material.dart';

import 'progress_step.dart';

const _blue = Color(0xFF0757D8);

class ProgressCard extends StatelessWidget {
  final double progress;

  const ProgressCard({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Progress Penyelesaian Magang",
            style: TextStyle(
              fontSize: 15,
              color: Color(0xff667085),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            "${(progress * 100).toInt()}%",
            style: const TextStyle(
              fontSize: 38,
              color: _blue,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xffE5E7EB),
              valueColor:
                  const AlwaysStoppedAnimation(_blue),
            ),
          ),

          const SizedBox(height: 25),

          const Row(
            children: [
              ProgressStep(
                title: "Presensi",
                completed: true,
              ),
              ProgressStep(
                title: "Logbook",
                completed: true,
              ),
              ProgressStep(
                title: "Penilaian",
                completed: true,
              ),
              ProgressStep(
                title: "Sertifikat",
                completed: false,
                isLast: true,
              ),
            ],
          )
        ],
      ),
    );
  }
}