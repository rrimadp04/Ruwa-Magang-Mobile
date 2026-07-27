import 'package:flutter/material.dart';

const _blue = Color(0xFF0757D8);
const _ink = Color(0xFF10213A);

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Nilai & Sertifikat",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Lihat hasil penilaian dan sertifikat magang Anda.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xff667085),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xffEAF2FF),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded, color: _blue),
            ),
          ),
        ],
      ),
    );
  }
}
