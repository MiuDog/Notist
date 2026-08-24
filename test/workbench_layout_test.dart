import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/main.dart';
import 'package:notist/src/shell/notist_workbench.dart';
import 'package:notist/src/sidebar/notist_sidebar.dart';
import 'package:notist/src/sidebar/notist_sidebar_explorer.dart';
import 'package:notist/src/stage/notist_stage.dart';

void main() {
  const destinations = ['Journals', 'Notist AI', '資產庫'];

  Future<void> pumpWorkbench(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const NotistApp());
    await tester.pumpAndSettle();
  }

  Finder destinationFinder(String label) {
    return find.descendant(
      of: find.byType(NotistSidebar),
      matching: find.bySemanticsLabel(label),
    );
  }

  List<Semantics> selectedDestinations(WidgetTester tester) {
    return tester
        .widgetList<Semantics>(
          find.descendant(
            of: find.byType(NotistSidebar),
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

  testWidgets('renders three full-width sidebar destinations', (tester) async {
    await pumpWorkbench(tester);

    expect(find.byType(NotistWorkbench), findsOneWidget);
    expect(find.byType(NotistSidebar), findsOneWidget);
    expect(find.byType(NotistStage), findsOneWidget);
    expect(find.byType(KlpFileExplorer), findsOneWidget);

    final buttonRects = [
      for (final destination in destinations)
        tester.getRect(destinationFinder(destination)),
    ];
    final firstRect = buttonRects.first;
    for (final rect in buttonRects.skip(1)) {
      expect(rect.left, firstRect.left);
      expect(rect.right, firstRect.right);
      expect(rect.height, firstRect.height);
    }

    // 版面稿：導覽與文件互斥，起始顯示的是 Flow 文件，因此此時導覽一個都不亮。
    // 這裡原本斷言「必有一個亮著且是 Journals」，那是導覽還只是裝飾時的行為。
    expect(selectedDestinations(tester), isEmpty);
  });

  testWidgets('shows an empty explorer without hard-coded note truth', (
    tester,
  ) async {
    await pumpWorkbench(tester);

    final explorer = tester.widget<KlpFileExplorer>(
      find.byType(KlpFileExplorer),
    );
    expect(find.byType(NotistSidebarExplorer), findsOneWidget);
    expect(explorer.sections, isEmpty);
    expect(find.text('尚無 Flow'), findsWidgets);
  });

  // 版面稿（Notist.dc.html）的規則是 nav 與文件**互斥**：
  //   isDoc:zone==="doc"，isJournals:zone==="nav"&&section==="journals" …
  //   selectFlow:(id)=>setState({selectedFlowId:id, zone:"doc"})
  //
  // 這取代了先前「導覽只是裝飾、stage 永遠顯示 Flow」的設計。原本這裡有一個
  // 'sidebar selection never replaces the single Flow stage'，它編碼的是舊行為。
  testWidgets('選擇導覽入口會換掉 stage 的內容', (tester) async {
    await pumpWorkbench(tester);

    // 起始在文件區。
    expect(
      find.byKey(const ValueKey('workspace-project-page')),
      findsOneWidget,
    );

    for (final destination in destinations) {
      await tester.tap(destinationFinder(destination));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('workspace-project-page')),
        findsNothing,
        reason: '$destination 應該換掉文件畫面，而不是疊在它上面',
      );

      final selected = selectedDestinations(tester);
      expect(selected, hasLength(1));
      expect(selected.single.properties.label, destination);
    }

    final shell = tester.widget<KlpWorkbenchShell>(
      find.byType(KlpWorkbenchShell),
    );
    expect(shell.secondaryVisible, isFalse);
  });
}
