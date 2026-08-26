import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notist/main.dart';
import 'package:notist/src/sidebar/notist_sidebar.dart';
import 'package:notist/src/stage/notist_canva_page.dart';
import 'package:notist/src/stage/notist_flow_page.dart';
import 'package:notist/src/stage/notist_sheet_page.dart';

void main() {
  Future<void> pumpWorkbench(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const NotistApp());
    await tester.pumpAndSettle();
  }

  testWidgets('workspace destinations never mount catalog page prototypes', (
    tester,
  ) async {
    await pumpWorkbench(tester);

    expect(find.byType(NotistFlowPage), findsNothing, reason: '專案');
    expect(find.byType(NotistCanvaPage), findsNothing, reason: '專案');
    expect(find.byType(NotistSheetPage), findsNothing, reason: '專案');

    for (final label in const ['Journals', 'Notist AI', '資產庫']) {
      await tester.tap(
        find.descendant(
          of: find.byType(NotistSidebar),
          matching: find.bySemanticsLabel(label),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NotistFlowPage), findsNothing, reason: label);
      expect(find.byType(NotistCanvaPage), findsNothing, reason: label);
      expect(find.byType(NotistSheetPage), findsNothing, reason: label);
    }
  });
}
