/// Notist 對 Kallopis Dock 的產品 adapter。

library;

import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';

/// 維護唯一的 Notist 導覽面板及其 Kallopis Dock 資料。
final class NotistDockLayoutController {
  NotistDockLayoutController({
    double primaryWidth = initialPrimaryWidth,
    bool primaryVisible = true,
    KlpDockLayoutData? dockLayout,
  }) : _layout = _normalize(dockLayout, primaryWidth, primaryVisible);

  /// 產品指定的預設面板寬度，不是 Kallopis 視覺 token。
  static const double initialPrimaryWidth = 268;
  static const double minimumPrimaryWidth = 200;
  static const double maximumPrimaryWidth = 460;
  static const String navigationPanelId = 'navigation';
  static const String navigationGroupId = 'navigation-group';

  static const KlpDockAreaConstraints sideConstraints = KlpDockAreaConstraints(
    minExtent: minimumPrimaryWidth,
    maxExtent: maximumPrimaryWidth,
  );

  KlpDockLayoutData _layout;

  KlpDockLayoutData get layout => _layout;
  double get primaryWidth => _navigationArea?.extent ?? initialPrimaryWidth;
  bool get primaryVisible => _navigationArea?.isVisible ?? false;

  bool resizePrimary(double width) {
    final next = width
        .clamp(minimumPrimaryWidth, maximumPrimaryWidth)
        .toDouble();
    final area = _navigationArea;
    if (area == null || next == area.extent) return false;

    _replaceNavigationArea(area.copyWith(extent: next));
    return true;
  }

  bool togglePrimary() {
    final area = _navigationArea;
    if (area == null) return false;

    _replaceNavigationArea(area.copyWith(isVisible: !area.isVisible));
    return true;
  }

  bool setLayout(KlpDockLayoutData layout) {
    if (identical(layout, _layout)) return false;

    _layout = _normalize(layout, primaryWidth, primaryVisible);
    return true;
  }

  void restore({
    required KlpDockLayoutData? layout,
    required double primaryWidth,
    required bool primaryVisible,
  }) {
    _layout = _normalize(layout, primaryWidth, primaryVisible);
  }

  KlpDockAreaData? get _navigationArea {
    if (_containsNavigation(_layout.left)) return _layout.left;
    if (_containsNavigation(_layout.right)) return _layout.right;

    return null;
  }

  void _replaceNavigationArea(KlpDockAreaData area) {
    if (_containsNavigation(_layout.left)) {
      _layout = _layout.copyWith(left: area);
      return;
    }

    if (_containsNavigation(_layout.right)) {
      _layout = _layout.copyWith(right: area);
    }
  }

  static bool _containsNavigation(KlpDockAreaData area) {
    return area.groups.any(
      (group) => group.panelIds.contains(navigationPanelId),
    );
  }

  static KlpDockLayoutData _normalize(
    KlpDockLayoutData? layout,
    double fallbackWidth,
    bool fallbackVisible,
  ) {
    if (layout == null || !_isValidNavigationLayout(layout)) {
      return _initialLayout(fallbackWidth, fallbackVisible);
    }

    final leftExtent = layout.left.extent
        .clamp(minimumPrimaryWidth, maximumPrimaryWidth)
        .toDouble();
    final rightExtent = layout.right.extent
        .clamp(minimumPrimaryWidth, maximumPrimaryWidth)
        .toDouble();

    return layout.copyWith(
      left: layout.left.copyWith(extent: leftExtent),
      right: layout.right.copyWith(extent: rightExtent),
      bottom: const KlpDockAreaData(
        axis: Axis.horizontal,
        groups: [],
        extent: 0,
        isVisible: false,
      ),
    );
  }

  static bool _isValidNavigationLayout(KlpDockLayoutData layout) {
    if (layout.left.axis != Axis.vertical ||
        layout.right.axis != Axis.vertical ||
        layout.bottom.axis != Axis.horizontal ||
        layout.bottom.groups.isNotEmpty) {
      return false;
    }

    final groups = [...layout.left.groups, ...layout.right.groups];
    if (groups.length != 1) return false;

    final group = groups.single;
    return group.panelIds.length == 1 &&
        group.panelIds.single == navigationPanelId &&
        group.activePanelId == navigationPanelId;
  }

  static KlpDockLayoutData _initialLayout(double width, bool visible) {
    final extent = width
        .clamp(minimumPrimaryWidth, maximumPrimaryWidth)
        .toDouble();

    return KlpDockLayoutData(
      left: KlpDockAreaData(
        axis: Axis.vertical,
        groups: [
          KlpDockGroupData(
            id: navigationGroupId,
            panelIds: const [navigationPanelId],
            activePanelId: navigationPanelId,
            mainAxisExtent: extent,
          ),
        ],
        extent: extent,
        isVisible: visible,
      ),
      right: const KlpDockAreaData(
        axis: Axis.vertical,
        groups: [],
        extent: initialPrimaryWidth,
        isVisible: false,
      ),
      bottom: const KlpDockAreaData(
        axis: Axis.horizontal,
        groups: [],
        extent: 0,
        isVisible: false,
      ),
    );
  }
}
