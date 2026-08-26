import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/main.dart';
import 'package:notist/src/sidebar/notist_sidebar.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const NotistApp());
    await tester.pumpAndSettle();
  }

  testWidgets('uses one Klp workbench window header', (tester) async {
    await pumpApp(tester);

    expect(find.byType(KlpWorkbenchWindowHeader), findsOneWidget);
    expect(find.byType(KlpWindowHeader), findsOneWidget);
    final headerFinder = find.byType(KlpWorkbenchWindowHeader);
    final layout = tester.element(headerFinder).klp.geometry.layout;
    expect(tester.getSize(headerFinder).height, layout.windowToolbarHeight);
    expect(find.text('⌘K'), findsOneWidget);
  });

  testWidgets('matches the absolute sidebar composition', (tester) async {
    await pumpApp(tester);

    final sidebar = find.byType(NotistSidebar);
    expect(tester.getSize(sidebar).width, 268);
    expect(
      find.descendant(
        of: sidebar,
        matching: find.byType(KlpSidebarIdentityHeader),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: sidebar, matching: find.byType(KlpFileExplorer)),
      findsOneWidget,
    );
    expect(find.byType(KlpSegmentedControl), findsNothing);
    expect(find.text('Flows'), findsWidgets);
    expect(find.bySemanticsLabel('Journals'), findsOneWidget);
    expect(find.bySemanticsLabel('Notist AI'), findsOneWidget);
    expect(find.bySemanticsLabel('資產庫'), findsOneWidget);
    expect(find.bySemanticsLabel('快速搜尋'), findsOneWidget);
  });

  testWidgets('keeps the Flow stage chrome from the golden layout', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.byType(KlpStageHeader), findsOneWidget);
    expect(
      find.byWidgetPredicate((widget) => widget is KlpPhaseToggle),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('編輯模式'), findsOneWidget);
    expect(find.bySemanticsLabel('頁面選單'), findsOneWidget);
    expect(find.text('Flows'), findsWidgets);
    expect(find.text('Flow'), findsWidgets);
    expect(find.text('FLOW'), findsOneWidget);
    expect(find.text('本機'), findsWidgets);
  });

  testWidgets('collapses and restores the primary sidebar from the header', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.bySemanticsLabel('收合側邊面板'));
    await tester.pumpAndSettle();
    expect(find.byType(NotistSidebar), findsNothing);
    expect(find.byType(KlpStageFrame), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('展開側邊面板'));
    await tester.pumpAndSettle();
    expect(find.byType(NotistSidebar), findsOneWidget);
  });
}
