import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';

import 'nts_assistant_message.dart';

/// Notist AI 入口畫面：對話串 ＋ 輸入區。
///
/// 只做組合——對話串與輸入框都是 Kallopis 的無語意元件，這裡不決定任何視覺。
class NotistAssistantPage extends StatelessWidget {
  const NotistAssistantPage({
    super.key,
    required this.placeholder,
    required this.sendLabel,
    required this.attachLabel,
    this.messages = const <NtsAssistantMessage>[],
    this.draft,
    this.scopeTags = const <String>[],
    this.onDraftChanged,
    this.onSend,
    this.onAttach,
    this.loadOlderLabel,
    this.onLoadOlder,
  });

  final List<NtsAssistantMessage> messages;

  final String placeholder;
  final String sendLabel;
  final String attachLabel;

  final String? draft;

  /// 這則對話的範圍標記，例如「這則筆記」「整個專案」。
  final List<String> scopeTags;

  final ValueChanged<String>? onDraftChanged;
  final VoidCallback? onSend;
  final VoidCallback? onAttach;
  final String? loadOlderLabel;
  final VoidCallback? onLoadOlder;

  @override
  Widget build(BuildContext context) {
    final klp = context.klp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: messages.isEmpty
              ? const KlpEmptyState(
                  icon: KlpIcons.sparkles,
                  title: '還沒有對話',
                  message: '問一個關於這則筆記或整個專案的問題。',
                )
              : KlpScrollViewport(
                  child: Padding(
                    padding: EdgeInsets.all(klp.space.base),
                    child: KlpMessageThread(
                      loadOlderLabel: loadOlderLabel,
                      onLoadOlder: onLoadOlder,
                      messages: [
                        for (final message in messages)
                          KlpMessageBubble(
                            author: message.author,
                            timestamp: message.timestamp,
                            emphasized: !message.fromUser,
                            child: KlpText(
                              message.text,
                              role: KlpTextRole.body,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
        ),
        Padding(
          padding: EdgeInsets.all(klp.space.compact),
          child: KlpMessageComposer(
            placeholder: placeholder,
            sendLabel: sendLabel,
            attachLabel: attachLabel,
            tags: scopeTags,
            value: draft,
            onChanged: onDraftChanged,
            onSend: onSend ?? () {},
            onAttach: onAttach ?? () {},
          ),
        ),
      ],
    );
  }
}
