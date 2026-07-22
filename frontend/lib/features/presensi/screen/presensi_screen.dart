import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../model/presensi.dart';
import '../repository/presensi_repository.dart';
import '../service/presensi_service.dart';
import 'presensi_success_screen.dart';
import 'selfie_camera_screen.dart';

const _blue = Color(0xFF0757D8);

/// Koordinat & radius kantor OPD untuk pre-check lokasi di sisi klien.
/// Nilainya harus sama dengan `config/presensi.php` di backend
/// (PRESENSI_OFFICE_LAT / PRESENSI_OFFICE_LNG / PRESENSI_RADIUS_METERS) —
/// keputusan akhir tetap divalidasi ulang oleh server saat submit.
const _officeLat = -5.438512;
const _officeLng = 105.258793;
const _radiusMeters = 250;

/// Tiga kondisi lokasi yang mungkin muncul di Halaman Absen
/// (mockup 02/03/04): valid, di luar radius, atau GPS mati.
enum _LocationStatus { unknown, gpsOff, invalid, valid }

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
  bool _photoConfirmed = false;
  Presensi? _submittedPresensi;
  bool _internshipFinished = false;
  _LocationStatus _locationStatus = _LocationStatus.unknown;
  int? _locationDistanceMeters;
  String? _locationAddress;
  Uint8List? _proofBytes;
  String? _proofName;
  String? _proofMimeType;
  int _recapPage = 0;
  String? _recapFilter;
  DateTimeRange? _recapDateRange;
  _DailyRecap? _selectedRecap;
  String? _submitErrorMessage;
  String _checkInTime = '07:30';
  String _checkOutTime = '16:00';
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

  Future<void> _load([DateTimeRange? range]) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await Future.wait([
        widget.repository.getHistory(start: range?.start, end: range?.end),
        widget.repository.getAttendanceSchedule(),
      ]);
      final history = result[0] as List<Presensi>;
      final schedule = result[1] as AttendanceSchedule;
      if (mounted) {
        setState(() {
          _history = history;
          _checkInTime = schedule.checkInTime;
          _checkOutTime = schedule.checkOutTime;
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
      (item) => item.status == 'izin' || item.status == 'tanpa_keterangan',
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
      _photoConfirmed = false;
      _locationStatus = _LocationStatus.unknown;
      _locationDistanceMeters = null;
      _locationAddress = null;
      _position = null;
      _proofBytes = null;
      _proofName = null;
      _proofMimeType = null;
      _note.clear();
      _page = 1;
    });
    await _getLocation();
  }

  Future<void> _getLocation() async {
    // Kondisi 1: GPS/layanan lokasi perangkat nonaktif.
    if (!await Geolocator.isLocationServiceEnabled()) {
      if (mounted) {
        setState(() {
          _locationStatus = _LocationStatus.gpsOff;
          _position = null;
        });
      }
      return;
    }
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _locationStatus = _LocationStatus.gpsOff;
            _position = null;
          });
        }
        _show('Izin lokasi diperlukan untuk presensi.');
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        _officeLat,
        _officeLng,
      ).round();
      final address = await _addressFromPosition(position);

      if (mounted) {
        setState(() {
          _position = position;
          _locationDistanceMeters = distance;
          _locationAddress = address;
          // Kondisi 2 & 3: dalam radius (valid) vs di luar radius (tidak valid).
          _locationStatus = distance <= _radiusMeters
              ? _LocationStatus.valid
              : _LocationStatus.invalid;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _locationStatus = _LocationStatus.gpsOff;
          _position = null;
        });
      }
      _show('Lokasi saat ini tidak dapat diambil. Coba lagi.');
    }
  }

  Future<String> _addressFromPosition(Position position) async {
    try {
      final places = await Geocoding().placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (places.isNotEmpty) {
        final place = places.first;
        final address = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
        ].whereType<String>().map((part) => part.trim()).where((part) => part.isNotEmpty).toSet().join(', ');
        if (address.isNotEmpty) return address;
      }
    } catch (_) {
      // GPS tetap dapat dikirim; pengguna diberi pesan alamat belum tersedia.
    }
    return 'Alamat lokasi belum dapat ditemukan';
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
            // Foto baru diambil -> belum "dipakai", tunggu pengguna
            // menekan tombol "Pakai Foto".
            _photoConfirmed = false;
          });
        }
      }
    } catch (_) {
      _show(
        'Aplikasi belum memiliki izin kamera. Izinkan kamera lalu coba lagi.',
      );
    }
  }

  /// Dipanggil saat pengguna menekan "Ulang Foto": foto dihapus dan
  /// kembali ke kondisi awal (placeholder kamera kosong).
  void _retakePhoto() {
    setState(() {
      _photo = null;
      _photoBytes = null;
      _photoConfirmed = false;
    });
  }

  /// Dipanggil saat pengguna menekan "Pakai Foto": mengunci foto
  /// yang sudah diambil agar siap dilampirkan saat submit.
  void _confirmPhoto() => setState(() => _photoConfirmed = true);

  Future<void> _pickProofFromGallery() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      await _setProof(image.readAsBytes(), image.name);
    } catch (_) {
      _show('Galeri tidak dapat diakses. Periksa izin perangkat.');
    }
  }

  Future<void> _pickProofFile() async {
    try {
      final picked = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
        withData: true,
      );
      final file = picked?.files.single;
      if (file?.bytes == null) return;
      await _setProof(Future.value(file!.bytes!), file.name);
    } catch (_) {
      _show('File tidak dapat dipilih. Coba ulangi.');
    }
  }

  Future<void> _setProof(Future<Uint8List> bytesFuture, String name) async {
    final bytes = await bytesFuture;
    if (bytes.lengthInBytes > 2 * 1024 * 1024) {
      if (mounted) {
        setState(() {
          _proofBytes = null;
          _proofName = null;
          _proofMimeType = null;
        });
      }
      _show('Gagal unggah file/foto, maks 2MB.');
      return;
    }
    final mime = _mimeFromName(name);
    if (mime == null) {
      _show('Bukti harus berupa JPG, PNG, atau PDF.');
      return;
    }
    if (mounted) {
      setState(() {
        _proofBytes = bytes;
        _proofName = name;
        _proofMimeType = mime;
      });
    }
  }

  String? _mimeFromName(String name) {
    final extension = name.split('.').last.toLowerCase();
    return switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'pdf' => 'application/pdf',
      _ => null,
    };
  }

  Future<void> _submit() async {
    final action = _selectedAction!;
    if (action == PresensiAction.izin && _note.text.trim().isEmpty) {
      _show('Alasan izin wajib diisi.');
      return;
    }
    if (action == PresensiAction.izin && _proofBytes == null) {
      _show('Bukti pendukung wajib diunggah.');
      return;
    }
    if (action != PresensiAction.izin) {
      if (_photo == null) {
        _show('Foto selfie wajib diambil.');
        return;
      }
      if (!_photoConfirmed) {
        _show('Tekan "Pakai Foto" untuk mengonfirmasi foto selfie Anda.');
        return;
      }
      if (_locationStatus != _LocationStatus.valid) {
        _show('Lokasi Anda belum memenuhi syarat untuk presensi.');
        return;
      }
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
        locationAddress: _locationAddress,
        photoBase64: image,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        proofBase64: _proofBytes == null
            ? null
            : 'data:$_proofMimeType;base64,${base64Encode(_proofBytes!)}',
        proofName: _proofName,
      );
      if (!mounted) return;
      setState(() {
        _submittedPresensi = submitted;
        _page = 3;
      });
      await _load();
    } on ApiException catch (error) {
      // Server adalah sumber kebenaran akhir soal radius; jika ditolak,
      // paksa tampilan lokasi kembali ke kondisi "Tidak Valid".
      if (error.message.toLowerCase().contains('radius') ||
          error.message.toLowerCase().contains('lokasi')) {
        if (mounted) {
          setState(() => _locationStatus = _LocationStatus.invalid);
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
    setState(() {
      _submitErrorMessage = message;
      _page = 4;
    });
  }

  /// 04-B (Usulan Tambahan): Presensi Gagal Dikirim.
  Widget _submitFailed() => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        _header('Presensi', back: () => setState(() => _page = 1)),
        const Spacer(),
        Container(
          width: 84,
          height: 84,
          decoration: const BoxDecoration(
            color: Color(0xFFFEE2E2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close_rounded,
            color: Color(0xFFDC2626),
            size: 40,
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Presensi Gagal Dikirim',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF10213A),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _submitErrorMessage ??
              'Terjadi kendala saat mengirim data presensi Anda. Periksa koneksi internet lalu coba lagi.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF616B7B),
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 34),
        FilledButton.icon(
          onPressed: () {
            setState(() => _page = 1);
            _getLocation();
          },
          style: FilledButton.styleFrom(
            backgroundColor: _blue,
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.refresh),
          label: const Text(
            'Coba Lagi',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => setState(() {
            _page = 0;
            _submitErrorMessage = null;
          }),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
          ),
          child: const Text(
            'Kembali ke Beranda',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const Spacer(),
      ],
    ),
  );

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
              4 => _submitFailed(),
              5 => _dailyDetail(),
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

  /// Placeholder dipakai saat mencari data jam masuk/pulang hari ini
  /// yang belum ada (id: 0 menandakan "tidak ditemukan").
  Presensi get _emptyPresensi => Presensi(
    id: 0,
    status: '',
    type: '',
    presensiDate: DateTime(0),
    createdAt: DateTime(0),
  );

  Widget _home() {
    final action = _todayAction;
    return RefreshIndicator(
      onRefresh: () => _load(_recapDateRange),
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
          _lihatRincianCard(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _errorState(),
            ),
          const SizedBox(height: 30),
          const Center(
            child: Text(
              '© 2026 Ruwa Magang. All Rights Reserved.',
              style: TextStyle(color: Color(0xFF9AA4B2), fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lihatRincianCard() => InkWell(
    onTap: () => setState(() => _page = 2),
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E7F2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFE5EEFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.assessment_outlined, color: _blue),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lihat Rincian',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 2),
                Text(
                  'Cek statistik kehadiran Anda',
                  style: TextStyle(fontSize: 12, color: Color(0xFF687386)),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF98A2B3)),
        ],
      ),
    ),
  );

  /// Izin hari ini (jika ada) — dipakai supaya tab Izin tidak menampilkan
  /// form kosong lagi kalau pengguna sudah pernah mengajukan hari ini.
  Presensi? get _todayIzin {
    for (final item in _history) {
      if (item.status == 'izin' && _isToday(item.presensiDate)) return item;
    }
    return null;
  }

  /// Ditampilkan di tab Izin ketika pengguna sudah mengajukan izin hari ini
  /// (mencegah pengajuan ganda). Catatan: API yang tersedia belum punya
  /// status persetujuan (disetujui/ditolak) — field itu perlu ditambahkan
  /// di backend (mis. kolom `approval_status` + endpoint admin) sebelum
  /// status ini bisa berubah dari "Menunggu Persetujuan".
  Widget _izinStatusCard(Presensi item) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE0E7F2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ID Permohonan',
              style: TextStyle(fontSize: 11, color: Color(0xFF687386)),
            ),
            Text(
              '#PRMT-${_dateKey(item.presensiDate).replaceAll('-', '')}${item.id}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Chip(
          label: Text('Menunggu Persetujuan'),
          avatar: Icon(Icons.more_horiz, size: 18, color: _blue),
          backgroundColor: Color(0xFFE4EDFF),
        ),
        const Divider(height: 30),
        const Text(
          'Keterangan Izin',
          style: TextStyle(fontSize: 11, color: Color(0xFF687386)),
        ),
        const SizedBox(height: 6),
        Text(
          item.note ?? '-',
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Anda sudah mengajukan izin untuk hari ini. Permohonan akan ditinjau oleh mentor/koordinator unit kerja.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF3B4A63),
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _form() {
    final isIzin = _selectedAction == PresensiAction.izin;
    final existingIzin = isIzin ? _todayIzin : null;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _header('Presensi', back: () => setState(() => _page = 0)),
        const SizedBox(height: 28),
        _tabs(isIzin),
        const SizedBox(height: 24),
        if (existingIzin != null)
          _izinStatusCard(existingIzin)
        else ...[
          _info(
            isIzin
                ? 'Ajukan izin jika Anda tidak dapat melakukan presensi kehadiran secara langsung.'
                : 'Pastikan Anda berada dalam radius lokasi kantor dan ambil foto dengan jelas.',
          ),
          const SizedBox(height: 26),
          if (isIzin) _izinForm() else _attendanceForm(),
          const SizedBox(height: 40),
          FilledButton(
            onPressed: _loading || !_canSubmit ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: _blue,
              disabledBackgroundColor: const Color(0xFFCBD5E1),
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
      ],
    );
  }

  /// Tombol kirim hanya aktif jika seluruh syarat kondisi terpenuhi:
  /// - Izin: alasan sudah diisi.
  /// - Datang/Pulang: lokasi berstatus valid DAN foto sudah dikonfirmasi
  ///   ("Pakai Foto" sudah ditekan).
  bool get _canSubmit {
    if (_selectedAction == PresensiAction.izin) {
      return _note.text.trim().isNotEmpty;
    }
    return _locationStatus == _LocationStatus.valid &&
        _photo != null &&
        _photoConfirmed;
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

  /// 09 Rincian Presensi — dibangun dari kalender bulan berjalan (1 s.d.
  /// hari ini) disandingkan dengan data presensi, karena API yang tersedia
  /// hanya mengembalikan baris untuk hari yang sudah ada catatannya.
  /// Hari kerja tanpa catatan setelah waktu kerja ditandai "Tanpa Keterangan", akhir pekan
  /// ditandai "Libur" walau tidak ada baris presensi untuk tanggal itu.
  List<_DailyRecap> get _dailyRecap {
    final now = DateTime.now();
    final firstOfMonth = _recapDateRange?.start ?? DateTime(now.year, now.month, 1);
    final lastDate = _recapDateRange?.end.isBefore(now) == true
        ? _recapDateRange!.end
        : now;
    final byDate = <String, List<Presensi>>{};
    for (final item in _history) {
      final key = _dateKey(item.presensiDate);
      byDate.putIfAbsent(key, () => []).add(item);
    }

    final result = <_DailyRecap>[];
    for (
      var day = firstOfMonth;
      !day.isAfter(lastDate);
      day = day.add(const Duration(days: 1))
    ) {
      final key = _dateKey(day);
      final records = byDate[key];
      final isWeekend =
          day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;

      if (records == null || records.isEmpty) {
        result.add(
          _DailyRecap(
            date: day,
            status: isWeekend ? 'Libur' : 'Tanpa Keterangan',
            subtitle: isWeekend ? 'Libur Akhir Pekan' : 'Tidak ada catatan',
          ),
        );
        continue;
      }

      final izinRecord = records.where((r) => r.status == 'izin').toList();
      if (izinRecord.isNotEmpty) {
        result.add(
          _DailyRecap(
            date: day,
            status: 'Izin',
            subtitle: izinRecord.first.note ?? 'Izin',
            record: izinRecord.first,
          ),
        );
        continue;
      }

      final masuk = records.where((r) => r.type == 'datang').toList();
      final pulang = records.where((r) => r.type == 'pulang').toList();
      final jamMasuk = masuk.isNotEmpty ? masuk.first.createdAt : null;
      final jamPulang = pulang.isNotEmpty ? pulang.first.createdAt : null;
      final tanpaKeterangan = records.any((r) => r.status == 'tanpa_keterangan');

      result.add(
        _DailyRecap(
          date: day,
          status: tanpaKeterangan ? 'Tanpa Keterangan' : 'Hadir',
          jamMasuk: jamMasuk,
          jamPulang: jamPulang,
          record: masuk.isNotEmpty ? masuk.first : pulang.first,
        ),
      );
    }
    return result.reversed.toList();
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Widget _detail() {
    final all = _dailyRecap;
    final filtered = _recapFilter == null
        ? all
        : all.where((d) => d.status == _recapFilter).toList();

    final hadirCount = all.where((d) => d.status == 'Hadir').length;
    final izinCount = all.where((d) => d.status == 'Izin').length;
    final tanpaKeteranganCount = all.where((d) => d.status == 'Tanpa Keterangan').length;
    final totalWorkdays = hadirCount + izinCount + tanpaKeteranganCount;
    final percent = totalWorkdays == 0
        ? 0
        : ((hadirCount / totalWorkdays) * 100).round();

    const pageSize = 5;
    final pageCount = (filtered.length / pageSize).ceil().clamp(1, 999);
    final safePage = _recapPage.clamp(0, pageCount - 1);
    final pageItems = filtered
        .skip(safePage * pageSize)
        .take(pageSize)
        .toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        children: [
          _header('Presensi', back: () => setState(() => _page = 0)),
          const SizedBox(height: 18),
          // Banner "Ringkasan Performa"
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 110,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Image.asset(
                      'assets/images/ringkasan_performa.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(color: Colors.black.withValues(alpha: 0.38)),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Ringkasan Performa',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Statistik Kehadiran',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _statCard('Hadir', hadirCount, const Color(0xFF0757D8)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCard('Izin', izinCount, const Color(0xFF08794D)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _statCard('Libur', all.where((d) => d.status == 'Libur').length, const Color(0xFF64748B)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCard('Tanpa Keterangan', tanpaKeteranganCount, const Color(0xFFDC2626)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE0E7F2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Persentase Kehadiran',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: _blue,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: totalWorkdays == 0 ? 0 : hadirCount / totalWorkdays,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE5EAF2),
                    color: _blue,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$hadirCount/$totalWorkdays Hari',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF687386),
                      ),
                    ),
                    const Text(
                      'Target minimal 80%',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF687386),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _monthlyCalendar(all),
          const SizedBox(height: 22),
          const Text(
            'Rekap Presensi',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _filterChip(
                icon: Icons.calendar_today_outlined,
                label: _recapDateRange == null ? 'Semua Tanggal' : _dateRangeLabel(_recapDateRange!),
                active: _recapDateRange != null,
                onTap: _pickDateRange,
              ),
              const SizedBox(width: 8),
              _filterChip(
                icon: Icons.tune,
                label: _recapFilter ?? 'Filter Status',
                active: _recapFilter != null,
                onTap: _pickStatusFilter,
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(top: 50),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            _errorState()
          else if (pageItems.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                child: Text(
                  'Tidak ada data untuk filter ini.',
                  style: TextStyle(color: Color(0xFF687386)),
                ),
              ),
            )
          else
            ...pageItems.map(_recapRow),
          if (pageItems.isNotEmpty) ...[
            const SizedBox(height: 8),
            _pagination(pageCount, safePage),
          ],
          const SizedBox(height: 24),
          const Center(
            child: Text(
              '© 2026 Ruwa Magang. All Rights Reserved.',
              style: TextStyle(color: Color(0xFF9AA4B2), fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickStatusFilter() async {
    final options = ['Hadir', 'Izin', 'Tanpa Keterangan', 'Libur'];
    final chosen = await showModalBottomSheet<String?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Filter Status',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
            ListTile(
              title: const Text('Semua Status'),
              onTap: () => Navigator.pop(context, null),
            ),
            ...options.map(
              (o) => ListTile(
                title: Text(o),
                onTap: () => Navigator.pop(context, o),
              ),
            ),
          ],
        ),
      ),
    );
    setState(() {
      _recapFilter = chosen;
      _recapPage = 0;
    });
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: _recapDateRange,
      helpText: 'Pilih rentang tanggal presensi',
    );
    if (range == null || !mounted) return;
    setState(() {
      _recapDateRange = range;
      _recapPage = 0;
    });
    await _load(range);
  }

  String _dateRangeLabel(DateTimeRange range) =>
      '${range.start.day}/${range.start.month}/${range.start.year} - ${range.end.day}/${range.end.month}/${range.end.year}';

  Widget _monthlyCalendar(List<_DailyRecap> recap) {
    final now = DateTime.now();
    final month = _recapDateRange?.start ?? DateTime(now.year, now.month, 1);
    final totalDays = DateUtils.getDaysInMonth(month.year, month.month);
    final byDay = {for (final day in recap) day.date.day: day};
    final leading = DateTime(month.year, month.month, 1).weekday - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E7F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kalender ${_monthName(month.month)} ${month.year}',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Sn'), Text('Sl'), Text('Rb'), Text('Km'), Text('Jm'), Text('Sb'), Text('Mg'),
            ],
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.15,
            children: [
              ...List.generate(leading, (_) => const SizedBox()),
              ...List.generate(totalDays, (index) {
                final day = index + 1;
                final status = byDay[day]?.status;
                final color = _statusColors[status] ?? const Color(0xFFE5E7EB);
                return Container(
                  margin: const EdgeInsets.all(2),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.18), shape: BoxShape.circle),
                  child: Text('$day', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
                );
              }),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: ['Hadir', 'Izin', 'Tanpa Keterangan', 'Libur'].map((status) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: _statusColors[status], shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text(status, style: const TextStyle(fontSize: 10)),
              ],
            )).toList(),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) => const [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ][month - 1];

  Widget _filterChip({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE5EEFF) : Colors.white,
        border: Border.all(color: active ? _blue : const Color(0xFFE0E7F2)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: active ? _blue : const Color(0xFF687386)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: active ? _blue : const Color(0xFF536176),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _statCard(String label, int value, Color color) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE0E7F2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, color: Color(0xFF687386)),
        ),
        const SizedBox(height: 6),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    ),
  );

  Widget _pagination(int pageCount, int current) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        onPressed: current > 0
            ? () => setState(() => _recapPage = current - 1)
            : null,
        icon: const Icon(Icons.chevron_left),
      ),
      for (var i = 0; i < pageCount; i++)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: InkWell(
            onTap: () => setState(() => _recapPage = i),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: i == current ? _blue : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${i + 1}',
                style: TextStyle(
                  color: i == current ? Colors.white : const Color(0xFF536176),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      IconButton(
        onPressed: current < pageCount - 1
            ? () => setState(() => _recapPage = current + 1)
            : null,
        icon: const Icon(Icons.chevron_right),
      ),
    ],
  );

  static const _statusColors = {
    'Hadir': Color(0xFF16A34A),
    'Izin': Color(0xFF2563EB),
    'Tanpa Keterangan': Color(0xFFDC2626),
    'Libur': Color(0xFF9CA3AF),
  };

  Widget _recapRow(_DailyRecap recap) {
    final color = _statusColors[recap.status] ?? _blue;
    final subtitle = recap.status == 'Hadir'
        ? (recap.jamMasuk == null
              ? '-'
              : '${_detailTime(recap.jamMasuk!)}'
                    '${recap.jamPulang != null ? ' - ${_detailTime(recap.jamPulang!)}' : ''}')
        : (recap.subtitle ?? recap.status);

    return InkWell(
      onTap: () => setState(() {
        _selectedRecap = recap;
        _page = 5;
      }),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border(left: BorderSide(color: color, width: 3)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF3FB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _monthAbbr(recap.date.month),
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF687386),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${recap.date.day}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _detailDate(recap.date),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF687386),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                recap.status,
                style: TextStyle(
                  color: color,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthAbbr(int month) => const [
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

  /// Halaman Detail Presensi Harian — muncul saat salah satu baris
  /// pada Rekap Presensi ditekan.
  Widget _dailyDetail() {
    final recap = _selectedRecap;
    if (recap == null) {
      return Center(
        child: TextButton(
          onPressed: () => setState(() => _page = 2),
          child: const Text('Kembali ke Rincian'),
        ),
      );
    }
    final color = _statusColors[recap.status] ?? _blue;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      children: [
        _header('Detail Presensi', back: () => setState(() => _page = 2)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E7F2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _detailDate(recap.date),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      recap.status,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 30),

              // --- Hadir: jam masuk-pulang, foto, lokasi ---
              if (recap.status == 'Hadir') ...[
                Row(
                  children: [
                    Expanded(
                      child: _metricTile(
                        'JAM MASUK',
                        recap.jamMasuk == null
                            ? '-'
                            : _detailTime(recap.jamMasuk!),
                      ),
                    ),
                    Expanded(
                      child: _metricTile(
                        'JAM PULANG',
                        recap.jamPulang == null
                            ? '-'
                            : _detailTime(recap.jamPulang!),
                      ),
                    ),
                  ],
                ),
                if (recap.record?.photo != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Foto Selfie',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      '${widget.repository.photoBaseUrl}/${recap.record!.photo}',
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 180,
                        color: const Color(0xFFEFF3FB),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ),
                ],
                if (recap.record?.locationDistanceMeters != null) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: _blue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Jarak ${recap.record!.locationDistanceMeters} meter dari kantor OPD',
                        style: const TextStyle(
                          color: Color(0xFF536176),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ]
              // --- Izin: alasan dan lampiran ---
              else if (recap.status == 'Izin') ...[
                const Text(
                  'Keterangan',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  recap.subtitle ?? '-',
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
                if (recap.record?.photo != null) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.attach_file, size: 16, color: _blue),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'Lampiran bukti pendukung',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      const Icon(
                        Icons.download_outlined,
                        size: 18,
                        color: _blue,
                      ),
                    ],
                  ),
                ],
              ]
              // --- Libur ---
              else if (recap.status == 'Libur') ...[
                const Text(
                  'Tidak ada aktivitas presensi karena hari ini adalah akhir pekan/hari libur.',
                  style: TextStyle(color: Color(0xFF687386), height: 1.5),
                ),
              ]
              // --- Tanpa Keterangan ---
              else ...[
                const Text(
                  'Tidak ada presensi lengkap maupun izin sampai melewati jam pulang.',
                  style: TextStyle(color: Color(0xFF687386), height: 1.5),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _historyDetailCard(Presensi item) {
    final isIzin = item.status == 'izin';
    final isPulang = item.status == 'pulang' || item.type == 'pulang';
    final title = isIzin
        ? 'Izin'
        : isPulang
        ? 'Presensi Pulang'
        : 'Presensi Masuk';
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
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_detailDate(item.presensiDate)} • ${_detailTime(item.createdAt)} WIB',
                      style: const TextStyle(
                        color: Color(0xFF687386),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 26),
          if (item.locationDistanceMeters != null ||
              item.locationAccuracy != null)
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: _blue),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    item.locationDistanceMeters == null
                        ? 'Akurasi GPS: ±${item.locationAccuracy} meter'
                        : 'Jarak ${item.locationDistanceMeters} meter • Akurasi ±${item.locationAccuracy ?? '-'} meter',
                    style: const TextStyle(
                      color: Color(0xFF536176),
                      fontSize: 12,
                    ),
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
        if (_photoConfirmed)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 15, color: Color(0xFF16A34A)),
                SizedBox(width: 6),
                Text(
                  'Selfie Terverifikasi',
                  style: TextStyle(
                    color: Color(0xFF16A34A),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _retakePhoto,
                icon: const Icon(Icons.refresh),
                label: const Text('Ulang Foto'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: _photoConfirmed ? null : _confirmPhoto,
                style: FilledButton.styleFrom(
                  backgroundColor: _photoConfirmed
                      ? const Color(0xFF16A34A)
                      : _blue,
                ),
                icon: Icon(
                  _photoConfirmed
                      ? Icons.check_circle_outline
                      : Icons.visibility_outlined,
                ),
                label: Text(_photoConfirmed ? 'Foto Dipakai' : 'Pakai Foto'),
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
        onChanged: (_) => setState(() {}),
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
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBFC9DF)),
        ),
        child: Column(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFE8F0FF),
              child: Icon(Icons.file_upload_outlined, color: _blue),
            ),
            const SizedBox(height: 10),
            Text(
              _proofName ?? 'Pilih foto dari galeri atau file perangkat',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _proofName == null ? _blue : const Color(0xFF08794D),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              _proofName == null
                  ? 'JPG, PNG, PDF (maks. 2MB)'
                  : '${(_proofBytes!.lengthInBytes / 1024).ceil()} KB',
              style: const TextStyle(color: Color(0xFF748097), fontSize: 11),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickProofFromGallery,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Galeri'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickProofFile,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('File'),
                  ),
                ),
              ],
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
      _locationCard(showOfficeMetrics: false),
    ],
  );

  Widget _locationCard({bool showOfficeMetrics = true}) {
    final status = _locationStatus;
    if (!showOfficeMetrics) return _izinLocationCard(status);

    return Container(
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

          // --- Kondisi 1: Lokasi Nonaktif (GPS mati / izin ditolak) ---
          if (status == _LocationStatus.gpsOff ||
              status == _LocationStatus.unknown) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5E9),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: const Color(0xFFFFDEB0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFE28A15),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Lokasi Belum Tersedia',
                          style: TextStyle(
                            color: Color(0xFF994C00),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Aktifkan GPS dan tekan "Perbarui Lokasi".',
                          style: TextStyle(
                            color: Color(0xFF994C00),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]
          // --- Kondisi 2 & 3: GPS aktif -> tampil detail alamat/jarak/akurasi ---
          else ...[
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
                    'ALAMAT',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF8A94A6),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _locationAddress ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _metricTile(
                    'JARAK KE KANTOR',
                    _locationDistanceMeters == null
                        ? '-'
                        : '$_locationDistanceMeters meter',
                  ),
                ),
                Expanded(
                  child: _metricTile(
                    'AKURASI GPS',
                    _position == null
                        ? '-'
                        : '±${_position!.accuracy.round()} meter',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Kondisi 3: Lokasi Tidak Valid (di luar radius)
            if (status == _LocationStatus.invalid)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEEE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFC9C9)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.cancel,
                      color: Color(0xFFF04444),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lokasi Tidak Valid',
                            style: TextStyle(
                              color: Color(0xFFD92D20),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Maksimal radius $_radiusMeters meter dari kantor OPD.',
                            style: const TextStyle(
                              color: Color(0xFFD92D20),
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            // Kondisi 2: Lokasi Valid (dalam radius)
            else if (status == _LocationStatus.valid)
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
                    Icon(
                      Icons.check_circle,
                      color: Color(0xFF42A85F),
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Lokasi Valid — Dalam radius kantor OPD',
                        style: TextStyle(
                          color: Color(0xFF36914E),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
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
  }

  Widget _izinLocationCard(_LocationStatus status) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Lokasi Saat Ini', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Text(
          status == _LocationStatus.gpsOff || status == _LocationStatus.unknown
              ? 'Aktifkan GPS lalu tekan Perbarui Lokasi.'
              : _locationAddress ?? 'Alamat lokasi belum tersedia.',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _getLocation,
          icon: const Icon(Icons.refresh),
          label: const Text('Perbarui Lokasi'),
        ),
      ],
    ),
  );

  Widget _metricTile(String label, String value) => Container(
    margin: const EdgeInsets.only(right: 8),
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: const Color(0xFFF7F8FA),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9.5,
            color: Color(0xFF8A94A6),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
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
  Widget _scheduleCard() {
    final action = _todayAction;

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'HARI & TANGGAL',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _detailDate(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5EEFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: _blue,
                ),
              ),
            ],
          ),
          const Divider(height: 26),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _jamTile(
                label: 'Jam Masuk',
                value: '$_checkInTime WIB',
                highlighted: true,
              ),
              _jamTile(
                label: 'Jam Pulang',
                value: '$_checkOutTime WIB',
                highlighted: true,
              ),
            ],
          ),
          if (action == PresensiAction.selesai) ...[
            const SizedBox(height: 10),
            const Text(
              'Presensi hari ini sudah lengkap. Sampai jumpa besok!',
              style: TextStyle(fontSize: 12, color: Color(0xFF687386)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _jamTile({
    required String label,
    required String value,
    required bool highlighted,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 12, color: Color(0xFF687386)),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: highlighted
              ? const Color(0xFF08794D)
              : const Color(0xFF10213A),
        ),
      ),
    ],
  );

  bool _isToday(DateTime value) {
    final now = DateTime.now();
    return value.year == now.year &&
        value.month == now.month &&
        value.day == now.day;
  }

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

/// Representasi satu baris rekap harian pada halaman Rincian Presensi
/// (mockup 09) dan Detail Presensi Harian (usulan tambahan).
class _DailyRecap {
  _DailyRecap({
    required this.date,
    required this.status,
    this.jamMasuk,
    this.jamPulang,
    this.subtitle,
    this.record,
  });

  final DateTime date;

  /// 'Hadir' | 'Izin' | 'Tanpa Keterangan' | 'Libur'
  final String status;
  final DateTime? jamMasuk;
  final DateTime? jamPulang;
  final String? subtitle;
  final Presensi? record;
}
