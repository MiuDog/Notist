import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/src/components/note/note_components.dart';

void main() {
  testWidgets('NotistSheetGrid supports controlled selection and editing', (
    tester,
  ) async {
    (int, int, String)? committed;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildKlpTheme(Brightness.light),
        home: SizedBox(
          width: 480,
          height: 240,
          child: NotistSheetGrid(
            cellValueAt: (row, column) => row == 0 && column == 0 ? 'A1' : null,
            onCellCommitted: (row, column, value) {
              committed = (row, column, value);
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('notist-sheet-cell-r0-c0')));
    await tester.pump(kDoubleTapTimeout);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(
      find.byKey(const ValueKey('notist-sheet-selection-r0-c1')),
      findsOneWidget,
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    final editor = find.byKey(const ValueKey('notist-sheet-editor-r0-c1'));
    await tester.showKeyboard(editor);
    await tester.enterText(editor, 'Next');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(committed, (0, 1, 'Next'));
  });

  testWidgets('NotistSheetGrid supports double-click editing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildKlpTheme(Brightness.light),
        home: SizedBox(
          width: 360,
          height: 200,
          child: NotistSheetGrid(
            cellValueAt: (_, _) => null,
            onCellCommitted: (_, _, _) {},
          ),
        ),
      ),
    );

    final cell = find.byKey(const ValueKey('notist-sheet-cell-r0-c0'));
    await tester.tap(cell);
    await tester.pump(kDoubleTapMinTime);
    await tester.tap(cell);
    await tester.pump();

    expect(
      find.byKey(const ValueKey('notist-sheet-editor-r0-c0')),
      findsOneWidget,
    );
    await tester.pump(kDoubleTapTimeout);
  });
}
