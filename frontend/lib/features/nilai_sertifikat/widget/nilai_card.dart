import 'package:flutter/material.dart';
import 'status_chip.dart';

const _blue = Color(0xFF0757D8);
const _ink = Color(0xFF10213A);

class NilaiCard extends StatelessWidget {
  final double nilai;
  final String predikat;
  final String status;
  final String reviewer;
  final String tanggal;
  final VoidCallback onDetail;

  const NilaiCard({
    super.key,
    required this.nilai,
    required this.predikat,
    required this.status,
    required this.reviewer,
    required this.tanggal,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          /// Trophy
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(35),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: _blue,
              size: 36,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Nilai Akhir",
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),

          const SizedBox(height: 18),

          /// Score Circle
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF2F73E6), Color(0xFF0757D8)],
              ),
            ),
            child: Center(
              child: Text(
                nilai.toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 38,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            predikat,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: _ink,
            ),
          ),

          const SizedBox(height: 12),

          StatusChip(status: status),

          const SizedBox(height: 28),

          const Divider(),

          const SizedBox(height: 20),

          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.people_alt_outlined, color: _blue),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Reviewer",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reviewer,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  color: _blue,
                  size: 20,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tanggal Review",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tanggal,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onDetail,
              style: FilledButton.styleFrom(
                backgroundColor: _blue,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.visibility_outlined),
              label: const Text(
                "Lihat Detail Penilaian",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
