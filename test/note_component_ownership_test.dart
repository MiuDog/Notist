import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:notist/notist.dart';

void main() {
  test('筆記語意元件由 Notist 以 Nts 前綴提供', () {
    expect(NtsBlock, isNotNull);
    expect(NtsBlockCanvas, isNotNull);
    expect(NtsPageBackground, isNotNull);
    expect(NtsPageBackgroundEditor, isNotNull);
    expect(NtsSheetGrid, isNotNull);
  });

  test('NtsBlock 不自行定義互動狀態風格', () {
    final source = File('lib/src/note/nts_block.dart').readAsStringSync();

    for (final forbidden in [
      'selectionWash',
      'selectedWash',
      'withValues(alpha:',
      'KlpSurfaceTone.component',
      'nts-block-highlight',
    ]) {
      expect(
        source,
        isNot(contains(forbidden)),
        reason: 'Notist 不應使用 $forbidden 撰寫狀態風格',
      );
    }
    expect(source, contains('KlpPressable('));
  });
}
