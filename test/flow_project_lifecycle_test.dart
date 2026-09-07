/// Notist 專案模組。

library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/src/project/notist_flow_document.dart';
import 'package:notist/src/project/notist_project_controller.dart';
import 'package:notist/src/project/notist_project_store.dart';
import 'package:notist/src/shell/notist_workbench.dart';

void main() {
  testWidgets('Explorer and Stage switch by stable Flow root ID', (
    tester,
  ) async {
    final controller = NotistProjectController(
      store: _MemoryProjectStore(['first.krdf', 'second.krdf']),
      loader: (path, initialTitle) async => NotistFlowDocument(
        rootId: 'root-$path',
        title: path == 'first.krdf' ? '第一份' : '第二份',
        filePath: path,
      ),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      KlpApp(
        showWindowHeader: false,
        home: KlpPanelFrame(
          content: KlpAppScreen(
            child: NotistWorkbench(
              projectController: controller,
              flowEditorBuilder: (context, filePath) =>
                  SizedBox(key: ValueKey('editor-$filePath')),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('第一份'), findsNWidgets(2));
    expect(find.text('第二份'), findsOneWidget);
    expect(find.byKey(const ValueKey('editor-first.krdf')), findsOneWidget);

    await tester.tap(find.text('第二份'));
    await tester.pump();

    expect(controller.selectedRootId, 'root-second.krdf');
    expect(find.byKey(const ValueKey('editor-second.krdf')), findsOneWidget);
    expect(find.text('第二份'), findsNWidgets(2));

    await tester.tap(find.bySemanticsLabel('頁面選單'));
    await tester.pumpAndSettle();

    expect(find.byType(KlpMenu), findsOneWidget);
    expect(find.text('匯入 Markdown'), findsOneWidget);
  });

  testWidgets(
    'empty project creates and opens a Flow from the visible action',
    (tester) async {
      final controller = NotistProjectController(
        store: _MemoryProjectStore([]),
        loader: (path, initialTitle) async => NotistFlowDocument(
          rootId: 'root-new',
          title: initialTitle,
          filePath: path,
        ),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        KlpApp(
          showWindowHeader: false,
          home: KlpPanelFrame(
            content: KlpAppScreen(
              child: NotistWorkbench(
                projectController: controller,
                flowEditorBuilder: (context, filePath) =>
                    SizedBox(key: ValueKey('editor-$filePath')),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('尚無 Flow'), findsNWidgets(2));
      expect(find.text('本機測試暫存尚未保存'), findsNothing);
      await tester.tap(find.text('新增 Flow').first);
      await tester.pumpAndSettle();

      expect(controller.documents.single.title, isEmpty);
      expect(find.byKey(const ValueKey('editor-new.krdf')), findsOneWidget);
      expect(find.byType(KlpFileExplorer), findsOneWidget);
    },
  );

  testWidgets('create failure stays visible without replacing Explorer', (
    tester,
  ) async {
    final controller = NotistProjectController(
      store: _MemoryProjectStore(['first.krdf']),
      loader: (path, initialTitle) async {
        if (path == 'new.krdf') throw StateError('disk unavailable');
        return NotistFlowDocument(
          rootId: 'root-first',
          title: '第一份',
          filePath: path,
        );
      },
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      KlpApp(
        showWindowHeader: false,
        home: KlpPanelFrame(
          content: KlpAppScreen(
            child: NotistWorkbench(
              projectController: controller,
              flowEditorBuilder: (context, filePath) =>
                  SizedBox(key: ValueKey('editor-$filePath')),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 直接觸發 controller，而不是點某顆按鈕。
    //
    // 本測試驗的是「建立失敗時錯誤訊息可見且不取代 Explorer」，
    // 與哪個 UI 元件觸發無關。先前綁在「筆記」區段的 trailing 按鈕上，
    // 但那顆按鈕的圖示是 folderPlus（新增資料夾）、行為卻是 createFlow，
    // 兩者不一致且從未被指定，已移除。把測試綁在特定按鈕上，
    // 會讓 UI 調整連帶弄壞與 UI 無關的行為驗證。
    await controller.createFlow();
    await tester.pumpAndSettle();

    expect(find.byType(KlpFileExplorer), findsOneWidget);
    expect(find.text('建立 Flow 失敗'), findsOneWidget);
    expect(find.textContaining('disk unavailable'), findsOneWidget);
    expect(find.byKey(const ValueKey('editor-first.krdf')), findsOneWidget);
  });

  testWidgets('Explorer paste creates a Flow in the selected folder', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.getData') return {'text': '# 新筆記'};
          return null;
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });
    final store = _MemoryProjectStore([], folders: ['研究']);
    final controller = NotistProjectController(
      store: store,
      loader: (path, initialTitle) => throw UnimplementedError(),
      markdownImporter: (path, markdown, initialTitle) async =>
          NotistFlowDocument(
            rootId: 'root-imported',
            title: '新筆記',
            filePath: path,
            folderPath: '研究',
          ),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      KlpApp(
        showWindowHeader: false,
        home: KlpPanelFrame(
          content: KlpAppScreen(
            child: NotistWorkbench(
              projectController: controller,
              flowEditorBuilder: (context, filePath) =>
                  SizedBox(key: ValueKey('editor-$filePath')),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('研究'));
    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();

    expect(store.lastAllocatedFolderPath, '研究');
    expect(controller.documents.single.title, '新筆記');
    expect(find.byKey(const ValueKey('editor-研究/new.krdf')), findsOneWidget);
  });
}

final class _MemoryProjectStore implements NotistProjectStore {
  @override
  final String directoryPath = '';

  _MemoryProjectStore(this.paths, {this.folders = const []});

  final List<String> paths;
  final List<String> folders;
  String? lastAllocatedFolderPath;

  @override
  Future<String> allocateFlowPath({String? folderPath}) async {
    lastAllocatedFolderPath = folderPath;
    return folderPath == null ? 'new.krdf' : '$folderPath/new.krdf';
  }

  @override
  Future<List<String>> listFolderPaths() async => List.of(folders);

  @override
  Future<List<NotistStoredFlow>> listFlows() async => [
    for (final path in paths) NotistStoredFlow(filePath: path, folderPath: ''),
  ];
}
