// Notist 筆記導覽按鈕。

import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis_foundation.dart';

import 'notist_note_visual_style.dart';

/// 筆記工作台導覽項目；視覺取自 [NotistNoteVisualStyle]。
class NotistNoteNavigationButton extends StatelessWidget {
  const NotistNoteNavigationButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.selected = false,
  });

  final KlpIconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return KlpSidebarNavigationButton(
      icon: icon,
      label: label,
      onPressed: onPressed,
      selected: selected,
    );
  }
}
