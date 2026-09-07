// Notist 筆記區塊畫布。

import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis_foundation.dart';

/// 承載自由定位筆記區塊的畫布表面。
class NotistNoteBlockCanvas extends StatelessWidget {
  const NotistNoteBlockCanvas({
    super.key,
    required this.children,
    this.constrained = false,
  });

  final List<Widget> children;
  final bool constrained;

  @override
  Widget build(BuildContext context) {
    final canvas = KlpSurface(
      tone: KlpSurfaceTone.inset,
      child: Stack(children: children),
    );

    return constrained ? canvas : InteractiveViewer(child: canvas);
  }
}
