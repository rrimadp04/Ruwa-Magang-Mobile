import 'package:flutter/material.dart';

const _blue = Color(0xFF0757D8);

class CustomTab extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const CustomTab({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xffEEF3FC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildItem(title: "Nilai", index: 0),
          _buildItem(title: "Sertifikat", index: 1),
        ],
      ),
    );
  }

  Widget _buildItem({required String title, required int index}) {
    final selected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 46,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? const [BoxShadow(color: Color(0x12000000), blurRadius: 8)]
                : [],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? _blue : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
