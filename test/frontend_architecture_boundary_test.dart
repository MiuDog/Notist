import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Iterable<File> _dartFiles(Directory root) {
  // 同時掃描產品程式與測試，避免測試以私有 API 建立錯誤契約。
  return root
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}

String _relativePath(File file) => file.path.replaceAll(r'\', '/');

void main() {
  test('Notist imports Kallopis only through public libraries', () {
    final currentTest = _relativePath(
      File('test/frontend_architecture_boundary_test.dart'),
    );
    final sources = <File>[
      ..._dartFiles(Directory('lib')),
      ..._dartFiles(Directory('test')),
    ];
    final privateImport = RegExp(
      "(?:import|export)\\s+['\"]package:kallopis/src/",
    );
    final violations = <String>[];

    for (final file in sources) {
      final path = _relativePath(file);
      if (path == currentTest) continue;
      if (privateImport.hasMatch(file.readAsStringSync())) violations.add(path);
    }

    expect(
      violations,
      isEmpty,
      reason:
          'lib/src 是 Kallopis 私有實作；Notist 只能使用公開入口：\n'
          '${violations.join('\n')}',
    );
  });

  test('product components name their public responsibility libraries', () {
    final unstableImport = RegExp(
      "import\\s+['\"]package:kallopis/(?:kallopis\\.dart|src/)",
    );
    final violations = <String>[];

    for (final file in _dartFiles(Directory('lib/src/components'))) {
      if (unstableImport.hasMatch(file.readAsStringSync())) {
        violations.add(_relativePath(file));
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          '產品元件必須明列 foundation、theme 或 experimental，不能依賴總入口：\n'
          '${violations.join('\n')}',
    );
  });
}
