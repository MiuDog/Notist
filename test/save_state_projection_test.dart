import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/src/krepis/notist_local_save_projection.dart';

void main() {
  test('local save controller only reaches saved after explicit success', () {
    final controller = NotistLocalSaveController();
    addTearDown(controller.dispose);

    expect(controller.value, NotistLocalSaveState.idle);

    controller.beginSave();
    expect(controller.value, NotistLocalSaveState.saving);

    controller.failSave(StateError('disk full'));
    expect(controller.value, NotistLocalSaveState.failed);
    expect(controller.error, isA<StateError>());

    controller.beginSave();
    expect(controller.value, NotistLocalSaveState.saving);

    controller.completeSave();
    expect(controller.value, NotistLocalSaveState.localSaved);
    expect(controller.error, isNull);
  });

  test('loaded file is distinct from an explicit save success', () {
    final controller = NotistLocalSaveController();
    addTearDown(controller.dispose);

    controller.markLoaded();

    expect(controller.value, NotistLocalSaveState.localLoaded);
  });

  test('stale document session cannot publish state or retry', () {
    final controller = NotistLocalSaveController();
    addTearDown(controller.dispose);
    var staleRetries = 0;
    var currentRetries = 0;

    final stale = controller.beginSession();
    controller.configureRetry(() => staleRetries += 1, session: stale);
    controller.completeSave(session: stale);

    final current = controller.beginSession();
    controller.configureRetry(() => currentRetries += 1, session: current);
    controller.failSave(StateError('current failure'), session: current);
    controller.completeSave(session: stale);
    controller.configureRetry(() => staleRetries += 1, session: stale);

    expect(controller.value, NotistLocalSaveState.failed);
    controller.retry?.call();
    expect(staleRetries, 0);
    expect(currentRetries, 1);

    controller.endSession(current);
    expect(controller.value, NotistLocalSaveState.idle);
    expect(controller.retry, isNull);
  });

  Future<void> pumpStatus(
    WidgetTester tester,
    NotistLocalSaveState state, {
    VoidCallback? onRetry,
  }) async {
    await tester.pumpWidget(
      KlpApp(
        showWindowHeader: false,
        home: KlpAppScreen(
          child: NotistLocalSaveStatus(state: state, onRetry: onRetry),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('projects every local save state with mutually exclusive copy', (
    tester,
  ) async {
    const cases = <NotistLocalSaveState, String>{
      NotistLocalSaveState.idle: '尚未儲存',
      NotistLocalSaveState.localLoaded: '已載入',
      NotistLocalSaveState.saving: '儲存中',
      NotistLocalSaveState.localSaved: '已儲存',
      NotistLocalSaveState.failed: '儲存失敗',
    };

    for (final entry in cases.entries) {
      await pumpStatus(tester, entry.key);

      expect(find.byType(KlpStatusIndicator), findsOneWidget);
      expect(find.text(entry.value), findsOneWidget);
      for (final other in cases.values.where((value) => value != entry.value)) {
        expect(find.text(other), findsNothing);
      }
    }
  });

  testWidgets('projects the Flow block count beside save state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const KlpApp(
        showWindowHeader: false,
        home: KlpAppScreen(
          child: NotistLocalSaveStatus(
            state: NotistLocalSaveState.localLoaded,
            blockCount: 3,
          ),
        ),
      ),
    );

    expect(find.text('區塊'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('本機'), findsOneWidget);
  });

  testWidgets('does not report local saved before the success state', (
    tester,
  ) async {
    for (final state in const [
      NotistLocalSaveState.idle,
      NotistLocalSaveState.localLoaded,
      NotistLocalSaveState.saving,
      NotistLocalSaveState.failed,
    ]) {
      await pumpStatus(tester, state);

      expect(find.text('已儲存'), findsNothing, reason: state.name);
      expect(
        find.textContaining(RegExp(r'^Saved$', caseSensitive: false)),
        findsNothing,
        reason: state.name,
      );
    }
  });

  testWidgets('save failure exposes retry in the status slot', (tester) async {
    var retries = 0;

    await pumpStatus(
      tester,
      NotistLocalSaveState.failed,
      onRetry: () => retries += 1,
    );

    expect(find.text('儲存失敗'), findsOneWidget);
    expect(find.text('重試儲存'), findsOneWidget);

    await tester.tap(find.text('重試儲存'));
    await tester.pump();

    expect(retries, 1);
  });
}
