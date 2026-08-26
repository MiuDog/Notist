import 'dart:ffi' as ffi;

import 'package:flutter_test/flutter_test.dart';
import 'package:notist/src/krepis/krepis_block.dart';
import 'package:notist/src/krepis/krepis_native.dart';

void main() {
  test('matches the Krepis ABI 1.3 fixed-width Block layouts', () {
    expect(ffi.sizeOf<KrepisInlineMarkInput>(), 40);
    expect(ffi.sizeOf<KrepisFlowBlockInput>(), 80);
    expect(ffi.sizeOf<KrepisFlowBlockInfo>(), 72);
    expect(ffi.sizeOf<KrepisInlineMarkInfo>(), 32);
  });

  test('maps every provider Block and inline mark kind without fallback', () {
    expect(
      List.generate(8, KrepisFlowBlockKind.fromAbi),
      KrepisFlowBlockKind.values,
    );
    expect(
      List.generate(5, KrepisInlineMarkKind.fromAbi),
      KrepisInlineMarkKind.values,
    );
    expect(() => KrepisFlowBlockKind.fromAbi(8), throwsStateError);
    expect(() => KrepisInlineMarkKind.fromAbi(5), throwsStateError);
  });

  test('keeps Block projection semantic fields immutable', () {
    const mark = KrepisInlineMarkProjection(
      kind: KrepisInlineMarkKind.strong,
      beginByte: 0,
      endByte: 6,
      metadata: '',
    );
    const block = KrepisFlowBlockProjection(
      position: 2,
      id: '00000000000000010000000000000002',
      kind: KrepisFlowBlockKind.heading,
      level: 2,
      nestingDepth: 0,
      orderedStart: 0,
      taskChecked: false,
      text: '規格',
      info: '',
      marks: [mark],
    );

    expect(block.position, 2);
    expect(block.id, '00000000000000010000000000000002');
    expect(block.kind, KrepisFlowBlockKind.heading);
    expect(block.level, 2);
    expect(block.marks, const [mark]);
  });
}
