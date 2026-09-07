/// Notist 專案模組。

library;

import 'package:flutter_test/flutter_test.dart';
import 'package:notist/src/krepis/text_edit_diff.dart';

void main() {
  test('simple insertion is a collapsed replacement', () {
    final range = findTextReplacement('AB', 'ABZ');

    expect(range.prefix, 2);
    expect(range.oldEnd, 2);
    expect(range.newEnd, 3);
  });

  test('surrogate pair replacement never splits the emoji', () {
    final range = findTextReplacement('A😀B', 'A😁B');

    expect(range.prefix, 1);
    expect(range.oldEnd, 3);
    expect(range.newEnd, 3);
  });

  test('combining mark edit expands to the whole grapheme cluster', () {
    final range = findTextReplacement('Cafe', 'Cafe\u0301');

    expect(range.prefix, 3);
    expect(range.oldEnd, 4);
    expect(range.newEnd, 5);
  });
}
