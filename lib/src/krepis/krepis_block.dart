String formatKrepisRootId(int high, int low) {
  final unsignedHigh = BigInt.from(high).toUnsigned(64);
  final unsignedLow = BigInt.from(low).toUnsigned(64);
  return '${unsignedHigh.toRadixString(16).padLeft(16, '0')}'
      '${unsignedLow.toRadixString(16).padLeft(16, '0')}';
}

enum KrepisFlowBlockKind {
  paragraph,
  heading,
  unorderedListItem,
  orderedListItem,
  taskListItem,
  blockQuote,
  codeBlock,
  thematicBreak;

  static KrepisFlowBlockKind fromAbi(int value) {
    if (value < 0 || value >= values.length) {
      throw StateError('Krepis 回傳未知 Flow Block kind：$value');
    }

    return values[value];
  }

  int get abiValue => index;
}

enum KrepisInlineMarkKind {
  emphasis,
  strong,
  strikethrough,
  code,
  link;

  static KrepisInlineMarkKind fromAbi(int value) {
    if (value < 0 || value >= values.length) {
      throw StateError('Krepis 回傳未知 inline mark kind：$value');
    }

    return values[value];
  }

  int get abiValue => index;
}

final class KrepisInlineMarkProjection {
  const KrepisInlineMarkProjection({
    required this.kind,
    required this.beginByte,
    required this.endByte,
    required this.metadata,
  });

  final KrepisInlineMarkKind kind;
  final int beginByte;
  final int endByte;
  final String metadata;
}

final class KrepisFlowBlockProjection {
  const KrepisFlowBlockProjection({
    required this.position,
    required this.id,
    required this.kind,
    required this.level,
    required this.nestingDepth,
    required this.orderedStart,
    required this.taskChecked,
    required this.text,
    required this.info,
    required this.marks,
  });

  final int position;
  final String id;
  final KrepisFlowBlockKind kind;
  final int level;
  final int nestingDepth;
  final int orderedStart;
  final bool taskChecked;
  final String text;
  final String info;
  final List<KrepisInlineMarkProjection> marks;

  KrepisFlowBlockDraft toDraft() {
    return KrepisFlowBlockDraft(
      kind: kind,
      text: text,
      level: level,
      nestingDepth: nestingDepth,
      orderedStart: orderedStart,
      taskChecked: taskChecked,
      info: info,
      marks: [
        for (final mark in marks)
          KrepisInlineMarkDraft(
            kind: mark.kind,
            beginByte: mark.beginByte,
            endByte: mark.endByte,
            metadata: mark.metadata,
          ),
      ],
    );
  }
}

final class KrepisFlowBlockRect {
  const KrepisFlowBlockRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final double x;
  final double y;
  final double width;
  final double height;
}

final class KrepisInlineMarkDraft {
  const KrepisInlineMarkDraft({
    required this.kind,
    required this.beginByte,
    required this.endByte,
    this.metadata = '',
  });

  final KrepisInlineMarkKind kind;
  final int beginByte;
  final int endByte;
  final String metadata;
}

final class KrepisFlowBlockDraft {
  const KrepisFlowBlockDraft({
    required this.kind,
    required this.text,
    this.level = 0,
    this.nestingDepth = 0,
    this.orderedStart = 0,
    this.taskChecked = false,
    this.info = '',
    this.marks = const [],
  });

  final KrepisFlowBlockKind kind;
  final String text;
  final int level;
  final int nestingDepth;
  final int orderedStart;
  final bool taskChecked;
  final String info;
  final List<KrepisInlineMarkDraft> marks;
}
