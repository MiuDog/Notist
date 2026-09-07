/// Notist 專案模組。

library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:notist/src/markdown/notist_markdown_file_source.dart';

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('notist-md-source-');
  });

  tearDown(() async {
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  test('reads Unicode Markdown without changing source bytes', () async {
    final file = File('${directory.path}${Platform.pathSeparator}研究.md');
    final original = utf8.encode('# 標題\n內容');
    await file.writeAsBytes(original);

    final source = await NotistMarkdownFileSourceReader.read(file.path);

    expect(source.title, '研究');
    expect(source.markdown, '# 標題\n內容');
    expect(await file.readAsBytes(), original);
  });

  test('rejects non Markdown, malformed UTF-8 and oversized sources', () async {
    final text = File('${directory.path}${Platform.pathSeparator}note.txt');
    await text.writeAsString('text');
    final malformed = File('${directory.path}${Platform.pathSeparator}bad.md');
    await malformed.writeAsBytes([0xC3, 0x28]);
    final oversized = File('${directory.path}${Platform.pathSeparator}huge.md');
    await oversized.writeAsBytes(
      List.filled(NotistMarkdownFileSourceReader.maxByteCount + 1, 0),
    );

    await expectLater(
      NotistMarkdownFileSourceReader.read(text.path),
      throwsArgumentError,
    );
    await expectLater(
      NotistMarkdownFileSourceReader.read(malformed.path),
      throwsFormatException,
    );
    await expectLater(
      NotistMarkdownFileSourceReader.read(oversized.path),
      throwsA(isA<FileSystemException>()),
    );
  });
}
