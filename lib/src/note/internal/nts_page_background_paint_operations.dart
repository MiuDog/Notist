part of 'nts_page_background_painter.dart';

extension _NtsPageBackgroundPaintOperations on NtsPageBackgroundPainter {
  void _paintRuled(
    Canvas canvas,
    Size size,
    NtsRuledPageBackgroundRecipe recipe,
  ) {
    final spacing = recipe.spacing ?? visuals.spacing;
    if (spacing * viewport.scale < visuals.markWidth) return;

    final paint = _paintFor(recipe.axis, recipe.strokeBehavior);
    final firstRow = (viewport.origin.dy / spacing).ceil();

    for (var row = firstRow; ; row += 1) {
      final y = _toViewportCoordinate(row * spacing, viewport.origin.dy);
      if (y > size.height) break;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _paintPeriodic(
    Canvas canvas,
    Size size,
    NtsPeriodicPageBackgroundRecipe recipe, {
    required bool dots,
  }) {
    final majorSpacing = recipe.majorSpacing ?? visuals.spacing;
    if (majorSpacing * viewport.scale < visuals.markWidth) return;

    final divisionCount = recipe.minorAxisCount + 1;
    final minorSpacing = majorSpacing / divisionCount;
    final showMinor = minorSpacing * viewport.scale >= visuals.markWidth;
    final visibleSpacing = showMinor ? minorSpacing : majorSpacing;
    final visibleDivisionCount = showMinor ? divisionCount : 1;
    final firstColumn = (viewport.origin.dx / visibleSpacing).ceil();
    final firstRow = (viewport.origin.dy / visibleSpacing).ceil();

    if (dots) {
      _paintDots(
        canvas,
        size,
        recipe,
        visibleDivisionCount,
        visibleSpacing,
        firstColumn,
        firstRow,
      );
      return;
    }

    final minorPaint = _paintFor(recipe.minorAxis, recipe.strokeBehavior);
    final majorPaint = _paintFor(recipe.majorAxis, recipe.strokeBehavior);

    for (var column = firstColumn; ; column += 1) {
      final x = _toViewportCoordinate(
        column * visibleSpacing,
        viewport.origin.dx,
      );
      if (x > size.width) break;
      final paint = column % visibleDivisionCount == 0
          ? majorPaint
          : minorPaint;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (var row = firstRow; ; row += 1) {
      final y = _toViewportCoordinate(row * visibleSpacing, viewport.origin.dy);
      if (y > size.height) break;
      final paint = row % visibleDivisionCount == 0 ? majorPaint : minorPaint;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _paintDots(
    Canvas canvas,
    Size size,
    NtsPeriodicPageBackgroundRecipe recipe,
    int divisionCount,
    double spacing,
    int firstColumn,
    int firstRow,
  ) {
    final minorPaint = _paintFor(
      recipe.minorAxis,
      recipe.strokeBehavior,
      defaultWidth: visuals.dotWidth,
    );
    final majorPaint = _paintFor(
      recipe.majorAxis,
      recipe.strokeBehavior,
      defaultWidth: visuals.dotWidth,
    );
    final minorRadius = minorPaint.strokeWidth / 2;
    final majorRadius = majorPaint.strokeWidth / 2;

    for (var row = firstRow; ; row += 1) {
      final y = _toViewportCoordinate(row * spacing, viewport.origin.dy);
      if (y > size.height) break;

      for (var column = firstColumn; ; column += 1) {
        final x = _toViewportCoordinate(column * spacing, viewport.origin.dx);
        if (x > size.width) break;

        final isMajor = row % divisionCount == 0 && column % divisionCount == 0;
        canvas.drawCircle(
          Offset(x, y),
          isMajor ? majorRadius : minorRadius,
          isMajor ? majorPaint : minorPaint,
        );
      }
    }
  }

  void _paintCustom(Canvas canvas, NtsCustomPageBackgroundRecipe recipe) {
    final points = <int, NtsPageBackgroundPoint>{
      for (final point in recipe.points) point.id: point,
    };
    final linePaint = _paintFor(recipe.lineStyle, recipe.strokeBehavior);
    final pointPaint = _paintFor(recipe.pointStyle, recipe.strokeBehavior);
    final pointRadius = pointPaint.strokeWidth / 2;

    for (final line in recipe.lines) {
      final start = points[line.startPointId];
      final end = points[line.endPointId];
      if (start == null || end == null) continue;
      canvas.drawLine(
        viewport.pageToViewport(start.position),
        viewport.pageToViewport(end.position),
        linePaint,
      );
    }

    for (final point in recipe.points) {
      canvas.drawCircle(
        viewport.pageToViewport(point.position),
        pointRadius,
        pointPaint,
      );
    }
  }

  Paint _paintFor(
    NtsPageBackgroundAxisStyle axis,
    NtsPageBackgroundStrokeBehavior behavior, {
    double? defaultWidth,
  }) {
    return Paint()
      ..color = axis.color ?? visuals.pattern
      ..strokeWidth = resolveMarkWidth(
        axis,
        behavior,
        defaultWidth: defaultWidth,
      )
      ..strokeCap = StrokeCap.round;
  }
}
