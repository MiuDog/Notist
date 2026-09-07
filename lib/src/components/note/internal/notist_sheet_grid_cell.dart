part of '../notist_sheet_grid.dart';

final class _NotistSheetHeaderCell extends StatelessWidget {
  const _NotistSheetHeaderCell({
    required this.width,
    required this.height,
    required this.label,
  });

  final double width;
  final double height;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.klpColors;
    final klp = context.klp;

    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tokens.surfaceInset,
        border: Border(
          right: BorderSide(color: tokens.divider, width: klp.shape.hairline),
          bottom: BorderSide(color: tokens.divider, width: klp.shape.hairline),
        ),
      ),
      child: KlpText(label, role: KlpTextRole.caption, tone: KlpTextTone.muted),
    );
  }
}

final class _NotistSheetCell extends StatelessWidget {
  const _NotistSheetCell({
    required this.row,
    required this.column,
    required this.width,
    required this.height,
    required this.value,
    required this.selected,
    required this.editing,
    required this.editorController,
    required this.editorFocus,
    required this.onTap,
    required this.onDoubleTap,
    required this.onSubmitted,
  });

  final int row;
  final int column;
  final double width;
  final double height;
  final String? value;
  final bool selected;
  final bool editing;
  final TextEditingController editorController;
  final FocusNode editorFocus;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final tokens = context.klpColors;
    final klp = context.klp;
    final content = Container(
      key: selected ? ValueKey('notist-sheet-selection-r$row-c$column') : null,
      width: width,
      height: height,
      padding: EdgeInsets.symmetric(horizontal: klp.space.contentInset),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: selected ? klp.selectionWash : tokens.stageSurface,
        border: Border(
          right: BorderSide(color: tokens.divider, width: klp.shape.hairline),
          bottom: BorderSide(color: tokens.divider, width: klp.shape.hairline),
        ),
      ),
      child: editing
          ? KlpTextField(
              key: ValueKey('notist-sheet-editor-r$row-c$column'),
              controller: editorController,
              focusNode: editorFocus,
              autofocus: true,
              size: KlpControlSize.sm,
              onSubmitted: onSubmitted,
            )
          : KlpText(
              value ?? '',
              role: KlpTextRole.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
    );

    final cell = SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          content,
          if (selected)
            IgnorePointer(
              child: KlpDashedBorder(
                radius: klp.shape.none,
                child: const SizedBox.expand(),
              ),
            ),
        ],
      ),
    );

    return Semantics(
      label: '${_columnLabel(column)}${row + 1}',
      selected: selected,
      button: true,
      onTap: onTap,
      child: GestureDetector(
        key: ValueKey('notist-sheet-cell-r$row-c$column'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        child: cell,
      ),
    );
  }
}

String _columnLabel(int column) {
  var value = column + 1;
  final characters = <int>[];
  while (value > 0) {
    value--;
    characters.add(65 + value % 26);
    value ~/= 26;
  }
  return String.fromCharCodes(characters.reversed);
}
