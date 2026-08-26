part of '../nts_page_background_recipe.dart';

/// 自訂背景在頁面座標中的單一節點；不包含選取或 hover 狀態。
@immutable
class NtsPageBackgroundPoint {
  const NtsPageBackgroundPoint({required this.id, required this.position});

  final int id;
  final Offset position;

  @override
  bool operator ==(Object other) {
    return other is NtsPageBackgroundPoint &&
        other.id == id &&
        other.position == position;
  }

  @override
  int get hashCode => Object.hash(id, position);
}

/// 以兩個 point id 表示端點的直線；不保存重複的端點座標。
@immutable
class NtsPageBackgroundLine {
  const NtsPageBackgroundLine({
    required this.id,
    required this.startPointId,
    required this.endPointId,
  });

  final int id;
  final int startPointId;
  final int endPointId;

  @override
  bool operator ==(Object other) {
    return other is NtsPageBackgroundLine &&
        other.id == id &&
        other.startPointId == startPointId &&
        other.endPointId == endPointId;
  }

  @override
  int get hashCode => Object.hash(id, startPointId, endPointId);
}

/// 只允許 point 與 line 的自訂背景資料。
///
/// 此 recipe 不負責產品保存、undo history 或 viewport 手勢。
final class NtsCustomPageBackgroundRecipe extends NtsPageBackgroundRecipe {
  NtsCustomPageBackgroundRecipe({
    List<NtsPageBackgroundPoint> points = const [],
    List<NtsPageBackgroundLine> lines = const [],
    NtsPageBackgroundAxisStyle? pointStyle,
    NtsPageBackgroundAxisStyle? lineStyle,
    this.snapSpacing,
    this.strokeBehavior = NtsPageBackgroundStrokeBehavior.fixed,
  }) : points = List.unmodifiable(points),
       lines = List.unmodifiable(lines),
       pointStyle = pointStyle ?? NtsPageBackgroundAxisStyle(),
       lineStyle = lineStyle ?? NtsPageBackgroundAxisStyle() {
    final resolvedSnapSpacing = snapSpacing;
    if (resolvedSnapSpacing != null) {
      _requirePositiveFinite(resolvedSnapSpacing, 'snapSpacing');
    }
    _validateElements(this.points, this.lines);
  }

  final List<NtsPageBackgroundPoint> points;
  final List<NtsPageBackgroundLine> lines;
  final NtsPageBackgroundAxisStyle pointStyle;
  final NtsPageBackgroundAxisStyle lineStyle;
  final double? snapSpacing;
  final NtsPageBackgroundStrokeBehavior strokeBehavior;

  int get nextPointId => _nextId(points.map((point) => point.id));

  int get nextLineId => _nextId(lines.map((line) => line.id));

  NtsPageBackgroundPoint? pointById(int id) {
    for (final point in points) {
      if (point.id == id) return point;
    }
    return null;
  }

  NtsCustomPageBackgroundRecipe copyWith({
    List<NtsPageBackgroundPoint>? points,
    List<NtsPageBackgroundLine>? lines,
    NtsPageBackgroundAxisStyle? pointStyle,
    NtsPageBackgroundAxisStyle? lineStyle,
    double? snapSpacing,
    NtsPageBackgroundStrokeBehavior? strokeBehavior,
  }) {
    return NtsCustomPageBackgroundRecipe(
      points: points ?? this.points,
      lines: lines ?? this.lines,
      pointStyle: pointStyle ?? this.pointStyle,
      lineStyle: lineStyle ?? this.lineStyle,
      snapSpacing: snapSpacing ?? this.snapSpacing,
      strokeBehavior: strokeBehavior ?? this.strokeBehavior,
    );
  }

  NtsCustomPageBackgroundRecipe removePoint(int id) {
    return copyWith(
      points: [
        for (final point in points)
          if (point.id != id) point,
      ],
      lines: [
        for (final line in lines)
          if (line.startPointId != id && line.endPointId != id) line,
      ],
    );
  }

  NtsCustomPageBackgroundRecipe removeLine(int id) {
    return copyWith(
      lines: [
        for (final line in lines)
          if (line.id != id) line,
      ],
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NtsCustomPageBackgroundRecipe &&
        listEquals(other.points, points) &&
        listEquals(other.lines, lines) &&
        other.pointStyle == pointStyle &&
        other.lineStyle == lineStyle &&
        other.snapSpacing == snapSpacing &&
        other.strokeBehavior == strokeBehavior;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(points),
    Object.hashAll(lines),
    pointStyle,
    lineStyle,
    snapSpacing,
    strokeBehavior,
  );
}

void _validateElements(
  List<NtsPageBackgroundPoint> points,
  List<NtsPageBackgroundLine> lines,
) {
  final pointIds = <int>{};
  for (final point in points) {
    if (point.id < 0 || !pointIds.add(point.id)) {
      throw ArgumentError.value(point.id, 'points', 'ids must be unique');
    }
    if (!_isFiniteOffset(point.position)) {
      throw ArgumentError.value(
        point.position,
        'points',
        'positions must be finite',
      );
    }
  }

  final lineIds = <int>{};
  for (final line in lines) {
    if (line.id < 0 || !lineIds.add(line.id)) {
      throw ArgumentError.value(line.id, 'lines', 'ids must be unique');
    }
    if (line.startPointId == line.endPointId ||
        !pointIds.contains(line.startPointId) ||
        !pointIds.contains(line.endPointId)) {
      throw ArgumentError.value(line, 'lines', 'endpoints must exist');
    }
  }
}

int _nextId(Iterable<int> ids) {
  var next = 0;
  for (final id in ids) {
    if (id >= next) next = id + 1;
  }
  return next;
}

bool _isFiniteOffset(Offset value) {
  return value.dx.isFinite && value.dy.isFinite;
}

void _requirePositiveFinite(double value, String name) {
  if (!value.isFinite || value <= 0) {
    throw ArgumentError.value(value, name, 'must be finite and positive');
  }
}
