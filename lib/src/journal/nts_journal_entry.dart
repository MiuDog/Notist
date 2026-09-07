/// Notist 專案模組。

library;

import 'package:flutter/foundation.dart';

/// 某一天的一則日誌條目。
///
/// 這是**筆記語意**的型別，屬於 Notist——Kallopis 的月曆不需要知道格子裡放的是
/// 待辦、排程還是別的東西，那正是它能被別的產品重用的原因。
@immutable
class NtsJournalEntry {
  const NtsJournalEntry({required this.date, required this.label});

  /// 條目所屬的日期。只有年月日有意義。
  final DateTime date;

  /// 顯示在月曆格子裡的一行字。
  final String label;
}

/// 一則待辦。
@immutable
class NtsTodoItem {
  const NtsTodoItem({
    required this.id,
    required this.label,
    required this.meta,
    this.done = false,
  });

  final String id;

  /// 待辦本身的敘述。
  final String label;

  /// 次要資訊，例如「筆記 · 今天」或「逾期 2 天」。
  ///
  /// 刻意是一段已經組好的字串而不是結構化欄位：什麼該顯示、怎麼措辭是產品的決定，
  /// 不該由呈現層拆解。
  final String meta;

  final bool done;
}

/// 一則排程。
@immutable
class NtsScheduleItem {
  const NtsScheduleItem({
    required this.id,
    required this.time,
    required this.label,
    required this.tag,
    this.tone = NtsScheduleTone.neutral,
  });

  final String id;

  /// 已格式化的時間，例如 `09:30`。格式屬於產品與語系，不由呈現層決定。
  final String time;

  final String label;

  /// 來源標記，例如「重複」「提醒」「行事曆」。
  final String tag;

  final NtsScheduleTone tone;
}

/// 排程來源的語意色調。
enum NtsScheduleTone { neutral, info, success, warning }
