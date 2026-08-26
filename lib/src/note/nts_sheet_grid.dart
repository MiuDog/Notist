import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kallopis/kallopis.dart';
import 'internal/nts_sheet_grid_geometry.dart';

part 'internal/nts_sheet_grid_cells.dart';
part 'internal/nts_sheet_grid_cell.dart';
part 'internal/nts_sheet_grid_interactions.dart';

/// 依 row、column 取得受控 Sheet cell 文字。
typedef NtsSheetCellValueAt = String? Function(int row, int column);

/// 將使用者提交的 cell 編輯交還給消費端資料層。
typedef NtsSheetCellCommitted =
    void Function(int row, int column, String value);

/// 向右、向下持續擴充的受控試算表視圖。
///
/// 元件只保存選取、編輯與 viewport 狀態；cell 資料由 [cellValueAt] 提供，編輯結果透過
/// [onCellCommitted] 回傳。抵達目前右方或下方邊界時會增加虛擬軌道，不建立完整二維資料。
class NtsSheetGrid extends StatefulWidget {
  const NtsSheetGrid({
    super.key,
    required this.cellValueAt,
    required this.onCellCommitted,
    this.horizontalController,
    this.verticalController,
    this.initialRowCount = 100,
    this.initialColumnCount = 26,
  }) : assert(initialRowCount > 0),
       assert(initialColumnCount > 0);

  final NtsSheetCellValueAt cellValueAt;
  final NtsSheetCellCommitted onCellCommitted;
  final ScrollController? horizontalController;
  final ScrollController? verticalController;
  final int initialRowCount;
  final int initialColumnCount;

  @override
  State<NtsSheetGrid> createState() => _NtsSheetGridState();
}

class _NtsSheetGridState extends State<NtsSheetGrid> {
  static const int _rowExpansion = 50;
  static const int _columnExpansion = 10;

  final FocusNode _gridFocus = FocusNode(debugLabel: 'Notist Sheet grid');
  final FocusNode _editorFocus = FocusNode(debugLabel: 'Notist Sheet cell');
  final TextEditingController _editorController = TextEditingController();

  late final ScrollController _horizontalScroll =
      widget.horizontalController ?? ScrollController();
  late final ScrollController _verticalScroll =
      widget.verticalController ?? ScrollController();
  late int _rowCount = widget.initialRowCount;
  late int _columnCount = widget.initialColumnCount;
  int _selectedRow = 0;
  int _selectedColumn = 0;
  bool _editing = false;
  bool _extendedHorizontally = false;
  bool _extendedVertically = false;

  void _update(VoidCallback change) {
    setState(change);
  }

  @override
  void initState() {
    super.initState();
    _horizontalScroll.addListener(_handleHorizontalScroll);
    _verticalScroll.addListener(_handleVerticalScroll);
  }

  @override
  void dispose() {
    _horizontalScroll.removeListener(_handleHorizontalScroll);
    _verticalScroll.removeListener(_handleVerticalScroll);
    if (widget.horizontalController == null) _horizontalScroll.dispose();
    if (widget.verticalController == null) _verticalScroll.dispose();
    _gridFocus.dispose();
    _editorFocus.dispose();
    _editorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final klp = context.klp;
    final geometry = NtsSheetGridGeometry(
      rowHeaderWidth: klp.space.sectionLarge,
      columnWidth: klp.space.pageLarge,
      rowHeight: klp.space.controlHeight,
      headerHeight: klp.space.controlHeightSmall,
      columnCount: _columnCount,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalOffset = _horizontalScroll.hasClients
            ? _horizontalScroll.offset
            : 0.0;
        final (firstColumn, lastColumn) = geometry.visibleColumns(
          horizontalOffset,
          constraints.maxWidth,
        );

        return ColoredBox(
          color: context.klpColors.stageSurface,
          child: Focus(
            key: const ValueKey('nts-sheet-grid'),
            focusNode: _gridFocus,
            autofocus: true,
            onKeyEvent: _handleGridKey,
            child: Semantics(
              container: true,
              label: 'Sheet grid',
              child: Scrollbar(
                controller: _horizontalScroll,
                notificationPredicate: (notification) =>
                    notification.depth == 0,
                child: SingleChildScrollView(
                  controller: _horizontalScroll,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: geometry.totalWidth,
                    child: Column(
                      children: [
                        _NtsSheetHeader(
                          geometry: geometry,
                          firstColumn: firstColumn,
                          lastColumn: lastColumn,
                        ),
                        Expanded(
                          child: Scrollbar(
                            controller: _verticalScroll,
                            child: ListView.builder(
                              controller: _verticalScroll,
                              itemExtent: geometry.rowHeight,
                              itemCount: _rowCount,
                              itemBuilder: (context, row) => _NtsSheetRow(
                                row: row,
                                geometry: geometry,
                                firstColumn: firstColumn,
                                lastColumn: lastColumn,
                                selectedRow: _selectedRow,
                                selectedColumn: _selectedColumn,
                                editing: _editing,
                                cellValueAt: widget.cellValueAt,
                                editorController: _editorController,
                                editorFocus: _editorFocus,
                                onCellTap: _selectCell,
                                onCellDoubleTap: _startEditing,
                                onSubmitted: _submitEditing,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
