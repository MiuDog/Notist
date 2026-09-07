/// Notist 專案模組。

library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/main.dart';
import 'package:notist/src/sidebar/notist_sidebar.dart';
import 'package:notist/src/stage/notist_stage.dart';

void main() {
  testWidgets('uses semantic dock spacing around the shell and panes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const NotistApp());
    await tester.pumpAndSettle();

    final dockFinder = find.byType(KlpDockLayout);
    final klp = tester.element(dockFinder).klp;
    final panelFinder = find.ancestor(
      of: find.byType(NotistSidebar),
      matching: find.byType(KlpPanelFrame),
    );
    final dockRect = tester.getRect(dockFinder);
    final panelRect = tester.getRect(panelFinder);
    final stageRect = tester.getRect(find.byType(NotistStage));
    final panelLeftGap = panelRect.left - dockRect.left;
    expect(panelLeftGap, greaterThanOrEqualTo(0.0));
    expect(panelLeftGap, lessThanOrEqualTo(klp.space.dockMargin.toDouble()));
    final stageLeftGap = stageRect.left - panelRect.right;
    expect(stageLeftGap, greaterThanOrEqualTo(0.0));
    expect(stageLeftGap, lessThanOrEqualTo(klp.space.dockMargin * 2));
    final stageRightGap = dockRect.right - stageRect.right;
    expect(stageRightGap, greaterThanOrEqualTo(0.0));
    expect(stageRightGap, lessThanOrEqualTo(klp.space.dockMargin.toDouble()));
    final stageBottomGap = dockRect.bottom - stageRect.bottom;
    expect(stageBottomGap, greaterThanOrEqualTo(0.0));
    expect(stageBottomGap, lessThanOrEqualTo(klp.space.dockMargin.toDouble()));
    final panelTopGap = panelRect.top - dockRect.top;
    final stageTopGap = stageRect.top - dockRect.top;
    expect(panelTopGap, greaterThanOrEqualTo(0.0));
    expect(panelTopGap, lessThanOrEqualTo(klp.space.dockMargin.toDouble()));
    expect(stageTopGap, greaterThanOrEqualTo(0.0));
    expect(stageTopGap, lessThanOrEqualTo(klp.space.dockMargin.toDouble()));
  });
}
