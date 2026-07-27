import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/opd_model.dart';
import '../widgets/opd_card.dart';
import 'detail_opd_page.dart';
import '../../pendaftaran/pages/pendaftaran_page.dart';

const _bidangList = [
  'Semua Bidang',
  'Administrasi Pemerintahan',
  'Arsip dan Perpustakaan',
  'Ekonomi dan Pembangunan',
  'Energi dan Sumber Daya',
  'Infrastruktur dan Tata Ruang',
  'Kelautan dan Perikanan',
  'Kesehatan',
  'Ketenteraman dan Kebencanaan',
  'Keuangan dan Aset',
  'Komunikasi dan Informatika',
  'Lingkungan Hidup',
  'Olahraga dan Kepemudaan',
  'Pariwisata dan Ekonomi Kreatif',
  'Pendidikan',
  'Perencanaan dan Pembangunan',
  'Perhubungan',
  'Perindustrian dan Perdagangan',
  'Pertanian dan Ketahanan Pangan',
  'Sosial dan Pemberdayaan',
  'Teknologi Informasi',
];

const _kategoriList = [
  'Semua Kategori',
  'Asisten',
  'Badan',
  'Biro',
  'Dinas',
  'Inspektorat',
  'Rumah Sakit',
  'Satuan',
  'Sekretariat',
  'UPTD',
  'Unit Pelaksana',
];

const _statusList = ['Semua Status', 'Terbuka', 'Penuh', 'Paling Diminati'];

const _urutkanList = ['Default', 'A-Z', 'Z-A'];

class OpdPage extends StatefulWidget {
  const OpdPage({super.key});

  @override
  State<OpdPage> createState() => _OpdPageState();
}

class _OpdPageState extends State<OpdPage> {
  final _search = TextEditingController();
  int _page = 1;
  final _totalOpd = 394;

  String _bidang = 'Semua Bidang';
  String _kategori = 'Semua Kategori';
  String _status = 'Semua Status';
  String _urutkan = 'Default';

  List<OpdModel> get _filtered {
    final q = _search.text.toLowerCase();
    var list = dummyOpds.where((o) {
      final matchQ = q.isEmpty || o.nama.toLowerCase().contains(q) || o.bidang.toLowerCase().contains(q);
      final matchBidang = _bidang == 'Semua Bidang' || o.bidang == _bidang;
      final matchKategori = _kategori == 'Semua Kategori' || o.kategori == _kategori;
      final matchStatus = _status == 'Semua Status' || o.status == _status;
      return matchQ && matchBidang && matchKategori && matchStatus;
    }).toList();

    if (_urutkan == 'A-Z') list.sort((a, b) => a.nama.compareTo(b.nama));
    if (_urutkan == 'Z-A') list.sort((a, b) => b.nama.compareTo(a.nama));
    return list;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _showPicker({
    required String title,
    required List<String> items,
    required String selected,
    required void Function(String) onSelect,
  }) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.ink)),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                final isSelected = item == selected;
                return ListTile(
                  title: Text(item, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.ink, fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal)),
                  trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
                  tileColor: isSelected ? AppColors.primaryLight : null,
                  onTap: () {
                    onSelect(item);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
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
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
      children: [
        const Text('Profil OPD & Pendaftaran', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink)),
        const SizedBox(height: 4),
        const Text('Temukan peluang magang terbaik di berbagai Instansi Pemerintahan.', style: TextStyle(color: AppColors.grey, fontSize: 13)),
        const SizedBox(height: 16),
        TextField(
          controller: _search,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Cari posisi atau departemen...',
            hintStyle: const TextStyle(color: AppColors.grey, fontSize: 13),
            prefixIcon: const Icon(Icons.search, color: AppColors.grey),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterBtn(),
              const SizedBox(width: 8),
              _filterDropdown('Bidang', _bidang != 'Semua Bidang', () => _showPicker(title: 'Bidang', items: _bidangList, selected: _bidang, onSelect: (v) => setState(() => _bidang = v))),
              const SizedBox(width: 8),
              _filterDropdown('Kategori', _kategori != 'Semua Kategori', () => _showPicker(title: 'Kategori', items: _kategoriList, selected: _kategori, onSelect: (v) => setState(() => _kategori = v))),
              const SizedBox(width: 8),
              _filterDropdown('Status', _status != 'Semua Status', () => _showPicker(title: 'Status', items: _statusList, selected: _status, onSelect: (v) => setState(() => _status = v))),
              const SizedBox(width: 8),
              _filterDropdown('Urutkan', _urutkan != 'Default', () => _showPicker(title: 'Urutkan', items: _urutkanList, selected: _urutkan, onSelect: (v) => setState(() => _urutkan = v))),
            ],
          ),
        ),
        const SizedBox(height: 14),
        FilledButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PendaftaranPage())),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(120, 46),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Daftar', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 20),
        ..._filtered.map((opd) => OpdCard(
          opd: opd,
          onDetail: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailOpdPage(opd: opd))),
        )),
        const SizedBox(height: 8),
        Text('Menampilkan ${_filtered.length} dari $_totalOpd OPD', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
        const SizedBox(height: 12),
        _pagination(),
        const SizedBox(height: 20),
        const Text('© 2026 • Dinas Komunikasi, Informatika, dan Statistik\n(Diskominfotik) Provinsi Lampung', textAlign: TextAlign.center, style: TextStyle(color: AppColors.grey, fontSize: 11)),
      ],
    ),
  );

  Widget _filterBtn() => FilledButton.icon(
    onPressed: () {},
    icon: const Icon(Icons.filter_list, size: 16),
    label: const Text('Filter'),
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
  );

  Widget _filterDropdown(String label, bool active, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.primaryLight : AppColors.white,
        border: Border.all(color: active ? AppColors.primary : AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: active ? AppColors.primary : AppColors.ink, fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, size: 16, color: active ? AppColors.primary : AppColors.grey),
        ],
      ),
    ),
  );

  Widget _pagination() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _pageBtn(Icons.chevron_left, () { if (_page > 1) setState(() => _page--); }),
      ...[1, 2, 3].map((p) => _pageNum(p)),
      _pageNum(-1, label: '...'),
      _pageNum(132),
      _pageBtn(Icons.chevron_right, () => setState(() => _page++)),
    ],
  );

  Widget _pageNum(int p, {String? label}) {
    final isActive = p == _page;
    return GestureDetector(
      onTap: p > 0 ? () => setState(() => _page = p) : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: isActive ? AppColors.primary : AppColors.border),
        ),
        alignment: Alignment.center,
        child: Text(label ?? '$p', style: TextStyle(color: isActive ? AppColors.white : AppColors.ink, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  Widget _pageBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: 34, height: 34,
      decoration: BoxDecoration(color: AppColors.white, shape: BoxShape.circle, border: Border.all(color: AppColors.border)),
      alignment: Alignment.center,
      child: Icon(icon, size: 18, color: AppColors.ink),
    ),
  );
}
