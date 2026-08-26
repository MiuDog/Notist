part of '../nts_page_background_recipe.dart';

enum NtsPageBackgroundStrokeBehavior { fixed, scaled }

/// 背景編輯器目前使用的工具。
enum NtsPageBackgroundEditorTool { connect, select, delete }

/// 可被選取的背景圖元種類。
enum NtsPageBackgroundElementKind { point, line }

/// 背景編輯器的單一選取結果；選取狀態不會寫入 recipe。
@immutable
class NtsPageBackgroundSelection {
  const NtsPageBackgroundSelection.point(this.id)
    : kind = NtsPageBackgroundElementKind.point;

  const NtsPageBackgroundSelection.line(this.id)
    : kind = NtsPageBackgroundElementKind.line;

  final NtsPageBackgroundElementKind kind;
  final int id;

  @override
  bool operator ==(Object other) {
    return other is NtsPageBackgroundSelection &&
        other.kind == kind &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(kind, id);
}

/// 頁面座標與 viewport 座標之間的單一轉換來源。
@immutable
class NtsPageBackgroundViewport {
  NtsPageBackgroundViewport({this.origin = Offset.zero, this.scale = 1}) {
    if (!_isFiniteOffset(origin)) {
      throw ArgumentError.value(origin, 'origin', 'must be finite');
    }
    _requirePositiveFinite(scale, 'scale');
  }

  final Offset origin;
  final double scale;

  Offset pageToViewport(Offset position) => (position - origin) * scale;

  Offset viewportToPage(Offset position) => position / scale + origin;

  @override
  bool operator ==(Object other) {
    return other is NtsPageBackgroundViewport &&
        other.origin == origin &&
        other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(origin, scale);
}

/// 主軸、次軸、線或點的執行期外觀。
///
/// `null` 代表沿用目前 Kallopis semantic theme。
@immutable
class NtsPageBackgroundAxisStyle {
  NtsPageBackgroundAxisStyle({this.color, this.width}) {
    final resolvedWidth = width;
    if (resolvedWidth != null) {
      _requirePositiveFinite(resolvedWidth, 'width');
    }
  }

  final Color? color;
  final double? width;

  NtsPageBackgroundAxisStyle copyWith({Color? color, double? width}) {
    return NtsPageBackgroundAxisStyle(
      color: color ?? this.color,
      width: width ?? this.width,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NtsPageBackgroundAxisStyle &&
        other.color == color &&
        other.width == width;
  }

  @override
  int get hashCode => Object.hash(color, width);
}
