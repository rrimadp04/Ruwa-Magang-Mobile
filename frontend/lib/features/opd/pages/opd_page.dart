import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/opd_model.dart';
import '../widgets/opd_card.dart';
import 'detail_opd_page.dart';
import '../../pendaftaran/pages/pendaftaran_page.dart';

class OpdPage extends StatefulWidget {
  const OpdPage({super.key});

  @override
  State<OpdPage> createState() => _OpdPageState();
}

class _OpdPageState extends State<OpdPage> {
  final _search = TextEditingController();
  int _page = 1;
  final _totalOpd = 394;

  List<OpdModel> get _filtered {
    final q = _search.text.toLowerCase();
    if (q.isEmpty) return dummyOpds;
    return dummyOpds
        .where((o) =>
            o.nama.toLowerCase().contains(q) ||
            o.bidang.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
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
        const Text(
          'Profil OPD & Pendaftaran',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Temukan peluang magang terbaik di berbagai Instansi Pemerintahan.',
          style: TextStyle(color: AppColors.grey, fontSize: 13),
        ),
        const SizedBox(height: 16),
        // Search bar
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Filter row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterBtn(Icons.filter_list, 'Filter', filled: true),
              const SizedBox(width: 8),
              _dropdown('Bidang'),
              const SizedBox(width: 8),
              _dropdown('Kategori'),
              const SizedBox(width: 8),
              _dropdown('Status'),
              const SizedBox(width: 8),
              _dropdown('Urutkan'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Daftar button
        FilledButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PendaftaranPage()),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(120, 46),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Daftar', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 20),
        // OPD list
        ..._filtered.map(
          (opd) => OpdCard(
            opd: opd,
            onDetail: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailOpdPage(opd: opd)),
            ),
          ),
        ),
        // Pagination info
        const SizedBox(height: 8),
        Text(
          'Menampilkan ${_filtered.length} dari $_totalOpd OPD',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.grey, fontSize: 13),
        ),
        const SizedBox(height: 12),
        _pagination(),
        const SizedBox(height: 20),
        const Text(
          '© 2026 • Dinas Komunikasi, Informatika, dan Statistik\n(Diskominfotik) Provinsi Lampung',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.grey, fontSize: 11),
        ),
      ],
    ),
  );

  Widget _filterBtn(IconData icon, String label, {bool filled = false}) =>
      filled
          ? FilledButton.icon(
              onPressed: () {},
              icon: Icon(icon, size: 16),
              label: Text(label),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            )
          : OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Text(label),
            );

  Widget _dropdown(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.white,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.ink)),
        const SizedBox(width: 4),
        const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.grey),
      ],
    ),
  );

  Widget _pagination() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _pageBtn(Icons.chevron_left, () {
        if (_page > 1) setState(() => _page--);
      }),
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
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: isActive ? AppColors.primary : AppColors.border),
        ),
        alignment: Alignment.center,
        child: Text(
          label ?? '$p',
          style: TextStyle(
            color: isActive ? AppColors.white : AppColors.ink,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _pageBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 18, color: AppColors.ink),
    ),
  );
}
