// Notist 筆記註解占位元件。

import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis_foundation.dart';

/// 隱藏原始註解內容時使用的唯讀視覺占位。
///
/// 註解內容與可見性規則由 Notist 決定；本元件只統一 placeholder 的文字層級。
final class NotistNoteCommentPlaceholder extends StatelessWidget {
  const NotistNoteCommentPlaceholder({
    super.key,
    this.label = 'Comment',
    this.semanticLabel,
  });

  final String label;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? label,
      child: ExcludeSemantics(
        child: KlpText(
          label,
          role: KlpTextRole.editor,
          tone: KlpTextTone.faint,
        ),
      ),
    );
  }
}
