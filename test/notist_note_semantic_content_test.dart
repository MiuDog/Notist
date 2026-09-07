import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/src/components/note/note_components.dart';

void main() {
  testWidgets(
    'comment placeholder hides consumer source behind semantic label',
    (tester) async {
      await tester.pumpWidget(
        const KlpApp(
          showWindowHeader: false,
          home: KlpPanelFrame(
            padding: EdgeInsets.zero,
            content: NotistNoteCommentPlaceholder(
              label: '註解',
              semanticLabel: '隱藏的註解內容',
            ),
          ),
        ),
      );

      expect(find.text('註解'), findsOneWidget);
      expect(find.bySemanticsLabel('隱藏的註解內容'), findsOneWidget);
    },
  );

  testWidgets('math host resolves editor style and centers display content', (
    tester,
  ) async {
    TextStyle? resolvedStyle;
    await tester.pumpWidget(
      KlpApp(
        showWindowHeader: false,
        home: KlpPanelFrame(
          padding: EdgeInsets.zero,
          content: NotistNoteMathHost(
            builder: (_, style) {
              resolvedStyle = style;
              return Text('x²', style: style);
            },
          ),
        ),
      ),
    );

    final context = tester.element(find.text('x²'));
    final type = context.klp.type;
    final expected = KlpTextStyles.definitionOf(
      KlpTextRole.editor,
      type,
    ).toTextStyle(type);
    expect(resolvedStyle?.fontFamily, expected.fontFamily);
    expect(resolvedStyle?.fontSize, expected.fontSize);
    expect(find.byType(Align), findsOneWidget);
  });

  testWidgets('inline math host does not introduce display alignment', (
    tester,
  ) async {
    await tester.pumpWidget(
      KlpApp(
        showWindowHeader: false,
        home: KlpPanelFrame(
          padding: EdgeInsets.zero,
          content: NotistNoteMathHost(
            display: false,
            builder: (_, style) => Text('α', style: style),
          ),
        ),
      ),
    );

    expect(find.text('α'), findsOneWidget);
    expect(find.byType(Align), findsNothing);
  });
}
