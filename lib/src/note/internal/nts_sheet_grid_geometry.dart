import 'dart:math' as math;

/// Sheet 軌道的累積位置與命中演算法。
final class NtsSheetGridGeometry {
  NtsSheetGridGeometry({
    required this.rowHeaderWidth,
    required this.columnWidth,
    required this.rowHeight,
    required this.headerHeight,
    required int columnCount,
  }) : _columnOffsets = _offsets(columnCount, columnWidth);

  final double rowHeaderWidth;
  final double columnWidth;
  final double rowHeight;
  final double headerHeight;
  final List<double> _columnOffsets;

  int get columnCount => _columnOffsets.length - 1;

  double get totalWidth => rowHeaderWidth + _columnOffsets.last;

  double columnOffset(int column) => rowHeaderWidth + _columnOffsets[column];

  int? columnAt(double position) {
    final localPosition = position - rowHeaderWidth;
    if (localPosition < 0 || localPosition >= _columnOffsets.last) return null;

    var low = 0;
    var high = _columnOffsets.length - 1;
    while (low + 1 < high) {
      final middle = (low + high) ~/ 2;
      if (_columnOffsets[middle] <= localPosition) {
        low = middle;
      } else {
        high = middle;
      }
    }
    return low;
  }

  (int, int) visibleColumns(double offset, double viewportWidth) {
    final first = columnAt(offset) ?? 0;
    final last = columnAt(offset + viewportWidth) ?? columnCount - 1;
    return (math.max(0, first - 1), math.min(columnCount - 1, last + 1));
  }

  static List<double> _offsets(int count, double extent) {
    return List<double>.generate(count + 1, (index) => index * extent);
  }
}
