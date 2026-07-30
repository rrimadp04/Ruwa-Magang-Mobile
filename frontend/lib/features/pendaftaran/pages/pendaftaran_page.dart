import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../opd/models/opd_model.dart';
import '../../status_pendaftaran/pages/status_pendaftaran_page.dart';

class PendaftaranPage extends StatefulWidget {
  const PendaftaranPage({super.key, this.selectedOpd});
  final OpdModel? selectedOpd;

  @override
  State<PendaftaranPage> createState() => _PendaftaranPageState();
}

class _PendaftaranPageState extends State<PendaftaranPage> {
  final _formKey = GlobalKey<FormState>();
  final _prodiCtrl = TextEditingController();
  final _opdSearchCtrl = TextEditingController();

  OpdModel? _selectedOpd;
  String? _selectedBidang;

  String? _cvName;
  String? _cvPath;
  Uint8List? _cvBytes;

  String? _transkripName;
  String? _transkripPath;
  Uint8List? _transkripBytes;

  String? _suratName;
  String? _suratPath;
  Uint8List? _suratBytes;

  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;

  List<OpdModel> _opdSuggestions = kDefaultOpds;
  bool _showOpdDropdown = false;

  @override
  void initState() {
    super.initState();
    if (widget.selectedOpd != null) {
      _selectedOpd = widget.selectedOpd;
      _opdSearchCtrl.text = widget.selectedOpd!.nama;
    }
    _opdSearchCtrl.addListener(_onOpdSearch);
  }

  void _onOpdSearch() {
    final q = _opdSearchCtrl.text.toLowerCase();
    if (q.isEmpty) {
      setState(() => _opdSuggestions = kDefaultOpds);
    } else {
      final all = [...kDefaultOpds, ...dummyOpds];
      final unique = <int, OpdModel>{};
      for (final o in all) { unique[o.id] = o; }
      setState(() {
        _opdSuggestions = unique.values
            .where((o) => o.nama.toLowerCase().contains(q))
            .toList()
          ..sort((a, b) => a.nama.compareTo(b.nama));
      });
    }
  }

  @override
  void dispose() {
    _prodiCtrl.dispose();
    _opdSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isMulai) async {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final firstDate = isMulai
        ? todayOnly
        : (_tanggalMulai != null ? _tanggalMulai!.add(const Duration(days: 1)) : todayOnly);

    final picked = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isMulai) {
          _tanggalMulai = picked;
          if (_tanggalSelesai != null && _tanggalSelesai!.isBefore(picked)) {
            _tanggalSelesai = null;
          }
        } else {
          _tanggalSelesai = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? d) {
    if (d == null) return 'mm/dd/yyyy';
    return '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';
  }

  static const int _maxBytes = 5 * 1024 * 1024;

  Future<void> _pickFile(
    String label,
    void Function(String name, String? path, Uint8List? bytes) onPicked,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        withData: true, // selalu ambil bytes agar bisa dibuka di web maupun mobile
      );
      if (result == null || result.files.isEmpty) return;
      final pf = result.files.first;

      if (pf.size > _maxBytes) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label melebihi batas 5 MB'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      String? filePath;
      Uint8List? fileBytes = pf.bytes;

      if (!kIsWeb) {
        filePath = pf.path;
        // Jika path null tapi bytes ada, tulis ke temp dir
        if (filePath == null && fileBytes != null) {
          final dir = await getTemporaryDirectory();
          final tmp = File('${dir.path}/${pf.name}');
          await tmp.writeAsBytes(fileBytes);
          filePath = tmp.path;
        }
      }

      if (!mounted) return;
      onPicked(pf.name, filePath, fileBytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih file: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _submit() {
    if (_cvName == null || _transkripName == null || _suratName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap upload CV, Transkrip, dan Surat Pengantar'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StatusPendaftaranPage(
            status: 'berhasil',
            opdNama: _selectedOpd?.nama ?? 'DINAS KOMUNIKASI, INFORMATIKA DAN STATISTIK',
            bidang: _selectedBidang ?? '',
            prodi: _prodiCtrl.text,
            cvName: _cvName,
            cvPath: _cvPath,
            cvBytes: _cvBytes,
            transkripName: _transkripName,
            transkripPath: _transkripPath,
            transkripBytes: _transkripBytes,
            suratName: _suratName,
            suratPath: _suratPath,
            suratBytes: _suratBytes,
            tanggalMulai: _tanggalMulai,
            tanggalSelesai: _tanggalSelesai,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bg,
    appBar: AppBar(
      backgroundColor: AppColors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.ink),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: const Text('Ruwa Magang'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryLight,
            child: const Icon(Icons.person, color: AppColors.primary, size: 20),
          ),
        ),
      ],
    ),
    body: GestureDetector(
      onTap: () {
        if (_showOpdDropdown) setState(() => _showOpdDropdown = false);
      },
      behavior: HitTestBehavior.translucent,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pendaftaran Magang', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink)),
              const SizedBox(height: 4),
              const Text('Lengkapi seluruh persyaratan magang Anda.', style: TextStyle(color: AppColors.grey, fontSize: 13)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('OPD Tujuan'),
                    _opdField(),
                    const SizedBox(height: 14),
                    _label('Bidang / Unit'),
                    _bidangDropdown(),
                    const SizedBox(height: 14),
                    _label('Prodi / Jurusan'),
                    _textField(_prodiCtrl, 'Masukkan Program Studi / Jurusan'),
                    const SizedBox(height: 14),
                    _labelRequired('CV (PDF/DOC)'),
                    _fileField(
                      fileName: _cvName,
                      onPick: () => _pickFile('CV', (n, p, b) => setState(() { _cvName = n; _cvPath = p; _cvBytes = b; })),
                      onRemove: _cvName != null ? () => setState(() { _cvName = null; _cvPath = null; _cvBytes = null; }) : null,
                    ),
                    const SizedBox(height: 4),
                    const Text('Format: PDF/DOC/DOCX • Max 5 MB', style: TextStyle(color: AppColors.grey, fontSize: 11)),
                    const SizedBox(height: 14),
                    _labelRequired('Transkrip Nilai (PDF/DOC)'),
                    _fileField(
                      fileName: _transkripName,
                      onPick: () => _pickFile('Transkrip', (n, p, b) => setState(() { _transkripName = n; _transkripPath = p; _transkripBytes = b; })),
                      onRemove: _transkripName != null ? () => setState(() { _transkripName = null; _transkripPath = null; _transkripBytes = null; }) : null,
                    ),
                    const SizedBox(height: 4),
                    const Text('Format: PDF/DOC/DOCX • Max 5 MB', style: TextStyle(color: AppColors.grey, fontSize: 11)),
                    const SizedBox(height: 14),
                    _labelRequired('Surat Pengantar Kampus (PDF/DOC)'),
                    _fileField(
                      fileName: _suratName,
                      onPick: () => _pickFile('Surat Pengantar', (n, p, b) => setState(() { _suratName = n; _suratPath = p; _suratBytes = b; })),
                      onRemove: _suratName != null ? () => setState(() { _suratName = null; _suratPath = null; _suratBytes = null; }) : null,
                    ),
                    const SizedBox(height: 4),
                    const Text('Format: PDF/DOC/DOCX • Max 5 MB', style: TextStyle(color: AppColors.grey, fontSize: 11)),
                    const SizedBox(height: 14),
                    _label('Tanggal Mulai'),
                    _dateField(_tanggalMulai, () => _pickDate(true)),
                    const SizedBox(height: 14),
                    _label('Tanggal Selesai'),
                    _dateField(_tanggalSelesai, () => _pickDate(false)),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Kirim Pendaftaran', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('© 2026 • Dinas Komunikasi, Informatika, dan Statistik (Diskominfotik) Provinsi Lampung', textAlign: TextAlign.center, style: TextStyle(color: AppColors.grey, fontSize: 11)),
            ],
          ),
        ),
      ),
    ),
    bottomNavigationBar: _bottomNav(),
  );

  Widget _opdField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GestureDetector(
        onTap: () => setState(() => _showOpdDropdown = !_showOpdDropdown),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            border: Border.all(color: _selectedOpd != null ? AppColors.primary : AppColors.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _selectedOpd?.nama ?? 'Pilih OPD',
                  style: TextStyle(color: _selectedOpd != null ? AppColors.ink : AppColors.grey, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.unfold_more, color: AppColors.grey, size: 18),
            ],
          ),
        ),
      ),
      if (_showOpdDropdown) ...[
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 4))],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: _opdSearchCtrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Ketik nama OPD...',
                    hintStyle: const TextStyle(color: AppColors.grey, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.grey),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _opdSuggestions.length,
                  itemBuilder: (_, i) {
                    final opd = _opdSuggestions[i];
                    final isSelected = _selectedOpd?.id == opd.id;
                    return ListTile(
                      dense: true,
                      title: Text(opd.nama, style: TextStyle(fontSize: 13, color: isSelected ? AppColors.primary : AppColors.ink, fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal)),
                      subtitle: Text(opd.bidang, style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary, size: 16) : null,
                      onTap: () => setState(() {
                        _selectedOpd = opd;
                        _opdSearchCtrl.text = opd.nama;
                        _showOpdDropdown = false;
                      }),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    ],
  );

  Widget _bidangDropdown() => GestureDetector(
    onTap: () => showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Pilih Bidang / Unit', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.ink)),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: kDaftarBidang.length,
              itemBuilder: (_, i) {
                final b = kDaftarBidang[i];
                final isSelected = b == _selectedBidang;
                return ListTile(
                  title: Text(b, style: TextStyle(fontSize: 13, color: isSelected ? AppColors.primary : AppColors.ink, fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal)),
                  trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
                  tileColor: isSelected ? AppColors.primaryLight : null,
                  onTap: () { setState(() => _selectedBidang = b); Navigator.pop(context); },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: _selectedBidang != null ? AppColors.primary : AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _selectedBidang ?? 'Pilih Bidang / Unit',
              style: TextStyle(color: _selectedBidang != null ? AppColors.ink : AppColors.grey, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: AppColors.grey, size: 18),
        ],
      ),
    ),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.ink)),
  );

  Widget _labelRequired(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.ink)),
        const SizedBox(width: 3),
        const Text('*', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    ),
  );

  Widget _textField(TextEditingController ctrl, String hint) => TextFormField(
    controller: ctrl,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.grey, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
    ),
  );

  Widget _fileField({
    required String? fileName,
    required VoidCallback onPick,
    VoidCallback? onRemove,
  }) {
    final hasFile = fileName != null;
    return Container(
      decoration: BoxDecoration(
        color: hasFile ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
        border: Border.all(color: hasFile ? AppColors.success : AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Material(
            color: hasFile ? AppColors.success : AppColors.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(9),
              bottomLeft: Radius.circular(9),
            ),
            child: InkWell(
              onTap: onPick,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(9),
                bottomLeft: Radius.circular(9),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Text(
                  hasFile ? 'Ganti' : 'Pilih File',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              fileName ?? 'Belum ada file dipilih',
              style: TextStyle(color: hasFile ? AppColors.ink : AppColors.grey, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hasFile && onRemove != null)
            IconButton(
              icon: const Icon(Icons.close, size: 16, color: AppColors.error),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }

  Widget _dateField(DateTime? date, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(child: Text(_formatDate(date), style: TextStyle(color: date != null ? AppColors.ink : AppColors.grey, fontSize: 13))),
          const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.grey),
        ],
      ),
    ),
  );

  Widget _bottomNav() => NavigationBar(
    selectedIndex: 1,
    onDestinationSelected: (_) {},
    height: 74,
    indicatorColor: AppColors.primaryLight,
    destinations: const [
      NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Beranda'),
      NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'Daftar'),
      NavigationDestination(icon: Icon(Icons.edit_note_outlined), selectedIcon: Icon(Icons.edit_note), label: 'Logbook'),
      NavigationDestination(icon: Icon(Icons.workspace_premium_outlined), selectedIcon: Icon(Icons.workspace_premium), label: 'Sertifikat'),
      NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
    ],
  );
}
