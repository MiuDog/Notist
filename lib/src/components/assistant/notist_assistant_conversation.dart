/// Notist 專案模組。

library;

import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis_experimental.dart';
import 'package:kallopis/kallopis_foundation.dart';

import 'nts_assistant_panel_record.dart';

/// Notist AI 對話元件。
///
/// 產品語意資料一律以 [NtsAssistantPanelRecord] 注入；Kallopis 只負責訊息串與輸入器的
/// 通用呈現及互動。
final class NotistAssistantConversation extends StatelessWidget {
  const NotistAssistantConversation({
    super.key,
    required this.record,
    this.onDraftChanged,
    this.onSend,
    this.onAttach,
    this.onLoadOlder,
  });

  final NtsAssistantPanelRecord record;
  final ValueChanged<String>? onDraftChanged;
  final VoidCallback? onSend;
  final VoidCallback? onAttach;
  final VoidCallback? onLoadOlder;

  @override
  Widget build(BuildContext context) {
    final klp = context.klp;
    final canCompose = onDraftChanged != null && onSend != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: record.messages.isEmpty
              ? const KlpEmptyState(
                  icon: KlpIcons.sparkles,
                  title: '還沒有對話',
                  message: '問一個關於這則筆記或整個專案的問題。',
                )
              : KlpScrollViewport(
                  child: Padding(
                    padding: EdgeInsets.all(klp.space.base),
                    child: KlpMessageThread(
                      loadOlderLabel: record.loadOlderLabel,
                      onLoadOlder: onLoadOlder,
                      messages: [
                        for (final message in record.messages)
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
        if (canCompose)
          Padding(
            padding: EdgeInsets.all(klp.space.tight),
            child: KlpMessageComposer(
              placeholder: record.placeholder,
              sendLabel: record.sendLabel,
              attachLabel: record.attachLabel,
              tags: record.scopeTags,
              value: record.draft,
              onChanged: onDraftChanged,
              onSend: onSend,
              onAttach: onAttach,
            ),
          )
        else
          Padding(
            padding: EdgeInsets.all(klp.space.tight),
            child: const KlpStatusIndicator(
              data: KlpStatusItemData(
                label: 'Notist AI 尚未連線',
                kind: KlpStatusKind.circle,
              ),
            ),
          ),
      ],
    );
  }
}
