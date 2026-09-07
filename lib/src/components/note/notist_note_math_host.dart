// Notist 筆記數學內容 host。

import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis_foundation.dart';

/// 建立需要沿用 Kallopis editor typography 的外部內容 renderer。
typedef NotistNoteStyledContentBuilder =
    Widget Function(BuildContext context, TextStyle style);

/// 為外部數學 renderer 提供統一的 editor typography 與 display 對齊。
///
/// 本元件不解析 LaTeX，也不保存公式內容；[builder] 可使用任意 renderer。
final class NotistNoteMathHost extends StatelessWidget {
  const NotistNoteMathHost({
    super.key,
    required this.builder,
    this.display = true,
  });

  final NotistNoteStyledContentBuilder builder;
  final bool display;

  @override
  Widget build(BuildContext context) {
    final type = context.klp.type;
    final style = KlpTextStyles.definitionOf(KlpTextRole.editor, type)
        .toTextStyle(type)
        .copyWith(
          color: KlpTextStyles.colorFor(
            context.klpColors,
            role: KlpTextRole.editor,
          ),
        );
    final content = DefaultTextStyle(
      style: style,
      child: builder(context, style),
    );

    if (!display) return content;

    return Align(alignment: Alignment.center, child: content);
  }
}
