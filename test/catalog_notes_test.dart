import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/catalog/specimens/flow_demo.dart';
import 'package:notist/notist.dart';

void main() {
  testWidgets('Flow demo 的所有區塊可選取且六點操作鈕會開啟選單', (tester) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildKlpTheme(Brightness.light),
        home: const Scaffold(
          body: SingleChildScrollView(child: NtsFlowCatalogDemo()),
        ),
      ),
    );

    for (final label in [
      '一般段落',
      'H1 標題',
      'H4 標題',
      '項目列表',
      '編號列表',
      '待辦列表',
      '摺疊列表',
      '註解標題',
      '多欄',
      '表格',
      '圖片',
      'PLACEHOLDER',
      '分隔線',
      '資料庫',
    ]) {
      expect(find.text(label), findsWidgets, reason: '缺少 $label 區塊展示');
    }

    final blocks = tester.widgetList<NtsBlock>(find.byType(NtsBlock));
    expect(blocks, isNotEmpty);
    expect(blocks.every((block) => block.onContentPressed != null), isTrue);
    expect(blocks.every((block) => block.onHandleDragUpdate == null), isTrue);
    expect(
      find.byKey(const ValueKey('nts-block-handle')),
      findsNWidgets(blocks.length),
    );
    expect(find.byType(KlpAccordion), findsOneWidget);
    expect(find.text('引用'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('flow-block-paragraph')));
    await tester.pump();
    final contentPressed = tester.widget<NtsBlock>(
      find.descendant(
        of: find.byKey(const ValueKey('flow-block-paragraph')),
        matching: find.byType(NtsBlock),
      ),
    );
    expect(contentPressed.selected, isFalse);

    final handle = find.descendant(
      of: find.byKey(const ValueKey('flow-block-paragraph')),
      matching: find.byKey(const ValueKey('nts-block-handle')),
    );
    await tester.tap(handle);
    await tester.pump();

    final selected = tester.widget<NtsBlock>(
      find.descendant(
        of: find.byKey(const ValueKey('flow-block-paragraph')),
        matching: find.byType(NtsBlock),
      ),
    );
    expect(selected.selected, isTrue);
    expect(find.byType(KlpMenu), findsOneWidget);
  });

  testWidgets('多欄分隔把手可調整相鄰欄寬', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildKlpTheme(Brightness.light),
        home: const Scaffold(
          body: SingleChildScrollView(child: NtsFlowCatalogDemo()),
        ),
      ),
    );

    final resizeHandle = find.byKey(const ValueKey('flow-column-resize-0'));
    await tester.ensureVisible(resizeHandle);
    await tester.pump();

    final firstColumn = find.byKey(const ValueKey('flow-column-0'));
    final initialWidth = tester.getSize(firstColumn).width;

    await tester.drag(resizeHandle, const Offset(48, 0));
    await tester.pump();

    expect(tester.getSize(firstColumn).width, greaterThan(initialWidth));
  });

  testWidgets('表格與資料庫採參考圖的空白格線及工具列結構', (tester) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildKlpTheme(Brightness.light),
        home: const Scaffold(
          body: SingleChildScrollView(child: NtsFlowCatalogDemo()),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('flow-empty-table-grid')), findsOneWidget);
    expect(find.text('New database'), findsOneWidget);
    expect(find.text('Add property'), findsOneWidget);
    expect(find.text('New page'), findsOneWidget);
  });
}
