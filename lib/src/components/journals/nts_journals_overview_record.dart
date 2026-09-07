/// Notist 專案模組。

library;

import '../../journal/nts_journal_entry.dart';

/// Journals 總覽元件所需的完整呈現資料。
final class NtsJournalsOverviewRecord {
  const NtsJournalsOverviewRecord({
    required this.month,
    required this.monthLabel,
    required this.summaryLabel,
    required this.weekdayLabels,
    required this.previousMonthLabel,
    required this.nextMonthLabel,
    this.today,
    this.entries = const <NtsJournalEntry>[],
    this.todos = const <NtsTodoItem>[],
    this.schedule = const <NtsScheduleItem>[],
  });

  final DateTime month;
  final String monthLabel;
  final String summaryLabel;
  final List<String> weekdayLabels;
  final String previousMonthLabel;
  final String nextMonthLabel;
  final DateTime? today;
  final List<NtsJournalEntry> entries;
  final List<NtsTodoItem> todos;
  final List<NtsScheduleItem> schedule;
}
