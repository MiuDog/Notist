import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/src/krepis/notist_flow_editor.dart';

import 'support/keyboard_krepis_authority.dart';

void main() {
  testWidgets('Ink mode previews through Krepis and commits on pointer up', (
    tester,
  ) async {
    final authority = KeyboardKrepisAuthority();
    await tester.pumpWidget(
      KlpApp(
        showWindowHeader: false,
        home: KlpAppScreen(
          child: NotistFlowEditor(
            filePath: r'C:\Notist dogfood\ink.krdf',
            opener: (request) async => authority,
            inkEnabled: true,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    final editor = find.byKey(const ValueKey('notist-krepis-flow-editor'));
    final origin = tester.getTopLeft(editor);
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(gesture.removePointer);
    await gesture.down(origin + const Offset(80, 28));
    await gesture.moveTo(origin + const Offset(120, 36));

    await tester.pump();

    expect(authority.inkBeginCount, 1);
    expect(find.byKey(const ValueKey('notist-ink-preview')), findsOneWidget);

    await gesture.up();
    await tester.pump();

    expect(authority.inkCommitCount, 1);
    expect(find.byKey(const ValueKey('notist-ink-preview')), findsNothing);
  });
}
