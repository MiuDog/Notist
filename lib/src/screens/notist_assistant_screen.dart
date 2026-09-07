/// Notist 專案模組。

library;

import 'package:flutter/widgets.dart';

import '../components/assistant/notist_assistant_conversation.dart';
import '../components/assistant/nts_assistant_panel_record.dart';

/// Notist AI 畫面組裝入口。
final class NotistAssistantScreen extends StatelessWidget {
  const NotistAssistantScreen({
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
    return NotistAssistantConversation(
      record: record,
      onDraftChanged: onDraftChanged,
      onSend: onSend,
      onAttach: onAttach,
      onLoadOlder: onLoadOlder,
    );
  }
}
