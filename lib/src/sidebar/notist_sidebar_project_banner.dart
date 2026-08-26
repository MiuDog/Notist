import 'package:flutter/material.dart';
import 'package:kallopis/kallopis.dart';

/// Primary Sidebar 上方的專案導覽按鈕。
class NotistSidebarProjectBanner extends StatelessWidget {
  const NotistSidebarProjectBanner({
    super.key,
    required this.selected,
    required this.onPressed,
  });

  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return KlpRailItem(
      icon: KlpIcons.folder,
      label: '專案',
      selected: selected,
      onPressed: onPressed,
    );
  }
}
