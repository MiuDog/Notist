import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:notist/src/components/note/note_components.dart';

void main() {
  test('筆記元件由 Notist component 層提供', () {
    expect(NotistNoteBlock, isNotNull);
    expect(NotistNoteBlockCanvas, isNotNull);
    expect(NotistNoteBlockChrome, isNotNull);
    expect(NotistNoteCommentPlaceholder, isNotNull);
    expect(NotistNoteFileExplorer, isNotNull);
    expect(NotistNoteIdentityHeader, isNotNull);
    expect(NotistNoteInkPreview, isNotNull);
    expect(NotistNoteMathHost, isNotNull);
    expect(NotistNoteNavigationButton, isNotNull);
    expect(NotistNoteNavigationGroup, isNotNull);
    expect(NotistNotePrimarySidebarFrame, isNotNull);
    expect(NotistNoteVisualStyle, isNotNull);
    expect(NotistSheetGrid, isNotNull);
    expect(Directory('lib/src/note').existsSync(), isFalse);
  });

  test('筆記元件只透過 Kallopis 公開入口取得視覺能力', () {
    final directory = Directory('lib/src/components/note');
    final offenders = <String>[];

    for (final entity in directory.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      final source = entity.readAsStringSync();
      if (source.contains('package:kallopis/src/') ||
          source.contains('KlpNote') ||
          source.contains('KlpSheetGrid')) {
        offenders.add(entity.path.replaceAll(r'\', '/'));
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Notist 筆記元件不得依賴 Kallopis 私有路徑或保留已移除的筆記型別：\n${offenders.join('\n')}',
    );
  });

  test('筆記元件維持小檔與 tab 縮排', () {
    final directory = Directory('lib/src/components/note');
    final oversized = <String>[];
    final spaceIndented = <String>[];

    for (final entity in directory.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      final path = entity.path.replaceAll(r'\', '/');
      final lines = entity.readAsLinesSync();
      if (lines.length > 200) oversized.add('$path: ${lines.length}');
      for (var index = 0; index < lines.length; index++) {
        if (RegExp(r'^ +\S').hasMatch(lines[index])) {
          spaceIndented.add('$path:${index + 1}');
        }
      }
    }

    expect(
      oversized,
      isEmpty,
      reason: '筆記元件單檔不得超過 200 行：\n${oversized.join('\n')}',
    );
    expect(
      spaceIndented,
      isEmpty,
      reason: '筆記元件行首必須使用 tab：\n${spaceIndented.join('\n')}',
    );
  });
}
