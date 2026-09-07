/// Notist 工作台的產品導覽狀態。

library;

import '../notist_sidebar_mode.dart';
import '../notist_stage_zone.dart';
import '../notist_workspace_destination.dart';

/// 維護文件、固定入口與側欄內容的互斥關係。
final class NotistWorkspaceNavigationController {
  factory NotistWorkspaceNavigationController({
    NotistWorkspaceDestination destination =
        NotistWorkspaceDestination.journals,
  }) {
    return NotistWorkspaceNavigationController._(destination: destination);
  }

  NotistWorkspaceNavigationController._({required this._destination});

  NotistWorkspaceDestination _destination;
  NotistStageZone _zone = NotistStageZone.document;
  NotistSidebarMode _sidebarMode = NotistSidebarMode.notes;

  NotistWorkspaceDestination get destination => _destination;
  NotistStageZone get zone => _zone;
  NotistSidebarMode get sidebarMode => _sidebarMode;

  bool showNotesSidebar() => _setSidebarMode(NotistSidebarMode.notes);

  bool showAssistantSidebar() => _setSidebarMode(NotistSidebarMode.assistant);

  bool selectDestination(NotistWorkspaceDestination destination) {
    if (destination == NotistWorkspaceDestination.ai) {
      return showAssistantSidebar();
    }

    final unchanged =
        destination == _destination && _zone == NotistStageZone.destination;
    if (unchanged) return false;

    _destination = destination;
    _zone = NotistStageZone.destination;
    return true;
  }

  bool showDocument() {
    if (_zone == NotistStageZone.document) return false;

    _zone = NotistStageZone.document;
    return true;
  }

  void restore({
    required NotistWorkspaceDestination destination,
    required NotistStageZone zone,
    required NotistSidebarMode sidebarMode,
  }) {
    _destination = destination;
    _zone = zone;
    _sidebarMode = sidebarMode;
  }

  bool _setSidebarMode(NotistSidebarMode mode) {
    if (_sidebarMode == mode) return false;

    _sidebarMode = mode;
    return true;
  }
}
