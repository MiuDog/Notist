import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/notist.dart';

/// Notist 的 Flow 內容；沿用既有文字設計，只由 Kallopis 補上頁面底層。
class NotistFlowPage extends StatelessWidget {
  const NotistFlowPage({super.key, required this.noteTitle});

  final String noteTitle;

  @override
  Widget build(BuildContext context) {
    final klp = context.klp;

    return NtsPageBackground(
      key: const ValueKey('notist-flow-page'),
      style: NtsPageBackgroundStyle.plain,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxWidth < klp.geometry.layout.inlineNoticeBreakpoint;
          final horizontalPadding = compact
              ? klp.space.base
              : klp.space.pageLarge;

          return KlpScrollViewport(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: klp.space.section,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KlpText(noteTitle, role: KlpTextRole.display),
                SizedBox(height: klp.space.compact),
                const KlpText(
                  'TODAY · 10:24',
                  role: KlpTextRole.code,
                  tone: KlpTextTone.faint,
                ),
                SizedBox(height: klp.space.section),
                const KlpText(
                  'Keep the note close to the thought.',
                  role: KlpTextRole.lead,
                ),
                SizedBox(height: klp.space.base),
                const KlpText(
                  'There is no system to maintain here. Just a quiet place '
                  'to catch the useful things before they disappear.',
                  role: KlpTextRole.editor,
                  tone: KlpTextTone.muted,
                ),
                SizedBox(height: klp.space.section),
                const KlpText('A short list', role: KlpTextRole.section),
                SizedBox(height: klp.space.compact),
                const KlpText(
                  '— Send the draft before lunch\n'
                  '— Pick up coffee beans\n'
                  '— Walk without headphones\n'
                  '— Call home',
                  role: KlpTextRole.editor,
                ),
                SizedBox(height: klp.space.section),
                const KlpDivider(),
                SizedBox(height: klp.space.base),
                const KlpText(
                  'Small notes are allowed to stay small.',
                  role: KlpTextRole.editor,
                  tone: KlpTextTone.faint,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
