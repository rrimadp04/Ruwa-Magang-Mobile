import 'package:flutter/material.dart';
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
  final _bidang = TextEditingController();
  final _prodi = TextEditingController();

  String? _selectedOpd;
  String? _cvName;
  String? _transkripName;
  String? _suratName;
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;

  @override
  void initState() {
    super.initState();
    if (widget.selectedOpd != null) {
      _selectedOpd = widget.selectedOpd!.nama;
      _bidang.text = widget.selectedOpd!.bidang;
    }
  }

  @override
  void dispose() {
    _bidang.dispose();
    _prodi.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isMulai) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isMulai) {
          _tanggalMulai = picked;
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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StatusPendaftaranPage(
            status: 'berhasil',
            opdNama:
                _selectedOpd ?? 'DINAS KOMUNIKASI, INFORMATIKA DAN STATISTIK',
            bidang: _bidang.text,
            prodi: _prodi.text,
            cvName: _cvName,
            transkripName: _transkripName,
            suratName: _suratName,
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
    body: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pendaftaran Magang',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Lengkapi seluruh persyaratan magang Anda.',
              style: TextStyle(color: AppColors.grey, fontSize: 13),
            ),
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
                  _opdDropdown(),
                  const SizedBox(height: 14),
                  _label('Bidang / Unit'),
                  _textField(_bidang, 'Isi bidang tujuan'),
                  const SizedBox(height: 14),
                  _label('Prodi / Jurusan'),
                  _textField(_prodi, 'Masukkan Program Studi / Jurusan'),
                  const SizedBox(height: 14),
                  _labelRequired('CV (PDF/DOC)'),
                  _fileField(
                    _cvName,
                    () => setState(() => _cvName = 'cv_saya.pdf'),
                  ),
                  const SizedBox(height: 4),
                  const Text('Max Upload: 5 MB', style: TextStyle(color: AppColors.grey, fontSize: 11)),
                  const SizedBox(height: 14),
                  _labelRequired('Transkrip Nilai (PDF/DOC)'),
                  _fileField(
                    _transkripName,
                    () => setState(() => _transkripName = 'transkrip.pdf'),
                  ),
                  const SizedBox(height: 4),
                  const Text('Max Upload: 5 MB', style: TextStyle(color: AppColors.grey, fontSize: 11)),
                  const SizedBox(height: 14),
                  _labelRequired('Surat Pengantar Kampus (PDF/DOC)'),
                  _fileField(
                    _suratName,
                    () => setState(() => _suratName = 'surat_pengantar.pdf'),
                  ),
                  const SizedBox(height: 4),
                  const Text('Max Upload: 5 MB', style: TextStyle(color: AppColors.grey, fontSize: 11)),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Kirim Pendaftaran',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '© 2026 • Dinas Komunikasi, Informatika, dan Statistik (Diskominfotik) Provinsi Lampung',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    ),
    bottomNavigationBar: _bottomNav(),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.ink),
    ),
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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    ),
  );

  Widget _opdDropdown() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(10),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedOpd,
        hint: const Text(
          'Pilih OPD',
          style: TextStyle(color: AppColors.grey, fontSize: 13),
        ),
        isExpanded: true,
        items: dummyOpds
            .map(
              (o) => DropdownMenuItem(
                value: o.nama,
                child: Text(o.nama, style: const TextStyle(fontSize: 13)),
              ),
            )
            .toList(),
        onChanged: (v) => setState(() {
          _selectedOpd = v;
          final opd = dummyOpds.firstWhere((o) => o.nama == v);
          _bidang.text = opd.bidang;
        }),
      ),
    ),
  );

  Widget _fileField(String? fileName, VoidCallback onPick) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        GestureDetector(
          onTap: onPick,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
            child: const Text(
              'Choose File',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            fileName ?? 'No file chosen',
            style: TextStyle(
              color: fileName != null ? AppColors.ink : AppColors.grey,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );

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
          Expanded(
            child: Text(
              _formatDate(date),
              style: TextStyle(
                color: date != null ? AppColors.ink : AppColors.grey,
                fontSize: 13,
              ),
            ),
          ),
          const Icon(
            Icons.calendar_today_outlined,
            size: 16,
            color: AppColors.grey,
          ),
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
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: 'Beranda',
      ),
      NavigationDestination(
        icon: Icon(Icons.assignment_outlined),
        selectedIcon: Icon(Icons.assignment),
        label: 'Daftar',
      ),
      NavigationDestination(
        icon: Icon(Icons.edit_note_outlined),
        selectedIcon: Icon(Icons.edit_note),
        label: 'Logbook',
      ),
      NavigationDestination(
        icon: Icon(Icons.workspace_premium_outlined),
        selectedIcon: Icon(Icons.workspace_premium),
        label: 'Sertifikat',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profil',
      ),
    ],
  );
}
