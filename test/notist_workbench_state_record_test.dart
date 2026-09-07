/// Notist 專案模組。

library;

import 'package:flutter_test/flutter_test.dart';
import 'package:notist/src/shell/notist_session_state.dart';
import 'package:notist/src/shell/notist_sidebar_mode.dart';
import 'package:notist/src/shell/notist_stage_zone.dart';
import 'package:notist/src/shell/notist_workbench_controller.dart';
import 'package:notist/src/shell/notist_workspace_destination.dart';

void main() {
  test('state record packages the complete workbench composition state', () {
    final controller = NotistWorkbenchController();
    addTearDown(controller.dispose);

    controller.selectDestination(NotistWorkspaceDestination.assets);
    final state = controller.state;

    expect(state.destination, NotistWorkspaceDestination.assets);
    expect(state.zone, NotistStageZone.destination);
    expect(state.sidebarMode, NotistSidebarMode.notes);
    expect(state.startupBehavior, NotistStartupBehavior.restoreLast);
    expect(state.dockLayout.left.groups.single.panelIds, [
      NotistWorkbenchController.navigationPanelId,
    ]);
  });
}
