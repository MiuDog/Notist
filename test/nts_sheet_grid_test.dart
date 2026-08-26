import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/notist.dart';

void main() {
  testWidgets('Sheet 支援選取、鍵盤移動與受控編輯提交', (tester) async {
    (int, int, String)? committed;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildKlpTheme(Brightness.light),
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 480,
            height: 240,
            child: NtsSheetGrid(
              cellValueAt: (row, column) =>
                  row == 0 && column == 0 ? 'A1' : null,
              onCellCommitted: (row, column, value) {
                committed = (row, column, value);
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('nts-sheet-cell-r0-c0')));
    await tester.pump(kDoubleTapTimeout);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();

    expect(
      find.byKey(const ValueKey('nts-sheet-selection-r0-c1')),
      findsOneWidget,
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    final editor = find.byKey(const ValueKey('nts-sheet-editor-r0-c1'));
    await tester.showKeyboard(editor);
    await tester.enterText(editor, 'Next');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(committed, (0, 1, 'Next'));
  });

  testWidgets('Sheet 抵達右方與下方邊界時繼續擴充', (tester) async {
    final horizontal = ScrollController();
    final vertical = ScrollController();
    addTearDown(horizontal.dispose);
    addTearDown(vertical.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildKlpTheme(Brightness.light),
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 360,
            height: 200,
            child: NtsSheetGrid(
              horizontalController: horizontal,
              verticalController: vertical,
              initialRowCount: 8,
              initialColumnCount: 6,
              cellValueAt: (_, _) => null,
              onCellCommitted: (_, _, _) {},
            ),
          ),
        ),
      ),
    );

    final initialHorizontalExtent = horizontal.position.maxScrollExtent;
    final initialVerticalExtent = vertical.position.maxScrollExtent;
    horizontal.jumpTo(initialHorizontalExtent);
    vertical.jumpTo(initialVerticalExtent);
    await tester.pump();

    expect(
      horizontal.position.maxScrollExtent,
      greaterThan(initialHorizontalExtent),
    );
    expect(
      vertical.position.maxScrollExtent,
      greaterThan(initialVerticalExtent),
    );
  });

  testWidgets('Sheet 支援雙擊 cell 進入編輯', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildKlpTheme(Brightness.light),
        home: SizedBox(
          width: 360,
          height: 200,
          child: NtsSheetGrid(
            cellValueAt: (_, _) => null,
            onCellCommitted: (_, _, _) {},
          ),
        ),
      ),
    );

    final cell = find.byKey(const ValueKey('nts-sheet-cell-r0-c0'));
    await tester.tap(cell);
    await tester.pump(kDoubleTapMinTime);
    await tester.tap(cell);
    await tester.pump();

    expect(
      find.byKey(const ValueKey('nts-sheet-editor-r0-c0')),
      findsOneWidget,
    );
    await tester.pump(kDoubleTapTimeout);
  });
}
