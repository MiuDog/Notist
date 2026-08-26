import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../nts_page_background_recipe.dart';

part 'nts_page_background_paint_operations.dart';

/// renderer 已解析的 semantic 預設值；不包含產品或編輯狀態。
@immutable
class NtsPageBackgroundVisuals {
  const NtsPageBackgroundVisuals({
    required this.surface,
    required this.pattern,
    required this.spacing,
    required this.markWidth,
    required this.dotWidth,
  });

  final Color surface;
  final Color pattern;
  final double spacing;
  final double markWidth;
  final double dotWidth;

  @override
  bool operator ==(Object other) {
    return other is NtsPageBackgroundVisuals &&
        other.surface == surface &&
        other.pattern == pattern &&
        other.spacing == spacing &&
        other.markWidth == markWidth &&
        other.dotWidth == dotWidth;
  }

  @override
  int get hashCode =>
      Object.hash(surface, pattern, spacing, markWidth, dotWidth);
}

/// 所有頁面背景 recipe 共用的內部 renderer。
///
/// 呼叫端應使用 `NtsPageBackground`，不直接依賴這個實作型別。
class NtsPageBackgroundPainter extends CustomPainter {
  const NtsPageBackgroundPainter({
    required this.recipe,
    required this.viewport,
    required this.visuals,
  });

  final NtsPageBackgroundRecipe recipe;
  final NtsPageBackgroundViewport viewport;
  final NtsPageBackgroundVisuals visuals;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    canvas.drawRect(Offset.zero & size, Paint()..color = visuals.surface);

    switch (recipe) {
      case NtsPlainPageBackgroundRecipe():
        return;
      case NtsRuledPageBackgroundRecipe recipe:
        _paintRuled(canvas, size, recipe);
      case NtsDotsPageBackgroundRecipe recipe:
        _paintPeriodic(canvas, size, recipe, dots: true);
      case NtsGridPageBackgroundRecipe recipe:
        _paintPeriodic(canvas, size, recipe, dots: false);
      case NtsCustomPageBackgroundRecipe recipe:
        _paintCustom(canvas, recipe);
    }
  }

  @visibleForTesting
  double resolveMarkWidth(
    NtsPageBackgroundAxisStyle axis,
    NtsPageBackgroundStrokeBehavior behavior, {
    double? defaultWidth,
  }) {
    final scale = behavior == NtsPageBackgroundStrokeBehavior.scaled
        ? viewport.scale
        : 1.0;
    return (axis.width ?? defaultWidth ?? visuals.markWidth) * scale;
  }

  double _toViewportCoordinate(double coordinate, double origin) {
    return (coordinate - origin) * viewport.scale;
  }

  @override
  bool shouldRepaint(covariant NtsPageBackgroundPainter oldDelegate) {
    return oldDelegate.recipe != recipe ||
        oldDelegate.viewport != viewport ||
        oldDelegate.visuals != visuals;
  }
}
