import 'package:flutter/material.dart';
import 'package:kallopis/kallopis.dart';

enum NotistLocalSaveState { idle, localLoaded, saving, localSaved, failed }

final class NotistLocalSaveController
    extends ValueNotifier<NotistLocalSaveState> {
  NotistLocalSaveController() : super(NotistLocalSaveState.idle);

  Object? error;
  VoidCallback? _retry;
  var _generation = 0;

  VoidCallback? get retry => _retry;

  int beginSession() {
    _generation += 1;
    _clear();
    return _generation;
  }

  void beginSave({int? session}) {
    if (!_accepts(session)) return;
    error = null;
    value = NotistLocalSaveState.saving;
  }

  void markLoaded({int? session}) {
    if (!_accepts(session)) return;
    error = null;
    value = NotistLocalSaveState.localLoaded;
  }

  void completeSave({int? session}) {
    if (!_accepts(session)) return;
    error = null;
    value = NotistLocalSaveState.localSaved;
  }

  void failSave(Object nextError, {int? session}) {
    if (!_accepts(session)) return;
    error = nextError;
    value = NotistLocalSaveState.failed;
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
    value = NotistLocalSaveState.idle;
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
    final (label, kind, active) = switch (state) {
      NotistLocalSaveState.idle => ('尚未儲存', KlpStatusKind.circle, false),
      NotistLocalSaveState.localLoaded => ('已載入', KlpStatusKind.check, true),
      NotistLocalSaveState.saving => ('儲存中', KlpStatusKind.running, true),
      NotistLocalSaveState.localSaved => ('已儲存', KlpStatusKind.check, true),
      NotistLocalSaveState.failed => ('儲存失敗', KlpStatusKind.cross, false),
    };

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.klp.space.compact),
      child: Row(
        children: [
          KlpStatusIndicator(label: label, kind: kind, active: active),
          if (blockCount != null) ...[
            SizedBox(width: context.klp.space.base),
            const KlpText(
              '區塊',
              role: KlpTextRole.code,
              tone: KlpTextTone.muted,
            ),
            SizedBox(width: context.klp.space.tight),
            KlpText('$blockCount', role: KlpTextRole.code),
          ],
          if (undoHistoryEvicted) ...[
            SizedBox(width: context.klp.space.base),
            const KlpText(
              '較早的復原紀錄已清除',
              role: KlpTextRole.code,
              tone: KlpTextTone.muted,
            ),
          ],
          const Spacer(),
          if (state == NotistLocalSaveState.failed) ...[
            KlpButton(
              label: '重試儲存',
              compact: true,
              tone: KlpButtonTone.ghost,
              onPressed: onRetry,
            ),
            SizedBox(width: context.klp.space.compact),
          ],
          const KlpText('本機', role: KlpTextRole.code, tone: KlpTextTone.faint),
        ],
      ),
    );
  }
}
