part of '../nts_page_background_recipe.dart';

/// 頁面背景的不可變視覺 recipe。
@immutable
sealed class NtsPageBackgroundRecipe {
  const NtsPageBackgroundRecipe();
}

/// 只呈現目前 theme 頁面表面的背景，不包含任何圖樣。
final class NtsPlainPageBackgroundRecipe extends NtsPageBackgroundRecipe {
  const NtsPlainPageBackgroundRecipe();

  @override
  bool operator ==(Object other) => other is NtsPlainPageBackgroundRecipe;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// 等距橫線背景；只保存視覺幾何，不決定文字行高或文件排版。
final class NtsRuledPageBackgroundRecipe extends NtsPageBackgroundRecipe {
  NtsRuledPageBackgroundRecipe({
    NtsPageBackgroundAxisStyle? axis,
    this.spacing,
    this.strokeBehavior = NtsPageBackgroundStrokeBehavior.fixed,
  }) : axis = axis ?? NtsPageBackgroundAxisStyle() {
    final resolvedSpacing = spacing;
    if (resolvedSpacing != null) {
      _requirePositiveFinite(resolvedSpacing, 'spacing');
    }
  }

  final NtsPageBackgroundAxisStyle axis;
  final double? spacing;
  final NtsPageBackgroundStrokeBehavior strokeBehavior;

  NtsRuledPageBackgroundRecipe copyWith({
    NtsPageBackgroundAxisStyle? axis,
    double? spacing,
    NtsPageBackgroundStrokeBehavior? strokeBehavior,
  }) {
    return NtsRuledPageBackgroundRecipe(
      axis: axis ?? this.axis,
      spacing: spacing ?? this.spacing,
      strokeBehavior: strokeBehavior ?? this.strokeBehavior,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NtsRuledPageBackgroundRecipe &&
        other.axis == axis &&
        other.spacing == spacing &&
        other.strokeBehavior == strokeBehavior;
  }

  @override
  int get hashCode => Object.hash(axis, spacing, strokeBehavior);
}

/// 具有主軸與次軸週期的背景 recipe 共用契約。
///
/// 這個型別只定義週期幾何，不決定圖樣要以點或線呈現。
sealed class NtsPeriodicPageBackgroundRecipe extends NtsPageBackgroundRecipe {
  NtsPeriodicPageBackgroundRecipe({
    NtsPageBackgroundAxisStyle? minorAxis,
    NtsPageBackgroundAxisStyle? majorAxis,
    this.majorSpacing,
    this.minorAxisCount = 0,
    this.strokeBehavior = NtsPageBackgroundStrokeBehavior.fixed,
  }) : minorAxis = minorAxis ?? NtsPageBackgroundAxisStyle(),
       majorAxis = majorAxis ?? NtsPageBackgroundAxisStyle() {
    final resolvedSpacing = majorSpacing;
    if (resolvedSpacing != null) {
      _requirePositiveFinite(resolvedSpacing, 'majorSpacing');
    }
    if (minorAxisCount < 0) {
      throw ArgumentError.value(
        minorAxisCount,
        'minorAxisCount',
        'must not be negative',
      );
    }
  }

  final NtsPageBackgroundAxisStyle minorAxis;
  final NtsPageBackgroundAxisStyle majorAxis;
  final double? majorSpacing;
  final int minorAxisCount;
  final NtsPageBackgroundStrokeBehavior strokeBehavior;

  double? get minorSpacing {
    final spacing = majorSpacing;
    return spacing == null ? null : spacing / (minorAxisCount + 1);
  }

  bool equalsPeriodic(NtsPeriodicPageBackgroundRecipe other) {
    return other.minorAxis == minorAxis &&
        other.majorAxis == majorAxis &&
        other.majorSpacing == majorSpacing &&
        other.minorAxisCount == minorAxisCount &&
        other.strokeBehavior == strokeBehavior;
  }

  int get periodicHashCode => Object.hash(
    minorAxis,
    majorAxis,
    majorSpacing,
    minorAxisCount,
    strokeBehavior,
  );
}

/// 以點徑呈現主次週期的背景；`width` 在此代表點的直徑。
final class NtsDotsPageBackgroundRecipe
    extends NtsPeriodicPageBackgroundRecipe {
  NtsDotsPageBackgroundRecipe({
    super.minorAxis,
    super.majorAxis,
    super.majorSpacing,
    super.minorAxisCount,
    super.strokeBehavior,
  });

  NtsDotsPageBackgroundRecipe copyWith({
    NtsPageBackgroundAxisStyle? minorAxis,
    NtsPageBackgroundAxisStyle? majorAxis,
    double? majorSpacing,
    int? minorAxisCount,
    NtsPageBackgroundStrokeBehavior? strokeBehavior,
  }) {
    return NtsDotsPageBackgroundRecipe(
      minorAxis: minorAxis ?? this.minorAxis,
      majorAxis: majorAxis ?? this.majorAxis,
      majorSpacing: majorSpacing ?? this.majorSpacing,
      minorAxisCount: minorAxisCount ?? this.minorAxisCount,
      strokeBehavior: strokeBehavior ?? this.strokeBehavior,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NtsDotsPageBackgroundRecipe && equalsPeriodic(other);
  }

  @override
  int get hashCode => Object.hash(runtimeType, periodicHashCode);
}

/// 以水平與垂直線呈現主次週期的背景。
final class NtsGridPageBackgroundRecipe
    extends NtsPeriodicPageBackgroundRecipe {
  NtsGridPageBackgroundRecipe({
    super.minorAxis,
    super.majorAxis,
    super.majorSpacing,
    super.minorAxisCount,
    super.strokeBehavior,
  });

  NtsGridPageBackgroundRecipe copyWith({
    NtsPageBackgroundAxisStyle? minorAxis,
    NtsPageBackgroundAxisStyle? majorAxis,
    double? majorSpacing,
    int? minorAxisCount,
    NtsPageBackgroundStrokeBehavior? strokeBehavior,
  }) {
    return NtsGridPageBackgroundRecipe(
      minorAxis: minorAxis ?? this.minorAxis,
      majorAxis: majorAxis ?? this.majorAxis,
      majorSpacing: majorSpacing ?? this.majorSpacing,
      minorAxisCount: minorAxisCount ?? this.minorAxisCount,
      strokeBehavior: strokeBehavior ?? this.strokeBehavior,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NtsGridPageBackgroundRecipe && equalsPeriodic(other);
  }

  @override
  int get hashCode => Object.hash(runtimeType, periodicHashCode);
}
