/// Notist 專案模組。

library;

import '../../assistant/nts_assistant_message.dart';

/// Notist AI 面板所需的完整呈現資料。
///
/// 畫面組裝層在進入元件前完成資料投影，避免呼叫端各自傳入訊息、標籤與文字欄位，
/// 造成同一面板出現不完整或不一致的狀態。
final class NtsAssistantPanelRecord {
  const NtsAssistantPanelRecord({
    required this.placeholder,
    required this.sendLabel,
    required this.attachLabel,
    this.messages = const <NtsAssistantMessage>[],
    this.draft,
    this.scopeTags = const <String>[],
    this.loadOlderLabel,
  });

  final List<NtsAssistantMessage> messages;
  final String placeholder;
  final String sendLabel;
  final String attachLabel;
  final String? draft;
  final List<String> scopeTags;
  final String? loadOlderLabel;
}
