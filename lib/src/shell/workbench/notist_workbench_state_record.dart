/// Notist 工作台的完整畫面狀態資料。

library;

import 'package:kallopis/kallopis.dart';

import '../../settings/notist_settings.dart';
import '../notist_session_state.dart';
import '../notist_sidebar_mode.dart';
import '../notist_stage_zone.dart';
import '../notist_workspace_destination.dart';

/// 組裝工作台時唯一注入的狀態 record。
final class NotistWorkbenchStateRecord {
  const NotistWorkbenchStateRecord({
    required this.dockLayout,
    required this.destination,
    required this.zone,
    required this.sidebarMode,
    required this.startupBehavior,
    required this.settings,
  });

  final KlpDockLayoutData dockLayout;
  final NotistWorkspaceDestination destination;
  final NotistStageZone zone;
  final NotistSidebarMode sidebarMode;
  final NotistStartupBehavior startupBehavior;
  final NotistSettings settings;
}
