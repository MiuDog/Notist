import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/src/stage/notist_canva_page.dart';
import 'package:notist/src/stage/notist_sheet_page.dart';

void main() {
  Future<void> pumpPrototype(WidgetTester tester, Widget prototype) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      KlpApp(showWindowHeader: false, home: KlpAppScreen(child: prototype)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('matches the Canva page visual', (tester) async {
    await pumpPrototype(
      tester,
      const NotistCanvaPage(noteTitle: 'Books to look for'),
    );

    await expectLater(
      find.byKey(const ValueKey('notist-canva-page')),
      matchesGoldenFile('goldens/notist_canva_page.png'),
    );
  });

  testWidgets('matches the Sheet page visual', (tester) async {
    await pumpPrototype(tester, const NotistSheetPage(noteTitle: 'Groceries'));

    await expectLater(
      find.byKey(const ValueKey('notist-sheet-page')),
      matchesGoldenFile('goldens/notist_sheet_page.png'),
    );
  });
}
