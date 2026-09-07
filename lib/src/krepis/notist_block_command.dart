/// Notist 專案模組。

library;

import 'package:flutter/foundation.dart';

import 'krepis_block.dart';

enum NotistBlockCommandSurface { contextMenu, slashMenu }

enum NotistBlockCommandSection {
  actions,
  movement,
  basicBlocks,
  advancedBlocks,
}

enum NotistBlockCommandId {
  duplicate,
  moveUp,
  moveDown,
  delete,
  toggleTask,
  paragraph,
  heading,
  unorderedList,
  orderedList,
  taskList,
  quote,
  code,
  divider,
}

extension NotistBlockConversionCommand on NotistBlockCommandId {
  KrepisFlowBlockKind? get conversionKind => switch (this) {
    NotistBlockCommandId.paragraph => KrepisFlowBlockKind.paragraph,
    NotistBlockCommandId.heading => KrepisFlowBlockKind.heading,
    NotistBlockCommandId.unorderedList => KrepisFlowBlockKind.unorderedListItem,
    NotistBlockCommandId.orderedList => KrepisFlowBlockKind.orderedListItem,
    NotistBlockCommandId.taskList => KrepisFlowBlockKind.taskListItem,
    NotistBlockCommandId.quote => KrepisFlowBlockKind.blockQuote,
    NotistBlockCommandId.code => KrepisFlowBlockKind.codeBlock,
    NotistBlockCommandId.divider => KrepisFlowBlockKind.thematicBreak,
    NotistBlockCommandId.duplicate ||
    NotistBlockCommandId.moveUp ||
    NotistBlockCommandId.moveDown ||
    NotistBlockCommandId.delete ||
    NotistBlockCommandId.toggleTask => null,
  };
}

@immutable
final class NotistBlockCommand {
  const NotistBlockCommand({
    required this.id,
    required this.section,
    required this.label,
    required this.surfaces,
    required this.onPressed,
    this.caption,
    this.danger = false,
    this.selected = false,
  });

  final NotistBlockCommandId id;
  final NotistBlockCommandSection section;
  final String label;
  final Set<NotistBlockCommandSurface> surfaces;
  final VoidCallback? onPressed;
  final String? caption;
  final bool danger;
  final bool selected;

  bool get enabled => onPressed != null;
}
