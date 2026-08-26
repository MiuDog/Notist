import 'package:flutter/foundation.dart';

import 'krepis_block.dart';

enum KrepisTextAffinity { upstream, downstream }

enum KrepisBlockTargetAffinity { before, after }

@immutable
final class KrepisTextEndpointProjection {
  const KrepisTextEndpointProjection({
    required this.blockId,
    required this.graphemeBoundary,
    required this.affinity,
  });

  final String blockId;
  final int graphemeBoundary;
  final KrepisTextAffinity affinity;
}

@immutable
final class KrepisTextSelectionProjection {
  const KrepisTextSelectionProjection({
    required this.contentRevision,
    required this.anchor,
    required this.focus,
  });

  final int contentRevision;
  final KrepisTextEndpointProjection anchor;
  final KrepisTextEndpointProjection focus;
}

@immutable
final class KrepisCommandApplicabilityProjection {
  const KrepisCommandApplicabilityProjection({
    required this.contentRevision,
    required this.selectionCanReplace,
    required this.selectionRangeHasMoveTarget,
    required this.anchorCanConvert,
  });

  final int contentRevision;
  final bool selectionCanReplace;
  final bool selectionRangeHasMoveTarget;
  final bool anchorCanConvert;
}

@immutable
final class KrepisFlowBlockRange {
  const KrepisFlowBlockRange({
    required this.firstBlockId,
    required this.lastBlockId,
  });

  final String firstBlockId;
  final String lastBlockId;
}

@immutable
final class KrepisFlowBlockTarget {
  const KrepisFlowBlockTarget({required this.blockId, required this.affinity});

  final String blockId;
  final KrepisBlockTargetAffinity affinity;
}

@immutable
final class KrepisFlowBlockAttributes {
  const KrepisFlowBlockAttributes({
    required this.kind,
    this.level = 0,
    this.nestingDepth = 0,
    this.orderedStart = 0,
    this.taskChecked = false,
    this.info = '',
  });

  factory KrepisFlowBlockAttributes.fromBlock(
    KrepisFlowBlockProjection block, {
    KrepisFlowBlockKind? kind,
    bool? taskChecked,
  }) {
    final targetKind = kind ?? block.kind;
    final targetIsList = switch (targetKind) {
      KrepisFlowBlockKind.unorderedListItem ||
      KrepisFlowBlockKind.orderedListItem ||
      KrepisFlowBlockKind.taskListItem => true,
      _ => false,
    };
    final sourceIsList = switch (block.kind) {
      KrepisFlowBlockKind.unorderedListItem ||
      KrepisFlowBlockKind.orderedListItem ||
      KrepisFlowBlockKind.taskListItem => true,
      _ => false,
    };

    return KrepisFlowBlockAttributes(
      kind: targetKind,
      level: targetKind == KrepisFlowBlockKind.heading
          ? block.kind == KrepisFlowBlockKind.heading
                ? block.level
                : 1
          : 0,
      nestingDepth: targetIsList && sourceIsList ? block.nestingDepth : 0,
      orderedStart: targetKind == KrepisFlowBlockKind.orderedListItem
          ? block.kind == KrepisFlowBlockKind.orderedListItem
                ? block.orderedStart
                : 1
          : 0,
      taskChecked: targetKind == KrepisFlowBlockKind.taskListItem
          ? taskChecked ??
                (block.kind == KrepisFlowBlockKind.taskListItem &&
                    block.taskChecked)
          : false,
      info:
          targetKind == KrepisFlowBlockKind.codeBlock &&
              block.kind == KrepisFlowBlockKind.codeBlock
          ? block.info
          : '',
    );
  }

  final KrepisFlowBlockKind kind;
  final int level;
  final int nestingDepth;
  final int orderedStart;
  final bool taskChecked;
  final String info;
}
