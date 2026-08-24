import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/src/shell/notist_workbench.dart';
import 'package:notist/src/sidebar/notist_sidebar.dart';
import 'package:notist/src/stage/notist_canva_page.dart';
import 'package:notist/src/stage/notist_flow_page.dart';
import 'package:notist/src/stage/notist_sheet_page.dart';

void main() {
  const documentPath = r'C:\Notist dogfood\空白文件.krdf';

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
        home: KlpAppScreen(
          child: NotistWorkbench(
            flowFilePath: documentPath,
            flowEditorBuilder: flowEditorBuilder,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Finder destination(String label) {
    return find.descendant(
      of: find.byType(NotistSidebar),
      matching: find.bySemanticsLabel(label),
    );
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
    expect(find.byType(NotistFlowPage), findsNothing);
    expect(find.byType(NotistCanvaPage), findsNothing);
    expect(find.byType(NotistSheetPage), findsNothing);

    final shell = tester.widget<KlpWorkbenchShell>(
      find.byType(KlpWorkbenchShell),
    );
    expect(shell.secondaryVisible, isFalse);
    expect(find.byType(KlpTabs), findsNothing);
    expect(find.byType(KlpSplitLayout), findsNothing);
  });

  // 版面稿的規則是 nav 與文件互斥，因此切到入口畫面時編輯器**會**被換掉。
  // 原本這裡的 'sidebar destinations preserve the mounted paragraph editor'
  // 編碼的是舊設計（導覽只是裝飾），與版面稿相反。
  //
  // 真正要保住的是「切回文件時編輯器還在」——那才是使用者會察覺的事。
  testWidgets('切到入口再切回文件，編輯器仍然掛著', (tester) async {
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

    await tester.tap(destination('Journals'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('injected-paragraph-editor')),
      findsNothing,
      reason: '入口畫面應該換掉文件，而不是疊在上面',
    );

    await tester.tap(destination('Journals'));
    await tester.pumpAndSettle();
  });
}
