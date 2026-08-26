import 'package:flutter_test/flutter_test.dart';
import 'package:notist/src/krepis/krepis_block.dart';
import 'package:notist/src/krepis/krepis_editing.dart';
import 'package:notist/src/krepis/notist_flow_selection.dart';

void main() {
  const blocks = [
    KrepisFlowBlockProjection(
      position: 0,
      id: '00000000000000000000000000000001',
      kind: KrepisFlowBlockKind.paragraph,
      level: 0,
      nestingDepth: 0,
      orderedStart: 0,
      taskChecked: false,
      text: 'A',
      info: '',
      marks: [],
    ),
    KrepisFlowBlockProjection(
      position: 1,
      id: '00000000000000000000000000000002',
      kind: KrepisFlowBlockKind.paragraph,
      level: 0,
      nestingDepth: 0,
      orderedStart: 0,
      taskChecked: false,
      text: 'B',
      info: '',
      marks: [],
    ),
    KrepisFlowBlockProjection(
      position: 2,
      id: '00000000000000000000000000000003',
      kind: KrepisFlowBlockKind.paragraph,
      level: 0,
      nestingDepth: 0,
      orderedStart: 0,
      taskChecked: false,
      text: 'C',
      info: '',
      marks: [],
    ),
  ];

  test('resolves reverse stable selection into an ordered Block range', () {
    const selection = KrepisTextSelectionProjection(
      contentRevision: 4,
      anchor: KrepisTextEndpointProjection(
        blockId: '00000000000000000000000000000003',
        graphemeBoundary: 1,
        affinity: KrepisTextAffinity.downstream,
      ),
      focus: KrepisTextEndpointProjection(
        blockId: '00000000000000000000000000000001',
        graphemeBoundary: 0,
        affinity: KrepisTextAffinity.upstream,
      ),
    );

    final range = resolveNotistFlowSelectionRange(blocks, selection, blocks[1]);

    expect(range.firstBlockId, blocks.first.id);
    expect(range.lastBlockId, blocks.last.id);
    expect(blocks.every(range.contains), isTrue);
  });

  test('falls back to the current Block when stable IDs are stale', () {
    const selection = KrepisTextSelectionProjection(
      contentRevision: 4,
      anchor: KrepisTextEndpointProjection(
        blockId: 'ffffffffffffffffffffffffffffffff',
        graphemeBoundary: 0,
        affinity: KrepisTextAffinity.downstream,
      ),
      focus: KrepisTextEndpointProjection(
        blockId: 'ffffffffffffffffffffffffffffffff',
        graphemeBoundary: 0,
        affinity: KrepisTextAffinity.downstream,
      ),
    );

    final range = resolveNotistFlowSelectionRange(blocks, selection, blocks[1]);

    expect(range.firstBlockId, blocks[1].id);
    expect(range.lastBlockId, blocks[1].id);
  });
}
