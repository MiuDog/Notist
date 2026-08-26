// 公開參數必須維持既有的 style 名稱，不能改成私有欄位形式。
// ignore_for_file: prefer_initializing_formals

import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';
import 'internal/nts_page_background_painter.dart';
import 'nts_page_background_recipe.dart';

/// 頁面的內建向量背景樣式；只描述視覺語意，不保存產品資料。
enum NtsPageBackgroundStyle { plain, ruled, dots, grid }

/// 在 [child] 下方繪製會隨 Kallopis theme 改變的頁面背景。
class NtsPageBackground extends StatelessWidget {
  const NtsPageBackground({
    super.key,
    required NtsPageBackgroundStyle style,
    required this.child,
  }) : _style = style,
       recipe = null,
       viewport = null;

  const NtsPageBackground.recipe({
    super.key,
    required this.recipe,
    required this.child,
    this.viewport,
  }) : _style = null;

  final NtsPageBackgroundStyle? _style;

  /// 舊式樣建構式所選的內建樣式。
  ///
  /// recipe 建構式沒有對應 enum；該模式請讀 [recipe]，不要讀這個 getter。
  NtsPageBackgroundStyle get style => _style!;

  final NtsPageBackgroundRecipe? recipe;
  final NtsPageBackgroundViewport? viewport;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final klp = context.klp;
    final visuals = NtsPageBackgroundVisuals(
      surface: klp.color.stageSurface,
      pattern: klp.color.pagePattern,
      spacing: klp.space.loose,
      markWidth: klp.shape.hairline,
      dotWidth: klp.shape.stroke,
    );

    return CustomPaint(
      painter: NtsPageBackgroundPainter(
        recipe: recipe ?? _recipeFor(_style!),
        viewport: viewport ?? NtsPageBackgroundViewport(),
        visuals: visuals,
      ),
      child: child,
    );
  }

  NtsPageBackgroundRecipe _recipeFor(NtsPageBackgroundStyle style) {
    return switch (style) {
      NtsPageBackgroundStyle.plain => const NtsPlainPageBackgroundRecipe(),
      NtsPageBackgroundStyle.ruled => NtsRuledPageBackgroundRecipe(),
      NtsPageBackgroundStyle.dots => NtsDotsPageBackgroundRecipe(),
      NtsPageBackgroundStyle.grid => NtsGridPageBackgroundRecipe(),
    };
  }
}
