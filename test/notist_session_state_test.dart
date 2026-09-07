/// Notist 專案模組。

library;

import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/src/settings/notist_settings.dart';
import 'package:notist/src/shell/notist_session_state.dart';
import 'package:notist/src/shell/notist_sidebar_mode.dart';
import 'package:notist/src/shell/notist_stage_zone.dart';
import 'package:notist/src/shell/notist_workbench_controller.dart';
import 'package:notist/src/shell/notist_workspace_destination.dart';

void main() {
  test('local session store round-trips stable shell identity', () async {
    final directory = await Directory.systemTemp.createTemp(
      'notist-session-test-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final store = NotistLocalSessionStore(directory.path);
    const dockLayout = KlpDockLayoutData(
      left: KlpDockAreaData(
        axis: Axis.vertical,
        groups: [],
        extent: 320,
        isVisible: false,
      ),
      right: KlpDockAreaData(
        axis: Axis.vertical,
        groups: [
          KlpDockGroupData(
            id: NotistWorkbenchController.navigationGroupId,
            panelIds: [NotistWorkbenchController.navigationPanelId],
            activePanelId: NotistWorkbenchController.navigationPanelId,
            mainAxisExtent: 320,
          ),
        ],
        extent: 320,
      ),
      bottom: KlpDockAreaData(
        axis: Axis.horizontal,
        groups: [],
        extent: 0,
        isVisible: false,
      ),
    );
    const state = NotistSessionState(
      startupBehavior: NotistStartupBehavior.restoreLast,
      primaryVisible: false,
      primaryWidth: 320,
      zone: NotistStageZone.destination,
      destination: NotistWorkspaceDestination.ai,
      sidebarMode: NotistSidebarMode.assistant,
      selectedRootId: '00000000000000000000000000000042',
      dockLayout: dockLayout,
      settings: NotistSettings(
        appearanceMode: NotistAppearanceMode.ultraDark,
        accent: NotistAccent.blue,
      ),
    );

    await store.save(state);
    final restored = await store.load();

    expect(restored?.startupBehavior, NotistStartupBehavior.restoreLast);
    expect(restored?.primaryVisible, isFalse);
    expect(restored?.primaryWidth, 320);
    expect(restored?.destination, NotistWorkspaceDestination.ai);
    expect(restored?.sidebarMode, NotistSidebarMode.assistant);
    expect(restored?.selectedRootId, state.selectedRootId);
    expect(restored?.dockLayout?.right.groups.single.panelIds, [
      NotistWorkbenchController.navigationPanelId,
    ]);
    expect(restored?.dockLayout?.bottom.extent, 0);
    expect(restored?.settings.appearanceMode, NotistAppearanceMode.ultraDark);
    expect(restored?.settings.accent, NotistAccent.blue);

    final controller = NotistWorkbenchController();
    addTearDown(controller.dispose);
    controller.restore(restored!);
    expect(controller.zone, NotistStageZone.document);
    expect(controller.sidebarMode, NotistSidebarMode.assistant);
    expect(controller.settings.accent, NotistAccent.blue);
    expect(controller.dockLayout.right.groups.single.panelIds, [
      NotistWorkbenchController.navigationPanelId,
    ]);

    controller.togglePrimary();
    expect(controller.dockLayout.right.isVisible, isFalse);
    controller.togglePrimary();
    expect(controller.dockLayout.right.isVisible, isTrue);
  });

  test('legacy session without dock layout restores the navigation panel', () {
    final state = NotistSessionState.fromJson({
      'startupBehavior': NotistStartupBehavior.restoreLast.name,
      'primaryVisible': false,
      'primaryWidth': 360,
      'zone': NotistStageZone.document.name,
      'destination': NotistWorkspaceDestination.journals.name,
      'selectedRootId': null,
    });
    final controller = NotistWorkbenchController();
    addTearDown(controller.dispose);

    controller.restore(state);

    expect(controller.primaryVisible, isFalse);
    expect(controller.primaryWidth, 360);
    expect(controller.dockLayout.left.groups.single.panelIds, [
      NotistWorkbenchController.navigationPanelId,
    ]);
  });

  test('legacy AI Stage session migrates AI into the sidebar', () {
    final state = NotistSessionState.fromJson({
      'startupBehavior': NotistStartupBehavior.restoreLast.name,
      'primaryVisible': true,
      'primaryWidth': 268,
      'zone': NotistStageZone.destination.name,
      'destination': NotistWorkspaceDestination.ai.name,
      'selectedRootId': null,
    });
    final controller = NotistWorkbenchController();
    addTearDown(controller.dispose);

    controller.restore(state);

    expect(controller.zone, NotistStageZone.document);
    expect(controller.sidebarMode, NotistSidebarMode.assistant);
  });

  test('AI destination requests are routed to the sidebar', () {
    final controller = NotistWorkbenchController();
    addTearDown(controller.dispose);

    controller.selectDestination(NotistWorkspaceDestination.ai);

    expect(controller.zone, NotistStageZone.document);
    expect(controller.sidebarMode, NotistSidebarMode.assistant);
  });

  test('invalid persisted panel placement falls back to the safe layout', () {
    const navigation = KlpDockGroupData(
      id: 'navigation-group',
      panelIds: [NotistWorkbenchController.navigationPanelId],
      activePanelId: NotistWorkbenchController.navigationPanelId,
      mainAxisExtent: 300,
    );
    const unknown = KlpDockGroupData(
      id: 'unknown-group',
      panelIds: ['unknown'],
      activePanelId: 'unknown',
      mainAxisExtent: 300,
    );
    final invalidLayouts = [
      _dockLayout(bottomGroups: const [navigation]),
      _dockLayout(
        leftGroups: const [navigation],
        rightGroups: const [navigation],
      ),
      _dockLayout(),
      _dockLayout(leftGroups: const [unknown]),
    ];
    final controller = NotistWorkbenchController();
    addTearDown(controller.dispose);

    for (final layout in invalidLayouts) {
      controller.restore(
        NotistSessionState(
          startupBehavior: NotistStartupBehavior.restoreLast,
          primaryVisible: false,
          primaryWidth: 340,
          zone: NotistStageZone.document,
          destination: NotistWorkspaceDestination.journals,
          dockLayout: layout,
        ),
      );

      expect(controller.primaryVisible, isFalse);
      expect(controller.primaryWidth, 340);
      expect(controller.dockLayout.left.groups.single.panelIds, [
        NotistWorkbenchController.navigationPanelId,
      ]);
      expect(controller.dockLayout.right.groups, isEmpty);
      expect(controller.dockLayout.bottom.groups, isEmpty);
    }
  });

  test('initial startup behavior ignores the prior visual state', () {
    final controller = NotistWorkbenchController();
    addTearDown(controller.dispose);

    controller.restore(
      const NotistSessionState(
        startupBehavior: NotistStartupBehavior.initial,
        primaryVisible: false,
        primaryWidth: 400,
        zone: NotistStageZone.destination,
        destination: NotistWorkspaceDestination.assets,
      ),
    );

    expect(controller.startupBehavior, NotistStartupBehavior.initial);
    expect(controller.primaryVisible, isTrue);
    expect(controller.destination, NotistWorkspaceDestination.journals);
    expect(controller.zone, NotistStageZone.document);
  });
}

KlpDockLayoutData _dockLayout({
  List<KlpDockGroupData> leftGroups = const [],
  List<KlpDockGroupData> rightGroups = const [],
  List<KlpDockGroupData> bottomGroups = const [],
}) {
  return KlpDockLayoutData(
    left: KlpDockAreaData(
      axis: Axis.vertical,
      groups: leftGroups,
      extent: 300,
      isVisible: leftGroups.isNotEmpty,
    ),
    right: KlpDockAreaData(
      axis: Axis.vertical,
      groups: rightGroups,
      extent: 300,
      isVisible: rightGroups.isNotEmpty,
    ),
    bottom: KlpDockAreaData(
      axis: Axis.horizontal,
      groups: bottomGroups,
      extent: bottomGroups.isEmpty ? 0 : 300,
      isVisible: bottomGroups.isNotEmpty,
    ),
  );
}
