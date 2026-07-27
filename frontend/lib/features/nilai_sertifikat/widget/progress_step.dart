import 'package:flutter/material.dart';

const _blue = Color(0xFF0757D8);

class ProgressStep extends StatelessWidget {
  final String title;
  final bool completed;
  final bool isLast;

  const ProgressStep({
    super.key,
    required this.title,
    required this.completed,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: completed ? _blue : Colors.grey.shade300,
                child: Icon(
                  completed ? Icons.check : Icons.radio_button_unchecked,
                  color: Colors.white,
                  size: 15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (!isLast)
            Expanded(
              child: Container(
                height: 3,
                margin: const EdgeInsets.only(bottom: 24, left: 8, right: 8),
                color: completed ? _blue : Colors.grey.shade300,
              ),
            ),
        ],
      ),
    );
  }
}
