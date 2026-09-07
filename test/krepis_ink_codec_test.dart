/// Notist 專案模組。

library;

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:notist/src/krepis/krepis_ink.dart';
import 'package:notist/src/krepis/krepis_ink_codec.dart';

void main() {
  test('encodes the documented packed 9-byte preview sample', () {
    final encoded = encodeKrepisInkPreviewSamples(const [
      KrepisInkPreviewSampleProjection(
        xNormalized: 0x1234,
        yFixed: -2,
        pressure: 3,
        tiltAltitude: 4,
        tiltAzimuth: 5,
        dtMs: 0x6789,
      ),
    ]);

    expect(
      encoded,
      Uint8List.fromList([0x34, 0x12, 0xfe, 0xff, 3, 4, 5, 0x89, 0x67]),
    );
  });

  test('rejects malformed stable Ink owner IDs', () {
    expect(() => parseKrepisStableId('not-an-id'), throwsFormatException);
  });
}
