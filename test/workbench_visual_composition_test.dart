/// Notist 專案模組。

library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/main.dart';
import 'package:notist/src/shell/notist_workbench_controller.dart';
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

  Finder railItem(Pattern label) {
    return find.descendant(
      of: find.byType(KlpNavigationRail),
      matching: find.bySemanticsLabel(label),
    );
  }

  testWidgets('uses the Klp app window header', (tester) async {
    await pumpApp(tester);

    expect(find.byType(KlpWorkbenchWindowHeader), findsNothing);
    expect(find.byType(KlpWindowHeader), findsOneWidget);
    final headerFinder = find.byType(KlpWindowHeader);
    final klp = tester.element(headerFinder).klp;
    expect(
      tester.getSize(headerFinder).height,
      klpWindowHeaderHeight(klp.geometry),
    );
    expect(find.text('⌘K'), findsOneWidget);
  });

  testWidgets('matches the absolute sidebar composition', (tester) async {
    await pumpApp(tester);

    final sidebar = find.byType(NotistSidebar);
    final panel = find.ancestor(
      of: sidebar,
      matching: find.byType(KlpPanelFrame),
    );
    expect(
      tester.getSize(panel).width,
      NotistWorkbenchController.initialPrimaryWidth,
    );
    expect(
      find.descendant(
        of: sidebar,
        matching: find.byType(KlpSidebarIdentityHeader),
      ),
      findsNothing,
    );
    expect(
      find.descendant(of: sidebar, matching: find.byType(KlpFileExplorer)),
      findsOneWidget,
    );
    expect(find.byType(KlpSegmentedControl), findsNothing);
    expect(railItem(RegExp(r'^Project · ')), findsOneWidget);
    expect(railItem('Notes'), findsOneWidget);
    expect(railItem('Notist AI'), findsOneWidget);
    expect(railItem('Account'), findsOneWidget);
    expect(railItem('設定'), findsOneWidget);
    expect(find.byType(KlpRailItem), findsNWidgets(5));
  });

  testWidgets('keeps 8px rail edges around a square rail item', (tester) async {
    await pumpApp(tester);

    final rail = find.byType(KlpNavigationRailFrame);
    final item = find.byType(KlpRailItem).first;
    final spacing = tester.element(rail).klp.space;

    expect(tester.getSize(item).width, tester.getSize(item).height);
    expect(
      tester.getSize(rail).width,
      spacing.chromeRail + (spacing.dockMargin * 2),
    );
  });

  testWidgets('keeps the Flow stage chrome from the golden layout', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(
      find.ancestor(
        of: find.text('尚未選取專案'),
        matching: find.byType(KlpPanelHeader),
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate((widget) => widget is KlpPhaseToggle),
      findsNothing,
    );
    expect(find.bySemanticsLabel('唯讀'), findsOneWidget);
    expect(find.bySemanticsLabel('編輯'), findsOneWidget);
    expect(find.bySemanticsLabel('手寫（尚未提供）'), findsOneWidget);
    expect(find.bySemanticsLabel('頁面選單'), findsOneWidget);
    expect(find.text('本機'), findsWidgets);

    final stageHeader = find.byKey(const ValueKey('stage-panel-header-slot'));
    final stagePanelHeader = find.descendant(
      of: stageHeader,
      matching: find.byType(KlpPanelHeader),
    );
    final sidebarHeader = find.ancestor(
      of: find.text('Notes'),
      matching: find.byType(KlpPanelHeader),
    );
    expect(
      tester.getSize(stageHeader).height,
      tester.getSize(sidebarHeader).height,
    );
    expect(
      tester.widget<KlpPanelHeader>(stagePanelHeader).titleRole,
      KlpTextRole.appTitle,
    );
    expect(
      tester.widget<KlpText>(find.widgetWithText(KlpText, 'Notes')).role,
      KlpTextRole.appTitle,
    );

    final actionButtons = <String>['唯讀', '編輯', '手寫（尚未提供）', '頁面選單'].map(
      (label) => find.byWidgetPredicate(
        (widget) => widget is KlpIconButton && widget.label == label,
      ),
    );
    final actionButtonSizes = actionButtons.map(tester.getSize).toSet();
    expect(actionButtonSizes, hasLength(1));
    expect(
      actionButtonSizes.single,
      Size.square(tester.element(stageHeader).klp.space.iconButton),
    );
    final stageHeaderRect = tester.getRect(stageHeader);
    for (final actionButton in actionButtons) {
      expect(
        stageHeaderRect.contains(tester.getRect(actionButton).center),
        isTrue,
      );
    }
  });
}
