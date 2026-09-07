/// Notist 專案模組。

library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/main.dart';
import 'package:notist/src/assistant/notist_assistant_page.dart';
import 'package:notist/src/settings/notist_settings_dialog.dart';
import 'package:notist/src/shell/notist_workbench.dart';
import 'package:notist/src/shell/notist_workbench_controller.dart';
import 'package:notist/src/shell/notist_workbench_surface.dart';
import 'package:notist/src/sidebar/notist_sidebar.dart';
import 'package:notist/src/sidebar/notist_sidebar_explorer.dart';
import 'package:notist/src/stage/notist_stage.dart';

void main() {
  Future<void> pumpWorkbench(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const NotistApp());
    await tester.pumpAndSettle();
  }

  List<Semantics> selectedRailItems(WidgetTester tester) {
    return tester
        .widgetList<Semantics>(
          find.descendant(
            of: find.byType(KlpNavigationRail),
            matching: find.byType(Semantics),
          ),
        )
        .where(
          (semantics) =>
              semantics.properties.button == true &&
              semantics.properties.selected == true,
        )
        .toList();
  }

  Finder railItem(Pattern label) {
    return find.descendant(
      of: find.byType(KlpNavigationRail),
      matching: find.bySemanticsLabel(label),
    );
  }

  testWidgets('renders the requested grouped workbench rail', (
    WidgetTester tester,
  ) async {
    await pumpWorkbench(tester);

    expect(find.byType(NotistWorkbench), findsOneWidget);
    expect(find.byType(NotistWorkbenchScreen), findsOneWidget);
    expect(find.byType(NotistWorkbenchSurface), findsOneWidget);
    expect(find.byType(KlpNavigationRail), findsOneWidget);
    expect(find.byType(KlpRailItem), findsNWidgets(5));
    expect(railItem(RegExp(r'^Project · ')), findsOneWidget);
    expect(railItem('Notes'), findsOneWidget);
    expect(railItem('Notist AI'), findsOneWidget);
    expect(railItem('Account'), findsOneWidget);
    expect(railItem('設定'), findsOneWidget);
    expect(find.byType(NotistSidebar), findsOneWidget);
    expect(find.byType(NotistStage), findsOneWidget);
    expect(find.byType(KlpFileExplorer), findsOneWidget);

    final dock = tester.widget<KlpDockLayout>(find.byType(KlpDockLayout));
    final explorer = tester.widget<KlpFileExplorer>(
      find.byType(KlpFileExplorer),
    );
    expect(
      explorer.scrollController,
      same(dock.panels.single.contentScrollController),
    );

    final selected = selectedRailItems(tester);
    expect(selected, hasLength(1));
    expect(selected.single.properties.label, 'Notes');
  });

  testWidgets('shows an empty explorer without hard-coded note truth', (
    WidgetTester tester,
  ) async {
    await pumpWorkbench(tester);

    final explorer = tester.widget<KlpFileExplorer>(
      find.byType(KlpFileExplorer),
    );
    expect(find.byType(NotistSidebarExplorer), findsOneWidget);
    expect(explorer.sections, isEmpty);
    expect(find.text('尚無 Flow'), findsWidgets);
  });

  testWidgets('rail switches the sidebar while preserving the Stage', (
    WidgetTester tester,
  ) async {
    await pumpWorkbench(tester);

    expect(
      find.byKey(const ValueKey('workspace-project-page')),
      findsOneWidget,
    );

    await tester.tap(railItem('Notist AI'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('workspace-project-page')),
      findsOneWidget,
    );
    expect(find.byType(NotistSidebar), findsNothing);
    expect(find.byType(NotistAssistantPage), findsOneWidget);
    expect(find.text('問一個關於這則筆記或整個專案的問題。'), findsOneWidget);
    expect(find.text('Notist AI 尚未連線'), findsOneWidget);
    expect(selectedRailItems(tester).single.properties.label, 'Notist AI');

    await tester.tap(railItem('Notes'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('workspace-project-page')),
      findsOneWidget,
    );
    expect(find.byType(NotistSidebar), findsOneWidget);
    expect(find.byType(NotistAssistantPage), findsNothing);
    expect(selectedRailItems(tester).single.properties.label, 'Notes');

    final dock = tester.widget<KlpDockLayout>(find.byType(KlpDockLayout));
    expect(dock.panels, hasLength(1));
    expect(dock.panels.single.id, NotistWorkbenchController.navigationPanelId);
    expect(dock.panels.single.allowSide, isTrue);
    expect(dock.panels.single.allowBottom, isFalse);
    expect(dock.bottomConstraints, isNull);
  });

  testWidgets('Project and Account open honest menus', (
    WidgetTester tester,
  ) async {
    await pumpWorkbench(tester);

    await tester.tap(railItem(RegExp(r'^Project · ')));
    await tester.pumpAndSettle();
    expect(find.text('新增 Flow'), findsOneWidget);
    expect(find.text('匯入 Markdown'), findsWidgets);

    await tester.tapAt(const Offset(800, 600));
    await tester.pumpAndSettle();
    await tester.tap(railItem('Account'));
    await tester.pumpAndSettle();
    expect(find.text('帳號功能尚未提供'), findsOneWidget);
  });

  testWidgets('Settings opens the full settings page', (
    WidgetTester tester,
  ) async {
    await pumpWorkbench(tester);

    await tester.tap(railItem('設定'));
    await tester.pumpAndSettle();

    expect(find.byType(KlpPopupPanel), findsOneWidget);
    expect(find.byType(NotistSettingsPanel), findsOneWidget);
    expect(
      tester.widget<KlpPopupPanel>(find.byType(KlpPopupPanel)).kind,
      KlpPopupPanelKind.large,
    );
    expect(find.byType(Dialog), findsNothing);
    expect(find.byType(KlpSettingsPage), findsOneWidget);
    expect(find.text('外觀'), findsWidgets);
    expect(find.text('顯示模式'), findsWidgets);
    expect(find.text('操作色'), findsWidgets);

    await tester.tap(find.text('啟動與工作區'));
    await tester.pumpAndSettle();
    expect(find.text('啟動行為'), findsOneWidget);
    expect(find.text('保留上次狀態'), findsOneWidget);
  });
}
