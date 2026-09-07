import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/src/components/note/note_components.dart';

void main() {
  testWidgets('Ink 預覽只繪製消費端提供的點位並忽略輸入', (tester) async {
    await tester.pumpWidget(
      const KlpApp(
        showWindowHeader: false,
        home: KlpPanelFrame(
          padding: EdgeInsets.zero,
          content: SizedBox(
            width: 160,
            height: 100,
            child: NotistNoteInkPreview(
              origin: Offset(8, 8),
              points: [Offset.zero, Offset(24, 0), Offset(12, 24)],
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('notist-note-ink-preview')),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is IgnorePointer && widget.ignoring,
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
