import 'dart:typed_data';

sealed class KrepisDisplayCommand {
  const KrepisDisplayCommand();
}

final class KrepisDrawRect extends KrepisDisplayCommand {
  const KrepisDrawRect(this.x, this.y, this.width, this.height, this.color);

  final double x;
  final double y;
  final double width;
  final double height;
  final int color;
}

final class KrepisGlyph {
  const KrepisGlyph({
    required this.id,
    required this.xAdvance,
    required this.yAdvance,
    required this.xOffset,
    required this.yOffset,
  });

  final int id;
  final int xAdvance;
  final int yAdvance;
  final int xOffset;
  final int yOffset;
}

final class KrepisDrawGlyphRun extends KrepisDisplayCommand {
  const KrepisDrawGlyphRun({
    required this.fontId,
    required this.baselineX,
    required this.baselineY,
    required this.fontSize,
    required this.color,
    required this.glyphs,
  });

  final int fontId;
  final int baselineX;
  final int baselineY;
  final int fontSize;
  final int color;
  final List<KrepisGlyph> glyphs;
}

final class KrepisPushClip extends KrepisDisplayCommand {
  const KrepisPushClip(this.x, this.y, this.width, this.height);

  final double x;
  final double y;
  final double width;
  final double height;
}

final class KrepisPopClip extends KrepisDisplayCommand {
  const KrepisPopClip();
}

final class KrepisPushTransform extends KrepisDisplayCommand {
  const KrepisPushTransform(this.affine);

  final List<double> affine;
}

final class KrepisPopTransform extends KrepisDisplayCommand {
  const KrepisPopTransform();
}

final class KrepisDisplayFrame {
  const KrepisDisplayFrame(this.token, this.commands);

  final int token;
  final List<KrepisDisplayCommand> commands;
}

/// 解碼前 bytes 已由 Krepis checked decoder 驗證；這裡只轉成 Flutter 可繪製的值。
KrepisDisplayFrame decodeKrepisDisplay(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  if (bytes.length < 32 || data.getUint32(0, Endian.little) != 0x4c44524b) {
    throw const FormatException('Krepis display header 不合法');
  }
  final count = data.getUint32(16, Endian.little);
  final token = data.getUint64(24, Endian.little);
  final commands = <KrepisDisplayCommand>[];
  var offset = 32;
  for (var index = 0; index < count; index += 1) {
    final opcode = data.getUint16(offset, Endian.little);
    final size = data.getUint32(offset + 4, Endian.little);
    final payload = offset + 8;
    commands.add(switch (opcode) {
      1 => KrepisDrawRect(
        data.getFloat32(payload, Endian.little),
        data.getFloat32(payload + 4, Endian.little),
        data.getFloat32(payload + 8, Endian.little),
        data.getFloat32(payload + 12, Endian.little),
        data.getUint32(payload + 16, Endian.little),
      ),
      2 => _decodeGlyphRun(data, payload),
      3 => KrepisPushClip(
        data.getFloat32(payload, Endian.little),
        data.getFloat32(payload + 4, Endian.little),
        data.getFloat32(payload + 8, Endian.little),
        data.getFloat32(payload + 12, Endian.little),
      ),
      4 => const KrepisPopClip(),
      5 => KrepisPushTransform([
        for (var value = 0; value < 6; value += 1)
          data.getFloat32(payload + value * 4, Endian.little),
      ]),
      6 => const KrepisPopTransform(),
      _ => throw FormatException('未知 Krepis display opcode: $opcode'),
    });
    offset += size;
  }
  if (offset != bytes.length) {
    throw const FormatException('Krepis display command 長度不一致');
  }
  return KrepisDisplayFrame(token, List.unmodifiable(commands));
}

KrepisDrawGlyphRun _decodeGlyphRun(ByteData data, int payload) {
  final glyphCount = data.getUint32(payload + 24, Endian.little);
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
    fontId: data.getUint64(payload, Endian.little),
    baselineX: data.getInt32(payload + 8, Endian.little),
    baselineY: data.getInt32(payload + 12, Endian.little),
    fontSize: data.getInt32(payload + 16, Endian.little),
    color: data.getUint32(payload + 20, Endian.little),
    glyphs: List.unmodifiable(glyphs),
  );
}
