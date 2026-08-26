import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';

final class NotistInkPreview extends StatelessWidget {
  const NotistInkPreview({
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
        key: const ValueKey('notist-ink-preview'),
        painter: _NotistInkPreviewPainter(
          points: points,
          origin: origin,
          color: context.klpColors.interaction,
        ),
      ),
    );
  }
}

final class _NotistInkPreviewPainter extends CustomPainter {
  const _NotistInkPreviewPainter({
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
  bool shouldRepaint(covariant _NotistInkPreviewPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.origin != origin ||
        oldDelegate.color != color;
  }
}
