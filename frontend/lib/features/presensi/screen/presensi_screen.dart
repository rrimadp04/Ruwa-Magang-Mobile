import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../model/presensi.dart';
import '../repository/presensi_repository.dart';
import '../service/presensi_service.dart';
import 'presensi_success_screen.dart';
import 'selfie_camera_screen.dart';

const _blue = Color(0xFF0757D8);

class PresensiScreen extends StatefulWidget {
  const PresensiScreen({super.key, required this.repository});
  final PresensiRepository repository;

  @override
  State<PresensiScreen> createState() => _PresensiScreenState();
}

class _PresensiScreenState extends State<PresensiScreen> {
  List<Presensi> _history = [];
  bool _loading = true;
  String? _error;
  int _page = 0;
  PresensiAction? _selectedAction;
  Position? _position;
  XFile? _photo;
  Uint8List? _photoBytes;
  Presensi? _submittedPresensi;
  bool _internshipFinished = false;
  bool _locationRejected = false;
  String? _locationProblem;
  final _note = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final history = await widget.repository.getHistory();
      if (mounted) {
        setState(() {
          _history = history;
        });
      }
      _loadInternshipStatus();
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Tidak dapat memuat riwayat presensi.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadInternshipStatus() async {
    try {
      final finished = await widget.repository.isInternshipFinished();
      if (mounted) setState(() => _internshipFinished = finished);
    } catch (_) {
      // Status akhir magang tidak boleh menghalangi halaman presensi dibuka.
    }
  }

  PresensiAction get _todayAction {
    final now = DateTime.now();
    final today = _history.where(
      (item) =>
          item.presensiDate.year == now.year &&
          item.presensiDate.month == now.month &&
          item.presensiDate.day == now.day,
    );
    final hasHadir = today.any(
      (item) => item.status == 'hadir' || item.type == 'datang',
    );
    final hasPulang = today.any(
      (item) => item.status == 'pulang' || item.type == 'pulang',
    );
    final hasClosed = today.any(
      (item) => item.status == 'izin' || item.status == 'alfa',
    );
    if (hasClosed || (hasHadir && hasPulang)) return PresensiAction.selesai;
    return hasHadir ? PresensiAction.pulang : PresensiAction.hadir;
  }

  Future<void> _openForm(PresensiAction action) async {
    if (action == PresensiAction.selesai) return;
    setState(() {
      _selectedAction = action;
      _photo = null;
      _photoBytes = null;
      _locationRejected = false;
      _locationProblem = null;
      _position = null;
      _note.clear();
      _page = 1;
    });
    await _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const ApiException('Layanan lokasi perangkat belum aktif.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw const ApiException('Izin lokasi diperlukan untuk presensi.');
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (mounted) {
        setState(() {
          _position = position;
          _locationProblem = null;
        });
      }
    } on ApiException catch (error) {
      if (mounted) setState(() => _locationProblem = error.message);
      _show(error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _locationProblem = 'GPS belum aktif atau lokasi tidak tersedia.',
        );
      }
      _show('Lokasi saat ini tidak dapat diambil. Coba lagi.');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final image = await Navigator.of(context).push<XFile>(
        MaterialPageRoute(builder: (_) => const SelfieCameraScreen()),
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        if (mounted) {
          setState(() {
            _photo = image;
            _photoBytes = bytes;
          });
        }
      }
    } catch (_) {
      _show(
        'Aplikasi belum memiliki izin kamera. Izinkan kamera lalu coba lagi.',
      );
    }
  }

  Future<void> _submit() async {
    final action = _selectedAction!;
    if (action == PresensiAction.izin && _note.text.trim().isEmpty) {
      _show('Alasan izin wajib diisi.');
      return;
    }
    if (action != PresensiAction.izin && _photo == null) {
      _show('Foto selfie wajib diambil.');
      return;
    }
    if (_position == null) {
      _show('Lokasi GPS wajib diperbarui.');
      return;
    }
    setState(() => _loading = true);
    try {
      String? image;
      if (_photo != null) {
        image = 'data:image/jpeg;base64,${base64Encode(_photoBytes!)}';
      }
      final submitted = await widget.repository.submit(
        action: action,
        latitude: _position?.latitude ?? 0,
        longitude: _position?.longitude ?? 0,
        accuracy: _position?.accuracy ?? 0,
        photoBase64: image,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _submittedPresensi = submitted;
        _page = 3;
      });
      await _load();
    } on ApiException catch (error) {
      if (error.message.toLowerCase().contains('radius') ||
          error.message.toLowerCase().contains('lokasi')) {
        if (mounted) {
          setState(() {
            _locationRejected = true;
            _locationProblem = error.message;
          });
        }
      }
      _submitError(error.message);
    } catch (_) {
      _submitError('Gagal mengirim presensi. Periksa koneksi internet Anda.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _show(String message, {bool success = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success
              ? const Color(0xFF08794D)
              : const Color(0xFFB42318),
        ),
      );

  void _submitError(String message) {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error_outline, color: Color(0xFFC21F28)),
        title: const Text('Presensi Gagal'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _getLocation();
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: _internshipFinished
          ? _internshipEnd()
          : _isWeekend
          ? _holiday()
          : switch (_page) {
              0 => _home(),
              1 => _form(),
              2 => _detail(),
              _ => PresensiSuccessScreen(
                item: _submittedPresensi!,
                action: _selectedAction!,
                onBack: () => setState(() => _page = 0),
              ),
            },
    ),
  );

  bool get _isWeekend =>
      DateTime.now().weekday == DateTime.saturday ||
      DateTime.now().weekday == DateTime.sunday;

  Widget _home() {
    final action = _todayAction;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _header('Presensi'),
          const SizedBox(height: 22),
          _scheduleCard(),
          const SizedBox(height: 80),
          Center(
            child: InkWell(
              onTap: () => _openForm(action),
              borderRadius: BorderRadius.circular(120),
              child: Ink(
                width: 194,
                height: 194,
                decoration: BoxDecoration(
                  color: action == PresensiAction.selesai ? Colors.grey : _blue,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x440757D8),
                      blurRadius: 28,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.fingerprint_rounded,
                      color: Colors.white,
                      size: 55,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 42),
          Center(
            child: _pill(
              action == PresensiAction.selesai
                  ? 'Presensi Hari Ini Selesai'
                  : action == PresensiAction.pulang
                  ? 'Absen masuk telah tercatat'
                  : 'Belum melakukan absen datang',
              action == PresensiAction.selesai
                  ? Colors.green
                  : const Color(0xFFC21F28),
            ),
          ),
          const SizedBox(height: 70),
          OutlinedButton.icon(
            onPressed: () => setState(() => _page = 2),
            icon: const Icon(Icons.assessment_outlined),
            label: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Lihat Rincian\n',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(18),
              alignment: Alignment.centerLeft,
              side: const BorderSide(color: Color(0xFFE0E7F2)),
              backgroundColor: Colors.white,
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _errorState(),
            ),
        ],
      ),
    );
  }

  Widget _form() {
    final isIzin = _selectedAction == PresensiAction.izin;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _header('Presensi', back: () => setState(() => _page = 0)),
        const SizedBox(height: 28),
        _tabs(isIzin),
        const SizedBox(height: 24),
        _info(
          isIzin
              ? 'Ajukan izin jika Anda tidak dapat melakukan presensi kehadiran secara langsung.'
              : 'Pastikan Anda berada dalam radius lokasi kantor dan ambil foto dengan jelas.',
        ),
        const SizedBox(height: 26),
        if (isIzin) _izinForm() else _attendanceForm(),
        const SizedBox(height: 40),
        FilledButton(
          onPressed: _loading || _locationRejected ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: _blue,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            _selectedAction == PresensiAction.izin
                ? 'Kirim Permohonan'
                : 'Kirim Presensi ${_selectedAction == PresensiAction.pulang ? 'Pulang' : 'Datang'}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _holiday() => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        _header('Presensi', back: () => Navigator.maybePop(context)),
        const Spacer(),
        Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFDCEBFF),
            borderRadius: BorderRadius.circular(44),
          ),
          child: const Center(
            child: Icon(Icons.weekend_outlined, size: 120, color: _blue),
          ),
        ),
        const SizedBox(height: 46),
        const Text(
          'Hari Ini Libur',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w800,
            color: Color(0xFF10213A),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Presensi tidak tersedia pada hari Sabtu dan Minggu. Selamat beristirahat!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF616B7B), fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 44),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              CircleAvatar(
                backgroundColor: Color(0xFFDDE8FF),
                child: Icon(Icons.event_busy_outlined, color: _blue),
              ),
              SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STATUS HARI INI',
                    style: TextStyle(fontSize: 11, color: Color(0xFF748097)),
                  ),
                  Text(
                    'Libur Akhir Pekan',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        FilledButton.icon(
          onPressed: () => Navigator.maybePop(context),
          style: FilledButton.styleFrom(
            backgroundColor: _blue,
            minimumSize: const Size.fromHeight(55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.arrow_back),
          label: const Text(
            'Kembali',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const Spacer(),
      ],
    ),
  );

  Widget _internshipEnd() => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        _header('Presensi', back: () => Navigator.maybePop(context)),
        const Spacer(),
        Container(
          height: 185,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFDFEBFF), Color(0xFFF6F9FF)],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(
            child: Icon(
              Icons.school_rounded,
              size: 110,
              color: Color(0xFF164C9B),
            ),
          ),
        ),
        const SizedBox(height: 95),
        const Text(
          'Masa Magang Telah\nBerakhir',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 29,
            height: 1.15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF10213A),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Terima kasih telah mengikuti program magang. Presensi sudah tidak dapat dilakukan.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Color(0xFF616B7B), height: 1.5),
        ),
        const SizedBox(height: 46),
        FilledButton.icon(
          onPressed: () => setState(() => _page = 2),
          style: FilledButton.styleFrom(
            backgroundColor: _blue,
            minimumSize: const Size.fromHeight(55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.history),
          label: const Text(
            'Lihat Riwayat Presensi',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 26),
        const Text(
          'Sertifikat Anda akan dikirimkan melalui email yang terdaftar.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF747C8C), fontSize: 12),
        ),
        const Spacer(),
        const Text(
          'PRESENSI MAGANG',
          style: TextStyle(
            fontSize: 12,
            color: _blue,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '© 2026 Ruwa Magang. All Rights Reserved.',
          style: TextStyle(color: Color(0xFF687386)),
        ),
      ],
    ),
  );

  Widget _detail() {
    final hadir = _history.where(
      (item) => item.status == 'hadir' || item.type == 'datang',
    ).length;
    final pulang = _history.where(
      (item) => item.status == 'pulang' || item.type == 'pulang',
    ).length;
    final izin = _history.where((item) => item.status == 'izin').length;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        children: [
          _header('Rincian Presensi', back: () => setState(() => _page = 0)),
          const SizedBox(height: 20),
          Text(
            _detailDate(DateTime.now()),
            style: const TextStyle(color: Color(0xFF687386), fontSize: 14),
          ),
          const SizedBox(height: 16),
          _recapSummary(hadir: hadir, pulang: pulang, izin: izin),
          const SizedBox(height: 26),
          const Text(
            'Riwayat Presensi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF10213A),
            ),
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(top: 50),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            _errorState()
          else if (_history.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 58),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_note_outlined,
                      size: 58,
                      color: Color(0xFF64748B),
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Belum ada riwayat presensi',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Riwayat akan tampil setelah presensi berhasil dikirim.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF687386)),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._history.map(_historyDetailCard),
        ],
      ),
    );
  }

  Widget _recapSummary({
    required int hadir,
    required int pulang,
    required int izin,
  }) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [_blue, Color(0xFF2F73E6)]),
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(
          color: Color(0x330757D8),
          blurRadius: 16,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.fact_check_outlined, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'RINGKASAN PRESENSI',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _summaryMetric('Masuk', hadir),
            _summaryMetric('Pulang', pulang),
            _summaryMetric('Izin', izin),
          ],
        ),
      ],
    ),
  );

  Widget _summaryMetric(String label, int value) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$value',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    ),
  );

  Widget _historyDetailCard(Presensi item) {
    final isIzin = item.status == 'izin';
    final isPulang = item.status == 'pulang' || item.type == 'pulang';
    final title = isIzin ? 'Izin' : isPulang ? 'Presensi Pulang' : 'Presensi Masuk';
    final color = isIzin
        ? const Color(0xFFE28A15)
        : isPulang
        ? const Color(0xFFC44B1A)
        : const Color(0xFF08794D);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E7F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isIzin ? Icons.event_available_outlined : Icons.fingerprint,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(
                      '${_detailDate(item.presensiDate)} • ${_detailTime(item.createdAt)} WIB',
                      style: const TextStyle(color: Color(0xFF687386), fontSize: 12),
                    ),
                  ],
                ),
              ),
              _statusPill(item.status, color),
            ],
          ),
          const Divider(height: 26),
          if (item.locationDistanceMeters != null || item.locationAccuracy != null)
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: _blue),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    item.locationDistanceMeters == null
                        ? 'Akurasi GPS: ±${item.locationAccuracy} meter'
                        : 'Jarak ${item.locationDistanceMeters} meter • Akurasi ±${item.locationAccuracy ?? '-'} meter',
                    style: const TextStyle(color: Color(0xFF536176), fontSize: 12),
                  ),
                ),
              ],
            ),
          if (item.note != null && item.note!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              item.note!,
              style: const TextStyle(color: Color(0xFF536176), height: 1.35),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusPill(String status, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      status.isEmpty ? 'Tercatat' : '${status[0].toUpperCase()}${status.substring(1)}',
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
    ),
  );

  Widget _attendanceForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Foto Selfie', style: TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      InkWell(
        onTap: _takePhoto,
        child: Container(
          height: 270,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF0FF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFBFC9DF),
              style: BorderStyle.solid,
            ),
          ),
          child: _photoBytes == null
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: _blue,
                        size: 35,
                      ),
                    ),
                    SizedBox(height: 18),
                    Text(
                      'Ketuk untuk mengambil foto',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text('Gunakan kamera selfie'),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.memory(
                    _photoBytes!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
      ),
      if (_photoBytes != null) ...[
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.refresh),
                label: const Text('Ulang Foto'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => setState(() {}),
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Pakai Foto'),
              ),
            ),
          ],
        ),
      ],
      const SizedBox(height: 24),
      _locationCard(),
    ],
  );

  Widget _izinForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Alasan Izin *',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _note,
        maxLength: 200,
        maxLines: 5,
        decoration: const InputDecoration(
          hintText: 'Tuliskan alasan izin Anda di sini...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      const SizedBox(height: 18),
      const Text(
        'Upload Bukti *',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 8),
      Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFBFC9DF),
            style: BorderStyle.solid,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFFE8F0FF),
              child: Icon(Icons.file_upload_outlined, color: _blue),
            ),
            SizedBox(height: 10),
            Text(
              'Bukti pendukung mengikuti data presensi API',
              style: TextStyle(
                color: _blue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'JPG, PNG, PDF (maks. 5MB)',
              style: TextStyle(color: Color(0xFF748097), fontSize: 11),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      const Text(
        'Lokasi Saat Ini',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 8),
      _locationCard(),
    ],
  );

  Widget _locationCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lokasi Saat Ini',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'KOORDINAT GPS',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF8A94A6),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _position == null
                    ? 'Lokasi belum tersedia'
                    : '${_position!.latitude.toStringAsFixed(6)}, ${_position!.longitude.toStringAsFixed(6)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        if (_position != null)
          Text(
            'Akurasi GPS: ±${_position!.accuracy.round()} meter',
            style: const TextStyle(color: Color(0xFF536176)),
          ),
        if (_locationProblem != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _locationRejected
                  ? const Color(0xFFFFEEEE)
                  : const Color(0xFFFFF5E9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _locationRejected
                    ? const Color(0xFFFFC9C9)
                    : const Color(0xFFFFDEB0),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _locationRejected
                      ? Icons.cancel
                      : Icons.warning_amber_rounded,
                  color: _locationRejected
                      ? const Color(0xFFF04444)
                      : const Color(0xFFE28A15),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _locationProblem!,
                    style: TextStyle(
                      color: _locationRejected
                          ? const Color(0xFFD92D20)
                          : const Color(0xFF994C00),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else if (_position != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF9EF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD4EED7)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF42A85F), size: 18),
                SizedBox(width: 8),
                Text(
                  'Lokasi siap diverifikasi oleh server',
                  style: TextStyle(
                    color: Color(0xFF36914E),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _getLocation,
          icon: const Icon(Icons.refresh),
          label: const Text('Perbarui Lokasi'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(46),
          ),
        ),
      ],
    ),
  );

  Widget _tabs(bool isIzin) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xFFE7EEFC),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Expanded(child: _tab('Datang', !isIzin, () => _openForm(_todayAction))),
        Expanded(
          child: _tab('Izin', isIzin, () => _openForm(PresensiAction.izin)),
        ),
      ],
    ),
  );
  Widget _tab(String label, bool active, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Container(
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? _blue : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : const Color(0xFF536176),
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    ),
  );
  Widget _header(String title, {VoidCallback? back}) => Row(
    children: [
      IconButton(
        onPressed: back ?? () {},
        icon: const Icon(Icons.arrow_back, color: _blue),
      ),
      const SizedBox(width: 8),
      Text(
        title,
        style: const TextStyle(
          color: _blue,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
  Widget _scheduleCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x160757D8),
          blurRadius: 12,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HARI & TANGGAL',
          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        Text(
          'Presensi Hari Ini',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Jam Masuk\n08.00 WIB'),
            Text('Jam Pulang\n16.00 WIB'),
          ],
        ),
      ],
    ),
  );
  Widget _info(String text) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFEEF4FF),
      border: Border.all(color: const Color(0xFFC8D7FA)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, color: _blue),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(color: Color(0xFF536176))),
        ),
      ],
    ),
  );
  Widget _pill(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F3F7),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Text(text, style: TextStyle(color: color, fontSize: 12)),
  );
  Widget _errorState() => Center(
    child: Column(
      children: [
        Text(
          _error!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFB42318)),
        ),
        TextButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.refresh),
          label: const Text('Coba lagi'),
        ),
      ],
    ),
  );
}

String _detailTime(DateTime value) =>
    '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

String _detailDate(DateTime value) =>
    '${const ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'][value.weekday - 1]}, ${value.day} ${const ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'][value.month - 1]} ${value.year}';
