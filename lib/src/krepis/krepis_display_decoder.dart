/// Notist 專案模組。

part of 'krepis_display.dart';

const _displayMagic = 0x4c44524b;
const _supportedDisplayMajor = 1;
const _supportedDisplayMinor = 1;
const _frameHeaderSize = 32;
const _commandHeaderSize = 8;
const _maximumFrameBytes = 256 * 1024 * 1024;
const _maximumCommands = 10000000;
const _maximumGlyphs = 10000000;
const _maximumPolygonVertices =
    (_maximumFrameBytes - _commandHeaderSize - 8) ~/ 8;

final class _KrepisDisplayDecoder {
  _KrepisDisplayDecoder(this.bytes) : data = ByteData.sublistView(bytes);

  final Uint8List bytes;
  final ByteData data;
  late final int minor;
  var _clipDepth = 0;
  var _transformDepth = 0;

  KrepisDisplayFrame decode() {
    _validateFrameHeader();
    final count = data.getUint32(16, Endian.little);
    final token = data.getUint64(24, Endian.little);
    final commands = <KrepisDisplayCommand>[];
    var offset = _frameHeaderSize;
    for (var index = 0; index < count; index += 1) {
      _requireAvailable(
        offset,
        _commandHeaderSize,
        'Krepis display command header 截斷',
      );
      final opcode = data.getUint16(offset, Endian.little);
      final flags = data.getUint16(offset + 2, Endian.little);
      final size = data.getUint32(offset + 4, Endian.little);
      if (flags != 0 || size < _commandHeaderSize || size % 8 != 0) {
        throw const FormatException('Krepis display command header 不合法');
      }
      _requireAvailable(offset, size, 'Krepis display command payload 截斷');
      commands.add(_decodeCommand(opcode, offset, size));
      offset += size;
    }
    if (offset != bytes.length || _clipDepth != 0 || _transformDepth != 0) {
      throw const FormatException('Krepis display command 數量、長度或 stack 不平衡');
    }
    return KrepisDisplayFrame(token, List.unmodifiable(commands));
  }

  void _validateFrameHeader() {
    if (bytes.length < _frameHeaderSize || bytes.length > _maximumFrameBytes) {
      throw const FormatException('Krepis display frame 大小不合法');
    }
    final magic = data.getUint32(0, Endian.little);
    final major = data.getUint16(4, Endian.little);
    minor = data.getUint16(6, Endian.little);
    final headerSize = data.getUint32(8, Endian.little);
    final byteSize = data.getUint32(12, Endian.little);
    final count = data.getUint32(16, Endian.little);
    final flags = data.getUint32(20, Endian.little);
    final token = data.getUint64(24, Endian.little);
    if (magic != _displayMagic ||
        headerSize != _frameHeaderSize ||
        byteSize != bytes.length ||
        count > _maximumCommands ||
        flags != 0 ||
        token == 0) {
      throw const FormatException('Krepis display header invariant 失敗');
    }
    if (major != _supportedDisplayMajor || minor > _supportedDisplayMinor) {
      throw FormatException('Krepis display 版本不支援: $major.$minor');
    }
  }

  KrepisDisplayCommand _decodeCommand(int opcode, int offset, int size) {
    final payload = offset + _commandHeaderSize;
    return switch (opcode) {
      1 => _decodeRect(payload, size),
      2 => _decodeGlyphRun(payload, size),
      3 => _decodeClip(payload, size),
      4 => _decodePopClip(size),
      5 => _decodeTransform(payload, size),
      6 => _decodePopTransform(size),
      7 => _decodeFilledPolygon(payload, size),
      _ => throw FormatException('未知 Krepis display opcode: $opcode'),
    };
  }

  KrepisDrawRect _decodeRect(int payload, int size) {
    if (size != 32) throw const FormatException('DrawRect size 不合法');
    final values = _readFiniteFloats(payload, 4, 'DrawRect');
    if (values[2] < 0 || values[3] < 0) {
      throw const FormatException('DrawRect 尺寸不合法');
    }
    _requireZeroPadding(payload + 20, payload + 24, 'DrawRect');
    return KrepisDrawRect(
      values[0],
      values[1],
      values[2],
      values[3],
      data.getUint32(payload + 16, Endian.little),
    );
  }

  KrepisDrawGlyphRun _decodeGlyphRun(int payload, int size) {
    if (size < 40) throw const FormatException('DrawGlyphRun size 不合法');
    final fontId = data.getUint64(payload, Endian.little);
    final fontSize = data.getInt32(payload + 16, Endian.little);
    final glyphCount = data.getUint32(payload + 24, Endian.little);
    final direction = data.getUint32(payload + 28, Endian.little);
    if (fontId == 0 ||
        fontSize <= 0 ||
        glyphCount == 0 ||
        glyphCount > _maximumGlyphs ||
        direction > 1 ||
        glyphCount > (0xffffffff - 40) ~/ 24 ||
        size != 40 + glyphCount * 24) {
      throw const FormatException('DrawGlyphRun payload 不合法');
    }
    final glyphs = <KrepisGlyph>[];
    var offset = payload + 32;
    for (var index = 0; index < glyphCount; index += 1) {
      glyphs.add(
        KrepisGlyph(
          id: data.getUint32(offset, Endian.little),
          xAdvance: data.getInt32(offset + 4, Endian.little),
          yAdvance: data.getInt32(offset + 8, Endian.little),
          xOffset: data.getInt32(offset + 12, Endian.little),
          yOffset: data.getInt32(offset + 16, Endian.little),
        ),
      );
      offset += 24;
    }
    return KrepisDrawGlyphRun(
      fontId: fontId,
      baselineX: data.getInt32(payload + 8, Endian.little),
      baselineY: data.getInt32(payload + 12, Endian.little),
      fontSize: fontSize,
      color: data.getUint32(payload + 20, Endian.little),
      glyphs: List.unmodifiable(glyphs),
    );
  }

  KrepisPushClip _decodeClip(int payload, int size) {
    if (size != 24) throw const FormatException('PushClip size 不合法');
    final values = _readFiniteFloats(payload, 4, 'PushClip');
    if (values[2] < 0 || values[3] < 0) {
      throw const FormatException('PushClip 尺寸不合法');
    }
    _clipDepth += 1;
    return KrepisPushClip(values[0], values[1], values[2], values[3]);
  }

  KrepisPopClip _decodePopClip(int size) {
    if (size != 8 || _clipDepth == 0) {
      throw const FormatException('PopClip size 不合法或 stack underflow');
    }
    _clipDepth -= 1;
    return const KrepisPopClip();
  }

  KrepisPushTransform _decodeTransform(int payload, int size) {
    if (size != 32) {
      throw const FormatException('PushTransform size 不合法');
    }
    _transformDepth += 1;
    return KrepisPushTransform(
      List.unmodifiable(_readFiniteFloats(payload, 6, 'PushTransform')),
    );
  }

  KrepisPopTransform _decodePopTransform(int size) {
    if (size != 8 || _transformDepth == 0) {
      throw const FormatException('PopTransform size 不合法或 stack underflow');
    }
    _transformDepth -= 1;
    return const KrepisPopTransform();
  }

  KrepisDrawFilledPolygon _decodeFilledPolygon(int payload, int size) {
    if (minor < 1 || size < 40) {
      throw const FormatException('DrawFilledPolygon size 或版本不合法');
    }
    final vertexCount = data.getUint32(payload + 4, Endian.little);
    if (vertexCount < 3 ||
        vertexCount > _maximumPolygonVertices ||
        vertexCount > (0xffffffff - 16) ~/ 8 ||
        size != 16 + vertexCount * 8) {
      throw const FormatException('DrawFilledPolygon vertex 數量不合法');
    }
    final vertices = <KrepisDisplayPoint>[];
    var offset = payload + 8;
    for (var index = 0; index < vertexCount; index += 1) {
      final values = _readFiniteFloats(offset, 2, 'DrawFilledPolygon');
      vertices.add(KrepisDisplayPoint(values[0], values[1]));
      offset += 8;
    }
    return KrepisDrawFilledPolygon(
      data.getUint32(payload, Endian.little),
      List.unmodifiable(vertices),
    );
  }

  List<double> _readFiniteFloats(int offset, int count, String label) {
    final values = <double>[];
    for (var index = 0; index < count; index += 1) {
      final value = data.getFloat32(offset + index * 4, Endian.little);
      if (!value.isFinite) throw FormatException('$label 包含非 finite 數值');
      values.add(value);
    }
    return values;
  }

  void _requireAvailable(int offset, int size, String message) {
    if (offset < 0 ||
        size < 0 ||
        offset > bytes.length ||
        size > bytes.length - offset) {
      throw FormatException(message);
    }
  }

  void _requireZeroPadding(int start, int end, String label) {
    for (var offset = start; offset < end; offset += 1) {
      if (bytes[offset] != 0) throw FormatException('$label padding 非零');
    }
  }
}
