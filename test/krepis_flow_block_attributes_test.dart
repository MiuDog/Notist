import 'package:flutter_test/flutter_test.dart';
import 'package:notist/src/krepis/krepis_block.dart';
import 'package:notist/src/krepis/krepis_editing.dart';

void main() {
  const heading = KrepisFlowBlockProjection(
    position: 0,
    id: '00000000000000000000000000000001',
    kind: KrepisFlowBlockKind.heading,
    level: 2,
    nestingDepth: 0,
    orderedStart: 0,
    taskChecked: false,
    text: 'Title',
    info: '',
    marks: [],
  );
  const ordered = KrepisFlowBlockProjection(
    position: 1,
    id: '00000000000000000000000000000002',
    kind: KrepisFlowBlockKind.orderedListItem,
    level: 0,
    nestingDepth: 3,
    orderedStart: 4,
    taskChecked: false,
    text: 'Item',
    info: '',
    marks: [],
  );

  test('clears source-only attributes when converting kind', () {
    final quote = KrepisFlowBlockAttributes.fromBlock(
      heading,
      kind: KrepisFlowBlockKind.blockQuote,
    );

    expect(quote.level, 0);
    expect(quote.nestingDepth, 0);
    expect(quote.orderedStart, 0);
    expect(quote.taskChecked, isFalse);
    expect(quote.info, isEmpty);
  });

  test('supplies valid defaults and preserves shared list attributes', () {
    final task = KrepisFlowBlockAttributes.fromBlock(
      ordered,
      kind: KrepisFlowBlockKind.taskListItem,
    );
    final headingAttributes = KrepisFlowBlockAttributes.fromBlock(
      ordered,
      kind: KrepisFlowBlockKind.heading,
    );

    expect(task.nestingDepth, 3);
    expect(task.orderedStart, 0);
    expect(task.taskChecked, isFalse);
    expect(headingAttributes.level, 1);
  });

  test('ordered conversion defaults start to one', () {
    final attributes = KrepisFlowBlockAttributes.fromBlock(
      heading,
      kind: KrepisFlowBlockKind.orderedListItem,
    );

    expect(attributes.orderedStart, 1);
  });
}
