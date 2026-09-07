// Notist 筆跡預覽。

import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis_foundation.dart';

/// 呈現由 Notist 編輯層提供點位的即時筆跡預覽。
///
/// 本元件只負責繪製封閉路徑；座標、手勢、命中測試與 Ink authority
/// 仍由 Notist 的編輯層持有。
final class NotistNoteInkPreview extends StatelessWidget {
  const NotistNoteInkPreview({
    super.key,
    required this.points,
    required this.origin,
  });

  final List<Offset> points;
  final Offset origin;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        key: const ValueKey('notist-note-ink-preview'),
        painter: _NotistNoteInkPreviewPainter(
          points: points,
          origin: origin,
          color: context.klpColors.interaction,
        ),
      ),
    );
  }
}

final class _NotistNoteInkPreviewPainter extends CustomPainter {
  const _NotistNoteInkPreviewPainter({
    required this.points,
    required this.origin,
    required this.color,
  });

  final List<Offset> points;
  final Offset origin;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final path = Path()
      ..moveTo(origin.dx + points.first.dx, origin.dy + points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(origin.dx + point.dx, origin.dy + point.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _NotistNoteInkPreviewPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.origin != origin ||
        oldDelegate.color != color;
  }
}
