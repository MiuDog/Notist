// Notist 筆記導覽群組。

import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis_foundation.dart';

/// 在筆記側欄中以語意間距排列導覽項目。
class NotistNoteNavigationGroup extends StatelessWidget {
  const NotistNoteNavigationGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final gap = context.klp.space.hairline;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < children.length; index++) ...[
          children[index],
          if (index < children.length - 1) SizedBox(height: gap),
        ],
      ],
    );
  }
}
