/// Notist 專案模組。

library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/src/shell/notist_workbench.dart';

void main() {
  const documentPath = r'C:\Notist dogfood\空白文件.krdf';

  Finder railItem(String label) {
    return find.descendant(
      of: find.byType(KlpNavigationRail),
      matching: find.bySemanticsLabel(label),
    );
  }

  Future<void> pumpWorkbench(
    WidgetTester tester, {
    required Widget Function(BuildContext context, String filePath)
    flowEditorBuilder,
  }) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      KlpApp(
        showWindowHeader: false,
        home: KlpPanelFrame(
          content: KlpAppScreen(
            child: NotistWorkbench(
              flowFilePath: documentPath,
              flowEditorBuilder: flowEditorBuilder,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('project destination mounts the paragraph editor in one stage', (
    tester,
  ) async {
    String? capturedPath;

    await pumpWorkbench(
      tester,
      flowEditorBuilder: (context, filePath) {
        capturedPath = filePath;
        return const SizedBox.expand(
          key: ValueKey('injected-paragraph-editor'),
        );
      },
    );

    expect(capturedPath, documentPath);
    expect(
      find.byKey(const ValueKey('injected-paragraph-editor')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('workspace-project-page')),
      findsOneWidget,
    );
    expect(find.text('尚未建立專案文件'), findsNothing);
    final dock = tester.widget<KlpDockLayout>(find.byType(KlpDockLayout));
    expect(dock.layout.right.groups, isEmpty);
    expect(dock.layout.bottom.groups, isEmpty);
    expect(find.byType(KlpTabs), findsNothing);
    expect(find.byType(KlpSplitLayout), findsNothing);
  });

  // Notes 與 Notist AI 都是 sidebar 內容，切換時不可卸載中央編輯器。
  testWidgets('切換 sidebar 時編輯器保持掛載', (tester) async {
    await pumpWorkbench(
      tester,
      flowEditorBuilder: (context, filePath) {
        return const SizedBox.expand(
          key: ValueKey('injected-paragraph-editor'),
        );
      },
    );

    expect(
      find.byKey(const ValueKey('injected-paragraph-editor')),
      findsOneWidget,
    );

    await tester.tap(railItem('Notist AI'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('injected-paragraph-editor')),
      findsOneWidget,
      reason: 'AI 對話只應替換 sidebar，不可卸載中央文件',
    );

    await tester.tap(railItem('Notes'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('injected-paragraph-editor')),
      findsOneWidget,
    );
  });
}
