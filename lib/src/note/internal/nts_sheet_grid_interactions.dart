part of '../nts_sheet_grid.dart';

extension _NtsSheetGridInteractions on _NtsSheetGridState {
  KeyEventResult _handleGridKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || _editing) return KeyEventResult.ignored;

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowUp) return _moveSelection(-1, 0);
    if (key == LogicalKeyboardKey.arrowDown) return _moveSelection(1, 0);
    if (key == LogicalKeyboardKey.arrowLeft) return _moveSelection(0, -1);
    if (key == LogicalKeyboardKey.arrowRight) return _moveSelection(0, 1);
    if (key == LogicalKeyboardKey.enter) {
      _startEditing(_selectedRow, _selectedColumn);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _moveSelection(int rowDelta, int columnDelta) {
    _selectCell(
      (_selectedRow + rowDelta).clamp(0, _rowCount - 1),
      (_selectedColumn + columnDelta).clamp(0, _columnCount - 1),
    );
    return KeyEventResult.handled;
  }

  void _selectCell(int row, int column) {
    _update(() {
      _selectedRow = row;
      _selectedColumn = column;
      _editing = false;
    });
    _gridFocus.requestFocus();
  }

  void _startEditing(int row, int column) {
    _update(() {
      _selectedRow = row;
      _selectedColumn = column;
      _editing = true;
      final value = widget.cellValueAt(row, column) ?? '';
      _editorController.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    });
    _editorFocus.requestFocus();
  }

  void _submitEditing(String value) {
    widget.onCellCommitted(_selectedRow, _selectedColumn, value);
    _update(() => _editing = false);
    _gridFocus.requestFocus();
  }

  void _handleHorizontalScroll() {
    if (!_horizontalScroll.hasClients || !mounted) return;

    final position = _horizontalScroll.position;
    final nearEdge = position.extentAfter <= position.viewportDimension;
    if (!nearEdge) {
      _extendedHorizontally = false;
      _update(() {});
      return;
    }
    if (_extendedHorizontally) {
      _update(() {});
      return;
    }
    _update(() {
      _columnCount += _NtsSheetGridState._columnExpansion;
      _extendedHorizontally = true;
    });
  }

  void _handleVerticalScroll() {
    if (!_verticalScroll.hasClients || !mounted) return;

    final position = _verticalScroll.position;
    final nearEdge = position.extentAfter <= position.viewportDimension;
    if (!nearEdge) {
      _extendedVertically = false;
      return;
    }
    if (_extendedVertically) return;

    _update(() {
      _rowCount += _NtsSheetGridState._rowExpansion;
      _extendedVertically = true;
    });
  }
}
