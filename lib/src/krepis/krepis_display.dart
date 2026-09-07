/// Notist 專案模組。

library;

import 'dart:typed_data';

part 'krepis_display_decoder.dart';

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

final class KrepisDisplayPoint {
  const KrepisDisplayPoint(this.x, this.y);

  final double x;
  final double y;
}

final class KrepisDrawFilledPolygon extends KrepisDisplayCommand {
  const KrepisDrawFilledPolygon(this.color, this.vertices);

  final int color;
  final List<KrepisDisplayPoint> vertices;
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

KrepisDisplayFrame decodeKrepisDisplay(Uint8List bytes) =>
    _KrepisDisplayDecoder(bytes).decode();
