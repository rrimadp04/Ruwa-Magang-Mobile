import 'package:flutter/material.dart';
import 'logbook_ui.dart';

class SearchBox extends StatelessWidget {
  const SearchBox({super.key, required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => TextField(
    onChanged: onChanged,
    decoration: InputDecoration(
      hintText: 'Cari aktivitas logbook',
      prefixIcon: const Icon(Icons.search_rounded),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: logbookPrimary.withValues(alpha: 0.75)),
      ),
      suffixIcon: const Icon(Icons.tune_rounded, color: Color(0xFF64748B)),
    ),
  );
}
