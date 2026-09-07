/// Notist 專案模組。

library;

import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';

import '../settings/notist_settings.dart';
import 'notist_session_state.dart';
import 'notist_sidebar_mode.dart';
import 'notist_stage_zone.dart';
import 'notist_workspace_destination.dart';
import 'workbench/notist_dock_layout_controller.dart';
import 'workbench/notist_workbench_session_coordinator.dart';
import 'workbench/notist_workbench_state_record.dart';
import 'workbench/notist_workspace_navigation_controller.dart';

/// 工作台畫面的單一狀態入口，協調 Dock、導覽與 session 子狀態。
final class NotistWorkbenchController extends ChangeNotifier {
  factory NotistWorkbenchController({
    double primaryWidth = initialPrimaryWidth,
    bool primaryVisible = true,
    KlpDockLayoutData? dockLayout,
    NotistWorkspaceDestination destination =
        NotistWorkspaceDestination.journals,
    NotistStartupBehavior startupBehavior = NotistStartupBehavior.restoreLast,
    NotistSettings settings = NotistSettings.defaults,
  }) {
    return NotistWorkbenchController._(
      dockController: NotistDockLayoutController(
        primaryWidth: primaryWidth,
        primaryVisible: primaryVisible,
        dockLayout: dockLayout,
      ),
      navigationController: NotistWorkspaceNavigationController(
        destination: destination,
      ),
      startupBehavior: startupBehavior,
      settings: settings,
    );
  }

  NotistWorkbenchController._({
    required this._dockController,
    required this._navigationController,
    required this._startupBehavior,
    required this._settings,
  });

  static const double initialPrimaryWidth =
      NotistDockLayoutController.initialPrimaryWidth;
  static const double minimumPrimaryWidth =
      NotistDockLayoutController.minimumPrimaryWidth;
  static const double maximumPrimaryWidth =
      NotistDockLayoutController.maximumPrimaryWidth;
  static const String navigationPanelId =
      NotistDockLayoutController.navigationPanelId;
  static const String navigationGroupId =
      NotistDockLayoutController.navigationGroupId;
  static const KlpDockAreaConstraints sideConstraints =
      NotistDockLayoutController.sideConstraints;

  final NotistDockLayoutController _dockController;
  final NotistWorkspaceNavigationController _navigationController;
  NotistStartupBehavior _startupBehavior;
  NotistSettings _settings;

  /// 供畫面組裝層一次注入完整工作台狀態的專用 record。
  NotistWorkbenchStateRecord get state => NotistWorkbenchStateRecord(
    dockLayout: _dockController.layout,
    destination: _navigationController.destination,
    zone: _navigationController.zone,
    sidebarMode: _navigationController.sidebarMode,
    startupBehavior: _startupBehavior,
    settings: _settings,
  );

  KlpDockLayoutData get dockLayout => state.dockLayout;
  double get primaryWidth => _dockController.primaryWidth;
  bool get primaryVisible => _dockController.primaryVisible;
  NotistWorkspaceDestination get destination => state.destination;
  NotistSidebarMode get sidebarMode => state.sidebarMode;
  NotistStartupBehavior get startupBehavior => state.startupBehavior;
  NotistSettings get settings => state.settings;
  NotistStageZone get zone => state.zone;

  void resizePrimary(double width) {
    if (!_dockController.resizePrimary(width)) return;

    notifyListeners();
  }

  void togglePrimary() {
    if (!_dockController.togglePrimary()) return;

    notifyListeners();
  }

  void showNotesSidebar() =>
      _changeNavigation(_navigationController.showNotesSidebar);

  void showAssistantSidebar() =>
      _changeNavigation(_navigationController.showAssistantSidebar);

  void setDockLayout(KlpDockLayoutData layout) {
    if (!_dockController.setLayout(layout)) return;

    notifyListeners();
  }

  void selectDestination(NotistWorkspaceDestination destination) {
    _changeNavigation(
      () => _navigationController.selectDestination(destination),
    );
  }

  void showDocument() => _changeNavigation(_navigationController.showDocument);

  void setStartupBehavior(NotistStartupBehavior behavior) {
    if (_startupBehavior == behavior) return;

    _startupBehavior = behavior;
    notifyListeners();
  }

  void setAppearanceMode(NotistAppearanceMode mode) {
    if (_settings.appearanceMode == mode) return;

    _settings = _settings.copyWith(appearanceMode: mode);
    notifyListeners();
  }

  void setAccent(NotistAccent accent) {
    if (_settings.accent == accent) return;

    _settings = _settings.copyWith(accent: accent);
    notifyListeners();
  }

  void restore(NotistSessionState state) {
    _settings = state.settings;
    _startupBehavior = NotistWorkbenchSessionCoordinator.restore(
      state: state,
      dockController: _dockController,
      navigationController: _navigationController,
    );
    notifyListeners();
  }

  void _changeNavigation(bool Function() operation) {
    if (!operation()) return;

    notifyListeners();
  }
}
