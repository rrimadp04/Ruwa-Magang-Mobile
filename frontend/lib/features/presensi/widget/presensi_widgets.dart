import 'package:flutter/material.dart';

import '../model/presensi.dart';

const _blue = Color(0xFF0757D8);

class AttendanceHistoryTile extends StatelessWidget {
  const AttendanceHistoryTile({
    super.key,
    required this.item,
    required this.imageBaseUrl,
  });

  final Presensi item;
  final String imageBaseUrl;

  @override
  Widget build(BuildContext context) {
    final photo = item.photo;
    final imageUrl = photo == null || photo.isEmpty
        ? null
        : photo.startsWith('http')
        ? photo
        : '$imageBaseUrl/${photo.replaceFirst(RegExp(r'^/'), '')}';
    final valid = item.locationValid == true;
    final label = item.type == 'datang' ? 'Datang' : item.type;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE0E7F2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E8FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${item.presensiDate.day}\n${_month(item.presensiDate.month)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: _blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _date(item.presensiDate),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${_time(item.createdAt)} • ${label[0].toUpperCase()}${label.substring(1)}',
                    style: const TextStyle(color: Color(0xFF536176)),
                  ),
                  if (item.locationDistanceMeters != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${valid ? 'Lokasi valid' : 'Lokasi tidak valid'} • ${item.locationDistanceMeters} meter',
                      style: TextStyle(
                        fontSize: 12,
                        color: valid ? const Color(0xFF18804B) : Colors.red,
                      ),
                    ),
                  ],
                  if (item.note != null && item.note!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        item.note!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF536176),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported_outlined),
                ),
              )
            else
              _StatusChip(label: item.status),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: const Color(0xFFE5F2EC),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label[0].toUpperCase() + label.substring(1),
      style: const TextStyle(
        color: Color(0xFF08794D),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

String _month(int month) => const [
  'JAN',
  'FEB',
  'MAR',
  'APR',
  'MEI',
  'JUN',
  'JUL',
  'AGU',
  'SEP',
  'OKT',
  'NOV',
  'DES',
][month - 1];
String _time(DateTime time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
String _date(DateTime date) =>
    '${const ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'][date.weekday - 1]}, ${date.day} ${const ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'][date.month - 1]} ${date.year}';
