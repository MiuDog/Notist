/// Notist 專案模組。

library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';

import '../settings/notist_settings.dart';
import 'notist_sidebar_mode.dart';
import 'notist_stage_zone.dart';
import 'notist_workspace_destination.dart';

enum NotistStartupBehavior { restoreLast, initial }

final class NotistSessionState {
  const NotistSessionState({
    required this.startupBehavior,
    required this.primaryVisible,
    required this.primaryWidth,
    required this.zone,
    required this.destination,
    this.sidebarMode = NotistSidebarMode.notes,
    this.selectedRootId,
    this.dockLayout,
    this.settings = NotistSettings.defaults,
  });

  factory NotistSessionState.fromJson(Map<String, Object?> json) {
    final zone = NotistStageZone.values.byName(json['zone']! as String);
    final destination = NotistWorkspaceDestination.values.byName(
      json['destination']! as String,
    );
    final sidebarMode = switch (json['sidebarMode']) {
      final String value => NotistSidebarMode.values.byName(value),
      _
          when zone == NotistStageZone.destination &&
              destination == NotistWorkspaceDestination.ai =>
        NotistSidebarMode.assistant,
      _ => NotistSidebarMode.notes,
    };

    return NotistSessionState(
      startupBehavior: NotistStartupBehavior.values.byName(
        json['startupBehavior']! as String,
      ),
      primaryVisible: json['primaryVisible']! as bool,
      primaryWidth: (json['primaryWidth']! as num).toDouble(),
      zone: zone,
      destination: destination,
      sidebarMode: sidebarMode,
      selectedRootId: json['selectedRootId'] as String?,
      dockLayout: switch (json['dockLayout']) {
        final Map<String, Object?> value => _dockLayoutFromJson(value),
        _ => null,
      },
      settings: switch (json['settings']) {
        final Map<String, Object?> value => NotistSettings.fromJson(value),
        _ => NotistSettings.defaults,
      },
    );
  }

  final NotistStartupBehavior startupBehavior;
  final bool primaryVisible;
  final double primaryWidth;
  final NotistStageZone zone;
  final NotistWorkspaceDestination destination;
  final NotistSidebarMode sidebarMode;
  final String? selectedRootId;
  final KlpDockLayoutData? dockLayout;
  final NotistSettings settings;

  Map<String, Object?> toJson() => {
    'startupBehavior': startupBehavior.name,
    'primaryVisible': primaryVisible,
    'primaryWidth': primaryWidth,
    'zone': zone.name,
    'destination': destination.name,
    'sidebarMode': sidebarMode.name,
    'selectedRootId': selectedRootId,
    if (dockLayout case final layout?) 'dockLayout': _dockLayoutToJson(layout),
    'settings': settings.toJson(),
  };
}

KlpDockLayoutData _dockLayoutFromJson(Map<String, Object?> json) {
  return KlpDockLayoutData(
    left: _dockAreaFromJson(json['left']! as Map<String, Object?>),
    right: _dockAreaFromJson(json['right']! as Map<String, Object?>),
    bottom: _dockAreaFromJson(json['bottom']! as Map<String, Object?>),
  );
}

KlpDockAreaData _dockAreaFromJson(Map<String, Object?> json) {
  return KlpDockAreaData(
    axis: Axis.values.byName(json['axis']! as String),
    groups: [
      for (final group in json['groups']! as List<Object?>)
        _dockGroupFromJson(group! as Map<String, Object?>),
    ],
    extent: (json['extent']! as num).toDouble(),
    isVisible: json['isVisible']! as bool,
  );
}

KlpDockGroupData _dockGroupFromJson(Map<String, Object?> json) {
  return KlpDockGroupData(
    id: json['id']! as String,
    panelIds: (json['panelIds']! as List<Object?>).cast<String>(),
    activePanelId: json['activePanelId']! as String,
    mainAxisExtent: (json['mainAxisExtent']! as num).toDouble(),
  );
}

Map<String, Object?> _dockLayoutToJson(KlpDockLayoutData layout) => {
  'left': _dockAreaToJson(layout.left),
  'right': _dockAreaToJson(layout.right),
  'bottom': _dockAreaToJson(layout.bottom),
};

Map<String, Object?> _dockAreaToJson(KlpDockAreaData area) => {
  'axis': area.axis.name,
  'groups': [for (final group in area.groups) _dockGroupToJson(group)],
  'extent': area.extent,
  'isVisible': area.isVisible,
};

Map<String, Object?> _dockGroupToJson(KlpDockGroupData group) => {
  'id': group.id,
  'panelIds': group.panelIds,
  'activePanelId': group.activePanelId,
  'mainAxisExtent': group.mainAxisExtent,
};

abstract interface class NotistSessionStore {
  Future<NotistSessionState?> load();
  Future<void> save(NotistSessionState state);
}

final class NotistLocalSessionStore implements NotistSessionStore {
  NotistLocalSessionStore(String projectDirectoryPath)
    : _file = File(
        '$projectDirectoryPath${Platform.pathSeparator}.notist-session.json',
      );

  final File _file;

  @override
  Future<NotistSessionState?> load() async {
    if (!await _file.exists()) return null;
    final json = jsonDecode(await _file.readAsString());
    if (json is! Map<String, Object?>) {
      throw const FormatException('Notist session 必須是 JSON object');
    }
    return NotistSessionState.fromJson(json);
  }

  @override
  Future<void> save(NotistSessionState state) async {
    await _file.parent.create(recursive: true);
    final temporary = File('${_file.path}.tmp');
    await temporary.writeAsString(jsonEncode(state.toJson()), flush: true);
    if (await _file.exists()) await _file.delete();
    await temporary.rename(_file.path);
  }
}
