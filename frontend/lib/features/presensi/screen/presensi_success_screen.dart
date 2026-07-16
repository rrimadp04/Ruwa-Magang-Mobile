import 'package:flutter/material.dart';

import '../model/presensi.dart';

const _blue = Color(0xFF0757D8);

class PresensiSuccessScreen extends StatelessWidget {
  const PresensiSuccessScreen({
    super.key,
    required this.item,
    required this.action,
    required this.onBack,
  });

  final Presensi item;
  final PresensiAction action;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final izin = action == PresensiAction.izin;
    final pulang = action == PresensiAction.pulang;
    final title = izin
        ? 'Permohonan Izin\nBerhasil Dikirim!'
        : pulang
        ? 'Presensi Pulang\nBerhasil!'
        : 'Presensi Datang\nBerhasil!';
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back, color: _blue),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Presensi',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const Spacer(),
              Container(
                width: 112,
                height: 112,
                decoration: const BoxDecoration(
                  color: Color(0xFFBDD0F7),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircleAvatar(
                    radius: 42,
                    backgroundColor: _blue,
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 54,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: izin ? 29 : 30,
                  height: 1.2,
                  color: pulang ? _blue : const Color(0xFF10213A),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                izin
                    ? 'Terima kasih. Permohonan Anda telah masuk ke sistem kami dan sedang dalam antrean peninjauan.'
                    : pulang
                    ? 'Terima kasih atas dedikasi Anda hari ini.'
                    : '${_date(item.createdAt)}  •  ${_time(item.createdAt)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF60677A),
                  fontSize: 16,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 30),
              _detailCard(izin, pulang),
              const Spacer(),
              FilledButton.icon(
                onPressed: onBack,
                style: FilledButton.styleFrom(
                  backgroundColor: _blue,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(izin ? Icons.arrow_back : Icons.home_outlined),
                label: Text(
                  izin ? 'Kembali ke Presensi' : 'Kembali ke Beranda',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'PRESENSI MAGANG',
                style: TextStyle(
                  color: _blue,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '© 2026 Ruwa Magang. All Rights Reserved.',
                style: TextStyle(color: Color(0xFF687386)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailCard(bool izin, bool pulang) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFD0D9E9)),
      borderRadius: BorderRadius.circular(13),
    ),
    child: izin
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Keterangan Izin',
                style: TextStyle(fontSize: 12, color: Color(0xFF5D6675)),
              ),
              const SizedBox(height: 8),
              Text(
                item.note ?? 'Permohonan izin telah dikirim.',
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
              const Divider(height: 30),
              const Text(
                'STATUS SAAT INI',
                style: TextStyle(fontSize: 10, color: Color(0xFF697386)),
              ),
              const SizedBox(height: 6),
              const Chip(
                label: Text('Menunggu Persetujuan'),
                avatar: Icon(Icons.more_horiz, size: 18, color: _blue),
                backgroundColor: Color(0xFFE4EDFF),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pulang ? 'Pulang Kantor' : 'Datang (Arrival)',
                style: TextStyle(
                  color: pulang ? const Color(0xFFC44B1A) : _blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'LOKASI PRESENSI',
                style: TextStyle(fontSize: 10, color: Color(0xFF697386)),
              ),
              const SizedBox(height: 4),
              const Text(
                'Lokasi Magang',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Divider(height: 28),
              Row(
                children: [
                  Expanded(
                    child: _metric(
                      'JARAK',
                      item.locationDistanceMeters == null
                          ? '-'
                          : '${item.locationDistanceMeters} meter',
                    ),
                  ),
                  Expanded(
                    child: _metric(
                      'AKURASI GPS',
                      item.locationAccuracy == null
                          ? '-'
                          : '±${item.locationAccuracy} meter',
                    ),
                  ),
                ],
              ),
            ],
          ),
  );

  Widget _metric(String label, String value) => Container(
    padding: const EdgeInsets.all(11),
    margin: const EdgeInsets.only(right: 7),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F4FF),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF748097)),
        ),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
}

String _time(DateTime value) =>
    '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}:${value.second.toString().padLeft(2, '0')}';
String _date(DateTime value) =>
    '${const ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'][value.weekday - 1]}, ${value.day} ${const ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'][value.month - 1]} ${value.year}';
