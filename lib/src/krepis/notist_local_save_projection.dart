/// Notist 專案模組。

library;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:kallopis/kallopis.dart';

enum NotistLocalSaveState { idle, localLoaded, saving, localSaved, failed }

final class NotistLocalSaveController
    extends ValueNotifier<NotistLocalSaveState> {
  NotistLocalSaveController() : super(NotistLocalSaveState.idle);

  Object? error;
  VoidCallback? _retry;
  var _generation = 0;
  var _revision = 0;
  var _disposed = false;

  VoidCallback? get retry => _retry;

  int beginSession() {
    _generation += 1;
    _clear();
    return _generation;
  }

  void beginSave({int? session}) {
    if (!_accepts(session)) return;
    error = null;
    _publish(NotistLocalSaveState.saving);
  }

  void markLoaded({int? session}) {
    if (!_accepts(session)) return;
    error = null;
    _publish(NotistLocalSaveState.localLoaded);
  }

  void completeSave({int? session}) {
    if (!_accepts(session)) return;
    error = null;
    _publish(NotistLocalSaveState.localSaved);
  }

  void failSave(Object nextError, {int? session}) {
    if (!_accepts(session)) return;
    error = nextError;
    _publish(NotistLocalSaveState.failed);
  }

  void configureRetry(VoidCallback retry, {int? session}) {
    if (!_accepts(session)) return;
    _retry = retry;
  }

  void endSession(int session) {
    if (!_accepts(session)) return;
    _generation += 1;
    _clear();
  }

  void reset() {
    _generation += 1;
    _clear();
  }

  bool _accepts(int? session) => session == null || session == _generation;

  void _clear() {
    error = null;
    _retry = null;
    _publish(NotistLocalSaveState.idle);
  }

  void _publish(NotistLocalSaveState next) {
    final revision = ++_revision;
    if (value == next) return;

    // Widget 卸載期間不可同步喚醒仍掛著的 ValueListenableBuilder。
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_disposed || revision != _revision) return;

        value = next;
      });
      return;
    }

    value = next;
  }

  @override
  void dispose() {
    _disposed = true;
    _revision += 1;
    super.dispose();
  }
}

class NotistLocalSaveStatus extends StatelessWidget {
  const NotistLocalSaveStatus({
    super.key,
    required this.state,
    this.blockCount,
    this.onRetry,
    this.undoHistoryEvicted = false,
  });

  final NotistLocalSaveState state;
  final int? blockCount;
  final VoidCallback? onRetry;
  final bool undoHistoryEvicted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: KlpStatusBar(data: _statusData)),
        if (state == NotistLocalSaveState.failed) ...[
          SizedBox(width: context.klp.space.tight),
          KlpButton(
            label: '重試儲存',
            size: KlpControlSize.xs,
            tone: KlpButtonTone.ghost,
            onPressed: onRetry,
          ),
        ],
      ],
    );
  }

  KlpStatusBarData get _statusData {
    final (label, kind, active) = switch (state) {
      NotistLocalSaveState.idle => ('尚未儲存', KlpStatusKind.circle, false),
      NotistLocalSaveState.localLoaded => ('已載入', KlpStatusKind.check, true),
      NotistLocalSaveState.saving => ('儲存中', KlpStatusKind.running, true),
      NotistLocalSaveState.localSaved => ('已儲存', KlpStatusKind.check, true),
      NotistLocalSaveState.failed => ('儲存失敗', KlpStatusKind.cross, false),
    };
    final leading = <KlpStatusItemData>[
      KlpStatusItemData(label: label, kind: kind, active: active),
      if (blockCount != null)
        KlpStatusItemData(label: '區塊 $blockCount', showsIndicator: false),
      if (undoHistoryEvicted)
        const KlpStatusItemData(label: '較早的復原紀錄已清除', showsIndicator: false),
    ];

    return KlpStatusBarData(
      leading: leading,
      trailing: const [KlpStatusItemData(label: '本機', showsIndicator: false)],
    );
  }
}
