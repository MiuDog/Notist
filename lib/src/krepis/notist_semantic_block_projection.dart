/// Notist 專案模組。

library;

import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../components/note/notist_note_comment_placeholder.dart';
import '../components/note/notist_note_math_host.dart';
import 'krepis_block.dart';

/// 將 Krepis 語意資料投影成通用 Flutter 視覺；不保存或回寫文件狀態。
final class NotistSemanticBlockProjection extends StatelessWidget {
  const NotistSemanticBlockProjection({super.key, required this.block});

  final KrepisFlowBlockProjection block;

  static bool supports(KrepisFlowBlockProjection block) {
    return block.kind == KrepisFlowBlockKind.comment ||
        block.kind == KrepisFlowBlockKind.mathBlock ||
        block.marks.any((mark) => mark.kind == KrepisInlineMarkKind.math);
  }

  @override
  Widget build(BuildContext context) {
    if (block.kind == KrepisFlowBlockKind.comment) {
      return const NotistNoteCommentPlaceholder(
        label: '註解',
        semanticLabel: '隱藏的 Markdown 註解',
      );
    }
    if (block.kind == KrepisFlowBlockKind.mathBlock) {
      return NotistNoteMathHost(
        builder: (_, style) => Math.tex(
          _displayMathSource(block.text),
          textStyle: style,
          onErrorFallback: (_) => Text(block.text, style: style),
        ),
      );
    }
    final mathMarks = block.marks
        .where((mark) => mark.kind == KrepisInlineMarkKind.math)
        .toList(growable: false);
    return NotistNoteMathHost(
      display: false,
      builder: (_, style) => RichText(
        text: TextSpan(
          style: style,
          children: _inlineMathSpans(block.text, mathMarks, style),
        ),
      ),
    );
  }

  List<InlineSpan> _inlineMathSpans(
    String source,
    List<KrepisInlineMarkProjection> marks,
    TextStyle style,
  ) {
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final mark in marks) {
      final begin = _stringIndexForUtf8(source, mark.beginByte);
      final end = _stringIndexForUtf8(source, mark.endByte);
      final opening = math.max(cursor, begin - 1);
      if (opening > cursor) {
        spans.add(TextSpan(text: source.substring(cursor, opening)));
      }
      final latex = source.substring(begin, end);
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: Math.tex(
            latex,
            textStyle: style,
            onErrorFallback: (_) => Text('\$$latex\$', style: style),
          ),
        ),
      );
      cursor = math.min(source.length, end + 1);
    }
    if (cursor < source.length) {
      spans.add(TextSpan(text: source.substring(cursor)));
    }
    return spans;
  }

  int _stringIndexForUtf8(String source, int byteOffset) {
    var bytes = 0;
    var stringIndex = 0;
    for (final rune in source.runes) {
      if (bytes >= byteOffset) break;
      bytes += utf8.encode(String.fromCharCode(rune)).length;
      stringIndex += rune > 0xFFFF ? 2 : 1;
    }
    if (bytes != byteOffset) {
      throw StateError('Krepis inline mark 未落在 UTF-8 scalar 邊界');
    }
    return stringIndex;
  }

  String _displayMathSource(String source) {
    if (source.length > 4 &&
        source.startsWith(r'$$') &&
        source.endsWith(r'$$')) {
      return source.substring(2, source.length - 2);
    }
    return source;
  }
}
