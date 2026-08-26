import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/main.dart';
import 'package:notist/src/sidebar/notist_sidebar.dart';
import 'package:notist/src/stage/notist_stage.dart';

void main() {
  testWidgets('uses Kallopis default spacing around the shell and panes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const NotistApp());
    await tester.pumpAndSettle();

    final shellFinder = find.byType(KlpWorkbenchShell);
    final shell = tester.widget<KlpWorkbenchShell>(shellFinder);
    final compact = tester.element(shellFinder).klp.space.compact;
    expect(shell.padding, isNull);
    expect(shell.paneGap, isNull);
    expect(
      tester
          .widget<KlpPanelFrame>(
            find.descendant(
              of: find.byType(NotistSidebar),
              matching: find.byType(KlpPanelFrame),
            ),
          )
          .padding,
      isNull,
    );
    expect(
      tester
          .widget<KlpStageFrame>(
            find.descendant(
              of: find.byType(NotistStage),
              matching: find.byType(KlpStageFrame),
            ),
          )
          .padding,
      isNull,
    );

    final shellRect = tester.getRect(shellFinder);
    final sidebarRect = tester.getRect(find.byType(NotistSidebar));
    final stageRect = tester.getRect(find.byType(NotistStage));
    expect(sidebarRect.left - shellRect.left, compact);
    expect(stageRect.left - sidebarRect.right, compact);
    expect(shellRect.right - stageRect.right, compact);
    expect(shellRect.bottom - stageRect.bottom, compact);
    expect(sidebarRect.top, shellRect.top);
    expect(stageRect.top, shellRect.top);
  });
}
