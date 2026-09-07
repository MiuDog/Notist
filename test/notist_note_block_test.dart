import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/src/components/note/note_components.dart';

void main() {
  testWidgets('note block separates content and handle actions', (
    tester,
  ) async {
    var selected = 0;
    var contentPressed = 0;
    Offset? anchor;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildKlpTheme(Brightness.light),
        home: Scaffold(
          body: NotistNoteBlock(
            handleLabel: 'Open actions',
            onHandlePressed: (value) => anchor = value,
            onSelected: () => selected += 1,
            onContentPressed: () => contentPressed += 1,
            child: const KlpText('Note content'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Note content'));
    await tester.pump();
    expect(contentPressed, 1);
    expect(selected, 0);

    await tester.tap(find.byKey(const ValueKey('notist-note-block-handle')));
    await tester.pump();
    expect(selected, 1);
    expect(anchor, isNotNull);
  });

  testWidgets('selected chrome uses authority-provided geometry', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildKlpTheme(Brightness.light),
        home: Scaffold(
          body: SizedBox(
            height: 80,
            child: NotistNoteBlockChrome(
              contentLeft: 40,
              contentWidth: 240,
              visualHeight: 32,
              handleLabel: 'Open actions',
              onHandlePressed: (_) {},
              onSelected: () {},
              selected: true,
            ),
          ),
        ),
      ),
    );

    final surface = find.byKey(
      const ValueKey('notist-note-block-selection-surface'),
    );
    expect(surface, findsOneWidget);
    expect(tester.getSize(surface), const Size(240, 32));
  });
}
