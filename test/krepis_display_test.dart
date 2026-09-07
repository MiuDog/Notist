/// Notist 專案模組。

library;

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:notist/src/krepis/krepis_display.dart';

void main() {
  test('decodes display 1.1 filled polygon', () {
    final frame = decodeKrepisDisplay(_validPolygonFrame());

    expect(frame.token, 9);
    expect(frame.commands, hasLength(1));
    final polygon = frame.commands.single as KrepisDrawFilledPolygon;
    expect(polygon.color, 0xff336699);
    expect(polygon.vertices, hasLength(3));
    expect(polygon.vertices[0].x, 1);
    expect(polygon.vertices[0].y, 2);
    expect(polygon.vertices[2].x, 5);
    expect(polygon.vertices[2].y, 6);
  });

  test('decodes balanced nested clip and transform commands', () {
    final frame = decodeKrepisDisplay(_nestedPolygonFrame());

    expect(frame.commands, hasLength(5));
    expect(frame.commands[0], isA<KrepisPushClip>());
    expect(frame.commands[1], isA<KrepisPushTransform>());
    expect(frame.commands[2], isA<KrepisDrawFilledPolygon>());
    expect(frame.commands[3], isA<KrepisPopTransform>());
    expect(frame.commands[4], isA<KrepisPopClip>());
  });

  test('rejects truncated frame and command headers', () {
    final frame = _validPolygonFrame();
    expect(
      () => decodeKrepisDisplay(Uint8List.sublistView(frame, 0, 31)),
      throwsFormatException,
    );

    final truncated = Uint8List.sublistView(frame, 0, 36);
    ByteData.sublistView(
      truncated,
    ).setUint32(12, truncated.length, Endian.little);
    expect(() => decodeKrepisDisplay(truncated), throwsFormatException);
  });

  test('rejects truncated polygon payload', () {
    final frame = _validPolygonFrame();
    final truncated = Uint8List.sublistView(frame, 0, frame.length - 1);
    ByteData.sublistView(
      truncated,
    ).setUint32(12, truncated.length, Endian.little);

    expect(() => decodeKrepisDisplay(truncated), throwsFormatException);
  });

  test('rejects invalid polygon size and vertex count', () {
    final wrongSize = _validPolygonFrame();
    ByteData.sublistView(wrongSize).setUint32(36, 32, Endian.little);
    expect(() => decodeKrepisDisplay(wrongSize), throwsFormatException);

    final wrongCount = _validPolygonFrame();
    ByteData.sublistView(wrongCount).setUint32(44, 4, Endian.little);
    expect(() => decodeKrepisDisplay(wrongCount), throwsFormatException);

    final tooSmallCount = _validPolygonFrame();
    ByteData.sublistView(tooSmallCount).setUint32(44, 2, Endian.little);
    expect(() => decodeKrepisDisplay(tooSmallCount), throwsFormatException);
  });

  test('rejects stack underflow and unclosed stack frames', () {
    expect(
      () => decodeKrepisDisplay(_emptyCommandFrame(4)),
      throwsFormatException,
    );
    expect(
      () => decodeKrepisDisplay(_emptyCommandFrame(6)),
      throwsFormatException,
    );
    expect(
      () => decodeKrepisDisplay(_unclosedClipFrame()),
      throwsFormatException,
    );
    expect(
      () => decodeKrepisDisplay(_unclosedTransformFrame()),
      throwsFormatException,
    );
  });

  test('rejects non-finite polygon coordinates', () {
    final frame = _validPolygonFrame();
    ByteData.sublistView(frame).setFloat32(48, double.infinity, Endian.little);

    expect(() => decodeKrepisDisplay(frame), throwsFormatException);
  });

  test('rejects unsupported display versions', () {
    final unsupportedMajor = _validPolygonFrame();
    ByteData.sublistView(unsupportedMajor).setUint16(4, 2, Endian.little);
    expect(() => decodeKrepisDisplay(unsupportedMajor), throwsFormatException);

    final unsupportedMinor = _validPolygonFrame();
    ByteData.sublistView(unsupportedMinor).setUint16(6, 2, Endian.little);
    expect(() => decodeKrepisDisplay(unsupportedMinor), throwsFormatException);

    final legacyMinor = _validPolygonFrame();
    ByteData.sublistView(legacyMinor).setUint16(6, 0, Endian.little);
    expect(() => decodeKrepisDisplay(legacyMinor), throwsFormatException);
  });

  test('rejects invalid frame header invariants', () {
    final invalidMagic = _validPolygonFrame();
    ByteData.sublistView(invalidMagic).setUint32(0, 0, Endian.little);
    expect(() => decodeKrepisDisplay(invalidMagic), throwsFormatException);

    final invalidHeaderSize = _validPolygonFrame();
    ByteData.sublistView(invalidHeaderSize).setUint32(8, 24, Endian.little);
    expect(() => decodeKrepisDisplay(invalidHeaderSize), throwsFormatException);

    final invalidByteSize = _validPolygonFrame();
    ByteData.sublistView(invalidByteSize).setUint32(12, 32, Endian.little);
    expect(() => decodeKrepisDisplay(invalidByteSize), throwsFormatException);

    final invalidFlags = _validPolygonFrame();
    ByteData.sublistView(invalidFlags).setUint32(20, 1, Endian.little);
    expect(() => decodeKrepisDisplay(invalidFlags), throwsFormatException);

    final invalidToken = _validPolygonFrame();
    ByteData.sublistView(invalidToken).setUint64(24, 0, Endian.little);
    expect(() => decodeKrepisDisplay(invalidToken), throwsFormatException);

    final excessiveCount = _validPolygonFrame();
    ByteData.sublistView(excessiveCount).setUint32(16, 10000001, Endian.little);
    expect(() => decodeKrepisDisplay(excessiveCount), throwsFormatException);
  });

  test('rejects invalid command flags and alignment', () {
    final invalidFlags = _validPolygonFrame();
    ByteData.sublistView(invalidFlags).setUint16(34, 1, Endian.little);
    expect(() => decodeKrepisDisplay(invalidFlags), throwsFormatException);

    final invalidAlignment = _validPolygonFrame();
    ByteData.sublistView(invalidAlignment).setUint32(36, 41, Endian.little);
    expect(() => decodeKrepisDisplay(invalidAlignment), throwsFormatException);
  });

  test('rejects unknown display opcode', () {
    final frame = _validPolygonFrame();
    ByteData.sublistView(frame).setUint16(32, 99, Endian.little);

    expect(
      () => decodeKrepisDisplay(frame),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('未知 Krepis display opcode: 99'),
        ),
      ),
    );
  });
}

Uint8List _validPolygonFrame() {
  const commandSize = 40;
  final bytes = Uint8List(32 + commandSize);
  final data = ByteData.sublistView(bytes);
  data.setUint32(0, 0x4c44524b, Endian.little);
  data.setUint16(4, 1, Endian.little);
  data.setUint16(6, 1, Endian.little);
  data.setUint32(8, 32, Endian.little);
  data.setUint32(12, bytes.length, Endian.little);
  data.setUint32(16, 1, Endian.little);
  data.setUint64(24, 9, Endian.little);
  data.setUint16(32, 7, Endian.little);
  data.setUint32(36, commandSize, Endian.little);
  data.setUint32(40, 0xff336699, Endian.little);
  data.setUint32(44, 3, Endian.little);
  for (var index = 0; index < 6; index += 1) {
    data.setFloat32(48 + index * 4, index + 1, Endian.little);
  }
  return bytes;
}

Uint8List _nestedPolygonFrame() {
  final bytes = Uint8List(144);
  final data = ByteData.sublistView(bytes);
  _writeFrameHeader(data, bytes.length, 5);
  _writeCommandHeader(data, 32, 3, 24);
  data.setFloat32(48, 300, Endian.little);
  data.setFloat32(52, 300, Endian.little);
  _writeCommandHeader(data, 56, 5, 32);
  data.setFloat32(64, 1, Endian.little);
  data.setFloat32(76, 1, Endian.little);
  _writeCommandHeader(data, 88, 7, 40);
  data.setUint32(96, 0xff336699, Endian.little);
  data.setUint32(100, 3, Endian.little);
  for (var index = 0; index < 6; index += 1) {
    data.setFloat32(104 + index * 4, index + 1, Endian.little);
  }
  _writeCommandHeader(data, 128, 6, 8);
  _writeCommandHeader(data, 136, 4, 8);
  return bytes;
}

Uint8List _emptyCommandFrame(int opcode) {
  final bytes = Uint8List(40);
  final data = ByteData.sublistView(bytes);
  _writeFrameHeader(data, bytes.length, 1);
  _writeCommandHeader(data, 32, opcode, 8);
  return bytes;
}

Uint8List _unclosedClipFrame() {
  final bytes = Uint8List(56);
  final data = ByteData.sublistView(bytes);
  _writeFrameHeader(data, bytes.length, 1);
  _writeCommandHeader(data, 32, 3, 24);
  data.setFloat32(48, 10, Endian.little);
  data.setFloat32(52, 10, Endian.little);
  return bytes;
}

Uint8List _unclosedTransformFrame() {
  final bytes = Uint8List(64);
  final data = ByteData.sublistView(bytes);
  _writeFrameHeader(data, bytes.length, 1);
  _writeCommandHeader(data, 32, 5, 32);
  data.setFloat32(40, 1, Endian.little);
  data.setFloat32(52, 1, Endian.little);
  return bytes;
}

void _writeFrameHeader(ByteData data, int byteSize, int commandCount) {
  data.setUint32(0, 0x4c44524b, Endian.little);
  data.setUint16(4, 1, Endian.little);
  data.setUint16(6, 1, Endian.little);
  data.setUint32(8, 32, Endian.little);
  data.setUint32(12, byteSize, Endian.little);
  data.setUint32(16, commandCount, Endian.little);
  data.setUint64(24, 9, Endian.little);
}

void _writeCommandHeader(ByteData data, int offset, int opcode, int size) {
  data.setUint16(offset, opcode, Endian.little);
  data.setUint32(offset + 4, size, Endian.little);
}
