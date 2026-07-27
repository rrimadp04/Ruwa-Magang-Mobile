import 'package:flutter/material.dart';

const _blue = Color(0xFF0757D8);

class SertifikatCard extends StatelessWidget {
  final bool tersedia;
  final String nama;
  final VoidCallback onPressed;

  const SertifikatCard({
    super.key,
    required this.tersedia,
    required this.nama,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(blurRadius: 10, color: Color(0x14000000))],
      ),
      child: Column(
        children: [
          Icon(
            tersedia ? Icons.verified : Icons.workspace_premium_outlined,
            size: 70,
            color: tersedia ? Colors.green : Colors.orange,
          ),

          const SizedBox(height: 15),

          Text(
            tersedia ? "Sertifikat Tersedia" : "Sertifikat Belum Tersedia",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Text(
            tersedia
                ? nama
                : "Selesaikan seluruh proses magang agar sertifikat dapat diterbitkan.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, height: 1.5),
          ),

          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: _blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(tersedia ? Icons.visibility : Icons.refresh),
              label: Text(tersedia ? "Lihat Sertifikat" : "Cek Status"),
            ),
          ),
        ],
      ),
    );
  }
}
