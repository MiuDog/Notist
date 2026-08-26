import 'package:flutter/foundation.dart';

/// 一則與 Notist AI 的往來訊息。
///
/// 這是**筆記語意**的型別：訊息的「作者是誰、是不是自己說的」屬於這個產品的對話
/// 模型，而不是通用聊天元件該知道的事。
@immutable
class NtsAssistantMessage {
  const NtsAssistantMessage({
    required this.id,
    required this.author,
    required this.timestamp,
    required this.text,
    this.fromUser = false,
  });

  final String id;

  /// 顯示用的作者名。由產品決定怎麼稱呼——「你」或使用者名稱都由呼叫端給。
  final String author;

  /// 已格式化的時間，例如 `11:58`。格式屬於產品與語系。
  final String timestamp;

  final String text;

  /// 是不是使用者自己發的。決定氣泡要不要強調。
  final bool fromUser;
}
