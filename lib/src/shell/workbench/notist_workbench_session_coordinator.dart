/// Notist 工作台 session 的還原與相容遷移。

library;

import '../notist_session_state.dart';
import '../notist_sidebar_mode.dart';
import '../notist_stage_zone.dart';
import '../notist_workspace_destination.dart';
import 'notist_dock_layout_controller.dart';
import 'notist_workspace_navigation_controller.dart';

/// 將持久化資料轉為目前工作台可用的狀態。
final class NotistWorkbenchSessionCoordinator {
  const NotistWorkbenchSessionCoordinator._();

  static NotistStartupBehavior restore({
    required NotistSessionState state,
    required NotistDockLayoutController dockController,
    required NotistWorkspaceNavigationController navigationController,
  }) {
    if (state.startupBehavior != NotistStartupBehavior.restoreLast) {
      return state.startupBehavior;
    }

    dockController.restore(
      layout: state.dockLayout,
      primaryWidth: state.primaryWidth,
      primaryVisible: state.primaryVisible,
    );

    final migratesLegacyAssistant =
        state.zone == NotistStageZone.destination &&
        state.destination == NotistWorkspaceDestination.ai;
    navigationController.restore(
      destination: state.destination,
      zone: migratesLegacyAssistant ? NotistStageZone.document : state.zone,
      sidebarMode: migratesLegacyAssistant
          ? NotistSidebarMode.assistant
          : state.sidebarMode,
    );
    return state.startupBehavior;
  }
}
