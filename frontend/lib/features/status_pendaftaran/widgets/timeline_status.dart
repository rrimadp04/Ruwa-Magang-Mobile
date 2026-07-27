import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class TimelineStatus extends StatelessWidget {
  const TimelineStatus({super.key, required this.steps, required this.currentStep});

  final List<String> steps;
  final int currentStep;

  @override
  Widget build(BuildContext context) => Column(
    children: List.generate(steps.length, (i) {
      final done = i < currentStep;
      final active = i == currentStep;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done || active ? AppColors.primary : AppColors.border,
                ),
                child: Icon(
                  done ? Icons.check : Icons.circle,
                  size: 14,
                  color: AppColors.white,
                ),
              ),
              if (i < steps.length - 1)
                Container(width: 2, height: 32, color: done ? AppColors.primary : AppColors.border),
            ],
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              steps[i],
              style: TextStyle(
                color: active ? AppColors.primary : done ? AppColors.ink : AppColors.grey,
                fontWeight: active ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ),
        ],
      );
    }),
  );
}
