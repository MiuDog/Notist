/// Notist 專案模組。

library;

import 'package:flutter/widgets.dart';

import '../components/journals/notist_journals_overview.dart';
import '../components/journals/nts_journals_overview_record.dart';
import '../journal/nts_journal_entry.dart';

/// Journals 畫面組裝入口。
final class NotistJournalsScreen extends StatelessWidget {
  const NotistJournalsScreen({
    super.key,
    required this.record,
    this.onPreviousMonth,
    this.onNextMonth,
    this.onToggleTodo,
  });

  final NtsJournalsOverviewRecord record;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;
  final ValueChanged<NtsTodoItem>? onToggleTodo;

  @override
  Widget build(BuildContext context) {
    return NotistJournalsOverview(
      record: record,
      onPreviousMonth: onPreviousMonth,
      onNextMonth: onNextMonth,
      onToggleTodo: onToggleTodo,
    );
  }
}
