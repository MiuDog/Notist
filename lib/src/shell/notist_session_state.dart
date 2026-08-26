import 'dart:convert';
import 'dart:io';

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
    this.selectedRootId,
  });

  factory NotistSessionState.fromJson(Map<String, Object?> json) {
    return NotistSessionState(
      startupBehavior: NotistStartupBehavior.values.byName(
        json['startupBehavior']! as String,
      ),
      primaryVisible: json['primaryVisible']! as bool,
      primaryWidth: (json['primaryWidth']! as num).toDouble(),
      zone: NotistStageZone.values.byName(json['zone']! as String),
      destination: NotistWorkspaceDestination.values.byName(
        json['destination']! as String,
      ),
      selectedRootId: json['selectedRootId'] as String?,
    );
  }

  final NotistStartupBehavior startupBehavior;
  final bool primaryVisible;
  final double primaryWidth;
  final NotistStageZone zone;
  final NotistWorkspaceDestination destination;
  final String? selectedRootId;

  Map<String, Object?> toJson() => {
    'startupBehavior': startupBehavior.name,
    'primaryVisible': primaryVisible,
    'primaryWidth': primaryWidth,
    'zone': zone.name,
    'destination': destination.name,
    'selectedRootId': selectedRootId,
  };
}

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
