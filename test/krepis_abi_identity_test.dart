/// Notist 專案模組。

library;

import 'dart:ffi' as ffi;

import 'package:flutter_test/flutter_test.dart';
import 'package:notist/src/krepis/krepis_block.dart';
import 'package:notist/src/krepis/krepis_native.dart';

void main() {
  test('formats both root halves as unsigned fixed-width hexadecimal', () {
    final identity = formatKrepisRootId(-1, -9223372036854775808);

    expect(identity, 'ffffffffffffffff8000000000000000');
    expect(identity.length, 32);
  });

  test('preserves leading zeroes in the 128-bit root identity', () {
    expect(formatKrepisRootId(0x12, 0x34), '00000000000000120000000000000034');
  });

  test('requires the additive Flow projection ABI minor', () {
    expect(KrepisNative.requiredAbiMajor, 1);
    expect(KrepisNative.requiredAbiMinor, 11);
    expect(ffi.sizeOf<KrepisFlowDocumentInfo>(), 24);
    expect(ffi.sizeOf<KrepisMarkdownImportResultNative>(), 24);
  });
}
