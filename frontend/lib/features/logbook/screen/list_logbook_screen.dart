import 'package:flutter/material.dart';

import '../../nilai_sertifikat/screen/notification_screen.dart';
import '../model/logbook_model.dart';
import '../repository/logbook_repository.dart';
import '../widget/custom_appbar.dart';
import '../widget/empty_state.dart';
import '../widget/logbook_card.dart';
import '../widget/logbook_ui.dart';
import '../widget/search_box.dart';
import '../widget/summary_card.dart';
import 'detail_logbook_screen.dart';
import 'tambah_logbook_screen.dart';

class ListLogbookScreen extends StatefulWidget {
  const ListLogbookScreen({super.key, required this.repository});
  final LogbookRepository repository;
  @override
  State<ListLogbookScreen> createState() => _ListLogbookScreenState();
}

class _ListLogbookScreenState extends State<ListLogbookScreen> {
  late Future<List<LogbookModel>> _future;
  String _query = '';
  LogbookStatus? _filter;
  @override
  void initState() {
    super.initState();
    _future = widget.repository.getLogbooks();
  }

  Future<void> _reload() async =>
      setState(() => _future = widget.repository.getLogbooks());

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: logbookBackground,
    appBar: CustomAppbar(
      title: 'Logbook',
      showBack: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: logbookBorder),
              boxShadow: const [BoxShadow(color: Color(0x080F172A), blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Stack(
              children: [
                IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationScreen()),
                ),
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: logbookInk,
                ),
              ),
                const Positioned(
                right: 8,
                top: 9,
                child: CircleAvatar(radius: 4, backgroundColor: logbookDanger),
              ),
              ],
            ),
          ),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      heroTag: 'add-logbook',
      onPressed: _addLogbook,
      backgroundColor: logbookPrimary,
      foregroundColor: Colors.white,
      elevation: 5,
      child: const Icon(Icons.add_rounded),
    ),
    body: FutureBuilder<List<LogbookModel>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _LogbookSkeleton();
        }
        if (snapshot.hasError) {
          return _LogbookLoadError(
            message: '${snapshot.error}',
            onRetry: _reload,
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyState(
            title: 'Belum ada logbook',
            message: 'Mulailah mencatat aktivitas magang harian Anda.',
          );
        }
        final all = snapshot.data!;
        final filtered = all
            .where(
              (item) =>
                  item.title.toLowerCase().contains(_query.toLowerCase()) &&
                  (_filter == null || item.status == _filter),
            )
            .toList();
        return RefreshIndicator(
          onRefresh: _reload,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 92),
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(2, 4, 2, 16),
                    child: Text(
                      'Catat progres harianmu dan pantau setiap proses review dalam satu tempat.',
                      style: TextStyle(fontSize: 13, color: logbookMuted, height: 1.5),
                    ),
                  ),
                  SummaryCard(
                    total: all.length,
                    approved: all
                        .where((x) => x.status == LogbookStatus.approved)
                        .length,
                    pending: all
                        .where((x) => x.status == LogbookStatus.pending)
                        .length,
                    revision: all
                        .where((x) => x.status == LogbookStatus.revision)
                        .length,
                  ),
                  const SizedBox(height: 24),
                  const Text('Cari aktivitas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: logbookInk)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: SearchBox(
                          onChanged: (value) => setState(() => _query = value),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _filterButton(),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _filterChips(),
                  const SizedBox(height: 28),
                  if (filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: EmptyState(
                        title: 'Aktivitas tidak ditemukan',
                        message: 'Coba kata kunci atau filter lain.',
                      ),
                    ),
                  if (filtered.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Icon(Icons.history_rounded, size: 17, color: logbookPrimary),
                          SizedBox(width: 8),
                          Text('Aktivitas terbaru', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: logbookInk)),
                        ],
                      ),
                    ),
                  ],
                  ..._groupedList(filtered),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget _filterButton() => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: _showFilter,
      borderRadius: BorderRadius.circular(16),
      child: const SizedBox(
        width: 52,
        height: 52,
        child: Icon(Icons.tune_rounded, color: logbookPrimary),
      ),
    ),
  );
  Widget _filterChips() => SizedBox(
    height: 38,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _chip('Semua', null),
        _chip('Disetujui', LogbookStatus.approved),
        _chip('Menunggu', LogbookStatus.pending),
        _chip('Revisi', LogbookStatus.revision),
      ],
    ),
  );
  Widget _chip(String label, LogbookStatus? value) {
    final active = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: active,
        onSelected: (_) => setState(() => _filter = value),
        selectedColor: logbookPrimary,
        labelStyle: TextStyle(
          color: active ? Colors.white : logbookMuted,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide(
          color: active ? logbookPrimary : const Color(0xFFE2E8F0),
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  List<Widget> _groupedList(List<LogbookModel> items) {
    final groups = <String, List<LogbookModel>>{};
    final newest = DateTime.now();
    for (final item in items) {
      final days = DateTime(newest.year, newest.month, newest.day)
          .difference(
            DateTime(
              item.activityDate.year,
              item.activityDate.month,
              item.activityDate.day,
            ),
          )
          .inDays;
      final label = days == 0
          ? 'Hari Ini'
          : days == 1
          ? 'Kemarin'
          : days <= 7
          ? 'Minggu Ini'
          : 'Bulan Ini';
      groups.putIfAbsent(label, () => []).add(item);
    }
    return groups.entries
        .expand(
          (group) => [
            Text(
              group.key,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: logbookInk,
              ),
            ),
            const SizedBox(height: 12),
            ...group.value.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: LogbookCard(
                  item: item,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailLogbookScreen(
                        repository: widget.repository,
                        item: item,
                      ),
                    ),
                  ).then((_) => _reload()),
                ),
              ),
            ),
          ],
        )
        .toList();
  }

  void _showFilter() => showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Logbook',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            _filterTile('Semua', null),
            ...[
              LogbookStatus.approved,
              LogbookStatus.pending,
              LogbookStatus.revision,
            ].map((status) => _filterTile(logbookStatusLabel(status), status)),
          ],
        ),
      ),
    ),
  );
  Widget _filterTile(String label, LogbookStatus? status) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    trailing: _filter == status
        ? const Icon(Icons.check_rounded, color: logbookPrimary)
        : null,
    onTap: () {
      setState(() => _filter = status);
      Navigator.pop(context);
    },
  );
  void _addLogbook() => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => TambahLogbookScreen(repository: widget.repository),
    ),
  ).then((_) => _reload());
}

class _LogbookSkeleton extends StatelessWidget {
  const _LogbookSkeleton();
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const _Bone(height: 18, width: 210),
      const SizedBox(height: 16),
      const _Bone(height: 112),
      const SizedBox(height: 20),
      const _Bone(height: 52),
      const SizedBox(height: 24),
      ...List.generate(
        4,
        (_) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: _Bone(height: 116),
        ),
      ),
    ],
  );
}

class _Bone extends StatelessWidget {
  const _Bone({required this.height, this.width = double.infinity});
  final double height, width;
  @override
  Widget build(BuildContext context) => Container(
    height: height,
    width: width,
    decoration: BoxDecoration(
      color: const Color(0xFFE8EDF5),
      borderRadius: BorderRadius.circular(16),
    ),
  );
}

class _LogbookLoadError extends StatelessWidget {
  const _LogbookLoadError({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 58, color: logbookWarning),
          const SizedBox(height: 16),
          const Text(
            'Logbook belum dapat dimuat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: logbookInk,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: logbookMuted),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => onRetry(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    ),
  );
}
