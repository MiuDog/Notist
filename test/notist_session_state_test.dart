import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:notist/src/shell/notist_session_state.dart';
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
    const state = NotistSessionState(
      startupBehavior: NotistStartupBehavior.restoreLast,
      primaryVisible: false,
      primaryWidth: 320,
      zone: NotistStageZone.destination,
      destination: NotistWorkspaceDestination.ai,
      selectedRootId: '00000000000000000000000000000042',
    );

    await store.save(state);
    final restored = await store.load();

    expect(restored?.startupBehavior, NotistStartupBehavior.restoreLast);
    expect(restored?.primaryVisible, isFalse);
    expect(restored?.primaryWidth, 320);
    expect(restored?.destination, NotistWorkspaceDestination.ai);
    expect(restored?.selectedRootId, state.selectedRootId);
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
