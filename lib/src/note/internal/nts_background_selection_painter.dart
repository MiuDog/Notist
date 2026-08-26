part of '../nts_page_background_editor.dart';

class _NtsBackgroundSelectionPainter extends CustomPainter {
  const _NtsBackgroundSelectionPainter({
    required this.recipe,
    required this.viewport,
    required this.selection,
    required this.color,
    required this.guideColor,
    required this.width,
    required this.snapSpacing,
  });

  final NtsCustomPageBackgroundRecipe recipe;
  final NtsPageBackgroundViewport viewport;
  final NtsPageBackgroundSelection? selection;
  final Color color;
  final Color guideColor;
  final double width;
  final double snapSpacing;

  @override
  void paint(Canvas canvas, Size size) {
    _paintCoordinateGrid(canvas, size);

    final selected = selection;
    if (selected == null) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    final points = <int, NtsPageBackgroundPoint>{
      for (final point in recipe.points) point.id: point,
    };

    switch (selected.kind) {
      case NtsPageBackgroundElementKind.point:
        final point = points[selected.id];
        if (point == null) return;
        canvas.drawCircle(
          viewport.pageToViewport(point.position),
          width + width,
          paint,
        );
      case NtsPageBackgroundElementKind.line:
        NtsPageBackgroundLine? selectedLine;
        for (final line in recipe.lines) {
          if (line.id == selected.id) selectedLine = line;
        }
        if (selectedLine == null) return;
        final start = points[selectedLine.startPointId];
        final end = points[selectedLine.endPointId];
        if (start == null || end == null) return;
        canvas.drawLine(
          viewport.pageToViewport(start.position),
          viewport.pageToViewport(end.position),
          paint,
        );
    }
  }

  void _paintCoordinateGrid(Canvas canvas, Size size) {
    final viewportSpacing = snapSpacing * viewport.scale;
    if (viewportSpacing < width) return;

    final paint = Paint()
      ..color = guideColor
      ..strokeWidth = width;
    final firstColumn = (viewport.origin.dx / snapSpacing).ceil();
    final firstRow = (viewport.origin.dy / snapSpacing).ceil();

    for (var column = firstColumn; ; column += 1) {
      final x = (column * snapSpacing - viewport.origin.dx) * viewport.scale;
      if (x > size.width) break;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var row = firstRow; ; row += 1) {
      final y = (row * snapSpacing - viewport.origin.dy) * viewport.scale;
      if (y > size.height) break;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NtsBackgroundSelectionPainter oldDelegate) {
    return oldDelegate.recipe != recipe ||
        oldDelegate.viewport != viewport ||
        oldDelegate.selection != selection ||
        oldDelegate.color != color ||
        oldDelegate.guideColor != guideColor ||
        oldDelegate.width != width ||
        oldDelegate.snapSpacing != snapSpacing;
  }
}

bool _selectionExists(
  NtsPageBackgroundSelection selection,
  NtsCustomPageBackgroundRecipe recipe,
) {
  return switch (selection.kind) {
    NtsPageBackgroundElementKind.point => recipe.points.any(
      (point) => point.id == selection.id,
    ),
    NtsPageBackgroundElementKind.line => recipe.lines.any(
      (line) => line.id == selection.id,
    ),
  };
}

double _distanceToSegment(Offset point, Offset start, Offset end) {
  final segment = end - start;
  final lengthSquared = segment.dx * segment.dx + segment.dy * segment.dy;
  if (lengthSquared == 0) return (point - start).distance;

  final relative = point - start;
  final projection =
      (relative.dx * segment.dx + relative.dy * segment.dy) / lengthSquared;
  final clamped = math.max(0.0, math.min(1.0, projection));
  return (point - (start + segment * clamped)).distance;
}
