/// Notist 專案模組。

library;

import 'package:flutter/widgets.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/src/krepis/krepis_block.dart';
import 'package:notist/src/krepis/notist_semantic_block_projection.dart';

void main() {
  Future<void> pumpProjection(
    WidgetTester tester,
    KrepisFlowBlockProjection block,
  ) {
    return tester.pumpWidget(
      KlpApp(
        showWindowHeader: false,
        home: KlpPanelFrame(
          content: Center(child: NotistSemanticBlockProjection(block: block)),
        ),
      ),
    );
  }

  testWidgets('comment projection hides source content', (tester) async {
    await pumpProjection(
      tester,
      const KrepisFlowBlockProjection(
        position: 0,
        id: 'comment',
        kind: KrepisFlowBlockKind.comment,
        level: 0,
        nestingDepth: 0,
        orderedStart: 0,
        taskChecked: false,
        text: '<!-- secret -->',
        info: '',
        marks: [],
      ),
    );

    expect(find.text('註解'), findsOneWidget);
    expect(find.textContaining('secret'), findsNothing);
  });

  testWidgets('display and Unicode inline math use real math widgets', (
    tester,
  ) async {
    await pumpProjection(
      tester,
      const KrepisFlowBlockProjection(
        position: 0,
        id: 'display-math',
        kind: KrepisFlowBlockKind.mathBlock,
        level: 0,
        nestingDepth: 0,
        orderedStart: 0,
        taskChecked: false,
        text: r'$$x^2$$',
        info: '',
        marks: [],
      ),
    );
    expect(find.byType(Math), findsOneWidget);

    await pumpProjection(
      tester,
      const KrepisFlowBlockProjection(
        position: 0,
        id: 'inline-math',
        kind: KrepisFlowBlockKind.paragraph,
        level: 0,
        nestingDepth: 0,
        orderedStart: 0,
        taskChecked: false,
        text: r'值為 $α$',
        info: '',
        marks: [
          KrepisInlineMarkProjection(
            kind: KrepisInlineMarkKind.math,
            beginByte: 8,
            endByte: 10,
            metadata: '',
          ),
        ],
      ),
    );
    expect(find.byType(Math), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
