import 'krepis_block.dart';
import 'krepis_editing.dart';

/// 將 stable selection 投影成 Notist 畫面需要的連續 Block 範圍。
final class NotistFlowSelectionRange {
  const NotistFlowSelectionRange({
    required this.firstPosition,
    required this.lastPosition,
    required this.firstBlockId,
    required this.lastBlockId,
  });

  factory NotistFlowSelectionRange.single(KrepisFlowBlockProjection block) {
    return NotistFlowSelectionRange(
      firstPosition: block.position,
      lastPosition: block.position,
      firstBlockId: block.id,
      lastBlockId: block.id,
    );
  }

  final int firstPosition;
  final int lastPosition;
  final String firstBlockId;
  final String lastBlockId;

  bool contains(KrepisFlowBlockProjection block) {
    return block.position >= firstPosition && block.position <= lastPosition;
  }

  KrepisFlowBlockRange get stableRange => KrepisFlowBlockRange(
    firstBlockId: firstBlockId,
    lastBlockId: lastBlockId,
  );
}

NotistFlowSelectionRange resolveNotistFlowSelectionRange(
  List<KrepisFlowBlockProjection> blocks,
  KrepisTextSelectionProjection? selection,
  KrepisFlowBlockProjection fallback,
) {
  if (selection == null) return NotistFlowSelectionRange.single(fallback);

  final anchor = blocks.indexWhere(
    (block) => block.id == selection.anchor.blockId,
  );
  final focus = blocks.indexWhere(
    (block) => block.id == selection.focus.blockId,
  );
  if (anchor < 0 || focus < 0) {
    return NotistFlowSelectionRange.single(fallback);
  }

  final firstIndex = anchor < focus ? anchor : focus;
  final lastIndex = anchor > focus ? anchor : focus;
  return NotistFlowSelectionRange(
    firstPosition: blocks[firstIndex].position,
    lastPosition: blocks[lastIndex].position,
    firstBlockId: blocks[firstIndex].id,
    lastBlockId: blocks[lastIndex].id,
  );
}
