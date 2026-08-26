part of '../nts_sheet_grid.dart';

final class _NtsSheetHeader extends StatelessWidget {
  const _NtsSheetHeader({
    required this.geometry,
    required this.firstColumn,
    required this.lastColumn,
  });

  final NtsSheetGridGeometry geometry;
  final int firstColumn;
  final int lastColumn;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: geometry.totalWidth,
      height: geometry.headerHeight,
      child: Stack(
        children: [
          _NtsSheetHeaderCell(
            width: geometry.rowHeaderWidth,
            height: geometry.headerHeight,
            label: '',
          ),
          for (var column = firstColumn; column <= lastColumn; column++)
            Positioned(
              left: geometry.columnOffset(column),
              child: _NtsSheetHeaderCell(
                width: geometry.columnWidth,
                height: geometry.headerHeight,
                label: _columnLabel(column),
              ),
            ),
        ],
      ),
    );
  }
}

final class _NtsSheetRow extends StatelessWidget {
  const _NtsSheetRow({
    required this.row,
    required this.geometry,
    required this.firstColumn,
    required this.lastColumn,
    required this.selectedRow,
    required this.selectedColumn,
    required this.editing,
    required this.cellValueAt,
    required this.editorController,
    required this.editorFocus,
    required this.onCellTap,
    required this.onCellDoubleTap,
    required this.onSubmitted,
  });

  final int row;
  final NtsSheetGridGeometry geometry;
  final int firstColumn;
  final int lastColumn;
  final int selectedRow;
  final int selectedColumn;
  final bool editing;
  final NtsSheetCellValueAt cellValueAt;
  final TextEditingController editorController;
  final FocusNode editorFocus;
  final void Function(int row, int column) onCellTap;
  final void Function(int row, int column) onCellDoubleTap;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: geometry.totalWidth,
      height: geometry.rowHeight,
      child: Stack(
        children: [
          _NtsSheetHeaderCell(
            width: geometry.rowHeaderWidth,
            height: geometry.rowHeight,
            label: '${row + 1}',
          ),
          for (var column = firstColumn; column <= lastColumn; column++)
            Positioned(
              left: geometry.columnOffset(column),
              child: _NtsSheetCell(
                row: row,
                column: column,
                width: geometry.columnWidth,
                height: geometry.rowHeight,
                value: cellValueAt(row, column),
                selected: row == selectedRow && column == selectedColumn,
                editing:
                    editing && row == selectedRow && column == selectedColumn,
                editorController: editorController,
                editorFocus: editorFocus,
                onTap: () => onCellTap(row, column),
                onDoubleTap: () => onCellDoubleTap(row, column),
                onSubmitted: onSubmitted,
              ),
            ),
        ],
      ),
    );
  }
}
