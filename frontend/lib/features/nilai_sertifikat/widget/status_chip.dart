import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {

  final String status;

  const StatusChip({
    super.key,
    required this.status,
  });

  Color get color {

    switch (status.toLowerCase()) {

      case "disetujui":
        return const Color(0xff16A34A);

      case "menunggu":
        return const Color(0xffF59E0B);

      case "ditolak":
        return const Color(0xffDC2626);

      default:
        return Colors.grey;

    }

  }

  IconData get icon {

    switch (status.toLowerCase()) {

      case "disetujui":
        return Icons.check_circle;

      case "menunggu":
        return Icons.schedule;

      case "ditolak":
        return Icons.cancel;

      default:
        return Icons.info;

    }

  }

  @override
  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

      decoration: BoxDecoration(

        color: color.withValues(alpha: .1),

        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .16)),

      ),

      child: Row(

        mainAxisSize: MainAxisSize.min,

        children: [

          Icon(
            icon,
            color: color,
            size: 15,
          ),

          const SizedBox(width: 6),

          Text(

            status,

            style: TextStyle(

              color: color,

              fontSize: 12,
              fontWeight: FontWeight.w800,

            ),

          ),

        ],

      ),

    );

  }

}
