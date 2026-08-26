import 'package:flutter/foundation.dart';

import 'krepis_block.dart';

@immutable
final class NotistBlockCommandActions {
  const NotistBlockCommandActions({
    required this.onDuplicate,
    this.onMoveUp,
    this.onMoveDown,
    this.onDelete,
    this.onToggleTask,
    this.onConvert = const {},
  });

  final VoidCallback onDuplicate;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleTask;
  final Map<KrepisFlowBlockKind, VoidCallback> onConvert;
}
