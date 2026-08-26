import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/src/krepis/krepis_editor_controller.dart';
import 'package:notist/src/krepis/notist_block_command_registry.dart';
import 'package:notist/src/krepis/notist_flow_editor.dart';
import 'package:notist/src/stage/notist_flow_page.dart';

import 'support/keyboard_krepis_authority.dart';

void main() {
  const documentPath = r'C:\Notist dogfood\空白 文件.krdf';

  void setClipboardText(String text) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.getData') return {'text': text};
          return null;
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });
  }

  Future<void> pumpEditor(
    WidgetTester tester, {
    required KrepisEditorOpener opener,
  }) async {
    await tester.pumpWidget(
      KlpApp(
        showWindowHeader: false,
        home: KlpAppScreen(
          child: NotistFlowEditor(filePath: documentPath, opener: opener),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('requests the explicit path with blank initial text', (
    tester,
  ) async {
    KrepisEditorOpenRequest? capturedRequest;

    await pumpEditor(
      tester,
      opener: (request) {
        capturedRequest = request;
        return Future<KrepisEditorAuthority>.error(
          StateError('expected RED boundary'),
        );
      },
    );

    expect(capturedRequest?.filePath, documentPath);
    expect(capturedRequest?.initialText, isEmpty);
  });

  testWidgets('shows loading while the native opener is pending', (
    tester,
  ) async {
    final pending = Completer<KrepisEditorAuthority>();

    await pumpEditor(tester, opener: (request) => pending.future);

    expect(find.byType(KlpLoadingState), findsOneWidget);
    expect(find.text('正在開啟本機測試文件'), findsOneWidget);
    expect(find.byType(KlpErrorState), findsNothing);
    expect(find.byType(NotistFlowPage), findsNothing);
    expect(find.text('Keep the note close to the thought.'), findsNothing);
    expect(find.text('A short list'), findsNothing);
  });

  testWidgets('shows an honest load failure and retries the same request', (
    tester,
  ) async {
    final requests = <KrepisEditorOpenRequest>[];
    final retryPending = Completer<KrepisEditorAuthority>();

    await pumpEditor(
      tester,
      opener: (request) {
        requests.add(request);
        if (requests.length == 1) {
          return Future<KrepisEditorAuthority>.error(
            StateError('native load failed'),
          );
        }
        return retryPending.future;
      },
    );
    await tester.pump();

    expect(find.byType(KlpErrorState), findsOneWidget);
    expect(find.text('無法開啟本機測試文件'), findsOneWidget);
    expect(find.text('重試'), findsOneWidget);
    expect(find.byType(NotistFlowPage), findsNothing);

    await tester.tap(find.text('重試'));
    await tester.pump();

    expect(requests, hasLength(2));
    expect(requests[1].filePath, requests[0].filePath);
    expect(requests[1].initialText, requests[0].initialText);
    expect(find.byType(KlpLoadingState), findsOneWidget);
    expect(find.byType(KlpErrorState), findsNothing);
  });

  testWidgets('Backspace and key repeat always reach the Krepis authority', (
    tester,
  ) async {
    final authority = KeyboardKrepisAuthority();
    await pumpEditor(tester, opener: (request) async => authority);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('notist-krepis-flow-editor')));

    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.sendKeyRepeatEvent(LogicalKeyboardKey.backspace);

    expect(authority.backspaceCount, 2);
  });

  testWidgets('Control Y invokes redo', (tester) async {
    final authority = KeyboardKrepisAuthority();
    await pumpEditor(tester, opener: (request) async => authority);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('notist-krepis-flow-editor')));

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyY);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);

    expect(authority.redoCount, 1);
  });

  testWidgets('Control V imports clipboard Markdown through Krepis', (
    tester,
  ) async {
    final authority = KeyboardKrepisAuthority();
    await pumpEditor(tester, opener: (request) async => authority);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('notist-krepis-flow-editor')));
    setClipboardText('# 標題\n\n- 項目');

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();

    expect(authority.markdownPasteCount, 1);
    expect(authority.lastMarkdown, '# 標題\n\n- 項目');
  });

  testWidgets('Control Shift V keeps clipboard text unformatted', (
    tester,
  ) async {
    final authority = KeyboardKrepisAuthority();
    await pumpEditor(tester, opener: (request) async => authority);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('notist-krepis-flow-editor')));
    setClipboardText('# 純文字');

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();

    expect(authority.markdownPasteCount, 0);
    expect(authority.plainTextPasteCount, 1);
  });

  testWidgets('選取框只畫到視覺高度，chrome 仍佔滿版面高度', (tester) async {
    final authority = KeyboardKrepisAuthority();
    await pumpEditor(tester, opener: (request) async => authority);
    await tester.pump();

    final chrome = find.byKey(
      const ValueKey('notist-flow-block-00000000000000000000000000000002'),
    );
    final outline = find.byKey(const ValueKey('nts-block-selection-outline'));
    expect(chrome, findsOneWidget);
    expect(outline, findsOneWidget);

    // 假 authority：版面高 32，視覺高 24（差一個 8 的區塊間距）。
    final chromeHeight = tester.getSize(chrome).height;
    final outlineHeight = tester.getSize(outline).height;

    expect(chromeHeight, 32, reason: 'chrome 佔版面高度，相鄰 Block 的點擊區才會連續無縫');
    expect(
      outlineHeight,
      24,
      reason:
          '選取框只到視覺高度——畫滿版面高度會讓框比文字高一個間距，'
          '看起來像文字上浮、每個區塊佔兩行',
    );
    expect(
      outlineHeight < chromeHeight,
      isTrue,
      reason: '兩者必須不同；相同就代表視覺與命中矩形又被混為一談',
    );
  });

  testWidgets('Block handle duplicates through the Krepis authority', (
    tester,
  ) async {
    final authority = KeyboardKrepisAuthority();
    await pumpEditor(tester, opener: (request) async => authority);
    await tester.pump();

    expect(
      find.byKey(const ValueKey('nts-block-chrome-handle')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('nts-block-selection-outline')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('nts-block-chrome-handle')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('建立副本'));
    await tester.pumpAndSettle();

    expect(authority.duplicateCount, 1);
  });

  testWidgets('slash insertion opens the gated shared command menu', (
    tester,
  ) async {
    final authority = KeyboardKrepisAuthority();
    await pumpEditor(tester, opener: (request) async => authority);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('notist-krepis-flow-editor')));

    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: '/abc',
        selection: TextSelection.collapsed(offset: 1),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('notist-flow-slash-menu')),
      findsOneWidget,
    );
    expect(find.text('基本區塊'), findsOneWidget);
    expect(
      find.text(NotistBlockCommandRegistry.providerUnavailable),
      findsWidgets,
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('notist-flow-slash-menu')), findsNothing);
  });
}
