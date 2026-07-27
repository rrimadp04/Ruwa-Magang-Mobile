import 'package:flutter/material.dart';
import 'logbook_ui.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppbar({super.key, required this.title, this.subtitle, this.showBack = true, this.actions});
  final String title;
  final String? subtitle;
  final bool showBack;
  final List<Widget>? actions;
  @override Size get preferredSize => Size.fromHeight(subtitle == null ? 64 : 76);
  @override Widget build(BuildContext context) => AppBar(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    centerTitle: false,
    automaticallyImplyLeading: showBack,
    titleSpacing: showBack ? 0 : 20,
    title: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(color: logbookInk, fontWeight: FontWeight.w800, fontSize: 19)),
      ),
      if (subtitle != null) Text(subtitle!, style: const TextStyle(color: logbookMuted, fontSize: 11, height: 1.4)),
    ]),
    actions: actions,
  );
}
